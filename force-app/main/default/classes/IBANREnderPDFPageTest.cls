@isTest
private class IBANREnderPDFPageTest {
    
  private static testMethod void IBANREnderPDFPage() {
             
        PageReference pageRef = Page.Bankaccount;
        Test.setCurrentPage(pageRef);
        
        Account acc1 = new Account();
        acc1.FirstName = 'Test';
        acc1.LastName = 'Class';
        acc1.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc1.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc1.Onboarding_Group__pc = 'Registration';
        insert acc1;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(acc1);
        ApexPages.currentPage().getParameters().put('accId',acc1.id);
        
        IBANRenderPDFPage mngUser= new IBANRenderPDFPage();
    }  
}