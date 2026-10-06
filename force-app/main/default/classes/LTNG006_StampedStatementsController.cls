/**
 *  @author: Aniss Mbarki
 *  @date: 2022-01-06  
 *  @description:
 *      controller for aura component "LTNG006_StampedStatements"
 *      display bank Account Statements List
 *      
 */
public with sharing class LTNG006_StampedStatementsController {

    private static ApiConnection con = new ApiConnection();
    private static String CLASS_NAME = LTNG006_StampedStatementsController.class.getName();

    @AuraEnabled(cacheable=false)
    public static Boolean stampedStatementVisibility(String accountId){
        PAD.debugLogBegin(CLASS_NAME, 'stampedStatementVisibility', 'Parameters : [accountId] : '+accountId );
        Boolean isVisible = SensitiveDataCleaner.checkStaffVisibilityForStatements(accountId);
        PAD.debugLogEnd(CLASS_NAME, 'stampedStatementVisibility', '[isVisible] : ' + isVisible );
        return isVisible;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountStatements(String customerId,String requestTextJson){
        PAD.debugLogBegin(CLASS_NAME, 'loadAccountStatements', 'Parameters : [customerId] : '+customerId +', [requestTextJson] : '+requestTextJson);
        ApiConnection.Response response = SM001_ApiCalls.callAccountStatementsApi(con,customerId,requestTextJson);
        PAD.debugLogEnd(CLASS_NAME, 'loadAccountStatements', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }



    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getAccountStatementDetails(String customerId ,String requestTextJson){
        PAD.debugLogBegin(CLASS_NAME, 'getAccountStatementDetails', 'Parameters : [customerId] : '+customerId +', [requestTextJson] : '+requestTextJson);
        //ApiConnection.Response response = new MCK001_ApiCalls().callAccountStatementsDetailsApi(null,null,200);
        ApiConnection.Response response = SM001_ApiCalls.callAccountStatementsDetailsApi(con,customerId,requestTextJson);
        PAD.debugLogEnd(CLASS_NAME, 'getAccountStatementDetails', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }

}