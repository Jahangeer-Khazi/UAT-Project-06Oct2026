@IsTest
private class KYCVerificationHandlerUpdateAPITest {

    // -------------------- Test Data --------------------
    @testSetup
    static void setupData() {
        // Create a Person Account (handler references __pc fields on Account)
        Account pa = new Account();
        pa.RecordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account' AND IsPersonType = true
            LIMIT 1
        ].Id;
        pa.FirstName = 'KYC';
        pa.LastName  = 'Updater';
        pa.PersonEmail = 'kyc.updater@abcbank.com';
        pa.Region_Flag__pc = 'Bahrain';
        pa.CIF__pc = '111010';
        pa.Subscription_Model__pc = 'both';
        pa.x_canary__pc = 'N';
        pa.Mobile_Phone_Check__pc = 'Y';
        insert pa;

        // KYC #1 → L3 disabled (false): will use buildRequestBodyUpdate and updateKycStatusUpdate
        KYC_Verification__c kycL2 = new KYC_Verification__c();
        kycL2.Account_Name__c = pa.Id;
      //  kycL2.CIF__c = 'CIF-PA-010';
        kycL2.case_Model__c = 'alburaq'; // to hit region += '_alburaq'
        kycL2.Type__c = 'KYC_PERIODIC_REVIEW';
        kycL2.Sub_Type__c = 'Custom Configurations';
        kycL2.Overdue_Handling__c = 'Level 2 - App (Nudges) & Notifications';
        kycL2.Overdue_Stage_Enable_L3__c = false;
        kycL2.No_of_days__c = 10;
        kycL2.Status__c = 'Open';
        insert kycL2;

        // KYC #2 → L3 enabled (true): will use buildRequestBodyUpdateOverdue and updateKycStatusUpdateOverdueStage
        KYC_Verification__c kycL3 = new KYC_Verification__c();
        kycL3.Account_Name__c = pa.Id;
     //   kycL3.CIF__c = 'CIF-PA-011';
        kycL3.case_Model__c = 'alburaq';
        kycL3.Type__c = 'KYC_PERIODIC_REVIEW';
        kycL3.Sub_Type__c = 'Custom Configurations';
        kycL3.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        kycL3.Overdue_Stage_Enable_L3__c = true;
        kycL3.No_of_days__c = 20;
        kycL3.Status__c = 'Open';
        insert kycL3;
    }

    // -------------------- Callout Mocks --------------------
    private class OkMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('PUT', req.getMethod(), 'Should use PUT');
            System.assert(req.getEndpoint().contains('/api/v1/kyc-verification'), 'Endpoint should be /api/v1/kyc-verification');
            HttpResponse r = new HttpResponse();
            r.setStatusCode(200);
            r.setBody('{"status":"success"}');
            return r;
        }
    }
    private class ErrorMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse r = new HttpResponse();
            r.setStatusCode(500);
            r.setBody('{"status":"error","message":"Internal Server Error"}');
            return r;
        }
    }
    private class ThrowMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Simulate a transport/timeout error
            throw new System.CalloutException('Simulated callout failure');
        }
    }

    // -------------------- Tests --------------------

    @IsTest
    static void testSuccess_L3Disabled() {
        Id targetId = [
            SELECT Id FROM KYC_Verification__c
            WHERE Overdue_Stage_Enable_L3__c = false
            LIMIT 1
        ].Id;

        Test.setMock(HttpCalloutMock.class, new OkMock());

        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerUpdateAPI(new Set<Id>{ targetId }));
        Test.stopTest();

        // Success path logs a system action
        Integer actions = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actions > 0, 'Should log a System Action for success (L3 disabled).');
    }

    @IsTest
    static void testSuccess_L3Enabled() {
        Id targetId = [
            SELECT Id FROM KYC_Verification__c
            WHERE Overdue_Stage_Enable_L3__c = true
            LIMIT 1
        ].Id;

        Test.setMock(HttpCalloutMock.class, new OkMock());

        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerUpdateAPI(new Set<Id>{ targetId }));
        Test.stopTest();

        // Success path logs a system action
        Integer actions = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actions > 0, 'Should log a System Action for success (L3 enabled).');
    }

    @IsTest
    static void testNon200Response_Bulk() {
        // Use both records to validate bulk handling and non-200 logging
        Set<Id> idsToProcess = new Set<Id>();
        for (KYC_Verification__c k : [SELECT Id FROM KYC_Verification__c LIMIT 2]) {
            idsToProcess.add(k.Id);
        }

        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerUpdateAPI(idsToProcess));
        Test.stopTest();

        // Non-200 should create a system action per record
        Integer actions = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actions >= 2, 'Should log at least one System Action per KYC for non-200 responses.');
    }

    @IsTest
    static void testExceptionBranch() {
        Id targetId = [SELECT Id FROM KYC_Verification__c LIMIT 1].Id;

        Test.setMock(HttpCalloutMock.class, new ThrowMock());

        Test.startTest();
        System.enqueueJob(new KYCVerificationHandlerUpdateAPI(new Set<Id>{ targetId }));
        Test.stopTest();

        // Exception path should log a system action
        Integer actions = [SELECT COUNT() FROM KYC_System_Action__c];
        System.assert(actions > 0, 'Exception should be logged as a KYC_System_Action__c.');
    }
}