/********************************************************************************************
* @name					FetchSTPFromBcrbAPITest
* @description			FetchSTPFromBcrbAPI code coverage would be done through this test class
* @date					22/05/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 22/05/2025		Initial Version
*********************************************************************************************
*/

@isTest

public class FetchSTPFromBcrbAPITest {

    @testSetup
    static void setupTestData(){
    	
        createAccountAndContact();
        createCreditCardServiceCase();
    }
    
    @isTest
    static void caseAssignToCreditCardTempQueueTest(){
        
        Test.startTest();
    	Test.setMock(HttpCalloutMock.class, new FetchSTPFromBcrbAPIMockTest());
        
    	Case c = [Select Id,OwnerId FROM Case WHERE Subject = 'test case - credit card service' LIMIT 1];
        FetchSTPFromBcrbAPI fs = new FetchSTPFromBcrbAPI( new Set<Id>{ c.Id });
        fs.execute(null);
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
        acc.PersonMailingState = 'Muharraq';
        acc.PersonMailingStreet = 'Villa 2 Bldg 111 Road 222';
        acc.PersonMailingPostalCode = '455';
        insert acc;
        //Credit Card Services
    }
    
    public static void createCreditCardServiceCase(){
        Account acct = [Select Id FROM Account WHERE PersonEmail = 'test2_creditcard_fcr@ilatest.com'];
        Contact cnt = [Select Id FROM Contact WHERE Email = 'test2_creditcard_fcr@ilatest.com'];
        RecordType creditCardRT = [Select Id,Name FROM RecordType where sobjecttype = 'Case' and Name = 'Credit Card Services'];
        
        Case c = new Case();
        c.RecordTypeId = creditCardRT.Id;
        c.ContactId = cnt.Id;
        c.Subject = 'test case - credit card service';
        c.Description = 'test desc';
        c.Case_Model__c = 'ila';
        c.Type = 'Credit Card Services';
        c.Sub_Type__c = 'Direct Debit Settings';
        c.Origin = 'Email';
        c.Case_Nature__c = 'FCR';
        c.Customer_Email_Suppression_on_Closure__c = true;
        c.Customer_Email_Suppression_on_Creation__c = true;
        insert c;
    }
}