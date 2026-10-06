/**
 * @author Aniss Mbarki
 * @date Création 30/11/2022
 * @date Modification
 * @description :
 */
@IsTest
public class LTNG30_WithoutSharingCaseUpdateTest {
    
	@testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ppc_Prepaid_Card').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case( 
        Region_Flag__c='Bahrain',
        Case_Model__c = 'ila',
        ContactId = acc1.PersonContactId,
        AccountId = acc1.id,
        Type='Credit Card Prepaid Application',
        RecordTypeId = acRecordTypeId), 'TestFactoryDefaults.CaseDefaults',true); 
    }
    
    @isTest
    public static void updateCaseFromFlowTest(){
        Case caseObj = [SELECT Id,Case_Model__c,AccountId FROM Case LIMIT 1 ];
        Test.startTest();
        	LTNG30_WithoutSharingCaseUpdate.CaseRecordDetails caseRec = new LTNG30_WithoutSharingCaseUpdate.CaseRecordDetails();
        	caseRec.caseId = caseObj.Id;
        	caseRec.status = 'Closed';
        	caseRec.subStatus = 'Expired';
        	LTNG30_WithoutSharingCaseUpdate.updateCaseFromFlow(new List<LTNG30_WithoutSharingCaseUpdate.CaseRecordDetails>{caseRec});
         Test.stopTest();
       
    }
}