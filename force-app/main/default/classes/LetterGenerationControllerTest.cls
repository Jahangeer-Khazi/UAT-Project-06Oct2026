@isTest
public class LetterGenerationControllerTest {

    // Mock implementation
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            System.debug('req.endpoint ' + req.getEndpoint());
            String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030003081773","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blu12e","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","blockDate":"2023-05-09","maskedCardNumber":"511724XXXXXX1773","issueDate":"2024-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"status":"account_cancelled_by_bank","canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","CHANGE_CREDIT_LIMIT","TRANSACTIONS_CONTROL"],"cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}],"enabledMainActions":[{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":7}],"primaryCardPciNumber":"2660030003081773","applicationStatus":"","blockCode":"O","pendingRequests":[]},{"id":"898989898989","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Test","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","blockDate":"2023-05-09","maskedCardNumber":"511724XXXXXX1773","issueDate":"2025-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"cardNature":"unsecured","status":"AccountCancelledByBank","primaryCardPciNumber":"2660030003081773"}],"pendingCards":[{"id":"16511","cardProductConfigurationId":2,"cardType":"01","productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","status":"PENDING","order":1000,"caseId":"5007Y00000IlpWNQAZ","embossName":"MOHAMED ALBASRI","createdDate":"2021-09-26T14:45:36","modifiedDate":"2021-09-26T14:45:36","closureDate":"2021-09-26T14:45:36","creditLimit":4000.00000,"requestType":"CREDIT_CARD_ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}]}],"cardOptions":[{"cardProductConfigurationId":4,"productMappingCode":"TITANIUM_CO_BRAND_01","cardDisplayName":"Titanium Gulf Air","cmsCardProductId":"005","cmsCardProductType":"01","order":2,"productStatus":"ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"}],"cardNature":["unsecured","secured"]}]}}';
            if (req.getEndpoint().contains('/api/v1/credit-cards')) {
            	res.setBody(body);
            }
            else {
            	res.setBody(body);    
            }
            
            res.setStatusCode(200);
            return res;
        }
    }
    
    private static Account accountObj;
    
    @testSetup
    static void setupTestData(){
    	createAccountAndContact();
        accountObj = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_lettergeneration_fcr@ilatest.com'];
    }
    
    @isTest
    static void testOutstandingBalanceLetter(){
        accountObj = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_lettergeneration_fcr@ilatest.com'];
        System.debug('accountObject16 ' + accountObj);
        Case caseObj = createNewCase('Collection Letters','Outstanding balance Letter','LoanFinanceServiceRequest','Credit Card');
        PageReference vfPage = Page.Outstanding_Balance_Letter;
        MCK001_ApiCalls.statusCodeGlobal = 200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('accId',accountObj.Id);
        ApexPages.currentPage().getParameters().put('csId',caseObj.Id);
        Test.startTest();
        LetterGenerationController controller = new LetterGenerationController();
        Test.stopTest();
        //PageReference newPage = controller.validateSurveyRequest();
    }
    
    @isTest
    static void testCancellationLetter(){
        accountObj = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_lettergeneration_fcr@ilatest.com'];
        Case caseObj = createNewCase('Credit Collection Letter Application','Cancellation Letter','Credit_Collection_Letter','FCR');
        PageReference vfPage = Page.Cancellation_letter_PDF;
        MCK001_ApiCalls.statusCodeGlobal = 200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('accId',accountObj.Id);
        ApexPages.currentPage().getParameters().put('csId',caseObj.Id);
        Test.startTest();
        LetterGenerationController controller = new LetterGenerationController();
        Test.stopTest();
    }
    
    @isTest
    static void testNoDueLetterLetter(){
        accountObj = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_lettergeneration_fcr@ilatest.com'];
        Case caseObj = createNewCase('Credit Collection Letter Application','No Due Letter','Credit_Collection_Letter','FCR');
        PageReference vfPage = Page.No_Due_Letter_PDF;
        MCK001_ApiCalls.statusCodeGlobal = 200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('accId',accountObj.Id);
        ApexPages.currentPage().getParameters().put('csId',caseObj.Id);
        Test.startTest();
        LetterGenerationController controller = new LetterGenerationController();
        Test.stopTest();
    }
    
    @isTest
    static void testBalanceConfirmationLetter(){
        accountObj = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_lettergeneration_fcr@ilatest.com'];
        Case caseObj = createNewCase('Credit Collection Letter Application','Balance Confirmation Letter','Credit_Collection_Letter','FCR');
        PageReference vfPage = Page.Balance_confirmation_PDF;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('accId',accountObj.Id);
        ApexPages.currentPage().getParameters().put('csId',caseObj.Id);
        Test.startTest();
        LetterGenerationController controller = new LetterGenerationController();
        Test.stopTest();
    }
    
    @isTest
    static void testReferenceLetter(){
        accountObj = [Select Id,PersonContactId FROM Account WHERE PersonEmail = 'test2_lettergeneration_fcr@ilatest.com'];
        Case caseObj = createNewCase('Credit Collection Letter Application','Reference Letter','Credit_Collection_Letter','FCR');
        PageReference vfPage = Page.Reference_Letter_PDF;
        Test.setCurrentPage(vfPage);
        ApexPages.currentPage().getParameters().put('accId',accountObj.Id);
        ApexPages.currentPage().getParameters().put('csId',caseObj.Id);
        Test.startTest();
        LetterGenerationController controller = new LetterGenerationController();
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccountTypeOrder(){
        Integer customerCode = LetterGenerationController.getAccountTypeOrder('CUSTOMER_ACCOUNT');
        System.assertEquals(customerCode,1);
        
        Integer kanzCode = LetterGenerationController.getAccountTypeOrder('KANZ');
        System.assertEquals(kanzCode,2);
        
        Integer invalidCode = LetterGenerationController.getAccountTypeOrder('TEST');
        System.assertEquals(invalidCode,99);
    }
    
    @isTest
    static void testGetCurrencyOrder(){
        Integer bhdCode = LetterGenerationController.getCurrencyOrder('BHD');
        System.assertEquals(bhdCode,0);
    }
    
    public static void createAccountAndContact(){
        Account acc = new Account();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2_lettergeneration_fcr@ilatest.com';
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
    
    public static Case createNewCase(String caseType,String caseSubType,String rtDevName,String caseNature){
        System.debug('accountObject83 ' + accountObj);
       	RecordType creditCardFCR = [Select Id,Name FROM RecordType where sobjecttype = 'Case' and DeveloperName =:rtDevName];
        
        Case c = new Case();
        c.RecordTypeId = creditCardFCR.Id;
        c.Subject = 'test case - Letter Generation';
        c.Description = 'customer letter generation request';
        c.Case_Model__c = 'ila';
        c.Type = caseType;
        c.Sub_Type__c = caseSubType;
        c.Status = 'New';
        c.Sub_Status__c = 'New';
        c.Priority = 'High';
        c.Origin = 'Service Centre';
        c.Case_Nature__c = caseNature;
        c.ContactId = accountObj.PersonContactId;
        c.Customer_Email_Suppression_on_Closure__c = true;
        c.Customer_Email_Suppression_on_Creation__c = true;
        insert c;
        return c;
    }
}