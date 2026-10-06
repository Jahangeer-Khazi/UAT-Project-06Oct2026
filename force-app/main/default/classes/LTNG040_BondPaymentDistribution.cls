/**
* @author Jayanth Manickam
* @date Création 08/01/2024
* @date Modification
* @description :ALL the functions used in LTNG040_BondPaymentDistribution
* @history Modifications :   
*  
*/


public class LTNG040_BondPaymentDistribution {
    
    private static String CLASS_NAME = LTNG040_BondPaymentDistribution.class.getName();
    
    //to process the Maturity amount to the Bond Share holders
    @InvocableMethod(label='Execute Distribution Process' description='The purpose of this service is to process distribution' callout=true )
    public static List<String> executeDistributionProcess(List<String> invstDistId){
        List<String>CalDistReq= New List<String>();
        List<String>processCalDistReq= New List<String>();
        List<String>ExeDistReq= New List<String>();
        List<String>processDistReq= New List<String>();
        For( Investment_Distribution__c IDObj :[SELECT Id,Amount__c,Checker_Result__c,ISIN_Code__c,ISIN_Type__c,Maker__c,Maker_Result__c,type__c,Status__c,OwnerId,Last_Api_Call_Status__c FROM Investment_Distribution__c WHERE Id IN:invstDistId]){
            if(IDObj.OwnerId==System.Label.Ila_Ops_Maker && IDObj.Maker_Result__c=='Send to Checker' && IDObj.Last_api_call_status__c==null){
                CalDistReq.add(IDObj.Id);
            }else if(IDObj.OwnerId==System.Label.Ila_Ops_Maker && IDObj.Maker_Result__c=='Send to Checker' && IDObj.Last_api_call_status__c=='Completed-Stage1'){
                processCalDistReq.add(IDObj.Id);
            }
            else if (IDObj.OwnerId==System.Label.Ila_Ops_Checker && IDObj.Checker_Result__c=='Execute Process' && IDObj.Last_api_call_status__c=='Success-Stage1'){
                ExeDistReq.add(IDObj.Id);
            }else if (IDObj.OwnerId==System.Label.Ila_Ops_Checker && IDObj.Checker_Result__c=='Execute Process' && IDObj.Last_api_call_status__c=='Completed-Stage2'){
                processDistReq.add(IDObj.Id);
            }
        }
        if(!CalDistReq.isEmpty()){
            processInvestmentDistribution(CalDistReq,'calculate_distribution');
        }
        if(!ExeDistReq.isEmpty()){
            processInvestmentDistribution(ExeDistReq,'execute');
        }
        if(!processCalDistReq.isEmpty()){
            CompletedProcessing(processCalDistReq,'calculate_distribution');
        }
        if(!processDistReq.isEmpty()){
            CompletedProcessing(processDistReq,'execute');
        }

        return null;
    }
        
    @AuraEnabled
    public static List<accountBondDetails> getInstrumentListViaApi() {       
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<accountBondDetails> bondDetails = new List<accountBondDetails>();
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('GET','/api/v1/bond/instruments?filterOption=ALL','Bahrain');
        ApiConnection.Response response = con.makeCallout(request);
        
       if (!response.isSuccess && null == response.responseData ) {
            String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.responseData ;
           System.debug(errorMsg);
           throw new AuraHandledException(errorMsg);
       }else {
            Map<String, Object> m = (Map<String, Object>)response.responseData;
           System.debug('M1######'+JSON.serializePretty(m));
                List<Object> InstrumentList = (List<Object>)m.get('instruments'); 
                for(Object InstDetails : InstrumentList){
                Map<String,Object> mapInstConfig = (Map<String, Object>)InstDetails;  
                                bondDetails.add( new accountBondDetails(
                                    String.valueOf(mapInstConfig.get('id')) , 
                                    String.valueOf(mapInstConfig.get('isInCodeCBB')) , 
                                    String.valueOf(mapInstConfig.get('isInTypeCBB')) , 
                                    String.valueOf(mapInstConfig.get('maturityDateCBB')),
                                    String.valueOf(mapInstConfig.get('maximumOrderAmount'))
                                ));
                                
                            }
                        }
        
        PAD.debugLogEnd(CLASS_NAME, 'getBondListViaApi', '[accToHoldAmount] : ' + bondDetails );
        System.debug('bondDetails#####'+bondDetails);
        return bondDetails;
    }
    
    
    // process the Maturity amount to the Bond Share holders
    @future(callout=true)
    public static void  processInvestmentDistribution(List<String> InvDist, String stage) {
        List<Draw_System_Action__c> lst = new List<Draw_System_Action__c>();
                //#CH01 Start
                String regionName='Bahrain';
        List<Investment_Distribution__c>InvstDstUpdateList = New  List<Investment_Distribution__c>();
        if(!InvDist.isEmpty()){
            Investment_Distribution__c InDstObj = [SELECT Id,ISIN_Code__c,ISIN_Type__c,Amount__c,Status__c,Type__c,Checker_Result__c,Checker__c,Instrument_ID__c FROM Investment_Distribution__c WHERE Id IN:InvDist];
            //#CH01 Start
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/bond/investments/distribute/'+InDstObj.Instrument_ID__c,'Bahrain');
            request.setBody('{"isinCode":"'+InDstObj.ISIN_Code__c+'","stage":"'+stage+'","type":"'+InDstObj.Type__c.toLowerCase()+'","report":"false","amount":'+InDstObj.Amount__c+',"crmCase":"'+InDstObj.Id+'"}');
            System.debug('{"isinCode":"'+InDstObj.ISIN_Code__c+'","stage":"'+stage+'","type":"'+InDstObj.Type__c.toLowerCase()+'","report":"true","amount":'+InDstObj.Amount__c+'}');
            request.setTimeout(40000);
            System.debug('request==>'+request.getEndpoint());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200 ) {
                system.debug('body'+response.getBody());
                lst = createBondSystemAction((String)request.getBody(),response.getBody(),request.getEndpoint(),request.getMethod(),InDstObj.Id,response.getStatusCode(),'processInvestmentDistribution', 'Failed');
                If(stage=='execute'){
                InDstObj.Last_Api_Call_Status__c='Failed-Stage2';
                }else{
                    InDstObj.Last_Api_Call_Status__c='Failed-Stage1';
                }
                InvstDstUpdateList.add(InDstObj);
            }else {
                If(stage=='execute'){
                InDstObj.Last_Api_Call_Status__c='Processing-Stage2';
                }else{
                  InDstObj.Last_Api_Call_Status__c='Processing-Stage1';
                }         
                InvstDstUpdateList.add(InDstObj);
            }
            
        }
        if(!InvstDstUpdateList.isEmpty()){
            update InvstDstUpdateList;
        }
        if(!lst.isEmpty()){ insert lst;}
    } 
    
    public static void CompletedProcessing(List<String> InvDist, String stage){
            List<Draw_System_Action__c> lst = new List<Draw_System_Action__c>();
            List<InvestmentDetails>InvDetails = new List<InvestmentDetails>();
            List<String>csvHeaders = New List<String>{'Parent Distribution ID','Distribution ID','Instrument ID','Investment ID','Type','Total Amount','Status','Amount','Proceeds CreditedOn','Proceeds CreditedTo','Creation Date'};
            List<String> csvFieldAPINames= New List<String>{'ID_ParentDistributionID','ID_DistributionID','ID_instrumentId','ID_investmentId','ID_type','ID_total_amount','ID_status','ID_amount','ID_proceedsCreditedOn','ID_proceedsCreditedTo','ID_creationDate'};
            List<Investment_Distribution__c>InvstDstUpdateList = New  List<Investment_Distribution__c>();
        if(!InvDist.isEmpty()){
            Investment_Distribution__c InDstObj = [SELECT Id,ISIN_Code__c,ISIN_Type__c,Amount__c,Status__c,Type__c,Checker_Result__c,Checker__c,Instrument_ID__c,Distribution_ID__c FROM Investment_Distribution__c WHERE Id IN:InvDist];
            //#CH01 Start
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('GET','/api/v1/bond/distribute/'+InDstObj.Distribution_ID__c,'Bahrain');
          //  request.setBody('{"isinCode":"'+InDstObj.ISIN_Code__c+'","stage":"'+stage+'","type":"'+InDstObj.Type__c.toLowerCase()+'","report":"false","amount":'+InDstObj.Amount__c+'}');
           // System.debug('{"isinCode":"'+InDstObj.ISIN_Code__c+'","stage":"'+stage+'","type":"'+InDstObj.Type__c.toLowerCase()+'","report":"true","amount":'+InDstObj.Amount__c+'}');
            request.setTimeout(40000);
            System.debug('request==>'+request.getEndpoint());
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() != 200 ) {
                lst = createBondSystemAction((String)request.getBody(),response.getBody(),request.getEndpoint(),request.getMethod(),InDstObj.Id,response.getStatusCode(),'processInvestmentDistribution', 'Failed');
                If(stage=='execute'){
                InDstObj.Last_Api_Call_Status__c='Failed-Stage2';
                }else{
                    InDstObj.Last_Api_Call_Status__c='Failed-Stage1';
                }
                InvstDstUpdateList.add(InDstObj);
            }else {
                 Map<String, Object> mres = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> m1 = (Map<String, Object>)mres.get('data');
                System.debug('response##'+JSON.serializePretty(m1));
                List<Object>distributionList = (List<Object>)m1.get('distributeDetails');
                System.debug('distributionlList'+JSON.serializePretty(distributionList));
                System.debug('M1######'+JSON.serializePretty(mres));
                for(Object Inv:distributionList){
                   Map<String,Object> mapInvstConfig = (Map<String, Object>)Inv;
                    InvDetails.add( new InvestmentDetails(
                        String.valueOf(mapInvstConfig.get('creationDate')) , 
                        String.valueOf(mapInvstConfig.get('proceedsCreditedOn')) , 
                        String.valueOf(mapInvstConfig.get('proceedsCreditedTo')),
                        String.valueOf(mapInvstConfig.get('amount')),
                        String.valueOf(mapInvstConfig.get('investmentId')),
                        String.valueOf(mapInvstConfig.get('id')),
                        String.valueOf(m1.get('status')),
                        String.valueOf(m1.get('type')),
                        String.valueOf(m1.get('total_amount')),
                        String.valueOf(m1.get('instrumentId')),
                        String.valueOf(m1.get('id'))
                    ));
                }
                If(stage=='execute'){
                    InDstObj.Last_Api_Call_Status__c='Success-Stage2';
                    InDstObj.Status__c='Closed'; 
                    String Title = 'Final'+ InDstObj.ISIN_Code__c + ' : ' + InDstObj.ISIN_Type__c +'-'+System.Today();
                    String ContentcsvId= GenerateCSVFile.createCSVCustom(csvHeaders,csvFieldAPINames,InvDetails,Title);
                    ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
                    ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=InDstObj.Id);
                    insert cdl;
                }else{
                    InDstObj.Last_Api_Call_Status__c='Success-Stage1';
                    InDstObj.OwnerId=System.Label.Ila_Ops_Checker;
                    String Title = 'Estimate'+InDstObj.ISIN_Code__c + ' : ' + InDstObj.ISIN_Type__c +'-'+System.Today();
                    String ContentcsvId= GenerateCSVFile.createCSVCustom(csvHeaders,csvFieldAPINames,InvDetails,Title);
                    ContentVersion cvs = [Select Id, ContentDocumentId from contentversion Where Id=:ContentcsvId];
                    ContentDocumentLink cdl = new ContentDocumentLink(ContentDocumentId=cvs.ContentDocumentId,linkedEntityId=InDstObj.Id);
                    insert cdl;
                }
                 InvstDstUpdateList.add(InDstObj);
           }
           
        }
        if(!InvstDstUpdateList.isEmpty()){
            update InvstDstUpdateList;
        }
        if(!lst.isEmpty()){ insert lst;}
    }
    
    
    public class InvestmentDetails{
        @AuraEnabled
        public String ID_creationDate{get;set;}
        @AuraEnabled
        public String ID_proceedsCreditedOn{get;set;}
        @AuraEnabled
        public String ID_proceedsCreditedTo{get;set;}
        @AuraEnabled
        public String ID_amount{get;set;}
        @AuraEnabled
        public String ID_investmentId{get;set;}
        @AuraEnabled
        public String ID_DistributionID{get;set;}
        @AuraEnabled
        public String ID_status{get;set;}
        @AuraEnabled
        public String ID_type{get;set;}
        @AuraEnabled
        public String ID_total_amount{get;set;}
        @AuraEnabled
        public String ID_instrumentId{get;set;}
        @AuraEnabled
        public String ID_ParentDistributionID{get;set;}
        public InvestmentDetails(String ID_creationDate,String ID_proceedsCreditedOn, String ID_proceedsCreditedTo, String ID_amount, String ID_investmentId, String ID_DistributionID, String ID_status, String ID_type, String ID_total_amount, String ID_instrumentId, string ID_ParentDistributionID ){
            this.ID_creationDate =ID_creationDate;
            this.ID_proceedsCreditedOn=ID_proceedsCreditedOn;
            this.ID_proceedsCreditedTo=ID_proceedsCreditedTo;
            this.ID_amount=ID_amount;
            this.ID_investmentId=ID_investmentId;
            this.ID_DistributionID=ID_DistributionID;
            this.ID_status =ID_status;
            this.ID_type= ID_type;
            this.ID_total_amount =ID_total_amount;
            this.ID_instrumentId=ID_instrumentId;
            this.ID_ParentDistributionID=ID_ParentDistributionID;
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
        
        @AuraEnabled 
        public String bs_label {get; set;}
        
        public accountBondDetails(String referenceNo,String bs_ISIN_Code,String bs_ISIN_Type, String bs_Maturity_Date, String bs_bidAllocationAmount){
            this.referenceNo = referenceNo;
            this.bs_ISIN_Code = bs_ISIN_Code;
            this.bs_ISIN_Type = bs_ISIN_Type;
            this.bs_label=bs_ISIN_Type+'-'+bs_ISIN_Code;
            this.bs_Maturity_Date= bs_Maturity_Date;
            this.bs_bidAllocationAmount = bs_bidAllocationAmount;
        }
    }
    
      public static List<Draw_System_Action__c> createBondSystemAction(final String reqBody, final String resBody,final String path, Final String method,final String invsId,Final Integer statCode,Final String strType, Final String strAction) {
        List<Draw_System_Action__c> lstSA = new List<Draw_System_Action__c>();
        Draw_System_Action__c action = new Draw_System_Action__c();
        action.Action_Type__c = strAction;
        action.Investment_Distribution__c = invsId;
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