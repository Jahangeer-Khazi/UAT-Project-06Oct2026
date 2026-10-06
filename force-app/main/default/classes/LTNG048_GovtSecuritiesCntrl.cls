/**
* @author Jayanth Manickam
* @date Création 25/06/2024
* @date Modification
* @description :Contact Center - GovtSecurities List View
* @history Modifications :   
*  
*/

public class LTNG048_GovtSecuritiesCntrl {
 
    //To get the list of Instruments via Api
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadGovSecurities(String regionName, String customerId) {  
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/bond/instruments?filterOption=BIDABLE',regionName);
            request.setHeader('customerId',customerId);
            System.debug('customerId==>'+customerId);
            System.debug('request==>'+Request.getEndpoint());
            //toDo : use api 
            ApiConnection.Response response = con.makeCallout(request);           
            if (!response.isSuccess && null == response.responseData ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.responseData ;
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                System.debug(response.responseData);
                System.debug('InstrumentList######'+JSON.serializePretty(response.responseData));
            }
         return response;
    }
    
        //To get the list of customer via Api
    @AuraEnabled(cacheable=false)
    public static List<Account> getCustomerDetails(String regionName, String customerId) {  
         List<Account>customerDetails=[Select Id, CIF__pc, Name, Segment__pc, PersonMobilePhone, PersonEmail, Subscription_Model__pc From Account Where CIF__pc=:customerId];
         return customerDetails;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getHistoryDetails(String regionName, String subType) {     
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/bond/instrument/historical-rates?subType='+subType, regionName);
            System.debug('request==>'+Request.getEndpoint());
            //toDo : use api 
           ApiConnection.Response response = con.makeCallout(request); 
            if (!response.isSuccess && null == response.responseData ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.responseData ;
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                System.debug(response.responseData);
                System.debug('InstrumentList######'+JSON.serializePretty(response.responseData));
            }
           System.debug(response.responseData);
           system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response.responseData));
            //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.responseData);
         return response;
    }
    
}