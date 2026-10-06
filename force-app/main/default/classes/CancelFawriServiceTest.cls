@IsTest
public class CancelFawriServiceTest {

    @TestSetup
    static void setup() {
        Account acc = (Account) TestDataFactory.createSObject(
            new Account(
                CIF__pc         = '7778789',
                Region_Flag__c  = 'Bahrain'
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );
            Id requestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                                      .get('Request').getRecordTypeId();


        Case c1 = (Case) TestDataFactory.createSObject(
            new Case(
                RecordTypeId                       = requestRecordTypeId,
                AccountId                          = acc.Id,
                ContactId                          = acc.PersonContactId,
                Type                               = 'Funds Transfer',
                Sub_Type__c                        = 'Fawri Cancellation Request',
                // cc_Request_Type__c                 = 'Cancellation Request',
                cc_Transaction_Reference_Number__c = 'TXN001',
                New_Mobile_Number__c               = 'BATCH001',
                Transaction_Date__c                = Date.today(),
                ccol_Hold_Account_IBAN__c          = 'IBAN_HOLD'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        Case c2 = (Case) TestDataFactory.createSObject(
            new Case(
                RecordTypeId                       = requestRecordTypeId,
                AccountId                          = acc.Id,
                ContactId                          = acc.PersonContactId,
                Type                               = 'Funds Transfer',
                Sub_Type__c                        = 'Fawri Cancellation Request',
                // cc_Request_Type__c                 = 'Cancellation Request',
                cc_Transaction_Reference_Number__c = 'TXN002',
                New_Mobile_Number__c               = 'BATCH002',
                Transaction_Date__c                = Date.today(),
                ccol_Hold_Account_IBAN__c          = 'IBAN_HOLD'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        insert new List<CaseAnnex__c>{
            new CaseAnnex__c(Case__c = c1.Id, Fawri_Cancel_Api_Count__c = 0),
            new CaseAnnex__c(Case__c = c2.Id, Fawri_Cancel_Api_Count__c = 0)
        };
    }


    private class FawriSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('');
            return res;
        }
    }

    private class FawriSuccessWithBodyMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"meta":{"code":"TMSC-0000","message":"Cancellation submitted successfully"},"data":{}}');
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

    private class FawriHttp200ButTmsc1003Mock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
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


    @IsTest
    static void testCallCancelSync_emptyBody200_isSuccess() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new FawriSuccessMock());

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(true, result.isSuccess, 'Empty-body HTTP 200 should be treated as success');

        CaseAnnex__c annex = [SELECT Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id];
        System.assertEquals(1, annex.Fawri_Cancel_Api_Count__c, 'API count should be incremented to 1');

        List<System_Action__c> actions = [SELECT Action__c, Type__c FROM System_Action__c
                                          WHERE Action__c = 'Cancel Fawri Transaction'];
        System.assertEquals(1, actions.size(), 'One System_Action__c log should be created');
     }

    @IsTest
    static void testCallCancelSync_missingRefNumber() {
        Case c = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN001' LIMIT 1];
        c.cc_Transaction_Reference_Number__c = null;
        update c;

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess, 'Should fail when Transaction Reference Number is missing');
        System.assertEquals('MISSING_REF_NUMBER', result.metaCode, 'metaCode should indicate missing ref number');
    }


    @IsTest
    static void testCallCancelSync_success() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new FawriSuccessWithBodyMock());

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(true,  result.isSuccess, 'Result should be success');
        System.assertEquals('TMSC-0000', result.metaCode, 'Meta code should be TMSC-0000');
        System.assertEquals('Cancellation submitted successfully', result.message, 'Message should match');

        CaseAnnex__c annex = [SELECT Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id];
        System.assertEquals(1, annex.Fawri_Cancel_Api_Count__c, 'API count should be incremented');

        List<System_Action__c> actions = [SELECT Action__c FROM System_Action__c
                                          WHERE Action__c = 'Cancel Fawri Transaction'];
        System.assertEquals(1, actions.size(), 'One system action log should be created');
    }


    @IsTest
    static void testCallCancelSync_tmsc1003Failure_http400() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new FawriTmsc1003Mock());

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess, 'Result should be failure on HTTP 400 with TMSC-1003');
        System.assertEquals('TMSC-1003', result.metaCode, 'Meta code should be TMSC-1003');
        System.assertEquals('Could not submit cancelation request', result.message, 'Message should match NeoBank error');

        Case checkerCheck = [SELECT cc_Checker_Result__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals('Approve', checkerCheck.cc_Checker_Result__c,
            'cc_Checker_Result__c must NOT be Approve when callout fails');
    }


    @IsTest
    static void testCallCancelSync_http200ButTmsc1003BodyIsFailure() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new FawriHttp200ButTmsc1003Mock());

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess,
            'isSuccess must be FALSE even on HTTP 200 when meta.code is TMSC-1003');
        System.assertEquals('TMSC-1003', result.metaCode,
            'metaCode should be TMSC-1003');
        System.assertEquals('Could not submit cancelation request', result.message,
            'Message should match what NeoBank returned in the body');

        Case checkerCheck = [SELECT cc_Checker_Result__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals('Approve', checkerCheck.cc_Checker_Result__c,
            'cc_Checker_Result__c must NOT be Approve when meta.code indicates failure');
    }


    @IsTest
    static void testCallCancelSync_genericFailure() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new FawriGenericFailureMock());

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess, 'Result should be failure for HTTP 500');
        System.assert(String.isNotBlank(result.message), 'Failure message should not be blank');
    }


    @IsTest
    static void testCallCancelSync_missingBatchId() {
        Case c = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN001' LIMIT 1];
        c.New_Mobile_Number__c = null;
        update c;

        Test.startTest();
        CancelFawriService.CancelResult result = CancelFawriService.callCancelSync(c.Id);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess, 'Should fail when Batch ID is missing');
        System.assertEquals('MISSING_BATCH_ID', result.metaCode, 'metaCode should indicate missing batch ID');
    }


    @IsTest
    static void testUpdateRecordsWithRollback_fawriGate_tmsc1003BlocksUpdate() {
        Case c = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN001' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case casePatch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.setMock(HttpCalloutMock.class, new FawriTmsc1003Mock());

        Test.startTest();
        Boolean exceptionThrown = false;
        String exceptionMsg = '';
        try {
            CaseAnnexController.updateRecordsWithRollback(casePatch, annex);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
            exceptionMsg = ex.getMessage();
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown, 'AuraHandledException must be thrown on TMSC-1003');
        System.assert(exceptionMsg.contains('TMSC-1003') || exceptionMsg.contains('could not be submitted') || exceptionMsg.contains('Script-thrown exception'),
            'Exception message should reference the NeoBank error code or description');

        Case dbCase = [SELECT cc_Checker_Result__c FROM Case WHERE Id = :c.Id];
        System.assertNotEquals('Approve', dbCase.cc_Checker_Result__c,
            'cc_Checker_Result__c must NOT be Approve after a failed callout');
    }

    @IsTest
    static void testUpdateRecordsWithRollback_fawriGate_successAllowsUpdate() {
        Case c = [SELECT Id FROM Case WHERE cc_Transaction_Reference_Number__c = 'TXN002' LIMIT 1];
        CaseAnnex__c annex = [SELECT Id, Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id LIMIT 1];

        Case casePatch = new Case(Id = c.Id, cc_Checker_Result__c = 'Approve');

        Test.setMock(HttpCalloutMock.class, new FawriSuccessWithBodyMock());

        Test.startTest();
        Boolean exceptionThrown = false;
        try {
            CaseAnnexController.updateRecordsWithRollback(casePatch, annex);
        } catch (Exception ex) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, exceptionThrown, 'No exception should be thrown on a successful callout');

        Case dbCase = [SELECT cc_Checker_Result__c, Last_Api_Call_Status__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Approve', dbCase.cc_Checker_Result__c,
            'cc_Checker_Result__c should be Approve after a successful callout');
        System.assertEquals('Success', dbCase.Last_Api_Call_Status__c,
            'Last_Api_Call_Status__c should be Success after callout');
    }
}