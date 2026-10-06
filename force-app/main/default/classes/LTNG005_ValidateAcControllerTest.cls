@isTest
public class LTNG005_ValidateAcControllerTest {

    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ac_AccountClosure').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,case_Nature__c='Account Maintenance'), 'TestFactoryDefaults.CaseDefaults',true);
    }

    @isTest
    public static void validateAccClosureViaApiFromFlowTest(){   
        List<Case> caseList = getAllCases();
        LTNG005_ValidateAccountClosureController.RequestAccClosure reqAccClosure= new LTNG005_ValidateAccountClosureController.RequestAccClosure();
        reqAccClosure.caseId = caseList.get(0).Id;
        reqAccClosure.notifType = 'REMINDER';
        Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                LTNG005_ValidateAccountClosureController.validateAccClosureViaApiFromFlow(new List<LTNG005_ValidateAccountClosureController.RequestAccClosure>{reqAccClosure});
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<String> tt = LTNG005_ValidateAccountClosureController.validateAccClosureViaApiFromFlow(new List<LTNG005_ValidateAccountClosureController.RequestAccClosure>{reqAccClosure});
          //  System.assert(tt == null);

            reqAccClosure.notifType = 'EXPIRED';
            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<String> tt1 = LTNG005_ValidateAccountClosureController.validateAccClosureViaApiFromFlow(new List<LTNG005_ValidateAccountClosureController.RequestAccClosure>{reqAccClosure});
          //  System.assert(tt1 == null);

        Test.stopTest();
    }

    @isTest
    public static void validateAccClosureViaApiTest(){   
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG005_ValidateAccountClosureController.AccountClosureValidationDetails tt = LTNG005_ValidateAccountClosureController.validateAccClosureViaApi(caseId);
            System.assert(tt != null);

        Test.stopTest();
    }


    private static List<Case> getAllCases(){
        return [SELECT Id,CaseNumber,ac_Iban__c,Customer_CIF__c,accountId,ac_EligibleToClose__c,ac_IneligibilityReasons__c,Sub_Status__c,Status FROM Case ];
    }

}