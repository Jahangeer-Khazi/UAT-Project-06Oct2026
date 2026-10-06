/**
 *  #CH01# Added by Amina BENABDELKRIM  20-06-2022 *** adding case model parameter to the method 
 */
@isTest
public class LTNG004_AccountClosureControllerTest {

    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ac_AccountClosure').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }

    
    @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
            Id acRecordTypeId = LTNG004_AccountClosureController.getAccRequestCaseRecordType();
            System.assert(acRecordTypeId != null);
        Test.stopTest();
    }

    @isTest
    public static void getAccountToCloseViaApiTest(){   
        Test.startTest();
            Id accId = [SELECT Id FROM Account LIMIT 1].Id;

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                List<LTNG004_AccountClosureController.AccountToCloseDetails> accList = LTNG004_AccountClosureController.getAccountToCloseViaApi(accId,null);//CH01
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<LTNG004_AccountClosureController.AccountToCloseDetails> accList1 = LTNG004_AccountClosureController.getAccountToCloseViaApi(accId,null);//CH01
            System.assert(accList1 != null);
        Test.stopTest();
    }  


    @isTest
    public static void updateCheckerSection500Test(){   
        List<Case> caseList = getAllCases();
        Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 500;
            String res = LTNG004_AccountClosureController.updateCheckerSection(caseList.get(0).Id,'Accept','test');
            System.assert(res != '');

        Test.stopTest();
    }

    @isTest
    public static void updateCheckerSection403Test(){   
        List<Case> caseList = getAllCases();
        Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 403;
            String res = LTNG004_AccountClosureController.updateCheckerSection(caseList.get(0).Id,'Accept','test');
            System.assert(res == null);

        Test.stopTest();
    }

    @isTest
    public static void updateCheckerSection200Test(){   
        List<Case> caseList = getAllCases();
        Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 200;
            String res = LTNG004_AccountClosureController.updateCheckerSection(caseList.get(0).Id,'Accept','test');
            System.assert(res == null);

        Test.stopTest();
    }


    private static List<Case> getAllCases(){
        return [SELECT Id,ac_Iban__c,Customer_CIF__c,accountId,ac_EligibleToClose__c,ac_IneligibilityReasons__c,Sub_Status__c,Status FROM Case ];
    }

}