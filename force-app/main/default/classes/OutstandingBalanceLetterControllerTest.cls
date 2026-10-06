/********************************************************************************************
* @name                 OutstandingBalanceLetterControllerTest
* @description          This class cover the code coverage for OutstandingBalanceLetterController class
* @date                 16/09/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           16/09/2025     Initial Version
*********************************************************************************************
*/
@isTest
public class OutstandingBalanceLetterControllerTest {

    @testSetup
    static void setupTestData(){
    	
        createAccountAndContact();
        createCreditCardFCRCase();
    }
    
    @isTest
    static void testOBL(){
        Case caseObj = [Select Id FROM Case LIMIT 1];
        Account accountObj = [Select Id FROM Account LIMIT 1];
        
        // Create a PageReference
        Test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        PageReference pageRef = Page.Outstanding_Balance_Letter;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('csId', caseObj.Id);
        pageRef.getParameters().put('accId', accountObj.Id);
        OutstandingBalanceLetterController obj = new OutstandingBalanceLetterController();
        
        //covering the OutstandingBalanceCmpController VF Component class code
        OutstandingBalanceCmpController vfComponentController = new OutstandingBalanceCmpController();
        vfComponentController.setWrapperObject(obj.obWrapper);
        vfComponentController.formattedTotalCreditCardBalance = obj.formattedCCTotalOutstanding;
    	vfComponentController.formattedTotalLoanBalance = obj.formattedLoanTotalOutstanding;
        
        Object wrapperObj = vfComponentController.getWrapperObject();
        System.assertNotEquals(wrapperObj,null,'Wrapper not populated.');
        System.assertNotEquals(vfComponentController.getTotalCreditCardBalance(),null,'Credit Card Amount not populated.');
        System.assertNotEquals(vfComponentController.getTotalLoanBalance(),null,'Loan amount not populated.');
        
        Test.stopTest();
    }
    
    public static void createAccountAndContact(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2_creditcard_fcr@ilatest.com';
        acc.ID_Number__pc = '851000000';
        acc.Nationality__pc = 'BH';
        acc.PersonMailingCity = 'Muharraq';
        acc.PersonMailingCountry = 'BH ';
        acc.CIF__pc = '64098';
        acc.PersonMailingState = 'Muharraq';
        acc.Region_Flag__c = 'Bahrain';
        acc.PersonMailingStreet = 'Villa 2 Bldg 111 Road 222';
        acc.PersonMailingPostalCode = '455';
        insert acc;
    }
    
    public static void createCreditCardFCRCase(){
        Account acct = [Select Id FROM Account WHERE PersonEmail = 'test2_creditcard_fcr@ilatest.com'];
        Contact cnt = [Select Id FROM Contact WHERE Email = 'test2_creditcard_fcr@ilatest.com'];
        RecordType creditCardFCR = [Select Id,Name FROM RecordType where sobjecttype = 'Case' and Name = 'Credit Card - FCR'];
        
        Case c = new Case();
        c.RecordTypeId = creditCardFCR.Id;
        c.ContactId = cnt.Id;
        c.Subject = 'test case - cash collateral';
        c.Description = 'test desc';
        c.Case_Model__c = 'ila';
        c.Type = 'Cash Collateral Letter';
        c.Sub_Type__c = 'Generate Cash Collateral Letter';
        c.Origin = 'Email';
        c.Case_Nature__c = 'FCR';
        c.Customer_Email_Suppression_on_Closure__c = true;
        c.Customer_Email_Suppression_on_Creation__c = true;
        insert c;
    }
}