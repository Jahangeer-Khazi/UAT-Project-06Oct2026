@isTest
private class LoanNoLiabilityControllerTest {
    
    static testMethod void testConstructor() {
        Account acc = new Account(FirstName = 'Test Account', LastName = 'Test Account');
        insert acc; 
 
        Case testCase = new Case(
            Subject = 'Test Case',
            Origin = 'Email',           
            AccountId = acc.Id,
            Case_Model__c = 'ila',
            Total_Legal_Fee__c = 1000,
            Letter_Type__c = 'No Liability'
        );
        insert testCase;
         System.debug('caseId:!!!!! ' + testCase.Id);
     
        PageReference pageRef = Page.LoanNoLiabilityPDF; 
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('accId', acc.Id);
        pageRef.getParameters().put('csId', testCase.Id);
        
       
        Test.startTest();
        LoanNoLiabilityController controller = new LoanNoLiabilityController();
        Test.stopTest();
        
  
        System.assertEquals(acc.Id, controller.accountId);
        System.assertEquals(testCase.Id, controller.caseId);
         System.assertEquals(testCase.Total_Legal_Fee__c, controller.legalFee);
  
    }
    
     
}