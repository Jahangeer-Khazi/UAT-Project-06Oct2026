public class LTNG058_CWPUNBLOCKACCOUNT {

    
    @InvocableMethod(label='Block/Unblock Account Api' description='The purpose of this service is to block accounts' callout=true )
    public static  List<String>  blockunblockAccountApiFromFlow(List<String> reqBlockUnblockAcc)
    {       
        UnblockAccountApi(reqBlockUnblockAcc);       
        return null;       
    }
    
    
    @future(callout=true)
    public static void UnblockAccountApi(List<String> CWPIds)
    {
       System.debug('unblockAccountApi*****************************');
        System.debug(CWPIds);
        Canceled_WP__c caseOb = [SELECT Id, Name, Case__c, Action__c, Prior_Status__c, Status__c, Customer_CIF__c, Customer__c FROM Canceled_WP__c WHERE Id = :CWPIds LIMIT 1];
        List<Account> accs = [SELECT Id,x_canary__pc,Region_Flag__pc,subscription_Model__pc FROM Account WHERE id=:caseOb.Customer__c LIMIT 1];
                String regionName = accs[0].Region_Flag__pc;//CH03
                if(accs[0].subscription_Model__pc == 'alburaq'){
                    regionName += '_alburaq';
                }
                //toDo : use api uncomment this part
                ApiConnection con = new ApiConnection();
                HttpRequest request = con.createRequest('POST','/api/v1/customer-products/restriction',regionName);//CH03
                //#CH02 : start
                
                if(accs!= null && accs.size()>0){
                    System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                    if(accs.get(0).x_canary__pc != null){
                        request.setHeader('x-canary', accs.get(0).x_canary__pc);
                    }
                }
                //#CH02 : end
               String Status='UNBLOCK';
                String type='ALL';
                request.setHeader('customerId', caseOb.Customer_CIF__c);
                System.debug('Request'+request);
          String body =  '{  "action":'+stringApiFormat('UNBLOCK')+
                            ',"type": '+stringApiFormat(type)+
                        '}';
        request.setBody(body);
        System.debug(request.getBody());
      
        HttpResponse response = EM001_ApiCalls.blockUnblockAccountApi(request,200);
                System.debug('response'+response);
                //HttpResponse response = new HttpResponse();
                // Create Manually json response For Test Class
                //String body = '{    "meta": {        "code": "ACCT-1008",        "message": "Account has blocked successfully."    },  "data": {}}';
                //response.setStatus('OK');
                //response.setStatusCode(200);
                //response.setBody(body);
                //response.setHeader('Content-Type', 'application/json');
                
                System.debug('Body###'+response.getBody());
                Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object>  validatecode = (Map<String, Object>) deserialized.get('meta');
                system.debug('deserialized'+deserialized);
                system.debug('m3'+validatecode.get('code'));
                if (response.getStatusCode() != 200 || (validatecode.get('code') !='ACCO-1011' && response.getStatusCode()== 200)) {
                }
                
                else{
                }  
    }
      public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
       
}