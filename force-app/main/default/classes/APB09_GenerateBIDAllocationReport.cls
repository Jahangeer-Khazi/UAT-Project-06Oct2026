/**
* @author Jayanth Manickam
* @date Création 08/01/2024
* @date Modification
* @description :Batch Class to process the BID Allocation and generate a bid allocation report
* @history Modifications :   
*  
*/

global class APB09_GenerateBIDAllocationReport implements Database.batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    global boolean runInTestMode = false; 
    global string ISINCode;
    global String ISINType;
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
    global APB09_GenerateBIDAllocationReport(boolean runInTestMode,string ISINCode,string ISINType,string triggerType) {
        this.runInTestMode = runInTestMode;
        this.ISINCode=ISINCode;
        this.ISINType=ISINType;
        this.triggerType=triggerType;
    }
    global APB09_GenerateBIDAllocationReport(boolean runInTestMode,string ISINCode,string triggerType) {
        this.runInTestMode = runInTestMode;
        this.ISINCode=ISINCode;
        this.triggerType=triggerType;
    }
    global APB09_GenerateBIDAllocationReport(boolean runInTestMode,string triggerType) {
        this.runInTestMode = runInTestMode;
        this.triggerType=triggerType;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString;
        //  if(triggerType=='Manual'){
        system.debug('ISINCode'+ISINCode);
        queryString= 'Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c From Case Where bs_ISIN_Code__c=:ISINCode  AND Sub_Status__c IN (\'In-Progress\',\'Processing\') AND Type=\'New Bond/Sukuk Buy Request\'';
        //  }else{
        //     queryString= 'Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c From Case Where bs_Bid_Due_Date__c=TODAY AND Sub_Status__c IN (\'In-Progress\',\'Processing\') AND Type=\'New Bond/Sukuk Buy Request\'';
        //    }
        
        if (!runInTestMode) {
            // System.debug('##queryString##'+queryString);
            return Database.getQueryLocator(queryString+'Limit 1');
        } else {
            return Database.getQueryLocator(queryString + ' Limit 10');			
        }
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
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
            SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',response.getStatusCode(), 'Bid Allocation Process - Configuration API', 'Failed'));
            // System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
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
        buyRequest.addAll(scope);
        
        for(case cs:(List<Case>)scope){
            if(buyRequests.containsKey(cs.bs_Instrument_Id__c)){
                List<Sobject>brequest = buyRequests.get(cs.bs_Instrument_Id__c);
                brequest.add(cs);
                buyRequests.put(cs.bs_Instrument_Id__c,brequest);
            }else{
                buyRequests.put(cs.bs_Instrument_Id__c,New List<sObject>{cs});
            }
            
        }
        List<System_Action__c> lst = new List<System_Action__c>();
        totalNoOfRecords +=scope.size();
        for(String code:buyRequests.keyset()){
            TotalBidSum=0;
            request = con.createRequest('GET','/api/v1/bond/instrument/investments?instrumentId='+code,'Bahrain');
            response = http.send(request);
            if (response.getStatusCode() != 200) 
            {   
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',response.getStatusCode(), 'Bid Allocation Process -Investments', 'Failed'));
                //  lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
            }else{
                
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                // Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                // System.debug('M1######'+m1);
                //Map<String, Object> m2 = (Map<String, Object>)m1.get('customerAccount');
                List<Object> InvestmentList = (List<Object>)m1.get('investments'); 
                System.debug('InstrumentList######'+JSON.serializePretty(InvestmentList));
                for(Object InvstDetails : InvestmentList){
                    Map<String,Object> mapInstConfig = (Map<String, Object>)InvstDetails;
                    Map<String,Object>instrumentDetail=(Map<String,Object>)mapInstConfig.get('instrument');
                    ISINType=String.valueOf(instrumentDetail.get('isInTypeCBB'));
                    ISINCode=String.valueOf(instrumentDetail.get('isInCodeCBB')) ;
                    System.debug('##investmentId##'+String.valueOf(mapInstConfig.get('id')));
                    InvestmentIds.add(String.valueOf(mapInstConfig.get('id')));
                    If((mapInstConfig.get('status'))=='In-Progress' || (mapInstConfig.get('status'))=='Processing'){ 
                        ProcessInvstMentID.put(String.valueOf(mapInstConfig.get('id')),Integer.valueOf(mapInstConfig.get('bidAmount')));
                        System.debug('##TotalBidSum##'+TotalBidSum);
                        TotalBidSum = TotalBidSum+Integer.valueOf(mapInstConfig.get('bidAmount'));
                        InstTotalBidInst.put(code,TotalBidSum);
                        InstrumentDetails.put(code,ISINCode);
                    }
                    If((mapInstConfig.get('status'))=='Cancelled'){
                        CancelInvstMentID.add(String.valueOf(mapInstConfig.get('id')));
                    }
                }
            }
        }
        System.debug('##TotalBidSum##'+TotalBidSum);
        System.debug('##MinimumBond##'+MinimumBond);
        System.debug('###InvestmentIds##'+InvestmentIds.size());
        for(String Cd:InstTotalBidInst.keySet()){
            if(InstTotalBidInst.get(Cd) >=MinimumBond){
                // For(Case BRCase:[Select Id,Customer_CIF__c,accountId,Last_Api_Call_Status__c,Sub_Status__c,bs_Bid_Amount__c,bs_ISIN_Code__c,bs_Instrument_Id__c,bs_Investment_ID__c from case where bs_Investment_ID__c IN:InvestmentIds]){
                //  if(!BRCase.isEmpty()){
                try { 
                    //  HttpRequrequest = new HttpRequest();
                    request = con.createRequest('POST','/api/v1/bond/investments/allocation','Bahrain');
                    //System.debug('BRCase[0].bs_ISIN_Code__c##'+BRCase.bs_ISIN_Code__c);
                    // System.debug('BRCase[0]'+BRCase);
                    request.setBody('{"instrumentId": "'+cd+'","isinCode":"'+InstrumentDetails.get(Cd)+'","stage":"processing"}');
                    System.debug('request==>'+Request.getEndpoint());
                    response = http.send(request);
                    System.debug('request##==>'+request.getBody());
                    System.debug('response##==>'+JSON.serializePretty(response.getBody()));
                    if (response.getStatusCode() != 200 ) {
                        SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',response.getStatusCode(), 'Bid Allocation Process -Allocaton', 'Failed'));
                        For(Case BRCase:[Select Id,Customer_CIF__c,accountId,Last_Api_Call_Status__c,Sub_Status__c,bs_Bid_Amount__c,bs_ISIN_Code__c,bs_Instrument_Id__c,bs_Investment_ID__c from case where bs_Investment_ID__c IN:InvestmentIds]){ 
                            lst = createSystemAction((String)request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     BRCase.Id,BRCase.Customer_CIF__c,BRCase.accountId,response.getStatusCode(), 
                                                     'BidAllocationProcess', 'BidAllocationProcess'
                                                    );
                            BRCase.Last_Api_Call_Status__c='Failed';
                                if(failedAPICall.containsKey(BRCase.bs_Instrument_Id__c)){
                                    List<Sobject>failed = failedAPICall.get(BRCase.bs_Instrument_Id__c);
                                    failed.add(BRCase);
                                    failedAPICall.put(BRCase.bs_Instrument_Id__c,failed);
                                }else{
                                    failedAPICall.put(BRCase.bs_Instrument_Id__c,New List<sObject>{BRCase});
                                }
                        }
                    }else {
                        For(Case BRCase:[Select Id,Customer_CIF__c,accountId,Last_Api_Call_Status__c,Sub_Status__c,bs_Bid_Amount__c,bs_ISIN_Code__c,bs_Instrument_Id__c,bs_Investment_ID__c from case where bs_Investment_ID__c IN:InvestmentIds]){ 
                            if(ProcessInvstMentID.ContainsKey(BRCase.bs_Investment_ID__c)){   
                                BRCase.Last_Api_Call_Status__c='Success';
                                BRCase.Sub_Status__c='Processing';
                                BRCase.Operation_Result__c='Processing';
                                //Total_Bid_Amount=ProcessInvstMentID.get(BRCase.bs_Investment_ID__c);
                                bidAllocations.put(BRCase.bs_Instrument_Id__c,InstTotalBidInst.get(BRCase.bs_Instrument_Id__c));
                            }else if(CancelInvstMentID.Contains(BRCase.bs_Investment_ID__c)){
                                BRCase.Last_Api_Call_Status__c='Success';
                                BRCase.Sub_Status__c='Cancelled';
                                BRCase.Operation_Result__c='Canceled';}
                            cs.add(BRCase);
                            
                        }  
                    }
                }
                catch (Exception e) {                      
                    System.debug('Error:' + e.getMessage() + 'LN:' + e.getLineNumber() );
                }
                //  }
            }else{
                set<String>ByBank= New set<String>();
                List<case>byCustomer =New List<Case>();
                ByBank.addAll(InstTotalBidInst.keySet());
                System.debug('inside ByBank'+ByBank);
                isMinimumBid=True;
                MinimumInvstMentID.putAll(ProcessInvstMentID);
                for(case cs:[Select Id,Customer_CIF__c,accountId,Last_Api_Call_Status__c,Sub_Status__c,bs_Bid_Amount__c,bs_ISIN_Code__c,bs_Instrument_Id__c,bs_Investment_ID__c from case where bs_Investment_ID__c IN:InvestmentIds]){
                    // if(ProcessInvstMentID.ContainsKey(cs.bs_Investment_ID__c)){
                    //    ByBank.add(cs.Id);
                    //}else 
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
                    ReleaseHoldAccountBalance(ByBank,'Cancelled by Bank Due to Bank Minimum Amount');
                }
                if(!byCustomer.isEmpty()){
                    update byCustomer;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        List<Sobject>cslist =New  List<Sobject>();
        List<String> csModel = New List<String>();
        if(!cs.isEmpty()){update cs;}
        MAP<String,List<Sobject>> BRCasebuyRequests= New MAP<String,List<Sobject>>();
        for(Case BRCase:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c,ccol_Hold_Account_IBAN__c,cc_Nationality__c,Account.Passport_Number__pc from case where bs_ISIN_Code__c=:ISINCode AND Sub_Status__c IN('In-Progress','Processing') AND Operation_Result__c !='Canceled'  AND Type='New Bond/Sukuk Buy Request']){
            //for(Case BRCase:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c from case where bs_ISIN_Code__c=:ISINCode AND Type='New Bond/Sukuk Buy Request']){ 
            if(BRCasebuyRequests.containsKey(BRCase.bs_Instrument_Id__c)){
                cslist= BRCasebuyRequests.get(BRCase.bs_Instrument_Id__c);
                cslist.add(BRCase);
                BRCasebuyRequests.put(BRCase.bs_Instrument_Id__c,cslist);
            }else{
                BRCasebuyRequests.put(BRCase.bs_Instrument_Id__c,New List<Sobject>{BRCase});
            }
            csModel.add(BRCase.Case_Model__c);
        }
        System.debug('isMinimumBid-->BH0006A14871'+isMinimumBid);
        System.debug('MinimumInvstMentID'+MinimumInvstMentID.keySet());
        if(buyRequest.isEmpty()){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            String[] toaddr = new String[]{System.Label.Treasury_Ops_Email_Address}; 
                String[] ccaddr = new string[]{System.Label.ila_Ops_Email_Address};
                    email.setSubject('Buy Request -' + ISINCode + ' - ' + ISINType);
            StaticResource srBegin= [select id,body from StaticResource Where Name = 'BidEmailTemplateBeginning'];
            StaticResource srEnd= [select id,body from StaticResource Where Name = 'BidEmailTemplateEnd'];
            String bodyContent=srBegin.body.toString()+'No Buy Requests Available'+srEnd.body.toString();
            email.setHtmlBody(bodyContent);
            email.setToAddresses(toaddr);
            email.setCcAddresses(ccaddr);
            if(!Test.isrunningtest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
        }
        if(isMinimumBid){
             MAP<String,List<Sobject>> BRCasebuyRequestsMinimum= New MAP<String,List<Sobject>>();
            for(Case BRCase:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c,ccol_Hold_Account_IBAN__c from case where bs_Investment_Id__c IN:MinimumInvstMentID.keySet() AND Type='New Bond/Sukuk Buy Request']){
                //for(Case BRCase:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,ac_Iban__c,bs_Instrument_Id__c from case where bs_ISIN_Code__c=:ISINCode AND Type='New Bond/Sukuk Buy Request']){ 
                if(BRCasebuyRequestsMinimum.containsKey(BRCase.bs_Instrument_Id__c)){
                    cslist= BRCasebuyRequestsMinimum.get(BRCase.bs_Instrument_Id__c);
                    cslist.add(BRCase);
                    BRCasebuyRequestsMinimum.put(BRCase.bs_Instrument_Id__c,cslist);
                }else{
                    BRCasebuyRequestsMinimum.put(BRCase.bs_Instrument_Id__c,New List<Sobject>{BRCase});
                }
            }
            for(String Iscode:BRCasebuyRequestsMinimum.keySet()){
                String Title = ISINCode + ' : ' + ISINType +'-'+System.Today();
                System.debug('BRCasebuyRequests'+BRCasebuyRequestsMinimum.get(Iscode));
                String ContentcsvId= GenerateCSVFile.createCSV(csvHeaders,csvFieldAPINames,BRCasebuyRequestsMinimum.get(Iscode),Title);
                Bid_Allocation__c ba = New Bid_Allocation__c();
                System.debug('ISINCode##'+ISINCode);
                ba.ISIN_Code__c=ISINCode;
                ba.Instrument_ID__c=Iscode;
                ba.ISIN_Type__c=ISINType;
                ba.Number_of_BIDS__c=buyRequests.get(Iscode).size();
                ba.Number_of_Failed_BIDS__c=failedAPICall.ContainsKey(Iscode)?failedAPICall.get(Iscode).size():0;
                System.debug('nstTotalBidInst.get(Icode)'+InstTotalBidInst.get(Iscode));
                ba.Total_Bid_Amount__c=InstTotalBidInst.get(Iscode);
                ba.Trigger_Type__c=triggerType;
                ba.Last_Api_Call_Status__c='Success';
                ba.Status__c='Closed';
                ba.OwnerId=System.Label.Ila_Ops_Maker;
                upsert ba Bid_Allocation__c.ISIN_Code__c;
                ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
                ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=ba.Id);
                insert cdl;  
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                String[] toaddr = new String[]{System.Label.Treasury_Ops_Email_Address}; 
                    String[] ccaddr = new string[]{System.Label.ila_Ops_Email_Address};
                        email.setSubject('Buy Request -' + ISINCode + ' - ' + ISINType);
                StaticResource srBegin= [select id,body from StaticResource Where Name = 'BidEmailTemplateBeginning'];
                StaticResource srEnd= [select id,body from StaticResource Where Name = 'BidEmailTemplateEnd'];
                String bodyContent=srBegin.body.toString()+'Minimum Bank Bid Amount Not Reached - Bids Placed Canceled'+srEnd.body.toString();
                email.setHtmlBody(bodyContent);
                email.setToAddresses(toaddr); 
                email.setCcAddresses(ccaddr);
                List<id> ContentDocumentIds = new List<id>();
                ContentDocumentIds.add(cvs.Id);
                email.setEntityAttachments(ContentDocumentIds);  
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            }
            
        }else{
            for(String Icode:BRCasebuyRequests.keySet()){
                If((failedAPICall.isEmpty()||!failedAPICall.ContainsKey(Icode))&&(buyRequests.ContainsKey(Icode))){
                    String Title = ISINCode + ' : ' + ISINType +'-'+System.Today();
                    String ContentcsvId= GenerateCSVFile.createCSV(csvHeaders,csvFieldAPINames,BRCasebuyRequests.get(Icode),Title);
                    Bid_Allocation__c ba = New Bid_Allocation__c();
                    ba.ISIN_Code__c=ISINCode;
                    ba.Instrument_ID__c=Icode;
                    ba.ISIN_Type__c=ISINType;
                    ba.Number_of_BIDS__c=BRCasebuyRequests.get(Icode).size();
                    ba.Number_of_Failed_BIDS__c=failedAPICall.ContainsKey(Icode)?failedAPICall.get(Icode).size():0;
                    System.debug('nstTotalBidInst.get(Icode)'+InstTotalBidInst.get(Icode));
                    ba.Total_Bid_Amount__c=InstTotalBidInst.get(Icode);
                    ba.Trigger_Type__c=triggerType;
                    ba.Last_Api_Call_Status__c='Success';
                    ba.Status__c='Pending Bid Allocation Announcement';
                    ba.OwnerId=System.Label.Ila_Ops_Maker;
                    upsert ba Bid_Allocation__c.ISIN_Code__c;
                    ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
                    ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=ba.Id);
                    insert cdl;            
                    if(csModel.Contains('ila') && csModel.Contains('alburaq')){
                        caseModel='ila & alburaq';
                    }else if(csModel.Contains('ila') && !csModel.Contains('alburaq')){
                        caseModel='ila';
                    }else if(!csModel.Contains('ila') && csModel.Contains('alburaq')){
                        caseModel='alburaq';
                    }
                    List<Messaging.SingleEmailMessage>MessageList =New List<Messaging.SingleEmailMessage>();
                    OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
                    if ( owea.size() > 0 ) 
                    {email.setOrgWideEmailAddressId(owea.get(0).Id); }
                    String[] toaddr = new String[]{System.Label.Treasury_Ops_Email_Address}; 
                        String[] ccaddr = new string[]{System.Label.ila_Ops_Email_Address};
                            email.setSubject('Buy Request -' + ISINCode + ' - ' + ISINType);      
                    StaticResource srBegin= [select id,body from StaticResource Where Name = 'BidEmailTemplateBeginning'];
                    StaticResource srEnd= [select id,body from StaticResource Where Name = 'BidEmailTemplateEnd'];
                    //String bodyContent=' Total Buy Requests:'+ba.Number_of_BIDS__c+'<br/>'+'Total Bid Amount:'+ba.Total_Bid_Amount__c+'<br/>'+'ISIN:'+ba.ISIN_Code__c+'<br/>'+'Type:'+caseModel+'<br/>';
                    String bodyContent=' Total Buy Requests:'+ba.Number_of_BIDS__c+'<br/>'+'Total Bid Amount:'+ba.Total_Bid_Amount__c+'<br/>'+'ISIN:'+ba.ISIN_Code__c+'<br/>';
                    String allcontents = srBegin.body.toString()+bodyContent+srEnd.body.toString();
                    email.setHTMLBody(allcontents);
                    email.setToAddresses(toaddr);
                    email.setCcAddresses(ccaddr);
                    List<id> ContentDocumentIds = new List<id>();
                    ContentDocumentIds.add(cvs.Id);
                    email.setEntityAttachments(ContentDocumentIds);  
                    MessageList.add(email);
                    Savepoint sp = Database.setSavepoint();
                    Messaging.sendEmail(MessageList);
                    Database.rollback(sp);
                    List<Messaging.SingleEmailMessage>actualMessageList =New List<Messaging.SingleEmailMessage>();
                    for(Messaging.SingleEmailMessage em:MessageList){
                        Messaging.SingleEmailMessage EmailToSend = new Messaging.SingleEmailMessage();
                        EmailToSend.setToAddresses(em.getToAddresses());
                        EmailToSend.setCcAddresses(em.getCcAddresses());
                        EmailToSend.setHTMLBody(allcontents);
                        //EmailToSend.setWhatId(UserInfo.getUserId());
                        EmailToSend.setSubject(em.getSubject());
                        EmailToSend.setOrgWideEmailAddressId(em.getOrgWideEmailAddressId());
                        EmailToSend.setEntityAttachments(em.getEntityAttachments());
                        actualMessageList.add(EmailToSend);
                    }
                    Messaging.sendEmail(actualMessageList); 
                } 
                If (!SystemLog.isEmpty() && SystemLog.ContainsKey(Icode)){
                    Bid_Allocation__c baf = New Bid_Allocation__c();
                    baf.ISIN_Code__c=ISINCode;
                    baf.Instrument_ID__c=Icode;
                    baf.Number_of_BIDS__c=buyRequests.get(Icode).size();
                    baf.Number_of_Failed_BIDS__c=failedAPICall.ContainsKey(Icode)?failedAPICall.get(Icode).size():0;
                    baf.Total_Bid_Amount__c=bidAllocations.get(Icode);
                    baf.Trigger_Type__c=triggerType;
                    baf.Last_Api_Call_Status__c='Failure';
                    baf.OwnerId=System.Label.Ila_Ops_Maker;
                    baf.Status__c='Pending Bid Allocation Announcement';
                    upsert baf Bid_Allocation__c.ISIN_Code__c;
                    List<Draw_System_Action__c>SLog =New List<Draw_System_Action__c>();
                    for(Draw_System_Action__c DSA:SystemLog.get(Icode)){
                        DSA.Buy_Out_Request__c=baf.Id;
                        SLog.add(DSA);
                    }
                    if(!SLog.isEmpty()){
                        insert SLog;
                    }
                    //lstSA = createSystemActionBuyOut(request.getBody(),response.getBody(),request.getEndpoint(),'Post',caseAcc.get(accObj.Id).id,caseAcc.get(accObj.Id).Customer_CIF__c,caseAcc.get(accObj.Id).accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                }
                
                
            }
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
    
    public static List<Draw_System_Action__c> createBondSystemAction(final String reqBody, final String resBody, final String path, Final String method,  Final Integer statCode,Final String strType, Final String strAction) {
        List<Draw_System_Action__c> lstSA = new List<Draw_System_Action__c>();
        Draw_System_Action__c action = new Draw_System_Action__c();
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
    
    global static void  ReleaseHoldAccountBalance(set<String> instrumentIds,String reason) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        Map<String,List<Case>>caseAcc = New Map<String,List<Case>>();
        if(!instrumentIds.isEmpty()){
            For(Case caseObj:[SELECT Id,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,ID_Type__c,cc_ID_Number__c,bs_Bid_Amount__c,account.CIF__pc,Case_Model__c,Customer_CIF__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Issue_No__c,bs_Investment_ID__c,bs_Instrument_Id__c FROM Case WHERE bs_Instrument_Id__c IN:instrumentIds AND Sub_status__c IN ('Processing','In-Progress')]){
                // caseAcc.put(caseObj.accountId,caseObj);
                if(caseAcc.containsKey(caseObj.bs_Instrument_Id__c)){
                    List<Case>cslist= caseAcc.get(caseObj.bs_Instrument_Id__c);
                    cslist.add(caseObj);
                    caseAcc.put(caseObj.bs_Instrument_Id__c,cslist);
                }else{
                    caseAcc.put(caseObj.bs_Instrument_Id__c,New List<Case>{caseObj});
                }
            }
            
            //#CH01 Start
            //  CaseModel = caseObj.Case_Model__c;
            //  if(caseObj.accountId != null && caseObj.accountId != '' ){
            for(String instCode:caseAcc.KeySet())
                //#CH01 Start
            {
                String regionName = 'Bahrain';
                //#CH01 Start
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                ApiConnection con = new ApiConnection();
                request = con.createRequest('DELETE','/api/v1/bond/instrument/'+instCode,regionName);
                HttpResponse response = http.send(request);
                System.debug('******************** loadAccountDetails : Start ********************* ');
                System.debug(request.getEndpoint());    
                System.debug(request.getMethod());
                System.debug(request.getBody());
                // System.debug(JSON.serializePretty(response));
                System.debug('******************** loadAccountDetails : End ********************* ');
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    
                    for(Case cs:caseAcc.get(instCode)){
                        lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'DELETE',cs.id,cs.Customer_CIF__c,cs.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                        cs.Last_Api_Call_Status__c='Failed';
                        casesToUpdateList.add(cs);
                    }
                    // caseAcc.get(accObj.Id).Last_Api_Call_Status__c='Failed';
                }else {   
                    for(Case cs:caseAcc.get(instCode)){
                        cs.Last_Api_Call_Status__c='Success';
                        cs.sub_status__c='Cancelled';
                        cs.Status='Closed';
                        cs.Closure_Reason__c=reason;
                        casesToUpdateList.add(cs);
                    }
                    
                }
                //}
                
            }
        }
        if(!casesToUpdateList.isEmpty()){
            update casesToUpdateList;}
        if(!lstSA.isEmpty()){
            insert lstSA;} 
    }
}