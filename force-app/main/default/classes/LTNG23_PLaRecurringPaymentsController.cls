/**
 *  @author: Aniss Mbarki
 *  @date: 2022-05-09  
 *  @description:
 *      controller for aura component "LTNG23_PLaRecurringPayments"
 *      
 */
public with sharing class LTNG23_PLaRecurringPaymentsController {

    private static ApiConnection con = new ApiConnection();
    private static String CLASS_NAME = LTNG23_PLaRecurringPaymentsController.class.getName();


    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getScheduledPlaPayments(String customerId,String requestTextJson, String regionName){
        PAD.debugLogBegin(CLASS_NAME, 'getScheduledPlaPayments', 'Parameters : [customerId] : '+customerId +', [requestTextJson] : '+requestTextJson);
        
        //ApiConnection.Response response = new MCK001_ApiCalls().callScheduledPlaPaymentsApi(null,null,200);
        ApiConnection.Response response = SM001_ApiCalls.callScheduledPlaPaymentsApi(con,customerId,requestTextJson,regionName);
        
        
        PAD.debugLogEnd(CLASS_NAME, 'getScheduledPlaPayments', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }


    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getSchedulRecPayDetails(String customerId ,String scheduleId,  String regionName){
        PAD.debugLogBegin(CLASS_NAME, 'getSchedulRecPayDetails', 'Parameters : [customerId] : '+customerId +', [scheduleId] : '+scheduleId);
        
        //ApiConnection.Response response = new MCK001_ApiCalls().callScheduledPlaPaymentDetailsApi(null,null,200);
        ApiConnection.Response response = SM001_ApiCalls.callScheduledPlaPaymentDetailsApi(con,customerId,scheduleId,regionName);
        
        PAD.debugLogEnd(CLASS_NAME, 'getSchedulRecPayDetails', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }

}