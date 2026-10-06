/**
 * @description       : This is the batch class responsable of checking alert status using api Get Compliance Case Status API  
 *                      By fetch all Prepaid credit card cases with following conditions (status == open & sub-status == screening)
 * @author            : ANISS MBARKI
 * @creation date     : 04-07-2022
 * History Changes :   #CH01 : #Imane Tsioucha# #22-02-2024# add x-canary header
**/
global without sharing class APB06_CheckPrepaidCardCases implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id prepaidCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ppc_Prepaid_Card').getRecordTypeId();
        //to add Case_Model__c for alburaq project
        return Database.getQueryLocator('SELECT Id,Status,Sub_Status__c,cc_Name_on_the_Card__c,sc_Card_Holder_Mobile_No__c,sc_Card_Holder_Email_Address__c,ppc_CardDesign__c,Card_Product_Configuration_Id__c,'+
                                            'sc_Relationship__c,sc_Card_Holder_ID_Number__c,sc_Card_Holder_ID_Expiry_Date__c,sc_Card_Holder_Last_Name__c,sc_Jumio_Scan_Reference_Number__c,'+
                                            'sc_Card_Holder_First_Name__c,sc_Card_Holder_Date_of_Birth__c,Region_Flag__c,ppc_OTP_MobileNo__c,ppc_OTP_EmailAddress__c,Card_Type__c,ppc_ParticipantName__c,'+
                                            'sc_Card_Holder_Nationality__c,sc_Card_Holder_Gender__c,Account.PersonEmail,Account.CIF__pc,Account.x_canary__pc,Customer_CIF__c,accountId,ccol_Hold_Amount__c,'+
                                            'ppc_Approved_Name_On_The_Card__c,ppc_Card_Holder_Age__c,ppc_Adult_Issuance_Fee__c,ppc_Adult_Issuance_VAT__c,ppc_Minor_Issuance_Fee__c,ppc_Minor_Issuance_VAT__c,'+
                                            '(SELECT Id,Status__c FROM Prepaid_Credit_Cards__r WHERE Status__c = \'In Progress\') '+
                                        'FROM Case WHERE RecordTypeId = :prepaidCardRecordId AND Status != \'Closed\' AND Sub_Status__c = \'Screening\'');
    }

    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        System.debug('execute**********************');
        List<Prepaid_CreditCard__c> prepaiCardToUpdate = new List<Prepaid_CreditCard__c>();
        List<Case> caseToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        ApiConnection con = new ApiConnection();

        for(Case objCase : caseList){
            
            String regionName = objCase.Region_Flag__c;
            /* if (objCase.Case_Model__c == 'alburaq') {
                regionName += '_alburaq';
            } */

            HttpRequest request1 = con.createRequest('GET','/api/v1/compliances',regionName);
            request1.setTimeout(60000);

            HttpResponse compilanceResp = SM001_ApiCalls.getComplianceCaseStatusApi( request1, objCase );
            System.debug('Start -- Case Id : ' + objCase);
            if(compilanceResp.getStatusCode() != 200){
                objCase.OwnerId = System.Label.Prepaid_Maker_Queue;
                objCase.Last_Api_Call_Status__c = 'Failed';
                System.debug('The status code returned when calling get Compliance Case Status Api was not expected: ' + compilanceResp.getStatusCode() + ' ' + compilanceResp.getStatus());
                lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),compilanceResp.getBody(),
                                                request1.getEndpoint(),'GET',
                                                objCase.id,objCase.Customer_CIF__c,objCase.accountId,compilanceResp.getStatusCode(), 
                                                'Prepaid Credit Card Calling get Compliance Case Status Api From the batch', 'Prepaid Credit Card'
                                            ));    
            }else{
                //check the value of "decision"
                System.debug('getComplianceCaseStatusApi Successfully !');
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(compilanceResp.getBody());// meta, data
                Map<String, Object> dataMap = (Map<String, Object>)m.get('data');
                String screeningResult = String.valueOf(dataMap.get('screeningResults'));
                String decision = String.valueOf(dataMap.get('decision'));
                System.debug(dataMap);
                if(decision == 'PASS' || decision == 'EDD' ){
                    objCase.sc_NameScreening__c = false;
                    objCase.sc_ScreeningResult__c = 'PASS';

                    //trigger api to create supplementary card in V+ 
                    HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
                    if(objCase.Account.x_canary__pc != null){
                        request2.setHeader('x-canary', objCase.Account.x_canary__pc);//CH01
                    }
                    request2.setTimeout(60000);
                    //call the api using SM001 to fill the request body 
                    HttpResponse prepaidCardResp = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request2,objCase,'APPROVED');

                    if (prepaidCardResp.getStatusCode() != 200) 
                    {
                        objCase.Sub_Status__c = 'Incomplete';
                        objCase.Last_Api_Call_Status__c = 'Failed';
                        objCase.OwnerId = System.Label.Prepaid_Maker_Queue;//toCheck : ...
                        System.debug('The status code returned was not expected: ' + prepaidCardResp.getStatusCode() + ' ' + prepaidCardResp.getStatus());
                        lstSA.add(SM001_ApiCalls.setSystemAction(request2.getBody(),prepaidCardResp.getBody(),
                                                    request2.getEndpoint(),request2.getMethod(),
                                                    objCase.id,objCase.Customer_CIF__c,objCase.accountId,prepaidCardResp.getStatusCode(),
                                                    'Prepaid Credit Card  -- call api to create Prepaid card in V+ With Approved status -- error from the batch', 'Credit Card'));
                    } 
                    else 
                    {
                        System.debug('Response APi in V+ : '+prepaidCardResp.getBody());

                        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(prepaidCardResp.getBody());// meta, data
                        Map<String, Object> dataMap1 = (Map<String, Object>)m1.get('data');
                        objCase.Sub_Status__c = 'Approved';
                        objCase.Status = 'Closed';
                        objCase.cc_CRM_Stage__c = 'APPROVED';
                        objCase.cc_Application_Stages__c = 'Completed';
                        
                        //toCheck : ... 
                        if(objCase.Prepaid_Credit_Cards__r != null && objCase.Prepaid_Credit_Cards__r.size()>0 ){
                            Prepaid_CreditCard__c objPrepCard = objCase.Prepaid_Credit_Cards__r.get(0); 
                            objPrepCard.Status__c = 'Active';
                            objPrepCard.Name_Screening__c = false;
                            objPrepCard.Screening_Result__c = 'PASS';
                            objPrepCard.Compliance_Status_Api_Response__c = compilanceResp.getBody();

                            prepaiCardToUpdate.add(objPrepCard);
                        }                        
                    }
                    
                }else if(decision == 'REJECT') {
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Declined';
                    objCase.cc_CRM_Stage__c = 'DECLINED';
                    objCase.Awaiting_Customer_Feedback__c = false;

                    if(objCase.Prepaid_Credit_Cards__r != null && objCase.Prepaid_Credit_Cards__r.size()>0 ){
                        Prepaid_CreditCard__c objPrepCard = objCase.Prepaid_Credit_Cards__r.get(0); 
                        objPrepCard.Status__c = 'Decline';
                        objPrepCard.Name_Screening__c = true;
                        objPrepCard.Screening_Result__c = screeningResult;
                        objPrepCard.Compliance_Status_Api_Response__c = compilanceResp.getBody();

                        prepaiCardToUpdate.add(objPrepCard);
                    }

                    //Call Api here in decline....
                    HttpRequest request4 = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
                    if(objCase.Account.x_canary__pc != null){
                        request4.setHeader('x-canary', objCase.Account.x_canary__pc);//CH01
                    }
                    request4.setTimeout(60000);
                    HttpResponse response4 = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request4,objCase,'DECLINED');
                    if (response4.getStatusCode() != 200) 
                    {
                        objCase.OwnerId = System.Label.Prepaid_Maker_Queue;
                        objCase.Last_Api_Call_Status__c = 'Failed';
                        System.debug('The status code returned was not expected: ' + response4.getStatusCode() + ' ' + response4.getStatus());
                        lstSA.add(SM001_ApiCalls.setSystemAction(request4.getBody(),response4.getBody(),request4.getEndpoint(),request4.getMethod(),
                                objCase.id,objCase.Customer_CIF__c,objCase.accountId,response4.getStatusCode(), 
                                'Prepaid Credit Card -- call api for Prepaid card in V+ With Decline Status -- error from the batch', 'Prepaid Credit Card'));
                    } 
                    else 
                    {
                        System.debug(response4.getBody());
                    }

                }else{
                    if(objCase.Prepaid_Credit_Cards__r != null && objCase.Prepaid_Credit_Cards__r.size()>0 ){
                        Prepaid_CreditCard__c objPrepCard = objCase.Prepaid_Credit_Cards__r.get(0); 
                        objPrepCard.Compliance_Status_Api_Response__c = compilanceResp.getBody();
                        prepaiCardToUpdate.add(objPrepCard);
                    }
                }

                caseToUpdate.add(objCase);
            }
        }

        if(caseToUpdate != null && caseToUpdate.size()>0){
            update caseToUpdate;
        }
        if(prepaiCardToUpdate != null && prepaiCardToUpdate.size()>0){
            update prepaiCardToUpdate;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }

        //toDo : handle unexpected errors ....
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('APB06_CheckPrepaidCardCases finished !');
    }
}