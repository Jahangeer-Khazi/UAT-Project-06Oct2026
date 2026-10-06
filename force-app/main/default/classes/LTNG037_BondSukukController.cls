/**
* @author Jayanth Manickam
* @date Création 25/12/2023
* @date Modification
* @description :ALL the functions used in LTNG037_BondSukukBuyRequest
* @history Modifications :   
*  
*/

public class LTNG037_BondSukukController {
    
    private static String CLASS_NAME = LTNG037_BondSukukController.class.getName();
    // Get Sukuk Bond Request RecordType
    @AuraEnabled
    public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
    }
    
    // Get available balance from the account
    @InvocableMethod(label='get Available Balance' description='The purpose of this service is to get the account balance' callout=true )
    public static List<String> validateAccountBalance(List<String> caseId){
        List<String>validateAccountBalCase= New List<String>();
        List<String>InvTempCanclCase= New List<String>();
        List<String>AppInvstmentIDs= New List<String>();
        For( Case caseObj :[SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,type,Operation_Result__c,Cc_Checker_result__c,OwnerId, Origin,bs_Investment_ID__c FROM Case WHERE Id IN:caseId]){
            if(caseObj.OwnerId==System.Label.Investment_Temp_Queue && caseObj.Operation_Result__c=='Canceled' && caseObj.Type=='New Bond/Sukuk Buy Request'){
                InvTempCanclCase.add(caseObj.Id);
            }else if(caseObj.OwnerId==System.Label.Investment_Buy_Request_Checker && caseObj.cc_Checker_result__c=='Accept' && caseObj.Type=='New Bond/Sukuk Buy Request' && caseObj.Origin=='CRM'){
                validateAccountBalCase.add(caseObj.Id);
            }else if (caseObj.Origin=='APP' && caseObj.OwnerId==System.Label.Investment_Temp_Queue){
                AppInvstmentIDs.add(caseObj.Id);
            }
        }
        //call future method
        if(!validateAccountBalCase.isEmpty()){
            validateAccountBalancewithBID(validateAccountBalCase);
        }
        if(!InvTempCanclCase.isEmpty()){
            ReleaseHoldAccountBalance(InvTempCanclCase,'Cancelled by Customer');
        }
        if(!AppInvstmentIDs.isEmpty()){
            Integer delay =20000;
            Long start = DateTime.now().getTime();
            while(DateTime.now().getTime()-start<delay);
            getInvestmentDetailsSourceApp(AppInvstmentIDs);
        }
        
        return null;
    } 
    
    //To compare the available Balance with Bid Amount
    @future(callout=true)
    public static void  getInvestmentDetailsSourceApp(List<String> caseId) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<String>accntID = New List<String>();
        List<Case> caseRec= New List<Case>();
        if(!caseId.isEmpty()){
            for(Case caseObj: [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Instrument__c,Customer_CIF__c,bs_Investment_ID__c, Account.x_canary__pc FROM Case WHERE Id IN:caseId]){
                CaseModel = caseObj.Case_Model__c;
                String regionName = caseObj.Region_Flag__c;
                if(caseModel == 'alburaq'){
                    regionName += '_alburaq';
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                ApiConnection con = new ApiConnection();
                // request = con.createRequest('GET','/api/v1/bond/investments?customerId='+caseObj.Customer_CIF__c,regionName);
                request = con.createRequest('GET','/api/v1/bond/investments/'+caseObj.bs_Investment_ID__c,regionName);
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
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                    
                    
                } else {
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                    System.debug('m1######'+JSON.serializePretty(m1));
                    //List<Object> InvestmentList = (List<Object>)m1.get('investments'); 
                    //  System.debug('InstrumentList######'+JSON.serializePretty(InvestmentList));
                    Map<String,Object> Investments = (Map<String,Object>)m1.get('investment'); 
                    System.debug('InstrumentList######'+JSON.serializePretty(Investments));
                    // for(Object InvstDetails : InvestmentList){
                    Map<String,Object> mapInstConfig = (Map<String, Object>)Investments; 
                    //  Map<String,Object> mapInstConfig = (Map<String, Object>)InvstDetails; 
                    Map<String,Object>instrumentDetail=(Map<String,Object>)mapInstConfig.get('instrument');
                    System.debug('isinTypeCBB###'+mapInstConfig.get('isinTypeCBB'));       
                    System.debug('minimumOrderAmount###'+mapInstConfig.get('minimumOrderAmount'));
                    if(mapInstConfig.get('id')==caseObj.bs_Investment_ID__c){
                        caseObj.ccol_Hold_Account_IBAN__c=String.valueOf(mapInstConfig.get('fundingAccountIban'));
                        caseObj.ccol_Hold_Account__c='Account';
                        caseObj.bs_Instrument__c=String.valueOf(instrumentDetail.get('isInTypeCBB'))+'-'+String.valueOf(instrumentDetail.get('isInCodeCBB'));
                        caseObj.bs_Issue_No__c=String.valueOf(instrumentDetail.get('issueNoCBB'));
                        caseObj.bs_Instrument_ID__c=String.valueOf(instrumentDetail.get('id'));
                        caseObj.bs_ISIN_Code__c=String.valueOf(instrumentDetail.get('isInCodeCBB'));
                        caseObj.bs_ISIN_Type__c=String.valueOf(instrumentDetail.get('isInTypeCBB'));
                        caseObj.bs_Issue_Date__c =Date.valueOf((String.valueOf(instrumentDetail.get('issueDateCBB')).split(' ')[0]).split('-')[2]+'-'+(String.valueOf(instrumentDetail.get('issueDateCBB')).split(' ')[0]).split('-')[1]+'-'+(String.valueOf(instrumentDetail.get('issueDateCBB')).split(' ')[0]).split('-')[0]);
                        caseObj.bs_Bid_Due_Date__c =Date.valueOf((String.valueOf(instrumentDetail.get('bidDueDate')).split(' ')[0]).split('-')[2]+'-'+(String.valueOf(instrumentDetail.get('bidDueDate')).split(' ')[0]).split('-')[1]+'-'+(String.valueOf(instrumentDetail.get('bidDueDate')).split(' ')[0]).split('-')[0]);                           
                        caseObj.bs_Issue_Amount__c =String.valueOf(instrumentDetail.get('issueAmountCBB'));                       
                        caseObj.bs_Maturity_Date__c=Date.valueOf((String.valueOf(instrumentDetail.get('maturityDateCBB')).split(' ')[0]).split('-')[2]+'-'+(String.valueOf(instrumentDetail.get('maturityDateCBB')).split(' ')[0]).split('-')[1]+'-'+(String.valueOf(instrumentDetail.get('maturityDateCBB')).split(' ')[0]).split('-')[0]);                            
                        caseObj.bs_Invitation_Date__c=Date.valueOf((String.valueOf(instrumentDetail.get('invitationDateCBB')).split(' ')[0]).split('-')[2]+'-'+(String.valueOf(instrumentDetail.get('invitationDateCBB')).split(' ')[0]).split('-')[1]+'-'+(String.valueOf(instrumentDetail.get('invitationDateCBB')).split(' ')[0]).split('-')[0]);                            
                        caseObj.bs_Tender_Date__c=Date.valueOf((String.valueOf(instrumentDetail.get('tenderDateCBB')).split(' ')[0]).split('-')[2]+'-'+(String.valueOf(instrumentDetail.get('tenderDateCBB')).split(' ')[0]).split('-')[1]+'-'+(String.valueOf(instrumentDetail.get('tenderDateCBB')).split(' ')[0]).split('-')[0]);
                        caseObj.bs_Bid_Fees__c=Decimal.valueOf(String.valueOf(mapInstConfig.get('bidAmountFee')));
                        caseObj.Special_Rate__c=String.valueOf(instrumentDetail.get('rateCBB'));
                        caseObj.bs_Total_Bid_Amount__c=Decimal.valueOf(String.valueOf(mapInstConfig.get('bidAmount')))+Decimal.valueOf(String.valueOf(mapInstConfig.get('bidAmountFee')))+Decimal.valueOf(String.valueOf(mapInstConfig.get('bidAmountVat')));
                        caseObj.bs_Bid_Amount__c=Decimal.valueOf(String.valueOf(mapInstConfig.get('bidAmount')));
                        caseObj.bs_Bid_VAT__c=Decimal.valueOf(String.valueOf(mapInstConfig.get('bidAmountVat')));
                        casesToUpdateList.add(caseObj);
                    }
                }
                // }
            }
            if(!casesToUpdateList.isEmpty()){
                update casesToUpdateList;
            }
            if(!lstSA.isEmpty()){
                insert lstSA;
            }
            //  PAD.debugLogEnd(CLASS_NAME, 'getInstrumentListViaApi', '[InsDetail] : ' + InsDetail );
        }
        
    }
    
    //To get the list of Instruments via Api
    @AuraEnabled
    public static List<InstrumentDetails> getInstrumentListViaApi(String accountId,String caseModel) {
        
        PAD.debugLogBegin(CLASS_NAME, 'getAccountToHoldAmountViaApi', 'Parameters : [accountId] : '+accountId );
        
        List<InstrumentDetails> InsDetail = new List<InstrumentDetails>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 Start
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/bond/instruments?filterOption=BIDABLE',regionName);
            request.setHeader('customerId',accObj.CIF__pc);
            if(accObj!= null){
                System.debug('x-canary added :'+accObj.x_canary__pc);
                if(accObj.x_canary__pc != null){
                    request.setHeader('x-canary', accObj.x_canary__pc);
                }
            }
            System.debug('request==>'+Request.getEndpoint());
            //toDo : use api 
            ApiConnection.Response response = con.makeCallout(request);           
            if (!response.isSuccess && null == response.responseData ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.responseData ;
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)response.responseData;
                List<Object> InstrumentList = (List<Object>)m.get('instruments'); 
                for(Object InstDetails : InstrumentList){
                    Map<String,Object> mapInstConfig = (Map<String, Object>)InstDetails;
                    System.debug('##mapInstConfig'+JSON.serializePretty(mapInstConfig.get('allowActions')));
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
                        String.valueOf(mapInstConfig.get('id')),
                        String.valueOf(mapInstConfig.get('maximumOrderAmount')),
                        String.valueOf(mapInstConfig.get('allowActions'))
                    ));
                }
            }
        }
        System.debug('##3InsDetail'+JSON.serializePretty(InsDetail));
        PAD.debugLogEnd(CLASS_NAME, 'getInstrumentListViaApi', '[InsDetail] : ' + InsDetail );
        
        return InsDetail;
    }
    
    //To get the list of accounts to Hold the amount from via Api
    @AuraEnabled
    public static List<AccountToHoldAmountDetails> getAccountListViaApi(String accountId,String caseModel) {
        
        PAD.debugLogBegin(CLASS_NAME, 'getAccountToHoldAmountViaApi', 'Parameters : [accountId] : '+accountId );
        
        List<AccountToHoldAmountDetails> accToHoldAmount = new List<AccountToHoldAmountDetails>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/accounts?',accObj.CIF__pc,regionName);
             if(accObj!= null){
                System.debug('x-canary added :'+accObj.x_canary__pc);
                if(accObj.x_canary__pc != null){
                    request.setHeader('x-canary', accObj.x_canary__pc);
                }
            }
            System.debug('request==>'+Request.getEndpoint());
            ApiConnection.Response response = con.makeCallout(request);           
            if (!response.isSuccess && null == response.responseData ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response;
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)response.responseData;
                List<Object> accountList = (List<Object>)m.get('accounts'); 
                for(Object accountDetails : accountList){
                    System.debug('###accountDetails'+accountDetails);
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    System.debug('mapaccountConfig###'+JSON.serializePretty(mapaccountConfig));
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');
                    System.debug('mapaccountDetails###'+JSON.serializePretty(mapaccountDetails));
                    if (accCurrency=='BHD'){
                        
                        accToHoldAmount.add( new AccountToHoldAmountDetails(
                            String.valueOf(mapaccountDetails.get('iban')) , 
                            accCurrency,
                            String.valueOf(mapaccountConfig.get('productType')).toUpperCase(),
                            String.valueOf(mapaccountDetails.get('availableBalance'))
                        ));
                    }
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToHoldAmountViaApi', '[accToHoldAmount] : ' + accToHoldAmount );
        
        return accToHoldAmount;
    }
    
    //To compare the available Balance with Bid Amount
    @future(callout=true)
    public static void  validateAccountBalancewithBID(List<String> caseId) {
        String CaseModel;
        List<String> bidHoldAccountBal = New List<String>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        ApiConnection con = new ApiConnection();
        if(!caseId.isEmpty()){
            Case caseObj = [SELECT Id,account.CIF__pc,Customer_CIF__c,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,ac_Iban__c,ccol_Hold_Account_IBAN__c FROM Case WHERE Id IN:caseId];
            //#CH01 Start
            CaseModel = caseObj.Case_Model__c;
            System.debug(caseObj.accountId);
            //     if(caseObj.accountId != null && caseObj.accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id =:caseObj.accountId];
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            
            final String path = '/api/v1/accounts/details?';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', path, accObj.CIF__pc, regionName);
            request.setBody('{"id": "'+caseObj.ccol_Hold_Account_IBAN__c+'"}');
             if(accObj!= null){
                System.debug('x-canary added :'+accObj.x_canary__pc);
                if(accObj.x_canary__pc != null){
                    request.setHeader('x-canary', accObj.x_canary__pc);
                }
            }
            HttpResponse response = http.send(request);
            //ApiConnection.Response response = con.makeCallout(req);
            System.debug('******************** loadAccountDetails : Start ********************* ');
            
            System.debug(request.getEndpoint());    
            System.debug(request.getMethod());
            System.debug(request.getBody());
            // System.debug(JSON.serializePretty(response));
            System.debug('******************** loadAccountDetails : End ********************* ');
            
            if (response.getStatusCode() != 200) 
            {   
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                
                caseObj.Last_Api_Call_Status__c='Failed';
                //  lst.add(actionRecord);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                Map<String, Object> m2 = (Map<String, Object>)m1.get('account');
                Map<String,Object> mapaccountConfig = (Map<String, Object>)m2;
                if(Integer.valueOf(mapaccountConfig.get('availableBalance'))>=caseObj.bs_Total_Bid_Amount__c){
                    bidHoldAccountBal.add(caseObj.Id);
                    // caseObj.Last_Api_Call_Status__c='Success';
                }else{
                    System.debug('inside Else');
                    caseObj.Last_Api_Call_Status__c='Failed';
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                    casesToUpdateList.add(caseObj);
                }
                // }
                
            }
            
        }
        if(!casesToUpdateList.isEmpty()){
            update casesToUpdateList;
        }
        if(!lstSA.isEmpty()){
            insert lstSA;
        }
        if(!bidHoldAccountBal.isEmpty()) {
            HoldBidAmount(bidHoldAccountBal);
        }   
        // }
    }
    
    //To Calculate Fees based on Instrument 
    @AuraEnabled
    public static List<InstrumentDetails>getBondListViaApi(Decimal Bidamount,String isinCode, String Iban, String accountId, String caseModel){
        List<InstrumentDetails>bondcal = New List<InstrumentDetails>();      
        System.debug('##accountId##'+accountId);
        
        Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        ApiConnection con = new ApiConnection();
        request = con.createRequest('POST','/api/v1/bond/simulate',regionName);
        System.debug('Bidamount##'+Bidamount);
        request.setHeader('CustomerID',accObj.CIF__pc);
        if(accObj!= null){
            System.debug('x-canary added :'+accObj.x_canary__pc);
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
        }
        request.setBody('{"fundIBAN": "'+Iban+'","isinCode":"'+isinCode+'","bidAmount":"'+Bidamount+'"}');
        HttpResponse response = http.send(request);
        
        System.debug('InstrumentDetails###'+response.getBody());
        if (response.getStatusCode() != 200 ) {
            String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
            System.debug(errorMsg);
            throw new AuraHandledException(errorMsg);
        }else {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            Map<String, Object> m2 = (Map<String, Object>)m1.get('calculatedAmount');
            bondcal.add( new InstrumentDetails(
                String.valueOf(m2.get('feeAmount')) , 
                String.valueOf(m2.get('vatamount')) ,
                String.valueOf(m2.get('totalAmount'))
            ));
        }        
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToHoldAmountViaApi', '[accToHoldAmount] : ' + bondcal );
        
        return bondcal;
    }
    
    //To Hold Bid Amount
    public static void  HoldBidAmount(List<String> caseId) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        if(!caseId.isEmpty()){
            Case caseObj = [SELECT Id,account.CIF__pc,Customer_CIF__c,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Bid_Amount__c,bs_Bid_Fees__c,bs_Bid_VAT__c,bs_Investment_ID__c,ccol_Hold_Account_IBAN__c,bs_ISIN_Code__c FROM Case WHERE Id IN:caseId];
            //#CH01 Start
            CaseModel = caseObj.Case_Model__c;
            //  if(caseObj.accountId != null && caseObj.accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id =:caseObj.accountId];
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 Start
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/bond',accObj.CIF__pc,regionName);
            if(accObj!= null){
                System.debug('x-canary added :'+accObj.x_canary__pc);
                if(accObj.x_canary__pc != null){
                    system.debug('x-canary==>'+accObj.x_canary__pc);
                    request.setHeader('x-canary', accObj.x_canary__pc);
                }
            }
            request.setBody('{"fundingAccountIban": "'+caseObj.ccol_Hold_Account_IBAN__c+'","allocationAmount":'+caseObj.bs_Bid_Amount__c+',"isinCode":"'+caseObj.bs_ISIN_Code__c+'","feesAmount":'+caseObj.bs_Bid_Fees__c+',"vatAmount":'+ caseObj.bs_Bid_VAT__c+',"crmCaseNo":"'+caseObj.Id+'"}');
            request.setTimeout(40000);
            System.debug('request==>'+request.getEndpoint());
            HttpResponse response = http.send(request);            
            System.debug('response##==>'+response.getBody());
            if (response.getStatusCode() != 200) 
            {   
                Map<String, Object> eresponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> emeta = (Map<String, Object>)eresponse.get('meta');
                System.debug('errorresponse##'+emeta);
                if((String)emeta.get('code')=='BONDS-1027'){
                   caseObj.Status='Closed';
                   caseObj.Closure_Reason__c='BID Already Exist -Same ISINCODE';
                   caseObj.Sub_Status__c='Cancelled';
                   caseObj.Last_Api_Call_Status__c='Failed'; 
                }else{
                System.debug('The status code returned was not expected: ' + response.getStatusCode()+' ' + response.getStatus());
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                caseObj.Last_Api_Call_Status__c='Failed';
                }
                
                //lstSA.add(actionRecord);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                Map<String, Object> m2 = (Map<String, Object>)m1.get('investment');
                caseObj.bs_Investment_ID__c = (String)m2.get('id');
                caseObj.Last_Api_Call_Status__c='Success';
                caseObj.Sub_Status__c='In-Progress';
                caseObj.OwnerId=System.Label.Investment_Temp_Queue;
            }
            casesToUpdateList.add(caseObj);
            //  }
            if(!casesToUpdateList.isEmpty()){
                update casesToUpdateList;
            }
            if(!lstSA.isEmpty()){
                insert lstSA;
            } 
        }
    } 
    
    //To get the list of accounts to Hold the amount from via Api
    @future(callout=true)
    public static void  ReleaseHoldAccountBalance(List<String> caseId,String reason) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        Map<String,Case>caseAcc = New Map<String,Case>();
        if(!caseId.isEmpty()){
            For(Case caseObj:[SELECT Id,bs_ISIN_Type__c,bs_ISIN_Code__c,bs_Issue_Amount__c,bs_Invitation_Date__c,bs_Tender_Date__c,bs_Issue_Date__c,Currency__c,bs_Maturity_Date__c,cc_Full_Name__c,ID_Type__c,cc_ID_Number__c,bs_Bid_Amount__c,account.CIF__pc,Case_Model__c,Customer_CIF__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Issue_No__c,bs_Investment_ID__c,bs_Instrument_Id__c FROM Case WHERE Id IN:caseId]){
                caseAcc.put(caseObj.accountId,caseObj);
            }
            
            //#CH01 Start
            //  CaseModel = caseObj.Case_Model__c;
            //  if(caseObj.accountId != null && caseObj.accountId != '' ){
            for(Account accObj:[SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id IN:caseAcc.KeySet()])
                //#CH01 Start
            {
                String regionName = accObj.Region_Flag__c;
                if(caseAcc.get(accObj.Id).Case_Model__c == 'alburaq'){
                    regionName += '_alburaq';
                }
                //#CH01 Start
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                ApiConnection con = new ApiConnection();
                request = con.createRequest('DELETE','/api/v1/bond/investments/'+caseAcc.get(accObj.Id).bs_Investment_ID__c,accObj.CIF__pc,regionName);
                if(accObj!= null){
                System.debug('x-canary added :'+accObj.x_canary__pc);
                if(accObj.x_canary__pc != null){
                    system.debug('x-canary==>'+accObj.x_canary__pc);
                    request.setHeader('x-canary', accObj.x_canary__pc);
                }
            }
                HttpResponse response = http.send(request);
                System.debug('******************** loadAccountDetails : Start ********************* ');
                System.debug(request.getEndpoint());    
                System.debug(request.getMethod());
                System.debug(request.getBody());
                // System.debug(JSON.serializePretty(response));
                System.debug('******************** loadAccountDetails : End ********************* ');
                if (response.getStatusCode() != 200) {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'DELETE',caseAcc.get(accObj.Id).id,caseAcc.get(accObj.Id).Customer_CIF__c,caseAcc.get(accObj.Id).accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                    
                    caseAcc.get(accObj.Id).Last_Api_Call_Status__c='Failed';
                }else {               
                    caseAcc.get(accObj.Id).Last_Api_Call_Status__c='Success';
                    caseAcc.get(accObj.Id).sub_status__c='Cancelled';
                    caseAcc.get(accObj.Id).Status='Closed';
                    caseAcc.get(accObj.Id).Closure_Reason__c=reason;
                }
                casesToUpdateList.add(caseAcc.get(accObj.Id));
                //}
                
            }
        }
        if(!casesToUpdateList.isEmpty()){
            update casesToUpdateList;}
        if(!lstSA.isEmpty()){
            insert lstSA;} 
    }
    
    @AuraEnabled
    public static List<BondConfiguration> getBondConfiguration(String accountId, String caseModel){
        List<BondConfiguration>Bconfig =New List<BondConfiguration>();
        ApiConnection con = new ApiConnection();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id =:accountId];
        //#CH01 Start
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/bond/configurations',regionName);
        // request.setHeader('filterByParameter','QUESTIONNAIRE_ENABLED');
        if(accObj!= null){
            System.debug('x-canary added :'+accObj.x_canary__pc);
            if(accObj.x_canary__pc != null){
                system.debug('x-canary==>'+accObj.x_canary__pc);
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
        }
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        String result;
        String allowedMultiples;
        if (response.getStatusCode() != 200) 
        {   
            String errorMsg = 'The status code returned was not expected when we are calling Get Bond Configuration API : ' + response.getStatusCode();
            System.debug(errorMsg);
            throw new AuraHandledException(errorMsg);
            //     SystemLog.put(ISINCode,createBondSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',response.getStatusCode(), 'Bid Allocation Process - Configuration API', 'Failed'));
            // System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }else{                
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> configurations = (List<Object>)m1.get('configurations'); 
            System.debug('configurations######'+JSON.serializePretty(configurations));
            for(Object config : configurations){
                Map<String,Object> mapbankConfig = (Map<String, Object>)config;
                If(String.valueOf(mapbankConfig.get('param'))=='QUESTIONNAIRE_ENABLED'){
                    result= String.valueOf(mapbankConfig.get('value'));
                }
                If(String.valueOf(mapbankConfig.get('param'))=='AMOUNT_ALLOWED_MULTIPLES'){
                    allowedMultiples= String.valueOf(mapbankConfig.get('value'));
                }
                
                
            }
            Bconfig.add(New BondConfiguration(result,allowedMultiples));
        }
        return Bconfig;
    }
    
    public class AccountToHoldAmountDetails {
        @AuraEnabled 
        public String iban {get; set;}
        
        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}
        
        @AuraEnabled 
        public String ac_type {get; set;}
        
        @AuraEnabled
        public String ac_balance {get; set;}
        
        public AccountToHoldAmountDetails(String iban,String ac_currency,String ac_type, String ac_balance){
            this.iban = iban;
            this.ac_currency = ac_currency;
            this.ac_label = iban +' - '+ ac_currency;
            this.ac_type = ac_type;
            this.ac_balance = ac_balance;
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
        public String bs_Min_Amount {get;set;}      
        @AuraEnabled
        public String bs_Bid_VAT{get;set;}     
        @AuraEnabled
        public String bs_Total_Bid_Amount{get;set;}
        @AuraEnabled
        public String bs_Process_Per{get;set;}
        @AuraEnabled
        public String bs_Instrument_Id{get;set;}
        @AuraEnabled
        public String bs_Max_Amount{get;set;}
        @AuraEnabled
        public String bs_allowedActions{get;set;}
        
        public InstrumentDetails(String bs_ISIN_Type,String bs_ISIN_Code, String bs_Issue_No, String bs_Issue_Amount,String bs_Invitation_Date, String bs_Bid_Due_Date,String bs_Tender_Date,String bs_Issue_Date, String bs_Maturity_Date, String bs_Rate,String bs_Min_Amount,String bs_Bid_Fees,String bs_Bid_VAT, String bs_Total_Bid_Amount, String bs_Process_Per,String bs_Instrument_Id,String bs_Max_Amount, String bs_allowedActions){
            this.bs_Instrument = bs_ISIN_Type+'-'+bs_ISIN_Code;
            this.bs_ISIN_Code = bs_ISIN_Code;
            this.bs_ISIN_Type = bs_ISIN_Type;
            this.bs_Issue_No = bs_Issue_No;
            this.bs_Issue_Amount = bs_Issue_Amount;
            this.bs_Invitation_Date=(bs_Invitation_Date.split(' ')[0]).split('-')[2]+'-'+(bs_Invitation_Date.split(' ')[0]).split('-')[1]+'-'+(bs_Invitation_Date.split(' ')[0]).split('-')[0];
            this.bs_Bid_Due_Date=(bs_Bid_Due_Date.split(' ')[0]).split('-')[2]+'-'+(bs_Bid_Due_Date.split(' ')[0]).split('-')[1]+'-'+(bs_Bid_Due_Date.split(' ')[0]).split('-')[0];
            this.bs_Tender_Date=(bs_Tender_Date.split(' ')[0]).split('-')[2]+'-'+(bs_Tender_Date.split(' ')[0]).split('-')[1]+'-'+(bs_Tender_Date.split(' ')[0]).split('-')[0];
            this.bs_Issue_Date =(bs_Issue_Date.split(' ')[0]).split('-')[2]+'-'+(bs_Issue_Date.split(' ')[0]).split('-')[1]+'-'+(bs_Issue_Date.split(' ')[0]).split('-')[0];
            this.bs_Maturity_Date=(bs_Maturity_Date.split(' ')[0]).split('-')[2]+'-'+(bs_Maturity_Date.split(' ')[0]).split('-')[1]+'-'+(bs_Maturity_Date.split(' ')[0]).split('-')[0];
            this.bs_Rate = bs_Rate;
            this.bs_Min_Amount=bs_Min_Amount;
            this.bs_Units=bs_Units;
            this.bs_Bid_Fees=bs_Bid_Fees;
            this.bs_Bid_VAT=bs_Bid_VAT;
            this.bs_Total_Bid_Amount=bs_Total_Bid_Amount;
            this.bs_Process_Per=bs_Process_Per;
            this.bs_Instrument_Id = bs_Instrument_Id;
            this.bs_Max_Amount=bs_Max_Amount;
            this.bs_allowedActions=bs_allowedActions;
        }
        
        public InstrumentDetails (String bs_Bid_Fees,String bs_Bid_VAT, String bs_Total_Bid_Amount){
            this.bs_Bid_Fees=bs_Bid_Fees;
            this.bs_Bid_VAT=bs_Bid_VAT;
            this.bs_Total_Bid_Amount=bs_Total_Bid_Amount;
        }
    }
    
    public class BondConfiguration {
        @AuraEnabled 
        public String bs_Questionaire {get; set;}       
        @AuraEnabled 
        public String bs_ALLOWED_MULTIPLES {get; set;} 
        public BondConfiguration (String bs_Questionaire,String bs_ALLOWED_MULTIPLES){
            this.bs_Questionaire=bs_Questionaire;
            this.bs_ALLOWED_MULTIPLES=bs_ALLOWED_MULTIPLES;
        }
    }
    
    
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
}