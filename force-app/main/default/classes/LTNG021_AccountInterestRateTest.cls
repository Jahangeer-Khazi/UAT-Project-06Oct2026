@isTest
public class LTNG021_AccountInterestRateTest {
 @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AIR_AccountInterestRate').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',RHA_AccountType__c='HASSALA'),'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
            Id acRecordTypeId = LTNG021_AccountInterestRateController.getAccRequestCaseRecordType();
            System.assert(acRecordTypeId != null);
        Test.stopTest();
    }
     @isTest
    public static void getAccountForInterestRateViaApiTest(){   
        Test.startTest();
            Id accId = [SELECT Id FROM Account LIMIT 1].Id;

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                List<LTNG021_AccountInterestRateController.AccountForInterestDetails> accList = LTNG021_AccountInterestRateController.getAccountForInterestRateViaApi(accId,null);//CH01
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<LTNG021_AccountInterestRateController.AccountForInterestDetails> accList1 = LTNG021_AccountInterestRateController.getAccountForInterestRateViaApi(accId,null);//CH01
            System.assert(accList1 != null);
        Test.stopTest();
    }
     @isTest
    public static void UpdateAccountDetailsAPIFromFlowTest(){   
        List<Case> caseList = getAllCases();
       
        Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                LTNG021_AccountInterestRateController.UpdateAccountDetailsAPIFromFlow(new List<Id>{caseList.get(0).Id});
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<String> tt = LTNG021_AccountInterestRateController.UpdateAccountDetailsAPIFromFlow(new List<Id>{caseList.get(0).Id});
            System.assert(tt == null);

            
        Test.stopTest();
    }
   

    private static List<Case> getAllCases(){
        return [SELECT Id,CaseNumber,ac_Iban__c,Customer_CIF__c,accountId,ac_EligibleToClose__c,ac_IneligibilityReasons__c,Sub_Status__c,Status,RHA_AccountType__c FROM Case ];
    }
}