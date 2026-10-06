/**
* @author Aniss Mbarki
* @date Création 25/04/2023
* @date Modification
* @description : to hundel api calls for the Credit Card Requirements (credit card application Regular/Staff ; limit increase regular/staff ; supplementary card) 
* @change history: 
*             #CH01# add supplementary card Logique 
              #CH03 : #Imane Tsioucha# #22-02-2024# add x-canary header
              #CH04 : #Aniss Mbarki# #05-08-2024# ADD Alias_account__c Logic
 			  #CH05# #Jahangeer Mohammed #08-04-2026# Added Logic for Jordan Balance Transfer Process(NBA-15608)
*/
public without sharing class SM05_CreditCardApiHandler {
    
    private static String CLASS_NAME = SM05_CreditCardApiHandler.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static Map<Case,String> mapEmailPerCase = new Map<Case,String>();
    private static Set<Id> setCasesDocuSign = new Set<Id>();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    private static List<CaseComment> lstComment = new List<CaseComment>();
    public static Integer updateCreditCardRequestStatusApi_StatusCode = 200;
    public static Integer getCardProductConfiId_IncludeOtherProductsEqualTrue_StatusCode = 200;
    public static boolean throwException_1 = false;
    public static boolean throwException_2 = false;

    //#CH01
    private static List<Supplementary_Card__c> lstSuppCard = new List<Supplementary_Card__c>();
    
    @InvocableMethod(label='call Update Credit Card Request Status API' description='call Update Credit Card Request Status API' callout=true )
    public static List<String> updateCreditCardReqApiFromFlow(List<RequestCreditCard> reqPrepCards)
    {
        
        system.debug('reqPrepCards debug ==> '+reqPrepCards);
        RequestCreditCard reqCreditCard = reqPrepCards.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('isNew',reqCreditCard.isNew);
        details.put('changedField',reqCreditCard.changedField);
        system.debug('debug call updateCreditCardReqApiFromFlow');
        
        try{
            //call future method
            if(throwException_1){
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception!');
                throw e;
            }
            system.debug('debug call updateCreditCardReqApiFutureMeth');
            updateCreditCardReqApiFutureMeth(new Set<Id>{reqCreditCard.caseId},details);
            
        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId,Type FROM Case WHERE Id =: reqCreditCard.caseId];
            caseObj.Last_Api_Call_Status__c = 'Failed';
            update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                  'please check : '+CLASS_NAME+'.updateCreditCardReqApiFromFlow()', caseObj.Type
                                                 );
        }
        
        List<String> strLst = new List<String>();
        for(RequestCreditCard qst : reqPrepCards){
            strLst.add(qst.caseId);
        }
        return strLst;
    }
    
    @future(callout=true)
    public static void updateCreditCardReqApiFutureMeth(Set<Id> caseIds , Map<String,String> details){
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            //CH03 : add Account.x_canary__pc 
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.x_canary__pc,Account.Region_Flag__pc,(SELECT Id,Status__c FROM Supplementary_Cards__r) FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        
        String isNew = details.get('isNew');
        String changedField = details.get('changedField');
        
        for(Case caseObj : cases){
            try {
                if(throwException_2){
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception!');
                    throw e;
                }
                
                //update default values (approved fields)
                caseObj = cc_CreditCardSetDefaultValues(caseObj);
                
                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }
                
                HttpRequest request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest,regionName);
                request.setTimeout(60000);
                HttpResponse response;
                if ( test.isRunningTest() ) {
                    //fake response 
                    response = new HttpResponse();
                    String body = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."},"data":{"campaign":{"id":"0","name":"Not Applicable","validity":"0"}}}';
                    response.setStatus('OK');    
                    response.setStatusCode(updateCreditCardRequestStatusApi_StatusCode);
                    response.setBody(body);
                    response.setHeader('Content-Type', 'application/json');
                }
                
                if(isNew != null && isNew.equalsIgnoreCase('yes') ){ //for both types "'Credit Card Application'" & "'Credit Limit Increase Application'" 
                    /* 
                    objectif : call APi "request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards , regionName )" 
                    to get "cardProductConfigurationId" based on "objCase.cc_Requested_Card_Type__c" to use it on the next api 
                    
                    if( caseObj.PrimaryCardProductConfigurationId__c != null && caseObj.RecordType_DeveloperName__c == 'Credit_Card_Supplementary' ){
                        //no need to call Primary card configID function
                    }else{
                        caseObj.PrimaryCardProductConfigurationId__c = getCardProductConfigurationId(caseObj);
                    }*/

                    //#CH01
                    if( caseObj.Type == 'Credit Card Supplementary Application' && caseObj.RecordType_DeveloperName__c == 'Credit_Card_Supplementary'){
                        caseObj.PrimaryCardProductConfigurationId__c = getCardProductConfigurationId_SupplementaryCase(caseObj);
                    }else{
                        caseObj.PrimaryCardProductConfigurationId__c = getCardProductConfigurationId(caseObj);
                    }
                    
                    //#CH00 : Reminder Part on creation
                    if( caseObj.Type == 'Credit Card Application' && caseObj.RecordType_DeveloperName__c == 'Credit_Card'){
                        caseObj.cc_Send_notification_dateTime__c = System.now();
                        caseObj.cc_Customer_Response__c = 'Customer Not Responded';
                    }
                    //#CH00 : End

                    //#CH01 : Reminder Part on creation
                    if( caseObj.Type == 'Credit Card Supplementary Application' && caseObj.RecordType_DeveloperName__c == 'Credit_Card_Supplementary' &&
                        caseObj.Sub_Status__c == 'Pending' && caseObj.Awaiting_Customer_Feedback__c == true ){
                        caseObj.cc_Send_notification_dateTime__c = System.now();
                        caseObj.cc_Customer_Response__c = 'Customer Not Responded';
                    }
                    //#CH01 : End
                    
                    if( !test.isRunningTest() && caseObj.cc_CC_Application_Source__c != 'API' ){
                        response = updateCreditCardRequestStatusApi(request,caseObj,null,isNew);
                    }
                    
                    if(caseObj.cc_CC_Application_Source__c != 'API'){
                        if(response.getStatusCode() != 200){
                            System.debug('Invalid Update Credit Card Request Status API after insert');
                            caseObj.Last_Api_Call_Status__c = 'Failed';
                            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                     request.getEndpoint(),request.getMethod(),
                                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                     caseObj.Type+' Request Status API', caseObj.Type
                                                                    ));
                        }else{
                            System.debug('Update Credit Card Request Status API Getting Success Status Code from API after insert');
                            caseObj.Last_Api_Call_Status__c = 'Success';
                        }
                    }
                }
                else {
                    //#CH01 : add condition "|| caseObj.Type == 'Credit Card Supplementary Application'"
                    if(caseObj.Type == 'Credit Card Application' || caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Supplementary Application'){
                        
                        //objectif : add function to get apiStatus based on changedField and his value
                        CC_Application_Status_Mapping__mdt apiStatusMappingRecord = getApiStatusBasedOnCaseChanges(caseObj,changedField);
                        
                        if(apiStatusMappingRecord != null){
                            system.debug('debugging return metadata record : '+apiStatusMappingRecord.MasterLabel);
                        }
                        
                        //call again the Api to get cardProductConfig using the ApprovedCardType field in case it's changed manually during the process :
                        if(apiStatusMappingRecord != null && apiStatusMappingRecord.apiStatus__c != null && apiStatusMappingRecord.apiStatus__c.contains('APPROVED') ){
                            
                            //#CH01
                            if( caseObj.Type == 'Credit Card Supplementary Application' && caseObj.RecordType_DeveloperName__c == 'Credit_Card_Supplementary'){
                                caseObj.PrimaryCardProductConfigurationId__c = getCardProductConfigurationId_SupplementaryCase(caseObj);
                            }else{
                                //toCheck : only concerned if always "cc_Approved_Requested_Card_Type__c" will be not empty
                                caseObj.PrimaryCardProductConfigurationId__c = getCardProductConfiId_IncludeOtherProductsEqualTrue(caseObj);
                            }
                            //#CH01- end
                        }
                        
                        if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == true ){
                            System.debug('debug inside response');
                            if( !test.isRunningTest() ){
                                response = updateCreditCardRequestStatusApi(request,caseObj,apiStatusMappingRecord.apiStatus__c,isNew);
                            }
                            system.debug('---> Response New --> '+response.getBody());
                            if(response.getStatusCode() != 200){
                                caseObj.Last_Api_Call_Status__c = 'Failed';
                                if( changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c') ){
                                    caseObj.put( changedField , null );  
                                }
                                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                                         request.getEndpoint(),request.getMethod(),
                                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                                         caseObj.Type+' Request Status API', caseObj.Type
                                                                        ));
                            }
                            else{
                                system.debug('debug Success API');
                                caseObj = cc_CreditCardApplicationProcess(caseObj,changedField,apiStatusMappingRecord);
                            }
                        }else if(apiStatusMappingRecord != null && apiStatusMappingRecord.isApiCall__c == false){
                            system.debug('debug not calling API:');
                            caseObj.Last_Api_Call_Status__c = 'Success';
                            caseObj = cc_CreditCardApplicationProcess(caseObj,changedField,apiStatusMappingRecord);
                            
                            //Particullar Senarios :
                            if(changedField != null && changedField.equalsIgnoreCase('cc_Credit_Verification_Result__c') && caseObj.cc_Credit_Verification_Result__c == 'Return to Evaluator' ){
                                caseObj.cc_Credit_Evaluation_Result__c = 'Referred by Verifier';
                            }
                            else if(changedField != null && changedField.equalsIgnoreCase('cc_Credit_Approval_Result__c') && caseObj.cc_Credit_Approval_Result__c == 'Return to Verifier' ){
                                caseObj.cc_Credit_Verification_Result__c = 'Referred By Approver';
                            }
                            
                        }else {
                            system.debug('debug No meteadata record found'+caseObj.CaseNumber);
                            
                            lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +'No meteadata record found'+caseObj.CaseNumber,
                                                                     null,null,
                                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                                     caseObj.Type+' updateCreditCardReqApiFutureMeth (No CC_Application_Status_Mapping__mdt meteadata record found for this changed field: '+changedField+')', caseObj.Type
                                                                    ));
                            caseObj.Last_Api_Call_Status__c = 'Failed';
                            if( changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c') ){
                                caseObj.put( changedField , null );  
                            }             
                        }
                    }
                }
                
                
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                         caseObj.Type+' updateCreditCardReqApiFutureMeth (unhandled error)', caseObj.Type
                                                        ));
                caseObj.Last_Api_Call_Status__c = 'Failed';     
                if(caseObj.Status == 'All Documents Uploaded' ){
                    caseObj.Is_Doc_Dicrepancy__c = false;
                }
                
                if( changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c') ){
                    caseObj.put( changedField , null );  
                }        
            }
            
        }
        
        if(cases != null && cases.size()>0){
            system.debug('Debug Update Case:'+cases[0].cc_Application_Stages__c);
            update cases;
        }
        if(lstSA != null && lstSA.size()>0 && !Test.isRunningTest()){
            
            insert lstSA;
        }
        
        if(lstComment != null && lstComment.size()>0){
            insert lstComment;
        }

        //#CH01 :Start
        if(lstSuppCard != null && lstSuppCard.size()>0){
            upsert lstSuppCard;
        }
        //#CH01 :End

        //send emailsfboth or
        for( Case cs : mapEmailPerCase.keySet() ){
            system.debug('Send Email Alert:'+ mapEmailPerCase.get(cs));
            sendEmailAlert( cs , mapEmailPerCase.get(cs) );
        }
        
        if(setCasesDocuSign != null && setCasesDocuSign.size()>0 && !test.isRunningTest()){
            System.debug('call DocuSignApexToolKit');
            DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCasesDocuSign);
            System.enqueueJob(autoSendDocSign);
        }
        
    }
    
    public static void sendEmailAlert(Case objCase,String emailAlertName){
        
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId',objCase.Id);
        Params.put('emailAlertName',emailAlertName);
        Params.put('caseModel',objCase.Case_Model__c);
        Params.put('caseRecordTyeName',objCase.RecordType_DeveloperName__c);
        //create instance of Interview
        Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
        //Invoke start method
        stage.start(); 
    } 
    
    public static HttpResponse updateCreditCardRequestStatusApi(HttpRequest request,Case objCase,String updatedStatus,String isNewCase){
        PAD.debugLogBegin(CLASS_NAME, 'updateCreditCardRequestStatusApi','Parameters : [objCase] : '+ objCase);
        system.debug('debug API status : '+updatedStatus);
        if(objCase.Customer_CIF__c != null){
            request.setHeader('customerId', objCase.Customer_CIF__c);
        }
        
        if(updatedStatus == null ){
            if(objCase.Sub_Status__c == 'In-Progress'){
                updatedStatus = 'IN_PROGRESS';
            }else if(objCase.Sub_Status__c == 'Pending'){
                updatedStatus = 'PENDING';
            }
        }
        
        Map<String, String> requestObject = new Map<String, String>{
            'crmCaseId' => objCase.Id,
                'status' => updatedStatus,
                'embossName' => objCase.cc_Name_on_the_Card__c
                };
                    
                    
        requestObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c) );
        
        if( objCase.Type == 'Credit Limit Increase Application' && objCase.cc_CC_Application_Source__c == 'Manual' ){
            requestObject.put('pciNumber',objCase.cc_Credit_Card_PCI_Number__c);
        }
        
        if(objCase.Type == 'Credit Limit Increase Application'){
            requestObject.put('targetType','LIMIT_INCREASE');
        }
        
        //#CH01 :start
        if(objCase.Type == 'Credit Card Supplementary Application'){
            requestObject.put('targetType','SUPPLEMENTARY_CARD');
        }
        //#CH01 :end

        //#CH02 :Start
        if(isNewCase != null && isNewCase.equalsIgnoreCase('yes') && (objCase.Type == 'Credit Limit Increase Application' || objCase.Type == 'Credit Card Application') ){
            requestObject.put('termsAndConditionsAcceptance','false');
        }
        //#CH02 :End
        //CH05: Start
        if(isNewCase != null && isNewCase.equalsIgnoreCase('yes') && objcase.Type == 'Credit Card Application' && objcase.Is_Balance_Transfer__c == true){
            Integer balanceTransferRate = convertRate(objcase.Balance_Transfer_Rate__c);
            Integer balanceTransferFee = convertFee(objcase.Balance_Transfer_Fee__c);
            
            requestObject.put('balanceTransferOffer',objcase.Balance_Transfer_Offer_Code__c);
            requestObject.put('balanceTransferAmount',String.valueOf(objcase.cc_Balance_Transfer_Amount__c));
            requestObject.put('balanceTransferTenure',objcase.Balance_Transfer_Tenor__c);
            requestObject.put('balanceTransferOtherBankCardLimit', String.valueOf(objcase.Balance_Transfer_Other_Card_Limit__c));
            requestObject.put('balanceTransferRate', String.valueOf(balanceTransferRate));
            requestObject.put('balanceTransferFee', String.valueOf(balanceTransferFee));
        }
        //CH05: END
        Decimal approvedCreditLimit;
        if(objCase.cc_Approved_Credit_Limit__c != null ){
            approvedCreditLimit = objCase.cc_Approved_Credit_Limit__c;
        }else{
            approvedCreditLimit = objCase.cc_Requested_Credit_Limit__c;
        }
        
        Decimal approvedBalanceTransferAmount;
        if(objCase.cc_Approved_Balance_Transfer_Amount__c != null ){
            approvedBalanceTransferAmount = objCase.cc_Approved_Balance_Transfer_Amount__c;
        }else{
            approvedBalanceTransferAmount = objCase.cc_Balance_Transfer_Amount__c;
        }
        
        //add additional body params based on the apiStatus
        if(updatedStatus != null && objCase.Type != 'Credit Card Supplementary Application'){ //#CH01 : skip this bloc for supplementary
            
            if(updatedStatus.equalsIgnoreCase('APPROVED_PENDING_BT_PROCESSING') || updatedStatus.equalsIgnoreCase('APPROVED_PENDING_SIGNATURE') || 
               updatedStatus.equalsIgnoreCase('APPROVED')
              ){
                  requestObject.put('creditLimit',String.valueOf(approvedCreditLimit));
                  //CH05: Start
                  if(objcase.Type == 'Credit Card Application' && objcase.Is_Balance_Transfer__c == true){
                      Integer balanceTransferRate = convertRate(objcase.Balance_Transfer_Rate__c);
            		  Integer balanceTransferFee = convertFee(objcase.Balance_Transfer_Fee__c);
            		  requestObject.put('balanceTransferOffer',objcase.Balance_Transfer_Offer_Code__c);
                      requestObject.put('balanceTransferAmount',String.valueOf(approvedBalanceTransferAmount));
            		  requestObject.put('balanceTransferTenure',objcase.Balance_Transfer_Tenor__c);
            		  requestObject.put('balanceTransferOtherBankCardLimit', String.valueOf(objcase.Balance_Transfer_Other_Card_Limit__c));
            		  requestObject.put('balanceTransferRate', String.valueOf(balanceTransferRate));
                      requestObject.put('balanceTransferFee', String.valueOf(balanceTransferFee));
                  }
                  //CH05: END
                  if(updatedStatus.equalsIgnoreCase('APPROVED') || 
                     (updatedStatus.equalsIgnoreCase('APPROVED_PENDING_BT_PROCESSING') /*&& objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'*/)  
                    ){
                        //CH05: Start
                        if(objcase.Is_Balance_Transfer__c == false){
                           requestObject.put('balanceTransferAmount', String.valueOf(approvedBalanceTransferAmount) ); 
                        }
                        //requestObject.put('balanceTransferAmount', String.valueOf(approvedBalanceTransferAmount) );
                        //CH05: END
                    }
                  
              }
            else if(updatedStatus.equalsIgnoreCase('APPROVED_PENDING_BT_LETTER') && objCase.cc_Balance_Transfer_Reference_Number__c != null ){
                requestObject.put('transactionReference',objCase.cc_Balance_Transfer_Reference_Number__c );
            }
            
        }
        
        //#CH01 :start   
        if( objCase.Type == 'Credit Card Supplementary Application' && updatedStatus == 'PENDING' && isNewCase != null && isNewCase.equalsIgnoreCase('yes') ){
            //if new case created from app with substatus pending should call api with this body request
            String bod = '{"crmCaseId":"'+objCase.Id+
                            '","cardProductConfigurationId":'+SM001_ApiCalls.stringApiFormat(objCase.PrimaryCardProductConfigurationId__c)+
                            ',"pciNumber":'+SM001_ApiCalls.stringApiFormat(objCase.PrimaryCard__c) +
                            ',"embossName":'+ SM001_ApiCalls.stringApiFormat(objCase.cc_Name_on_the_Card__c)+
                            ',"supplementaryCard":'+
                                '{"mobile":"'+objCase.sc_Card_Holder_Mobile_No__c+
                                '","email":"'+objCase.sc_Card_Holder_Email_Address__c+
                                '","relationship":"'+objCase.sc_Relationship__c+
                                '","enableSpendingLimit":false},'+
                            '"creditLimit": 0' +
                            ',"targetType": "SUPPLEMENTARY_CARD","status":"PENDING"}';
            request.setBody(bod);
        }
        else{
            request.setBody( JSON.serialize(requestObject) );
        }
        //#CH01 :end
        
        System.debug('********************* updateCreditCardRequestStatusApi request.getEndpoint() **********************');
        System.debug(request.getEndpoint());
        
        System.debug('********************* updateCreditCardRequestStatusApi request.getBody() **********************');
        System.debug(request.getBody());
        
        HttpResponse response = EM001_ApiCalls.updateCreditCardRequestStatusApi(request,200);

        PAD.debugLogEnd(CLASS_NAME, 'updateCreditCardRequestStatusApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        
        //Store Success Response 
        if(response.getStatusCode() == 200){
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     objCase.Type+' Request Status API', objCase.Type
                                                    ));
        }
        
        return response;
    }
    
	//CH05: Start
    public static Integer convertRate(String rateStr) {
        if(String.isBlank(rateStr)) return 0;
        rateStr = rateStr.replace('%', '').trim();
        return Integer.valueOf(rateStr);
    }

    public static Integer convertFee(String feeStr) {
        if(String.isBlank(feeStr)) return 0;
        feeStr = feeStr.replace('JOD', '').trim();
        Decimal feeDecimal = Decimal.valueOf(feeStr);
        return feeDecimal.intValue();
    }
	//CH05: END
    
    public static String getCardProductConfigurationId(Case objCase){
        String cardProductConfigurationIdString;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = objCase.Region_Flag__c;    
        if(objCase.Case_Model__c == 'alburaq'){    
            regionName += '_alburaq';  
        }  
        request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards , regionName );  
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        
        HttpResponse response;
        if( test.isRunningTest() ){
            response = new HttpResponse();
            String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[],"pendingCards":[],"cardOptions":[{"cardProductConfigurationId":24,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila blue","cmsCardProductId":"002","cmsCardProductType":"01","order":0,"productStatus":"ORDER","campaign":[],"cardConfigurations":[{"configCode":"SUPPLEMENTARY_CARD_FEES","configValue":"0"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BAHRAIN","configValue":"0"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BH","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_TYPE","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CODE","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CONFIG_ID","configValue":"0"},{"configCode":"SUPPLEMENTARY_MIN_AGE","configValue":"0"},{"configCode":"SUPPLEMENTARY_MAX_AGE","configValue":"0"},{"configCode":"SUPPLEMENTARY_ID_SUPPORTED_COUNTRIES","configValue":"0"},{"configCode":"SUPPLEMENTARY_EXPIRY_DATE","configValue":"0"},{"configCode":"SUPPLEMENTARY_VALIDATE_PRIMARY_NATIONAL_ID","configValue":"0"},{"configCode":"MINIMUM_CREDIT_LIMIT_SECURED","configValue":"1500"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_البحرين","configValue":"0"},{"configCode":"MINIMUM_LIMIT","configValue":"1500"},{"configCode":"MAXIMUM_LIMIT","configValue":"50000"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed,Student,Business owner,Retired,Unemployed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"JOD"},{"configCode":"ANNUAL_RATE","configValue":"1.75"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"4"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_MAX_AMT","configValue":"105"},{"configCode":"ANNUAL_RATE","configValue":"1.75"},{"configCode":"MINIMUM_CREDIT_LIMIT_UNSECURED","configValue":"1500"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"200"},{"configCode":"MINIMUM_MONTHLY_INCOME_ILA","configValue":"200"},{"configCode":"MINIMUM_MONTHLY_INCOME_TO_ILA","configValue":"200"},{"configCode":"MINIMUM_LIMIT","configValue":"1500"},{"configCode":"MAXIMUM_LIMIT","configValue":"25000"},{"configCode":"HAS_DOCUMENTS","configValue":"TRUE"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed,Retired,Business Owner"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"JOD"},{"configCode":"MINIMUM_CREDIT_LIMIT","configValue":"1500"},{"configCode":"CREDIT_LIMIT_MULTIPLAYER","configValue":"1.2"},{"configCode":"CARD_REPLACEMENT_VAT","configValue":"0"},{"configCode":"CASHBACK_ENABLED","configValue":"TRUE"},{"configCode":"SHOW_ANNUAL_FEES_AMOUNT","configValue":"FALSE"},{"configCode":"SHOW_ANNUAL_RATE","configValue":"FALSE"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"0"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"0"},{"configCode":"DEFAULT_REQUESTED_CREDIT_LIMIT","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"4"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_MAX_AMT","configValue":"150"},{"configCode":"CARD_REPLACEMENT_FEES","configValue":"10"},{"configCode":"CMS_FEE_CONFIGURATION","configValue":"08"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_VAT","configValue":"0"}],"cardNature":["unsecured"],"cardTypeConfigurations":[]}]}}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
        }else{
            response = http.send(request);
        }
        
        
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     'Calling GET credit card Api After Insert', objCase.Type
                                                    ));
        }
        else
        {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> m2 = (List<Object>)m1.get('cardOptions');
            List<Map<String, Object>> a = new List<Map<String, Object>> ();
            for(Object obj : m2)
            {
                a.add((Map<String, Object>)obj);
                {
                    system.debug('---->> OBJ Iterations after insert --> '+obj);
                }
            }
            
            for(Map<String, Object> map1 : a)
            {
                if(map1.get('productMappingCode')== objCase.cc_Requested_Card_Type__c)
                {
                    cardProductConfigurationIdString = String.valueOf(map1.get('cardProductConfigurationId'));
                    system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationIdString);
                }
            }
            
            //Store Sucess Response
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     'Calling GET credit card Api to store cardProductConfigurationId : ==> '+cardProductConfigurationIdString , objCase.Type
                                                    ));
        }
        return cardProductConfigurationIdString;
    }
    
    public static String getCardProductConfiId_IncludeOtherProductsEqualTrue(Case objCase){
        System.debug('getCardProductConfiId_IncludeOtherProductsEqualTrue --> Function -->   ');
        String approvedCardProductConfigurationIdString;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = objCase.Region_Flag__c;    
        if(objCase.Case_Model__c == 'alburaq'){    
            regionName += '_alburaq';  
        }  
        request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, regionName );  
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        
        HttpResponse response;
        if( test.isRunningTest() ){
            response = new HttpResponse();
            String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[],"pendingCards":[],"cardOptions":[{"cardProductConfigurationId":24,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila blue","cmsCardProductId":"002","cmsCardProductType":"01","order":0,"productStatus":"ORDER","campaign":[],"cardConfigurations":[{"configCode":"SUPPLEMENTARY_CARD_FEES","configValue":"0"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BAHRAIN","configValue":"0"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BH","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_TYPE","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CODE","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CONFIG_ID","configValue":"0"},{"configCode":"SUPPLEMENTARY_MIN_AGE","configValue":"0"},{"configCode":"SUPPLEMENTARY_MAX_AGE","configValue":"0"},{"configCode":"SUPPLEMENTARY_ID_SUPPORTED_COUNTRIES","configValue":"0"},{"configCode":"SUPPLEMENTARY_EXPIRY_DATE","configValue":"0"},{"configCode":"SUPPLEMENTARY_VALIDATE_PRIMARY_NATIONAL_ID","configValue":"0"},{"configCode":"MINIMUM_CREDIT_LIMIT_SECURED","configValue":"1500"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_البحرين","configValue":"0"},{"configCode":"MINIMUM_LIMIT","configValue":"1500"},{"configCode":"MAXIMUM_LIMIT","configValue":"50000"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed,Student,Business owner,Retired,Unemployed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"JOD"},{"configCode":"ANNUAL_RATE","configValue":"1.75"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"4"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_MAX_AMT","configValue":"105"},{"configCode":"ANNUAL_RATE","configValue":"1.75"},{"configCode":"MINIMUM_CREDIT_LIMIT_UNSECURED","configValue":"1500"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"200"},{"configCode":"MINIMUM_MONTHLY_INCOME_ILA","configValue":"200"},{"configCode":"MINIMUM_MONTHLY_INCOME_TO_ILA","configValue":"200"},{"configCode":"MINIMUM_LIMIT","configValue":"1500"},{"configCode":"MAXIMUM_LIMIT","configValue":"25000"},{"configCode":"HAS_DOCUMENTS","configValue":"TRUE"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed,Retired,Business Owner"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"JOD"},{"configCode":"MINIMUM_CREDIT_LIMIT","configValue":"1500"},{"configCode":"CREDIT_LIMIT_MULTIPLAYER","configValue":"1.2"},{"configCode":"CARD_REPLACEMENT_VAT","configValue":"0"},{"configCode":"CASHBACK_ENABLED","configValue":"TRUE"},{"configCode":"SHOW_ANNUAL_FEES_AMOUNT","configValue":"FALSE"},{"configCode":"SHOW_ANNUAL_RATE","configValue":"FALSE"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"0"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"0"},{"configCode":"DEFAULT_REQUESTED_CREDIT_LIMIT","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"4"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_MAX_AMT","configValue":"150"},{"configCode":"CARD_REPLACEMENT_FEES","configValue":"10"},{"configCode":"CMS_FEE_CONFIGURATION","configValue":"08"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_VAT","configValue":"0"}],"cardNature":["unsecured"],"cardTypeConfigurations":[]}]}}';
            response.setStatus('OK');    
            response.setStatusCode(getCardProductConfiId_IncludeOtherProductsEqualTrue_StatusCode);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
        }else{
            response = http.send(request);
        }
        
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     'Calling GET credit card Api IncludeOtherProductsEqualTrue', objCase.Type
                                                    ));
        }
        else
        {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> m2 = new List<Object>();
            if(m1.containsKey('cardOptions') != null)
                m2=(List<Object>)m1.get('cardOptions');
            else if(m1.containsKey('pendingCards') != null)
                m2=(List<Object>)m1.get('pendingCards');
            
            List<Map<String, Object>> a = new List<Map<String, Object>> ();
            for(Object obj : m2)
            {
                a.add((Map<String, Object>)obj);
                {
                    system.debug('---->> OBJ Iterations after insert --> '+obj);
                }
            }
            
            for(Map<String, Object> map1 : a)
            {
                String approvedRequestCardType;
                if( objCase.cc_Approved_Requested_Card_Type__c != null ){
                    approvedRequestCardType = objCase.cc_Approved_Requested_Card_Type__c;
                }else{
                    approvedRequestCardType = objCase.cc_Requested_Card_Type__c;
                }
                if( map1.get('productMappingCode')== approvedRequestCardType )
                {
                    approvedCardProductConfigurationIdString = String.valueOf(map1.get('cardProductConfigurationId'));
                    system.debug('---> FINALL cardProductConfigurationId --> '+approvedCardProductConfigurationIdString);
                }
            }
            
            //Store Sucess Response
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     'Calling GET credit card Api to store cardProductConfigurationId before calling Approved apiStatus : ==> '+approvedCardProductConfigurationIdString , objCase.Type
                                                    ));
        }
        return approvedCardProductConfigurationIdString;
    }
    
    public static String getQueueIdBasedOnRegionAndQueueDevName( String regionFlag, String queueName ) {
        List<Queue_IDs__mdt> queueIds = [SELECT Id, Queue_ID__c, Queue_Name__c, Region__c 
                                         FROM Queue_IDs__mdt 
                                         WHERE Region__c =: regionFlag AND Queue_Name__c=:queueName];
        
        if(queueIds != null && queueIds.size()>0 ){
            System.debug('Debug queue Ids: '+queueIds);
            return queueIds[0].Queue_ID__c;
        }
        return null;
    }
    
    public static CC_Application_Status_Mapping__mdt getApiStatusBasedOnCaseChanges( Case caseObj, String changedField ){
        
        //CH05: Start: Added a field Is_Balance_Transfer__c on SOQL
        List<CC_Application_Status_Mapping__mdt> mappingMetadataList = [SELECT id,Label, fieldAPiName__c, Value__c, apiStatus__c,Awaiting_Customer_Feedback__c,Sub_Status__c,
                                                                        queueDeveloperName__c,isApiCall__c,crmStage__c,emailAlertName__c,cc_Application_Stages__c,regionName__c,Status__c,
                                                                        Type__c, criteria__c,MasterLabel,isDocuSign__c,sectionResultFields__c, fieldsToBeReseted__c,Is_Balance_Transfer__c
                                                                        FROM CC_Application_Status_Mapping__mdt 
                                                                        WHERE Type__c = :caseObj.Type AND regionName__c = :caseObj.Region_Flag__c AND fieldAPiName__c = :changedField 
                                                                        AND Value__c = :(String)caseObj.get(changedField) AND RecordType_DeveloperName__c =:caseObj.RecordType_DeveloperName__c];
        //CH05: END
        CC_Application_Status_Mapping__mdt defaultMetadataRec = null;
        system.debug('debugging Metadata:' +mappingMetadataList);
        for(CC_Application_Status_Mapping__mdt metadataRec : mappingMetadataList) {
            //CH05: Start
            if(metadataRec.criteria__c == null){
                // Special handling ONLY for Card Operation Result = Accept
                if(caseObj.Type == 'Credit Card Application' && changedField == 'cc_Card_Operations_Result__c' && metadataRec.Value__c == 'Accept'){
                    if(metadataRec.Is_Balance_Transfer__c == caseObj.Is_Balance_Transfer__c){
                        System.debug('Matched Based on Balance Transfer in Card Operation Result');
                        return metadataRec;
                     }
                     continue;
                }
                // Special handling ONLY for Operation Result = Accept Final Stage
                if(caseObj.Type == 'Credit Card Application' && changedField == 'cc_Operations_Result__c' && metadataRec.Value__c == 'Balance Transfer Processed'){
                    if(metadataRec.Is_Balance_Transfer__c == caseObj.Is_Balance_Transfer__c){
                        System.debug('Matched Based on Balance Transfer in BT Operation Result');
                        return metadataRec;
                     }
                     continue;
                }
                // Normal scenarios (only one metadata expected)
                if(defaultMetadataRec == null){
                    defaultMetadataRec = metadataRec;
                }
                continue;
            }
            //CH05: END
 			if(evaluateCriteria(caseObj, metadataRec.criteria__c)){
                return metadataRec;
            }
            
        }                                           
        return defaultMetadataRec;
    }
    
    public static Case cc_CreditCardApplicationProcess( Case caseObj, String changedField ,CC_Application_Status_Mapping__mdt apiStatusMappingRecord){
        
        String regionName = caseObj.Region_Flag__c; 
        
        caseObj.Awaiting_Customer_Feedback__c = apiStatusMappingRecord.Awaiting_Customer_Feedback__c;
        if(apiStatusMappingRecord.Sub_Status__c != null ){
            caseObj.Sub_Status__c = apiStatusMappingRecord.Sub_Status__c;
            caseObj.LastCaseSubStatusChanged__c = System.now();
            
            //Start : Logic to handle reminders part
            if( caseObj.Sub_Status__c.equalsIgnoreCase('Pending') || caseObj.Sub_Status__c.equalsIgnoreCase('Discrepancies')  || caseObj.Sub_Status__c.equalsIgnoreCase('Docs Received') ){
                caseObj.cc_Send_notification_dateTime__c = System.now();
                
                if( caseObj.Sub_Status__c.equalsIgnoreCase('Docs Received') ){
                    caseObj.Is_Doc_Dicrepancy__c = false;
                    caseObj.cc_Doc_Upload_Date_Time__c = System.now();
                }else {
                    caseObj.cc_Customer_Response__c = 'Customer Not Responded';
                }
                
                caseObj.cc_SMS_Sent_Flag__c = false;
                caseObj.cc_Email_Sent_Flag__c = false;
                caseObj.cc_signature_sms_sent_flag__c = false;
                caseObj.First_Reminder_Sent__c = false;
                caseObj.Second_Reminder_Sent__c = false;
                caseObj.Third_Reminder_Sent__c = false;
            }
            else if( caseObj.Sub_Status__c.equalsIgnoreCase('Pending Signature Verification') && apiStatusMappingRecord.Awaiting_Customer_Feedback__c == true ){
                caseObj.cc_Send_notification_dateTime__c = System.now();
                caseObj.cc_Customer_Response__c = 'Customer Not Responded';
            }
            else if( caseObj.Sub_Status__c.equalsIgnoreCase('Follow Up') && apiStatusMappingRecord.Awaiting_Customer_Feedback__c == true ){
                caseObj.cc_Send_notification_dateTime__c = System.now();
                caseObj.cc_Customer_Response__c = 'Customer Not Responded';
            }
            //End : reminders part

            //#CH04 :Start
            if( caseObj.Sub_Status__c.equalsIgnoreCase('Cancelled') && (caseObj.Type == 'Credit Limit Increase Application' || caseObj.Type == 'Credit Card Application' ) ){
                String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
                if(profileNameUserInfo == 'Integration Gateway' ){
                    caseObj.Alias_account__c = 'API';
                }else{
                    caseObj.Alias_account__c = 'Manual';
                }
            }
            //#CH04 :End
        }      
        if(apiStatusMappingRecord.Status__c != null ){
            caseObj.Status = apiStatusMappingRecord.Status__c;
        }     
        if(apiStatusMappingRecord.queueDeveloperName__c != null ){
            caseObj.OwnerId = getQueueIdBasedOnRegionAndQueueDevName(regionName,apiStatusMappingRecord.queueDeveloperName__c);
            caseObj.cc_Application_Stages__c = apiStatusMappingRecord.cc_Application_Stages__c;
        }
        if(apiStatusMappingRecord.isApiCall__c == true){
            caseObj.Last_Api_Call_Status__c = 'Success';
        }
        if(apiStatusMappingRecord.crmStage__c != null){
            caseObj.cc_CRM_Stage__c = apiStatusMappingRecord.crmStage__c;
        }
        if(apiStatusMappingRecord.emailAlertName__c != null){
            mapEmailPerCase.put(caseObj,apiStatusMappingRecord.emailAlertName__c);
        }
        if(apiStatusMappingRecord.isDocuSign__c == true){
            setCasesDocuSign.add(caseObj.id);
        }
        
        if( apiStatusMappingRecord.sectionResultFields__c != null ){
            List<string> fieldList = apiStatusMappingRecord.sectionResultFields__c.split(';');
            caseObj.put(fieldList.get(0),System.now());
            caseObj.put(fieldList.get(1),UserInfo.getUserId());
            
            String commentResult = (String)caseObj.get(fieldList.get(2));
            if( commentResult != null ){
                CaseComment resultComm = new CaseComment( ParentID=caseObj.id, CommentBody= fieldList.get(3) + ' - '+ commentResult );
                lstComment.add(resultComm);
                caseObj.put(fieldList.get(2),null);
            }
        }
        if( apiStatusMappingRecord.fieldsToBeReseted__c != null ){
            
            for(String FieldName: apiStatusMappingRecord.fieldsToBeReseted__c.split(';')){
                
                String objectName = 'Case';
                
                SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                DescribeSObjectResult d = r.getDescribe();
                if( d.fields.getMap().get(fieldName)!= null && String.valueof(d.fields.getMap().get(fieldName).getDescribe().getType()) == 'BOOLEAN'){
                    caseObj.put(FieldName,false);
                    continue;
                }
                caseObj.put(FieldName,null);
                
            }
        }

        //#CH01 : Start particular case for supplementary card (maker result == accept) 
        if( caseObj.Type == 'Credit Card Supplementary Application' && changedField.equalsIgnoreCase('cc_Checker_Result__c') && caseObj.cc_Checker_Result__c == 'Accept' ){
            caseObj = nameScreeningProcess(caseObj,changedField);
        }

        if( caseObj.Type == 'Credit Card Supplementary Application' && changedField.equalsIgnoreCase('cc_Card_Operations_Result__c') && caseObj.cc_Card_Operations_Result__c == 'Accept' ){
            caseObj = callApiToCreateSupplementaryCardInVPlus(caseObj,changedField);
        }
        //#CH01 : End
        
        return caseObj;
    }
    
    public static Boolean evaluateCriteria(Case caseObj, String criteriaField ){
        Boolean result = true;
        for(String criteria:criteriaField.split('&&')){
            
            List<string> opList = criteria.split(';');
            
            String caseField = opList[0];
            String operator = opList[1];
            String value = opList[2];
            if(operator == '=='){
                result = result && (caseObj.get(caseField) == value);
            } else if(operator == '!='){
                result = result && (caseObj.get(caseField) != value);
            }
        }
        return result;
    }
    
    public static Case cc_CreditCardSetDefaultValues(Case caseObj){
        
        if( caseObj.cc_Approved_Balance_Transfer_Amount__c == null ){
            caseObj.cc_Approved_Balance_Transfer_Amount__c = caseObj.cc_Balance_Transfer_Amount__c;
        }
        if( caseObj.cc_Approved_Credit_Limit__c == null ){
            caseObj.cc_Approved_Credit_Limit__c = caseObj.cc_Requested_Credit_Limit__c;
        }
        if( caseObj.cc_Approved_Requested_Card_Type__c == null ){
            caseObj.cc_Approved_Requested_Card_Type__c = caseObj.cc_Requested_Card_Type__c;
        }
        if( caseObj.cc_Approved_employment_status__c == null ){
            caseObj.cc_Approved_employment_status__c = caseObj.cc_Employment_Status__c;
        }
        if( caseObj.cc_Approved_Name_on_the_card__c == null ){
            caseObj.cc_Approved_Name_on_the_card__c = caseObj.cc_Name_on_the_Card__c;
        }
        if( caseObj.cc_Approved_Embossing_line_4__c == null ){
            caseObj.cc_Approved_Embossing_line_4__c = caseObj.cc_Embossing_Line_4__c;
        }
        
        //Start : Salary calculation ... 
        if(caseObj.Basic_Salary__c == null){
            caseObj.Basic_Salary__c = 0;
        }
        if(caseObj.Fixed_Allowances__c == null){
            caseObj.Fixed_Allowances__c = 0;
        }
        if(caseObj.Variable_Allowances__c == null){
            caseObj.Variable_Allowances__c = 0;
        }
        if(caseObj.Business_Income__c == null){
            caseObj.Business_Income__c = 0;
        }
        caseObj.cc_Approved_Salary__c=caseObj.Basic_Salary__c + caseObj.Fixed_Allowances__c + caseObj.Variable_Allowances__c + caseObj.Business_Income__c;
        if(caseObj.cc_Approved_Salary__c == 0){
            caseObj.cc_Final_DBR__c = 0;
        }else{
            caseObj.cc_Final_DBR__c = (caseObj.Final_Total_Obligations__c/ caseObj.cc_Approved_Salary__c)*100;
        }
        //end : Salary calculation
        
        if( caseObj.cc_Approved_Balance_Transfer_Card_Provi__c == null ){
            caseObj.cc_Approved_Balance_Transfer_Card_Provi__c = caseObj.cc_Balance_Transfer_Card_Provider__c;
        }
        if( caseObj.cc_Approved_Balance_Transfer_Card_Number__c == null ){
            caseObj.cc_Approved_Balance_Transfer_Card_Number__c = caseObj.cc_Balance_Transfer_Card_Number__c;
            caseObj.sys_Balance_Transfer_Card_Number__c = caseObj.cc_Balance_Transfer_Card_Number__c;
            if(caseObj.sys_Balance_Transfer_Card_Number__c != '' && caseObj.sys_Balance_Transfer_Card_Number__c != null){
                caseObj.cc_First_6_Digit__c = caseObj.sys_Balance_Transfer_Card_Number__c.substring(0,6);
                caseObj.cc_Last_4_Digit__c = caseObj.sys_Balance_Transfer_Card_Number__c.substring(12,16);
            }
        }
        if( caseObj.cc_Approved_Transfer_Type__c == null ){
            caseObj.cc_Approved_Transfer_Type__c = caseObj.cc_Balance_Transfer_Type__c;
        }
        
        return caseObj;
    }
    
    //#CH01 : Start
    public static Case nameScreeningProcess(Case caseObj, String changedField){
        
        String regionName = caseObj.Region_Flag__c;
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }

        caseObj.Last_Api_Call_Status__c = 'Success'; //next will be change if there is any api error
        Supplementary_Card__c objSuppCard = new Supplementary_Card__c(
                                                    Status__c = 'In Progress',
                                                    Primary_Customer__c = caseObj.AccountId,
                                                    Related_Case__c = caseObj.Id,
                                                    Relationship__c = caseObj.sc_Relationship__c,
                                                    Card_Holder_First_Name__c = caseObj.sc_Card_Holder_First_Name__c,
                                                    Card_Holder_Last_Name__c = caseObj.sc_Card_Holder_Last_Name__c,
                                                    Card_Holder_Date_of_Birth__c = caseObj.sc_Card_Holder_Date_of_Birth__c,
                                                    Card_Holder_Email__c = caseObj.sc_Card_Holder_Email_Address__c,
                                                    Card_Holder_Mobile__c = caseObj.sc_Card_Holder_Mobile_No__c,
                                                    Card_Holder_Gender__c = caseObj.sc_Card_Holder_Gender__c,
                                                    Card_Holder_ID_Number__c = caseObj.sc_Card_Holder_ID_Number__c,
                                                    Card_Holder_ID_Expiry_Date__c = caseObj.sc_Card_Holder_ID_Expiry_Date__c,
                                                    Card_Holder_Nationality__c = caseObj.sc_Card_Holder_Nationality__c,
                                                    Embossing_Name__c = caseObj.cc_Embossing_Line_4__c,
                                                    Card_Holder_Name_on_the_Card__c = caseObj.cc_Approved_Name_on_the_card__c,
                                                    Supplementary_Card_PCI_Number__c = caseObj.PrimaryCard__c,
                                                    Supplementary_Card_ID__c = caseObj.CaseNumber
                                                );

        if(caseObj.Supplementary_Cards__r != null && caseObj.Supplementary_Cards__r.size()>0 ){
            objSuppCard.Id = caseObj.Supplementary_Cards__r.get(0).Id;    
        }

        HttpRequest request1 = con.createRequest('POST','/api/v1/compliances/direct', regionName);

        HttpResponse nameScrenResp = callNameScreeningApi( request1, caseObj );

        lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),nameScrenResp.getBody(),
                                                             request1.getEndpoint(),request1.getMethod(),
                                                             caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,nameScrenResp.getStatusCode(), 
                                                             caseObj.Type+' : Calling Name Screening Api', caseObj.Type
                                                            ));

        if(nameScrenResp.getStatusCode() != 200){
            System.debug('The status code returned when calling name screening api was not expected: ' + nameScrenResp.getStatusCode() + ' ' + nameScrenResp.getStatus());
            caseObj.Last_Api_Call_Status__c = 'Failed';
            if(changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c')){
                caseObj.put( changedField , null );
            }
        }else{
            System.debug('Name Screening Api running succefully! ');
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(nameScrenResp.getBody());// meta, data
            Map<String, Object> dataMap = (Map<String, Object>)m.get('data');
            System.debug(dataMap);
            Boolean nameScreening = (Boolean) dataMap.get('nameScreening');
            String screeningResult = String.valueOf(dataMap.get('screeningResult'));
            
            caseObj.sc_NameScreening__c = nameScreening;
            caseObj.sc_ScreeningResult__c = screeningResult;
            
            objSuppCard.sc_NameScreening__c = nameScreening;
            objSuppCard.sc_ScreeningResult__c = screeningResult;

            if(nameScreening){
                System.debug('Name Screening Api equal true ! ');
                caseObj.Sub_Status__c = 'Screening';
                caseObj.Awaiting_Customer_Feedback__c = false;
                caseObj.OwnerId = System.Label.Jordan_Credit_Card_Temp_Queue;
            }else{
                System.debug('Name Screening Api equal false ! ');
                caseObj.Awaiting_Customer_Feedback__c = false;
                caseObj.OwnerId = System.Label.Jordan_Credit_Card_Admin_Queue;
                objSuppCard.Status__c = 'Active';
            }

            lstSuppCard.add(objSuppCard);
        }

        return caseObj;
    }

    public static HttpResponse callNameScreeningApi(HttpRequest request, Case caseObj){
        
        String fullName = caseObj.sc_Name_Screening_First_Name__c + ' ' + caseObj.sc_Name_Screening_Second_Name__c + ' ' + caseObj.sc_Name_Screening_Last_Name__c ;
        
        String body = '{"idNumber":'+ SM001_ApiCalls.stringApiFormat(caseObj.sc_Card_Holder_Jordan_ID_Number__c) +
                        ',"idExpiryDate":' + SM001_ApiCalls.stringApiFormat(SM001_ApiCalls.dateToApiDateFormat(caseObj.sc_Card_Holder_ID_Expiry_Date__c)) +
                        ',"fullName":' + SM001_ApiCalls.stringApiFormat(fullName) +
                        ',"dateOfBirth":' + SM001_ApiCalls.stringApiFormat(SM001_ApiCalls.dateToApiDateFormat(caseObj.sc_Card_Holder_Date_of_Birth__c)) +
                        ',"nationality":' + SM001_ApiCalls.stringApiFormat(caseObj.sc_Card_Holder_Nationality__c) +
                        ',"gender":'+ SM001_ApiCalls.stringApiFormat(caseObj.sc_Card_Holder_Gender__c)+
                    '}';

        request.setBody(body);
        request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', caseObj.sc_Card_Holder_Jordan_ID_Number__c);
        request.setTimeout(60000);

        system.debug('---> Request body --> '+request.getBody());
        system.debug('---> Request getEndpoint() --> '+request.getEndpoint() );

        HttpResponse response = EM001_ApiCalls.callNameScreeningApi(request,null);
        /* MCK001_ApiCalls mck = new MCK001_ApiCalls();
        MCK001_ApiCalls.nameScreening = false;
        HttpResponse response = mck.callNameScreeningApi( request, 200 );//fake aniss to be removed */
        System.debug(response.getBody());

        return response;
    }

    public static Case callApiToCreateSupplementaryCardInVPlus(Case caseObj,String changedField){
        String regionName = caseObj.Region_Flag__c;
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }
        caseObj.Awaiting_Customer_Feedback__c = false;
        HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request', regionName);

         //#CH03 : start
         if(caseObj.Account.x_canary__pc != null){
             request2.setHeader('x-canary', caseObj.Account.x_canary__pc);
         }
         //#CH03 : end

        HttpResponse suppCardResp = SM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus( request2, caseObj );
        //HttpResponse suppCardResp = new MCK001_ApiCalls().callApiToCreateSupplementaryCardInVPlus( request2, 200 );//fake aniss to be removed

        lstSA.add(SM001_ApiCalls.setSystemAction( request2.getBody(),suppCardResp.getBody(),
                                                     request2.getEndpoint(),request2.getMethod(),
                                                     caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,suppCardResp.getStatusCode(), 
                                                     caseObj.Type+' : call api to create supplementary card in V+ ', caseObj.Type
                                                    ));
        if (suppCardResp.getStatusCode() != 200) 
        {
           System.debug('The status code returned was not expected: ' + suppCardResp.getStatusCode() + ' ' + suppCardResp.getStatus());
           caseObj.Last_Api_Call_Status__c = 'Failed';
           //caseObj.Approve_Card_Using_API__c = true;//to add in dev with button
           caseObj.OwnerId = System.Label.Jordan_Supplementary_Maker_Queue;
           caseObj.Sub_Status__c = 'In-Progress';
           if(changedField != null && !changedField.equalsIgnoreCase('Sub_Status__c')){
                caseObj.put( changedField , null );
           }
        } 
        else 
        {
            System.debug('Response in SUPP - Prescreener Accepts - : '+suppCardResp.getBody());
            caseObj.Status = 'Closed';
            caseObj.Sub_Status__c = 'Approved';
            caseObj.cc_CRM_Stage__c = 'APPROVED';
            caseObj.cc_Application_Stages__c = 'Completed';
            caseObj.sc_ScreeningResult__c = 'PASS';
            
            if(caseObj.Supplementary_Cards__r != null && caseObj.Supplementary_Cards__r.size()>0 ){
                Supplementary_Card__c objSuppCard = caseObj.Supplementary_Cards__r.get(0);
                objSuppCard.Status__c = 'Active';
                objSuppCard.sc_ScreeningResult__c = 'PASS';
                lstSuppCard.add(objSuppCard);
            }
        }

        return caseObj;
    }
    
    public static String getCardProductConfigurationId_SupplementaryCase(Case objCase){
        String cardProductConfigurationIdString;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = objCase.Region_Flag__c;    
        if(objCase.Case_Model__c == 'alburaq'){    
            regionName += '_alburaq';  
        }  
        request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards , regionName );  
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        
        HttpResponse response;
        if( test.isRunningTest() ){
            response = new HttpResponse();
            String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[],"pendingCards":[],"cardOptions":[{"cardProductConfigurationId":24,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila blue","cmsCardProductId":"002","cmsCardProductType":"01","order":0,"productStatus":"ORDER","campaign":[],"cardConfigurations":[{"configCode":"SUPPLEMENTARY_CARD_FEES","configValue":"0"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BAHRAIN","configValue":"0"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BH","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_TYPE","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CODE","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CONFIG_ID","configValue":"0"},{"configCode":"SUPPLEMENTARY_MIN_AGE","configValue":"0"},{"configCode":"SUPPLEMENTARY_MAX_AGE","configValue":"0"},{"configCode":"SUPPLEMENTARY_ID_SUPPORTED_COUNTRIES","configValue":"0"},{"configCode":"SUPPLEMENTARY_EXPIRY_DATE","configValue":"0"},{"configCode":"SUPPLEMENTARY_VALIDATE_PRIMARY_NATIONAL_ID","configValue":"0"},{"configCode":"MINIMUM_CREDIT_LIMIT_SECURED","configValue":"1500"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_البحرين","configValue":"0"},{"configCode":"MINIMUM_LIMIT","configValue":"1500"},{"configCode":"MAXIMUM_LIMIT","configValue":"50000"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed,Student,Business owner,Retired,Unemployed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"JOD"},{"configCode":"ANNUAL_RATE","configValue":"1.75"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"4"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_MAX_AMT","configValue":"105"},{"configCode":"ANNUAL_RATE","configValue":"1.75"},{"configCode":"MINIMUM_CREDIT_LIMIT_UNSECURED","configValue":"1500"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"200"},{"configCode":"MINIMUM_MONTHLY_INCOME_ILA","configValue":"200"},{"configCode":"MINIMUM_MONTHLY_INCOME_TO_ILA","configValue":"200"},{"configCode":"MINIMUM_LIMIT","configValue":"1500"},{"configCode":"MAXIMUM_LIMIT","configValue":"25000"},{"configCode":"HAS_DOCUMENTS","configValue":"TRUE"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed,Retired,Business Owner"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"JOD"},{"configCode":"MINIMUM_CREDIT_LIMIT","configValue":"1500"},{"configCode":"CREDIT_LIMIT_MULTIPLAYER","configValue":"1.2"},{"configCode":"CARD_REPLACEMENT_VAT","configValue":"0"},{"configCode":"CASHBACK_ENABLED","configValue":"TRUE"},{"configCode":"SHOW_ANNUAL_FEES_AMOUNT","configValue":"FALSE"},{"configCode":"SHOW_ANNUAL_RATE","configValue":"FALSE"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"0"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"0"},{"configCode":"DEFAULT_REQUESTED_CREDIT_LIMIT","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"4"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"0"},{"configCode":"CASH_ADVANCE_FEE_MAX_AMT","configValue":"150"},{"configCode":"CARD_REPLACEMENT_FEES","configValue":"10"},{"configCode":"CMS_FEE_CONFIGURATION","configValue":"08"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"},{"configCode":"SUPPLEMENTARY_CARD_VAT","configValue":"0"}],"cardNature":["unsecured"],"cardTypeConfigurations":[]}]}}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
        }else{
            response = http.send(request);
        }
        
        
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     'Calling GET credit card supplementary Api After Insert', objCase.Type
                                                    ));
        }
        else
        {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            List<Object> m2 = (List<Object>)m1.get('currentCards');
            List<Map<String, Object>> a = new List<Map<String, Object>> ();
            for(Object obj : m2)
            {
                a.add((Map<String, Object>)obj);
                {
                    system.debug('---->> OBJ Iterations after insert --> '+obj);
                }
            }
            
            for(Map<String, Object> map1 : a)
            {
                if(map1.get('productMappingCode')== objCase.cc_Requested_Card_Type__c && ((Boolean)map1.get('isPrimary')) == true )
                {
                    cardProductConfigurationIdString = String.valueOf(map1.get('cardProductionConfigurationId'));
                    system.debug('---> FINALL cardProductionConfigurationId --> '+cardProductConfigurationIdString);
                }
            }
            
            //Store Sucess Response
            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                     request.getEndpoint(),request.getMethod(),
                                                     objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                                                     'Calling GET credit card Api to store supp cardProductConfigurationId : ==> '+cardProductConfigurationIdString , objCase.Type
                                                    ));
        }
        return cardProductConfigurationIdString;
    }

    //#CH01 : End


    public class RequestCreditCard {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        
        @InvocableVariable(label='changedField' description='changedField apiName')
        public String changedField;
    }
    
}