/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 26-03-2026
*      Description : Test Class for CreditCardCacheQueuableAPI Class
*      Change History: 
*/
@isTest
public class CreditCardCacheQueuableAPITest {
     private class GenericHttpMock implements HttpCalloutMock {

        Integer statusCode;
        String responseBody;

        GenericHttpMock(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
    @isTest
    static void unitTest1() {
        Account acc = new Account(FirstName = 'Test',LastName = 'CustomerFrank',PersonEmail = 'test@test.com',CIF__pc = '123456',ID_Type__pc = 'Bahraini ID',
                                  ID_Number__pc = 'CPR123',ID_Expiry_Date__pc = System.today().addYears(1),iGA_Passport_Number__pc = 'PASS123');
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Convert Credit Card').getRecordTypeId();
        Case cse = new Case(RecordTypeId = recordTypeId,AccountId = acc.Id,Status = 'New',Sub_Status__c = 'In-Progress',Type = 'Convert Credit Card Nature Application',
                            Sub_Type__c = 'Convert to Unsecured',cc_Name_on_the_Card__c = 'Test CustomerFrank',cc_Credit_Card_PCI_Number__c = 'PCI123542143535',PrimaryCardProductConfigurationId__c = '16',
                            Region_Flag__c = 'Bahrain',Case_Model__c = 'ila');
        insert cse;
        List<Case> cseList = new List<Case>();
        cseList.add(cse);
        
        Test.setMock(HttpCalloutMock.class, new GenericHttpMock(200, 'SUCCESS'));
        Test.startTest();
        System.enqueueJob(new CreditCardCacheQueuableAPI(new Set<Id>(new Map<Id, Case>(cseList).keySet())));
        Test.stopTest();
    }

}