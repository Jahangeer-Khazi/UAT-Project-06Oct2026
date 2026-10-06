/********************************************************************************************
* @name					CashCollateralCertificateControllerTest
* @description			CashCollateralCertificateController code coverage would be done through this test class
* @date					13/03/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 06/04/2025		Initial Version
*********************************************************************************************
*/

@isTest
public class CashCollateralCertificateControllerTest {

    @testSetup
    static void setupTestData(){
    	
        createAccountAndContact();
        createCreditCardFCRCase();
    }
    
    @isTest
    static void caseAssignToCreditCardTempQueueTest(){
    	Case c = [Select Id,OwnerId FROM Case WHERE Subject = 'test case - cash collateral'];
        System.assertEquals(Label.Credit_Card_Temp,c.OwnerId,'Case has not assigned to Credit Card Temp Queue');
    }
    
    @isTest
    static void downloadCashCollateralCertTest(){
    	Case c = [Select Id,OwnerId FROM Case WHERE Subject = 'test case - cash collateral'];
        Map<String,Object> cardDetails = getCreditCardDetailMap();
        
        // Create a PageReference
        PageReference pageRef = Page.CashCollateralCertificatePDF;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', c.Id);
        for(String key :cardDetails.keyset()){
            pageRef.getParameters().put(key,(String)cardDetails.get(key));
        }
        
        
        //standard controller
        ApexPages.StandardController standardController = new ApexPages.StandardController(c);
        
        // Instantiate the controller extension
        CashCollateralCertificateController controllerExtension = new CashCollateralCertificateController(standardController);
        
        String todayDate = controllerExtension.getFormattedTodayDate();
        
        System.Assert(!String.isEmpty(todayDate),'Cash Collateral Date not generated.');
        
        /*ApiConnection.Response response = creditCardListController.downloadCashCollateral(c.Id,cardDetails);
        system.debug('response ' + response);
        System.assertEquals(response.isSuccess,true,'Download Cash Collateral Method Failed.');*/
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
    
    public static Map<String,Object> getCreditCardDetailMap(){
        Map<String,Object> mapOfCreditCardDetails = new Map<String,Object>();
        mapOfCreditCardDetails.put('creditLimit','2000');
        mapOfCreditCardDetails.put('accountNo','558856******6138');
        mapOfCreditCardDetails.put('issueDate','2027-10-21');
        mapOfCreditCardDetails.put('cardType','ila gulf air');
        mapOfCreditCardDetails.put('typeOfAccount','FIXED_DEPOSIT');
        mapOfCreditCardDetails.put('holdAccount',' 660000019990;660000019992');
        mapOfCreditCardDetails.put('pledgedAmount','121');
        return mapOfCreditCardDetails;
    }
}