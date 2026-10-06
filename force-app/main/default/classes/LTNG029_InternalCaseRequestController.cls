/***
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 02-16-2023
 * last modified by  :  20-12-2023 CH01: Added by Imane Tsioucha (Credit Card Collection Cases Requirement)
 * *			                   #CH03# #Jahangeer Mohammed# #24-02-2025# Added Logic for Re-applying Control Feature(NBA-13039)
  
**/
public with sharing class LTNG029_InternalCaseRequestController {
    
    private static String CLASS_NAME = LTNG029_InternalCaseRequestController.class.getName();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    private static ApiConnection con = new ApiConnection();
    @TestVisible 
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_DETAILS = new List<String>{
            'currency',
            'creditLimit',
            'availableCreditLimit',
            'holdAmount',
            'lastPaymentAmount',
            'availableCashLimit',
            'lastStatementBalance',
            'unbilledAmount',
            'cashLimit',
            'minimumDues',
            'totalDues',
            'pastDues',
            'pointsBalance',
            'accountBlockCode1',
            'accountBlockDate1',
            'accountBlockCode2',
            'accountBlockDate2',
            'usedCreditLimit'
            };
     private final static List<String> SENSITIVE_FIELDS_ACCOUNT_LIST = new List<String>{
        'currency',
        'creditLimit',
        'availableCreditLimit',
        'holdAmount',
        'lastPaymentAmount',
        'availableCashLimit',
        'lastStatementBalance',
        'unbilledAmount',
        'cashLimit',
        'minimumDues',
        'totalDues',
        'pastDues',
        'pointsBalance'
        };    
        private final static List<String> SENSITIVE_FIELDS_EPP_List = new List<String>{
            'tenor',
            'transactionAmount',
            'numberOfInstallementsPaid',
            'numberOfInstallementsRemaining',
            'installementAmount',
            'remainingBalance'
      };       
     

      //start omar
     
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadLoansList(final String customerId, Final String caseModel) {
        return Loans_LoansListController.loadLoansList(customerId, caseModel);
    }
//end omar

    @AuraEnabled(cacheable=false)
     //CH01: To retrieve credit card from API
    public static Map<String,Object> getPCIOptionsV2(String accID,String caseModel){
        Map<String,Object> retrivePCIOption = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c FROM Account WHERE Id=: accID];
         
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);

        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        system.debug('testttt==> '+response.getStatusCode());
        if (response.getStatusCode() == 200)
        
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1); 
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); 
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                if(mapRelatedCurrentCards.containsKey('id')  ){
                  //  String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                   
                        retrivePCIOption.put((String)mapRelatedCurrentCards.get('id'),mapRelatedCurrentCards);
                    
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
        }
        return retrivePCIOption;
    }

      //CH01: To retrieve credit card details from API
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadCardDetails(final String customerId, final String cardId, final String personEmail, String regionName) {
        Map<String, Object> resMap;
        final HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards/'+cardId+'/details', customerId, personEmail, regionName);
        req.setTimeout(120000);
        
        system.debug('---> REQUEST --> '+req);
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('---> RESPONSE --> '+response);
        system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response));
        //added by shashank
        if (response.isSuccess && null != response.responseData ||(test.isRunningTest())) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                system.debug('SENSITIVE_FIELDS_ACCOUNT_DETAILS||'+SENSITIVE_FIELDS_ACCOUNT_DETAILS);
                CreditCard_SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
       
        }
        
        return response;
    }

    

    @AuraEnabled
	public static Id getInternalCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Internal_Case').getRecordTypeId();
    }


    //CH02: Start
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> loadDeviceList(String accID,String caseModel){
        Map<String,Object> retriveDeviceOptions = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c FROM Account WHERE Id=: accID];
         
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/ping/user/devices', regionName);

        //request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);

        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        
        //HttpResponse response = http.send(request);
        //fake responses : ...
        HttpResponse response;
        if ( test.isRunningTest() ) {
            response = new HttpResponse();
            String body = '{"meta": {"code": "PING-2001","message": "Ping user device details has been retrieved successfully"},"data": {"devices": [  {"id": "cd6607a1-3229-4ce5-b4e0-1e11a995a881","status": "ACTIVE","manufacturer": "Apple","model": {"name": "iPhone10,6","marketingName": "iPhone X"},"os": {"name": "IOS","version": "16.0"},"createdAt": "2023-09-21T11:30:15","updatedAt": "2023-12-25T15:56:10"},{"id": "acddb6a7-8d25-4e33-a6fc-9e7d9bd7f8c5","status": "ACTIVE","manufacturer": "Google","model": {"name": "Pixel 6","marketingName": "Pixel 6"},"os": {"name": "ANDROID","version": "13.0"},"createdAt": "2023-08-28T16:02:47","updatedAt": "2023-08-29T07:51:26"} ] }}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json'); 
            system.debug('---> Responce New --> '+response.getBody());
        }else {
            response = http.send(request);
            system.debug('---->> response.getStatusCode() --> '+response.getStatusCode());
            system.debug('---->> response.getBody() --> '+response.getBody());
        }

        if (response.getStatusCode() == 200)
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1); 
            List<Object> devicesList = (List<Object>)m1.get('devices'); 
            System.debug('---> LIST devicesList --> '+devicesList);
            List<Map<String, Object>> lstDeviceMap = new List<Map<String, Object>> ();
            for(Object deviceObj : devicesList){
                lstDeviceMap.add((Map<String, Object>)deviceObj);
                system.debug('---->> deviceObj Iterations --> '+deviceObj);
                 
            }
            for(Map<String,Object> mapRelatedDevice : lstDeviceMap){
                if(mapRelatedDevice.containsKey('id')  ){
                    retriveDeviceOptions.put((String)mapRelatedDevice.get('id'),mapRelatedDevice);
                }
            }
            system.debug('retriveDeviceOptions||'+retriveDeviceOptions);
        }
        return retriveDeviceOptions;
    }

    @InvocableMethod(label='call PingOne Platform API - Delete MFA User Device' description='call PingOne Platform API - Delete MFA User Device')
    public static List<String> deleteDeviceApiFromFlow(List<Id> caseIds)
    {
        //deleteDeviceApiFuture(new Set<Id>(caseIds));
		System.enqueueJob(
            new DeleteDeviceApiQueueable(new Set<Id>(caseIds))
        );
        return caseIds;
    }
    @future(callout=true)
    public static void deleteDeviceApiFuture (Set<Id> caseIds)
    {
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for(Case caseObj : cases){
            try {

                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }
                
                Http http = new Http();
                //HttpRequest request = con.createRequest('DELETE', '/api/v1/ping/user/devices/'+caseObj.Hold_ID__c,regionName);
                HttpRequest request = con.createRequest('POST', '/api/v1/devices/unpairing?',regionName);
                
                //request.setHeader('userId', caseObj.Account.PersonEmail);
                request.setHeader('customerId', caseObj.Account.CIF__pc);
                request.setBody('{"deviceId": "'+caseObj.Hold_ID__c+'","reason": "REASON_DONT_USE"}');
                request.setTimeout(60000);
                HttpResponse response;
                if ( test.isRunningTest() ) {
                    //fake response 
                    response = new HttpResponse();
                    String body1 = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."}}';
                    response.setStatus('OK');    
                    response.setStatusCode(200);
                    response.setBody(body1);
                    response.setHeader('Content-Type', 'application/json');
                }else{
                    response = http.send(request);
                }

                //store response as system action !
                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                        request.getEndpoint(),request.getMethod(),
                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                        'Calling PingOne Platform API - Delete MFA User Device', caseObj.Type
                        ));
                
                
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    caseObj.Last_Api_Call_Status__c = 'Failed';
                }
                else
                {
                    caseObj.Status = 'Closed';
                }
                
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                         caseObj.Type+' deleteDeviceApi (unhandled error)', caseObj.Type
                                                        ));
                caseObj.Last_Api_Call_Status__c = 'Failed';
            }

        }

        if(cases != null && cases.size()>0){
            update cases;
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
    }
    //CH02: End
    
    //CH03: Start
    @AuraEnabled
	public static Boolean checkCreditCardUser(String userId) {
        System.debug('User Id:'+userId);
        User u = [Select Id,Cannot_Close_Non_Credit_Card_Application__c from User where Id =: userId];
        return u.Cannot_Close_Non_Credit_Card_Application__c;
    }
    //CH03: END
}