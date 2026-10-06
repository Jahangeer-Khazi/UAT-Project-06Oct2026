/********************************************************************************************
* @name					WalkInCustomerSurveyControllerTest
* @description			WalkInCustomerSurveyController code coverage would be done through this test class
* @date					26/08/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 26/08/2025		Initial Version
*********************************************************************************************
*/

@isTest
public class WalkInCustomerSurveyControllerTest {

    @testSetup
    static void setupTestData(){
    	createAccountAndContact();
    }
    
    @isTest
    static void caseClosedAndSurveySubmitted(){
        //closing the case.
        Case caseObj = createCustomerWalkinCase();
        caseObj.Status = 'Closed';
        update caseObj;
        
        //Survey link would email to customer and customer can complete the survey.
        PageReference surveyStartPage = Page.walkin_customer_survey;
        Test.setCurrentPage(surveyStartPage);
        ApexPages.currentPage().getParameters().put('id',caseObj.Id);
        WalkInCustomerSurveyController controller = new WalkInCustomerSurveyController();
        PageReference newPage = controller.validateSurveyRequest();
        
        System.assertEquals(null,newPage,'newPage obj must be null, if not then there is an error');
        
        //Saving survey Response.
        controller.caseId = caseObj.Id;
        controller.isIssueFixed = true;
        controller.rating = '4';
		controller.saveSurveyRequest();
        
        //validating that survey response record has created.
        List<Walkin_Customer_Survey_Response__c> response = [Select Id,Case__c 
                                                             FROM Walkin_Customer_Survey_Response__c 
                                                             WHERE Case__c =:caseobj.Id LIMIT 1];
        System.debug('!response.isEmpty() ' + response);
        System.assert(!response.isEmpty(),'Survey Response record has not been created.');
        
        //submitting the same survey would ended an error.
        //Test.setCurrentPage(surveyStartPage);
        WalkInCustomerSurveyController controller2 = new WalkInCustomerSurveyController();
        ApexPages.currentPage().getParameters().put('id',response[0].Case__c);
        //PageReference newPage2 = controller.validateSurveyRequest();
        PageReference newPage2 = controller2.saveSurveyRequest();
        System.assertNotEquals(null,newPage2,'newPage obj must be null, if not then there is an error');
        
        
    }
    
    @isTest
    static void invalidCaseSurveySubmitted(){
    	Account acct = [Select Id FROM Account LIMIT 1];
        
        //Passing invalid case id to get the error page in return once survey request is validated
        PageReference surveyStartPage = Page.walkin_customer_survey;
        Test.setCurrentPage(surveyStartPage);
        ApexPages.currentPage().getParameters().put('id','');
        WalkInCustomerSurveyController controller = new WalkInCustomerSurveyController();
        PageReference newPage = controller.validateSurveyRequest();
        
        System.assertNotEquals(null,newPage,'error page is return, because of invalid case id');
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
        acc.PersonMailingState = 'Muharraq';
        acc.PersonMailingStreet = 'Villa 2 Bldg 111 Road 222';
        acc.PersonMailingPostalCode = '455';
        acc.Language_Preference__pc = 'English';
        insert acc;
    }
    
    public static Case createCustomerWalkinCase(){
        Account acct = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_creditcard_fcr@ilatest.com'];
        RecordType creditCardFCR = [Select Id,Name FROM RecordType where sobjecttype = 'Case' and DeveloperName = 'Walkin_Customers'];
        
        Case c = new Case();
        c.RecordTypeId = creditCardFCR.Id;
        c.Subject = 'test case - walkin';
        c.Description = 'customer walkin for app support';
        c.Case_Model__c = 'ila';
        c.Type = 'Walkin Customer';
        c.Sub_Type__c = 'APP Support';
        c.Status = 'New';
        c.Sub_Status__c = 'New';
        c.Priority = 'High';
        c.Origin = 'Service Centre';
        c.Case_Nature__c = 'Walkin';
        c.ContactId = acct.PersonContactId;
        c.Customer_Email_Suppression_on_Closure__c = true;
        c.Customer_Email_Suppression_on_Creation__c = true;
        insert c;
        return c;
    }
}