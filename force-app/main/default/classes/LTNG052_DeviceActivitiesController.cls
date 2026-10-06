public without sharing class LTNG052_DeviceActivitiesController {

    private static ApiConnection con = new ApiConnection();
    private static String CLASS_NAME = LTNG052_DeviceActivitiesController.class.getName();

    @AuraEnabled(cacheable=false)
    public static Object loadDeviceActivities(String accountId){
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,CIF__pc FROM Account WHERE Id = :accountId ];
        String regionName ;
        String caseModel ;
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            caseModel = lstAcc.get(0).Subscription_Model__pc;
        }  
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        HttpRequest req = con.createRequest('GET', '/api/v1/devices/activity', lstAcc.get(0).CIF__pc ,regionName);
        
        HttpResponse response;
        if (test.isRunningTest() ) {
            //fake response 
            response = new HttpResponse();
            String body1 = '{    "meta": {        "code": "AUTH-1002",        "message": "MFA with OTP verification was successful."    },    "data": {      "deviceActivities": [      {        "id": 1,        "action":"UNPAIRED",        "triggeredBy":"CRM",        "reason":"DEVICE_NO_LONGER_USE",        "deviceId":"dfdf-dfdf5-dfdf-fdfdf",        "deviceManufacturer": "SM-59966",        "deviceOs": "Android",        "deviceModel" : "test",        "actionDate": "2024-05-05T20:00:00"      }]    }}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body1);
            response.setHeader('Content-Type', 'application/json');
        }else{
            Http http = new Http();
            response = http.send(req);
        }

        if (response.getStatusCode() != 200 ) {
            String errorMsg = 'The status code returned was not expected when we are calling Get Device Activity API : ' + response.getStatusCode();
            System.debug(errorMsg);
            throw new AuraHandledException(errorMsg);
        }
        else {
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('m1######'+JSON.serializePretty(resMap.get('data')));
            return resMap.get('data');
        }
    }

}