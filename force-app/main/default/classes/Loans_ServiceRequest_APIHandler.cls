/*     
*      Change History: 
*      #CH01# #Aitogram omar# #14-04-2026#  added logic to call already existing  method creditCardCustomerProfileUpdate.updateCustomerdetails
*      #CH02# #Aniss Mbarki# #27-07-2026#  change 11 in NBA-17380
 
*/

public without sharing class Loans_ServiceRequest_APIHandler {

    private static String CLASS_NAME = Loans_ServiceRequest_APIHandler.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    private static List<CaseComment> lstComment = new List<CaseComment>();
    private static Map<Case,String> mapEmailPerCase = new Map<Case,String>();
    private static List<Case> emailtoOwnerCases = new List<Case>();

    private static CaseAnnex__c tempCaseAnnexRecord;

    @InvocableMethod(label='Loan Service Request API Handler' description='Loan Service Request API Handler' callout=true )
    public static List<String> serviceRequestHandlerFromFlow(List<LoanWrapper> Loans){
        
        system.debug('Loans debug ==> '+Loans);
        LoanWrapper Loan = Loans.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('isNew',Loan.isNew);
        details.put('objectSource',Loan.objectSource);
        details.put('changedField',Loan.changedField);
        system.debug('debug call serviceRequestHandlerFromFlow');
        
        try{
            
            system.debug('debug call serviceRequestHandlerFutureMeth 1');
            serviceRequestHandlerFutureMeth(new Set<Id>{loan.caseId},details);
            
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: Loan.caseId];
            // caseObj.Last_Api_Call_Status__c = 'Failed';
            //update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.serviceRequestHandlerFromFlow()', caseObj.Type);
        }
        
        List<String> strLst = new List<String>();
        for(LoanWrapper qst : Loans){
            strLst.add(qst.caseId);
        }
        return strLst;
    } 
    
    // @AuraEnabled
    // public static Map<String, Object> generateRepaymentScheduleApiHandler (Case caseRecord ,CaseAnnex__c caseAnnexRecord)
    // {   
    //     Map<String, Object> result = new Map<String, Object>();
    //     try {

    //         //no need to create logs for this api , 
    //         //.. if yes, please handle the creation on this class to avoid the error : "Error Message : You have uncommitted work pending. Please commit or rollback before calling out .."
    //         HttpResponse simulationResp = Lwc03_FinancialDetailsController.callSimulationApi(caseRecord,caseAnnexRecord,false);

    //         if (simulationResp.getStatusCode() != 200)
    //         {
    //             System.debug('The status code returned was not expected: ' + simulationResp.getStatusCode() + ' ' + simulationResp.getStatus());
    //             result.put('status', 'Error');
    //             result.put('message', 'Error occurred while processing: ' + simulationResp.getStatusCode() + ' ' + simulationResp.getStatus());
    //         }
    //         else
    //         {
    //             System.debug('bcrbp api simulationResp.getBody() : ' + simulationResp.getBody());
    //             result.put('status', 'Success');
    //             result.put('response', simulationResp.getBody());
    //             Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(simulationResp.getBody());
    //             Map<String, Object> scheduleResp = (Map<String, Object>)m1.get('data');
    //             caseAnnexRecord.cx_ln_SimulationReference__c = (String)scheduleResp.get('simulationReference');
    //         }
    //     } catch (Exception e) {
    //         result.put('status', 'Error');
    //         result.put('message', 'Error occurred while processing: ' + e.getMessage());
    //         System.debug(e.getMessage());
    //         System.debug(e.getStackTraceString());
    //     }

    //     return result;
    // }
    
    //@future(callout=true)
    public static void serviceRequestHandlerFutureMeth(Set<Id> caseIds , Map<String,String> details){
        system.debug('debug call serviceRequestHandlerFutureMeth began');
        List<Case> cases = new List<Case>();
        List<CaseAnnex__c> CaseAnnexs = new List<CaseAnnex__c>();
        
        String isNew = details.get('isNew');
        String objectSource = details.get('objectSource');
        String changedField = details.get('changedField');
        system.debug('debug isNew :'+isNew);
        system.debug('debug changedField :'+changedField);
        system.debug('debug caseIds :'+caseIds);
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        Case caseObj = cases[0];
        system.debug('debug caseObj :'+caseObj);
        String caseAnnexId = caseObj.CaseAnnex__c;
        String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');   
        String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Id =:caseAnnexId';
        CaseAnnexs = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(caseAnnexsoqlQuery));
        CaseAnnex__c caseAnnexRecord = CaseAnnexs[0];

        try {
            
            if(isNew != null && isNew.equalsIgnoreCase('yes') ){ // Handle Creation 
                

            }
            else if (isNew != null && isNew.equalsIgnoreCase('no')) {// Handle Update
                
                switch on changedField {
                    when 'isSubmitted__c'{
                        //I commented this part and I move it to HandOffProcessController.submitForm() , because we should not wait for the response and refresh the page to get the result 
                            //so on the controller we will call the api on submit and get results synchronously
                    }
                    when else {
                        // Start Handling metadata
                        CC_Application_Status_Mapping__mdt apiStatusMappingRecord = getApiStatusBasedOnCaseChanges(caseObj, caseAnnexRecord, objectSource ,changedField);
                        
                        if(apiStatusMappingRecord != null){
                            system.debug('debugging return metadata record : '+apiStatusMappingRecord.MasterLabel);
                        }

                        if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == false){
                            system.debug('debug not calling API:');
                            caseObj.Last_Api_Call_Status__c = 'Success';
                            caseObj = LoanServiceRequestProcessFields(caseObj, caseAnnexRecord, changedField,apiStatusMappingRecord);
                            caseAnnexRecord = tempCaseAnnexRecord;
                            
                        }else {
                            // No meteadata record was found
                            system.debug('debug No meteadata record found'+caseObj.CaseNumber);
                            
                            lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +'No meteadata record found'+caseObj.CaseNumber,
                                                                     null,null,
                                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                                     caseObj.Type+' updateLoanApiFutureMeth (No CC_Application_Status_Mapping__mdt meteadata record found for this changed field: '+changedField+')', caseObj.Type
                                                                    ));
                            caseObj.Last_Api_Call_Status__c = 'Failed';
                            if (objectSource == 'CaseAnnex__c') {
                                caseAnnexRecord.put( changedField , null );
                            } else {
                                if( changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c') ){
                                    caseObj.put( changedField , null ); 
                                }
                            }            
                        }

                        caseObj.Loan_case_Annex_changed_field__c = null;
                        caseObj.Loan_case_Annex_changed_field_new_value__c = null;
                        caseObj.Loan_case_Annex_changed_field_old_value__c = null;


                        // End Handling metadata
                    }
                }
                
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                        null,null,
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                        caseObj.Type+'serviceRequestHandlerFutureMeth (unhandled error)', caseObj.Type
                                                    ));
                    
        }

        if(cases != null && cases.size()>0){
            system.debug('Debug Update Case:');
            update caseObj;
        }

        if(CaseAnnexs != null && CaseAnnexs.size()>0){
            system.debug('Debug Update Case Annex:');
            update caseAnnexRecord;
        }
        // CH01 Start
        if (caseObj != null && caseObj.AccountId != null && (caseObj.cc_Credit_Approval_Result__c == 'Approve'  || caseObj.cc_Credit_Approval_Result__c == 'Decline') &&
            (caseObj.Sub_Type__c == 'Top-up' || caseObj.Sub_Type__c == 'Restructuring' || caseObj.Sub_Type__c == 'Partial Settlement')) {
            creditCardCustomerProfileUpdate.updateCustomerdetails(new Map<Id, Id>{caseObj.Id => caseObj.AccountId});
        }
        // CH01 end 

        if(lstSA != null && lstSA.size()>0 && !Test.isRunningTest()){
            
            insert lstSA;
        }
        
        if(lstComment != null && lstComment.size()>0){
            insert lstComment;
        }
        
        /*system.debug('mapEmailPerCase '+mapEmailPerCase);
        // Handle Email Alerts
        for( Case cs : mapEmailPerCase.keySet() ){
            
            Flow.Interview loansNotificationsFlow = Flow.Interview.createInterview('Loans_Notifications_Flow', 
                                                     new Map<String, Object>{
                                                         'newCase' => cs,
                                                         'NotificationTime' => 'immediate'
                                                     });

            loansNotificationsFlow.start();

        }*/

        system.debug('emailtoOwnerCases '+emailtoOwnerCases);
        // Handle Email Alerts for internal emails to oner
        for( Case cs : emailtoOwnerCases ){
            
            Flow.Interview loansNotificationsFlow1 = Flow.Interview.createInterview('Loans_Notifications_Flow', 
                                                    new Map<String, Object>{
                                                        'newCase' => cs,
                                                        'varT_EmailDeveloperName' => 'Email_Notification_General'
                                                    });

            loansNotificationsFlow1.start();
        }
        
        
        
    }

    //////////////////////////////////
    public static Case LoanServiceRequestProcessFields( Case caseObj,CaseAnnex__C caseAnnexRecord, String changedField ,CC_Application_Status_Mapping__mdt apiStatusMappingRecord){
        
        String regionName = caseObj.Region_Flag__c; 
        
        caseObj.Awaiting_Customer_Feedback__c = apiStatusMappingRecord.Awaiting_Customer_Feedback__c;
        if(apiStatusMappingRecord.Sub_Status__c != null ){
            caseObj.Sub_Status__c = apiStatusMappingRecord.Sub_Status__c;
            caseObj.LastCaseSubStatusChanged__c = System.now();
                        
        }      
        if(apiStatusMappingRecord.Status__c != null ){

            caseObj.Status = apiStatusMappingRecord.Status__c;
            caseAnnexRecord.cx_ln_Last_Status_Changed_Date_Time__c = System.now(); 
        }   
        
        
        if(apiStatusMappingRecord.queueDeveloperName__c != null ){
            caseObj.OwnerId = getQueueIdBasedOnQueueDevName(apiStatusMappingRecord.queueDeveloperName__c);
            //Aniss start #CH02
            if(apiStatusMappingRecord.queueDeveloperName__c == 'Loan_Finance_Operations_Processing_Queue'){
                caseObj.Owner_Change_Date__c = System.now();
            }
            //Aniss End #CH02
            emailtoOwnerCases.add(caseObj);
        }
        if(apiStatusMappingRecord.cc_Application_Stages__c != null ){
            caseObj.cc_Application_Stages__c = apiStatusMappingRecord.cc_Application_Stages__c;
        }
        if(apiStatusMappingRecord.isApiCall__c == true){
            caseObj.Last_Api_Call_Status__c = 'Success';
        }
        if(apiStatusMappingRecord.crmStage__c != null){
            caseObj.cc_CRM_Stage__c = apiStatusMappingRecord.crmStage__c;
        }
        /*if(apiStatusMappingRecord.emailAlertName__c != null && apiStatusMappingRecord.emailAlertName__c != ''){
            mapEmailPerCase.put(caseObj,apiStatusMappingRecord.emailAlertName__c);
        }*/
        
        if( apiStatusMappingRecord.sectionResultFields__c != null ){
            List<string> fieldList = apiStatusMappingRecord.sectionResultFields__c.split(';');
            String commentResult;

            List<string> fieldList0 = fieldList.get(0).split('\\.');
            system.debug('fieldList0 : ' +fieldList0);
            if(fieldList0.size() > 1){
                if(fieldList0.get(0) == 'CaseAnnex__c'){
                    caseAnnexRecord.put(fieldList0.get(1),System.now());
                } else {
                    caseObj.put(fieldList0.get(0),System.now());
                    
                }
            }else {
                caseObj.put(fieldList.get(0),System.now());
                
            }

            if(fieldList.size() > 1){
                List<string> fieldList1 = fieldList.get(1).split('\\.');
                if(fieldList1.size() > 1){
                    if(fieldList1.get(0) == 'CaseAnnex__c'){
                        caseAnnexRecord.put(fieldList1.get(1),UserInfo.getUserId());
                    } else {
                        caseObj.put(fieldList1.get(0),UserInfo.getUserId());
                        
                    }
                } else {
                    caseObj.put(fieldList.get(1),UserInfo.getUserId());
                    
                }
            }
            

            if(fieldList.size() > 2){
                List<string> fieldList2 = fieldList.get(2).split('\\.');
                if(fieldList2.size() > 1){
                    if(fieldList2.get(0) == 'CaseAnnex__c'){
                        commentResult = (String)caseAnnexRecord.get(fieldList2.get(1));
                    } else {
                        commentResult = (String)caseObj.get(fieldList2.get(1));
                    }
                } else {
                    commentResult = (String)caseObj.get(fieldList.get(2));
                }

                if( commentResult != null ){
                    CaseComment resultComm = new CaseComment( ParentID=caseObj.id, CommentBody= fieldList.get(3) + ' - '+ commentResult );
                    lstComment.add(resultComm);
    
                    if(fieldList2.size() > 1){
                        if(fieldList2.get(0) == 'CaseAnnex__c'){
                            caseAnnexRecord.put(fieldList2.get(1),null);
                        } else {
                            caseObj.put(fieldList2.get(1),null);
                        }
                    } else {
                        caseObj.put(fieldList.get(2),null);
                    }
                    
                }
            }

        }

        if( apiStatusMappingRecord.fieldsToBeReseted__c != null ){
            
            for(String Field: apiStatusMappingRecord.fieldsToBeReseted__c.split(';')){
                String fieldName;
                String objectName;

                List<string> ListField = Field.split('\\.');
                if(ListField.size() > 1 && ListField.get(0) == 'CaseAnnex__c'){
                    
                    objectName = 'CaseAnnex__c';
                    fieldName = ListField.get(1);
                    SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                    DescribeSObjectResult d = r.getDescribe();
                    if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                        caseObj.put(FieldName,false);
                        continue;
                    }
                    system.debug('caseAnnexRecord.put(FieldName,null);');
                    caseAnnexRecord.put(FieldName,null);

                } else {
                    objectName = 'Case';
                    fieldName = Field;
                    SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                    DescribeSObjectResult d = r.getDescribe();
                    if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                        caseObj.put(FieldName,false);
                        continue;
                    }
                    caseObj.put(FieldName,null);
                }
                
                
            }
        }
        //omar start - thi is added for UATNB-200965  we might add it for the other subtypes for loanServiceRequest
        if(caseObj.Sub_Type__c == 'Partial Settlement' && caseObj.cc_Customer_Authenticated_Flag__c == true && changedField == 'cc_Service_Centre_Result__c'){
            caseAnnexRecord.cx_ln_CustomerAuthenticated_Datetime__c = System.now();
        }
        //omar -end
        tempCaseAnnexRecord = caseAnnexRecord;

        return caseObj;
    }

    /////////////////////////////////////
    public static CC_Application_Status_Mapping__mdt getApiStatusBasedOnCaseChanges( Case caseObj, CaseAnnex__C CaseAnnexRecord, String ObjectSource, String changedField ){
        
        String fieldValue ;
        if(ObjectSource == 'CaseAnnex__c'){
            fieldValue = String.valueOf(CaseAnnexRecord.get(changedField));
        }else{
            fieldValue = String.valueOf(caseObj.get(changedField));
        }
        system.debug('Metada caseObj.Type '+caseObj.Type);
        system.debug('Metada caseObj.Region_Flag__c '+caseObj.Region_Flag__c);
        system.debug('Metada changedField '+changedField);
        system.debug('Metada fieldValue '+fieldValue);
        system.debug('Metada caseObj.RecordType_DeveloperName__c '+caseObj.RecordType_DeveloperName__c);

        List<CC_Application_Status_Mapping__mdt> mappingMetadataList = [SELECT id,Label, fieldAPiName__c, Value__c, apiStatus__c,Awaiting_Customer_Feedback__c,Sub_Status__c,
                                                                        queueDeveloperName__c,isApiCall__c,crmStage__c,emailAlertName__c,cc_Application_Stages__c,regionName__c,Status__c,
                                                                        Type__c, criteria__c,MasterLabel,isDocuSign__c,sectionResultFields__c, fieldsToBeReseted__c, Object__c
                                                                        FROM CC_Application_Status_Mapping__mdt 
                                                                        WHERE Type__c = :caseObj.Type AND sub_Type__c = :caseObj.sub_Type__c AND regionName__c = :caseObj.Region_Flag__c AND fieldAPiName__c = :changedField 
                                                                        AND Value__c = :fieldValue AND RecordType_DeveloperName__c =:caseObj.RecordType_DeveloperName__c];
        
        CC_Application_Status_Mapping__mdt defaultMetadataRec = null;
        system.debug('debugging Metadata List:' +mappingMetadataList);
        
        for(CC_Application_Status_Mapping__mdt metadataRec : mappingMetadataList) {
            if(metadataRec.criteria__c == null){
                defaultMetadataRec = metadataRec;
                continue;
            }
            if(evaluateCriteria(ObjectSource, caseObj, CaseAnnexRecord, metadataRec.criteria__c)){
                return metadataRec;
            }
            
        }                                           
        return defaultMetadataRec;
    }

    ///////////////////////////////////////
    public static Boolean evaluateCriteria(String ObjectSource, Case caseObj, CaseAnnex__c CaseAnnexRecord, String criteriaField ){
        Boolean result = true;
        for(String criteria:criteriaField.split('&&')){
            
            List<string> opList = criteria.split(';');
            
            String caseField = opList[0];
            String operator = opList[1];
            String value = opList[2];
            String fieldValue;
            if(caseField.contains('.')){
                String[] caseFieldList = caseField.split('\\.');
                if(caseFieldList.get(0) == 'CaseAnnex__c'){
                    fieldValue = String.valueOf(CaseAnnexRecord.get(caseFieldList.get(1)));
                } else { 
                    fieldValue = String.valueOf(caseObj.get(caseFieldList.get(1)));
                }
                
            } else {
                fieldValue = String.valueOf(caseObj.get(caseField));
            }

            if(operator == '=='){
                result = result && (fieldValue == value);
            } else if(operator == '!='){
                result = result && (fieldValue != value);
            }
        }
        return result;
    }

    //////////////////////////////////
    public static Id getQueueIdBasedOnQueueDevName(String queueName ) {
        List<Group> queueIds = [SELECT Id, Name, DeveloperName from Group where type = 'queue' and DeveloperName =: queueName];
        
        if(queueIds != null && queueIds.size()>0 ){
            System.debug('Debug queue Ids: '+queueIds);
            return queueIds[0].Id;
        }
        return null;
    }

    ///////////////////////////////////////
    public class LoanWrapper {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        
        @InvocableVariable(label='objectSource' description='Object apiName')
        public String objectSource;

        @InvocableVariable(label='changedField' description='changedField apiName')
        public String changedField;
    }
}