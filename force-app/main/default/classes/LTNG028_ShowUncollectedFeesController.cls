/**
 *  @author: Wissal Benqezza
 *  @date: 2022-11-02  
 *  @description:
 *      controller for aura component "LTNG028_ShowUncollectedFees"
 *     
 *      
 */
public class LTNG028_ShowUncollectedFeesController {
    

    private static ApiConnection con = new ApiConnection();
    private static String CLASS_NAME = LTNG028_ShowUncollectedFeesController.class.getName();

   
    //Add regionName parameter by elmustapha elgarni
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response callUncollectedFeesApi(String customerId,String requestTextJson,string regionName){
        PAD.debugLogBegin(CLASS_NAME, 'callUncollectedFeesApi', 'Parameters : [customerId] : '+customerId +', [requestTextJson] : '+requestTextJson);
         ApiConnection.Response response = SM001_ApiCalls.callUncollectedFeesApi(con,customerId,requestTextJson,regionName);
         system.debug('response-- '+response);
        
//         //fake response
//         HttpResponse response1 = new HttpResponse();
//         String body =
//  '{"meta": {"code": "TRAN-1009","message": "Transaction Details for Account Id has been retrieved successfully."},"data": {"transactions": [{"id": "BH09ABCO00929029882","holdDate": "2019-01-01","holdExpiryDate": "2019-08-01","holdType": "Release Debit Card Transaction","holdCurrency": "","holdAmount": "100","holdReferenceNumber": "1254555","previousBalance": "2019-01-31","currentBalance": "","generateAdvice": "completed","holdDescription1":"","holdDescription2":"","holdDescription3":"","holdDescription4":"","holdDescription5":"","holdDescription6":""}]}}';

//         response1.setStatus('OK');
//         response1.setStatusCode(200);
//         response1.setBody(body);
//         response1.setHeader('Content-Type', 'application/json');
         //Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        // ApiConnection.Response response = new ApiConnection.Response();
        
        //response.responseData = resMap.get('data');
       // response.isSuccess = true;
        
        PAD.debugLogEnd(CLASS_NAME, 'callUncollectedFeesApi', '[RESULTS] :' + JSON.serializePretty(response));
        return response;
    }
 }