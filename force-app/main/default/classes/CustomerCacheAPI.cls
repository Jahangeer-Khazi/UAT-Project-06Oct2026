/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:31-05-2022
 * 		Change History: 
 *			  
*/
global class CustomerCacheAPI {
private static ApiConnection con = new ApiConnection();
@future(callout=true)
    public static void customerCache(Set<Id> setAccId){
        List<Account> lstAcc = [Select id, PersonContactId, CIF__pc, PersonEmail, Mobile_Country_Code__pc, PersonMobilePhone, Mobile_Country_Code_Update__pc, Phone,Region_Flag__c  from Account where id in: setAccId];
        for(Account acc : lstAcc){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('DELETE', '/api/v1/customers/cache',acc.Region_Flag__c);
            request.setHeader('userId', acc.PersonEmail);
            request.setHeader('customerId', acc.CIF__pc);
            //request.setTimeout(120000);
            HttpResponse response = http.send(request);
            if(response.getStatusCode()!= 200){
                 System.debug('Error Response in Customer Cache API:'+response.getBody());
            }
            else{
                System.debug('Success Response in Customer Cache API:'+response.getBody());
            }
        }
    }
}