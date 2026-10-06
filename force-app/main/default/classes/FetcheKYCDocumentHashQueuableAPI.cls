/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 27-11-2022
*       Change History: 
*					  #CH01# #Jahangeer Mohammed# #04-04-2023# Added a new field eKYC_IDandV_Document_Uploaded_Date__pc which captures the current date
*        
*/
public class FetcheKYCDocumentHashQueuableAPI implements Queueable, Database.AllowsCallouts {
    private static ApiConnection con = new ApiConnection();
    set<Id> caseId;
    public static String fakeBody;
    public FetcheKYCDocumentHashQueuableAPI(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account> accToUpdate = new List<Account>();
        List<Case> caseToUpdate = new List<Case>();
        List<Case> lstCase = [Select Id,Status,Sub_Status__c,AccountId,Customer_CIF__c,Region_Flag__c,Account.PersonEmail,Account.CIF__pc,Account.eKYC_IDandV_Document_Upload_Hash__pc
                              from Case where Id IN : caseId];
        if(lstCase.size()>0){
            Set<String> setofErrorCaseId = new Set<String>();
            try{
            for(Case objCase : lstCase){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                HttpResponse response;
                String body = '';
                if(System.Label.PERIODIC_REVIEW_ISACTUAL_RESPONSE.equalsIgnoreCase('true')){
                     request = con.createRequest('POST', '/api/v1/government-data/wathiq/person/documents?', objCase.Region_Flag__c);
                     //body = '{"s3Path":"","mockURL":null}';
                     //body = '{"s3Path":"","mockURL":"https://run.mocky.io/v3/42ed2783-2026-484b-9aed-2dc03d41a6f6"}';
                    //body = '{"s3Path":"","mockURL":"https://run.mocky.io/v3/6daedd4a-e15b-4d89-b268-67d0b8784497"}';
                    //body = '{"s3Path":"","mockURL":"https://run.mocky.io/v3/89854fd3-5aa2-42db-becf-2674fe7a5087"}';
                     //body = '{"s3Path":"","mockURL":"https://run.mocky.io/v3/48079ce4-3835-48b3-9921-bc7c2519dbaa"}';
                    body = '{"s3Path":"","mockURL":"https://run.mocky.io/v3/984253e0-9020-4ccd-9d70-20947f9da4eb"}';
                     request.setBody(body); 
                     request.setHeader('userId', objCase.Account.PersonEmail);
                     request.setHeader('customerId', objCase.Account.CIF__pc);
                     request.setTimeout(70000);
                     system.debug('---> request body --> '+request.getBody());
                     response = http.send(request);
                }
                if(System.Label.PERIODIC_REVIEW_ISDUMMY_RESPONSE.equalsIgnoreCase('true')){
                     response = new HttpResponse();
                     body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"messageStatus":"string","errorCode":"string","responseDescription":"string","timestamp":"string","cipherMessageId":"string","documentName":"string","documentType":"string","documentHash":"DummyTestHashValue","documentWathiqPath":"string","documentWathiqDownloadPath":"string","documentS3Path":"string","crmSyncResult":true}}';
                     if(test.isRunningTest()){
                        body = fakeBody;
                    }
                    response.setStatus('OK');
                    response.setStatusCode(200);
                    response.setBody(body);
                    response.setHeader('Content-Type', 'application/json');
                }
             
                if(response.getStatusCode() != 200){
                    System.debug('Invalid Status Code from API');
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/government-data/wathiq/person/documents?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Periodic Review', 'Periodic Review');
                }
                else{
                    System.debug('Response Body:'+response.getBody());
                    Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                    Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                    String docHashValue = (String)mapJSONData.get('documentHash');
                    System.debug('Doc Hash Value:'+docHashValue);
                    Account a = new Account();
                    a.Id = objCase.AccountId;
                    a.pr_ReviewStatus__c = 'In-Progress';
                    a.eKYC_IDandV_Document_Upload_Hash__pc = docHashValue;
                    //CH01: Start
                    a.eKYC_IDandV_Document_Uploaded_Date__pc = System.now();
                    //CH01: END
                    accToUpdate.add(a);
                    objCase.Sub_Status__c = 'In-Progress';
                    objCase.Status = 'In Progress';
                    //objCase.Account.eKYC_IDandV_Document_Upload_Hash__pc = docHashValue;
                    caseToUpdate.add(objCase);
                }
            } //for loop Ends
            }catch(Exception Ex){
                String compName = 'FetcheKYCDocumentHashQueuableAPI';
                String compType = 'Apex Class';
                for(Case c: lstCase){
                  setofErrorCaseId.add(c.Id); 
                }
                String failureRecordReference = String.join(new List<String>(setofErrorCaseId), ',');
                String ObjectType = 'Case';
                String errorMessage = ex.getMessage()  + ex.getStackTraceString();
                PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
            }
        } //if loop Ends
        Set<String> setErrCaseIds = new Set<String>();
        Set<String> setofSuccessFullCaseIds = new Set<String>();
        Set<String> setofErrorCaseIds = new Set<String>();
        Set<String> setOfErrormessage = new Set<String>();
        try{
            if(caseToUpdate.size()>0){
                Database.SaveResult[] SResult = Database.update(caseToUpdate,false);
                for(Integer i=0; i<SResult.size(); i++){
                    if(SResult[i].isSuccess()){
                        setofSuccessFullCaseIds.add(caseToUpdate.get(i).Id);
                    }
                    else if(!SResult[i].isSuccess()){
                        setofErrorCaseIds.add(caseToUpdate.get(i).Id);
                        for(Database.Error err : SResult[i].getErrors()){
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
                if(!setofSuccessFullCaseIds.isEmpty()){
                    String compName = 'FetcheKYCDocumentHashQueuableAPI';
                    String compType = 'Apex Class';
                    String successRecordReference = String.join(new List<String>(setofSuccessFullCaseIds), ',');
                    String ObjectType = 'Case';
                    //Boolean b = true;
                    String caseCategory = 'IDandV Document Hash Updated';
                    PeriodicReviewBatchTrackerLogs.successCaselogWithCategory(compName, compType, successRecordReference,ObjectType,caseCategory);
                    
                }
                if(!setofErrorCaseIds.isEmpty()){
                    String compName = 'FetcheKYCDocumentHashQueuableAPI';
                    String compType = 'Apex Class';
                    String failureRecordReference = String.join(new List<String>(setofErrorCaseIds), ',');
                    String ObjectType = 'Case';
                    String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                    PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
                    
                }
              
                //update caseToUpdate;
            }
            if(accToUpdate.size()>0){
                if(!test.isRunningTest()){
                	update accToUpdate;
                }
                if(test.isRunningTest())
                    throw new MyCustomException('Bad Code');
            }
        }catch(Exception ex){
            String compName = 'FetcheKYCDocumentHashQueuableAPI';
            String compType = 'Apex Class';
            for(case c : caseToUpdate){
                setErrCaseIds.add(c.Id);
            }
            String failureRecordReference = String.join(new List<String>(setErrCaseIds), ',');
            String ObjectType = 'Case';
            String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            PeriodicReviewBatchTrackerLogs.errorCaselog(compName, compType, failureRecordReference,errorMessage,ObjectType);
            
            //System.debug('Exception Message in Periodic Handler API:'+e.getMessage());
        }    
         if(lstSA.size()>0){
            insert lstSA;
        }
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        action.Case__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        lstSA.add(action);
        
        return lstSA;
        
    }
   
}