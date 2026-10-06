@IsTest
public class CaseFawriTransferControllerTest {


    @TestSetup
    static void setup() {
        Account acc = (Account) TestDataFactory.createSObject(
            new Account(
                CIF__pc         = '12345',
                Region_Flag__c  = 'Bahrain'
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );

        Id requestRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                                      .get('Request').getRecordTypeId();

        Case c = (Case) TestDataFactory.createSObject(
            new Case(
                RecordTypeId                       = requestRecordTypeId,
                AccountId                          = acc.Id,
                ContactId                          = acc.PersonContactId,
                cc_Transaction_Reference_Number__c = 'TXN-CTRL-001',
                New_Mobile_Number__c               = 'BATCH-CTRL-001',
                Transaction_Date__c                = Date.today(),
                ccol_Hold_Account_IBAN__c          = 'JO12BLOM0000000000001234567890'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        insert new CaseAnnex__c(
            Case__c                   = c.Id,
            Fawri_Cancel_Api_Count__c = 0
        );
    }


    private class ListSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"data":[{"id":"TX1"},{"id":"TX2"}]}');
            return res;
        }
    }

    private class EmptyBodySuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('');
            return res;
        }
    }

    private class CancelSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"meta":{"code":"TMSC-0000","message":"Cancelled OK"},"data":{}}');
            return res;
        }
    }

    private class CancelFailureMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(400);
            res.setStatus('Bad Request');
            res.setBody('{"meta":{"code":"TMSC-1003","message":"Could not submit cancelation request"}}');
            return res;
        }
    }

    private class ServerErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setStatus('Internal Server Error');
            res.setBody('Unexpected server error');
            return res;
        }
    }


    @IsTest
    static void testGetFawriTransferList_success() {
        Test.setMock(HttpCalloutMock.class, new ListSuccessMock());

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.getFawriTransferList('CIF12345', 'Jordan');
        Test.stopTest();

        System.assertEquals(true, resp.isSuccess, 'Response should be successful on HTTP 200');
        System.assertNotEquals(null, resp.responseData, 'Response data should not be null');
    }

    @IsTest
    static void testGetFawriTransferList_emptyBody() {
        Test.setMock(HttpCalloutMock.class, new EmptyBodySuccessMock());

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.getFawriTransferList('CIF12345', 'Jordan');
        Test.stopTest();

        System.assertEquals(true, resp.isSuccess, 'HTTP 200 with empty body should still be success');
    }

    @IsTest
    static void testGetFawriTransferList_httpFailure() {
        Test.setMock(HttpCalloutMock.class, new ServerErrorMock());

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.getFawriTransferList('CIF12345', 'Jordan');
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess, 'Response should be failure on HTTP 500');
    }





    @IsTest
    static void testGetCaseDetails_returnsCase() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        Case result = CaseFawriTransferController.getCaseDetails(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'getCaseDetails should return a Case record');
        System.assertEquals(c.Id, result.Id, 'Returned Case Id should match requested Id');
    }


    @IsTest
    static void testGetFawriApiCount_returnsAnnex() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        CaseAnnex__c annex = CaseFawriTransferController.getFawriApiCount(c.Id);
        Test.stopTest();

        System.assertNotEquals(null, annex, 'getFawriApiCount should return a CaseAnnex record');
        System.assertEquals(0, annex.Fawri_Cancel_Api_Count__c, 'Initial Fawri API count should be 0');
    }


    @IsTest
    static void testCancelFawriTransaction_success() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CancelSuccessMock());

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.cancelFawriTransaction(c.Id);
        Test.stopTest();

        System.assertEquals(true, resp.isSuccess, 'Cancellation should succeed on HTTP 200');

        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Success', updatedCase.Last_Api_Call_Status__c,
            'Last_Api_Call_Status__c should be Success after successful cancellation');

        CaseAnnex__c annex = [SELECT Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id];
        System.assertEquals(1, annex.Fawri_Cancel_Api_Count__c, 'API count should be incremented to 1');

        List<System_Action__c> actions = [SELECT Action__c, Type__c FROM System_Action__c
                                          WHERE Action__c = 'Cancel Fawri Transaction'];
        System.assertEquals(1, actions.size(), 'One System_Action__c log should be created');
  
        
    }

    @IsTest
    static void testCancelFawriTransaction_httpFailure() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new CancelFailureMock());

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.cancelFawriTransaction(c.Id);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess, 'Cancellation should fail on HTTP 400');

        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('Failed', updatedCase.Last_Api_Call_Status__c,
            'Last_Api_Call_Status__c should be Failed on non-200 response');

        CaseAnnex__c annex = [SELECT Fawri_Cancel_Api_Count__c FROM CaseAnnex__c WHERE Case__c = :c.Id];
        System.assertEquals(1, annex.Fawri_Cancel_Api_Count__c,
            'API count should still be incremented even on failure');
    }

    @IsTest
    static void testCancelFawriTransaction_serverError() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new ServerErrorMock());

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.cancelFawriTransaction(c.Id);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess, 'Should be failure on HTTP 500');
    }

    @IsTest
    static void testCancelFawriTransaction_missingBatchId() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Case c = (Case) TestDataFactory.createSObject(
            new Case(
                AccountId                          = acc.Id,
                cc_Transaction_Reference_Number__c = 'TXN-NO-BATCH',
                Transaction_Date__c                = Date.today(),
                ccol_Hold_Account_IBAN__c          = 'JO00TEST'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        insert new CaseAnnex__c(Case__c = c.Id, Fawri_Cancel_Api_Count__c = 0);

        Test.startTest();
        ApiConnection.Response resp = CaseFawriTransferController.cancelFawriTransaction(c.Id);
        Test.stopTest();

        System.assertEquals(false, resp.isSuccess, 'Should fail when Batch ID is missing');
        System.assert(
            String.valueOf(resp.errorData).contains('Batch ID'),
            'Error data should mention the missing Batch ID'
        );
    }


    @IsTest
    static void testSendFawriCancellationEmail_noPersonEmail_noException() {
        Case c = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        Boolean exThrown = false;
        try {
            CaseFawriTransferController.sendFawriCancellationEmail(c.Id);
        } catch (Exception ex) {
            exThrown = true;
        }
        Test.stopTest();

        System.assertEquals(false, exThrown,
            'sendFawriCancellationEmail should not throw when no email template or address is found');
    }
}