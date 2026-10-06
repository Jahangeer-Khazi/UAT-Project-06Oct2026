public without sharing class LTNG066_CustomerRestrictionController {

    @AuraEnabled
    public static String loadRetrieveCustomerRestrictions(String recordId, String pageType){
        System.debug('loadRetrieveCustomerRestrictions recordId--> '+ recordId + '; pageType --> '+ pageType );
        ApiConnection con = new ApiConnection();
        String errorMsg;
        List<System_Action__c> lstSA = new List<System_Action__c>();

        if(recordId != null && recordId != '' ){
            Case caseRecord = [SELECT Id,Case_Model__c,Region_Flag__c, Account.PersonEmail, Customer_CIF__c,accountId,Type FROM Case WHERE Id=: recordId];
            String regionName = caseRecord.Region_Flag__c;
            String caseModel = caseRecord.Case_Model__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('GET','/api/v1/toDoAshish?',regionName);
    
            request.setHeader('userId', caseRecord.Account.PersonEmail);
            request.setHeader('customerId', caseRecord.Customer_CIF__c);
            
            //toDo : set Body ..
            //system.debug('---> Request --> '+request.getBody());

            HttpResponse response;
            if( test.isRunningTest() ){//uncomment : use real api later
                response = new Http().send(request);
            }else{
                //fake response
                response = new HttpResponse();
                //"Lock a specific amount" //lockSpecificAmount
                //"Block a specific account or all accounts" //blockAccounts
                //"Cancelled Residency Permit" //cancelledResidencyPermit
                //"Blacklisted status" //blacklistedStatus
                //"Exit case in progress" //exitCaseInProgress
                String body = '{ "meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"lockSpecificAmount":true,"blockAccounts":false,"cancelledResidencyPermit":true,"blacklistedStatus":true,"exitCaseInProgress":true} }';
                response.setStatus('OK');    
                response.setStatusCode(200);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json');
            }
            system.debug('---> Response New --> '+response.getBody());
    
            if (response.getStatusCode() != 200 ) {
                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint(),request.getMethod(),
                                                    caseRecord.id,caseRecord.Customer_CIF__c,caseRecord.accountId,response.getStatusCode(), 
                                                    'loadRetrieveCustomerRestrictions Api', caseRecord.Type
                                                    ));
            }else {
                List<String> lstErrors = new List<String>();
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> mData = (Map<String, Object>)m.get('data');
                System.debug('mData --> '+ response.getBody());
                Boolean lockSpecificAmount = (Boolean)mData.get('lockSpecificAmount');
                if(lockSpecificAmount){
                    lstErrors.add('Lock a specific amount');
                }
                Boolean blockAccounts = (Boolean)mData.get('blockAccounts');
                if(blockAccounts){
                    lstErrors.add('Block a specific account or all accounts');
                }
                Boolean cancelledResidencyPermit = (Boolean)mData.get('cancelledResidencyPermit');
                if(cancelledResidencyPermit){
                    lstErrors.add('Cancelled Residency Permit');
                }
                Boolean blacklistedStatus = (Boolean)mData.get('blacklistedStatus');
                if(blacklistedStatus){
                    lstErrors.add('Blacklisted status');
                }
                Boolean exitCaseInProgress = (Boolean)mData.get('exitCaseInProgress');
                if(exitCaseInProgress){
                    lstErrors.add('Exit case in progress');
                }

                if(lstErrors != null && lstErrors.size()>0 ){
                    errorMsg = 'The customer has the following restriction(s): '+ String.join(lstErrors, '; ');
                }
            }

            if(lstSA != null && lstSA.size()>0){
                insert lstSA;
            }
        }

        if(UserInfo.getUserId() != '0053N000006tZMjQAM'){
            errorMsg = null;
        }

        return errorMsg;
    }
}