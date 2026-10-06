public without sharing class DocuSignGetEnvelopeId {

    private static String CLASS_NAME = DocuSignGetEnvelopeId.class.getName();
    private static ApiConnection con = new ApiConnection();
    
    @InvocableMethod(label='docuSign Get EnvelopeId' description='docuSign Get EnvelopeId' callout=true )
    public static List<String> docuSignGetEnvelopeIdFromFlow(List<reqWrapper> reqObjs){
        reqWrapper reqObj = reqObjs.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('isNew',reqObj.isNew);
        details.put('objectSource',reqObj.objectSource);
        details.put('changedField',reqObj.changedField);
        details.put('cif',reqObj.cif);
        details.put('channel',reqObj.channel);
        details.put('caseModel',reqObj.caseModel);
        details.put('isSTP_Process',reqObj.isSTP_Process);
        system.debug('debug call updateLoanUpdateApiFromFlow');

        //call future method
        docuSignGetEnvelopeFuture(reqObj.caseId,details);

        List<String> strLst = new List<String>();
        for(reqWrapper qst : reqObjs){
            strLst.add(qst.caseId);
        }
        return strLst;
    } 

    // called in creation and update
    @future(callout=true)
    public static void docuSignGetEnvelopeFuture(Id caseId , Map<String,String> details){
        String cif = details.get('cif');
        String channel = details.get('channel');
        String caseModel = details.get('caseModel');
        String isNew = details.get('isNew');
        String objectSource = details.get('objectSource');
        String changedField = details.get('changedField');
        String isSTP_Process = details.get('isSTP_Process');

        system.debug('debug isNew :'+isNew);
        system.debug('debug changedField :'+changedField);
        system.debug('debug caseId :'+caseId);
        system.debug('debug isSTP_Process :'+isSTP_Process);
        
        try{
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c,Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case WHERE Id = :caseId';
            List<Case> cases = new List<Case>((List<Case>)Database.query(soqlQuery));
            Case caseObj = cases[0];
            system.debug('debug caseObj :'+caseObj);
            String caseAnnexId = caseObj.CaseAnnex__c;
            String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');   
            String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Id =:caseAnnexId';
            List<CaseAnnex__c> CaseAnnexs = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(caseAnnexsoqlQuery));
            CaseAnnex__c caseAnnexRecord = CaseAnnexs[0];
            
            if(isSTP_Process == 'true'){
                HttpRequest request = Lwc03_FinancialDetailsController.prepareSimulationRequest(caseObj,caseAnnexRecord);
                HttpResponse simulationResp = Lwc03_FinancialDetailsController.callSimulationApi(caseObj,caseAnnexRecord,request,false);
                
                //store system log all the time
                insert SM001_ApiCalls.setSystemAction( request.getBody(),simulationResp.getBody(),
                                                                        request.getEndpoint(),request.getMethod(),
                                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,simulationResp.getStatusCode(), 
                                                                        'call simulation schedule API (STP Process before calling docusign)', caseObj.Type
                                                                        );

                if (simulationResp.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + simulationResp.getStatusCode() + ' ' + simulationResp.getStatus());
                    caseObj.cc_Control_Type__c = null;
                    update caseObj;
                }
                else
                {
                    System.debug('bcrbp api simulationResp.getBody() : ' + simulationResp.getBody());
                    Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(simulationResp.getBody());
                    Map<String, Object> scheduleResp = (Map<String, Object>)m1.get('data');
                    caseAnnexRecord.cx_ln_SimulationReference__c = (String)scheduleResp.get('simulationReference');
                    update caseAnnexRecord;
                    //wait for someTime then call docusign to generate the envelopeId
                    Integer nbrMinutes = Integer.valueof(System.Label.Loan_WaitingTimeAfterSimulation);
                    String hour = String.valueOf(Datetime.now().hour());
                    String min = String.valueOf(Datetime.now().addMinutes(nbrMinutes).minute());
                    String ss = String.valueOf(Datetime.now().second());
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    details.put('isSTP_Process','false'); //to avoid calling the same bloc after scheduler works 
                    ScheduleDocSignJob docJob = new ScheduleDocSignJob(caseId, details);
                    System.debug('call ScheduleDocSignJob --> ');
                    System.schedule('Docu Sign JOB RUNNING '+system.now(),nextFireTime,docJob);
                }
                
            }else{
                //Always create system log    
                List<System_Action__c> lstSA = new List<System_Action__c>();

                Loan_DocuSignEnvelopeReqWrapper requestWrapper = new Loan_DocuSignEnvelopeReqWrapper();
                requestWrapper.cif = cif;
                requestWrapper.caseId = caseId;
                requestWrapper.channel = channel;
                requestWrapper.caseModel = caseModel;
                Loan_DocuSignEnvelopeResponseWrapper resp = Loans_ServiceManagerHandler.createDocuSignEnvelope(requestWrapper);
                system.debug('resp check ==> '+resp);
                system.debug('resp.envelopeId ==> '+resp.envelopeId);
                
                details.put('envelopeId',resp.envelopeId);
                details.put('contactId',resp.contactId);
        
                //store system log all the time
                lstSA.add(SM001_ApiCalls.setSystemAction( 'Docusign Api called','envelopeId ==> '+resp.envelopeId,
                                                          null,null,
                                                          caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                          'Docusign Api called after field is changing : '+changedField, caseObj.Type
                                                         ));
                insert lstSA;
                
                if(resp.envelopeId != null){
                    // call loan update process in queable method !!
                    System.enqueueJob(new UpdateLoanStatusProcessJob(caseId, details));
                }
            }
           
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: caseId];
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.docuSignGetEnvelopeIdFromFlow()', caseObj.Type
                                                 );
        }

    }

    public class reqWrapper {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        @InvocableVariable(label='CIF' description='the CIF' required=true)
        public String cif;
        @InvocableVariable(label='channel' description='channel' required=true)
        public String channel;
        @InvocableVariable(label='Case Model' description='Case Model' required=true)
        public String caseModel;
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        @InvocableVariable(label='objectSource' description='Object apiName')
        public String objectSource;
        @InvocableVariable(label='changedField' description='changedField apiName')
        public String changedField;
        @InvocableVariable(label='isSTP_Process' description='is STP Process?')
        public String isSTP_Process;
    }

    // Inner class to update
    public class UpdateLoanStatusProcessJob implements Queueable {
        private Id caseId;
        private Map<String,String> details;

        public UpdateLoanStatusProcessJob(Id caseId, Map<String,String> details) {
            this.caseId = caseId;
            this.details = details;
        }

        public void execute(QueueableContext qc) {
            System.debug('execute Queueable method UpdateLoanStatusProcessJob -- to update case after to avoid error : Future method cannot be called from a future or batch method:');
            Loans_APIHandler.updateLoanApiFutureMeth(new Set<Id>{this.caseId},this.details);
        }
    }
}