/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 06-03-2025
*      Description : Handling API'S for Credit Card Cash Collateral Project
*      Change History: 
 					#CH01# #Jahangeer Mohammed# 23-07-2026# Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query and it is not required for reminder notifications(NBA-17560)

*/
global class CreditCardCashCollateralSTP {
    private static ApiConnection con = new ApiConnection();
    private static final String[] units = new String[]{
        'Zero', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven',
        'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen',
        'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'
    };

    private static final String[] tens = new String[]{
        '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
    };
    public static String convertDecimalToBahrainWords(Decimal inputNumber) {
        if (inputNumber == null) return '';

        inputNumber = inputNumber.setScale(3); // Ensure 3 decimal places
        String[] parts = String.valueOf(inputNumber).split('\\.');

        String wholePart = parts[0];
        String decimalPart = (parts.size() > 1) ? parts[1] : '000';

        // Pad decimal part to 3 digits
        while (decimalPart.length() < 3) {
            decimalPart += '0';
        }

        String words = numberToWords(Long.valueOf(wholePart));
        return words + ' & fills ' + decimalPart + '/1000 only';
    }

    private static String numberToWords(Long num) {
        if (num == 0) return 'Zero';
        return convert(num).trim();
    }

    private static String convert(Long num) {
        if (num < 20) return units[num.intValue()];

        if (num < 100) {
            Long tenPart = Math.floor(num / 10).longValue();
            Long unitPart = num - (tenPart * 10);
            String result = tens[tenPart.intValue()];
            if (unitPart > 0) {
                result += ' ' + units[unitPart.intValue()];
            }
            return result;
        }

        if (num < 1000) {
            Long hundredPart = Math.floor(num / 100).longValue();
            Long remainder = num - (hundredPart * 100);
            String result = units[hundredPart.intValue()] + ' Hundred';
            if (remainder > 0) {
                result += ' ' + convert(remainder);
            }
            return result;
        }

        if (num < 1000000) {
            Long thousandPart = Math.floor(num / 1000).longValue();
            Long remainder = num - (thousandPart * 1000);
            String result = convert(thousandPart) + ' Thousand';
            if (remainder > 0) {
                result += ' ' + convert(remainder);
            }
            return result;
        }

        if (num < 1000000000) {
            Long millionPart = Math.floor(num / 1000000).longValue();
            Long remainder = num - (millionPart * 1000000);
            String result = convert(millionPart) + ' Million';
            if (remainder > 0) {
                result += ' ' + convert(remainder);
            }
            return result;
        }

        Long billionPart = Math.floor(num / 1000000000).longValue();
        Long remainder = num - (billionPart * 1000000000);
        String result = convert(billionPart) + ' Billion';
        if (remainder > 0) {
            result += ' ' + convert(remainder);
        }
        return result;
    }
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType, Boolean isAPIFailed) {
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
   /* @future(callout=true)
    public static void CashCollateralCaseCreationSTP(Set<Id> setCaseId)
    {
        System.debug('Case ID :'+setCaseId);
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Integer cardProductConfigurationIdString;
        //CH01: Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query
        List<Case> lstCase = [Select id,AccountId,Account.ID_Type__pc,Account.x_canary__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,Account.iGA_Passport_Number__pc,cc_Passport_Number__c,cc_CPR_Number__c,cc_CPR_Expiry_Date__c, status, Sub_Status__c, Type, Sub_Type__c,ccol_Hold_Account__c,ccol_Hold_Account_IBAN__c, cc_Requested_Card_Type__c, 
                              Customer_Segment__c,Customer_CIF__c, cc_Name_on_the_Card__c, Origin, Account.PersonEmail, Account.CIF__pc,Region_Flag__c,ccol_Approved_Hold_Account__c,
                              cc_Credit_Card_PCI_Number__c,cc_CC_Application_Source__c, PrimaryCardProductConfigurationId__c,Card_Product_Configuration_Id__c, 
                              PrimaryCard__c,cc_Requested_Credit_Limit__c,ccol_Existing_Hold_Amount__c,ccol_New_Hold_Amount__c,ccol_Hold_Account_Balance__c,ccol_Hold_Reference_Number__c,cc_Credit_Pre_Screening_Result__c,cc_Credit_Approval_Result__c,cc_Business_Approval_Result__c,
                              cc_Service_Centre_Result__c,cc_Signature_Verifier_Result__c,cc_Application_Submission_Date_Time__c,ccjo_ID_Number__c,ccjo_ID_Expiry_Date__c,cc_Terms_and_Conditions_Acceptance_Flag__c,ac_Iban__c,Has_Co_Brand_Membership_Number__c,Is_Balance_Transfer__c,
                              cc_Credit_Pre_Screening_Result_Date_Time__c,cc_Credit_Approval_Result_Date_Time__c,cc_Signature_Verification_Date_Time__c,cc_CRM_Stage__c,cc_Application_Stages__c,Approved_Campaign_Name__c,cc_Approved_Credit_Limit__c,cc_Approved_Requested_Card_Type__c,
                              cc_Approved_Embossing_line_4__c from Case where id in: setCaseId];
        System.debug('CASE LIST:'+lstCase);
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //request = con.createRequest('GET','/api/v1/credit-cards?',objCase.Region_Flag__c);
            request = con.createRequest('GET',System.Label.CC_EndPointGetCreditCards,objCase.Region_Flag__c);
            request.setHeader('userId', objCase.Account.PersonEmail);
            request.setHeader('customerId', objCase.Account.CIF__pc);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc);
            }
            System.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            System.debug('---> Responce New --> '+response.getBody());
             if (response.getStatusCode() != 200) 
            {   
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);
                
            } 
            else 
            {
                System.debug(response.getBody());      
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                System.debug('---> MAP m --> '+m);  // meta, data
                System.debug('---> MAP m VALUES --> '+m.Values());
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
                List<Object> m2 = (List<Object>)m1.get('cardOptions');
                System.debug('---> LIST m2 --> '+m2);
                
                List<Map<String, Object>> a = new List<Map<String, Object>> ();
                
                for(Object obj : m2)
                {
                    a.add((Map<String, Object>)obj);
                    {
                        system.debug('---->> OBJ Iterations --> '+obj);
                    }
                }
                system.debug('---->> FINALL aaaa --> '+a);
                System.debug('Requested Card Type:'+objCase.cc_Requested_Card_Type__c);
                for(Map<String, Object> map1 : a)
                {
                    if(map1.get('productMappingCode')== objCase.cc_Requested_Card_Type__c)
                    {
                        system.debug('---> FINALL 1111 --> '+(Integer)map1.get('cardProductConfigurationId'));
                        cardProductConfigurationIdString = (Integer)map1.get('cardProductConfigurationId');
                        system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationIdString);
                    }
                }               
            } 
            String body ='';    
            Http http1 = new Http();
            HttpRequest request1 = new HttpRequest();
            //request1 = con.createRequest('PUT','/api/v1/credit-cards/request?',objCase.Region_Flag__c);
            request1 = con.createRequest('PUT',System.Label.CC_EndPointCreditCardRequest,objCase.Region_Flag__c);
            if(objCase.Account.x_canary__pc != null){
                request1.setHeader('x-canary', objCase.Account.x_canary__pc);
            }
            if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+cardProductConfigurationIdString +
                        '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                        '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                        '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';
                }
                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+cardProductConfigurationIdString +
                        '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                        '","campaignId": null,"creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';
                }
                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                            '","campaignId": null,"membershipNumber": null,"status":"APPROVED_PENDING_SIGNATURE"}';
                    }
                    else if(objCase.cc_Approved_Embossing_line_4__c != null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                            '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +    
                            '","campaignId": null,"status":"APPROVED_PENDING_SIGNATURE"}';
                    }
                    
                }
            }
            if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                       body = '{"crmCaseId": "'+objCase.Id +
                             '","cardProductConfigurationId": "'+cardProductConfigurationIdString +
                             '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                             '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                             '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                             '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE"}';
            }
            System.debug('---> BODY IN APPROVED PENDING SIGNATURE IN CASH COLLATERAL STP --> '+body);               
            request1.setBody(body);
            request1.setHeader('userId', objCase.Account.PersonEmail);
            request1.setHeader('customerId', objCase.Account.CIF__pc);
            
            System.debug('---> Request in Cash Collateral STP--> '+request1.getBody());
            HttpResponse response1 = http1.send(request1);
            if(response1.getStatusCode() != 200) 
            {
                System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
            } 
            else 
            {
                System.debug('Response in STP Case Creation: '+response1.getBody());
                
                objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
                objCase.cc_Credit_Pre_Screening_Result__c = 'Accept';
                objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = System.now();
                objCase.cc_Credit_Approval_Result__c = 'Approve';
                objCase.cc_Credit_Approval_Result_Date_Time__c = System.now();
                objCase.ownerId = System.Label.Credit_Signature_Verification;
                objCase.Sub_Status__c = 'Pending Signature Verification';
                objCase.cc_CRM_Stage__c = 'APPROVED PENDING';
                objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                
                lstUpdateCase.add(objCase);
            }
            
            
        }//for loop Ends
        if(lstUpdateCase.size()>0){
            System.debug('List Upsert:'+lstUpdateCase);
            upsert lstUpdateCase;
        }
        if(lstSA.size()>0)
            insert lstSA;
    }*/
}