/**
 *  #CH01# Added by Imane Tsioucha  20-06-2022 *** adding case model parameter to the method 
 */
@isTest
public class LTNG013_BlockUnbAccControllerTest {
    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();
        //Id acRecordTypeIdJO = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('JO_Block_Unblock_Account').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',BUA_AccountsInformation__c='5556666-BHD',Type='Block Account',cbb_BlockStatusB__c='ila Risk'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    
    @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
            Id acRecordTypeId = LTNG013_BlockUnblockAccountController.getAccRequestCaseRecordType();
            System.assert(acRecordTypeId != null);
        Test.stopTest();
    }
    
    @isTest
    public static void getIsFraudTeamUser(){   
        Test.startTest();
        Boolean isFraudUser = LTNG013_BlockUnblockAccountController.isFraudTeamUser();
        Test.stopTest();
    }
    
    /* @isTest
    public static void getRecordTypeIdByregionName(){   
        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        String recTypeId = LTNG013_BlockUnblockAccountController.getRecordTypeIdByregionName(accId);
        Test.stopTest();
    }*/
    
    @isTest
    public static void getAccountToBlockUnblockViaApiTest(){   
        Test.startTest();
        Id accId = [SELECT Id FROM Account LIMIT 1].Id;
        
        MCK001_ApiCalls.statusCodeGlobal = 500;
        try {
            List<LTNG013_BlockUnblockAccountController.AccountToBlockUnblockDetails> accList = LTNG013_BlockUnblockAccountController.getAccountToBlockUnblockViaApi(accId,null);//CH01
        } catch (Exception exp) {
            System.assert(true);
        }
        
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<LTNG013_BlockUnblockAccountController.AccountToBlockUnblockDetails> accList1 = LTNG013_BlockUnblockAccountController.getAccountToBlockUnblockViaApi(accId,null);//CH01
        System.assert(accList1 != null);
        Test.stopTest();
    }
    
    @isTest
    public static void blockunblockAccountApiFromFlowTest(){   
        List<Case> caseList = getAllCases();
        LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc requestBlockUnblockAcc= new LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc();
        requestBlockUnblockAcc.caseId = caseList.get(0).Id;
        requestBlockUnblockAcc.statusType = 'BLOCK';
        //  requestBlockUnblockAcc.BUA_AccountsInformation__c='5556666-BHD';
        Test.startTest();
        
        MCK001_ApiCalls.statusCodeGlobal = 500;
        try {
            LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
        } catch (Exception exp) {
            System.assert(true);
        }
        
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<String> tt = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
        System.assert(tt == null);
        
        requestBlockUnblockAcc.statusType = 'UNBLOCK';
        MCK001_ApiCalls.statusCodeGlobal = 200;
        List<String> tt1 = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
        System.assert(tt1 == null);
        
        Test.stopTest();
    }

    @isTest
    public static void blockunblockAccountApiFromFlowTest2(){   
        List<Case> caseList = getAllCases();
        LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc requestBlockUnblockAcc= new LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc();
        requestBlockUnblockAcc.caseId = caseList.get(0).Id;
        requestBlockUnblockAcc.statusType = 'UNBLOCK';
        //  requestBlockUnblockAcc.BUA_AccountsInformation__c='5556666-BHD';
        Test.startTest();
        
        MCK001_ApiCalls.statusCodeGlobal = 500;
        try {
            LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
        } catch (Exception exp) {
            System.assert(true);
        }
        
        MCK001_ApiCalls.statusCodeGlobal = 400;
        List<String> tt = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
        
        requestBlockUnblockAcc.statusType = 'UNBLOCK';
        MCK001_ApiCalls.statusCodeGlobal = 400;
        List<String> tt1 = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
        
        Test.stopTest();
    }
    
    @isTest
    public static void blockunblockAccountApiFromFlowTest3(){   
        User thisUser = [select Id from User where Profile.Name = 'RMT' AND isActive = true LIMIT 1]; 
        System.runAs(thisUser) {
            List<Case> caseList = getAllCases();
            LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc requestBlockUnblockAcc= new LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc();
            requestBlockUnblockAcc.caseId = caseList.get(0).Id;
            requestBlockUnblockAcc.statusType = 'UNBLOCK';
            Test.startTest();
            
            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
            } catch (Exception exp) {
                System.assert(true);
            }
            
            MCK001_ApiCalls.statusCodeGlobal = 400;
            List<String> tt = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
            
            requestBlockUnblockAcc.statusType = 'UNBLOCK';
            MCK001_ApiCalls.statusCodeGlobal = 400;
            List<String> tt1 = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
            
            Test.stopTest();
        }
    }
    
    @isTest
    public static void UpdateApproverProfileTest(){   
        List<Case> caseList = getAllCases();
        Account accId = [SELECT Id FROM Account LIMIT 1];
        LTNG013_BlockUnblockAccountController.UpdateApproverProfile(accId.Id,'ila','5556666-BHD');
       // requestBlockUnblockAcc.accountId = accId.Id;
      //  requestBlockUnblockAcc.caseModel = 'ila';
      //  requestBlockUnblockAcc.UnblockAccount='5556666-BHD';
       /* Test.startTest();

            MCK001_ApiCalls.statusCodeGlobal = 500;
            try {
                LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
            } catch (Exception exp) {
                System.assert(true);
            }

            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<String> tt = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
            System.assert(tt == null);

            requestBlockUnblockAcc.statusType = 'UNBLOCK';
            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<String> tt1 = LTNG013_BlockUnblockAccountController.blockunblockAccountApiFromFlow(new List<LTNG013_BlockUnblockAccountController.RequestBlockUnblockAcc>{requestBlockUnblockAcc});
            System.assert(tt1 == null);

        Test.stopTest();*/
    }
   

    private static List<Case> getAllCases(){
        return [SELECT Id,CaseNumber,ac_Iban__c,Customer_CIF__c,accountId,ac_EligibleToClose__c,ac_IneligibilityReasons__c,Sub_Status__c,Status,BUA_AccountsInformation__c FROM Case ];
    }

 }