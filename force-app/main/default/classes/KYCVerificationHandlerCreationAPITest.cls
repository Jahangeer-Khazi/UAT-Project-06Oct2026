@IsTest
private class KYCVerificationHandlerCreationAPITest {
    // ---------- Test data setup ----------
    @testSetup
    static void setupData() {
        // Create a Person Account for linkage (adjust if Person Accounts not enabled)
        Account a = new Account();
        a.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;
        a.LastName = 'Test Person';
        a.FirstName = 'KYC';
        a.PersonEmail = 'person@test.abc ';
        // Custom person-account fields referenced in handler (adjust if different)
        a.Region_Flag__pc = 'Bahrain';
        a.CIF__pc = '12345';
        a.Subscription_Model__pc = 'both';
        a.x_canary__pc = 'N';
        a.Mobile_Phone_Check__pc = '+973234567654';
        insert a;
        
        // KYC record that WILL trigger notification (Overdue_Handling__c != Level 1 ...)
        KYC_Verification__c kycOk = new KYC_Verification__c();
        kycOk.Account_Name__c = a.Id;
        //kycOk.CIF__c = 'CIF-12345';
        kycOk.case_Model__c = 'alburaq'; // to hit regionName += '_alburaq'
         kycOk.Type__c = 'KYC_PERIODIC_REVIEW';
        // kycOk.case_Model__c='ila',
           kycOk.Sub_Type__c = 'Custom Configurations';
            kycOk.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';

        //kycOk.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        kycOk.No_of_days__c = 5;
        kycOk.Status__c = 'Open';
        insert kycOk;
        
        // KYC record that SKIPS notification (Overdue_Handling__c = Level 1 - App (Nudges))
        KYC_Verification__c kycNoNotify = new KYC_Verification__c();
        kycNoNotify.Account_Name__c = a.Id;
      //  kycNoNotify.CIF__c = 'CIF-999';
        kycNoNotify.case_Model__c = 'alburaq';
        kycNoNotify.Type__c = 'KYC_PERIODIC_REVIEW';
        kycNoNotify.Sub_Type__c = 'Custom Configurations';
        kycNoNotify.Overdue_Handling__c = 'Level 2 - App (Nudges) & Notifications';
        kycNoNotify.No_of_days__c = 3;
        kycNoNotify.Status__c = 'Open';
        insert kycNoNotify;
    }
    
    // ---------- Callout Mocks ----------
    // 200 OK mock
    private class KycOkMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod(), 'Method should be POST');
            System.assert(req.getEndpoint().contains('/api/v1/kyc-verification'), 'Endpoint mismatch');
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}');
            return res;
        }
    }
    // 500 error mock
    private class KycErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"status":"error","message":"Internal Server Error"}');
            return res;
        }
    }
    // Exception mock
    private class KycThrowMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate transport/timeout error
            throw new System.CalloutException('Simulated callout failure');
        }
    }
    
    // ---------- Tests ----------
    @IsTest
    static void testSuccessAndSkipNotificationBranch() {
        // Use only the record that SKIPS notification and receives 200 OK
        Id kycId = [SELECT Id FROM KYC_Verification__c WHERE Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' LIMIT 1].Id;
        
        Test.setMock(HttpCalloutMock.class, new KycOkMock());
        
        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerCreationAPI(new Set<Id>{ kycId }));
        Test.stopTest();
        
        // Assert a System Action was created
        List<KYC_System_Action__c> actions = [
            SELECT Id , Method__c
            FROM KYC_System_Action__c
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
        System.assert(actions.size() > 0, 'System Action should be created on 200 response');
        
        // We cannot assert internal notification side-effect for SKIP scenario,
        // but code path executed without exception is validated by coverage.
    }
    
    @IsTest
    static void testSuccessAndNotificationBranch() {
        // Use the record that triggers notification and receives 200 OK
        Id kycId = [SELECT Id FROM KYC_Verification__c WHERE Overdue_Handling__c != 'Level 3 - App (Nudges & Splash), Notifications & Restrictions' LIMIT 1].Id;
        
        Test.setMock(HttpCalloutMock.class, new KycOkMock());
        
        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerCreationAPI(new Set<Id>{ kycId }));
        Test.stopTest();
        
        // System Action must be created; notification path executed
        Integer actionCount = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actionCount > 0, 'System Action should be created on success branch');
    }
    
    @IsTest
    static void testNon200ResponseBranch() {
        // Use both records to test bulk handling with a non-200 response
        Set<Id> idsToProcess = new Set<Id>();
        for (KYC_Verification__c k : [SELECT Id FROM KYC_Verification__c LIMIT 2]) {
            idsToProcess.add(k.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new KycErrorMock());
        
        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerCreationAPI(idsToProcess));
        Test.stopTest();
        
        // Non-200 should still log System Actions
        Integer actionCount = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actionCount >= 2, 'Should create at least one action per record for non-200');
    }
    
    @IsTest
    static void testExceptionBranch() {
        // Trigger the exception catch block via Mock
        Id kycId = [SELECT Id FROM KYC_Verification__c LIMIT 1].Id;
        
        Test.setMock(HttpCalloutMock.class, new KycThrowMock());
        
        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerCreationAPI(new Set<Id>{ kycId }));
        Test.stopTest();
        
        // An exception-based System Action should be created
        Integer actionCount = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actionCount > 0, 'Exception should log a KYC_System_Action__c');
    }
}