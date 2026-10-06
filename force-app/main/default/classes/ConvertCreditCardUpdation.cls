/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date:  08/07/2025
*       Change History: 
*        			#CH01# #Jahangeer Mohammed# #15-07-2026# Added Card Product Configuration Id in the Request Body
*/
public class ConvertCreditCardUpdation {
    private static ApiConnection con = new ApiConnection();
    @InvocableMethod(label='Call API Credit Card Request to Convert Credit Card While Update' description='Credit Card Request API to Convert Credit Card While Update' callout=true )
    public static void createCreditCardReqApiFromFlow(List<convertCreditCard> createCreditCards){
        Map<String,String> details = new Map<String,String>();
        System.debug('Convert Credit Card Case Creation:'+createCreditCards);
        convertCreditCard conCard = createCreditCards.get(0);
        details.put('isNew',conCard.isNew);
        details.put('caseId',conCard.caseId);
        details.put('isResultFieldChange',conCard.isResultFieldChange);
        System.debug('Map Details:'+details);
        convertCreditCardUpdateFutureJob(new Set<Id>{conCard.caseId},details);
        
    }
    @future(callout=true)
    public static void convertCreditCardUpdateFutureJob(Set<Id> caseIds , Map<String,String> details){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        set<Id> setCaseIdsApprovedByApprover = new set<Id>();
        set<Id> setCaseIdsResendBySignatureVerifier = new set<Id>();
        String isNew = details.get('isNew');
        String changedField = details.get('isResultFieldChange');
        List<Case> lstCase = [Select id,Account.x_canary__pc,cc_Credit_Card_PCI_Number__c, status, Sub_Status__c,RecordTypeId, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c, Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc, cc_Credit_Approval_Result__c, cc_Credit_Evaluation_Result__c, cc_Credit_Verification_Result__c, cc_Business_Approval_Result__c, cc_Credit_Approval_Result_Date_Time__c, cc_Application_Stages__c, 
                              cc_Approved_Balance_Transfer_Amount__c,Is_Doc_Dicrepancy__c,cc_Approved_Requested_Card_Type__c,cc_Approved_Transfer_Type__c,cc_Approved_Name_on_the_card__c,cc_Approved_Embossing_line_4__c,cc_Signature_Verifier_Result__c,cc_Service_Centre_Result__c,cc_Operations_Result__c,cc_HR_Result__c, cc_HR_Result_Date_Time__c, cc_Business_Approval_Result_Date_Time__c, cc_Credit_Evaluation_Result_Date_Time__c, cc_Credit_Verification_Result_Date_Time__c, cc_Credit_Pre_Screening_Result__c, cc_Credit_Pre_Screening_Result_Date_Time__c,Account.Segment__pc, cc_Maker__c,
                              Account.Nationality__pc,cc_CEO_Result__c,sc_Spending_Limit_Amount__c,sc_Relationship__c, sc_Card_Holder_First_Name__c, sc_Card_Holder_Last_Name__c, sc_Card_Holder_Date_of_Birth__c, sc_Card_Holder_Email_Address__c,cc_Balance_Transfer_Reference_Number__c,cc_isDocumentReceived__c,Fraud_Results__c,
                              Campaign_Name__c,Approved_Campaign_Name__c,sc_Card_Holder_Mobile_No__c, sc_Card_Holder_Gender__c, sc_Card_Holder_ID_Number__c, cc_ID_Expiry_Date__c, sc_Card_Holder_Nationality__c, cc_Embossing_Line_4__c, cc_Is_Doc_Uploaded__c, cc_Is_Doc_Uploaded_For_Dicrepancy__c,PrimaryCardProductConfigurationId__c, PrimaryCard__c, CaseNumber,sc_Card_Holder_ID_Expiry_Date__c,cc_PCI_Id__c, Region_Flag__c,cc_Customer_Response__c,Case_Model__c ,cc_Request_Type__c,cc_Temporary_Limit_Increase_Duration__c,cc_Temporary_Limit_Increase_Expiry_Date__c,cc_Reminder_Triggered__c,
                              cc_Requested_Credit_Limit__c,LastModifiedBy.Name,Is_Balance_Transfer__c,Has_Co_Brand_Membership_Number__c,Account.FirstName, Account.LastName,Reapplying_Restriction_Period__c,ccol_Approved_Hold_Account__c,ccol_Approved_Hold_Account_IBAN__c,ccol_Hold_Reference_Number__c FROM Case where Id In: caseIds];
        for(Case objCase : lstCase){
            String body = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String regionName = objCase.Region_Flag__c; 
            if(objCase.Case_Model__c == 'alburaq'){ 
                regionName += '_alburaq';   
            } 
            request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc);
            }
            
            ////////////////////////////////////////////////////// START: CREDIT PRE-SCREENER ACTION //////////////////////////////////////////////////
            if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Credit_Pre_Screening_Result__c')){
                if(objCase.cc_Credit_Pre_Screening_Result__c == 'Accept'){
                    if(objCase.Campaign_Name__c != null){
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Campaign_Name__c +
                            '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                     }
                     else if(objCase.Campaign_Name__c == null){
                            System.debug('Campaign Name is Blank');
                            body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                     }
               }
               else if(objCase.cc_Credit_Pre_Screening_Result__c == 'Discrepancy in Documents'){
                     body = '{"crmCaseId": "'+objCase.Id +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"DISCREPANCIES"}';
               }
               else if(objCase.cc_Credit_Pre_Screening_Result__c == 'Request Documents'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"PENDING"}';
               }
               else if(objCase.cc_Credit_Pre_Screening_Result__c == 'Refer to Service Center'){
                   //CH01: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        	'","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "CONVERT_TO_UNSECURED","status":"REFERRED_BY_PRESCREENER"}';
                   //CH01: END
               }
               request.setBody(body);
               request.setHeader('userId', objCase.Account.PersonEmail);
               request.setHeader('customerId', objCase.Account.CIF__pc);
               System.debug('Request Body When Pre-Screener Action:'+request.getBody());
               HttpResponse response = http.send(request);
               if(response.getStatusCode() != 200)
               {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
               }
               else{
                    System.debug('Response Body When Pre-Screener Action:'+response.getBody());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);

               }
                
            }
           ////////////////////////////////////////////////////// END: CREDIT PRE-SCREENER ACTION //////////////////////////////////////////////////
            
           ////////////////////////////////////////////////////// START: DOCUMENTS RECEIVED //////////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && objCase.Sub_Status__c == 'Documents Received'){
                body = '{"crmCaseId": "'+objCase.Id +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
               request.setBody(body);
               request.setHeader('userId', objCase.Account.PersonEmail);
               request.setHeader('customerId', objCase.Account.CIF__pc);
               System.debug('Request Body When Confirm Doc Upload:'+request.getBody());
               HttpResponse response = http.send(request);
               if(response.getStatusCode() != 200)
               {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
               }
               else{
                    System.debug('Response Body When Documents Received:'+response.getBody());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);

               }

            }
           ////////////////////////////////////////////////////// END: DOCUMENTS RECEIVED //////////////////////////////////////////////////////
		   
           ////////////////////////////////////////////////////// START: CREDIT EVALUATION ACTION ////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Credit_Evaluation_Result__c')){
                if(objCase.cc_Credit_Evaluation_Result__c == 'Accept'){
                    if(objCase.Campaign_Name__c != null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Campaign_Name__c +
                            '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                    }
                    else if(objCase.Campaign_Name__c == null){
                        System.debug('Campaign Name is Blank');
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                    }
                }
                else if(objCase.cc_Credit_Evaluation_Result__c == 'Refer to Service Center'){
                    //CH01: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"REFERRED_BY_EVALUATOR"}';
                    //CH01: END
                }
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Evaluator Actions:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
                }
                else{
                    System.debug('Response Body When Evaluator Actions:'+response.getBody());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
           ////////////////////////////////////////////////////// END: CREDIT EVALUATION ACTION //////////////////////////////////////////////////
           
           ////////////////////////////////////////////////////// START: CREDIT VERIFIER ACTION ////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Credit_Verification_Result__c')){
                if(objCase.cc_Credit_Verification_Result__c == 'Approve'){
                    if(objCase.Campaign_Name__c != null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Campaign_Name__c +
                            '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                    }
                    else if(objCase.Campaign_Name__c == null){
                        System.debug('Campaign Name is Blank');
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                    }
                }
                else if(objCase.cc_Credit_Verification_Result__c == 'Refer to Service Center'){
                    //CH01: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"REFERRED_BY_VERIFIER"}';
                    //CH01: END
                }
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Verifier Actions:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
                }
                else{
                    System.debug('Response Body When Verifier Actions:'+response.getBody());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
           ////////////////////////////////////////////////////// END: CREDIT VERIFIER ACTION //////////////////////////////////////////////////
           
            ////////////////////////////////////////////////////// START: CREDIT APPROVER ACTION ////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Credit_Approval_Result__c')){
                System.debug('Credit Card Approver Actions'); 
                if(objCase.cc_Credit_Approval_Result__c == 'Approve'){
                    if(objCase.Campaign_Name__c != null){
                        body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c  +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","campaignId": "'+objCase.Campaign_Name__c +
                            		'","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                            		'","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                            		'","referenceId":"'+objCase.ccol_Hold_Reference_Number__c+
                                    '","pciNumber":"'+objCase.cc_Credit_Card_PCI_Number__c+
                                    '","targetType": "CONVERT_TO_UNSECURED","status":"APPROVED"}';
                    }
                    else if(objCase.Campaign_Name__c == null){
                        body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c  +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            		'","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                            		'","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                            		'","referenceId":"'+objCase.ccol_Hold_Reference_Number__c+
                                    '","pciNumber":"'+objCase.cc_Credit_Card_PCI_Number__c+
                                    '","targetType": "CONVERT_TO_UNSECURED","campaignId": null,"status":"APPROVED"}';
                    }
                   
                }
                else if(objCase.cc_Credit_Approval_Result__c == 'Refer to Service Center'){
                    //CH01: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"REFERRED_BY_APPROVER"}';
                    //CH01: END
                 }
                else if(objCase.cc_Credit_Approval_Result__c == 'Send to Signature Verification'){
                    if(objCase.Approved_Campaign_Name__c != null){
                        body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                '","targetType": "CONVERT_TO_UNSECURED","status":"APPROVED_PENDING_SIGNATURE"}'; 
                    }
                    else if(objCase.Approved_Campaign_Name__c == null){
                         body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","targetType": "CONVERT_TO_UNSECURED","campaignId": null,"status":"APPROVED_PENDING_SIGNATURE"}';
                    }
                    setCaseIdsApprovedByApprover.add(objCase.id);
                }
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Approver Actions:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
                }
                else{
                    System.debug('Response Body When Credit Approver Actions:'+response.getBody());
					if(objCase.cc_Credit_Approval_Result__c == 'Approve'){
                        objCase.Status = 'Closed';
                    	objCase.Sub_Status__c = 'Approved';
                    	objCase.cc_Application_Stages__c = 'Completed';
                    	objCase.cc_CRM_Stage__c = 'APPROVED';
                    	objCase.cc_Credit_Approval_Result_Date_Time__c = System.now();
                    	lstUpdateCase.add(objCase);
                    }                    
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
           ////////////////////////////////////////////////////// END: CREDIT APPROVER ACTION //////////////////////////////////////////////////
           
           ////////////////////////////////////////////////////// START: Service Centre ACTION ////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Service_Centre_Result__c')){
                if(objCase.cc_Service_Centre_Result__c == 'Return to Pre-Screener' || objCase.cc_Service_Centre_Result__c == 'Return to Evaluator' ||  objCase.cc_Service_Centre_Result__c == 'Return to Verifier' || objCase.cc_Service_Centre_Result__c == 'Return to Approver'){
                    if(objCase.Campaign_Name__c != null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": "'+objCase.Campaign_Name__c +
                            '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                    }
                    else if(objCase.Campaign_Name__c == null){
                        System.debug('Campaign Name is Blank');
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","campaignId": null,"targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                    }
                }
                else if(objCase.cc_Service_Centre_Result__c == 'Return to Signature Verifier'){
                    body = '{"crmCaseId": "'+objCase.Id +
                                '","targetType": "CONVERT_TO_UNSECURED","status":"APPROVED_PENDING_SIGNATURE"}';
                }
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Service Center Actions:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
                }
                else{
                    System.debug('Response Body When Service Centre Actions:'+response.getBody());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
           ////////////////////////////////////////////////////// END: Service Centre ACTION //////////////////////////////////////////////////
           
          ////////////////////////////////////////////////////// START: SIGNATURE VERIFIER ACTION //////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Signature_Verifier_Result__c')){
                if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                    if(objCase.Campaign_Name__c != null){
                        body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c  +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","campaignId": "'+objCase.Campaign_Name__c +
                            		'","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                            		'","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                            		'","referenceId":"'+objCase.ccol_Hold_Reference_Number__c+
                                    '","pciNumber":"'+objCase.cc_Credit_Card_PCI_Number__c+
                                    '","targetType": "CONVERT_TO_UNSECURED","status":"APPROVED"}';
                    }
                    else if(objCase.Campaign_Name__c == null){
                        body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c  +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                            		'","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                            		'","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                            		'","referenceId":"'+objCase.ccol_Hold_Reference_Number__c+
                                    '","pciNumber":"'+objCase.cc_Credit_Card_PCI_Number__c+
                                    '","targetType": "CONVERT_TO_UNSECURED","campaignId": null,"status":"APPROVED"}';
                    }
                   
                }
                else if(objCase.cc_Signature_Verifier_Result__c == 'Re-Send'){
                    body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CONVERT_TO_UNSECURED","status":"APPROVED_PENDING_SIGNATURE"}';
                    
                }
                else if(objCase.cc_Signature_Verifier_Result__c == 'Refer to Service Center'){
                    //CH01: Start
                    body = '{"crmCaseId": "'+objCase.Id +
                        	'","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +	
                            '","targetType": "CONVERT_TO_UNSECURED","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
                    //CH01: END
                }
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Service Center Actions:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
                }
                else{
                    System.debug('Response Body When Signature Verifier Actions:'+response.getBody());
                    if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                        objCase.Status = 'Closed';
                    	objCase.Sub_Status__c = 'Approved';
                    	objCase.cc_Application_Stages__c = 'Completed';
                    	objCase.cc_CRM_Stage__c = 'APPROVED';
                    	objCase.cc_Signature_Verification_Date_Time__c = System.now();
                    	lstUpdateCase.add(objCase);
                    }
                    else if(objCase.cc_Signature_Verifier_Result__c == 'Re-Send'){
                        setCaseIdsResendBySignatureVerifier.add(objCase.id);
                    }
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
          ///////////////////////////////////////////////////// END: SIGNATURE VERIFIER ACTION /////////////////////////////////////////////////
          
            
            
          /////////////////////////////////////////////////////// START: CANCELLED BY CUSTOMER /////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && (objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Evaluation_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Verification_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer' || objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer')){
                body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "CONVERT_TO_UNSECURED","status":"CANCELLED"}';
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Cancelled by Customer:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                	if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Approval_Result__c = '';
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Evaluation_Result__c = '';
                    if(objCase.cc_Credit_Verification_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Verification_Result__c = '';
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Pre_Screening_Result__c = '';
                    if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                       objCase.cc_Signature_Verifier_Result__c = '';
                    }
                    lstUpdateCase.add(objCase);
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);

                }
                else{
                    System.debug('Response Body When Service Centre Actions:'+response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Cancelled';
                    objCase.cc_CRM_Stage__c = 'CANCELLED';
                    
                    if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Approval';
                    }
                   
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Evaluation_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Evaluation';
                    }
                    if(objCase.cc_Credit_Verification_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Verification_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Verification';
                    }
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                    }
                    if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    }
                    
                    lstUpdateCase.add(objCase);
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
          /////////////////////////////////////////////////////// END: CANCELLED BY CUSTOMER /////////////////////////////////////////////////

         /////////////////////////////////////////////////////// START: DECLINE BY CUSTOMER /////////////////////////////////////////////////
            else if(isNew != null && isNew.equalsIgnoreCase('no') && (objCase.cc_Credit_Pre_Screening_Result__c == 'Decline' || objCase.cc_Credit_Evaluation_Result__c == 'Decline' || objCase.cc_Credit_Verification_Result__c == 'Decline' || objCase.cc_Credit_Approval_Result__c == 'Decline' || objCase.cc_Signature_Verifier_Result__c == 'Decline' || objCase.cc_Business_Approval_Result__c == 'Decline')){
                String decReason = DeclineReasonMapping.fetchDeclineMappingValue(objCase.id);
				body = '{"crmCaseId": "'+objCase.Id +
                         '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                         '","declineReasons": "'+decReason +
                         '","targetType": "CONVERT_TO_UNSECURED","status":"DECLINED"}';
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                System.debug('Request Body When Cancelled by Customer:'+request.getBody());
                HttpResponse response = http.send(request);
                if(response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                	if(objCase.cc_Credit_Approval_Result__c == 'Decline')
                        objCase.cc_Credit_Approval_Result__c = '';
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Decline')
                        objCase.cc_Credit_Evaluation_Result__c = '';
                    if(objCase.cc_Credit_Verification_Result__c == 'Decline')
                        objCase.cc_Credit_Verification_Result__c = '';
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Decline')
                        objCase.cc_Credit_Pre_Screening_Result__c = '';
                    if(objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                       objCase.cc_Signature_Verifier_Result__c = '';
                    }
                    if(objCase.cc_Business_Approval_Result__c == 'Decline'){
                        objCase.cc_Business_Approval_Result__c = '';
                    }
                    lstUpdateCase.add(objCase);
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);

                }
                else{
                    System.debug('Response Body When Service Centre Actions:'+response.getBody());
                    objCase.Status = 'Closed';
                    objCase.Sub_Status__c = 'Declined';
                    objCase.cc_CRM_Stage__c = 'DECLINED';
                    
                    if(objCase.cc_Credit_Approval_Result__c == 'Decline'){
                        objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Approval';
                    }
                   
                    if(objCase.cc_Credit_Evaluation_Result__c == 'Decline'){
                        objCase.cc_Credit_Evaluation_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Evaluation';
                    }
                    if(objCase.cc_Credit_Verification_Result__c == 'Decline'){
                        objCase.cc_Credit_Verification_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Verification';
                    }
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Decline'){
                        objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                    }
                    if(objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                        objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    }
                    if(objCase.cc_Business_Approval_Result__c == 'Decline'){
                        objCase.cc_Business_Approval_Result_Date_Time__c = system.now();
                        objCase.cc_Application_Stages__c = 'Credit Business Team';
                    }
                    
                    lstUpdateCase.add(objCase);
                    lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);
                    
                }
            }
          /////////////////////////////////////////////////////// END: DECLINE BY CUSTOMER /////////////////////////////////////////////////

        }//for loop Ends
        if(lstUpdateCase.size()>0){
            update lstUpdateCase;
        }
        if(setCaseIdsApprovedByApprover.size()>0){
            if(!test.isRunningTest()){
                ConvertCreditCardDocusignTemplates autoSendDocSign =  new ConvertCreditCardDocusignTemplates(setCaseIdsApprovedByApprover);
           		System.enqueueJob(autoSendDocSign);
            }
           
        }
        if(setCaseIdsResendBySignatureVerifier.size()>0){
            if(!test.isRunningTest()){
                ConvertCreditCardDocusignTemplates autoSendDocSign =  new ConvertCreditCardDocusignTemplates(setCaseIdsResendBySignatureVerifier);
           		System.enqueueJob(autoSendDocSign); 
            }
           
        }
        if(lstSA.size()>0){
          insert lstSA;
      	}
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType,Boolean isAPIFailed) {
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
        action.Is_API_Failed__c = isAPIFailed;
        lstSA.add(action);
        
        return lstSA;
        
    }
    public class convertCreditCard{
        @InvocableVariable(label='CaseId' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        
        @InvocableVariable(label='Result Field Change' description='used to Capture Change Field')
        public String isResultFieldChange;
    }


}