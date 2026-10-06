@isTest
public class CreditCollectionLettersControllerTest {
    
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
    
    static Account accObj;
    static Case objCase;
    static Case objCase1;
    static{
        Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Collection_Letter').getRecordTypeId();
        accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Collection Letter Application',Case_Nature__c = 'FCR',Sub_Type__c = 'No Due Letter',cc_Checker_Result__c = 'Accept',cc_Maker__c = 'Accept',Total_Legal_Fee__c=12.00,Letter_Type__c='Outstanding Balance'),
                                                    'TestFactoryDefaults.CaseDefaults',true); 
        
        objCase1 = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                    Type = 'Credit Collection Letter Application',Case_Nature__c = 'FCR',Sub_Type__c = 'Cancellation Letter',cc_Checker_Result__c = 'Accept',cc_Maker__c = 'Accept',Total_Legal_Fee__c=12.00,Letter_Type__c='No Liability'),
                                                    'TestFactoryDefaults.CaseDefaults',true); 
    }
     @isTest
    static void testLoadCardList(){
        Test.startTest();

        CreditCollectionLettersController.getCollectionLetterCaseRecordType();
        CreditCollectionLettersController.getCollectionLetterCaseQueue();
       	MCK001_ApiCalls.statusCodeGlobal = 200;
        Map<String,String> retriveCardOption=CreditCollectionLettersController.getCardOptions(accObj.Id,'D');
        string key=string.valueOf(retriveCardOption.keySet());
        String cardId=((key.substringAfter('&')).substringAfter('&')).substringBefore('&');
         MCK001_ApiCalls.statusCodeGlobal = 200;
        CreditCollectionLettersController.loadCardDetails(accObj.Id, cardId);
        CreditCollectionLettersController.downloadcasePdf(objCase.Id);
        CreditCollectionLettersController.sendEmailWithPdf(objCase.Id);
        CreditCollectionLettersController.sendEmailWithPdf(objCase1.Id);
        test.stopTest();
    }
    
    @isTest
    static void testValidateCreditCard(){
    	
        Case caseObj = [Select Id,AccountId FROM Case where Case_Nature__c = 'FCR' LIMIT 1];
        Test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CreditCollectionLettersController.validateCreditCard(caseObj.AccountId,'D','outstanding letter balance');
        CreditCollectionLettersController.validateCreditCard(caseObj.AccountId,'A','cancellation letter');
        CreditCollectionLettersController.getDefaultAccountIdViaApi(caseObj.AccountId,'ila');
        Test.stopTest();
    }
  
}