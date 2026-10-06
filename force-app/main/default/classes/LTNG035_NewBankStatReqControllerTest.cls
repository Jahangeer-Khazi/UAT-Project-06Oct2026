@isTest
public without sharing class LTNG035_NewBankStatReqControllerTest {

    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779',Segment__pc='Regular'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BankStatementRequest').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',
            Sub_Type__c = 'Request Account Bank Statement',NumberOfPages__c=2,Type='New Bank Statement Request'), 'TestFactoryDefaults.CaseDefaults',true);
    }

    @isTest
    public static void getBankStatementRecordTypeTest(){   
        Test.startTest();
            Id acRecordTypeId = LTNG035_NewBankStatementReqController.getBankStatementRecordType();
            System.assert(acRecordTypeId != null);
        Test.stopTest();
    }

    @isTest
    public static void getAccountConfigViaApiTest(){   
        Test.startTest();
            Account acc = [SELECT Id FROM Account LIMIT 1];
            MCK001_ApiCalls.statusCodeGlobal = 200;
            LTNG035_NewBankStatementReqController.getAccountConfigViaApi(acc.Id,'alburaq');
        Test.stopTest();
    }

    @isTest
    public static void calculateFeesTest(){   
        Test.startTest();
            Case cs = [SELECT Id FROM Case LIMIT 1];
            LTNG035_NewBankStatementReqController.calculateFees(cs.Id);
        Test.stopTest();
    }

    @isTest
    public static void getCCardOptionsViaApiTest(){  
        Case caseObj = [SELECT Id,Case_Model__c,AccountId FROM Case LIMIT 1 ];
        String accpuntId=caseObj.AccountId;
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            List<Object> prepaidCard = LTNG035_NewBankStatementReqController.getCCardOptionsViaApi(caseObj.AccountId,'Request Credit Card Bank Statement',caseObj.Case_Model__c);
            System.assert(prepaidCard != null);
         Test.stopTest();
       
    }


    @isTest
    public static void sendEmailDocuSignTest(){  
        Case caseObj = [SELECT Id,Case_Model__c,AccountId FROM Case LIMIT 1 ];
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            try {
                LTNG035_NewBankStatementReqController.sendEmailDocuSign(new List<Id>{caseObj.id});
                LTNG035_NewBankStatementReqController.sendEmailDocuSignFuture(new Set<Id>{caseObj.id});
            } catch (Exception exp) {
                System.debug('error');                
            }
         Test.stopTest();
       
    }

}