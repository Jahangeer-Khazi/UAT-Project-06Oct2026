/**
 * @author Aniss Mbarki
 * @date Création 01/07/2022
 * @date Modification
 * @description : to hundel api calls for the Prepaid Card Requirement 
 *              #CH01 : 17/02/2023 :  CRM23-171 (pi-2063): setTimeOut before calling Api
 *              #CH02 : #Imane Tsioucha# #22-02-2024# add x-canary header
 */
public without sharing class SM04_PrepaidCardApiHandler {

    private static String CLASS_NAME = SM04_PrepaidCardApiHandler.class.getName();

    @InvocableMethod(label='Update Prepaid Card Request Status API' description='call Update Credit Card Request Status API each time the sub-status is changed' callout=true )
    public static List<String> updateCreditCardReqApiFromFlow(List<RequestPrepaidCard> reqPrepCards){

        RequestPrepaidCard reqPreCard = reqPrepCards.get(0);
        Map<String,String> details = new Map<String,String>();
        details.put('makerResult',reqPreCard.makerResult);
        details.put('subStatus',reqPreCard.subStatus);
        details.put('qaResult',reqPreCard.qaResult);

        try{
            //call future method
            updateCreditCardReqApiFutureMeth(new Set<Id>{reqPreCard.caseId},details);

        }catch(Exception e){
            Case caseObj = [SELECT Id,Customer_CIF__c,accountId FROM Case WHERE Id =: reqPreCard.caseId];
            caseObj.Last_Api_Call_Status__c = 'Failed';
            update caseObj;
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                null,null,
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                'please check : '+CLASS_NAME+'.updateCreditCardReqApiFromFlow()', 'Prepaid Credit Card'
                                            );
        }

        List<String> strLst = new List<String>();
        for(RequestPrepaidCard qst : reqPrepCards){
            strLst.add(qst.caseId);
        }
        return strLst;
    } 

    @future(callout=true)
    public static void updateCreditCardReqApiFutureMeth(Set<Id> caseIds , Map<String,String> details){
        
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Prepaid_CreditCard__c> lstpreCards = new List<Prepaid_CreditCard__c>();
        ApiConnection con = new ApiConnection();
        
        
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            //CH02 : add Account.x_canary__pc
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc,(SELECT Id FROM Prepaid_Credit_Cards__r) FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        String qaResult = details.get('qaResult');
        String makerResult = details.get('makerResult');
        String subStatus = details.get('subStatus');
        Map<Case,String> mapEmailPerCase = new Map<Case,String>();

        //#CH01 : add delay of 2 seconds before calling APIS
        Long endT = System.Now().getTime()+2000;
        While(System.Now().getTime() < endT){
        }
        //#CH01
        
        for(Case caseObj : cases){
            try {
                String regionName = caseObj.Region_Flag__c;
                if (caseObj.Case_Model__c == 'alburaq') {
                    regionName += '_alburaq';
                }

                HttpRequest request = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
                if(caseObj.Account.x_canary__pc != null){
                    request.setHeader('x-canary', caseObj.Account.x_canary__pc); //CH02
                }
                request.setTimeout(60000);
                HttpResponse response;
                HttpResponse responseTwo;
                if (test.isRunningTest()) {
                    //fake response 
                    response = new HttpResponse();
                    String body = '{    "meta": {        "code":"CCRD-1500",        "message": "Credit card request status has been updated successfully"    },   "data":{            "applicationReferenceNumber":"",            "primaryMaskedCardNumber":"",    		"primaryPciNumber":"",			"supplementary1MaskedCardNumber":"",            "supplementary1PciNumber":"",            "supplementary2MaskedCardNumber":"",            "supplementary2PciNumber":"",            "holdAmount" : 3.30,            "holdAccount" : "IBN84598878778",            "holdAccountBalance" : 0.0,            "holdReferenceNumber" : "123596288"	}}';
                    response.setStatus('OK');    
                    response.setStatusCode(200);
                    response.setBody(body);
                    response.setHeader('Content-Type', 'application/json');
                }

                if(qaResult != null && qaResult != ''){
                    caseObj.ppc_QA_Result_Date_Time__c = System.now();
                    if(qaResult == 'Pending Documents'){
                        caseObj.Sub_Status__c = 'Pending Documents';
                        caseObj.ppc_Send_notification_dateTime__c = System.now();
                        caseObj.Awaiting_Customer_Feedback__c = true;
                        caseObj.OwnerId = System.Label.Prepaid_Temp_Queue;
                        mapEmailPerCase.put(caseObj,'CC_PREPAID_DOCS');
                        System.debug('qaResult == Pending Documents');
                        caseObj.Last_Api_Call_Status__c = 'Success';
                        response = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request,caseObj,'PENDING');

                    }else if(qaResult == 'Decline') {
                        caseObj.Sub_Status__c = 'Declined';
                        caseObj.OwnerId = System.Label.Prepaid_Temp_Queue;
                        caseObj.Status = 'Closed';
                        caseObj.Last_Api_Call_Status__c = 'Success';
                        response = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request,caseObj,'DECLINED');

                    }else if(qaResult == 'Accept') {

                        response = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request,caseObj,'APPROVED');

                        if(response.getStatusCode() != 200){                
                            System.debug('qa Results The status code returned when calling Update Credit Card Status api was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            caseObj.Last_Api_Call_Status__c = 'Failed';
                            caseObj.Sub_Status__c = 'Incomplete';
                            caseObj.OwnerId = System.Label.Prepaid_Maker_Queue;
                            caseObj.ppc_QA_Result__c = null;
                            caseObj.ppc_QA_Result_Date_Time__c = null;

                            lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                request.getEndpoint(),request.getMethod(),
                                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                'Calling Credit Card Update Status Api After qa Results changed to Accept', 'Prepaid Credit Card'
                                            ));

                        }else{
                            caseObj.Last_Api_Call_Status__c = 'Success';
                            if(caseObj.Prepaid_Credit_Cards__r != null && caseObj.Prepaid_Credit_Cards__r.size()>0){
                                Prepaid_CreditCard__c objPrepCardExist = caseObj.Prepaid_Credit_Cards__r.get(0); 
                                objPrepCardExist.Status__c = 'Active';
                                lstpreCards.add(objPrepCardExist);
                            }
                            caseObj.OwnerId = System.Label.Prepaid_Temp_Queue;
                            caseObj.Sub_Status__c = 'Approved';
                            caseObj.Status = 'Closed';
                            caseObj.Awaiting_Customer_Feedback__c = false;
                        }
                    }

                }else{
                    if( !test.isRunningTest() ){
                        response = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request,caseObj,subStatus);
                        //responseTwo = SM001_ApiCalls.updateCreditCardApi(caseObj.Id);
                    }
                    system.debug('---> Responce New --> '+response.getBody());
                    if(response.getStatusCode() != 200){
                        System.debug('Invalid Update Prepaid Card Request Status API');
                        caseObj.Last_Api_Call_Status__c = 'Failed';
                        caseObj.OwnerId = System.Label.Prepaid_Maker_Queue;
                        if(makerResult != null && makerResult != ''){
                            caseObj.cc_Maker__c = null;
                            caseObj.cc_Maker_Result_Date_Time__c = null;
                        }
                        lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                        'Prepaid Card Request Status API', 'Prepaid Credit Card'
                                                    ));
                    }
                    else{
                        System.debug('Update Prepaid Card Request Status API Getting Success Status Code from API');
                        caseObj.Last_Api_Call_Status__c = 'Success';
                        
                        Map<String, Object> m10 = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                        Map<String, Object> m11 = (Map<String, Object>)m10.get('data');//currentCards,pendingCards,cardOptions
                        if(caseObj.ppc_HoldAccount__c == null){
                            caseObj.ppc_HoldAccount__c =  String.valueOf(m11.get('holdAccount'));
                        }
                        if(caseObj.ccol_Hold_Amount__c == null){
                            caseObj.ccol_Hold_Amount__c = (Decimal)m11.get('holdAmount');
                        }
                        if(caseObj.ccol_Hold_Reference_Number__c == null){
                            caseObj.ccol_Hold_Reference_Number__c = String.valueOf(m11.get('holdReferenceNumber'));
                        }
        
                        //toDo : logic to separate function
                        if(makerResult != null && makerResult != ''){
                            caseObj.cc_Maker_Result_Date_Time__c = System.now();
                            if(makerResult == 'Pending Documents'){
                                caseObj.Sub_Status__c = 'Pending Documents';
                                caseObj.ppc_Send_notification_dateTime__c = System.now();
                                caseObj.Awaiting_Customer_Feedback__c = true;
                                caseObj.OwnerId = System.Label.Prepaid_Temp_Queue;
                                mapEmailPerCase.put(caseObj,'CC_PREPAID_DOCS');
                                System.debug('makerResult == Pending Documents ==> Process Done');
        
                            }else if(makerResult == 'Decline') {
                                caseObj.Sub_Status__c = 'Declined';
                                caseObj.Status = 'Closed';
                            }else if(makerResult == 'Cancelled by Customer') {
                                caseObj.Sub_Status__c = 'Cancelled';
                                caseObj.Status = 'Closed';
                            }else if(makerResult == 'Accept'){
                                
                                Prepaid_CreditCard__c objPrepCard = new Prepaid_CreditCard__c(
                                                                    Status__c = 'In Progress',
                                                                    Applicant__c = caseObj.AccountId,
                                                                    Related_Case__c = caseObj.Id,
                                                                    Relationship__c = caseObj.sc_Relationship__c,
                                                                    Card_Holder_First_Name__c = caseObj.sc_Card_Holder_First_Name__c,
                                                                    Card_Holder_Last_Name__c = caseObj.sc_Card_Holder_Last_Name__c,
                                                                    Card_Holder_Date_of_Birth__c = caseObj.sc_Card_Holder_Date_of_Birth__c,
                                                                    Card_Holder_Email__c = caseObj.ppc_OTP_EmailAddress__c,
                                                                    Card_Holder_Mobile_Number__c = caseObj.ppc_OTP_MobileNo__c,
                                                                    Card_Holder_Gender__c = caseObj.sc_Card_Holder_Gender__c,
                                                                    Card_Holder_ID_Number__c = caseObj.sc_Card_Holder_ID_Number__c,
                                                                    Card_Holder_ID_Expiry_Date__c = caseObj.sc_Card_Holder_ID_Expiry_Date__c,
                                                                    Card_Holder_Nationality__c = caseObj.sc_Card_Holder_Nationality__c,
                                                                    Embossing_Name__c = caseObj.cc_Name_on_the_Card__c, //toCheck
                                                                    Card_Holder_Name_on_the_Card__c = caseObj.ppc_Approved_Name_On_The_Card__c,
                                                                    Prepaid_Credit_Card_Id__c = caseObj.CaseNumber
                                                                );
    
                                if(caseObj.Prepaid_Credit_Cards__r != null && caseObj.Prepaid_Credit_Cards__r.size()>0){
                                    Prepaid_CreditCard__c objPrepCardExist = caseObj.Prepaid_Credit_Cards__r.get(0); 
                                    objPrepCard.Id = objPrepCardExist.Id;
                                }
                                
                                if (caseObj.sc_Relationship__c == 'Myself') {
    
                                    //call prepaid credit card APi with status "APPROVED" in order to collect fees and create Prepaid Credit Card in V+
                                    HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
                                    if(caseObj.Account.x_canary__pc != null){
                                        request2.setHeader('x-canary', caseObj.Account.x_canary__pc); //CH02
                                    }
                                    request2.setTimeout(60000);
    
                                    HttpResponse response2;
                                    if( !test.isRunningTest() ){
                                        response2 = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request2,caseObj,'APPROVED');
                                    }
                                    else{
                                        //fake Response
                                        response2 = response;
                                    }
                                    
                                    
                                    if(response2.getStatusCode() != 200){                
                                        System.debug('The status code returned when calling Update Credit Card Status api was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
                                        caseObj.Last_Api_Call_Status__c = 'Failed';
                                        caseObj.Sub_Status__c = 'Incomplete';
                                        caseObj.OwnerId = System.Label.Prepaid_Maker_Queue;
    
                                        lstSA.add(SM001_ApiCalls.setSystemAction( request2.getBody(),response2.getBody(),
                                                            request2.getEndpoint(),request2.getMethod(),
                                                            caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response2.getStatusCode(), 
                                                            'Calling Credit Card Update Status Api', 'Prepaid Credit Card'
                                                        ));
    
                                    }else{
    
                                        objPrepCard.Status__c = 'Active';
                                        caseObj.Sub_Status__c = 'Approved';
                                        caseObj.Status = 'Closed';
                                        caseObj.Awaiting_Customer_Feedback__c = false;
                                        lstpreCards.add(objPrepCard);
                                    }
                                }else{
                                    caseObj.Sub_Status__c = 'In-Progress';
                                    caseObj.OwnerId = System.Label.Prepaid_Temp_Queue; //toCheck : use metadata??
                                    HttpRequest request1 = con.createRequest('POST','/api/v1/compliances/direct', regionName);
                                    request1.setTimeout(100000);
                                    HttpResponse nameScrenResp = SM001_ApiCalls.callNameScreeningApi( request1, caseObj );
                                    
                                    //fake response
                                    /* 
                                        nameScrenResp = new HttpResponse();
                                        String body1 = '{'+
                                                '"data":'+
                                                    '{'+
                                                        '"riskRating":"LOW",'+
                                                        '"screeningResult":["PEPHIT"],'+
                                                        '"eddDecision":"PASS",'+
                                                        '"nameScreening": false'+
                                                    '},'+
                                                '"meta":'+
                                                    '{'+
                                                        '"code":"COMP-1000",'+
                                                        '"message":"Name screening and risk classification gets verified successfully."'+
                                                    '}'+
                                            '}';
                
                                        nameScrenResp.setStatus('OK');
                                        nameScrenResp.setStatusCode(200);
                                        nameScrenResp.setBody(body1); 
                                    */
        
            
                                    if(nameScrenResp.getStatusCode() != 200){                
                                        System.debug('The status code returned when calling name screening api was not expected: ' + nameScrenResp.getStatusCode() + ' ' + nameScrenResp.getStatus());
                                        caseObj.Last_Api_Call_Status__c = 'Failed';
                                        caseObj.OwnerId = System.Label.Prepaid_Maker_Queue;
                                        lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),nameScrenResp.getBody(),
                                                            request1.getEndpoint(),request1.getMethod(),
                                                            caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,nameScrenResp.getStatusCode(), 
                                                            'Calling Name Screening Api', 'Prepaid Credit Card'
                                                        ));
            
                                    }else{
                                        System.debug('Name Screening Api running succefully! ');
                                        //check the value of "nameScreening"
                                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(nameScrenResp.getBody());// meta, data
                                        Map<String, Object> dataMap = (Map<String, Object>)m.get('data');
                                        System.debug(dataMap);
                                        Boolean nameScreening = (Boolean) dataMap.get('nameScreening');
                                        String screeningResult = String.valueOf(dataMap.get('screeningResult'));
                                        
                                        caseObj.sc_NameScreening__c = nameScreening;
                                        caseObj.sc_ScreeningResult__c = screeningResult;
                                        
                                        objPrepCard.Name_Screening__c = nameScreening;
                                        objPrepCard.Screening_Result__c = screeningResult;
            
                                        if(nameScreening){
                                            System.debug('Name Screening Api equal true ! ');
                                            caseObj.Sub_Status__c = 'Screening';
                                            caseObj.Awaiting_Customer_Feedback__c = false;
                                            caseObj.OwnerId = System.Label.Prepaid_Temp_Queue;
                                        }else{
                                            System.debug('Name Screening Api equal false ! ');
                                            caseObj.Awaiting_Customer_Feedback__c = false;
                                            
                                            String Prepaid_stp = System.Label.Prepaid_stp ;
                                            if( test.isRunningTest() ){Prepaid_stp = 'on';}
    
                                            if( Prepaid_stp != null && Prepaid_stp.equalsIgnoreCase('off')){
                                                caseObj.OwnerId = System.Label.Prepaid_QA_Queue;
                                            }else{
                                                //call prepaid credit card APi with status "APPROVED" in order to collect fees and create Prepaid Credit Card in V+
                                                HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
                                                if( caseObj.Account.x_canary__pc != null ){
                                                    request2.setHeader('x-canary', caseObj.Account.x_canary__pc); //CH02
                                                }
                                                request2.setTimeout(60000);
            
                                                HttpResponse response2;
                                                if( !test.isRunningTest() ){
                                                    response2 = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request2,caseObj,'APPROVED');
                                                }
                                                else{
                                                    //fake Response
                                                    response2 = response;
                                                }
                                                
                                                
                                                if(response2.getStatusCode() != 200){                
                                                    System.debug('The status code returned when calling Update Credit Card Status api was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
                                                    caseObj.Last_Api_Call_Status__c = 'Failed';
                                                    caseObj.Sub_Status__c = 'Incomplete';
                                                    caseObj.OwnerId = System.Label.Prepaid_Maker_Queue;
        
                                                    lstSA.add(SM001_ApiCalls.setSystemAction( request2.getBody(),response2.getBody(),
                                                                        request2.getEndpoint(),request2.getMethod(),
                                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response2.getStatusCode(), 
                                                                        'Calling Credit Card Update Status Api', 'Prepaid Credit Card'
                                                                    ));
                
                                                }else{
                
                                                    objPrepCard.Status__c = 'Active';
                                                    caseObj.Sub_Status__c = 'Approved';
                                                    caseObj.Status = 'Closed';
                                                }
                                            }
                                        }
            
                                        lstpreCards.add(objPrepCard);
                                    }
                                }
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
                                                'Prepaid Card updateCreditCardReqApiFutureMeth (unhandled error)', 'Prepaid Credit Card'
                                            ));
                caseObj.Last_Api_Call_Status__c = 'Failed';             
            }


        }
        
        if(cases != null && cases.size()>0){
            update cases;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(lstpreCards != null && lstpreCards.size()>0){
            upsert lstpreCards;
        }

        //send emails
        for( Case cs : mapEmailPerCase.keySet() ){
            sendEmailAlert( cs , mapEmailPerCase.get(cs) );
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

    public class RequestPrepaidCard {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public String caseId;

        @InvocableVariable(label='Maker Result' description='Maker Result of the Case')
        public String makerResult;

        @InvocableVariable(label='Sub Status' description='Sub Status of the Case')
        public String subStatus;

        @InvocableVariable(label='QA Results' description='QA Results of the Case')
        public String qaResult;
    }

}