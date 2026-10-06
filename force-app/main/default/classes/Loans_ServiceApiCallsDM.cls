/**
 * @author ANISS MBARKI
 * @date Création 07/12/2023
 * @date Modification 
 * @description Loans_ServiceApiCallsDM - Apex class (part of the Mocking Framework) that contains the real call to apis for Loans requirement
 * @history Modifications :
 */
public with sharing class Loans_ServiceApiCallsDM implements Loans_ServiceApiCallsInterface {

    public static HttpResponse callGetLoanTransactionsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse callGetLoanPaymentsScheduleApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse callLoansOptionsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getUserApplicationInfoAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse createLoanApplicationApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse updateLoanApplicationApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getExistingLiabilitiesAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getCustomerProductsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getAppFulfillmentIdAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getLoanCalculatorMatrixAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getLoanEarlySettlementDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse getLoanPartialSettlementDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }
}