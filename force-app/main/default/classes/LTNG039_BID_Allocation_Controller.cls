/**
* @author Jayanth Manickam
* @date Création 08/01/2024
* @date Modification
* @description :ALL the functions used in LTNG039_BID_Allocation_Controller
* @history Modifications :   
*  
*/

public class LTNG039_BID_Allocation_Controller {
    private static String CLASS_NAME = LTNG039_BID_Allocation_Controller.class.getName();
    public string ISINCode;
    public String ISINType;
    
    public Integer totalNoOfRecords =0; 
    public Decimal Total_Bid_Amount =0;
    public List<sObject>buyRequest =  New List<sObject>();
    public Map<String,List<sObject>>buyRequests =  New Map<String,List<sObject>>();
    public Map<String,Decimal>bidAllocations =  New Map<String,Decimal>();
    public List<Case>cs= New List<Case>();
    public Map<String,Integer>InstTotalBidInst= New Map<String,Integer>();
    public String htmlBody='';
    
    //To get the recordType
    @AuraEnabled
    public static Id getBidAllocationRecordType() {
        return Schema.SObjectType.Bid_Allocation__c.getRecordTypeInfos()[0].getRecordTypeId();
    }
    
    //To get the list of available Instruments
    @AuraEnabled
    public static List<InstrumentDetails> getInstrumentListViaApi() {
        
        List<InstrumentDetails> InsDetail = new List<InstrumentDetails>();
        String regionName = 'Bahrain';
        //#CH01 Start
        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/bond/instruments?filterOption=ALL',regionName);
        System.debug('request==>'+request.getEndpoint());
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200 ) {
            String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
            System.debug(errorMsg);
            throw new AuraHandledException(errorMsg);
        }else {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> InstrumentList = (List<Object>)m1.get('instruments'); 
            for(Object InstDetails : InstrumentList){
                Map<String,Object> mapInstConfig = (Map<String, Object>)InstDetails;                
                InsDetail.add( new InstrumentDetails(
                    String.valueOf(mapInstConfig.get('isInTypeCBB')) , 
                    String.valueOf(mapInstConfig.get('isInCodeCBB')) , 
                    String.valueOf(mapInstConfig.get('issueNoCBB')),
                    String.valueOf(mapInstConfig.get('issueAmountCBB')),
                    String.valueOf(mapInstConfig.get('invitationDateCBB')),
                    String.valueOf(mapInstConfig.get('bidDueDate')),
                    String.valueOf(mapInstConfig.get('tenderDateCBB')),
                    String.valueOf(mapInstConfig.get('issueDateCBB')),
                    String.valueOf(mapInstConfig.get('maturityDateCBB')),
                    String.valueOf(mapInstConfig.get('rateCBB')),
                    String.valueOf(mapInstConfig.get('minimumOrderAmount')),
                    String.valueOf(mapInstConfig.get('processingFeesMinimumAmount')),
                    String.valueOf(mapInstConfig.get('processingFeesVAT')),
                    String.valueOf(mapInstConfig.get('totalBidAmount')),
                    String.valueOf(mapInstConfig.get('processingFeesPercentage')),
                    String.valueOf(mapInstConfig.get('id'))
                ));
            }
        }
        
        return InsDetail;
    }
    
    
    //To get process the bid allocation manually by operations
    @AuraEnabled
    public static String generateBIDAllocation(String InstrumentID, String triggerType) {
        String message = 'Processing the request';
        // Id jobId = Database.executeBatch(new APB09_GenerateBIDAllocationReport(True,ISINCode,ISINType,triggerType)); 
        Id jobId = System.enqueueJob(new QB01GenerateBIDAllocationReport(False,InstrumentID,triggerType));
        return message;
    }
    
    
    //To get the list of available Instruments
    //
    // Get available balance from the account
    @InvocableMethod(label='process Build Allocation' description='The purpose of this service is to get the account balance' callout=true )
    public static List<String> processBidAllocation(List<String> BidAllocationID){
        List<String>preprocessBids= New List<String>();
        List<String>processBids= New List<String>();
        List<String>processingStage = New List<String>();
        List<String>bidAllocationStage = New List<String>();
        List<String>bidExecutionStage = New List<String>();
        List<String>buyRequstSuccess = New List<String>();
        List<String>PreTreasuryOpsEmail = New List<String>();
        List<String>PostTreasuryOpsEmail = New List<String>();
        //   List<String>AppInvstmentIDs= New List<String>();
        For( Bid_Allocation__c bidObj :[SELECT Id,Auction_Report_Status__c,Allocation_Process_Status__c,Bid_Allocation_per__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Maker_Result__c,Checker_Result__c,OwnerId FROM Bid_Allocation__c WHERE Id IN:BidAllocationID]){
            System.debug('bidObj.OwnerId==>'+bidObj.OwnerId);
            System.debug('CustomLabel==>'+System.Label.Ila_Ops_Maker);
            System.debug('Auction_Report_Status__c==>'+bidObj.Auction_Report_Status__c);
            System.debug('Maker_Result__c==>'+bidObj.Maker_Result__c);
            System.debug('Last_Api_Call_Status__c==>'+bidobj.Last_Api_Call_Status__c);
            if(bidobj.Last_Api_Call_Status__c =='Completed-Stage1' && bidObj.OwnerId ==System.Label.Ila_Ops_Maker){
                processingStage.add(bidObj.Id);
            }else if(bidobj.Last_Api_Call_Status__c =='Completed-Stage2' && bidObj.OwnerId ==System.Label.Ila_Ops_Maker){
                bidAllocationStage.add(bidObj.Id);
            }else if(bidobj.Last_Api_Call_Status__c =='Completed-Stage3' && bidObj.OwnerId ==System.Label.Ila_Ops_Checker){
                bidExecutionStage.add(bidObj.Id);
            }else if(bidObj.Maker_Result__c=='Send to Checker' && bidObj.OwnerId ==System.Label.Ila_Ops_Maker && bidobj.Last_Api_Call_Status__c !='Completed-Stage2'){
                preprocessBids.add(bidObj.Id);
            }else if(bidObj.Checker_Result__c=='Execute Bid Allocation' && bidObj.OwnerId ==System.Label.Ila_Ops_Checker && bidobj.Last_Api_Call_Status__c !='Completed-Stage3'){
                processBids.add(bidObj.Id);
            }else if(bidobj.Last_Api_Call_Status__c =='Success-Stage3' && bidObj.OwnerId ==System.Label.Ila_Ops_Maker && bidObj.Auction_Report_Status__c=='Post Issuance Completed' && bidObj.Maker_Result__c==null){
                System.debug('inside1');
                PostTreasuryOpsEmail.add(bidObj.Id);
            }else if(bidObj.Maker_Result__c=='Buy Order Request Completed' && bidObj.OwnerId ==System.Label.Ila_Ops_Maker && bidobj.Last_Api_Call_Status__c =='Success-Stage3' && bidObj.Auction_Report_Status__c=='Post Issuance Completed'){
                buyRequstSuccess.add(bidObj.Id);
            }else if(bidobj.Last_Api_Call_Status__c =='Success-Stage1' && bidObj.OwnerId ==System.Label.Ila_Ops_Maker && bidObj.Auction_Report_Status__c=='Pre Issuance Completed'){
                PreTreasuryOpsEmail.add(bidObj.Id);
            }
            
        }
        //call future method
        if(!preprocessBids.isEmpty()){
            System.debug('inside##'+preprocessBids);
            validateprocessBids(preprocessBids);
        }
        if(!processBids.isEmpty()){
            executeprocessBids(processBids);
        }
        if(!processingStage.isEmpty()){
            CompletedStageProcessing(processingStage);
        }
        if(!bidAllocationStage.isEmpty())
        {
            CompletedStageBidAllocExecution(bidAllocationStage,'Estimate');
        }
        if(!bidExecutionStage.isEmpty()){
            CompletedStageBidAllocExecution(bidExecutionStage,'Final');
        }
        if(!buyRequstSuccess.isEmpty()){
            CloseAllBuyRequest(buyRequstSuccess);
        }
        if(!PreTreasuryOpsEmail.isEmpty()){
            sendEmailTreasuryOps(PreTreasuryOpsEmail,'Pre Issuance');
        }
        if(!PostTreasuryOpsEmail.isEmpty()){
            sendEmailTreasuryOps(PostTreasuryOpsEmail,'Post Issuance');
        }
        return null;
    } 
    
    //To compare the available Balance with Bid Amount
    @future(callout=true)
    public static void  validateprocessBids(List<String> BidAllocationID) {
        List<Draw_System_Action__c>SystemLog = New List<Draw_System_Action__c>();
        List<Bid_Allocation__c> UpdateBAList=new List<Bid_Allocation__c>();
        List<InvestmentDetails> InvsDetail = new List<InvestmentDetails>();
        System.debug('BidAllocationID==>'+BidAllocationID);
        if(!BidAllocationID.isEmpty()){
            Bid_Allocation__c bidObj = [SELECT Id,Allocation_Process_Status__c,Bid_Allocation_per__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Issue_Price__c,Yield_Rate__c FROM Bid_Allocation__c WHERE Id IN:BidAllocationID];
            Http http = new Http();
            ApiConnection con = new ApiConnection();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST','/api/v1/bond/investments/allocation','Bahrain');
            request.setBody('{"instrumentId": "'+bidObj.Instrument_ID__c+'","isinCode":"'+bidObj.ISIN_Code__c+'","stage":"bid_allocation","bidAllocationRate":"'+bidObj.Bid_Allocation_per__c+'","issuePrice":"'+bidObj.Issue_Price__c+'","yieldRate":"'+bidObj.Yield_Rate__c+'","crmCase":"'+bidObj.Id+'"}');
            System.debug('request==>'+Request.getEndpoint());
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            System.debug('request##==>'+request.getBody());
            System.debug('response##==>'+JSON.serializePretty(response.getBody()));
            if (response.getStatusCode() != 200 ) {
                SystemLog.addAll(createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',response.getStatusCode(), 'Bid Allocation Process - validate API', 'Failed'));
                bidObj.Last_Api_Call_Status__c='Failed-Stage2';
            }else {            
                bidObj.Last_Api_Call_Status__c='Processing-Stage2';
            }
            UpdateBAList.add(bidObj);
        }
        if(!UpdateBAList.isEmpty()){
            update UpdateBAList;
        }
        if(!SystemLog.isEmpty()){
            insert SystemLog;
        }
        
    }
    
    
    
    //To compare the available Balance with Bid Amount
    @future(callout=true)
    public static void  executeprocessBids(List<String> BidAllocationID) {
        List<Draw_System_Action__c>SystemLog = New List<Draw_System_Action__c>();
        List<Bid_Allocation__c> UpdateBAList=new List<Bid_Allocation__c>();
        List<InvestmentDetails> InvsDetail = new List<InvestmentDetails>();
        List<Case>CaseRec= New List<Case>();
        List<Object> investments = New List<Object>();
        if(!BidAllocationID.isEmpty()){
            Bid_Allocation__c bidObj = [SELECT Id,Allocation_Process_Status__c,Bid_Allocation_per__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Issue_Price__c FROM Bid_Allocation__c WHERE Id IN:BidAllocationID];
            Http http = new Http();
            ApiConnection con = new ApiConnection();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST','/api/v1/bond/investments/allocation','Bahrain');
            request.setTimeout(120000);
            request.setBody('{"instrumentId": "'+bidObj.Instrument_ID__c+'","isinCode":"'+bidObj.ISIN_Code__c+'","stage":"execute","crmCase":"'+bidObj.Id+'"}');
            System.debug('request==>'+Request.getEndpoint());
            HttpResponse response = http.send(request);
            System.debug('request##==>'+request.getBody());
            System.debug('response##==>'+JSON.serializePretty(response.getBody()));
            if (response.getStatusCode() != 200 ) {
                SystemLog.addAll(createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',response.getStatusCode(), 'Bid Allocation Process -Execute API', 'Failed'));
                bidObj.Last_Api_Call_Status__c='Failed-Stage3';
            }else {
                bidObj.Last_Api_Call_Status__c='Processing-Stage3';
                
            }
            UpdateBAList.add(bidObj);
        }
        if(!UpdateBAList.isEmpty()){
            update UpdateBAList;
        }
        
        if(!SystemLog.isEmpty()){
            insert SystemLog;
        }
        
    }
    
    public static void CompletedStageProcessing (List<String> BidAllocationID){
        MAP<String,List<Sobject>> BRCasebuyRequests= New MAP<String,List<Sobject>>();
        List<Case> ProcessCasebuyRequests= New List<Case>();
        List<Case> InprogressCasebuyRequests= New List<Case>();
        Bid_Allocation__c bidObj =[SELECT Id,Allocation_Process_Status__c,Total_Bid_Amount__c,Bid_Allocation_per__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Maker_Result__c,Checker_Result__c,OwnerId,Number_of_BIDS__c FROM Bid_Allocation__c WHERE Id IN:BidAllocationID];
        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/bond/instrument/investments?instrumentId='+bidObj.Instrument_ID__c,'Bahrain');
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        if (response.getStatusCode() != 200) 
        {   
            bidObj.Last_Api_Call_Status__c='Failed-Stage1';
        }else{
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            Object Summary =  (Map<String, Object>)m1.get('summary'); 
            List<Object> InvestmentList = (List<Object>)m1.get('investments');
            Map<String,Case>CurrentInvestment = New Map<String,Case>();
            for (Case ncs:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c,bs_Investment_ID__c,Account.Passport_Number__pc,cc_Nationality__c From Case Where bs_ISIN_Code__c=:bidObj.ISIN_Code__c  AND Sub_Status__c IN ('In-Progress','Processing') AND Type='New Bond/Sukuk Buy Request']){
                CurrentInvestment.put(ncs.bs_Investment_ID__c,ncs);
            }
            System.debug('response##==>'+JSON.serializePretty(InvestmentList));
            for(Object InvstDetails : InvestmentList){
                Map<String,Object> mapInvstConfig = (Map<String, Object>)InvstDetails;
                System.debug('InstrumentDetails##'+JSON.serializePretty((Map<String, Object>)mapInvstConfig.get('instrument')));
                Map<String,Object> mapInstConfig = (Map<String, Object>)mapInvstConfig.get('instrument');
                System.debug('isInTypeCBB'+String.valueOf(mapInstConfig.get('isInTypeCBB')));
                System.debug('isInCodeCBB'+String.valueOf(mapInstConfig.get('isInCodeCBB')));
                if(CurrentInvestment.containsKey( String.valueOf(mapInvstConfig.get('id')))&& (String.valueOf(mapInvstConfig.get('status'))=='Processing')){
                    Case preq = New Case();
                    Preq.Id=CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).Id;
                    Preq.Last_Api_Call_Status__c='Success';
                    Preq.Sub_Status__c='Processing';
                    Preq.Operation_Result__c='Processing';
                    ProcessCasebuyRequests.add(Preq);
                }else if(CurrentInvestment.containsKey( String.valueOf(mapInvstConfig.get('id')))&& (String.valueOf(mapInvstConfig.get('status'))=='In-Progress')){
                    InprogressCasebuyRequests.add(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))));
                }
            }
            if(!ProcessCasebuyRequests.isEmpty() && InprogressCasebuyRequests.isEmpty()){
                update ProcessCasebuyRequests;
                bidObj.Last_Api_Call_Status__c='Success-Stage1';
                bidObj.Number_of_BIDS__c = ProcessCasebuyRequests.size();
                bidObj.Number_of_Failed_BIDS__c=0;
                update bidObj;
            }else if(!ProcessCasebuyRequests.isEmpty() && !InprogressCasebuyRequests.isEmpty()){
                update ProcessCasebuyRequests;
                bidObj.Last_Api_Call_Status__c='Failed-Stage1';
                bidObj.Number_of_BIDS__c = ProcessCasebuyRequests.size() + InprogressCasebuyRequests.size();
                bidObj.Number_of_Failed_BIDS__c= InprogressCasebuyRequests.size();
                update bidObj;
            }else if(ProcessCasebuyRequests.isEmpty() && !InprogressCasebuyRequests.isEmpty()){
                bidObj.Last_Api_Call_Status__c='Failed-Stage1';
                bidObj.Number_of_BIDS__c = InprogressCasebuyRequests.size();
                bidObj.Number_of_Failed_BIDS__c= InprogressCasebuyRequests.size();
                update bidObj;
                
            }
            // bidObj.Last_Api_Call_Status__c='Success-Stage1';
            // update bidObj;
            List<Sobject>cslist =New  List<Sobject>();
            for(Case BRCase:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c,ccol_Hold_Account_IBAN__c,cc_Nationality__c,Account.Passport_Number__pc,Sub_Status__c from case where bs_ISIN_Code__c=:bidObj.ISIN_Code__c AND Sub_Status__c IN('In-Progress','Processing') AND Operation_Result__c !='Canceled'  AND Type='New Bond/Sukuk Buy Request']){
                //for(Case BRCase:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c from case where bs_ISIN_Code__c=:ISINCode AND Type='New Bond/Sukuk Buy Request']){ 
                
                if(BRCasebuyRequests.containsKey(BRCase.bs_Instrument_Id__c)){
                    cslist= BRCasebuyRequests.get(BRCase.bs_Instrument_Id__c);
                    cslist.add(BRCase);
                    BRCasebuyRequests.put(BRCase.bs_Instrument_Id__c,cslist);
                }else{
                    BRCasebuyRequests.put(BRCase.bs_Instrument_Id__c,New List<Sobject>{BRCase});
                }
            }
        }
        if(!BRCasebuyRequests.isEmpty() && BRCasebuyRequests.containsKey(bidObj.Instrument_ID__c)){
            List<String>csvHeaders = New List<String>{'ISIN Type','ISIN Code','Issue No','Issue Amount','Invitation Date','Tender Date','Issue Date','Currency','Maturity Date','Investor Name','Investor ID Type','Investor ID Number','Unit','IBAN','Bid Amount','Status'};
                List<String> csvFieldAPINames= New List<String>{'bs_ISIN_Type__c','bs_ISIN_Code__c','bs_Issue_No__c','bs_Issue_Amount__c','bs_Invitation_Date__c','bs_Tender_Date__c','bs_Issue_Date__c','Currency__c','bs_Maturity_Date__c','cc_Full_Name__c','ID_Type__c','cc_ID_Number__c','Case_Model__c','ccol_Hold_Account_IBAN__c','bs_Bid_Amount__c','Sub_Status__c','cc_Nationality__c','Account.Passport_Number__pc'};
                    String Title = bidObj.ISIN_Code__c + ' : ' + bidObj.ISIN_Type__c +'-'+System.Today();
            String ContentcsvId= GenerateCSVFile.createCSV(csvHeaders,csvFieldAPINames,BRCasebuyRequests.get(bidObj.Instrument_ID__c),Title);
            ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
            ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=bidObj.Id);
            insert cdl;            
            List<Messaging.SingleEmailMessage>MessageList =New List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
            if ( owea.size() > 0 ) 
            {email.setOrgWideEmailAddressId(owea.get(0).Id); }
            String[] toaddr = new String[]{System.Label.Treasury_Ops_Email_Address}; 
                String[] ccaddr = new string[]{System.Label.ila_Ops_Email_Address};
                    email.setSubject('Buy Request -' + bidObj.ISIN_Code__c + ' - ' + bidObj.ISIN_Type__c);      
            StaticResource srBegin= [select id,body from StaticResource Where Name = 'BidEmailTemplateBeginning'];
            StaticResource srEnd= [select id,body from StaticResource Where Name = 'BidEmailTemplateEnd'];
            //String bodyContent=' Total Buy Requests:'+ba.Number_of_BIDS__c+'<br/>'+'Total Bid Amount:'+ba.Total_Bid_Amount__c+'<br/>'+'ISIN:'+ba.ISIN_Code__c+'<br/>'+'Type:'+caseModel+'<br/>';
            String bodyContent=' Total Buy Requests:'+bidObj.Number_of_BIDS__c+'<br/>'+'Total Bid Amount:'+bidObj.Total_Bid_Amount__c+'<br/>'+'ISIN:'+bidObj.ISIN_Code__c+'<br/>';
            String allcontents = srBegin.body.toString()+bodyContent+srEnd.body.toString();
            email.setHTMLBody(allcontents);
            email.setToAddresses(toaddr);
            email.setCcAddresses(ccaddr);
            List<id> ContentDocumentIds = new List<id>();
            ContentDocumentIds.add(cvs.Id);
            email.setEntityAttachments(ContentDocumentIds);  
            MessageList.add(email);
            Savepoint sp = Database.setSavepoint();
            if(!Test.isrunningtest()){
                Messaging.sendEmail(MessageList); 
            }          
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
                if(!Test.isrunningtest()){
                   Messaging.sendEmail(actualMessageList); 
            } 
        
        }
        
    }
    public static void CompletedStageBidAllocExecution (List<String> BidAllocationID,String Stage){
        List<String>stillProcessing = New List<String>();
        List<Case>CaseRec= New List<Case>();
        Bid_Allocation__c bidObj =[SELECT Id,Allocation_Process_Status__c,Total_Bid_Amount__c,Bid_Allocation_per__c,Issue_Price__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Maker_Result__c,Checker_Result__c,OwnerId,Number_of_BIDS__c FROM Bid_Allocation__c WHERE Id IN:BidAllocationID];
        List<String>csvHeaders = New List<String>{'ISIN Type','ISIN Code','Issue No','Issue Amount','Invitation Date','Tender Date','Issue Date','Currency','Maturity Date','Investor Name','Investor ID Type','Investor ID Number','Unit','IBAN','Bid Amount','Bid Allocation Date','Bid Allocation Percentage','Bid Allocation Amount','Bid Allocation Amount Fee','Bid Allocation Amount VAT','CBB Percentage of total','Yield Rate','Issue Price','Status'};
            List<String> csvFieldAPINames= New List<String>{'bs_ISIN_Type','bs_ISIN_Code','bs_Issue_No','bs_Issue_Amount','bs_Invitation_Date','bs_Tender_Date','bs_Issue_Date','bs_Currency','bs_Maturity_Date','bs_customerName','bs_IDType','bs_IDNumber','bs_Unit','bs_fundingAccountIban','bs_Bid_Amount','bs_bidallocationdate','bs_bidallocationpercentage','bs_bidallocationamount','bs_bidallocationamountfee','bs_bidallocationamountvat','bs_CBBpercentageoftotal','bs_yieldrate','bs_IssuePrice','bs_Status','bs_passportNumber','bs_Nationality'};
                List<InvestmentDetails> InvsDetail = new List<InvestmentDetails>();
        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/bond/instrument/investments?instrumentId='+bidObj.Instrument_ID__c,'Bahrain');
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        if (response.getStatusCode() != 200) 
        {   
            if(Stage=='Final'){
                bidObj.Last_Api_Call_Status__c='Failed-Stage3';
            }else{
                bidObj.Last_Api_Call_Status__c='Failed-Stage2';  
            }
        }else{
            
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            Object Summary =  (Map<String, Object>)m1.get('summary'); 
            List<Object> InvestmentList = (List<Object>)m1.get('investments');
            Map<String,Case>CurrentInvestment = New Map<String,Case>();
            for (Case ncs:[Select Id,account.CIF__pc,accountId,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_No__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,cc_ID_Number__c,ID_Type__c,bs_Bid_Amount__c,Status,Region_Flag__c,Case_Model__c,bs_Instrument_Id__c,bs_Investment_ID__c,Account.Passport_Number__pc,cc_Nationality__c From Case Where bs_ISIN_Code__c=:bidObj.ISIN_Code__c  AND Sub_Status__c IN ('In-Progress','Processing') AND Type='New Bond/Sukuk Buy Request']){
                CurrentInvestment.put(ncs.bs_Investment_ID__c,ncs);
            }
            System.debug('response##==>'+JSON.serializePretty(InvestmentList));
            for(Object InvstDetails : InvestmentList){
                Map<String,Object> mapInvstConfig = (Map<String, Object>)InvstDetails;
                System.debug('InstrumentDetails##'+JSON.serializePretty((Map<String, Object>)mapInvstConfig.get('instrument')));
                Map<String,Object> mapInstConfig = (Map<String, Object>)mapInvstConfig.get('instrument');
                System.debug('isInTypeCBB'+String.valueOf(mapInstConfig.get('isInTypeCBB')));
                System.debug('isInCodeCBB'+String.valueOf(mapInstConfig.get('isInCodeCBB')));
                if(CurrentInvestment.containsKey( String.valueOf(mapInvstConfig.get('id')))){
                    if(String.valueOf(mapInvstConfig.get('status'))!='Active'){
                        stillProcessing.add(String.valueOf(mapInvstConfig.get('status')));
                    }
                    InvsDetail.add( new InvestmentDetails(
                        String.valueOf(mapInstConfig.get('isInTypeCBB')) , 
                        String.valueOf(mapInstConfig.get('isInCodeCBB')) , 
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Issue_No__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Issue_Amount__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).cc_Full_Name__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).ID_Type__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).cc_ID_Number__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Invitation_Date__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Tender_Date__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Issue_Date__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Maturity_Date__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).Case_Model__c),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).bs_Bid_Amount__c),                    
                        String.valueOf(mapInvstConfig.get('fundingAccountIban')),
                        String.valueOf(mapInvstConfig.get('bidAllocationDate')),
                        String.valueOf(mapInvstConfig.get('bidAllocationPercentage')),
                        String.valueOf(mapInvstConfig.get('bidAllocationAmount')),
                        String.valueOf(mapInvstConfig.get('bidAllocationAmountFee')),
                        String.valueOf(mapInvstConfig.get('bidAllocationAmountVat')),
                        String.valueOf(mapInvstConfig.get('cbbPercentageOfTotal')),
                        String.valueOf(mapInvstConfig.get('yieldRate')),
                        String.valueOf(String.valueOf(bidObj.Issue_Price__c)),
                        String.valueOf(mapInvstConfig.get('status')),
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).Account.Passport_Number__pc), 
                        String.valueOf(CurrentInvestment.get( String.valueOf(mapInvstConfig.get('id'))).cc_Nationality__c) 
                    ));
                }
            }
            if(Stage=='Final'){
                if(stillProcessing.isEmpty()){
                    for (Case cs:[SELECT Id,Sub_Status__c,Status,bs_ISIN_Code__c,bs_ISIN_Type__c,Last_Api_Call_Status__c FROM Case WHERE bs_ISIN_Code__c =:bidObj.ISIN_Code__c AND Sub_Status__c='Processing']){
                        cs.sub_status__c='Active';
                        cs.operation_result__c='Active';
                        CaseRec.add(cs);
                    }
                    bidObj.status__c='Pending CBB Report';
                    bidObj.OwnerId=System.Label.Ila_Ops_Maker;
                    bidObj.Last_Api_Call_Status__c='Success-Stage3';
                    bidObj.Maker_Result__c='';
                }else{
                    bidObj.Last_Api_Call_Status__c='Failed-Stage3';
                }
                
                
            }else{
                bidObj.status__c='Pending Bid Allocation Distribution';
                bidObj.Last_Api_Call_Status__c='Success-Stage2';
                bidObj.OwnerId=System.Label.Ila_Ops_checker;
                bidObj.Checker_Result__c='';
            }
            update bidObj;
            
        }
        System.debug('InvsDetail==>'+InvsDetail);
        if(!InvsDetail.isEmpty()){
            
            String Title = Stage=='Estimate'?'Buy Order Process-Estimation-':'Buy Order Process-Final Execution-'+System.Today();
            String ContentcsvId= GenerateCSVFile.createCSVCustom(csvHeaders,csvFieldAPINames,InvsDetail,Title);
            ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
            ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=bidObj.Id);
            insert cdl;
        }
        if(!CaseRec.isEmpty()){
            update  CaseRec;  
        }
    }
    public Static void CloseAllBuyRequest(List<String> BidAllocationID){
        List<Case>CaseRec= New List<Case>();
        List<Bid_Allocation__c> bidObj =[SELECT Id,Allocation_Process_Status__c,Total_Bid_Amount__c,Bid_Allocation_per__c,Issue_Price__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Maker_Result__c,Checker_Result__c,OwnerId,Number_of_BIDS__c FROM Bid_Allocation__c WHERE Id IN:BidAllocationID];
        for(Case CS:[Select Id, Sub_status__c,Status from Case where bs_instrument_id__c=:bidObj[0].Instrument_ID__c and Sub_status__c='Active']){
            cs.status = 'Closed';
            CaseRec.add(cs);
        }
        if(!CaseRec.isEmpty()){
            update CaseRec;
        }
        
    }   
    
    public Static void sendEmailTreasuryOps(List<String> BidAllocationID, String reportStatus){
        Bid_Allocation__c bidObj =[SELECT Id,Allocation_Process_Status__c,Total_Bid_Amount__c,Bid_Allocation_per__c,Issue_Price__c,Name,ISIN_Code__c,ISIN_Type__c,Last_Api_Call_Status__c,Status__c,Instrument_ID__c,Maker_Result__c,Checker_Result__c,OwnerId,Number_of_BIDS__c FROM Bid_Allocation__c WHERE Id IN:BidAllocationID];
        String Title = bidObj.ISIN_Code__c + ' : ' + bidObj.ISIN_Type__c +'-'+System.Today();
        String bodyContent;
        String Subject;
        String subjecttype =String.valueOf(bidObj.ISIN_Type__c).containsIgnoreCase('Bill')?'Treasury Bills':String.valueOf(bidObj.ISIN_Type__c).containsIgnoreCase('Sukuk')?'Sukuks':String.valueOf(bidObj.ISIN_Type__c).containsIgnoreCase('Bond')?'Bonds':'';
        // String ContentcsvId= GenerateCSVFile.createCSV(csvHeaders,csvFieldAPINames,BRCasebuyRequests.get(bidObj.Instrument_ID__c),Title);
        
        ContentDocumentLink cdl;
        for (ContentDocumentLink CDK:[SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.ContentModifiedDate, ContentDocument.ContentSize FROM ContentDocumentLink WHERE LinkedEntityId=:bidObj.Id]){
            if(reportStatus=='Pre Issuance' && String.valueOf(CDK.ContentDocument.Title).containsIgnoreCase('pre-issuance')){
                Cdl=CDK;
                
                bodyContent='Please find the Pre Issuance file attached <br/>';
                subject=subjecttype+' '+'Auction Report - Pre-Issuance  -' + bidObj.ISIN_Code__c;
            }else if(reportStatus=='Post Issuance' && String.valueOf(CDK.ContentDocument.Title).containsIgnoreCase('post-issuance')){
  //              bodyContent='Please find the Post Issuance file attached <br/>';
                Cdl=CDK;
               subject=subjecttype+' '+'Auction Report - Post-Issuance  -' + bidObj.ISIN_Code__c;
            }
        }
        
        ContentVersion cvs = [Select Id, ContentDocumentId from contentversion where ContentDocumentId=:cdl.ContentDocumentId];
        //insert cdl;            
        List<Messaging.SingleEmailMessage>MessageList =New List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'donotreply@ilabank.com'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        if ( owea.size() > 0 ) 
        {email.setOrgWideEmailAddressId(owea.get(0).Id); }
        String[] toaddr = new String[]{System.Label.Treasury_Ops_Email_Address}; 
            String[] ccaddr = new string[]{System.Label.ila_Ops_Email_Address};
                email.setSubject(subject);      
        StaticResource srBegin= [select id,body from StaticResource Where Name = 'BondsPrePostIssuance'];
        StaticResource srEnd= [select id,body from StaticResource Where Name = 'BidEmailTemplateEnd'];
        //String bodyContent=' Total Buy Requests:'+ba.Number_of_BIDS__c+'<br/>'+'Total Bid Amount:'+ba.Total_Bid_Amount__c+'<br/>'+'ISIN:'+ba.ISIN_Code__c+'<br/>'+'Type:'+caseModel+'<br/>';
        //String bodyContent=' Total Buy Requests:'+bidObj.Number_of_BIDS__c+'<br/>'+'Total Bid Amount:'+bidObj.Total_Bid_Amount__c+'<br/>'+'ISIN:'+bidObj.ISIN_Code__c+'<br/>';
        // String bodyContent='
        String allcontents = srBegin.body.toString()+srEnd.body.toString();
        email.setHTMLBody(allcontents);
        email.setToAddresses(toaddr);
        email.setCcAddresses(ccaddr);
        List<id> ContentDocumentIds = new List<id>();
        ContentDocumentIds.add(cvs.Id);
        email.setEntityAttachments(ContentDocumentIds);  
        MessageList.add(email);
        Savepoint sp = Database.setSavepoint();
        if(!test.isrunningtest()){
              Messaging.sendEmail(MessageList);
        }   
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
        if(!test.isrunningtest()){
        Messaging.sendEmail(actualMessageList);
        }
    }
    public class InstrumentDetails {
        @AuraEnabled 
        public String bs_Instrument {get; set;}       
        @AuraEnabled 
        public String bs_ISIN_Type {get; set;}       
        @AuraEnabled 
        public String bs_ISIN_Code {get; set;}       
        @AuraEnabled 
        public String bs_Issue_No {get; set;}       
        @AuraEnabled
        public String bs_Issue_Amount {get; set;}       
        @AuraEnabled
        public String bs_Invitation_Date {get; set;}        
        @AuraEnabled
        public String bs_Bid_Due_Date {get; set;}
        @AuraEnabled
        public String bs_Issue_Date {get; set;}
        @AuraEnabled
        public String bs_Tender_Date {get; set;}
        @AuraEnabled
        public String  bs_Maturity_Date {get; set;}
        @AuraEnabled
        public String  bs_Rate {get; set;}       
        @AuraEnabled
        public String  bs_Units {get; set;}               
        @AuraEnabled
        public String bs_Bid_Fees {get; set;}      
        @AuraEnabled
        public String bs_Bid_Amount {get;set;}      
        @AuraEnabled
        public String bs_Bid_VAT{get;set;}     
        @AuraEnabled
        public String bs_Total_Bid_Amount{get;set;}
        @AuraEnabled
        public String bs_Process_Per{get;set;}
        @AuraEnabled
        public String bs_Instrument_Id{get;set;}
        
        public InstrumentDetails(String bs_ISIN_Type,String bs_ISIN_Code, String bs_Issue_No, String bs_Issue_Amount,String bs_Invitation_Date, String bs_Bid_Due_Date,String bs_Tender_Date,String bs_Issue_Date, String bs_Maturity_Date, String bs_Rate,String bs_Bid_Amount,String bs_Bid_Fees,String bs_Bid_VAT, String bs_Total_Bid_Amount, String bs_Process_Per, String bs_Instrument_Id){
            this.bs_Instrument = bs_ISIN_Type+'-'+bs_ISIN_Code;
            this.bs_ISIN_Code = bs_ISIN_Code;
            this.bs_ISIN_Type = bs_ISIN_Type;
            this.bs_Issue_No = bs_Issue_No;
            this.bs_Issue_Amount = bs_Issue_Amount;
            this.bs_Invitation_Date=bs_Invitation_Date;
            this.bs_Bid_Due_Date=bs_Bid_Due_Date;
            this.bs_Tender_Date=bs_Tender_Date;
            this.bs_Issue_Date = bs_Issue_Date;
            this.bs_Maturity_Date= bs_Maturity_Date;
            this.bs_Rate = bs_Rate;
            this.bs_Bid_Amount=bs_Bid_Amount;
            this.bs_Units=bs_Units;
            this.bs_Bid_Fees=bs_Bid_Fees;
            this.bs_Bid_VAT=bs_Bid_VAT;
            this.bs_Total_Bid_Amount=bs_Total_Bid_Amount;
            this.bs_Process_Per=bs_Process_Per;
            this.bs_Instrument_Id=bs_Instrument_Id;
        }
    }
    
    
    
    public class InvestmentDetails {
        @AuraEnabled 
        public String bs_Instrument {get; set;}       
        @AuraEnabled 
        public String bs_ISIN_Type {get; set;}       
        @AuraEnabled 
        public String bs_ISIN_Code {get; set;}  
        @AuraEnabled 
        public String bs_Issue_No {get; set;}
        @AuraEnabled
        public String bs_Issue_Amount {get; set;} 
        /* @AuraEnabled 
public String bs_InstrumentId {get; set;}       
@AuraEnabled
public String bs_InvestmentId {get; set;}  */   
        @AuraEnabled
        public String bs_Invitation_Date {get; set;}
        @AuraEnabled
        public String bs_Issue_Date {get; set;}
        @AuraEnabled
        public String bs_Tender_Date {get; set;}
        @AuraEnabled
        public String  bs_Maturity_Date {get; set;}
        @AuraEnabled
        public String bs_customerName {get; set;}   
        @AuraEnabled
        public String bs_IDType {get; set;}
        @AuraEnabled
        public String bs_IDNumber {get; set;}
        @AuraEnabled
        public String bs_fundingAccountIban {get; set;}
        @AuraEnabled
        public String bs_bidallocationdate {get; set;}
        @AuraEnabled
        public String  bs_bidallocationpercentage {get; set;}
        @AuraEnabled
        public String  bs_bidallocationamount {get; set;}       
        @AuraEnabled
        public String  bs_bidallocationamountfee {get; set;}               
        @AuraEnabled
        public String bs_bidallocationamountvat {get; set;}      
        @AuraEnabled
        public String bs_CBBpercentageoftotal {get;set;}      
        @AuraEnabled
        public String bs_yieldrate{get;set;}     
        @AuraEnabled
        public String bs_IssuePrice{get;set;}
        @AuraEnabled
        public String bs_Unit{get;set;}
        @AuraEnabled
        public String bs_Bid_Amount{get;set;}
        @AuraEnabled
        public String bs_Currency{get;set;}
        @AuraEnabled
        public String bs_passportNumber{get;set;}
        @AuraEnabled
        public String bs_Nationality{get;set;}
        @AuraEnabled
        public String bs_Status{get;set;}
        
        public InvestmentDetails(String bs_ISIN_Type,String bs_ISIN_Code,String bs_Issue_No,String bs_Issue_Amount,/* String bs_InstrumentId, String bs_InvestmentId,String bs_customerId, String bs_status ,*/String bs_customerName,String bs_IDType,String bs_IDNumber,String bs_Invitation_Date,String bs_Tender_Date,String bs_Issue_Date, String bs_Maturity_Date,String bs_Unit,String bs_Bid_Amount,String bs_fundingAccountIban,String bs_bidallocationdate, String bs_bidallocationpercentage, String bs_bidallocationamount,String bs_bidallocationamountfee,String bs_bidallocationamountvat,String bs_CBBpercentageoftotal, String bs_yieldrate, String bs_IssuePrice,String bs_Status, String bs_passportNumber, String bs_Nationality){
            this.bs_Instrument = bs_ISIN_Type+'-'+bs_ISIN_Code;
            this.bs_ISIN_Type=bs_ISIN_Type;
            this.bs_ISIN_Code = bs_ISIN_Code;
            this.bs_Issue_No=bs_Issue_No;
            this.bs_Issue_Amount=bs_Issue_Amount;
            this.bs_Invitation_Date=bs_Invitation_Date;
            this.bs_Tender_Date=bs_Tender_Date;
            this.bs_Issue_Date = bs_Issue_Date;
            this.bs_Maturity_Date= bs_Maturity_Date;
            this.bs_customerName = bs_customerName;
            this.bs_IDType = bs_IDType;
            this.bs_IDNumber = bs_IDNumber;
            this.bs_fundingAccountIban=bs_fundingAccountIban;
            this.bs_bidallocationdate = bs_bidallocationdate;
            this.bs_bidallocationpercentage= bs_bidallocationpercentage;
            this.bs_bidallocationamount = bs_bidallocationamount;
            this.bs_bidallocationamountfee=bs_bidallocationamountfee;
            this.bs_bidallocationamountvat=bs_bidallocationamountvat;
            this.bs_CBBpercentageoftotal=bs_CBBpercentageoftotal;
            this.bs_IssuePrice=bs_IssuePrice;
            this.bs_yieldrate=bs_yieldrate;
            this.bs_Status=bs_Status;
            this.bs_Unit=bs_Unit;
            this.bs_Bid_Amount=bs_Bid_Amount;
            this.bs_Currency='BHD';
            this.bs_passportNumber = bs_passportNumber;
            this.bs_Nationality =bs_Nationality;
        }
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
}