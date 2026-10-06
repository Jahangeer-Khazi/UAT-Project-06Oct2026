/*      Organization : ABC Bank
*       Created By: Maksud Ali
*       Created Date: 25-12-2025
*       Change History: 
*/
@isTest
public class creditCardPdfController2Test {

    @testSetup
    static void setupTestData(){
    	
        createAccountAndContact();
    }
    
    @isTest
    static void generateExcelForCreditCardStatementTest(){
    	
        Account acc = [Select Id,Region_Flag__c,CIF__pc FROM Account LIMIT 1];
        
        String stngifyFilters = '{"pciNumber":"2660030014529560","fromDate":"2023-06-04","toDate":"2023-09-05","debitCreditIndicator":"ALL","cardAccountIndicator":"ALL","offset":1,"pageSize":20,"status":"ALL"}';
        
        String accName = EncodingUtil.base64Encode(Blob.valueOf('John Test'));
        String customerId = EncodingUtil.base64Encode(Blob.valueOf(acc.CIF__pc));
        String selCardId = EncodingUtil.base64Encode(Blob.valueOf('56478678908765'));
        String regionName = EncodingUtil.base64Encode(Blob.valueOf('Bahrain'));
        String cardType = EncodingUtil.base64Encode(Blob.valueOf('Prepaid Card'));
       	String datePopulated = EncodingUtil.base64Encode(Blob.valueOf('Y'));
        String jsonBody = '{"fromDate": "2025-06-24","toDate": "2025-09-25","debitCreditIndicator": "ALL","cardAccountIndicator": "ALL","offset": 1,"pageSize": 20,"status": "ALL"}';
        
        
        PageReference pageRef = Page.CreditCardTransactionExcel;
        Test.setCurrentPage(pageRef);
        
        final TransactionDetailsCalloutMock mock = new TransactionDetailsCalloutMock();
        mock.testBody = '{"meta":{"code":"CCRD-XXXX","message":"Request for card transaction is done successfully."},"data":{"transactions":[{"customerId":"5548503","pciNumber":"2660030035919261","transactionType":"987","transactionDate":"2026-03-24T17:30:00","valueDate":"2026-03-24","originalAmount":-0.5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-0.5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"VAT DB ANNUAL FEE","authorizationCode":"000000","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980324842500022","maskedCardNumber":"511724XXXXXX9261","merchantCategoryCode":"0000","walletIdentifier":"               ","status":"P","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]},{"customerId":"5548503","pciNumber":"2660030035919261","transactionType":"011","transactionDate":"2026-03-24T17:30:00","valueDate":"2026-03-24","originalAmount":-5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"CARD REPLACEMENT FEES","authorizationCode":"      ","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980324842500022","maskedCardNumber":"511724XXXXXX9261","merchantCategoryCode":"0000","walletIdentifier":"               ","status":"P","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]},{"customerId":"5548503","pciNumber":"2660030035085339","transactionType":"987","transactionDate":"2026-01-22T17:30:00","valueDate":"2026-02-21","originalAmount":-0.5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-0.5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"VAT DB ANNUAL FEE","authorizationCode":"000000","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980122842500087","maskedCardNumber":"511724XXXXXX5339","merchantCategoryCode":"0000","walletIdentifier":"               ","status":"B","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]},{"customerId":"5548503","pciNumber":"2660030035085339","transactionType":"011","transactionDate":"2026-01-22T17:30:00","valueDate":"2026-02-21","originalAmount":-5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"CARD REPLACEMENT FEES","authorizationCode":"      ","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980122842500087","maskedCardNumber":"511724XXXXXX5339","merchantCategoryCode":"0000","walletIdentifier":"  ","status":"B","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]}]}}';
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        
        pageRef.getParameters().put('accName', accName);
        pageRef.getParameters().put('customerId', customerId);
        pageRef.getParameters().put('selCardId', selCardId);
        pageRef.getParameters().put('regionName', regionName);
        pageRef.getParameters().put('stngifyFilters', stngifyFilters);
        pageRef.getParameters().put('cardType', cardType);
        pageRef.getParameters().put('datePopulated', datePopulated);
        creditCardPdfController2 obj = new creditCardPdfController2();
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
    
    public class TransactionDetailsCalloutMock implements HttpCalloutMock {
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            String jsonBody = req.getBody();
            
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if(jsonBody.contains('"offset":2')){
                res.setBody('{"meta":{"code":"CCRD-XXXX","message":"Request for card transaction is done successfully."},"data":{"transactions":[]}}');
            }
            else {
                res.setBody(testBody);
            }
            return res;
        }
    }
}