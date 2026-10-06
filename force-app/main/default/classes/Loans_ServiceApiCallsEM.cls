/**
 * @author ANISS MBARKI
 * @date Création 07/12/2023
 * @date Modification 
 * @description Loans_ServiceApiCallsEM - Apex class (part of the Mocking Framework) Purpose : Reroute to the correct class Using Stub Concept  
 * @history Modifications : 
 */
public class Loans_ServiceApiCallsEM implements  Loans_ServiceApiCallsInterface {

    // WS STUB
    private static Loans_ServiceApiCallsInterface stub {
        get {
           return callApi_STUB();
        }
    }

    // Private variable_Getter method
    private static Loans_ServiceApiCallsInterface callApi_STUB(){
        Loans_ServiceApiCallsInterface STUB;
       
        if (Test.isRunningTest()) {
           STUB = new Loans_ServiceApiCallsMock(); 
        } else {
           STUB = new Loans_ServiceApiCallsDM();
        }

       return STUB;
    }

    // ****************  Api calls ********************************** 
    public static HttpResponse callGetLoanTransactionsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callGetLoanTransactionsApi(request, statusCode);
        return response;     
    }
    public static HttpResponse callGetLoanPaymentsScheduleApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callGetLoanPaymentsScheduleApi(request, statusCode);
        return response;     
    }

    public static HttpResponse callLoansOptionsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callLoansOptionsAPI(request, statusCode);
        return response;     
    }

    public static HttpResponse getUserApplicationInfoAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getUserApplicationInfoAPI(request, statusCode);
        return response;     
    }

    public static HttpResponse createLoanApplicationApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.createLoanApplicationApi(request, statusCode);
        return response;     
    }

    public static HttpResponse updateLoanApplicationApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.updateLoanApplicationApi(request, statusCode);
        return response;     
    }

    public static HttpResponse getExistingLiabilitiesAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getExistingLiabilitiesAPI(request, statusCode);
        return response;     
    }
    
    public static HttpResponse getCustomerProductsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getCustomerProductsAPI(request, statusCode);
        return response;     
    }

    public static HttpResponse getAppFulfillmentIdAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getAppFulfillmentIdAPI(request, statusCode);
        return response;     
    }

    public static HttpResponse getLoanCalculatorMatrixAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getLoanCalculatorMatrixAPI(request, statusCode);
        return response;     
    }

    public static HttpResponse getLoanEarlySettlementDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getLoanEarlySettlementDetailsAPI(request, statusCode);
        return response;     
    }

    public static HttpResponse getLoanPartialSettlementDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getLoanPartialSettlementDetailsAPI(request, statusCode);
        return response;     
    }
}