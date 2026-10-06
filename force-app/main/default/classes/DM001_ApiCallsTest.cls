/**
 * *  Version History :
 *      #CH01:   Added by Ranjith Raja 29-09-2024
**/
@isTest
public class DM001_ApiCallsTest {

    private static ApiConnection con = new ApiConnection();

    private class RestMock1 implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';
            String body = '{'+
                                '"data":'+
                                    '{'+
                                        '"riskRating":"LOW",'+
                                        '"screeningResult":["PEPHIT"],'+
                                        '"eddDecision":"PASS",'+
                                        '"nameScreening":true'+
                                    '},'+
                                '"meta":'+
                                    '{'+
                                        '"code":"COMP-1000",'+
                                        '"message":"Name screening and risk classification gets verified successfully."'+
                                    '}'+
                            '}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest static void getComplianceCaseStatusApiTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        HttpRequest request1 = con.createRequest('GET','/api/v1/compliances',null);
        HttpResponse response = DM001_ApiCalls.getComplianceCaseStatusApi(request1,200);
        System.assert(response.getStatusCode() == 200);
    }

    @isTest static void callNameScreeningApiTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        HttpRequest request1 = con.createRequest('POST','/api/v1/compliances/direct',null);
        HttpResponse response = DM001_ApiCalls.callNameScreeningApi(request1,200);
        System.assert(response.getStatusCode() == 200);
    }

    @isTest static void callApiToCreateSupplementaryCardInVPlusTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        HttpRequest request1 = con.createRequest('PUT','/api/v1/credit-cards/request',null);
        HttpResponse response = DM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus(request1,200);
        System.assert(response.getStatusCode() == 200);
    }


    @isTest static void callBlockAmountApiTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        HttpRequest request1 = con.createRequest('PUT','/api/v1/credit-cards/request',null);
        HttpResponse response = DM001_ApiCalls.callBlockAmountApi(request1,200);
        System.assert(response.getStatusCode() == 200);
    }


    @isTest static void callUnblockAmountApiTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        HttpRequest request1 = con.createRequest('PUT','/api/v1/credit-cards/request',null);
        HttpResponse response = DM001_ApiCalls.callUnblockAmountApi(request1,200);
        System.assert(response.getStatusCode() == 200);
    }

    @isTest static void creditCardStatementTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        HttpRequest request = con.createRequest('POST','/api/v1/statements/credit-card',null);
        ApiConnection.Response response = DM001_ApiCalls.callCreditCardStatementApi(con,request,200);
        System.assert(response != null);

        HttpRequest request1 = con.createRequest('POST','/api/v1/statements/credit-card/details',null);
        ApiConnection.Response response1 = DM001_ApiCalls.callCreditCardStatementDetailsApi(con,request1,200);
        System.assert(response1 != null); 
    }

    @isTest static void accountStatementsTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        HttpRequest request = con.createRequest('POST','/api/v1/statements',null);
        ApiConnection.Response response = DM001_ApiCalls.callAccountStatementsApi(con,request,200);
        System.assert(response != null);

        HttpRequest request1 = con.createRequest('POST','/api/v1/statements/details',null);
        ApiConnection.Response response1 = DM001_ApiCalls.callAccountStatementsDetailsApi(con,request1,200);
        System.assert(response1 != null);
    }

    @isTest static void accountClosureTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        HttpRequest request = con.createRequest('GET','/api/v1/accounts',null);
        HttpResponse response = DM001_ApiCalls.callAccountListApi(request,200);
        System.assert(response.getStatusCode() == 200);

        HttpRequest request1 = con.createRequest('GET','/api/v1/customer-products/account/closure/validation',null);
        HttpResponse response1 = DM001_ApiCalls.callValidateAccountClosureApi(request1,200);
        System.assert(response1.getStatusCode() == 200);

        HttpRequest request2 = con.createRequest('DELETE','/api/v1/customer-products/account',null);
        HttpResponse response2 = DM001_ApiCalls.callCloseAccountApi(request2,200);
        System.assert(response2.getStatusCode() == 200);
    }

    @isTest static void creditCardStatusTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        HttpRequest request = con.createRequest('GET','/api/v1/credit-cards?',null);
        ApiConnection.Response response = DM001_ApiCalls.getCreditCardStatusApi(con,request,200);

        HttpRequest request1 = con.createRequest('GET','/api/v1/credit-cards/{cardId}/details',null);
        ApiConnection.Response response1 = DM001_ApiCalls.getCreditCardDetailsApi(con,request1,200);
    }

    @isTest static void ConApisTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        ApiConnection.Response response = DM001_ApiCalls.getCreditCardStatusApi(con,new HttpRequest(),200);
        System.assert(response != null);

        ApiConnection.Response response1 = DM001_ApiCalls.getCreditCardDetailsApi(con,new HttpRequest(),200);
        System.assert(response1 != null);

        ApiConnection.Response response2 = DM001_ApiCalls.callScheduledPlaPaymentsApi(con,new HttpRequest(),200);
        System.assert(response2 != null);

        ApiConnection.Response response3 = DM001_ApiCalls.callScheduledPlaPaymentDetailsApi(con,new HttpRequest(),200);
        System.assert(response3 != null);

        ApiConnection.Response response4 = DM001_ApiCalls.callUncollectedFeesApi(con,new HttpRequest(),200);
        System.assert(response4 != null);

    }


    @isTest static void apisTest() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        HttpResponse response = DM001_ApiCalls.updateCreditCardRequestStatusApi(new HttpRequest(),200);
        System.assert(response.getStatusCode() == 200);

        HttpResponse response1 = DM001_ApiCalls.blockUnblockAccountApi(new HttpRequest(),200);
        System.assert(response1.getStatusCode() == 200);

        HttpResponse response2 = DM001_ApiCalls.getAccountsListAllApi(new HttpRequest(),200);
        System.assert(response2.getStatusCode() == 200);

        HttpResponse response3 = DM001_ApiCalls.getAccountHoldTransactionsApi(new HttpRequest(),200);
        System.assert(response3.getStatusCode() == 200);

        HttpResponse response4 = DM001_ApiCalls.callUpdateFeeWaiverFlagReasonApi(new HttpRequest(),200);
        System.assert(response4.getStatusCode() == 200);

        // CH01:Start
        HttpResponse response5 = DM001_ApiCalls.ManualOnboardingAPI(new HttpRequest(),200);
        System.assert(response5 != null);

        HttpResponse response6 = DM001_ApiCalls.UpdateAccountForInterestRate(new HttpRequest(),200);
        System.assert(response6.getStatusCode() == 200);
        
        HttpResponse response7 = DM001_ApiCalls.PeriodicReviewBlockProductsApi(new HttpRequest(),200);
        System.assert(response7.getStatusCode() == 200);
        
        HttpResponse response8 = DM001_ApiCalls.PeriodicReviewUnblockProductsApi(new HttpRequest(),200);
        System.assert(response8.getStatusCode() == 200);
        
        HttpResponse response9 = DM001_ApiCalls.BenefitPayAPIUpdateApi(new HttpRequest(),200);
        System.assert(response9.getStatusCode() == 200);
        // CH01: End
    }

    @isTest static void updateCustomerDetailsAPI_TEST() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new RestMock1());

        HttpResponse response = DM001_ApiCalls.updateCustomerDetailsAPI(new HttpRequest(),200);
        System.assert(response.getStatusCode() == 200);

    }

    
}