/**
* @author Jayanth Manickam
* @date Création 08/01/2024
* @date Modification
* @description :Batch Class to process the BID Allocation and generate a bid allocation report
* @history Modifications :   
*  
*/


global class QB01GenerateBIDAllocationReport implements Queueable, Database.AllowsCallouts{
    
    global boolean runInTestMode = false; 
    global string ISINCode;
    global String ISINType;
    global String InstrumentID;
    global String triggerType;
    global String caseModel;
    global Boolean isMinimumBid = false;
    global  Map<String,Integer>MinimumInvstMentID= New Map<String,Integer>();
    global Map<String,List<sObject>>failedAPICall = New Map<String,List<sObject>>();
    global Map<String,List<Draw_System_Action__c>>SystemLog = New Map<String,List<Draw_System_Action__c>>();
    global List<String>csvHeaders = New List<String>{'ISIN Type','ISIN Code','Issue No','Issue Amount','Invitation Date','Tender Date','Issue Date','Currency','Maturity Date','Investor Name','Investor ID Type','Investor ID Number','Unit','IBAN','Bid Amount'};
    global List<String> csvFieldAPINames= New List<String>{'bs_ISIN_Type__c','bs_ISIN_Code__c','bs_Issue_No__c','bs_Issue_Amount__c','bs_Invitation_Date__c','bs_Tender_Date__c','bs_Issue_Date__c','Currency__c','bs_Maturity_Date__c','cc_Full_Name__c','ID_Type__c','cc_ID_Number__c','Case_Model__c','ccol_Hold_Account_IBAN__c','bs_Bid_Amount__c','cc_Nationality__c','Account.Passport_Number__pc'};
    global Integer totalNoOfRecords =0; 
    global Decimal Total_Bid_Amount =0;
    global List<sObject>buyRequest =  New List<sObject>();
    global Map<String,List<sObject>>buyRequests =  New Map<String,List<sObject>>();
    global Map<String,Decimal>bidAllocations =  New Map<String,Decimal>();
    global List<Case>cs= New List<Case>();
    global Map<String,Integer>InstTotalBidInst= New Map<String,Integer>();
    global String htmlBody='';
    global Bid_Allocation__c ba;
    global QB01GenerateBIDAllocationReport(boolean runInTestMode,string InstrumentID,string triggerType) {
        this.runInTestMode = runInTestMode;
        this.InstrumentID=InstrumentID;
        this.triggerType=triggerType;
        List<Bid_Allocation__c>ExistBid = [Select Id,ISIN_Code__c From Bid_Allocation__c Where Instrument_Id__c=:InstrumentID ];
        if(!ExistBid.isEmpty()){
            ba =ExistBid[0];
        }else{
           ba = New Bid_Allocation__c();
           ba.Instrument_ID__c=InstrumentID;
           insert ba;  
        }
           
    }
    public void execute(QueueableContext context) {
	    StaticResource srBegin= [select id,body from StaticResource Where Name = 'BidEmailTemplateBeginning'];
        StaticResource srEnd= [select id,body from StaticResource Where Name = 'BidEmailTemplateEnd'];
		OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
        List<String> InvestmentIds = New List<String>();
        Map<String,Integer>ProcessInvstMentID= New Map<String,Integer>();
        Map<String,String>InstrumentDetails= New Map<String,String>();
        List<String>CancelInvstMentID= New List<String>();
        String endpoint;
        Integer MinimumBond=0;
        Integer TotalBidSum=0;
        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/bond/configurations','Bahrain');
        request.setHeader('filterByParameter','BANK_MINIMUM_BID_AMOUNT_BONDS');
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        if (response.getStatusCode() != 200) 
        {   
            SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',response.getStatusCode(), 'Bid Allocation Process - Configuration API', 'Failed',String.valueOf(ba.Id)));
        }else{                
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> configurations = (List<Object>)m1.get('configurations'); 
            System.debug('configurations######'+JSON.serializePretty(configurations));
            for(Object config : configurations){
                Map<String,Object> mapbankConfig = (Map<String, Object>)config;
                If(String.valueOf(mapbankConfig.get('param'))=='BANK_MINIMUM_BID_AMOUNT_BONDS'){
                    MinimumBond= Integer.valueOf(mapbankConfig.get('value'));
                }
                
            }
        }
        List<System_Action__c> lst = new List<System_Action__c>();
        TotalBidSum=0;
        request = con.createRequest('GET','/api/v1/bond/instrument/investments?instrumentId='+InstrumentID,'Bahrain');
        response = http.send(request);
        if (response.getStatusCode() != 200) 
        {   
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',response.getStatusCode(), 'Bid Allocation Process -Investments', 'Failed',String.valueOf(ba.Id)));
            //  lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
        }else{            
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> InvestmentList = (List<Object>)m1.get('investments'); 
            System.debug('InstrumentList######'+JSON.serializePretty(InvestmentList));
            for(Object InvstDetails : InvestmentList){
                Map<String,Object> mapInstConfig = (Map<String, Object>)InvstDetails;
                Map<String,Object>instrumentDetail=(Map<String,Object>)mapInstConfig.get('instrument');
                ISINType=String.valueOf(instrumentDetail.get('isInTypeCBB'));
                ISINCode=String.valueOf(instrumentDetail.get('isInCodeCBB')) ;
                InvestmentIds.add(String.valueOf(mapInstConfig.get('id')));
                If((mapInstConfig.get('status'))=='In-Progress' || (mapInstConfig.get('status'))=='Processing'){ 
                    ProcessInvstMentID.put(String.valueOf(mapInstConfig.get('id')),Integer.valueOf(mapInstConfig.get('bidAmount')));
                    TotalBidSum = TotalBidSum+Integer.valueOf(mapInstConfig.get('bidAmount'));
                    InstTotalBidInst.put(InstrumentID,TotalBidSum);
                    InstrumentDetails.put(InstrumentID,ISINCode);
                }
                If((mapInstConfig.get('status'))=='Cancelled'){
                    CancelInvstMentID.add(String.valueOf(mapInstConfig.get('id')));
                }
            }

        }
        System.debug('##TotalBidSum##'+TotalBidSum);
        System.debug('##MinimumBond##'+MinimumBond);
        System.debug('###InvestmentIds##'+InvestmentIds.size());
        for(String Cd:InstTotalBidInst.keySet()){
            if(InstTotalBidInst.get(Cd) >=MinimumBond){
                try { 

                   
                                        //  HttpRequrequest = new HttpRequest();
                    request = con.createRequest('POST','/api/v1/bond/investments/allocation','Bahrain');
                    request.setBody('{"instrumentId": "'+cd+'","isinCode":"'+InstrumentDetails.get(Cd)+'","stage":"processing","crmCase":"'+ba.Id+'"}');
                    System.debug('request==>'+Request.getEndpoint());
                    response = http.send(request);
                    System.debug('request##==>'+request.getBody());
                    System.debug('response##==>'+JSON.serializePretty(response.getBody()));
                    if (response.getStatusCode() != 200 ) {
                         SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',response.getStatusCode(), 'Bid Allocation Process - Processing Stage', 'Failed',String.valueOf(ba.Id)));
                        ba.Last_Api_Call_Status__c='Failed-Stage1';
                    }else {
                        ba.Last_Api_Call_Status__c='Processing-Stage1';
                    }
                    ba.ISIN_Code__c=ISINCode;
                    ba.Instrument_ID__c=InstrumentID;
                    ba.ISIN_Type__c=ISINType;
                    ba.Number_of_BIDS__c=ProcessInvstMentID.keySet().size();
                    ba.Number_of_Failed_BIDS__c=0;
                    ba.Total_Bid_Amount__c=InstTotalBidInst.get(InstrumentID);
                    ba.Trigger_Type__c=triggerType;                    
                    ba.Status__c='Pending Bid Allocation Announcement';
                    ba.OwnerId=System.Label.Ila_Ops_Maker;
                    update ba;
                }
                catch (Exception e) {                      
                    System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
                }
              }
            else{
			 isMinimumBid=True;
			}
          }
			if(isMinimumBid){
                set<String>ByBank= New set<String>();
                List<case>byCustomer =New List<Case>();
                ByBank.addAll(InstTotalBidInst.keySet());
                System.debug('inside ByBank'+ByBank);
                
                MinimumInvstMentID.putAll(ProcessInvstMentID);
                for(case cs:[Select Id,Customer_CIF__c,accountId,Last_Api_Call_Status__c,Sub_Status__c,bs_Bid_Amount__c,bs_ISIN_Code__c,bs_Instrument_Id__c,bs_Investment_ID__c from case where bs_Investment_ID__c IN:InvestmentIds]){
                    if(CancelInvstMentID.Contains(cs.bs_Investment_ID__c)){
                        cs.Last_Api_Call_Status__c='Success';
                        cs.Sub_Status__c='Cancelled';
                        cs.Operation_Result__c='Canceled';
                        cs.Status='Closed';
                        cs.Closure_Reason__c='Cancelled by Customer';
                        byCustomer.add(cs);
                    }                   
                }
                if(!ByBank.isEmpty()){
                    List<System_Action__c> lstSA = new List<System_Action__c>();
                    Map<String,List<Case>>caseAcc = New Map<String,List<Case>>();
                    List<Case> casesToUpdateList=new List<Case>();
                    For(Case caseObj:[SELECT Id,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,ID_Type__c,cc_ID_Number__c,bs_Bid_Amount__c,account.CIF__pc,Case_Model__c,Customer_CIF__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Issue_No__c,bs_Investment_ID__c,bs_Instrument_Id__c FROM Case WHERE bs_Instrument_Id__c IN:ByBank AND Sub_status__c IN ('Processing','In-Progress')]){
                        if(caseAcc.containsKey(caseObj.bs_Instrument_Id__c)){
                            List<Case>cslist= caseAcc.get(caseObj.bs_Instrument_Id__c);
                            cslist.add(caseObj);
                            caseAcc.put(caseObj.bs_Instrument_Id__c,cslist);
                        }else{
                            caseAcc.put(caseObj.bs_Instrument_Id__c,New List<Case>{caseObj});
                        }
                    }
                    
                    for(String instCode:caseAcc.keySet()){
                        
                        String regionName = 'Bahrain';
                        request = con.createRequest('DELETE','/api/v1/bond/instrument/'+instCode,regionName);
                        response = http.send(request);
                        System.debug(request.getEndpoint());    
                        System.debug(request.getMethod());
                        System.debug(request.getBody());
                        if (response.getStatusCode() != 200) {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());      
                            for(Case cs:caseAcc.get(instCode)){
                                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'DELETE',cs.id,cs.Customer_CIF__c,cs.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                                cs.Last_Api_Call_Status__c='Failed';
                                casesToUpdateList.add(cs);
                            }
                        }else {   
                            for(Case cs:caseAcc.get(instCode)){
                                cs.Last_Api_Call_Status__c='Success';
                                cs.sub_status__c='Cancelled';
                                cs.Status='Closed';
                                cs.Closure_Reason__c='Cancelled by Bank Due to Bank Minimum Amount';
                                casesToUpdateList.add(cs);
                            }
                                String Title = ISINCode + ' : ' + ISINType +'-'+System.Today();
                                String ContentcsvId= GenerateCSVFile.createCSV(csvHeaders,csvFieldAPINames,caseAcc.get(instCode),Title);
                                Bid_Allocation__c ba = New Bid_Allocation__c();
                                System.debug('ISINCode##'+ISINCode);
                                ba.ISIN_Code__c=ISINCode;
                                ba.Instrument_ID__c=instCode;
                                ba.ISIN_Type__c=ISINType;
                                ba.Number_of_BIDS__c=caseAcc.get(instCode).size();
                                ba.Number_of_Failed_BIDS__c=0;
                                ba.Total_Bid_Amount__c=InstTotalBidInst.get(instCode);
                                ba.Trigger_Type__c=triggerType;
                                ba.Last_Api_Call_Status__c='Success';
                                ba.Status__c='Closed';
                                ba.OwnerId=System.Label.Ila_Ops_Maker;
                                upsert ba Bid_Allocation__c.ISIN_Code__c;
                                ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
                                ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=ba.Id);
                                insert cdl;  
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                
                                if ( owea.size() > 0 ) {
                                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                String[] toaddr = new String[]{System.Label.Treasury_Ops_Email_Address}; 
                                    String[] ccaddr = new string[]{System.Label.ila_Ops_Email_Address};
                                        email.setSubject('Buy Request -' + ISINCode + ' - ' + ISINType);
                               
                                String bodyContent=srBegin.body.toString()+'Minimum Bank Bid Amount Not Reached - Bids Placed Canceled'+srEnd.body.toString();
                                email.setHtmlBody(bodyContent);
                                email.setToAddresses(toaddr); 
                                email.setCcAddresses(ccaddr);
                                List<id> ContentDocumentIds = new List<id>();
                                ContentDocumentIds.add(cvs.Id);
                                email.setEntityAttachments(ContentDocumentIds);  
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                            }
                            // ReleaseHoldAccountBalance(ByBank,'Cancelled by Bank Due to Bank Minimum Amount');
                        }
                    
                     if(!casesToUpdateList.isEmpty()){
                        update casesToUpdateList;
                        
                    }
                    }
                    if(!byCustomer.isEmpty()){
                        update byCustomer;
                    }

                }
        if(!SystemLog.isEmpty()){
            insert SystemLog.get(ISINCode);
        }
        }
        
        
        
        global static List<Draw_System_Action__c> createBondSystemAction(final String reqBody, final String resBody, final String path, Final String method,  Final Integer statCode,Final String strType, Final String strAction, Final String BidallocId) {
            List<Draw_System_Action__c> lstSA = new List<Draw_System_Action__c>();
            Draw_System_Action__c action = new Draw_System_Action__c();
            action.Buy_Out_Request__c=BidallocId;
            action.Action_Type__c = strAction;
            action.Endpoint__c = path;
            action.Method__c = method;
            action.HTTP_Response_Code__c = statCode;
            action.Title__c=strType;
            action.Request_Body__c = reqBody;
            action.Response_Body__c = resBody;
            action.RecordTypeId=SObjectType.Draw_System_Action__c.getRecordTypeInfosByDeveloperName().get('Bonds_Sukuk').getRecordTypeId();
            lstSA.add(action);
            
            return lstSA;
            
        }
        
        global static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
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