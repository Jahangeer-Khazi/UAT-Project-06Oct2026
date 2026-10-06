/**
 * @description       : This is the batch class responsable of checking alert status using api Get Compliance Case Status API  
 *                      By fetch all supplementary credit card cases with following conditions (status == open & sub-status == screening)
 * @author            : ANISS MBARKI
 * @creation date     : 07-12-2021
 * History Changes :  
 *                  #CH01 : add api calls after the case is declined
 *                  #CH02 : by Hamza Chaoui 04-07-2022 -- implement alburaq unit changes
 * 					#CH03 : #Jahangeer Mohammed# #09-01-2023 added Logic to Approved Card Using API (NBA-6312)
 *                  #CH04 : by Aniss Mbarki 09-10-2023 -- Jordan Supplementary Card Requirement
 *                  #CH05 : by Imane Tssioucha -- add x_canary__pc logic
**/
global with sharing class APB001_CheckSupplementaryCardCases implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id suppCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId();
        //#CH02 : add Case_Model__c into soql query
        //CH03: Start #Added Field Approve_Card_Using_API__c in SOQL
        //CH05 : add this field on the soql Account.x_canary__pc
        return Database.getQueryLocator('SELECT Id,Status,Approve_Card_Using_API__c,Sub_Status__c,PrimaryCardProductConfigurationId__c,PrimaryCard__c,cc_Name_on_the_Card__c,sc_Card_Holder_Mobile_No__c,sc_Card_Holder_Email_Address__c,'+
                                            'sc_Relationship__c,sc_Card_Holder_ID_Number__c,sc_Card_Holder_ID_Expiry_Date__c,sc_Card_Holder_Last_Name__c,sc_Card_Holder_First_Name__c,sc_Card_Holder_Date_of_Birth__c,'+
                                            'sc_Card_Holder_Nationality__c,sc_Card_Holder_Gender__c,Account.PersonEmail,Account.CIF__pc,Account.x_canary__pc,Customer_CIF__c,accountId,Case_Model__c,Region_Flag__c,'+
                                            '(SELECT Id,Status__c FROM Supplementary_Cards__r WHERE Status__c = \'In Progress\') '+
                                            'FROM Case WHERE RecordTypeId = :suppCardRecordId AND Status != \'Closed\' AND Sub_Status__c = \'Screening\'');
       //CH03: END
    }

    global void execute(Database.BatchableContext bc, List<Case> caseList) {
        System.debug('execute**********************');
        List<Supplementary_Card__c> suppToUpdate = new List<Supplementary_Card__c>();
        List<Case> caseToUpdate = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        ApiConnection con = new ApiConnection();

      
        for(Case objCase : caseList){

            //#CH02 : Start
            String regionName = objCase.Region_Flag__c;
            if(objCase.Case_Model__c == 'alburaq'){
                regionName += '_alburaq'; 
            }
            HttpRequest request1 = con.createRequest('GET','/api/v1/compliances',regionName);
            //#CH02 : End

            HttpResponse compilanceResp = SM001_ApiCalls.getComplianceCaseStatusApi( request1, objCase );
            System.debug('Start -- Case Id : ' + objCase);
            if(compilanceResp.getStatusCode() != 200){
                System.debug('The status code returned when calling get Compliance Case Status Api was not expected: ' + compilanceResp.getStatusCode() + ' ' + compilanceResp.getStatus());
                lstSA.add(SM001_ApiCalls.setSystemAction( request1.getBody(),compilanceResp.getBody(),
                                                request1.getEndpoint(),'GET',
                                                objCase.id,objCase.Customer_CIF__c,objCase.accountId,compilanceResp.getStatusCode(), 
                                                'Credit Card Supplemntary Application Calling get Compliance Cas eStatus Api From the batch', 'Credit Card'
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

                    //#CH04 :Start : add diffrent logic for Jordan
                    if(objCase.Region_Flag__c == 'Bahrain'){
                        objCase.sc_NameScreening__c = false;
                        objCase.sc_ScreeningResult__c = 'PASS';
    
                        //trigger api to create supplementary card in V+ 
                        HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request', regionName);//#CH02 : add regionName param!!
                        
                        if(objCase.Account.x_canary__pc != null){
                            request2.setHeader('x-canary', objCase.Account.x_canary__pc);//CH05
                        }
                        //call the api using SM001 to fill the request body 
                        HttpResponse suppCardResp = SM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus( request2, objCase );
    
                        if (suppCardResp.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + suppCardResp.getStatusCode() + ' ' + suppCardResp.getStatus());
                            lstSA.add(SM001_ApiCalls.setSystemAction(request2.getBody(),suppCardResp.getBody(),
                                                        request2.getEndpoint(),'PUT',
                                                        objCase.id,objCase.Customer_CIF__c,objCase.accountId,suppCardResp.getStatusCode(),
                                                           'Credit Card Supplemntary Application -- call api to create supplementary card in V+ With Approved status -- error from the batch', 'Credit Card'));
                                //#Jahangeer Mohammed# added the Logic Approved Supplementary Card Using API
                               //CH03: Start
                               objCase.Approve_Card_Using_API__c = true;
                               objCase.OwnerId = System.Label.Supplimentary_Maker_Queue;
                               objCase.Sub_Status__c = 'In-Progress';
                               //CH03: END
                        } 
                        else 
                        {
                            System.debug('Response APi in V+ : '+suppCardResp.getBody());
                            objCase.Status = 'Closed';
                            objCase.Sub_Status__c = 'Approved';
                            //objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();//no longer used the preescreener date
                            objCase.cc_CRM_Stage__c = 'APPROVED';
                            objCase.cc_Application_Stages__c = 'Completed';
                            
                            if(objCase.Supplementary_Cards__r != null && objCase.Supplementary_Cards__r.size()>0 ){
                                Supplementary_Card__c objSuppCard = objCase.Supplementary_Cards__r.get(0); 
                                objSuppCard.Status__c = 'Active';
                                objSuppCard.sc_NameScreening__c = false;
                                objSuppCard.sc_ScreeningResult__c = '';
                                objSuppCard.ComplianceStatusApiResponse__c = compilanceResp.getBody();
    
                                suppToUpdate.add(objSuppCard);
                            }
                        }

                    }else if(objCase.Region_Flag__c == 'Jordan') {
                        objCase.OwnerId = System.Label.Jordan_Credit_Card_Admin_Queue;
                        objCase.sc_NameScreening__c = false;
                        objCase.sc_ScreeningResult__c = decision;
                        if(objCase.Supplementary_Cards__r != null && objCase.Supplementary_Cards__r.size()>0 ){
                            Supplementary_Card__c objSuppCard = objCase.Supplementary_Cards__r.get(0); 
                            objSuppCard.Status__c = 'Active';
                            objSuppCard.sc_NameScreening__c = false;
                            objSuppCard.sc_ScreeningResult__c = decision;
                            objSuppCard.ComplianceStatusApiResponse__c = compilanceResp.getBody();

                            suppToUpdate.add(objSuppCard);
                        }
                    }
                    //#CH04 :End
                    
                }else if(decision == 'REJECT') {
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Declined';
                    objCase.cc_CRM_Stage__c = 'DECLINED';
                    objCase.Awaiting_Customer_Feedback__c = false;

                    if(objCase.Supplementary_Cards__r != null && objCase.Supplementary_Cards__r.size()>0 ){
                        Supplementary_Card__c objSuppCard = objCase.Supplementary_Cards__r.get(0); 
                        objSuppCard.Status__c = 'Decline';
                        objSuppCard.sc_NameScreening__c = true;
                        objSuppCard.sc_ScreeningResult__c = screeningResult;
                        objSuppCard.ComplianceStatusApiResponse__c = compilanceResp.getBody();

                        suppToUpdate.add(objSuppCard);
                    }

                    //CH01 : Call Api here in decline....
                    HttpRequest request4 = con.createRequest('PUT','/api/v1/credit-cards/request', regionName);//#CH02 : add regionName param!!
                    String reqBody = '{"crmCaseId": "'+objCase.Id +
                                     '","targetType": "SUPPLEMENTARY_CARD","status":"DECLINED"}';
                    system.debug('---> BODY IN DECLINE --> '+reqBody);               
                    request4.setBody(reqBody);
                    request4.setHeader('userId', objCase.Account.PersonEmail);
                    request4.setHeader('customerId', objCase.Account.CIF__pc);
                    if(objCase.Account.x_canary__pc != null){
                        request4.setHeader('x-canary', objCase.Account.x_canary__pc);//CH05
                    }
                    system.debug('---> request in DECLINE --> '+request4.getBody());
                    //call the EM001 method with our new request4 Body
                    HttpResponse response4 = EM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus(request4,null);
                    if (response4.getStatusCode() != 200) 
                    {
                        System.debug('The status code returned was not expected: ' + response4.getStatusCode() + ' ' + response4.getStatus());
                        lstSA.add(SM001_ApiCalls.setSystemAction(request4.getBody(),response4.getBody(),request4.getEndpoint(),'PUT',
                                objCase.id,objCase.Customer_CIF__c,objCase.accountId,response4.getStatusCode(), 
                                'Credit Card Supplemntary Application -- call api for supplementary card in V+ With Decline Status -- error from the batch', 'Credit Card'));
                    } 
                    else 
                    {
                        System.debug(response4.getBody());
                    }
                    //CH01 -END

                }else{
                    if(objCase.Supplementary_Cards__r != null && objCase.Supplementary_Cards__r.size()>0 ){
                        Supplementary_Card__c objSuppCard = objCase.Supplementary_Cards__r.get(0); 
                        objSuppCard.ComplianceStatusApiResponse__c = compilanceResp.getBody();
                        suppToUpdate.add(objSuppCard);
                    }
                }

                caseToUpdate.add(objCase);
            }
        }

        if(caseToUpdate != null && caseToUpdate.size()>0){
            update caseToUpdate;
        }
        if(suppToUpdate != null && suppToUpdate.size()>0){
            update suppToUpdate;
        }
        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('APB001_CheckSupplementaryCardCases finished !');
    }
}