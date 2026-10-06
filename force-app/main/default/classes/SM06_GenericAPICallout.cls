/**
 * @author Elmustapha ELGARNI
 * @date Création 02/11/2023
 * @date Modification
 * @description : A generic function to perform api callouts from flows 
 */
public without sharing class SM06_GenericAPICallout {

    private static String CLASS_NAME = SM06_GenericAPICallout.class.getName();
    public static Integer MockResponseStatusCode = 200;

    @InvocableMethod(label='API callout' description='Perform an API Callout from flow' callout=true )
    public static List<String> apiCallout(List<RequestDetails> RequestDetailsList){



        RequestDetails reqDetails = RequestDetailsList.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('json_header',reqDetails.json_header);
        details.put('json_body',reqDetails.json_body);
        details.put('path',reqDetails.path);
        details.put('method',reqDetails.method);
        details.put('json_ActionsOnSuccess',reqDetails.json_ActionsOnSuccess);
        details.put('json_ActionsOnFailure',reqDetails.json_ActionsOnFailure);

        try{
            //call future method
            genericAPICallout(new Set<Id>{reqDetails.caseId},details);

        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId FROM Case WHERE Id =: reqDetails.caseId];
            caseObj.Last_Api_Call_Status__c = 'Failed';
            update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                null,null,
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                'please check : '+CLASS_NAME+'.genericAPICallout()', 'API callout from flow'
                                            );
        }
        
        return null;
    } 

    @future(callout=true)
    public static void genericAPICallout(Set<Id> caseIds , Map<String,String> details){
        
        List<System_Action__c> lstSA = new List<System_Action__c>();
        ApiConnection con = new ApiConnection();
        
        List<Case> cases = DM002_Case.getListByIds(caseIds);
        String path = details.get('path');
        String method = details.get('method');
        String json_header = details.get('json_header');
        String json_body = details.get('json_body');

        String json_ActionsOnSuccess = details.get('json_ActionsOnSuccess');
        String json_ActionsOnFailure = details.get('json_ActionsOnFailure');

        

        for(Case caseObj : cases){
            String regionName = caseObj.Region_Flag__c;
            if (caseObj.Case_Model__c == 'alburaq') {
                regionName += '_alburaq';
            }
            system.debug('--+ request regionname --> '+regionName);
            system.debug('--+ request method --> '+method);
            HttpRequest request = con.createRequest(method,path,regionName);
            if(json_header != null && json_header != ''){
                Map<String, Object> headersMap = (Map<String, Object>) JSON.deserializeUntyped(json_header);
                for(String key:headersMap.keyset()) {
                    system.debug('--+ headers : '+key+' --> '+headersMap.get(key));
                    request.setHeader(key, (String) headersMap.get(key));
                }
            }
            if(json_body != null && json_body != ''){
                request.setBody(json_body);
            }
            system.debug('--+ request Endpoint --> '+request.getEndpoint());
            system.debug('--+ request method --> '+request.getMethod());
            system.debug('--+ request json_header --> '+json_header);
            system.debug('--+ request json_body --> '+json_body);
            
            HttpResponse response = new HttpResponse();
            if(!Test.isRunningTest()){
                //Send Request
                response = new Http().send(request);
            } else{
                // fake response 
                String body = '{    "meta": {        "code":"CCRD-1500",        "message": "Credit card request status has been updated successfully"    },   "data":{            "applicationReferenceNumber":"",            "primaryMaskedCardNumber":"",    		"primaryPciNumber":"",			"supplementary1MaskedCardNumber":"",            "supplementary1PciNumber":"",            "supplementary2MaskedCardNumber":"",            "supplementary2PciNumber":"",            "holdAmount" : 3.30,            "holdAccount" : "IBN84598878778",            "holdAccountBalance" : 0.0,            "holdReferenceNumber" : "123596288"	}}';
                response.setStatus('OK');    
                response.setStatusCode(MockResponseStatusCode);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json');
                system.debug('--+ Responce New --> '+response.getBody());
            }


            if(response.getStatusCode() != 200){
                System.debug('Invalid generic Status API');
                caseObj.Last_Api_Call_Status__c = 'Failed';
                
                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                request.getEndpoint(),request.getMethod(),
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                'Generic Request Status API', 'Generic API Callout'
                                            ));

                // Handle On failure actions
                if(json_ActionsOnFailure != null && json_ActionsOnFailure != ''){
                    List<CustomData> customDataList = (List<CustomData>)JSON.deserialize(json_ActionsOnFailure, List<CustomData>.class);
                    for(CustomData actionData: customDataList){
                        String fieldName = actionData.fieldName;
                        if(actionData.data_source == 'value'){

                            if(actionData.value == null || actionData.value == ''){

                                String objectName = 'Case';
                                SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                                DescribeSObjectResult d = r.getDescribe();
                                if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                                    caseObj.put(FieldName,false);
                                    continue;
                                }
                                caseObj.put(FieldName,null);
                            }
                            caseObj.put(FieldName,actionData.value);
                        } else if(actionData.data_source == 'response_data'){

                        }
                    } 
                }
        
            }
            else{
                System.debug(' API Getting Success Status Code from API');
                caseObj.Last_Api_Call_Status__c = 'Success';

                // Handle On Success actions
                if(json_ActionsOnSuccess != null && json_ActionsOnSuccess != ''){
                    List<CustomData> customDataList = (List<CustomData>)JSON.deserialize(json_ActionsOnSuccess, List<CustomData>.class);
                    for(CustomData actionData: customDataList){
                        String fieldName = actionData.fieldName;
                        if(actionData.data_source == 'value'){

                            if(actionData.value == null || actionData.value == ''){

                                String objectName = 'Case';
                                SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                                DescribeSObjectResult d = r.getDescribe();
                                if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                                    caseObj.put(FieldName,false);
                                    
                                } else{
                                    caseObj.put(FieldName,null);
                                }
                                
                            }else{
                                caseObj.put(FieldName,actionData.value);
                            }
                            
                        } else if(actionData.data_source == 'response_data'){

                        }
                    } 
                }

            }
        }
        
        if(cases != null && cases.size()>0){
            update cases;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }

    }





    public class RequestDetails {

        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;

        @InvocableVariable(label='path' description='example: /credit-cards' required=true)
        public String Path;

        @InvocableVariable(label='method' description='GET, PUT, POST, ...' required=true)
        public String method;

        @InvocableVariable(label='json_header' description='json contains header parameters')
        public String json_header;
        
        @InvocableVariable(label='json_body' description='body text in json format')
        public String json_body;

        @InvocableVariable(label='json_ActionsOnSuccess' description='actions on response success')
        public String json_ActionsOnSuccess;
        
        @InvocableVariable(label='json_ActionsOnFailure' description='actions on API callout failure')
        public String json_ActionsOnFailure;

    }


    public class CustomData {
        public String fieldName { get; set; }
        public String data_source { get; set; }
        public String value { get; set; }
        public String dataPath { get; set; }
    }

}