/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 03-09-2023
*       Change History: 
*/
@isTest
public class bankAccountCASControllerTest {
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
    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setStatusCode(200);
            res.setBody('{"responseData":{"result":[{"instruments":[{"channels":[{"name":"BenefitPay","isDefault":"true","channelType":"ACCESS_CHANNEL","channelLink":"https://www.test-benefitpay.bh/wallet/ext/v1/accounts/cas/"}],"birthdate":691200000,"gender":"Female","nationality":"BH","alias":"Riyhik","address3":"Manama-BH","address2":"","address1":"Villa","name":"CLEMENT PANCRAS","lastUpdateDate":1692619306000,"registerationDate":1692616500000,"userConsent":true,"email":"mavericilaopenbank5@gmail.com","bank_id":"ABCO","instrumentType":"IBAN","bankAccountType":"SAVING","status":"ACTIVE","instrumentId":"BH72ABCO55485079101001","mobileNo":"97332689587","type":"CUSTOMER_ACCOUNT","currency":{"decimalPlaces":3,"code":"BHD"},"branch":"91084710","source":"ila","order":1}],"customer_type":"PERSONAL","customerIdType":"CPR","customerId":"940798165"}],"casAvailabilityServiceStatus":true,"consentType":"cas","casCreationEligibility":true},"recordLength":null,"isSuccess":true,"errorData":null}');
            return res;
        }
    }
    @isTest
    static void unitTest1(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody ='{"instrument_type":"IBAN","page_no":1,"instruments_ids":[{"instrument_id":"54674788464647"}],"page_size":"10"}';
        bankAccountCASController.loadCASDet('5464546','54674788464647','Bahrain');
        test.stopTest();
    }    

}