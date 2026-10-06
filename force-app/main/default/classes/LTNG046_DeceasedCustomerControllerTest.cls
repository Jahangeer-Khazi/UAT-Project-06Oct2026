@isTest
public class LTNG046_DeceasedCustomerControllerTest {

    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Reason = 'Service'), 'TestFactoryDefaults.CaseDefaults',true);
    }

    
    @isTest
    public static void getDeceasedCustomerCaseRecordTypeTest(){   
        Test.startTest();
            Id acRecordTypeId = LTNG046_DeceasedCustomerController.getDeceasedCustomerCaseRecordType();
            System.assert(acRecordTypeId != null);
        Test.stopTest();
    }

    @isTest
    public static void deceasedCustomerInitFromFlowTest(){  
        Id caseId = [SELECT Id FROM Case LIMIT 1].id; 
        Test.startTest();
        try {
            LTNG046_DeceasedCustomerController.deceasedCustomerInitFromFlow(new List<Id>{caseId});
            LTNG046_DeceasedCustomerController.deceasedCustomerInitFuture(new Set<Id>{caseId});
        } catch (Exception exp) {
            //System.assert(true);
        }
        Test.stopTest();
    }  

}