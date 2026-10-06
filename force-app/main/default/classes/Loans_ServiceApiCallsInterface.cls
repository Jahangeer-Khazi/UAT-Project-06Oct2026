/**
 * @author ANISS MBARKI
 * @date Création 07/12/2023
 * @date Modification 
 * @description  - Interface class contains the definition of the different API calls for Loans requirement
 * @history Modifications :
 */
public interface Loans_ServiceApiCallsInterface {

    HttpResponse callGetLoanTransactionsApi(HttpRequest request, Integer statusCode);
    HttpResponse callGetLoanPaymentsScheduleApi(HttpRequest request, Integer statusCode);
    HttpResponse callLoansOptionsAPI(HttpRequest request, Integer statusCode);
    HttpResponse getUserApplicationInfoAPI(HttpRequest request, Integer statusCode);
    HttpResponse createLoanApplicationApi(HttpRequest request, Integer statusCode);
    HttpResponse updateLoanApplicationApi(HttpRequest request, Integer statusCode);
    HttpResponse getExistingLiabilitiesAPI(HttpRequest request, Integer statusCode);
    HttpResponse getCustomerProductsAPI(HttpRequest request, Integer statusCode);
    HttpResponse getAppFulfillmentIdAPI(HttpRequest request, Integer statusCode);
    HttpResponse getLoanCalculatorMatrixAPI(HttpRequest request, Integer statusCode);
    HttpResponse getLoanEarlySettlementDetailsAPI(HttpRequest request, Integer statusCode);
    HttpResponse getLoanPartialSettlementDetailsAPI(HttpRequest request, Integer statusCode);
}