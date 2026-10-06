/**
* @author Jayanth Manickam
* @date Création 02/03/2022
* @date Modification
* @description :Contains functions called in 'bankStatementController'
*/

@isTest 
public class bankStatementControllerTest {
    
    static testMethod void testMethod1() 
    {
         Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BankStatementRequest').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',
            Sub_Type__c = 'Request Account Bank Statement',Type='New Bank Statement Request'), 'TestFactoryDefaults.CaseDefaults',true);
        Test.StartTest(); 
        PageReference pageRef = Page.bankStatement; // Add your VF page Name here
        pageRef.getParameters().put('recordId', String.valueOf(caseObj.Id));
        Test.setCurrentPage(pageRef);
        bankStatementController testAccPlan = new bankStatementController();
   
 Test.StopTest();
    }

}