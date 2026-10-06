/********************************************************************************************
* @name					WavierLimitControllerTest
* @description			WavierLimitController code coverage would be done through this test class
* @date					27/08/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 27/08/2025		Initial Version
*********************************************************************************************
*/

@isTest
public class WavierLimitControllerTest {

    @testSetup
    static void setupTestData(){
        createTestUser();
    	createAccountAndContact();
        createBudgetMatrixRecors();
    }
    
    @isTest
    static void testGetWavierLimit(){
    	ApiConnection.Response response = WavierLimitController.getWavierLimit();
        System.assertEquals(true,response.isSuccess,'budget record does not fetched.');
    }
    
    @isTest
    static void testGetWavierHistory(){
    
        Account acc = [Select Id FROM Account LIMIT 1];
        New_Wavier_Approval__c obj = new New_Wavier_Approval__c();
        obj.Case_Model__c = 'ila';
        obj.Type__c = 'Fee & Charges';
        obj.Sub_Type__c = 'Credit Card - Fee & Charges';
        obj.Request_Type__c = 'Overlimit';
        obj.Case_Origin__c = 'Phone';
        obj.Claim_Amount__c = 1;
        obj.Transaction_Reference_Number__c = '234FDFJKLJ3242';
        obj.Subject__c = 'Test class request for approval';
        obj.Description__c = 'test class desc';
        obj.Customer__c = acc.Id;
        insert obj;
        
        ApiConnection.Response response = WavierLimitController.getWavierHistory(acc.Id);
        System.assertEquals(true,response.isSuccess,'Wavier record has not created.');
    }
    
    public static void createBudgetMatrixRecors(){
        List<Budget_Matrix__c> listOfMatrix = new List<Budget_Matrix__c>();
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'Team Leaders',Budget__c = 500,Utilization__c = 0,CRM_Queue__c='Team Leaders FAQ',Max_Waiver_Amount__c = 30));
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'Head of Contact Center',Budget__c = 1000,Utilization__c = 0,CRM_Queue__c='Head Of Contact Center FAQ'));
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'Head of Customer Service',Budget__c = 2500,Utilization__c = 0,CRM_Queue__c='Product Managers FAQ'));
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'Product Manager',Budget__c = 1000,Utilization__c = 0,CRM_Queue__c='Product Managers FAQ'));
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'Head of Proposition',Budget__c = 2500,Utilization__c = 0,CRM_Queue__c='Head of Propositions FAQ'));
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'HoB',Budget__c = 0,Utilization__c = 15000,CRM_Queue__c='Head of Business FAQ'));
        listOfMatrix.add(new Budget_Matrix__c(Role_Name__c = 'CEO',Budget__c = 0,Utilization__c = 25000,CRM_Queue__c='CEO FAQ'));
        insert listOfMatrix;
    }

    public static void createTestUser(){
        User sysAdmin = new User(
            Username = 'testapproval_Waiver@test.com',
            LastName = 'test123',
            FirstName = 'test123',
            Email = 'test123_approval_rmt@gmail.com',
            Alias = 'ikart',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [Select Id FROM Profile WHERE Name = 'System Administrator'].Id
        );
        insert sysAdmin;
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
}