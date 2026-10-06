@isTest
private class CaseAnnexControllerTest {


    @TestSetup
    static void setup() {
        Account genericAcc = (Account) TestDataFactory.createSObject(new Account(), true);

        Account fawriAcc = (Account) TestDataFactory.createSObject(
            new Account(
                CIF__pc        = '9991234',
                Region_Flag__c = 'Bahrain'
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );

        Id requestRtId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Request')
            .getRecordTypeId();

        Case genericCase = (Case) TestDataFactory.createSObject(new Case(AccountId = genericAcc.Id), true);

        Case fawriCase = (Case) TestDataFactory.createSObject(
            new Case(
                RecordTypeId                       = requestRtId,
                AccountId                          = fawriAcc.Id,
                ContactId                          = fawriAcc.PersonContactId,
                Type                               = 'Funds Transfer',
                Sub_Type__c                        = 'Fawri Cancellation Request',
                // cc_Request_Type__c                 = 'Cancellation Request',
                cc_Transaction_Reference_Number__c = 'TXN-ANNEX-01',
                New_Mobile_Number__c               = 'BATCH-ANNEX-01',
                Transaction_Date__c                = Date.today(),
                ccol_Hold_Account_IBAN__c          = 'IBAN_HOLD'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        Case fawriCaseMissingBatch = (Case) TestDataFactory.createSObject(
            new Case(
                RecordTypeId                       = requestRtId,
                AccountId                          = fawriAcc.Id,
                ContactId                          = fawriAcc.PersonContactId,
                Type                               = 'Funds Transfer',
                Sub_Type__c                        = 'Fawri Cancellation Request',
                // cc_Request_Type__c                 = 'Cancellation Request',
                cc_Transaction_Reference_Number__c = 'TXN-ANNEX-02',
                New_Mobile_Number__c               = null,
                Transaction_Date__c                = Date.today(),
                ccol_Hold_Account_IBAN__c          = 'IBAN_HOLD'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        insert new List<CaseAnnex__c>{
            new CaseAnnex__c(Case__c = genericCase.Id,           Fawri_Cancel_Api_Count__c = 0),
            new CaseAnnex__c(Case__c = fawriCase.Id,             Fawri_Cancel_Api_Count__c = 0),
            new CaseAnnex__c(Case__c = fawriCaseMissingBatch.Id, Fawri_Cancel_Api_Count__c = 0)
        };
    }


    private static void addCurrentUserToCheckerQueue() {
        List<Group> queues = [
            SELECT Id
            FROM   Group
            WHERE  DeveloperName = 'Checker_Fawri_Cancellation'
            AND    Type          = 'Queue'
            LIMIT  1
        ];
        if (!queues.isEmpty()) {
            insert new GroupMember(
                GroupId       = queues[0].Id,
                UserOrGroupId = UserInfo.getUserId()
            );
        }
    }


    private class FawriSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"meta":{"code":"TMSC-0000","message":"Cancellation submitted successfully"},"data":{}}');
            return res;
        }
    }

    private class FawriHttp200ButTmsc1003Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"meta":{"code":"TMSC-1003","message":"Could not submit cancelation request"}}');
            return res;
        }
    }

    private class FawriTmsc1003Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            res.setBody('{"meta":{"code":"TMSC-1003","message":"Could not submit cancelation request"}}');
            return res;
        }
    }

    private class FawriGenericFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Internal Server Error');
            res.setBody('{"error":"Unexpected server error"}');
            return res;
        }
    }


    @isTest
    static void testGetConfigJson() {
        List<Case_Annex__mdt> result = CaseAnnexController.getConfigJson(
            'Advance Payment',
            'New Loan / Finance Service Request',
            'LoanFinanceServiceRequest'
        );
        System.debug('result >> ' + result);
        System.assertNotEquals(null, result[0].JSON_Value__c);
    }

    @isTest
    static void testGetConfigJson_blankParams_throwsException() {
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.getConfigJson('', 'SomeType', 'SomeRT');
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'AuraHandledException expected for blank subtype');
    }


    @isTest
    static void testGetCaseAnnexId() {
        Case testCase = [SELECT Id FROM Case WHERE Type != 'Funds Transfer' LIMIT 1];
        List<String> result = CaseAnnexController.getCaseAnnexFields(testCase.Id);
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testGetCaseAnnexId_nullId_throwsException() {
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.getCaseAnnexFields(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'AuraHandledException expected for null record id');
    }


    @isTest
    static void testGetCaseSubtype() {
        Case testCase = [SELECT Id FROM Case WHERE Type != 'Funds Transfer' LIMIT 1];
        String result = CaseAnnexController.getCaseFields(testCase.Id);
        System.assertNotEquals(null, result, 'JSON result should not be null');
    }

    @isTest
    static void testGetCaseFields_nullId_throwsException() {
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.getCaseFields(null);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assertEquals(true, exceptionThrown, 'AuraHandledException expected for null record id');
    }


    @isTest
    static void testGetOwnerDeveloperName() {
        Group g = [SELECT Id, DeveloperName FROM Group WHERE Type = 'Queue' LIMIT 1];
        String devName = CaseAnnexController.getOwnerDeveloperName(g.Id);
        System.assertEquals(g.DeveloperName, devName, 'Should return correct DeveloperName');
    }


    @isTest
    static void testUpdateRecordsWithRollback_nonFawriCase_gateNotTriggered() {
        Case testCase      = [SELECT Id FROM Case WHERE Type != 'Funds Transfer' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id FROM CaseAnnex__c WHERE Case__c = :testCase.Id LIMIT 1];

        Test.startTest();
        Boolean fawriGateThrewException = false;
        try {
            CaseAnnexController.updateRecordsWithRollback(testCase, annex);
        } catch (AuraHandledException e) {
            fawriGateThrewException = true;
        } catch (Exception e) {
            System.debug('Non-gate exception (ignored): ' + e.getMessage());
        }
        Test.stopTest();

        System.assertEquals(false, fawriGateThrewException,
            'The Fawri cancellation gate must NOT fire for a non-Fawri Case');
    }


    @isTest
    static void testUpdateRecordsWithRollback_fawriApprove_userNotInCheckerQueue_throwsPermissionError() {
        Case c     = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN-ANNEX-01' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case patch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.startTest();
        Boolean exceptionThrown = false;
        String  exceptionMsg    = '';
        try {
            CaseAnnexController.updateRecordsWithRollback(patch, annex);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMsg    = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'AuraHandledException must be thrown when user is not in the checker queue');
        System.assert(
            String.isNotBlank(exceptionMsg),
            'Exception message should not be blank: ' + exceptionMsg
        );
    }

   

    @isTest
    static void testUpdateRecordsWithRollback_fawriApprove_tmsc1003Http400_throwsException() {
        addCurrentUserToCheckerQueue();

        Case c     = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN-ANNEX-01' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case patch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.setMock(HttpCalloutMock.class, new FawriTmsc1003Mock());

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.updateRecordsWithRollback(patch, annex);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'AuraHandledException must be thrown when cancellation API returns TMSC-1003 (HTTP 400)');

        Case dbCase = [SELECT cc_Checker_Result__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals('Approve', dbCase.cc_Checker_Result__c,
            'Case must NOT be persisted with Approve when callout fails');
    }


    @isTest
    static void testUpdateRecordsWithRollback_fawriApprove_http200ButTmsc1003_throwsException() {
        addCurrentUserToCheckerQueue();

        Case c     = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN-ANNEX-01' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case patch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.setMock(HttpCalloutMock.class, new FawriHttp200ButTmsc1003Mock());

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.updateRecordsWithRollback(patch, annex);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'AuraHandledException must be thrown even when HTTP 200 but body contains TMSC-1003');

        Case dbCase = [SELECT cc_Checker_Result__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals('Approve', dbCase.cc_Checker_Result__c,
            'Case must NOT be persisted with Approve on logical TMSC-1003 failure');
    }


    @isTest
    static void testUpdateRecordsWithRollback_fawriApprove_missingBatchId_throwsException() {
        addCurrentUserToCheckerQueue();

        Case c     = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN-ANNEX-02' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case patch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.startTest();
        Boolean exceptionThrown = false;
        String  exceptionMsg    = '';
        try {
            CaseAnnexController.updateRecordsWithRollback(patch, annex);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
            exceptionMsg    = e.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'AuraHandledException must be thrown when Batch ID is missing');
        System.assert(
            String.isNotBlank(exceptionMsg),
            'Exception message should not be blank');
    }


    @isTest
    static void testUpdateRecordsWithRollback_fawriApprove_http500_throwsException() {
        addCurrentUserToCheckerQueue();

        Case c     = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN-ANNEX-01' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case patch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.setMock(HttpCalloutMock.class, new FawriGenericFailureMock());

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.updateRecordsWithRollback(patch, annex);
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'AuraHandledException must be thrown when callout returns HTTP 500');
    }


    @isTest
    static void testUpdateRecordsWithRollback_fawriCase_nullCheckerResult_gateSkipped() {
        Case c     = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN-ANNEX-01' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case patch = new Case(Id = c.Id, cc_Checker_Result__c = null);

        Test.startTest();
        Boolean fawriGateThrewException = false;
        try {
            CaseAnnexController.updateRecordsWithRollback(patch, annex);
        } catch (AuraHandledException e) {
            fawriGateThrewException = true;
        } catch (Exception e) {
            System.debug('Non-gate exception (ignored): ' + e.getMessage());
        }
        Test.stopTest();

        System.assertEquals(false, fawriGateThrewException,
            'The Fawri gate must NOT fire when cc_Checker_Result__c is null');
    }
}