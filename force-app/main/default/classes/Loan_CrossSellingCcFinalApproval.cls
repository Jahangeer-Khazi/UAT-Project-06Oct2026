/**
* @author Aniss Mbarki
* @date Création 30/09/2024
* @date Modification
* @description : 
*/
public without sharing class Loan_CrossSellingCcFinalApproval {
    
    private static String CLASS_NAME = Loan_CrossSellingCcFinalApproval.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    

    @InvocableMethod(label='call Update Loan Cross Selling CC Request Status API' description='call Update Loan Cross Selling CC Request Status API' callout=true )
    public static List<String> updateCrossSellingCCReqApiFromFlow(List<RequestLoanCrossSelling> reqCrossSellingCase)
    {   
        system.debug('reqCrossSellingCase debug ==> '+reqCrossSellingCase);
        RequestLoanCrossSelling reqCrossSellingRecord = reqCrossSellingCase.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('changedField',reqCrossSellingRecord.changedField);
        
        try{
            
            updateCreditCardCrossReqApiFutureMeth(new Set<Id>{reqCrossSellingRecord.caseId},details);
            
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: reqCrossSellingRecord.caseId];
            caseObj.Last_Api_Call_Status__c = 'Failed';
            update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.updateCrossSellingCCReqApiFromFlow()', caseObj.Type
                                                 );
        }
        
        List<String> strLst = new List<String>();
        for(RequestLoanCrossSelling qst : reqCrossSellingCase){
            strLst.add(qst.caseId);
        }
        return strLst;
    }

    @future(callout=true)
    public static void updateCreditCardCrossReqApiFutureMeth(Set<Id> caseIds , Map<String,String> details){
        
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c,Account.PersonEmail,Account.CIF__pc,Account.x_canary__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        
        String changedField = details.get('changedField');
        List<CaseAnnex__c> cxList = new List<CaseAnnex__c>();
        Boolean isUpdateCase = false;
        for(Case caseObj : cases){
            try {
                
                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }
                
                HttpRequest request = con.createRequest('POST', '/api/v1/credit-cards/cross?',regionName);
                request.setTimeout(60000);
                HttpResponse response;
                if ( test.isRunningTest() ) {
                    //fake response 
                    response = new HttpResponse();
                    String body = '{"meta":{"code":"CCRD-12345","message":"your card application is captured successfully"},"data":{"caseId":"AJ987df344","holdRefrence":"8778679"}}';
                    response.setStatus('OK');    
                    response.setStatusCode(200);
                    response.setBody(body);
                    response.setHeader('Content-Type', 'application/json');
                }

                if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_PreScreening_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_CrossSelling_PreScreening_Datetime__c = System.now()
                                );
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                else if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_Evaluator_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_Cross_Selling_Evaluator_Datetime__c = System.now()
                                );
                    
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                else if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_Verifier_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_Cross_Selling_Verifier_Date_Time__c = System.now()
                                );
                    
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                else if( changedField != null && changedField.equalsIgnoreCase('cx_ln_Cross_Selling_Approver_Result__c') ){
                    CaseAnnex__c cx = new CaseAnnex__c(
                                    Id=caseObj.CaseAnnex__c,
                                    cx_ln_Cross_Selling_Approver_Date_Time__c = System.now()
                                );
                    
                    if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c == 'Decline' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'DECLINED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    else if( caseObj.CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c == 'Cancelled' ){
                        response = updateCrossSellingCaseStatusApi(request,caseObj,'CANCELLED');
                        caseObj.cc_Approved_Credit_Limit__c = 0;
                        cx.cx_ln_Approved_Credit_Limit__c = 0;
                        isUpdateCase = true;
                    }
                    cxList.add(cx);
                }
                //cc_Signature_Verifier_Result__c ==> accept
                else if( changedField != null && changedField.equalsIgnoreCase('cc_Signature_Verifier_Result__c') ){
                    if( !test.isRunningTest() ){
                        if( caseObj.cc_Signature_Verifier_Result__c == 'Accept' ){
                            response = updateCrossSellingCaseStatusApi(request,caseObj,'APPROVED');
                        }
                    }
                }
                //Store Both Success/Error Response 
                if(response != null && response.getStatusCode() != null){
                    lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                    request.getEndpoint(),request.getMethod(),
                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                    caseObj.Type+' Request cross selling Status API', caseObj.Type
                                ));
                }
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                         caseObj.Type+' updateCreditCardCrossReqApiFutureMeth (unhandled error)', caseObj.Type
                                                        ));
            }
            
        }
        
        if(cxList != null && cxList.size()>0){
            update cxList;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(isUpdateCase == true && cases != null && cases.size()>0){
            update cases;
        }
    }

    public static HttpResponse updateCrossSellingCaseStatusApi(HttpRequest request,Case objCase,String updatedStatus){
        PAD.debugLogBegin(CLASS_NAME, 'updateCrossSellingCaseStatusApi','Parameters : [objCase] : '+ objCase);
        system.debug('debug API status : '+updatedStatus);
        if(objCase.Customer_CIF__c != null){
            request.setHeader('customerId', objCase.Customer_CIF__c);
        }
        
        Map<String, String> requestObject = new Map<String, String>{
            'cardProductConfigurationId' => objCase.PrimaryCardProductConfigurationId__c,
            'crmCaseId' => objCase.Id,
            'status' => updatedStatus,
            'nameOnTheCard' => objCase.cc_Name_on_the_Card__c, //toDo : check if this the right mapping or we need add logic for approved value if it's not empty
            'creditLimit' => String.valueOf(objCase.cc_Requested_Credit_Limit__c), //toDo : check if this the right mapping or we need add logic for approved value if it's not empty
            'targetType' => 'CREDIT_CARD_ORDER_CROSS_SELL'
        };
       
        request.setBody( JSON.serialize(requestObject) );

        
        System.debug('********************* updateCrossSellingCaseStatusApi request.getEndpoint() **********************');
        System.debug(request.getEndpoint());
        
        System.debug('********************* updateCrossSellingCaseStatusApi request.getBody() **********************');
        System.debug(request.getBody());
        
        HttpResponse response = EM001_ApiCalls.updateCreditCardRequestStatusApi(request,200);

        PAD.debugLogEnd(CLASS_NAME, 'updateCrossSellingCaseStatusApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        
        return response;
    }

    public class RequestLoanCrossSelling {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='changedField' description='changedField apiName')
        public String changedField;
    }
    
}