/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 21-08-2023
*       Change History: 
*/
@isTest
public class creditCardPdfControllerTest {
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');    
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    public class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            //res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"meta":{"code":"CCRD-XXXX","message":"Request for card transaction is done successfully."},"data":{"transactions":[{"customerId":"5548503","pciNumber":"2660030035919261","transactionType":"987","transactionDate":"2026-03-24T17:30:00","valueDate":"2026-03-24","originalAmount":-0.5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-0.5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"VAT DB ANNUAL FEE","authorizationCode":"000000","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980324842500022","maskedCardNumber":"511724XXXXXX9261","merchantCategoryCode":"0000","walletIdentifier":"               ","status":"P","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]},{"customerId":"5548503","pciNumber":"2660030035919261","transactionType":"011","transactionDate":"2026-03-24T17:30:00","valueDate":"2026-03-24","originalAmount":-5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"CARD REPLACEMENT FEES","authorizationCode":"      ","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980324842500022","maskedCardNumber":"511724XXXXXX9261","merchantCategoryCode":"0000","walletIdentifier":"               ","status":"P","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]},{"customerId":"5548503","pciNumber":"2660030035085339","transactionType":"987","transactionDate":"2026-01-22T17:30:00","valueDate":"2026-02-21","originalAmount":-0.5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-0.5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"VAT DB ANNUAL FEE","authorizationCode":"000000","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980122842500087","maskedCardNumber":"511724XXXXXX5339","merchantCategoryCode":"0000","walletIdentifier":"               ","status":"B","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]},{"customerId":"5548503","pciNumber":"2660030035085339","transactionType":"011","transactionDate":"2026-01-22T17:30:00","valueDate":"2026-02-21","originalAmount":-5,"originalCurrency":{"code":"BHD","decimalPlaces":3},"amount":-5,"amountCurrency":{"code":"BHD","decimalPlaces":3},"transactionDescription1":"CARD REPLACEMENT FEES","authorizationCode":"      ","authorizationReferenceNumber":"000000000000","transactionReference":"09999999980122842500087","maskedCardNumber":"511724XXXXXX5339","merchantCategoryCode":"0000","walletIdentifier":"  ","status":"B","recordNumber":"00000","eppEligibilityFlag":"N","eppList":[]}]}}');
            return res;
        }
    }
    @isTest
    static void unitTest1(){
        String accName = EncodingUtil.base64Encode(Blob.valueOf('JohnCena'));
        String customerId = EncodingUtil.base64Encode(Blob.valueOf('564786'));
        String selCardId = EncodingUtil.base64Encode(Blob.valueOf('56478678908765'));
        String regionName = EncodingUtil.base64Encode(Blob.valueOf('Bahrain'));
        
        PageReference pageRef = Page.creditCardTransactionVF;
        
        
        pageRef.getParameters().put('accName', accName);
        pageRef.getParameters().put('customerId', customerId);
        pageRef.getParameters().put('selCardId', selCardId);
        pageRef.getParameters().put('regionName', regionName);
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new RestMock());
        creditCardPdfController controller = new creditCardPdfController();
        Test.stopTest();
   }
   @isTest
    static void unitTest2(){
        String stngifyFilters = '{"pciNumber":"2660030014529560","fromDate":"2023-06-04","toDate":"2023-09-05","debitCreditIndicator":"ALL","cardAccountIndicator":"ALL","offset":1,"pageSize":20,"status":"ALL"}';
        
        String accName = EncodingUtil.base64Encode(Blob.valueOf('JohnCena'));
        String customerId = EncodingUtil.base64Encode(Blob.valueOf('564786'));
        String selCardId = EncodingUtil.base64Encode(Blob.valueOf('56478678908765'));
        String regionName = EncodingUtil.base64Encode(Blob.valueOf('Bahrain'));
       
        
        PageReference pageRef = Page.creditCardTransactionVF2;
        
        
        pageRef.getParameters().put('accName', accName);
        pageRef.getParameters().put('customerId', customerId);
        pageRef.getParameters().put('selCardId', selCardId);
        pageRef.getParameters().put('regionName', regionName);
        pageRef.getParameters().put('stngifyFilters', stngifyFilters);
        
        Test.setCurrentPage(pageRef);
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new RestMock());
        creditCardPdfController2 controller = new creditCardPdfController2();
        Test.stopTest();
   }


}