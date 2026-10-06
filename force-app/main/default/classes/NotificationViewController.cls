/**
*  @author: Shruti K
*  @date: 2022-03-07 
*  @description:controller for aura components related to Notification view
*  Version History :
*  CRM-37 - AG
*  display notification list 
*
*/
public class NotificationViewController {
    private static ApiConnection con = new ApiConnection();
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountTransactions(final String customerId,final String searchParametersJson, String regionName) {
        system.debug('customerId'+customerId);
        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = new List<Object>();
        List<Object>mockFilter = New List<Object>();
        List<Object>mockSearchParam = New List<Object>();
        try{
            final String path = '/api/v1/notifications?';
            final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
            req.setTimeout(120000);
            req.setBody(searchParametersJson);
            System.debug('Request Body:'+req.getBody());
            // response = con.makeCallout(req);
            /*Mocked Response-start*/
            response.isSuccess= true;
            response.responseData=(Map<String, Object>)JSON.deserializeUntyped('{"messages" : [{"notificationType":"SMS","templateCode":"TEST","category": "CREDIT CARD","notificationDate" : "2022-01-15T15:15:15","mobileNumber":"+97333100000","email": "example@example.com"},{"notificationType":"Email","templateCode":"Draft","category": "CREDIT CARD","notificationDate" :"2022-08-15T15:15:15","mobileNumber":"+97333100000","email": "example@example.com"}]}');
            /*end*/
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            System.debug('Response data keys:'+responseData.keySet());
            Object[] transactions = (Object[])responseData.get('messages');
            NotificationViewController.MyPayload objParsedWrapper = NotificationViewController.parse(searchParametersJson);
            if (response.isSuccess && null != response.responseData){
                /*mock setting need to be removed start*/
                System.debug('objParsedWrapper.fromDate'+objParsedWrapper.fromDate);
                System.debug('objParsedWrapper.toDate'+objParsedWrapper.toDate);
                System.debug('datval'+Date.ValueOf('2022-01-15'));
                if((objParsedWrapper.fromDate !=null && objParsedWrapper.fromDate<=Date.ValueOf('2022-01-15'))&&(objParsedWrapper.toDate!=null && objParsedWrapper.toDate>=Date.ValueOf('2022-01-15'))){
                    mockFilter.add(transactions[0]);
                }
                if((objParsedWrapper.fromDate !=null && objParsedWrapper.fromDate<=Date.ValueOf('2022-08-15'))&&(objParsedWrapper.toDate!=null && objParsedWrapper.toDate>=Date.ValueOf('2022-08-15'))){
                    mockFilter.add(transactions[1]);
                }
                response.recordLength = mockFilter.size();
                response.responseData = mockFilter;
                /*mock setting remove end*/
                /*uncomment below actual code
                response.recordLength = transactions.size();
                response.responseData = transactions;*/
            }
            System.debug('Response object:'+response);
            return response;   
        }catch(exception ex){
            System.debug('Exception Occured:>>>'+ex.getMessage()+' LineNumber>>>'+ex.getLineNumber());
            response.isSuccess = false;
            return response;
        }
    }
    
    /*mock response*/
    public class MyPayload {
        public Date fromDate {get;set;}
        public Date toDate {get;set;}
        public String category {get;set;}
        
    }
    public static MyPayload parse(String json) {
        return (MyPayload) System.JSON.deserialize(json, MyPayload.class);
    }
}