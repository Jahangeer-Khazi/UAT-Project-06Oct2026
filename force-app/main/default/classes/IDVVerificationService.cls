/**
* @author Jayanth Manickam
* @date 02/12/2024
*/


public class IDVVerificationService {
    
    @AuraEnabled(cacheable=true)
    public static List<verificationDetails> getVerificationHistory(String recordId){
        List<verificationDetails>vfresult= New List<verificationDetails>();
        List<verificationDetails>fvfresult= New List<verificationDetails>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Account>acnt = [Select Id, CIF__pc,Region_flag__pc,Subscription_Model__pc From Account where Id=:recordId];
        String Subscription_Model = acnt[0].Subscription_Model__pc;
        System.debug(Subscription_Model);
        String regionName= acnt[0].Region_flag__pc;
        if(Subscription_Model=='alburaq'){
            regionName += '_alburaq';
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        ApiConnection con = new ApiConnection();
        request = con.createRequest('GET','/api/v1/id-and-verification/history',regionName);
        request.setHeader('customerId',acnt[0].CIF__pc);
        HttpResponse response = http.send(request); 
        if (response.getStatusCode() != 200) 
        {   
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //  lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
            
        } else {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            List<String>crmcaseIDs =New List<String>();
            List<Object>verificationList = (List<Object>)m.get('data');
            System.debug('m1######'+JSON.serializePretty(verificationList));  
            for(Object vefDetails : verificationList){
                Map<String,Object> vfDetail = (Map<String, Object>)vefDetails;
                //System.debug('##mapInstConfig'+JSON.serializePretty(verificationDetails.get('allowActions')));
                if(vfDetail.get('crmCaseId')!=null){
                    crmcaseIDs.add(String.valueOf(vfDetail.get('crmCaseId')));
                }
                vfresult.add( new verificationDetails(
                    String.valueOf(vfDetail.get('unit')) , 
                    String.valueOf(vfDetail.get('activity')) , 
                    String.valueOf(vfDetail.get('numberOfRetries')),
                    String.valueOf(vfDetail.get('status')),
                    String.valueOf(vfDetail.get('crmCaseId')),
                    String.valueOf(vfDetail.get('createdDate')),
                    String.valueOf(vfDetail.get('lastUpdatedDate')),
                    String.valueOf(vfDetail.get('method'))
                ));
            }
            Map<String,String>CaseNum = New Map<String,String>();
            if(!crmcaseIDs.isEmpty()){
                
                for(Case cs:[Select Id, caseNumber from case where ID IN:crmcaseIDs]){
                    CaseNum.put(cs.Id,cs.caseNumber);
                }
            }
            
            for(verificationDetails vcsDetail:vfresult){
                fvfresult.add( new verificationDetails(
                    String.valueOf(vcsDetail.vfid) , 
                    String.valueOf(vcsDetail.activity), 
                    String.valueOf(vcsDetail.numberOfRetries),
                    String.valueOf(vcsDetail.status),
                    CaseNum.get(String.valueOf(vcsDetail.crmCaseId)),
                    String.valueOf(vcsDetail.createdDate),
                    String.valueOf(vcsDetail.lastUpdatedDate),
                    String.valueOf(vcsDetail.authMethod)
                ));
                
            }
        }
        return fvfresult;
    }
    
    // Get available balance from the account
    @InvocableMethod(label='update IDV Verfication Status' description='The purpose of this service is to update ID&v verification status' callout=true )
    public static List<String> idvVerificationStatus(List<String> caseId){
        List<String> ConfirmedFraud= New List<String>(); 
        List<String> CancelRequest= New List<String>();
        List<String> SkippedRequest = New List<String>();  
        List<String> customerContacted = New List<String>(); 
        List<String>DeclLoanCaseId = New List<String>();
        List<String>PndLoanCaseId = New List<String>();
        List<String>UrevLoanCaseId = New List<String>();
        if(!caseId.isEmpty()){
            for(Case caseObj: [SELECT Id,ParentId,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,Account.x_canary__pc,OwnerId,Fraud_Results__c,cc_Contact_Centre_Result__c,Sub_Type__c FROM Case WHERE Id IN:caseId]){
                System.debug(System.Label.Frauds_Queue);
                System.debug(caseObj.OwnerId);
                if(caseObj.OwnerId==System.Label.Frauds_Queue && caseObj.Fraud_Results__c=='Confirm Fraud'){
                    ConfirmedFraud.add(caseObj.Id);
                    if(caseObj.Sub_Type__c=='Personal Loan / Finance'){
                        DeclLoanCaseId.add(caseObj.Id);
                    }
                }else if(caseObj.OwnerId==System.Label.Frauds_Queue && (caseObj.Fraud_Results__c=='Cancel Request' || caseObj.Fraud_Results__c=='Genuine Request – Expired CPR')){
                    CancelRequest.add(caseObj.Id);
                    if(caseObj.Sub_Type__c=='Personal Loan / Finance'){
                        PndLoanCaseId.add(caseObj.Id);
                    }
                }else if (caseObj.OwnerId==System.Label.Frauds_Queue && caseObj.Fraud_Results__c=='Skip ID&V Next Login'){
                    SkippedRequest.add(caseObj.Id);
                    if(caseObj.Sub_Type__c=='Personal Loan / Finance'){
                        UrevLoanCaseId.add(caseObj.Id);
                    }
                }else if (caseObj.OwnerId==System.Label.Contact_Center_Internal && caseObj.cc_Contact_Centre_Result__c=='Customer Contacted'){
                    customerContacted.add(caseObj.Id);
                    if(caseObj.Sub_Type__c=='Personal Loan / Finance'){
                        PndLoanCaseId.add(caseObj.Id);
                    }
                }
            }
            if(!DeclLoanCaseId.isEmpty()){
                UpdateLoanFinanceApplicationStatus(DeclLoanCaseId,'Closed','Declined ID&V Fraud',ConfirmedFraud,'Fraud','Fraud',true);
            }else if(DeclLoanCaseId.isEmpty() && !ConfirmedFraud.isEmpty()){
                UpdateLoanFinanceApplicationStatus(DeclLoanCaseId,'Closed','Declined ID&V Fraud',ConfirmedFraud,'Fraud','Fraud',false);
            }
            if(!PndLoanCaseId.isEmpty()){
                if(!CancelRequest.isEmpty()){
                    UpdateLoanFinanceApplicationStatus(PndLoanCaseId,'Pending','Pending ID&V',CancelRequest,'Closed','Canceled',true);
                }
                if(!customerContacted.isEmpty()){
                    UpdateLoanFinanceApplicationStatus(PndLoanCaseId,'Pending','Pending ID&V',customerContacted,'Closed','Completed',true); 
                }
            }else if(PndLoanCaseId.isEmpty() && (!customerContacted.isEmpty() ||!CancelRequest.isEmpty() )){
                if(!CancelRequest.isEmpty()){
                    UpdateLoanFinanceApplicationStatus(PndLoanCaseId,'Pending','Pending ID&V',CancelRequest,'Closed','Canceled',false);
                }
                if(!customerContacted.isEmpty()){
                    UpdateLoanFinanceApplicationStatus(PndLoanCaseId,'Pending','Pending ID&V',customerContacted,'Closed','Completed',false); 
                }
            }
            if(!UrevLoanCaseId.isEmpty()){
                UpdateLoanFinanceApplicationStatus(UrevLoanCaseId,'Pending','Pending Signature In-App',SkippedRequest,'CONSUMED','Skipped',true);
            }else if(UrevLoanCaseId.isEmpty() && !SkippedRequest.isEmpty()){
                UpdateLoanFinanceApplicationStatus(UrevLoanCaseId,'Pending','Pending Signature In-App',SkippedRequest,'Skipped','Skipped',false); 
            }      
        }
        return null;
    }
    
    
  
    @future(callout=true)
    public static void  UpdateLoanFinanceApplicationStatus(List<String> caseId,String Lnstatus,String LnsubStatus,List<String> subcaseId,String subIdvstatus,String subStatus,Boolean isLoan) {
        List<Case> cases = new List<Case>();
         List<Case> casesToUpdateList=new List<Case>();
        List<System_Action__c> lst = new List<System_Action__c>();
        String CaseModel;
        if(isLoan){
            if(!caseId.isEmpty()){
                cases= [SELECT Id,account.CIF__pc,ParentId,ContactId,Case_Model__c,Region_Flag__c,accountId,Account.x_canary__pc,Account.Region_Flag__pc,Customer_CIF__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c FROM Case WHERE Id IN:caseId];
                for(Case caseObj:cases){
                    CaseModel = caseObj.Case_Model__c;
                    String regionName = caseObj.Region_Flag__c;
                    if(caseModel == 'alburaq'){
                        regionName += '_alburaq';
                    }
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    ApiConnection con = new ApiConnection();
                    request = con.createRequest('PUT','/api/v1/loans/application',regionName);
                    request.setBody('{"crmCaseId": "'+caseObj.ParentId+'","status":"'+Lnstatus+'","subStatus":"'+LnsubStatus+'"}');
                    request.setHeader('customerId',caseObj.Customer_CIF__c);
                     System.debug('Body###'+request.getBody());
                    if(caseObj!= null){
                        System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                        if(caseObj.Account.x_canary__pc != null){
                            request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                        }
                    }
                    request.setTimeout(120000);
                    HttpResponse response = http.send(request);            
                    if (response.getStatusCode() != 200) 
                    {   
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                                       request.getEndpoint() ,request.getMethod(),
                                                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                       'LoanFinanceApplicationIDVstatus', 'LoanFinanceApplicationIDVstatus'
                                                                                      );
                        lst.add(actionRecord);
                        //  lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'IDVVerificationService', 'IDVVerificationService');
                        
                        
                    } else {
                        case cs = New case();
                        cs.Id=caseObj.ParentId;
                        cs.Sub_Status__c=LnsubStatus;
                        cs.Status=Lnstatus;
                        casesToUpdateList.add(cs);
                        UpdateIDVStatus(subcaseId,subIdvstatus,subStatus);
                    }
                }
            }
        }else{
            
            UpdateIDVStatus(subcaseId,subIdvstatus,subStatus);
        }
        
        if(lst != null && lst.size()>0){
            insert lst;
        }
        if(casesToUpdateList != null && casesToUpdateList.size()>0){
            update casesToUpdateList;
        }
    }
    
    //To update IDV status

    public static void  UpdateIDVStatus(List<String> caseId,String Idvstatus, String subStatus) {
        Boolean isFraud;
        String statusCode;
        String CaseModel;
        Boolean updateIDVStatus=False;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<Case> cases = new List<Case>();
        List<String> bcaseId = new List<String>();
        List<System_Action__c> lst = new List<System_Action__c>();
        List<Account>accntlst = New List<Account>();
        if(!caseId.isEmpty()){
            cases= [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,Account.x_canary__pc,Account.Region_Flag__pc,Customer_CIF__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c FROM Case WHERE Id IN:caseId];
            if(Idvstatus=='Fraud'){
                for(Case caseObj : cases){
                    String regionName = caseObj.Account.Region_Flag__pc;
                    if(caseObj.case_Model__c == 'alburaq'){
                        regionName += '_alburaq';
                    }
                    //toDo : use api uncomment this part
                    ApiConnection con = new ApiConnection();
                    HttpRequest request = con.createRequest('PUT','/api/v1/accounts/block-unblock',regionName);
                    System.debug('Request'+request);
                    if(caseObj!= null){
                        System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                        if(caseObj.Account.x_canary__pc != null){
                            request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                        }
                    }
                    request.setHeader('customerId', caseObj.Customer_CIF__c);
                    String types ='DEBIT' ;
                    String updatedStatus='BLOCK';
                    String body =  '{"action":'+stringApiFormat(updatedStatus)+',"type": '+stringApiFormat(types)+',"allAccounts":true}';
                    request.setBody(body);
                    System.debug(request.getBody());
                    
                    HttpResponse response = EM001_ApiCalls.blockUnblockAccountApi(request,200);
                    
                    
                    System.debug('Body###'+response.getBody());
                    Map<String, Object> deserialized = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String, Object>  validatecode = (Map<String, Object>) deserialized.get('meta');
                    system.debug('deserialized'+deserialized);
                    system.debug('m3'+validatecode.get('code'));
                    if (response.getStatusCode() != 200) {
                        
                        System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                                       request.getEndpoint() ,request.getMethod(),
                                                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                       'Block/Unblock Accounts API', updatedStatus
                                                                                      );
                        lst.add(actionRecord);
                        updateIDVStatus=False;
                    }
                    
                    else{
                        Account acc= New Account();
                        acc.Id=caseObj.accountId;
                        acc.Blacklisted__c=true;
                        acc.Is_Fraud__c=true;
                        accntlst.add(acc);
                        if(lst.isEmpty()){
                            updateIDVStatus=True; 
                            isFraud=True;
                            statusCode='BRANCH_REJECTED';
                        }
                        
                    }
                    
                }
            }else{
                updateIDVStatus=True;
                isFraud=False;
                if(Idvstatus=='Skipped'){
                    statusCode='SKIPPED';
                }else if(Idvstatus=='CONSUMED'){
                     statusCode='CONSUMED';
                }else{
                    statusCode='VERIFICATION_RETRY';
                }
                
            }
            
            if(updateIDVStatus){
                for(Case caseObj:cases){
                    CaseModel = caseObj.Case_Model__c;
                    String regionName = caseObj.Region_Flag__c;
                    if(caseModel == 'alburaq'){
                        regionName += '_alburaq';
                    }
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    ApiConnection con = new ApiConnection();
                    // request = con.createRequest('GET','/api/v1/bond/investments?customerId='+caseObj.Customer_CIF__c,regionName);
                    request = con.createRequest('PUT','/api/v1/id-and-verification/status',regionName);
                    request.setBody('{"caseId": "'+caseObj.Id+'","isFraudCase":"'+isFraud+'","statusCode":"'+statusCode+'"}');
                    request.setHeader('customerId',caseObj.Customer_CIF__c);
                    
                    if(caseObj!= null){
                        System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                        if(caseObj.Account.x_canary__pc != null){
                            request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                        }
                    }
                    request.setTimeout(120000);
                    HttpResponse response = http.send(request);            
                    if (response.getStatusCode() != 200) 
                    {   
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                                       request.getEndpoint() ,request.getMethod(),
                                                                                       caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                                       'IDVVerificationService', 'IDVVerificationService'
                                                                                      );
                        lst.add(actionRecord);
                        //  lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'IDVVerificationService', 'IDVVerificationService');
                        
                        
                    } else {
                        if(subStatus=='Fraud'){
                            bcaseId.add(caseObj.Id);
                            caseObj.Sub_Status__c='Fraud';
                            caseObj.status='Closed';
                            caseObj.Fraud_Results_Date_Time__c=System.Now();
                            casesToUpdateList.add(caseObj);
                            AppRestrictionCustomerController.UpdateAppRestrictionIDV(bcaseId,TRUE,'BLACKLISTED');
                        }    
                        if(subStatus=='Completed'){
                            caseObj.Sub_Status__c='Completed';
                            caseObj.status='Closed';
                            caseObj.cc_Contact_Centre_Date_Time__c=System.Now();
                            casesToUpdateList.add(caseObj);
                        } 
                        if(subStatus=='Canceled'){
                            caseObj.Sub_Status__c='Cancelled';
                            caseObj.Fraud_Results_Date_Time__c=System.Now();
                            caseObj.status='Closed';
                            casesToUpdateList.add(caseObj);
                        } 
                        if(subStatus=='Skipped'){
                            caseObj.Sub_Status__c='Skipped';
                            caseObj.Fraud_Results_Date_Time__c=System.Now();
                            caseObj.status='Closed';
                            casesToUpdateList.add(caseObj);
                        }  
                    }
                    
                }
            }
            //   if(lst == null)   {
            if(casesToUpdateList != null && casesToUpdateList.size()>0){
                update casesToUpdateList;
                
            }
            if(accntlst != null && casesToUpdateList.size()>0){
                update accntlst;
                
            }
            //     }
            
            if(lst != null && lst.size()>0){
                insert lst;
            }  
            
        }
    }
    public class verificationDetails {
        @AuraEnabled 
        public String vfid {get; set;}       
        @AuraEnabled 
        public String activity {get; set;} 
        @AuraEnabled 
        public String numberOfRetries {get; set;} 
        @AuraEnabled 
        public String status {get; set;} 
        @AuraEnabled 
        public String crmCaseId {get; set;} 
        @AuraEnabled 
        public String createdDate {get; set;} 
        @AuraEnabled 
        public String lastUpdatedDate {get; set;} 
        @AuraEnabled 
        public String authMethod {get; set;} 
        public verificationDetails (String vfid,String activity, String numberOfRetries,string status, string crmCaseId, string createdDate, string lastUpdatedDate, string authMethod){
            this.vfid=(vfid =='alburaq'?'alburaq':'ila');
            this.activity=activity;
            this.numberOfRetries=numberOfRetries;
            Switch on status{
                when 'IN_PROGRESS' {
                    this.status='Pending';
                }when 'REQUIRE_BRANCH_VERIFICATION' {
                    this.status='Case';
                }when 'FAILED'{
                    this.status='Fail';
                }when 'BRANCH_REJECTED'{
                    this.status='Fraud';
                }when 'SUCCESS'{
                    this.status='Success';
                }when 'VERIFICATION_RETRY'{
                    this.status='Closed';
                }when else{
                    this.status=status;
                }
            }
            //this.status=status;
            this.crmCaseId=crmCaseId;
            this.createdDate=createdDate;
            this.lastUpdatedDate=lastUpdatedDate;
            this.authMethod=authMethod;
        }
    }
    //To update IDV status
    
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //  action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
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
    public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
}