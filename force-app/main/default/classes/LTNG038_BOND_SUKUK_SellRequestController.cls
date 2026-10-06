/**
* @author Jayanth Manickam
* @date Création 08/01/2024
* @date Modification
* @description :ALL the functions used in LTNG038_BOND_SUKUK_SellRequest
* @history Modifications :   
*  
*/

public class LTNG038_BOND_SUKUK_SellRequestController {
    private static String CLASS_NAME = LTNG037_BondSukukController.class.getName();
    
    @AuraEnabled
    public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
    }
    
    
    @InvocableMethod(label='get Sell Bond Request List' description='The purpose of this service is to get the Sell Bond Request List' callout=true )
    public static List<String> SellBondRequestList(List<String> caseId){
        List<String>AcceptSellReq= New List<String>();
        List<String>CancelSellReq= New List<String>();
        List<String>ProcessSellReq= New List<String>();
        List<String>AppInvstmentIDs= New List<String>();
        For( Case caseObj :[SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,type,Operation_Result__c,Cc_Checker_result__c,OwnerId, Origin,bs_Investment_ID__c,sub_type__c FROM Case WHERE Id IN:caseId]){
            if(caseObj.OwnerId==System.Label.Investment_Sell_Request_Queue && caseObj.Operation_Result__c=='Decline' && ((caseObj.Type=='New Bond/Sukuk Sell Request')||(caseObj.Type=='Sukuk/bonds/Government security' && caseObj.Sub_Type__c=='Request to sell'))){
                CancelSellReq.add(caseObj.Id);
            }else if(caseObj.OwnerId==System.Label.Investment_Sell_Request_Checker && caseObj.cc_Checker_result__c=='Accept' && ((caseObj.Type=='New Bond/Sukuk Sell Request')||(caseObj.Type=='Sukuk/bonds/Government security' && caseObj.Sub_Type__c=='Request to sell'))){
                AcceptSellReq.add(caseObj.Id);
            }else if (caseObj.OwnerId==System.Label.Investment_Sell_Request_Queue && caseObj.Operation_Result__c=='Process Sell' && ((caseObj.Type=='New Bond/Sukuk Sell Request')||(caseObj.Type=='Sukuk/bonds/Government security' && caseObj.Sub_Type__c=='Request to sell'))){
                ProcessSellReq.add(caseObj.Id);
            }else if (caseObj.Origin=='App' && caseObj.OwnerId==System.Label.Investment_Sell_Request_Queue){
                AppInvstmentIDs.add(caseObj.Id);
            }
        }
        if(!AcceptSellReq.isEmpty()){
            SellBondRequest(AcceptSellReq,'create');
        }
        if(!CancelSellReq.isEmpty()){
            SellBondRequest(CancelSellReq,'cancel');
        }
        if(!ProcessSellReq.isEmpty()){
            SellBondRequest(ProcessSellReq,'sell');
        }
        if(!AppInvstmentIDs.isEmpty()){
            getInvestmentDetailsSourceApp(AppInvstmentIDs);
        }
        
        return null;
    } 
    //To get the list of all Bonds bought by the customer
    @AuraEnabled
    public static List<accountBondDetails> getAccountBondListViaApi(String accountId,String caseModel) {
        
        PAD.debugLogBegin(CLASS_NAME, 'getBondListViaApi', 'Parameters : [accountId] : '+accountId );
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<accountBondDetails> bondDetails = new List<accountBondDetails>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];

            System.debug('### Bond Investments - Account Query Result ###');
System.debug('Account Id: ' + accObj.Id);
System.debug('CIF: ' + accObj.CIF__pc);
System.debug('Person Email: ' + accObj.PersonEmail);
System.debug('Region Flag: ' + accObj.Region_Flag__c);
System.debug('X-Canary: ' + accObj.x_canary__pc);

            //#CH01 Start
            String regionName = accObj.Region_Flag__c;

            System.debug('### Bond Investments - Initial Region Name ###');
System.debug('regionName before caseModel check: ' + regionName);
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }

            System.debug('### Bond Investments - Region Name ###');
System.debug('caseModel: ' + caseModel);
System.debug('Final regionName: ' + regionName);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();

            System.debug('### Bond Investments - Creating HTTP Request ###');
System.debug('HTTP Method: GET');
System.debug('API Path: /api/v1/bond/investments');
System.debug('Region Name passed to createRequest: ' + regionName);

            request = con.createRequest('GET','/api/v1/bond/investments',regionName);

            System.debug('### Bond Investments - Request Created ###');
System.debug('Request Endpoint: ' + request.getEndpoint());
System.debug('Request Method: ' + request.getMethod());

            request.setHeader('customerId',accObj.CIF__pc);

            System.debug('customerId header set: ' + accObj.CIF__pc);

            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
                System.debug('x-canary header set: ' + accObj.x_canary__pc);
            } else {
    System.debug('x-canary header NOT set because value is null');
}
            System.debug('### Bond Investments - Final Request Details ###');
System.debug('Request Endpoint: ' + request.getEndpoint());
System.debug('Request Method: ' + request.getMethod());
System.debug('customerId: ' + request.getHeader('customerId'));
System.debug('x-canary: ' + request.getHeader('x-canary'));
            

            //toDo : use api 
System.debug('### Bond Investments - Sending HTTP Request ###');
System.debug('request==>' + request.getEndpoint());

            HttpResponse response = http.send(request);
            // ApiConnection.Response response = con.makeCallout(request);
            
            System.debug('### Bond Investments - HTTP Response ###');
System.debug('Response Status Code: ' + response.getStatusCode());
System.debug('Response Status: ' + response.getStatus());
System.debug('Response Body: ' + response.getBody());

            if (response.getStatusCode() != 200) 
            {   
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',accObj.Id,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                
            } else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> InvestmentList = (List<Object>)m1.get('investments'); 
                for(Object InvstDetails : InvestmentList){
                    Map<String,Object> mapInstConfig = (Map<String, Object>)InvstDetails;
                    Map<String,Object>instrumentDetail=(Map<String,Object>)mapInstConfig.get('instrument');
                    
                    if(mapInstConfig.get('status')=='Active'){
                        bondDetails.add( new accountBondDetails(
                            String.valueOf(mapInstConfig.get('id')) , 
                            String.valueOf(instrumentDetail.get('isInTypeCBB')) , 
                            String.valueOf(instrumentDetail.get('isInCodeCBB')) , 
                            String.valueOf(instrumentDetail.get('maturityDateCBB')),
                            String.valueOf(mapInstConfig.get('bidAmount'))
                        ));
                        
                    }
                }
            }
            
        }
        PAD.debugLogEnd(CLASS_NAME, 'getBondListViaApi', '[accToHoldAmount] : ' + bondDetails );
        
        return bondDetails;
    }
    
    // API request to sell the selected bond
    @future(callout=true)
    public static void  SellBondRequest(List<String> caseId, String stage) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        if(!caseId.isEmpty()){
            Case caseObj = [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Investment_ID__c,Customer_CIF__c,Claim_Amount__c,Transaction_Date__c,Transaction_Amount__c,bs_Issue_Date__c,ac_Iban__c,To_Date__c FROM Case WHERE Id IN:caseId];
            //#CH01 Start
            CaseModel = caseObj.Case_Model__c;
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
            request = con.createRequest('PUT','/api/v1/bond/sell',accObj.CIF__pc,regionName);
            if(accObj.x_canary__pc!=null)
            {
            request.setHeader('x-canary', accObj.x_canary__pc);
            }
            if(stage=='sell'){
            String SDate = DateTime.newInstance(caseObj.Transaction_Date__c.year(),caseObj.Transaction_Date__c.month(),caseObj.Transaction_Date__c.day()).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
            String PDate =  DateTime.newInstance(caseObj.To_Date__c.year(),caseObj.To_Date__c.month(),caseObj.To_Date__c.day()).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss');
              request.setBody('{"investmentId":"'+caseObj.bs_Investment_ID__c+'","crmCaseNo":"'+caseObj.Id+'","action":"'+stage+'","sellingPrice":"'+caseObj.Claim_Amount__c+'","sellingAmount":"'+caseObj.Transaction_Amount__c+'","sellingDate":"'+SDate+'","proceedsCreditedTo":"'+caseObj.ac_Iban__c+'","proceedsCreditedOn":"'+SDate+'"}');
                System.debug('{"investmentId":"'+caseObj.bs_Investment_ID__c+'","crmCaseNo":"'+caseObj.Id+'","action":"'+stage+'","sellingPrice":"'+caseObj.Claim_Amount__c+'","sellingAmount":"'+caseObj.Transaction_Amount__c+'","sellingDate":"'+SDate+'","proceedsCreditedTo":"'+caseObj.ac_Iban__c+'","proceedsCreditedOn":"'+PDate+'"}');
            }else{
              request.setBody('{"investmentId":"'+caseObj.bs_Investment_ID__c+'","crmCaseNo":"'+caseObj.Id+'","action":"'+stage+'"}');  
            }
            
            System.debug('requestBody==>'+'{"investmentId":"'+caseObj.bs_Investment_ID__c+'","crmCaseNo":"'+caseObj.Id+'","action":"'+stage+'"}');
            request.setTimeout(40000);
            System.debug('request==>'+request.getEndpoint());
            HttpResponse response = http.send(request);           
            System.debug('response##==>'+response.getBody());
            if (response.getStatusCode() != 200) 
            {   
                System.debug('The status code returned was not expected: ' + response.getStatusCode()+' ' + response.getStatus());
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Sell Request', 'Bond Sukuk Sell Request');  
                caseObj.Last_Api_Call_Status__c='Failed';
                casesToUpdateList.add(caseObj);
            }else{
                    caseObj.Last_Api_Call_Status__c='Success';
                     caseObj.OwnerId=System.Label.Investment_Sell_Request_Queue;
                if(stage=='sell'){
                        caseObj.Sub_Status__c='Sold';
                        caseObj.Status='Closed';
                    }
                if(stage=='cancel'){
                     caseObj.Sub_Status__c='Cancelled';
                     caseObj.Status='Closed';
                }
                    casesToUpdateList.add(caseObj);
                }
            
            //  }
            if(!casesToUpdateList.isEmpty()){
                update casesToUpdateList;
            }
            if(!lstSA.isEmpty()){
                insert lstSA;
            } 
        }
    }
    
      //To compare the available Balance with Bid Amount
    @future(callout=true)
    public static void  getInvestmentDetailsSourceApp(List<String> caseId) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        if(!caseId.isEmpty()){
            Case caseObj = [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Instrument__c,Customer_CIF__c,bs_Investment_ID__c FROM Case WHERE Id IN:caseId];
            //#CH01 Start
            CaseModel = caseObj.Case_Model__c;
                Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id =:caseObj.accountId];
                //#CH01 Start
                String regionName = accObj.Region_Flag__c;
                if(caseModel == 'alburaq'){
                    regionName += '_alburaq';
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                ApiConnection con = new ApiConnection();
                request = con.createRequest('GET','/api/v1/bond/investments?customerId='+caseObj.Customer_CIF__c,regionName);
                request.setHeader('customerId',accObj.CIF__pc);
                request.setHeader('x-canary', accObj.x_canary__pc);
                HttpResponse response = http.send(request);            
                if (response.getStatusCode() != 200) 
                {   
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                    
                } else {
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                    Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                    List<Object> InvestmentList = (List<Object>)m1.get('investments'); 
                    System.debug('InstrumentList######'+JSON.serializePretty(InvestmentList));
                    for(Object InvstDetails : InvestmentList){
                        Map<String,Object> mapInstConfig = (Map<String, Object>)InvstDetails; 
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
                }
            if(!casesToUpdateList.isEmpty()){
                update casesToUpdateList;
            }
            //  PAD.debugLogEnd(CLASS_NAME, 'getInstrumentListViaApi', '[InsDetail] : ' + InsDetail );
        }
        
    }
    
    public class accountBondDetails {
        @AuraEnabled 
        public String referenceNo {get; set;}
        
        @AuraEnabled 
        public String bs_ISIN_Code {get; set;}
        
        @AuraEnabled 
        public String bs_ISIN_Type {get; set;}
        
        @AuraEnabled 
        public String bs_Maturity_Date {get; set;}
        
        @AuraEnabled
        public String bs_bidAllocationAmount {get; set;}
        
        public accountBondDetails(String referenceNo,String bs_ISIN_Type,String bs_ISIN_Code, String bs_Maturity_Date, String bs_bidAllocationAmount){
            this.referenceNo = referenceNo;
            this.bs_ISIN_Code = bs_ISIN_Code;
            this.bs_ISIN_Type = bs_ISIN_Type;
            this.bs_Maturity_Date= (bs_Maturity_Date.split(' ')[0]).split('-')[2]+'-'+(bs_Maturity_Date.split(' ')[0]).split('-')[1]+'-'+(bs_Maturity_Date.split(' ')[0]).split('-')[0];
            this.bs_bidAllocationAmount = bs_bidAllocationAmount;
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