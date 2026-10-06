/**
*  @author: YZ
*  @date: 2022-06-27
*  @description:
*       Controller for Aura actions in following components: JordanCivilDepartment
*       Change History:
*              #CH01# Added #28-06-2022# Added by Navin for IBJ-6002 Civil Department retry
               #CH02# Added #12-07-2022# Added by Navin for IBJ-6002 Identification Rejected
*/
public with sharing class JordanCivilDepartmentController {
    @TestVisible
    private static ApiConnection con = new ApiConnection();

    @AuraEnabled(cacheable=false)
    public static Case getCaseDetails (String caseId) {
        if(caseId == null || caseId == '') return new Case();
        String query = 'Select Status, AccountId, Type, Origin, RecordType.Name, Region_Flag__c';
        system.debug('QUERY: '+query);
        return database.query(query + ' from Case where Id =:caseId');
    }
   
    @AuraEnabled(cacheable=false)
    public static Boolean eKycRetry (String caseId) {        
        return eKycCall (caseId, 'Retry');
    } 

    @AuraEnabled(cacheable=false)
    public static Boolean eKycConvert (String caseId) {
        return eKycCall (caseId, 'Convert');
    }

    public static Boolean eKycCall (String caseId, String caseStatus) {
        Boolean responseSuccess = false;
        Case retrievedCase = [SELECT Id, AccountId, Account.PersonEmail, Type, Region_Flag__c, Account.CIF__pc
                       FROM Case WHERE Id =: caseId];
        String body = '{"caseId": "'+retrievedCase.Id + 
                          '","email": "'+retrievedCase.Account.PersonEmail + 
                          '","caseType": "'+retrievedCase.Type + 
                          '","caseStatus": "'+caseStatus+'"}';                          
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request = con.createRequest('POST', '/api/v1/onboarding/continue?', retrievedCase.Region_Flag__c);
        request.setBody(body);
        request.setHeader('userId', retrievedCase.Account.PersonEmail);
        request.setHeader('customerId', retrievedCase.Account.CIF__pc);    
        System.debug('@@@ Request '+request.getBody());
        // HttpResponse response = http.send(request);
        
        System_Action__c action = new System_Action__c(Case__c = retrievedCase.Id, Account__c = retrievedCase.AccountId, Origin__c = 'CRM', Source_Timestamp__c = String.ValueOf(Datetime.now()), Method__c = 'PUT', Endpoint__c = request.getEndpoint(), Request_Body__c = request.getBody(), Type__c = 'On-boarding');
        ApiConnection apConn = new ApiConnection();
        ApiConnection.Response response = new ApiConnection.Response();
        response = apConn.makeCallout(request, action);

        if (!response.isSuccess) {
            responseSuccess = false;
            System.debug('The status code returned was not expected: ' + response.errorData);
            System.debug('@@@ Response '+response.responseData);
        }
        else {  
            responseSuccess = true;
        }
        
        /*if (response.getStatusCode() != 200) {
            responseSuccess = false;
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('@@@ Response '+response.getBody());
        }
        else {  
            responseSuccess = true;
        }*/
        return responseSuccess;
    }

    @InvocableMethod
    public static void civilDepartmentInvocableLogic (List<Requests> requestList) {
        // This logic is being triggered from Flow "Jordan Civil Department Logic"
        Id jobId = System.enqueueJob(new eKycLogicQueueable(requestList[0].caseId, requestList[0].logicLabel));
        System.debug('@@@ eKycLogicQueueable job Id '+jobId);
    }

    public class Requests {
        @InvocableVariable(label='Logic' description='Indicates which logic needs to be executed' required=true)
        public String logicLabel;
        @InvocableVariable(label='Case ID' description='Case ID' required=true)
        public Id caseId;
    }

    private class eKycLogicQueueable implements Queueable, Database.AllowsCallouts {
        private String logic;
        private Id caseId;
        public eKycLogicQueueable(Id caseId, String logic) {
            this.logic = logic;
            this.caseId = caseId;
        }
        public void execute(QueueableContext context) {
            switch on this.logic {
                when 'eKYC Approved' {
                    eKycCall (this.caseId, 'Approved');
                }	
                when 'eKYC Rejected' {		 
                    eKycCall (this.caseId, 'Rejected');
                }
                when 'Identification Rejected' {		 
                    identificationCall (this.caseId, 'Rejected');
                }                
            }
        }
    }
    
    // #CH01# IBJ-6003  - Civil Department retry
    @AuraEnabled(cacheable=false)
    public static Boolean eKYCCase(String caseId) {
        Boolean civilDataResponse;

        Case cItem  = [SELECT Id, status, Sub_Status__c, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c,AccountId,
                       Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc, ContactId, Region_Flag__c
                       FROM Case WHERE Id =: caseId];

        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(new List<Case>{cItem});

        // IBJ-6002 and IBJ-6003
        String body = '{"uidValue": "true","crmSync":"true","promoteGovernmentDataToCustomerProfile":"false"}';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        //api/v1/government-data/wathiq/person?language=en&unit=neo
        request = con.createRequest('PUT', '/api/v1/government-data/jo-civil-service/person?',  cItem.Region_Flag__c);
        
        system.debug('---> BODY --> '+body);
        system.debug('userId: '+cItem.Account.PersonEmail);
        system.debug('customerId: '+cItem.Account.CIF__pc);
        
        request.setBody(body);
        request.setHeader('userId', cItem.Account.PersonEmail);
        request.setHeader('customerId', cItem.Account.CIF__pc);
        //request.setTimeout(50000);
        system.debug('---> Request --> '+request);

        System_Action__c action = new System_Action__c(Case__c = cItem.Id, Account__c = cItem.AccountId, Origin__c = 'CRM', Source_Timestamp__c = String.ValueOf(Datetime.now()), Method__c = 'PUT', Endpoint__c = request.getEndpoint(), Request_Body__c = request.getBody(), Type__c = 'On-boarding');
        ApiConnection apConn = new ApiConnection();
        ApiConnection.Response response = new ApiConnection.Response();
        response = apConn.makeCallout(request, action);

        if (!response.isSuccess)
        {
            civilDataResponse = false;
            System.debug('The status code returned was not expected: ' + response.errorData);
            //throw new AuraHandledException('Error from API');
            
        }
        else
        {
            if(response.isSuccess){
                civilDataResponse = true;
                //IBJ-6003
                if(cItem.Type=='Civil Department'){
                    System.debug('response.responseData: '+response.responseData);
                    if(String.isNotBlank(String.ValueOf(response.responseData))){
                        // Map<String, Object> jsonResultMap = (Map<String, Object>) JSON.deserializeUntyped(String.ValueOf(response.responseData));
                    }
                    // If further processing is needed, this can be done easily from the response.
                }
            }
        }        
        
        /* HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200)
        {
            civilDataResponse = false;
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //throw new AuraHandledException('Error from API');
            
        }
        else
        {
            if(response.getStatusCode() == 200){
                civilDataResponse = true;
                //IBJ-6003
                if(cItem.Type=='Civil Department'){
                    if(String.isNotBlank(response.getBody())){
                        Map<String, Object> jsonResultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    }
                    // If further processing is needed, this can be done easily from the response.
                }
            }
        }*/
        
        return civilDataResponse;
    }

    // #CH02# IBJ-6002  - Identification Rejected
    public static Boolean identificationCall (String caseId, String caseStatus) {
        Boolean responseSuccess = false;
        Case retrievedCase = [SELECT Id, AccountId, Account.PersonEmail, Type, Region_Flag__c, Account.CIF__pc
                       			FROM Case WHERE Id =: caseId];
        String body = '{"email": "'+retrievedCase.Account.PersonEmail + 
                        '","caseType": "'+retrievedCase.Type + 
                        '","caseStatus": "'+caseStatus+'"}';                          
        Http http = new Http();
        HttpRequest request = new HttpRequest(); 
        request = con.createRequest('POST', '/api/v1/onboarding/continue?', retrievedCase.Region_Flag__c);
        request.setBody(body);
        System.debug('retrievedCase.Account: '+retrievedCase.Account);
        request.setHeader('userId', retrievedCase.Account.PersonEmail);
        request.setHeader('customerId', retrievedCase.Account.CIF__pc);    
        System.debug('@@@ Request '+request.getBody());
        // HttpResponse response = http.send(request);
        
        System_Action__c action = new System_Action__c(Case__c = retrievedCase.Id, Account__c = retrievedCase.AccountId, Origin__c = 'CRM', Source_Timestamp__c = String.ValueOf(Datetime.now()), Method__c = 'PUT', Endpoint__c = request.getEndpoint(), Request_Body__c = request.getBody(), Type__c = 'On-boarding');
        ApiConnection apConn = new ApiConnection();
        ApiConnection.Response response = new ApiConnection.Response();
        response = apConn.makeCallout(request, action);

        if (!response.isSuccess) {
            responseSuccess = false;
            System.debug('The status code returned was not expected: ' + response.errorData);
            System.debug('@@@ Response '+response.responseData);
        }
        else {  
            responseSuccess = true;
        }
        
        return responseSuccess;
    }


    
}