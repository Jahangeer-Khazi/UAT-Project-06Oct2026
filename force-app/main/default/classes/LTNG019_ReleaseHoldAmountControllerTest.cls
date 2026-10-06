/**
  #CH01 : #D&A Team #24-06-2022# Added case model parameter to method.
 */
@isTest
public class LTNG019_ReleaseHoldAmountControllerTest {
     @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('db_AccountHold').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',RHA_AccountType__c ='CUSTOMER_ACCOUNT'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
            Id acRecordTypeId = LTNG019_ReleaseHoldAmountController.getAccRequestCaseRecordType();
            System.assert(acRecordTypeId != null);
        Test.stopTest();
    }
    
    @isTest
    public static void getAccountToHoldAmountViaApiTest(){   
        Test.startTest();
            Id accId = [SELECT Id FROM Account LIMIT 1].Id;

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                List<LTNG019_ReleaseHoldAmountController.AccountToHoldAmountDetails> accList = LTNG019_ReleaseHoldAmountController.getAccountToHoldAmountViaApi(accId,null);//CH01
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<LTNG019_ReleaseHoldAmountController.AccountToHoldAmountDetails> accList1 = LTNG019_ReleaseHoldAmountController.getAccountToHoldAmountViaApi(accId,null);//CH01
            System.assert(accList1 != null);
        Test.stopTest();
    }  
 @isTest
    public static void getAccDetailsViaApiTest(){   
        Test.startTest();
            String accIban = 'BH06ABCO55401509101001';
            Id accId = [SELECT Id FROM Account LIMIT 1].Id;

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                List<LTNG019_ReleaseHoldAmountController.AccountHoldTransaction> accList = LTNG019_ReleaseHoldAmountController.getAccDetailsViaApi(accIban,accId,null);//CH01;
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<LTNG019_ReleaseHoldAmountController.AccountHoldTransaction> accList1 = LTNG019_ReleaseHoldAmountController.getAccDetailsViaApi(accIban,accId,null);//CH01;
            System.assert(accList1 != null);
        Test.stopTest();
    }  

}