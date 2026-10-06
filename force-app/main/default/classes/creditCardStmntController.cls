public class creditCardStmntController {
    private static ApiConnection con = new ApiConnection();
     private final static List<String> SENSITIVE_FIELDS_ACCOUNT_DETAILS = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance'
    };
    
   @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadCreditCardStatement(final String customerId,final String pciNumber,string regionName, string requestTextJson){
        final ApiConnection.Response response = SM001_ApiCalls.callCreditCardStatementApi(con,customerId,regionName,requestTextJson);
        
        System.debug(JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
        }
        return response;
    }
	
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getCardStatements(final String customerId,final String pciNumber,string regionName, string requestTextJson){
        final ApiConnection.Response response = SM001_ApiCalls.callCreditCardStatementDetailsApi(con,customerId,regionName,requestTextJson);
        
        System.debug(JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
        }
        return response;

    }
}