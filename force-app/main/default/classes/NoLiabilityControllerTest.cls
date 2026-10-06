@isTest
public class NoLiabilityControllerTest {
    
    static Account accObj;
    static Case objCase;
    static{
        Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Collection_Letter').getRecordTypeId();
        accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Collection Letter Application',cc_Checker_Result__c = 'Accept',cc_Maker__c = 'Accept',Total_Legal_Fee__c=12.00,Letter_Type__c='Outstanding Balance'),
                                                    'TestFactoryDefaults.CaseDefaults',true);  
    }
    
    private static testMethod void NoLiabilityPDFPage() {
    PageReference pageRef = Page.Bankaccount;
        Test.setCurrentPage(pageRef);
        
                ApexPages.StandardController sc1 = new ApexPages.StandardController(accObj);
        ApexPages.currentPage().getParameters().put('accId',accObj.id);
        ApexPages.currentPage().getParameters().put('csId',objCase.Id);
        MCK001_ApiCalls.statusCodeGlobal = 200;
        MCK001_ApiCalls.statusCodeGlobal = 200;
        NoLiabilityController liability= new NoLiabilityController();
	
    }
}