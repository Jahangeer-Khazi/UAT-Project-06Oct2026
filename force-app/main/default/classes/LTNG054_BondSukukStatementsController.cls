/**
 *  @author: Jayanth Manickam
 *  @date: 2024-09-24  
 *  @description:
 *      controller for aura component "LTNG054_BondSukukStatementsController"
 *      display bank Bonds Statements List
 *      
 */
public class LTNG054_BondSukukStatementsController {
   private static ApiConnection con = new ApiConnection();
    private static String CLASS_NAME = LTNG054_BondSukukStatementsController.class.getName();

    @AuraEnabled(cacheable=false)
    public static Boolean BondSukukStatementVisibility(String accountId){
        PAD.debugLogBegin(CLASS_NAME, 'BondSukukStatementVisibility', 'Parameters : [accountId] : '+accountId );
        Boolean isVisible = SensitiveDataCleaner.checkStaffVisibilityForStatements(accountId);
        PAD.debugLogEnd(CLASS_NAME, 'BondSukukStatementVisibility', '[isVisible] : ' + isVisible );
        return isVisible;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadBondSukukStatements(String customerId, String regionName){
        PAD.debugLogBegin(CLASS_NAME, 'loadBondSukukStatements', 'Parameters : [customerId] : '+customerId);
        ApiConnection.Response response = SM001_ApiCalls.callBondSukukStatementsApi(con,customerId,regionName);
        PAD.debugLogEnd(CLASS_NAME, 'loadBondSukukStatements', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }



    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getBondSukukStatementDetails(String customerId ,String regionName, String requestTextJson){
        PAD.debugLogBegin(CLASS_NAME, 'getBondSukukStatementDetails', 'Parameters : [customerId] : '+customerId +', [requestTextJson] : '+requestTextJson);
        ApiConnection.Response response = SM001_ApiCalls.callBondSukukStatementsDetailsApi(con,customerId,regionName,requestTextJson);
        PAD.debugLogEnd(CLASS_NAME, 'getBondSukukStatementDetails', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }
}