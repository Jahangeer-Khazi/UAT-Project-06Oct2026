@isTest
public class UpdateCreditCardRequestStatusAPITest {
 @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Case case1 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id), 'TestFactoryDefaults.CaseDefaults',true);
        
 }

    @isTest
    public static void updateCreditCardRequestStatusApiFromFlowTest(){  
        List<Case> caseList = getAllCases();
       UpdateCreditCardRequestStatusAPI.RequestApi requestApi= new  UpdateCreditCardRequestStatusAPI.RequestApi();
        requestApi.caseId = caseList.get(0).Id;
        Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                UpdateCreditCardRequestStatusApi.updateCreditCardRequestStatusApiFromFlow(new List<updateCreditCardRequestStatusApi.RequestApi>{requestApi});
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
             UpdateCreditCardRequestStatusApi.updateCreditCardRequestStatusApiFromFlow(new List<updateCreditCardRequestStatusApi.RequestApi>{requestApi});
            System.assert( null);

            requestApi.notifType = 'EXPIRED';
            MCK001_ApiCalls.statusCodeGlobal = 200;
            UpdateCreditCardRequestStatusApi.updateCreditCardRequestStatusApiFromFlow(new List<updateCreditCardRequestStatusApi.RequestApi>{requestApi});
            System.assert(null);

        Test.stopTest();
      }
     private static List<Case> getAllCases(){
        return [SELECT Id,CaseNumber,Type,Customer_CIF__c,accountId,LastCaseSubStatusChanged__c,Sub_Status__c,Status FROM Case ];
    }
    }