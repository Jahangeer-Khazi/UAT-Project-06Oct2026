/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 09-12-2021
*      Description : Handling API'S for Credit Card Cash Collateral Project
*      Change History: 
*                   #CH01# #Jahangeer Mohammed# #19-04-2022# Added Card Nature = Secured for Cancelled by Customer & Decline Condition
*                   #CH02# #Jahangeer Mohammed #15-07-2022# Added Logic to Populate CPR Number & CPR Expiry(NBA-5692 & NBA-5693) 
*                   #CH03# #Jahangeer Mohammed #24-07-2022# Added Logic to Store CardProductConfigurationId
*                   #CH04# #Jahangeer Mohammed# #15-08-2022# Added campaignID in request parameter as per ticket(NBA-5719)
*                   #CH05# #Jahangeer Mohammed# #12-09-2022# Added Logic for Cash Collateral Limit Increase Application(NBA-6043)
*                   #CH06# #Jahangeer Mohammed# #21-11-2022# Added Logic for Cancelled by Customer for Cash Collateral Limit Increase Process(NBA-6559)
*                   #CH07# #Jahangeer Mohammed# #29-11-2022# Added Logic to Populate CPR Number & CPR Expiry for Cash Collateral Limit Increase Application
*		   			#CH08# #Jahangeer Mohammed# #27-04-2023# Restrict Cash Collateral Applications to Bahrain Region and adding Jordan Logic for API Calls
*					#CH09# #Jayanth Manickam# #02-05-2023# Add  Jordan Logic for Cash Collateral Limit Increase
*					#CH10# #Jahangeer Mohammed# #22-05-2023# Added Custom Labels to Store Credit Card End-Point Urls to avoid hardcoding
*					#CH11# #Jahangeer Mohammed# #31-10-2023# Added terms & Condition Flag during Cash Collateral Case Creation
                    #CH12 : #Imane Tsioucha# #22-02-2024# add x-canary header
*					#CH13# #Jahangeer Mohammed# #21-05-2024# Added Decline & Cancelled by Customer in Signature Verifier Phase(NBA-11053)
* 					#CH14# #Jahangeer Mohammed# #21-07-2024# Added Campaign Name Segregation for Null and Not Null
*					#CH15# #Jahangeer Mohammed# #04-08-2024# Added Logic to add Alias Name as API/Manual based on the Last Modified User
*					#CH16# #Jahangeer Mohammed# #21-08-2024# Added Debit Account IBAN(Fixed Deposit Funding Account)
*					#CH17# #Jahangeer Mohammed# #02-10-2024# Added Existing IBAN for Cash Collateral Limit Increase Fixed Deposit
* 					#CH18# #Jahangeer Mohammed# #17-12-2024# Added Logic to add Co-Branded Cards(NBA-12524)
*                   #CH19# #Jahangeer Mohammed# #02-02-2025# Added Logic for API Failures(NBA-13083)
* 					#CH20# #Jahangeer Mohammed# #25-02-2025# Added Logic for iGA Passport Number (UATNB-156349)
*			        #CH21# #Jahangeer Mohammed# #09-02-2025# Added Logic for Premium Retention for Co-branded Cards for Premium Customers (NBA-13210)
* 					#CH22# #Jahangeer Mohammed# #17-04-2025# Added Logic to add STP Decisoning(NBA-13287)
*					#CH23# #Jahangeer Mohammed# #07-08-2025# Added Logic for Ila World Elite Premium Invitation and Retention (NBA-15626)
					#CH24# #Jahangeer Mohammed# #05-11-2025# Added Logic for World Entitlement Project(NBA-15929)
					#CH25# #Jahangeer Mohammed# 24-11-2025# Added Logic for Queues Re-structuring at Credit Pre-Screener (NBA-15993)
                    #CH26# #Jahangeer Mohammed# 30-12-2025# Added Logic for Reapplying Restriction Period Unsecured Limit Increase and Secured Application(NBA-16360)
*                   #CH27# #Aniss Mbarki# 23-12-2025# Added Logic for Credit Card - In-App DocuSign Documents Signing  (NBA-13727)
                    #CH29# #Jahangeer Mohammed# 15-04-2026# Added Logic for Cash Collateral Current Credit Limit Increase(NBA-8386)
*                   #CH30# #Aniss Mbarki# 05-04-2026# Added Logic for Credit Card - In-App DocuSign attah Documents Signing to an email
 					#CH31# #Jahangeer Mohammed# 23-07-2026# Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query and it is not required for reminder notifications and related fields - Automatic Creation of Upgrade Cases from Limit Increase Application(NBA-17560)

*/

global class CreditCardCashCollateral {
    private static ApiConnection con = new ApiConnection();
    //CH19: Added isAPIFailed parameter in the method
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
    @future(callout=true)
    public static void CashCollateralCaseCreation(Set<Id> setCaseId)
    {
        System.debug('Case ID :'+setCaseId);
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //CH24: Start
        List<World_Elite_Entitlement__c> lstWorldEntitCase = new List<World_Elite_Entitlement__c>();
        //CH24: END
        Integer cardProductConfigurationIdString;
        //CH02 : Added AccountId,Account.ID_Type__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,cc_CPR_Number__c,cc_CPR_Expiry_Date__c in SOQL Query
        //CH05 : Added Existing Hold Amount field in SOQL Query
        //CH08: Added ccjo_ID_Number__c,ccjo_ID_Expiry_Date__c in SOQL Query
        //CH17: Added ac_Iban__c in SOQL Query
        //CH18: Added Has_Co_Brand_Membership_Number__c,Is_Balance_Transfer__c in SOQL Query
        //CH20 : Added Account.iGA_Passport_Number__pc,cc_Passport_Number__c in SOQL Query
        //CH29 : Added cc_Current_Credit_Limit__c in SOQL Query
        //CH31: Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query
        List<Case> lstCase = [Select id,AccountId,Account.ID_Type__pc,Account.x_canary__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,Account.iGA_Passport_Number__pc,cc_Passport_Number__c,cc_CPR_Number__c,cc_CPR_Expiry_Date__c, status, Sub_Status__c, Type, Sub_Type__c,ccol_Hold_Account__c,ccol_Hold_Account_IBAN__c, cc_Requested_Card_Type__c, Account.FirstName, Account.LastName,
                              Customer_Segment__c,Customer_CIF__c, cc_Name_on_the_Card__c, Origin, Account.PersonEmail, Account.CIF__pc,Region_Flag__c,
                              cc_Credit_Card_PCI_Number__c,cc_CC_Application_Source__c,/*cc_Activate_Reminders_for_Pending_Cases__c,*/ PrimaryCardProductConfigurationId__c,Card_Product_Configuration_Id__c, 
                              PrimaryCard__c,cc_Requested_Credit_Limit__c,ccol_Existing_Hold_Amount__c,ccol_New_Hold_Amount__c,ccol_Hold_Account_Balance__c,ccol_Hold_Reference_Number__c,cc_Credit_Pre_Screening_Result__c,cc_Credit_Approval_Result__c,cc_Business_Approval_Result__c,ccol_Approved_Hold_Amount__c,
                              cc_Service_Centre_Result__c,cc_Signature_Verifier_Result__c,cc_Application_Submission_Date_Time__c,ccjo_ID_Number__c,ccjo_ID_Expiry_Date__c,cc_Terms_and_Conditions_Acceptance_Flag__c,ac_Iban__c,Has_Co_Brand_Membership_Number__c,Is_Balance_Transfer__c,cc_Current_Credit_Limit__c
                              from Case where id in: setCaseId];
        System.debug('CASE LIST:'+lstCase);
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH10: Start
            //request = con.createRequest('GET','/api/v1/credit-cards?',objCase.Region_Flag__c);
            request = con.createRequest('GET',System.Label.CC_EndPointGetCreditCards,objCase.Region_Flag__c);
            //CH10: END
            System.debug('Person Email :'+objCase.Account.PersonEmail);
            System.debug('Customer ID :'+objCase.Account.CIF__pc);
            //System.debug('Case ID :'+setCaseId);
            
            request.setHeader('userId', objCase.Account.PersonEmail);
            request.setHeader('customerId', objCase.Account.CIF__pc);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc); // CH12
            }
        
            
            system.debug('---> Request --> '+request.getBody());
            HttpResponse response = http.send(request);
            system.debug('---> Responce New --> '+response.getBody());
            
            if (response.getStatusCode() != 200) 
            {   
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //CH19: Added isAPIFailed parameter in the method
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
            //CH10: Start
            //request1 = con.createRequest('PUT','/api/v1/credit-cards/request?',objCase.Region_Flag__c);
            request1 = con.createRequest('PUT',System.Label.CC_EndPointCreditCardRequest,objCase.Region_Flag__c);
            if(objCase.Account.x_canary__pc != null){
                request1.setHeader('x-canary', objCase.Account.x_canary__pc); // CH12
            }

            //CH10: END
            
            if(objCase.Sub_Status__c == 'In-Progress'){
                system.debug('--> Check inside In Progress --> ');
                //CH08: Start Added a Region Flag in if condition
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')){
                    //CH11: Start
                    if(objCase.cc_Name_on_the_Card__c !=null && objCase.Region_Flag__c == 'Bahrain'){
                        //CH18: Start
                        if(objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                             body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS","cardNature":"secured"}';
                        }
                        else if(objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                            body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS","cardNature":"secured"}';
                        }
                       //CH18: END
                    }
                    else if(objCase.cc_Name_on_the_Card__c == null && objCase.Region_Flag__c == 'Bahrain'){
                        //CH18: Start
                        if(objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                             body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS","cardNature":"secured"}';
                        }
                        else if(objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                             body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS","cardNature":"secured"}';
                        }
                        //CH18: END
                    }
                    else if(objCase.cc_Name_on_the_Card__c !=null && objCase.Region_Flag__c == 'Jordan'){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            //'","termsAndConditionsAcceptance":"'+objCase.cc_Terms_and_Conditions_Acceptance_Flag__c+
                            '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS","cardNature":"secured"}';
                    }
                    else if(objCase.cc_Name_on_the_Card__c == null && objCase.Region_Flag__c == 'Jordan'){
                        body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            //'","termsAndConditionsAcceptance":"'+objCase.cc_Terms_and_Conditions_Acceptance_Flag__c+
                            '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS","cardNature":"secured"}';
                    }
                    //CH11: END
                }
                //CH08: END
                //CH05: Start
                //Adding Cash Collateral Limit Increase Logic in this block for Manual case creation
                //CH08: Start Added a Region Flag in if condition
                //CH09: Added Jordan Region Flag in if condition
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.cc_CC_Application_Source__c == 'Manual' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')){
                    //CH17: Start: Added Hold Account Type Parameter in the Request Body
                    if(objCase.ccol_Hold_Account__c != 'FIXED_DEPOSIT'){
                        if(objCase.cc_Name_on_the_Card__c != null){
                        	body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","cardProductConfigurationId":"'+objCase.PrimaryCardProductConfigurationId__c+
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                    	}
                     	else{
                           body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","cardProductConfigurationId":"'+objCase.PrimaryCardProductConfigurationId__c+
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                    	}
                    }
                    else if(objCase.ccol_Hold_Account__c == 'FIXED_DEPOSIT'){
                        if(objCase.cc_Name_on_the_Card__c != null){
                        	body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ac_Iban__c+
                            '","holdAccountIdNew":"'+objCase.ccol_Hold_Account_IBAN__c+   
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","cardProductConfigurationId":"'+objCase.PrimaryCardProductConfigurationId__c+
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                    	}
                     	else{
                           body = '{"pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                            '","crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","holdAccountType":"'+objCase.ccol_Hold_Account__c+
                            '","holdAccountId":"'+objCase.ac_Iban__c+
                            '","holdAccountIdNew":"'+objCase.ccol_Hold_Account_IBAN__c+
                            '","creditLimit":"'+objCase.cc_Requested_Credit_Limit__c+
                            '","cardProductConfigurationId":"'+objCase.PrimaryCardProductConfigurationId__c+
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                    	}
                    } //CH17: END
                    
                }
                //CH08: END
                //CH08: Start Added a Region Flag in if condition
                //CH09: Added Jordan Region Flag in if condition
                //Adding Cash Collateral Limit Increase Logic in this block for API case creation
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'  && objCase.cc_CC_Application_Source__c == 'API' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')){
                    if(objCase.cc_Name_on_the_Card__c !=null){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                    }
                    else{
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","embossName": "'+null +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                    }
                }
                //CH05: END
                //CH08: END
            }
            
            system.debug('---> BODY --> '+body);               
            request1.setBody(body);
            request1.setHeader('userId', objCase.Account.PersonEmail);
            request1.setHeader('customerId', objCase.Account.CIF__pc);
            
            system.debug('---> Request --> '+request1.getBody());
            request1.setTimeout(90000);
            HttpResponse response1 = http1.send(request1);
            system.debug('---> RESPONSE IN CASH COLLATERAL --> '+response1.getBody());
            
            if (response1.getStatusCode() != 200) 
            {
                System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                //CH19: Added isAPIFailed parameter in the method
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
            } 
            else 
            {
                System.debug('SUCCESS RESPONSE FROM API');
                System.debug(response1.getBody());
                //CH05: Start
                //CH08: Start Added a Region Flag
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')){
                    Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());// meta, data
                    Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                    System.debug(dataMap);
                    String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                    Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                    Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                    System.debug('Hold Reference Number After Case Created in Cash Collateral:'+holdReferenceNumber);
                    System.debug('Hold Account Balance After Case Created in Cash Collateral:'+holdAccBalance);
                    System.debug('Hold Amount After Case Created in Cash Collateral:'+holdAmount);
                    objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber;
                    objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                    objCase.ccol_Hold_Amount__c = holdAmount;
                    //CH03: Start
                    objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
                    //CH03: END
                    //CH24: Start
                    if(System.Label.ILA_WORLD_ENTITLEMENT_ENABLE.equalsIgnoreCase('true') && (objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01' || objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02') && objCase.Region_Flag__c == 'Bahrain'){
                          World_Elite_Entitlement__c wtlToInsert = CreateWorldEliteEntitCase.createWorldEntitlementCase(objCase.Account, objCase);
                    	  lstWorldEntitCase.add(wtlToInsert);
                    }
                    //CH24: END
                    //CH16: Start
                    if(objCase.Region_Flag__c == 'Jordan'){
                        objCase.Debit_Account_IBAN__c = String.valueOf(dataMap.get('debitAccountIban'));
                    }
                    //CH16: END
                    //lstUpdateCase.add(objCase);
                    //CH02: Start
                    //CH08: Start
                    if(objCase.Account.ID_Type__pc == 'Bahraini ID' && objCase.Region_Flag__c == 'Bahrain'){
                        objCase.cc_CPR_Number__c = objCase.Account.ID_Number__pc;
                        objCase.cc_CPR_Expiry_Date__c = objCase.Account.ID_Expiry_Date__pc;
                        //CH20: Start
                        objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
                        //CH20: END
                    }
                    //CH08: END
                    //CH08: Start
                    /*if(objCase.Account.ID_Type__pc == 'Jordanian ID' && objCase.Region_Flag__c == 'Jordan'){
                        objCase.ccjo_ID_Number__c = objCase.Account.ID_Number__pc;
                        objCase.ccjo_ID_Expiry_Date__c = objCase.Account.ID_Expiry_Date__pc;
                    }*/
                    //CH08: END
                    //CH02: END
                    lstUpdateCase.add(objCase);
                }
                //CH08: END
                //CH08: Added a Region Flag in if condition
                //CH09: Added Jordan Region Flag in if condition
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.cc_CC_Application_Source__c !='Api' && (objCase.Region_Flag__c == 'Bahrain'||objCase.Region_Flag__c == 'Jordan')){
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());// meta, data
                     // Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                       Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                       System.debug(dataMap);
                       String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                       Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                       Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                       //CH29: Start
                       Decimal currentLimit = (Decimal)dataMap.get('currentCreditLimit');
                       //CH29: END
                       System.debug('Hold Reference Number After Case Created in Cash Collateral LMT:'+holdReferenceNumber);
                       System.debug('Hold Account Balance After Case Created in Cash Collateral LMT:'+holdAccBalance);
                       System.debug('New Hold Amount After Case Created in Cash Collateral LMT :'+holdAmount);
                       System.debug('Current Credit Limit :'+currentLimit);
                       objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                       objCase.ccol_New_Hold_Amount__c = holdAmount;
                       //CH22: Start
                       objCase.ccol_Approved_Hold_Amount__c = holdAmount;
                       //CH22: END
                       objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber; 
                       //CH29: Start
                       objCase.cc_Current_Credit_Limit__c = currentLimit;
                       //CH29: END
                       objCase.cc_Application_Submission_Date_Time__c=objCase.cc_Application_Submission_Date_Time__c!=Null?objCase.cc_Application_Submission_Date_Time__c:System.today();
                       //CH07:Start
                       //CH16: Start
                       if(objCase.Region_Flag__c == 'Jordan'){
                            objCase.Debit_Account_IBAN__c = String.valueOf(dataMap.get('debitAccountIban'));
                        }
                      //CH16: END
                       //CH08: Start
                       if(objCase.Account.ID_Type__pc == 'Bahraini ID' && objCase.Region_Flag__c == 'Bahrain'){
                        objCase.cc_CPR_Number__c = objCase.Account.ID_Number__pc;
                        objCase.cc_CPR_Expiry_Date__c = objCase.Account.ID_Expiry_Date__pc;
                        //CH20: Start
                        objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
                        //CH20: END
                        }
                       //CH07: END
                       //CH08: END
                       lstUpdateCase.add(objCase);
                    }
                //CH05: END
                //CH08: END
            }
           
        }
        if(lstUpdateCase.size()>0){
            System.debug('List Upsert:'+lstUpdateCase);
            upsert lstUpdateCase;
        }
        if(lstSA.size()>0)
            insert lstSA;
        //CH24: Start
        if(lstWorldEntitCase.size()>0){
            insert lstWorldEntitCase;
        }
        //CH24: END
    }
    
    @future(callout=true)
    public static void CashCollateralCaseUpdate(Set<Id> setCaseId)
    {
        system.debug('setCaseId SIZE:'+setCaseId.size());
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Integer ApprovedCardProductConfigurationId;
        //CH31: Start
        Set<Id> setUpgradeCaseToInsert = new Set<Id>();
        //CH31: END
        //CH18: Start
        List<Case> lstPremiumInvitationCaseToInsert = new List<Case>();
		//CH18: END
		//CH26: Start
		List<Account> accListToUpdateRestrictCreditCard = new List<Account>();
        //CH26: END
        //CH04: Added Campaign Name, Approved Campaign Name in SOQL by #Jahangeer Mohammed# #15-08-2022#
        //CH08: Added fields Business Team L2, Business Team L3, Credit Admin, Card Operation in SOQL
        //CH15: Added LastModifiedBy.Name in the SOQL
        //CH17: Added ac_Iban__c in SOQL Query
        //CH18: Added cc_Approved_Embossing_line_4__c,cc_Embossing_Line_4__c,Is_Balance_Transfer__c,Has_Co_Brand_Membership_Number__c in SOQL Query
        //CH25: Added cc_Customer_Response__c in SOQL Query
        //CH26: Added Reapplying_Restriction_Period__c in the SOQL
        //CH27: adding ContactId,bs_Instrument_ID__c,Resend_DocuSign__c
        //CH30: added ,account.PersonContactId
        //CH31: Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query and Is_Initiated_from_Upgrade_Case__c in the SOQL
        List<Case> lstCase = [Select id, status, Sub_Status__c,cc_Application_Stages__c,Account.x_canary__pc, Type, Sub_Type__c,ccol_Hold_Account__c,ccol_Hold_Account_IBAN__c, cc_Requested_Card_Type__c, Customer_Segment__c,Customer_CIF__c, cc_Name_on_the_Card__c, Origin, Account.PersonEmail, Account.CIF__pc,cc_Credit_Card_PCI_Number__c,cc_CC_Application_Source__c,
                              /*cc_Activate_Reminders_for_Pending_Cases__c,*/ PrimaryCardProductConfigurationId__c, PrimaryCard__c, sc_Card_Holder_Mobile_No__c, sc_Card_Holder_Email_Address__c, sc_Relationship__c,ccol_Approved_Hold_Account__c,ccol_Approved_Hold_Amount__c,cc_Credit_Pre_Screening_Result__c,cc_Credit_Approval_Result__c,
                              cc_Business_Approval_Result__c,cc_CEO_Result__c,cc_HR_Result__c,cc_Signature_Verifier_Result__c,cc_Approved_Credit_Limit__c,cc_Approved_Requested_Card_Type__c,cc_Service_Centre_Result__c,cc_Operations_Result__c,cc_Approved_Transfer_Type__c,cc_Approved_Name_on_the_card__c,cc_Approved_Balance_Transfer_Amount__c,
                              ccol_Approved_Hold_Account_IBAN__c,Region_Flag__c,cc_Credit_Verification_Result__c,ccol_Hold_Account_Balance__c,ccol_New_Hold_Amount__c,ccol_Hold_Reference_Number__c,Campaign_Name__c,Approved_Campaign_Name__c,cc_Credit_Business_Team_L2_Result__c,cc_Credit_Business_Team_L3_Result__c,cc_Credit_Admin_Result__c,cc_Card_Operations_Result__c,
                              LastModifiedBy.Name,ac_Iban__c,cc_Approved_Embossing_line_4__c,cc_Embossing_Line_4__c,Is_Balance_Transfer__c,Has_Co_Brand_Membership_Number__c,Account.FirstName, Account.LastName,cc_Customer_Response__c,Reapplying_Restriction_Period__c,ContactId,bs_Instrument_ID__c,Resend_DocuSign__c,account.PersonContactId,Is_Initiated_from_Upgrade_Case__c
                              from Case where id in: setCaseId];
        for(Case objCase : lstCase){
            String body = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //CH10: Start
            //request = con.createRequest('PUT','/api/v1/credit-cards/request?',objCase.Region_Flag__c);
            request = con.createRequest('PUT',System.Label.CC_EndPointCreditCardRequest,objCase.Region_Flag__c);
            if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc);//CH12
            }
            //CH10: END
            //CH05: Added Cash Collateral Limit Increase condition in if condition
            //CH08: Added Region Flag in if condition
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			System.debug('Sub Status Value in Future Call:'+objCase.Sub_Status__c);
            System.debug('Application Stage in Future Call:'+objCase.cc_Application_Stages__c);
            if(((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'))  && objCase.Sub_Status__c == 'In-Progress' &&
              objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_HR_Result__c != 'Approved' && objCase.cc_HR_Result__c != 'Decline'  && 
              objCase.cc_Business_Approval_Result__c != 'Decline'  &&  objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' &&  objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' && objCase.cc_HR_Result__c !='Cancelled by Customer' &&
              objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer' && objCase.Region_Flag__c == 'Bahrain'){
                //CH04: Start
                //CH03: Start
                //CH08: Start Added a Region Flag in if condition
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain'){ 
                    //CH14: Start
                    if(objCase.Campaign_Name__c != null){
                        body = '{"crmCaseId": "'+objCase.Id + 
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","campaignId": "'+objCase.Campaign_Name__c +
                        '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS"}';
                    }
                    else if(objCase.Campaign_Name__c == null){
                         body = '{"crmCaseId": "'+objCase.Id + 
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","campaignId": null,"targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS"}';
                    }
                    //CH14: END
                }
                //CH08: END
                 //CH05: Start
                //CH08: Start Added a Region Flag in if condition
                //CH09: Added Jordan Region Flag in if condition
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Bahrain'){  
                     // Adding Cash Collateral Limit Increase Body in this block
                      body = '{"crmCaseId": "'+objCase.Id + 
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                }
                //CH08: END
                //CH05: END
                //CH03: END
                //CH04: END
                system.debug('---> BODY IN_PROGRESS FOR CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request IN_PROGRESS FOR CASH COLLATERAL--> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                    //CH04: Start
                    //CH08: Start Added a Region Flag in if condition
                    if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain'){
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                        //CH14: Start
                        if(dataMap.containsKey('campaign')){
                           Map<String, Object> dataMapCampaign = (Map<String, Object>)dataMap.get('campaign');
                           System.debug('Data Map Inside Campaign array:'+dataMapCampaign);
                           String campaignName = String.valueOf(dataMapCampaign.get('id'));
                           String campaignValidity = String.valueOf(dataMapCampaign.get('validity'));
                           System.debug('Campaign Name from API:'+campaignName);
                           System.debug('Campaign Validity from API:'+campaignValidity);
                           objCase.Campaign_Name__c = campaignName;
                           objCase.Campaign_Validity__c = campaignValidity; 
                        }
                        //CH14: END
                        lstUpdateCase.add(objCase);
                        //CH04: END
                    }
                    //CH08: END
                    //CH05: Start
                    //CH08: Start Added a Region Flag in if condition
                    //CH09: Added Jordan Region Flag in if condition
                    if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Bahrain'){
                       Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                       Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                       System.debug(dataMap);
                       String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                       Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                       Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                       System.debug('Hold Reference Number When Pre-screener Accepts in Cash Collateral LMT:'+holdReferenceNumber);
                       System.debug('Hold Account Balance When Pre-screener Accepts in Cash Collateral LMT:'+holdAccBalance);
                       System.debug('New Hold Amount When Pre-screener Accepts in Cash Collateral LMT :'+holdAmount);
                       objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                       objCase.ccol_New_Hold_Amount__c = holdAmount;
                       objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber; 
                       lstUpdateCase.add(objCase);
                    }
                    //CH05: END
                    //CH08: END
                }
            }
            //CH08: Start
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			  else if(((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'))  && objCase.Sub_Status__c == 'In-Progress' &&
              /*objCase.cc_Credit_Approval_Result__c != 'Approve' &&*/ objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_HR_Result__c != 'Approved' && objCase.cc_HR_Result__c != 'Decline'  && 
              objCase.cc_Business_Approval_Result__c != 'Decline'  &&  objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' &&  objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' && objCase.cc_HR_Result__c !='Cancelled by Customer' &&
              objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline'  && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Card_Operations_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Refer to Service Center' && objCase.cc_Credit_Admin_Result__c != 'Return to Signature Verification' && 
              objCase.cc_Credit_Admin_Result__c != 'Refer to service center' && objCase.cc_Card_Operations_Result__c != 'Refer to service center' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer' && objCase.Region_Flag__c == 'Jordan'){
                
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan'){ 
                    body = '{"crmCaseId": "'+objCase.Id + 
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","targetType": "CREDIT_CARD_ORDER","status":"IN_PROGRESS"}';
                }
                
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan'){  
                     // Adding Cash Collateral Limit Increase Body in this block
                      body = '{"crmCaseId": "'+objCase.Id + 
                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                            '","targetType": "LIMIT_INCREASE","status":"IN_PROGRESS","cardNature":"secured"}';
                }
                
                system.debug('---> BODY IN_PROGRESS FOR CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request IN_PROGRESS FOR CASH COLLATERAL--> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                    if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan'){
                      //Commented as per RM-5577
                       Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                       Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                       System.debug(dataMap);
                       /*String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                       Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                       Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                       System.debug('Hold Reference Number When Pre-screener Accepts in Cash Collateral LMT:'+holdReferenceNumber);
                       System.debug('Hold Account Balance When Pre-screener Accepts in Cash Collateral LMT:'+holdAccBalance);
                       System.debug('New Hold Amount When Pre-screener Accepts in Cash Collateral LMT :'+holdAmount);
                       objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                       objCase.ccol_New_Hold_Amount__c = holdAmount;
                       objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber; 
                       lstUpdateCase.add(objCase);*/
                    }
                }
            }
            //CH08: END
            //CH08: Start Added a Region Flag in if condition
            else if((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') && objCase.Sub_Status__c == 'Discrepancies' && objCase.cc_Credit_Pre_Screening_Result__c == 'Discrepancy in Documents' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')){
                body = '{"crmCaseId": "'+objCase.Id +
                    '","targetType": "CREDIT_CARD_ORDER","status":"DISCREPANCIES"}';
                
                system.debug('---> BODY IN DISCREPANCY FOR CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in DISCREPANACY FOR CASH COLLATERAL--> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug('Response in DISCREPANACY: '+response.getBody());
                    System.debug(' CREDIT TEMP QUEUE');
                    
                }
                
            }
            //CH08: END
           //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
           //CH08: Added a Region Flag in if condition
           //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			else if(((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Bahrain')) && (objCase.Sub_Status__c == 'Referred by Approver' || objCase.Sub_Status__c == 'Referred  by Pre-Screener') && objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline'  && objCase.cc_Business_Approval_Result__c != 'Decline' 
                    && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Accept' && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' && objCase.cc_Credit_Approval_Result__c  !='Cancelled by Customer' && objCase.cc_HR_Result__c !='Cancelled by Customer' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                //CH05: Start
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                    if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_APPROVER"}';
                    }
                    else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_PRESCREENER"}';
                    }
                }
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                     if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_APPROVER","cardNature":"secured"}';
                    }
                }
                //CH05: END
                system.debug('---> BODY in REFER CONDITION FOR CASH COLLATERAL BAHRAIN --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request FOR CASH COLLATERAL --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                }
            }
            //CH08: END
            
            /************************************************** START : REFER BY ACTION LOGIC FOR JORDAN *****************************************************************************************/
            //CH08: Start Added if block Logic for Jordan
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			else if((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan') && (objCase.Sub_Status__c == 'Referred by Approver' || objCase.Sub_Status__c == 'Referred  by Pre-Screener') && 
               objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Approval_Result__c != 'Cancelled by Customer'  && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired'  && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' &&
               objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                   
                   if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                       if(objCase.Sub_Status__c == 'Referred by Approver'){
                           body = '{"crmCaseId": "'+objCase.Id +
                               '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_APPROVER"}';
                       }
                       else if(objCase.Sub_Status__c == 'Referred  by Pre-Screener'){
                           body = '{"crmCaseId": "'+objCase.Id +
                               '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_PRESCREENER"}';
                       }
                   }
             if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                     if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_APPROVER","cardNature":"secured"}';
                    }
                }
                   system.debug('---> BODY in REFER CONDITION FOR CASH COLLATERAL JORDAN --> '+body);               
                   request.setBody(body);
                   request.setHeader('userId', objCase.Account.PersonEmail);
                   request.setHeader('customerId', objCase.Account.CIF__pc);
                   
                   system.debug('---> request FOR CASH COLLATERAL --> '+request.getBody());
                   HttpResponse response = http.send(request);
                   
                   if (response.getStatusCode() != 200) 
                   {
                       System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                       //CH19: Added isAPIFailed parameter in the method
                       lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                   } 
                   else 
                   {
                       System.debug(response.getBody());
                   }
               }
            //CH08: END
            /************************************************** END : REFER BY ACTION LOGIC FOR JORDAN *****************************************************************************************/
			            
            /************************************************** START : CASH COLLATERAL REFER BY ACTION LOGIC FOR JORDAN *****************************************************************************************/
            //CH09: Start Added if block Logic for Jordan
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			else if((objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan') && (objCase.Sub_Status__c == 'Referred by Approver' || objCase.Sub_Status__c == 'Referred  by Pre-Screener') && 
               objCase.cc_Credit_Approval_Result__c != 'Approve' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Approval_Result__c != 'Cancelled by Customer'  && objCase.cc_Credit_Pre_Screening_Result__c != 'Expired'  && objCase.cc_Credit_Pre_Screening_Result__c !='Cancelled by Customer' &&
               objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                   
                  if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                     if(objCase.Sub_Status__c == 'Referred by Approver'){
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_APPROVER","cardNature":"secured"}';
                    }
                }
                   system.debug('---> BODY in REFER CONDITION FOR CASH COLLATERAL JORDAN --> '+body);               
                   request.setBody(body);
                   request.setHeader('userId', objCase.Account.PersonEmail);
                   request.setHeader('customerId', objCase.Account.CIF__pc);
                   
                   system.debug('---> request FOR CASH COLLATERAL --> '+request.getBody());
                   HttpResponse response = http.send(request);
                   
                   if (response.getStatusCode() != 200) 
                   {
                       System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                       //CH19: Added isAPIFailed parameter in the method
                       lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                   } 
                   else 
                   {
                       System.debug(response.getBody());
                   }
               }
            //CH09: END
            /************************************************** END : CASH COLLATERAL REFER BY ACTION LOGIC FOR JORDAN *****************************************************************************************/
            
            /**************************************** START : CREDIT APPROVER APPROVES/HR RESULT APPROVES FOR BAHRAIN ****************************************/
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase & HR Result is been added in if block
            //CH08: Start Added a Region Flag in if condition 
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            //#CH27 : add && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App'
			else if((((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Bahrain')) && objCase.cc_Credit_Approval_Result__c == 'Approve' && objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline'  &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c!= 'Decline' && objCase.cc_Service_Centre_Result__c != 'Return to Signature Verifier' &&
                    objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' && objCase.cc_Signature_Verifier_Result__c != 'Refer to Service Center' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer') ||
                    objCase.cc_HR_Result__c == 'Approved' && objCase.Sub_Status__c == 'Pending Signature Verification' &&  objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                        //#CH27 : start
                        Map<String, String> bodyObject = new Map<String, String>{
                            'crmCaseId' => objCase.Id
                        };
                        //CH04: Start
                        //CH03: Start
                        //CH05: Start
                        if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                            if(objCase.cc_Credit_Approval_Result__c == 'Approve'){
                                //CH14: Start
                                //CH18: Start
                                if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                    /*body = '{"crmCaseId": "'+objCase.Id +
                                	'","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                	'","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                	'","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                	'","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';*/
                                    bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                    bodyObject.put('campaignId',String.valueOf(objCase.Approved_Campaign_Name__c));
                                    bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                    bodyObject.put('targetType','CREDIT_CARD_ORDER');
                                    bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                                }
                                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                    /*body = '{"crmCaseId": "'+objCase.Id +
                                	'","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                	'","campaignId": null,"creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                	'","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';*/
                                    bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                    bodyObject.put('campaignId',null);
                                    bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                    bodyObject.put('targetType','CREDIT_CARD_ORDER');
                                    bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                                }
                                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                                    if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
                                        /*body = '{"crmCaseId": "'+objCase.Id +
                                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                            '","campaignId": null,"membershipNumber": null,"status":"APPROVED_PENDING_SIGNATURE"}';*/
                                        bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                        bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                        bodyObject.put('campaignId',null);
                                        bodyObject.put('membershipNumber',null);
                                        bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                                    }
                                    else if(objCase.cc_Approved_Embossing_line_4__c != null){
                                        /*body = '{"crmCaseId": "'+objCase.Id +
                                            '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +    
                                            '","campaignId": null,"status":"APPROVED_PENDING_SIGNATURE"}';*/
                                        bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                        bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                        bodyObject.put('membershipNumber',String.valueOf(objCase.cc_Approved_Embossing_line_4__c));
                                        bodyObject.put('campaignId',null);
                                        bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                                    }
                                    
                            	}
                                //CH18: END
                                //CH14: END 
                            }
                            if(objCase.cc_HR_Result__c == 'Approved'){
                                /*body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}'; */
                                bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                                bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                                bodyObject.put('targetType','CREDIT_CARD_ORDER');
                                bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            }    
                           
                        }
                        //CH03: END
                        //CH04: END
                        if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                            /*body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE","cardNature":"secured"}';*/
                            bodyObject.put('cardProductConfigurationId',String.valueOf(objCase.PrimaryCardProductConfigurationId__c));
                            bodyObject.put('creditLimit',String.valueOf(objCase.cc_Approved_Credit_Limit__c));
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            bodyObject.put('cardNature','secured');
                        }
                        //CH05: END
                        system.debug('---> BODY IN APPROVED PENDING SIGNATURE IN CASH COLLATERAL --> '+body); 
                        if( (objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') && objCase.bs_Instrument_ID__c != null){
                            system.debug('---> envelopeId  --> '+objCase.bs_Instrument_ID__c);
                            if(objCase.Resend_DocuSign__c == 'In-App'){
                                bodyObject.put('signingType','IN_APP');
                                bodyObject.put('envelopeId',objCase.bs_Instrument_ID__c);
                                bodyObject.put('crmContactId',objCase.ContactId);
                            }
                            else if(objCase.Resend_DocuSign__c == 'Email'){
                                bodyObject.put('signingType','EMAIL');
                                bodyObject.put('envelopeId',null);
                                bodyObject.put('crmContactId',null);
                            }
                        }
                        body = JSON.serialize(bodyObject);
                        //#CH27 : End            
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request in CREDIT APPROVAL RESULT in cash collateral--> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug('Response in Approval: '+response.getBody());
                            System.debug(' CREDIT CARD APPROVAL RESULT IN CASH COLLATERAL');
                        }
                    }
            //CH08: END
            /**************************************** END : CREDIT APPROVER APPROVES/HR RESULT APPROVES FOR BAHRAIN ****************************************/
            
            /***************************************** START : CREDIT APPROVER APPROVES FOR JORDAN ******************************************************************/
            //CH08: Start
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            //#CH27 : add && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App'
			else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Approval_Result__c == 'Approve' && objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Service_Centre_Result__c != 'Return to Signature Verifier' && objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Credit_Admin_Result__c != 'Return to Signature Verification' && objCase.cc_Credit_Admin_Result__c != 'Accept' && objCase.cc_Credit_Admin_Result__c != 'Refer to service center' &&
                    objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                        
                        if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                            if(objCase.cc_Credit_Approval_Result__c == 'Approve'){
                                body = '{"crmCaseId": "'+objCase.Id +
                                    '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';
                            }
                        }
                        system.debug('---> BODY IN APPROVED PENDING SIGNATURE IN CASH COLLATERAL JORDAN --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request in CREDIT APPROVAL RESULT in cash collateral jordan--> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug('Response in Approval: '+response.getBody());
                            System.debug(' CREDIT CARD APPROVAL RESULT IN CASH COLLATERAL JORDAN');
                        }
            }
            //CH08: END
            
            /***************************************** END : CREDIT APPROVER APPROVES FOR JORDAN ******************************************************************/
 
             
            /***************************************** START : CASH COLLATERAL LIMIT INCREASE CREDIT APPROVER APPROVES FOR JORDAN ******************************************************************/
            //CH09: Start
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
            //#CH27 : add && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App'
			else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Approval_Result__c == 'Approve' && objCase.Sub_Status__c == 'Pending Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Service_Centre_Result__c != 'Return to Signature Verifier' && objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer'){
                        
                         if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                             body = '{"crmCaseId": "'+objCase.Id +
                                '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE","cardNature":"secured"}';
                        }
                        system.debug('---> BODY IN APPROVED PENDING SIGNATURE IN CASH COLLATERAL JORDAN --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request in CREDIT APPROVAL RESULT in cash collateral jordan--> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug('Response in Approval: '+response.getBody());
                            System.debug(' CREDIT CARD APPROVAL RESULT IN CASH COLLATERAL JORDAN');
                        }
            }
            //CH09: END
            
            /***************************************** END :  CASH COLLATERAL LIMIT INCREASE CREDIT APPROVER APPROVES FOR JORDAN ******************************************************************/
            
            //CH05: Start
             /**************************************** START : SIGNATURE VERIFIER CLOSE CASE FOR CASH COLLATERAL LIMIT UPDATE - BAHRAIN & JORDAN******************************************/
            //CH08: Start Added a Region Flag in if condition
            //CH09: Added Region Flag
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && (objCase.Region_Flag__c == 'Bahrain'|| objCase.Region_Flag__c == 'Jordan') && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Credit_Admin_Result__c != 'Return to Signature Verification' && 
                    objCase.cc_Credit_Admin_Result__c != 'Refer to service center' && objCase.cc_Credit_Admin_Result__c != 'Accept' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer')
                    {
                        Http http1 = new Http();
                        HttpRequest request1 = new HttpRequest();
                       //CH10: Start
                        //request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true', objCase.Region_Flag__c);
                        request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, objCase.Region_Flag__c);
                       //CH10: END 
                        request1.setHeader('userId', objCase.Account.PersonEmail);
                        request1.setHeader('customerId', objCase.Account.CIF__pc);
                        // request1.setHeader('includeOtherProducts', 'true');
                        
                        system.debug('---> request1 --> '+request1.getBody());
                        HttpResponse response1 = http1.send(request1);
                        system.debug('---> Response New 111 --> '+response1.getBody());
                        
                        if (response1.getStatusCode() != 200) 
                        {   
                            System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            
                        } 
                        else 
                        {
                            if(!test.isRunningTest()){
                                System.debug(response1.getBody());      
                                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                                System.debug('---> MAP m 222 --> '+m);  // meta, data
                                System.debug('---> MAP m VALUES 222 --> '+m.Values());
                                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                                System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                                List<Object> m2 = new List<Object>();
                                if(m1.containsKey('cardOptions') != null)
                                    m2=(List<Object>)m1.get('cardOptions');
                                else if(m1.containsKey('pendingCards') != null)
                                    m2=(List<Object>)m1.get('pendingCards'); 
                                //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                                
                                System.debug('---> LIST m2 222--> '+m2);
                                
                                List<Map<String, Object>> a = new List<Map<String, Object>> ();
                                
                                for(Object obj : m2)
                                {
                                    a.add((Map<String, Object>)obj);
                                    {
                                        system.debug('---->> OBJ Iterations 222--> '+obj);
                                    }
                                }
                                system.debug('---->> FINALL aaaa 222--> '+a);
                                
                                for(Map<String, Object> map1 : a)
                                {
                                    if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                    {
                                        system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                        ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                        system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                    }
                                }
                            }
                        }
                        
                        if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                            //CH17: Start
                            if(objCase.ccol_Hold_Account__c != 'FIXED_DEPOSIT'){
                                 body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                '","crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED","cardNature":"secured"}';
                            }
                            else if(objCase.ccol_Hold_Account__c == 'FIXED_DEPOSIT'){
                                body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                '","crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","holdAccountId":"'+objCase.ac_Iban__c+
                                '","holdAccountIdNew":"'+objCase.ccol_Hold_Account_IBAN__c+ 
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED","cardNature":"secured"}';
                            }
                            //CH17: END
                        }
                        system.debug('---> BODY --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if(response.getStatusCode() != 200 && !test.isRunningTest()) {
                            
                            if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                                objCase.cc_Signature_Verifier_Result__c = '';
                            }
                            lstUpdateCase.add(objCase);
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                            Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                            Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                            System.debug(dataMap);
                            String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                            Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                            Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                            System.debug('Hold Reference Number in Signature Verifier:'+holdReferenceNumber);
                            System.debug('Hold Account Balance In Signature Verifier:'+holdAccBalance);
                            System.debug('New Hold Amount in Signature Verifier :'+holdAmount);
                           // objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                           //  objCase.ccol_New_Hold_Amount__c = holdAmount;
                            objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber;
                            objCase.Status = 'Closed';
                            objCase.Sub_Status__c = 'Approved';
                            objCase.cc_Application_Stages__c = 'Completed';
                            objCase.cc_CRM_Stage__c = 'APPROVED';
                            //objCase.cc_isDocumentReceived__c = true;
                            objCase.cc_Signature_Verification_Date_Time__c = System.now();
                            //CH31: Start
                    		if(objCase.Is_Initiated_from_Upgrade_Case__c == true && objCase.Region_Flag__c == 'Bahrain'){
                       			setUpgradeCaseToInsert.add(objCase.Id);
                    		}
                    		//CH31: END
                            lstUpdateCase.add(objCase);

                            //#CH30 : Start
                            if(objCase.Resend_DocuSign__c == 'In-App' && objCase.Region_Flag__c == 'Bahrain'){SendEmailService.CC_sendEmailWithAtachements(objCase,'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));}
                            //#CH30: End
                        }
                        
                        
                    }
            //CH08: END
             /**************************************** END : SIGNATURE VERIFIER CLOSE CASE FOR CASH COLLATERAL LIMIT UPDATE - BAHRAIN ******************************************/
      //CH05: END 
            
            /**************************************** START : SIGNATURE VERIFIER CLOSE CASE FOR ILA BLUE/BLACK - BAHRAIN ****************************************/
            //CH08: Start Added a Region Flag in if condition
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			//CH18: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline'  && objCase.cc_CEO_Result__c != 'Decline' &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer' &&
                    (objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && objCase.Is_Balance_Transfer__c == false && objCase.cc_Approved_Requested_Card_Type__c != '')){
                        Http http1 = new Http();
                        HttpRequest request1 = new HttpRequest();
                        //CH10: Start
                        //request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true',objCase.Region_Flag__c);
                        request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts,objCase.Region_Flag__c);
                        //CH10: END
                        request1.setHeader('userId', objCase.Account.PersonEmail);
                        request1.setHeader('customerId', objCase.Account.CIF__pc);
                        // request1.setHeader('includeOtherProducts', 'true');
                        
                        system.debug('---> request1 --> '+request1.getBody());
                        HttpResponse response1 = http1.send(request1);
                        system.debug('---> Response New 111 --> '+response1.getBody());
                        
                        if (response1.getStatusCode() != 200) 
                        {   
                            System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            
                        } 
                        else 
                        {
                            System.debug(response1.getBody());      
                            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                            System.debug('---> MAP m 222 --> '+m);  // meta, data
                            System.debug('---> MAP m VALUES 222 --> '+m.Values());
                            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                            System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                            List<Object> m2 = new List<Object>();
                            if(m1.containsKey('cardOptions') != null)
                                m2=(List<Object>)m1.get('cardOptions');
                            else if(m1.containsKey('pendingCards') != null)
                                m2=(List<Object>)m1.get('pendingCards'); 
                            //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                            
                            System.debug('---> LIST m2 222--> '+m2);
                            
                            List<Map<String, Object>> a = new List<Map<String, Object>> ();
                            
                            for(Object obj : m2)
                            {
                                a.add((Map<String, Object>)obj);
                                {
                                    system.debug('---->> OBJ Iterations 222--> '+obj);
                                }
                            }
                            system.debug('---->> FINALL aaaa 222--> '+a);
                            
                            for(Map<String, Object> map1 : a)
                            {
                                if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                {
                                    system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                    ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                    system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                }
                            }
                            
                        }
                        if(objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01'){
                            if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                                //CH14: Start
                                //CH18: Start
                                if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                    body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                    '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                    '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                    '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                }
                                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                                    body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                    '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                    '","campaignId": null,"targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                }
                                else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                                    if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
                                        body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                            '","crmCaseId": "'+objCase.Id +
                                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                            '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                            '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                            '","campaignId": null,"membershipNumber": null,"targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                    }
                                    else if(objCase.cc_Approved_Embossing_line_4__c != null){
                                        body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                            '","crmCaseId": "'+objCase.Id +
                                            '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                            '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                            '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                                            '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                            '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                            '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                            '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                            '","campaignId": null,"targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                    }
                                    
                                }
                                //CH18: END
                               //CH14: END
                            }
                            
                            system.debug('---> BODY IN CASH COLLATERAL FOR NON BALANCE TRANSFER CARDS --> '+body);               
                            request.setBody(body);
                            request.setHeader('userId', objCase.Account.PersonEmail);
                            request.setHeader('customerId', objCase.Account.CIF__pc);
                            
                            system.debug('---> REQUEST IN CASH COLLATERAL FOR NON BALANCE TRANSFER CARDS  --> '+request.getBody());
                            HttpResponse response = http.send(request);
                            
                            if(response.getStatusCode() != 200 && !test.isRunningTest()) {
                                
                                if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                                    objCase.cc_Signature_Verifier_Result__c = '';
                                    objCase.cc_Signature_Verification_Date_Time__c = System.now();
                                }
                                lstUpdateCase.add(objCase);
                                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                //CH19: Added isAPIFailed parameter in the method
                                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            } 
                            else 
                            {
                                System.debug(response.getBody());
                                System.debug(response.getBody());
                                //CH23: Start
                                List<String> CREDIT_CARD_TYPE = System.Label.CREDIT_CARD_TYPE.split(',');
                                //CH23: END
                                //CH18: Start
                                if(objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' && objCase.cc_Approved_Requested_Card_Type__c != null && (objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null)){
                                     Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                	 Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                                     System.debug('Success Response Signature Verifier:'+dataMap);
                                     String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                                     objCase.cc_Embossing_Line_4__c = membershipNumber;
                                     objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                                     if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                        //CH23: Start
                                        Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH23: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     }
                                     //CH21: Start
                                     else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        //CH23: Start
                                        Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH23: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     }
                                     //CH21: END 
                                     
                                }
                                else if(objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Embossing_line_4__c != null){
                                    if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                        //CH23: Start
                                        Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH23: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     }
                                     //CH21: Start
                                     else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        //CH23: Start
                                        Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     	//CH23: END
                                        lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     }
                                     //CH21: END 
                                }
                                //CH18: END
                                //CH23: Start
                                else if(System.Label.ENABLE_CROSS_SELLING.equalsIgnoreCase('true') && CREDIT_CARD_TYPE.contains(objCase.cc_Approved_Requested_Card_Type__c) && objCase.Customer_Segment__c == 'Regular'){
                                    //CH23: Start
                                    Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                    //CH23: END
                                    lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                }
                                else if(System.Label.ENABLE_CROSS_SELLING.equalsIgnoreCase('true') && CREDIT_CARD_TYPE.contains(objCase.cc_Approved_Requested_Card_Type__c) && objCase.Customer_Segment__c == 'Premium'){
                                    //CH23: Start
                                    Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                    //CH23: END
                                    lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                }
                                //CH23: END
                                objCase.Status = 'Closed';
                                objCase.Sub_Status__c = 'Approved';
                                objCase.cc_Application_Stages__c = 'Completed';
                                objCase.cc_CRM_Stage__c = 'APPROVED';
                                objCase.cc_Signature_Verification_Date_Time__c = system.now();
                                lstUpdateCase.add(objCase);
                                
                                //#CH30 : Start
                                if(objCase.Resend_DocuSign__c == 'In-App' && objCase.Region_Flag__c == 'Bahrain'){SendEmailService.CC_sendEmailWithAtachements(objCase,'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));}
                                //#CH30: End
                            }
                        }     
                    }
            //CH08: END
            /**************************************** END : SIGNATURE VERIFIER CLOSE CASE FOR ILA BLUE/BLACK - BAHRAIN ****************************************/
            
            /**************************************** START : SIGNATURE VERIFIER RESULT IS ACCEPT FOR ILA SWITCH-BALANCE TRANSFER - BAHRAIN ****************************************/
            //CH08: Start Added a Region Flag in if condition
            //CH13: Added a condition Signature Verifier Result != Decline and Signature Verifier Result != Cancelled by Customer in if condition
			//CH18: Added Is_Balance_Transfer__c in if condition for Cobranded Cards
            else if((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain' && objCase.cc_Signature_Verifier_Result__c == 'Accept' && objCase.cc_Operations_Result__c != 'Balance Transfer Processed' && objCase.cc_Credit_Approval_Result__c != 'Decline'  &&
                     objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Cancelled by Customer') &&
                    (((objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Balance Transfer'))){
                        
                        Http http1 = new Http();
                        HttpRequest request1 = new HttpRequest();
                        //CH10: Start
                       // request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true',objCase.Region_Flag__c);
                        request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts,objCase.Region_Flag__c);
                        //CH10: END
                        
                        request1.setHeader('userId', objCase.Account.PersonEmail);
                        request1.setHeader('customerId', objCase.Account.CIF__pc);
                        // request1.setHeader('includeOtherProducts', 'true');
                        
                        system.debug('---> request1 --> '+request1.getBody());
                        HttpResponse response1 = http1.send(request1);
                        system.debug('---> Response New 111 --> '+response1.getBody());
                        
                        if (response1.getStatusCode() != 200) 
                        {   
                            System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            
                        }
                        else 
                        {
                            
                            System.debug(response1.getBody());      
                            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                            System.debug('---> MAP m 222 --> '+m);  // meta, data
                            System.debug('---> MAP m VALUES 222 --> '+m.Values());
                            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                            System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                            List<Object> m2 = new List<Object>();
                            if(m1.containsKey('cardOptions') != null)
                                m2=(List<Object>)m1.get('cardOptions');
                            else if(m1.containsKey('pendingCards') != null)
                                m2=(List<Object>)m1.get('pendingCards'); 
                            //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                            
                            System.debug('---> LIST m2 222--> '+m2);
                            
                            List<Map<String, Object>> a = new List<Map<String, Object>> ();
                            
                            for(Object obj : m2)
                            {
                                a.add((Map<String, Object>)obj);
                                {
                                    system.debug('---->> OBJ Iterations 222--> '+obj);
                                }
                            }
                            system.debug('---->> FINALL aaaa 222--> '+a);
                            
                            for(Map<String, Object> map1 : a)
                            {
                                if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                {
                                    system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                    ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                    system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                }
                            }
                            
                            if((objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' || objCase.Is_Balance_Transfer__c == true) && objCase.cc_Approved_Transfer_Type__c == 'Balance Transfer'){
                                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                                    //CH14: Start
                                    //CH18: Start
                                    if(objCase.Approved_Campaign_Name__c != null && objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                                        body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                        '","crmCaseId": "'+objCase.Id +
                                        '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                        '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                        '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                        '","campaignId": "'+objCase.Approved_Campaign_Name__c +
                                        '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                    }
                                    else if(objCase.Approved_Campaign_Name__c == null && objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                                        body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                        '","crmCaseId": "'+objCase.Id +
                                        '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                        '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                        '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                        '","campaignId": null,"targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                    }
                                    else if(objCase.Approved_Campaign_Name__c == null && objCase.Is_Balance_Transfer__c == true){
                                        if(objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null){
                                            body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                                '","crmCaseId": "'+objCase.Id +
                                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                                '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                                '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                                '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                                '","campaignId": null,"membershipNumber": null,"targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                        }
                                        else if(objCase.cc_Approved_Embossing_line_4__c != null){
                                            body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                                '","crmCaseId": "'+objCase.Id +
                                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                                '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                                                '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                                '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                                '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                                '","campaignId": null,"targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                                        }
                                    }
                                    //CH18: END
                                   //CH14: END
                                }
                                
                                system.debug('---> BODY IN ILA SWITCH-BALANCE TRANSFER FOR CASH COLLATERAL --> '+body);               
                                request.setBody(body);
                                request.setHeader('userId', objCase.Account.PersonEmail);
                                request.setHeader('customerId', objCase.Account.CIF__pc);
                                
                                system.debug('---> request in ILA SWITCH-BALANCE TRANSFER FOR CASH COLLATERAL --> '+request.getBody());
                                HttpResponse response = http.send(request);
                                if (response.getStatusCode() != 200) 
                                {
                                    if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                                        objCase.cc_Signature_Verifier_Result__c = '';
                                        objCase.cc_Signature_Verification_Date_Time__c = System.now();
                                    }
                                    lstUpdateCase.add(objCase);
                                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                    //CH19: Added isAPIFailed parameter in the method
                                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                                } 
                                else 
                                {
                                    System.debug('Response in ILA SWITCH-BALANCE TRANSFER IN CASH COLLATERAL : '+response.getBody());
                                    System.debug(' SIGNATURE VERIFICATION ACCEPT FOR ILA SWITCH-BALANCE TRANSFER IN CASH COLLATERAL');
                                    
                                    //CH18: Start
                                    if(objCase.Is_Balance_Transfer__c == true && (objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null)){
                                         Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                                         Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                                         System.debug('Success Response at Signature Verifier for Balance Transfer:'+dataMap);
                                         String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                                         objCase.cc_Embossing_Line_4__c = membershipNumber;
                                         objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                        	//CH23: Start
                                            Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH23: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     	 }
                                         //CH21: Start
                                     	else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        	//CH23: Start
                                            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH23: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     	}
                                     	//CH21: END 
                                         
                                    }
                                    else if(objCase.Is_Balance_Transfer__c == true && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Embossing_line_4__c != null){
                                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                                             //CH23: Start
                                             Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                             //CH23: END
                                             lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                         }
                                        //CH21: Start
                                     	else if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Premium'){
                                        	//CH23: Start
                                            Case cseToInsert = CreatePremiumRetentionCase.createPremiumCase(objCase.Account,objCase.cc_Approved_Requested_Card_Type__c,objCase.cc_Approved_Name_on_the_card__c);
                                     		//CH23: END
                                            lstPremiumInvitationCaseToInsert.add(cseToInsert);
                                     	}
                                     	//CH21: END 
                                	 }
                                    //CH18: END
                                    objCase.OwnerId = System.Label.Credit_Card_Regular_Buyout;
                                    objCase.cc_Application_Stages__c = 'Credit Buyout';
                                    objCase.Sub_Status__c = 'Approved';
                                    objCase.cc_CRM_Stage__c = 'APPROVED';
                                    objCase.cc_Signature_Verification_Date_Time__c = system.now();
                                    /*if(objCase.cc_HR_Result__c == 'Approved'){
objCase.cc_HR_Result_Date_Time__c = system.now();
}*/
                                    lstUpdateCase.add(objCase);
                                    //#CH30 : Start
                                    if(objCase.Resend_DocuSign__c == 'In-App' && objCase.Region_Flag__c == 'Bahrain'){ SendEmailService.CC_sendEmailWithAtachements(objCase,'ILA_CreditCard_Send_SignedDocs',System.Label.CreditCard_DocuSignFilesKeywords.split(';'));}
                                    //#CH30: End
                                }
                            } 
                            
                        }
                    }
            //CH08: END
            /*************************************** END : SIGNATURE VERIFIER RESULT IS ACCEPT FOR ILA SWITCH-BALANCE TRANSFER - BAHRAIN ****************************************/
            
            /**************************************** START : SIGNATURE VERIFIER RESULT IS RE-SEND - (BAHRAIN & JORDAN) ****************************************/
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
            //CH08: Start Removes the Decline conditions from if block
            //#CH27 : add || objCase.cc_Signature_Verifier_Result__c == 'Re-Send In-App'
            else if(((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral') || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase')) && (objCase.cc_Signature_Verifier_Result__c == 'Re-Send' || objCase.cc_Signature_Verifier_Result__c == 'Re-Send In-App') ){
                       
                        //#CH26 : start
                        Map<String, String> bodyObject = new Map<String, String>{
                            'crmCaseId' => objCase.Id
                        };

                       //CH08: Added Decline conditions from if block
                       //CH13: Added a condition Signature Verifier Result != Decline in if condition
						if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                           objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                            /*body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';*/
                            bodyObject.put('targetType','CREDIT_CARD_ORDER');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                        }
                		//CH08: END
                		//CH08: Added Decline conditions from if block
                		//CH13: Added a condition Signature Verifier Result != Decline in if condition
                        if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Bahrain' && objCase.cc_Credit_Approval_Result__c != 'Decline' && 
                           objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                           
                            /*body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE","cardNature":"secured"}'; */
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            bodyObject.put('cardNature','secured');
                        }
                        //CH08: END
                        //CH08: Start Added if block for Jordan
                        //CH13: Added a condition Signature Verifier Result != Decline in if condition
                        if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                           objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                            /*body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';*/
                            bodyObject.put('targetType','CREDIT_CARD_ORDER');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                        }
                        //CH08: END
                       	//CH09: Added Decline conditions from if block
                       	//CH13: Added a condition Signature Verifier Result != Decline in if condition
                        if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                           objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                           
                            /*body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE","cardNature":"secured"}'; */
                            bodyObject.put('targetType','LIMIT_INCREASE');
                            bodyObject.put('status','APPROVED_PENDING_SIGNATURE');
                            bodyObject.put('cardNature','secured');
                        }
                        //CH09: END
                        system.debug('---> BODY IN RESEND Approved Pending Signature FOR SIGNATURE VERIFICATION CASH COLLATERAL --> '+body);
                        if( (objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') && objCase.bs_Instrument_ID__c != null){
                            system.debug('---> envelopeId  --> '+objCase.bs_Instrument_ID__c);
                            if(objCase.cc_Signature_Verifier_Result__c == 'Re-Send In-App'){
                                bodyObject.put('signingType','IN_APP');
                                bodyObject.put('envelopeId',objCase.bs_Instrument_ID__c);
                                bodyObject.put('crmContactId',objCase.ContactId);
                                objCase.Resend_DocuSign__c = 'In-App';
                                lstUpdateCase.add(objCase);
                            }
                            else if(objCase.cc_Signature_Verifier_Result__c == 'Re-Send'){
                                bodyObject.put('signingType','EMAIL');
                                bodyObject.put('envelopeId',null);
                                bodyObject.put('crmContactId',null);
                                objCase.Resend_DocuSign__c = 'Email';
                                lstUpdateCase.add(objCase);
                            }
                        }
                        body = JSON.serialize(bodyObject);
                        //#CH27 : End               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request in Approved Pending Signature FOR SIGNATURE VERIFICATION CASH COLLATERAL --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug('Response in Approved Pending Signature FOR SIGNATURE VERIFICATION : '+response.getBody());
                            System.debug(' SIGNATURE VERIFICATION RE_SEND');
                        }
                    }
            //CH08: END
            /**************************************** END : SIGNATURE VERIFIER RESULT IS RE-SEND - (BAHRAIN & JORDAN) ****************************************/
            
            /******************************* START : SIGNATURE VERIFIER RESULT IS REFER TO SERVICE CENTER - (BAHRAIN & JORDAN) ****************************************/
            //CH08: Start Removes the Decline conditions from if block
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.cc_Signature_Verifier_Result__c == 'Refer to Service Center'){
                //CH08: Added Decline conditions from if block
                //CH13: Added a condition Signature Verifier Result != Decline in if condition
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Bahrain' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                   objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                       body = '{"crmCaseId": "'+objCase.Id +
                           '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
                   }
                //CH08: END
                //CH08: Start Added if block for Jordan
                //CH13: Added a condition Signature Verifier Result != Decline in if condition
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                   objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                       body = '{"crmCaseId": "'+objCase.Id +
                           '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
                }
                //CH08: END
                system.debug('---> BODY IN SIGNATURE VERIFIER IF REFER TO SERVICE CENTER IN CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in SIGNATURE VERIFIER IF REFER TO SERVICE CENTER IN CASH COLLATERAL ---> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug('Response in SIGNATURE VERIFIER IF REFER TO SERVICE CENTER IN CASH COLLATERAL - : '+response.getBody());
                    System.debug(' SIGNATURE VERIFICATION REFER TO SERVICE CENTER IN CASH COLLATERAL');
                }
            }
            //CH08: END
            /******************************* END : SIGNATURE VERIFIER RESULT IS  REFER TO SERVICE CENTER - (BAHRAIN & JORDAN)  ****************************************/
            
             
            /******************************* START : CREDIT CARD CASH COLLATERAL LIMIT INCREASE SIGNATURE VERIFIER RESULT IS REFER TO SERVICE CENTER - (JORDAN) ****************************************/
            //CH09: Start Removes the Decline conditions from if block
            else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.cc_Signature_Verifier_Result__c == 'Refer to Service Center'){
                //CH08: Start Added if block for Jordan
                //CH13: Added a condition Signature Verifier Result != Decline in if condition
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Approval_Result__c != 'Decline' &&
                   objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline'  && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                       body = '{"crmCaseId": "'+objCase.Id +
                           '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_SIGNATURE_VERIFIER"}';
                }
                //CH08: END
                system.debug('---> BODY IN SIGNATURE VERIFIER IF REFER TO SERVICE CENTER IN CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in SIGNATURE VERIFIER IF REFER TO SERVICE CENTER IN CASH COLLATERAL ---> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug('Response in SIGNATURE VERIFIER IF REFER TO SERVICE CENTER IN CASH COLLATERAL - : '+response.getBody());
                    System.debug(' SIGNATURE VERIFICATION REFER TO SERVICE CENTER IN CASH COLLATERAL');
                }
            }
            //CH09: END
            /******************************* END : CREDIT CARD CASH COLLATERAL LIMIT INCREASE SIGNATURE VERIFIER RESULT IS REFER TO SERVICE CENTER - (JORDAN)  ****************************************/
            
            /****************************************** START: CREDIT CARD CASH COLLATERAL LIMIT INCREASE SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER - (JORDAN) ******************************************/
            //CH09: Start Added Business Team L2, Business Team L3, Credit Admin Result if block
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            //#CH27 : add && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App'
            else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.cc_Service_Centre_Result__c == 'Return to Signature Verifier' && objCase.cc_Signature_Verifier_Result__c != 'Accept'  && objCase.cc_Signature_Verifier_Result__c != 'Re-Send' && objCase.cc_Signature_Verifier_Result__c != 'Re-Send In-App' &&
                    objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Business_Approval_Result__c != 'Decline' && objCase.cc_CEO_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' &&
                    objCase.cc_Credit_Admin_Result__c != 'Return to Signature Verification' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        //CH08: Added a Region Flag if block
                        if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && (objCase.Region_Flag__c == 'Jordan')){    
                               body = '{"crmCaseId": "'+objCase.Id +
                                   		'","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE"}';
                        } 
                		//CH08: END
                		
                        system.debug('---> BODY WHEN SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
                        
                    }
            //CH09: END
            /****************************************** END: CREDIT CARD CASH COLLATERAL LIMIT INCREASE SERVICE CENTER RESULT IS RETURN TO SIGNATURE VERIFIER - (JORDAN) ******************************************/
            
            
            /******************************************* START: CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER - JORDAN **********************************************************************/
            //CH08: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Admin_Result__c == 'Return to Signature Verification' &&
                    objCase.cc_Credit_Admin_Result__c != 'Accept' && objCase.cc_Credit_Admin_Result__c != 'Refer to service center' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline'  && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED_PENDING_SIGNATURE"}';
                        
                        system.debug('---> BODY WHEN CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER JORDAN  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
                    }
            
            //CH08: END
            /******************************************* END: CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER - JORDAN **********************************************************************/
            
              /******************************************* START: CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER - JORDAN **********************************************************************/
            //CH09: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Admin_Result__c == 'Return to Signature Verification' &&
                    objCase.cc_Credit_Admin_Result__c != 'Accept' && objCase.cc_Credit_Admin_Result__c != 'Refer to service center' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline'  && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"APPROVED_PENDING_SIGNATURE"}';
                        
                        system.debug('---> BODY WHEN CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER JORDAN  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
                    }
            
            //CH09: END
            /******************************************* END: CARD ADMIN RESULT IS RETURN TO SIGNATURE VERIFIER - JORDAN **********************************************************************/
 
            /******************************************* START: CARD ADMIN RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/
            //CH08: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Admin_Result__c == 'Refer to service center' &&
                    objCase.cc_Credit_Admin_Result__c != 'Accept' && objCase.cc_Credit_Admin_Result__c != 'Return to Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline'  && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_CREDIT_ADMIN"}';
                        
                        system.debug('---> BODY WHEN CARD ADMIN RESULT IS REFER TO SERVICE CENTER JORDAN  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request CARD ADMIN RESULT IS REFER TO SERVICE CENTER JORDAN --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
              }
            
            //CH08: END
            /******************************************* END: CARD ADMIN RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/
            
                /******************************************* START: CARD ADMIN RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/
            //CH09: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Credit_Admin_Result__c == 'Refer to service center' &&
                    objCase.cc_Credit_Admin_Result__c != 'Accept' && objCase.cc_Credit_Admin_Result__c != 'Return to Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "LIMIT_INCREASE","status":"REFERRED_BY_CREDIT_ADMIN"}';
                        
                        system.debug('---> BODY WHEN CARD ADMIN RESULT IS REFER TO SERVICE CENTER JORDAN  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request CARD ADMIN RESULT IS REFER TO SERVICE CENTER JORDAN --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
              }
            
            //CH09: END
            /******************************************* END: CARD ADMIN RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/

			 /**************************************** START : CARD OPERATION CLOSE CASE FOR ILA BLUE/BLACK - JORDAN ****************************************/
            //CH08: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Card_Operations_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline'  && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline' &&
                    (objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01' && objCase.cc_Approved_Requested_Card_Type__c != '')){
                        Http http1 = new Http();
                        HttpRequest request1 = new HttpRequest();
                        //CH10: Start
                        //request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true',objCase.Region_Flag__c);
                        request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts,objCase.Region_Flag__c);
                        //CH10: END
                        request1.setHeader('userId', objCase.Account.PersonEmail);
                        request1.setHeader('customerId', objCase.Account.CIF__pc);
                        // request1.setHeader('includeOtherProducts', 'true');
                        
                        system.debug('---> request1 --> '+request1.getBody());
                        HttpResponse response1 = http1.send(request1);
                        system.debug('---> Response New 111 --> '+response1.getBody());
                        
                        if (response1.getStatusCode() != 200) 
                        {   
                            System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            
                        } 
                        else 
                        {
                            System.debug(response1.getBody());      
                            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                            System.debug('---> MAP m 222 --> '+m);  // meta, data
                            System.debug('---> MAP m VALUES 222 --> '+m.Values());
                            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                            System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                            List<Object> m2 = new List<Object>();
                            if(m1.containsKey('cardOptions') != null)
                                m2=(List<Object>)m1.get('cardOptions');
                            else if(m1.containsKey('pendingCards') != null)
                                m2=(List<Object>)m1.get('pendingCards'); 
                            //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                            
                            System.debug('---> LIST m2 222--> '+m2);
                            
                            List<Map<String, Object>> a = new List<Map<String, Object>> ();
                            
                            for(Object obj : m2)
                            {
                                a.add((Map<String, Object>)obj);
                                {
                                    system.debug('---->> OBJ Iterations 222--> '+obj);
                                }
                            }
                            system.debug('---->> FINALL aaaa 222--> '+a);
                            
                            for(Map<String, Object> map1 : a)
                            {
                                if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                {
                                    system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                    ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                    system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                }
                            }
                            
                        }
                        if(objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01'){
                            if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                                body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                    '","crmCaseId": "'+objCase.Id +
                                    '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                    '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                    '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                    '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                                    '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                                    '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                            }
                            
                            system.debug('---> BODY IN CASH COLLATERAL FOR NON BALANCE TRANSFER CARDS ILA BLUE JORDAN --> '+body);               
                            request.setBody(body);
                            request.setHeader('userId', objCase.Account.PersonEmail);
                            request.setHeader('customerId', objCase.Account.CIF__pc);
                            
                            system.debug('---> REQUEST IN CASH COLLATERAL FOR NON BALANCE TRANSFER CARDS ILA BLUE JORDAN  --> '+request.getBody());
                            HttpResponse response = http.send(request);
                            
                            if(response.getStatusCode() != 200 && !test.isRunningTest()) {
                                
                                if(objCase.cc_Card_Operations_Result__c == 'Accept'){
                                    objCase.cc_Card_Operations_Result__c = '';
                                }
                                lstUpdateCase.add(objCase);
                                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                                //CH19: Added isAPIFailed parameter in the method
                                lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            } 
                            else 
                            {
                                System.debug(response.getBody());
                                objCase.Status = 'Closed';
                                objCase.Sub_Status__c = 'Approved';
                                objCase.cc_Application_Stages__c = 'Completed';
                                objCase.cc_CRM_Stage__c = 'APPROVED';
                                objCase.cc_Card_Operations_Result_Date_Time__c = system.now();
                                lstUpdateCase.add(objCase);
                            }
                        }     
                    }
            //CH08: END
            /**************************************** END : CARD OPERATION CLOSE CASE FOR ILA BLUE/BLACK - JORDAN ****************************************/
            
			
			 /**************************************** START :CASH COLLATERAL LIMIT INCREASE CARD OPERATION CLOSE CASE - JORDAN ****************************************/
            //CH09: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Card_Operations_Result__c == 'Accept' && objCase.cc_Credit_Approval_Result__c != 'Decline'  && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' &&
                    objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        Http http1 = new Http();
                        HttpRequest request1 = new HttpRequest();
                       //CH10: Start
                        //request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true', objCase.Region_Flag__c);
                        request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts, objCase.Region_Flag__c);
                       //CH10: END 
                        request1.setHeader('userId', objCase.Account.PersonEmail);
                        request1.setHeader('customerId', objCase.Account.CIF__pc);
                        // request1.setHeader('includeOtherProducts', 'true');
                        
                        system.debug('---> request1 --> '+request1.getBody());
                        HttpResponse response1 = http1.send(request1);
                        system.debug('---> Response New 111 --> '+response1.getBody());
                        
                        if (response1.getStatusCode() != 200) 
                        {   
                            System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                            
                        } 
                        else 
                        {
                            if(!test.isRunningTest()){
                                System.debug(response1.getBody());      
                                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                                System.debug('---> MAP m 222 --> '+m);  // meta, data
                                System.debug('---> MAP m VALUES 222 --> '+m.Values());
                                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                                System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                                List<Object> m2 = new List<Object>();
                                if(m1.containsKey('cardOptions') != null)
                                    m2=(List<Object>)m1.get('cardOptions');
                                else if(m1.containsKey('pendingCards') != null)
                                    m2=(List<Object>)m1.get('pendingCards'); 
                                //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                                
                                System.debug('---> LIST m2 222--> '+m2);
                                
                                List<Map<String, Object>> a = new List<Map<String, Object>> ();
                                
                                for(Object obj : m2)
                                {
                                    a.add((Map<String, Object>)obj);
                                    {
                                        system.debug('---->> OBJ Iterations 222--> '+obj);
                                    }
                                }
                                system.debug('---->> FINALL aaaa 222--> '+a);
                                
                                for(Map<String, Object> map1 : a)
                                {
                                    if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                                    {
                                        system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                                        ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                                        system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                                    }
                                }
                            }
                        }
                        
                        if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                            //CH17: Start
                            if(objCase.ccol_Hold_Account__c != 'FIXED_DEPOSIT'){
                                 body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                '","crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED","cardNature":"secured"}';
                            }
                            else if(objCase.ccol_Hold_Account__c == 'FIXED_DEPOSIT'){
                                body = '{"cardProductConfigurationId": "'+ApprovedCardProductConfigurationId +
                                '","crmCaseId": "'+objCase.Id +
                                '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                                '","holdAccountId":"'+objCase.ac_Iban__c+
                                '","holdAccountIdNew":"'+objCase.ccol_Hold_Account_IBAN__c+
                                '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                                '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                                '","targetType": "LIMIT_INCREASE","status":"APPROVED","cardNature":"secured"}';
                            }
                            //CH17: END
                           
                        }
                        system.debug('---> BODY --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if(response.getStatusCode() != 200 && !test.isRunningTest()) {
                            
                            if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                                objCase.cc_Signature_Verifier_Result__c = '';
                            }
                            lstUpdateCase.add(objCase);
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                            Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                            Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                            System.debug(dataMap);
                            String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                            Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                            Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                            System.debug('Hold Reference Number in Signature Verifier:'+holdReferenceNumber);
                            System.debug('Hold Account Balance In Signature Verifier:'+holdAccBalance);
                            System.debug('New Hold Amount in Signature Verifier :'+holdAmount);
                           // objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                          //  objCase.ccol_New_Hold_Amount__c = holdAmount;
                            objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber;
                            objCase.Status = 'Closed';
                            objCase.Sub_Status__c = 'Approved';
                            objCase.cc_Application_Stages__c = 'Completed';
                            objCase.cc_CRM_Stage__c = 'APPROVED';
                            //objCase.cc_isDocumentReceived__c = true;
                            objCase.cc_Signature_Verification_Date_Time__c = System.now();
                            lstUpdateCase.add(objCase);
                        }        
                    }
                    
            //CH09: END
            /**************************************** END :CASH COLLATERAL LIMIT INCREASE CARD OPERATION CLOSE CASE- JORDAN ****************************************/
            
            /******************************************* START: CARD OPERATION RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/
            //CH08: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Card_Operations_Result__c == 'Refer to service center' &&
                    objCase.cc_Card_Operations_Result__c != 'Accept' && objCase.cc_Card_Operations_Result__c != 'Return to Signature Verification' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_OPERATIONS"}';
                        
                        system.debug('---> BODY WHEN CARD OPERATION RESULT IS REFER TO SERVICE CENTER JORDAN  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request CARD OPERATION RESULT IS REFER TO SERVICE CENTER JORDAN --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
              }
            
            //CH08: END
            /******************************************* END: CARD OPERATION RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/
            
                       
			/******************************************* START: CASH COLLATERAL LIMIT INCREASE CARD OPERATION RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/
            //CH09: Start
            //CH13: Added a condition Signature Verifier Result != Decline in if condition
            else if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && objCase.Region_Flag__c == 'Jordan' && objCase.cc_Card_Operations_Result__c == 'Refer to service center' &&
                    objCase.cc_Card_Operations_Result__c != 'Accept' && objCase.cc_Card_Operations_Result__c != 'Return to Credit Admin' && objCase.cc_Credit_Approval_Result__c != 'Decline' && objCase.cc_Credit_Pre_Screening_Result__c != 'Decline' &&
                    objCase.cc_Credit_Business_Team_L2_Result__c != 'Decline' && objCase.cc_Credit_Business_Team_L3_Result__c != 'Decline' && objCase.cc_Signature_Verifier_Result__c != 'Decline'){
                        
                        body = '{"crmCaseId": "'+objCase.Id +
                            '","targetType": "CREDIT_CARD_ORDER","status":"REFERRED_BY_OPERATIONS"}';
                        
                        system.debug('---> BODY WHEN CARD OPERATION RESULT IS REFER TO SERVICE CENTER JORDAN  --> '+body);               
                        request.setBody(body);
                        request.setHeader('userId', objCase.Account.PersonEmail);
                        request.setHeader('customerId', objCase.Account.CIF__pc);
                        
                        system.debug('---> request CARD OPERATION RESULT IS REFER TO SERVICE CENTER JORDAN --> '+request.getBody());
                        HttpResponse response = http.send(request);
                        
                        if (response.getStatusCode() != 200) 
                        {
                            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                            //CH19: Added isAPIFailed parameter in the method
                            lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Cash Collateral Credit Limit Increase Application', 'Cash Collateral Credit Limit Increase',true);
                        } 
                        else 
                        {
                            System.debug(response.getBody());
                        }
              }
            
            //CH09: END
            /******************************************* END:  CASH COLLATERAL LIMIT INCREASE CARD CARD OPERATION RESULT IS REFER TO SERVICE CENTER - JORDAN *************************************************************/

            
            /*********************************** Start : HR APPROVAL RESULT IS APPROVE - BAHRAIN ************************************************************/
            //CH08: Start Added a Region Flag in if condition
            else if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && objCase.cc_HR_Result__c == 'Approved' && objCase.Region_Flag__c == 'Bahrain'){
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                //CH10: Start
                //request1 = con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true',objCase.Region_Flag__c);
                request1 = con.createRequest('GET',System.Label.CC_EndPointGetCreditCardsIncludingOtherProducts,objCase.Region_Flag__c);
                //CH10: END
                
                request1.setHeader('userId', objCase.Account.PersonEmail);
                request1.setHeader('customerId', objCase.Account.CIF__pc);
                // request1.setHeader('includeOtherProducts', 'true');
                
                system.debug('---> request1 --> '+request1.getBody());
                HttpResponse response1 = http1.send(request1);
                system.debug('---> Response New 111 --> '+response1.getBody());
                
                if (response1.getStatusCode() != 200) 
                {   
                    System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request1.getBody(),response1.getBody(),request1.getEndpoint(),'GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                    
                } 
                else 
                {
                    System.debug(response1.getBody());      
                    Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
                    System.debug('---> MAP m 222 --> '+m);  // meta, data
                    System.debug('---> MAP m VALUES 222 --> '+m.Values());
                    Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                    System.debug('---> MAP m1 222--> '+m1);  // currentCards,pendingCards,cardOptions
                    List<Object> m2 = new List<Object>();
                    if(m1.containsKey('cardOptions') != null)
                        m2=(List<Object>)m1.get('cardOptions');
                    else if(m1.containsKey('pendingCards') != null)
                        m2=(List<Object>)m1.get('pendingCards'); 
                    //List<Object> m2 = (List<Object>)m1.get('cardOptions');
                    
                    System.debug('---> LIST m2 222--> '+m2);
                    
                    List<Map<String, Object>> a = new List<Map<String, Object>> ();
                    
                    for(Object obj : m2)
                    {
                        a.add((Map<String, Object>)obj);
                        {
                            system.debug('---->> OBJ Iterations 222--> '+obj);
                        }
                    }
                    system.debug('---->> FINALL aaaa 222--> '+a);
                    
                    for(Map<String, Object> map1 : a)
                    {
                        if(map1.get('productMappingCode')== objCase.cc_Approved_Requested_Card_Type__c)
                        {
                            system.debug('---> FINALL 222 --> '+(Integer)map1.get('cardProductConfigurationId'));
                            ApprovedCardProductConfigurationId = (Integer)map1.get('cardProductConfigurationId');
                            system.debug('---> FINALL cardProductConfigurationId 222--> '+ApprovedCardProductConfigurationId);
                        }
                    }
                    
                } 
                
                
                if(objCase.cc_Approved_Requested_Card_Type__c != 'PLATINUM_BALANCE_TRANSFER_01'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                        '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                        '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                    
                    system.debug('---> BODY --> '+body);               
                    request.setBody(body);
                    request.setHeader('userId', objCase.Account.PersonEmail);
                    request.setHeader('customerId', objCase.Account.CIF__pc);
                    
                    system.debug('---> request in HR APPROVE FOR NON BALANCE IN CASH COLLATERAL--> '+request.getBody());
                    HttpResponse response = http.send(request);
                    
                    if (response.getStatusCode() != 200 && !test.isRunningTest()) {
                        
                        if(objCase.cc_HR_Result__c == 'Approved')
                            objCase.cc_HR_Result__c = '';
                        lstUpdateCase.add(objCase);
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        //CH19: Added isAPIFailed parameter in the method
                        lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                    } 
                    else 
                    {
                        System.debug(response.getBody());
                        System.debug('Response in HR APPROVE FOR NON BALANCE TRANSFER IN CASH COLLATERAL : '+response.getBody());
                        System.debug(' HR APPROVE FOR  NON BALANCE TRANSFER IN CASH COLLATERAL');
                        if(objCase.cc_HR_Result__c == 'Approved' && objCase.Type == 'Credit Card Cash Collateral Application'){
                            objCase.cc_HR_Result_Date_Time__c = system.now();
                            objCase.Status = 'Closed';
                            objCase.Sub_Status__c = 'Approved';
                            objCase.cc_CRM_Stage__c = 'APPROVED';
                            objCase.cc_Application_Stages__c = 'Completed';
                        }
                        lstUpdateCase.add(objCase);
                    }       
                }
                else if(objCase.cc_Approved_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01' && objCase.cc_Approved_Transfer_Type__c == 'Balance Transfer'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","creditLimit": "'+objCase.cc_Approved_Credit_Limit__c +
                        '","balanceTransferAmount": "'+objCase.cc_Approved_Balance_Transfer_Amount__c +
                        '","embossName": "'+objCase.cc_Approved_Name_on_the_card__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                        '","targetType": "CREDIT_CARD_ORDER","status":"APPROVED","cardNature":"secured"}';
                    
                    
                    system.debug('---> BODY IN HR APPROVE FOR BALANCE TRANSFER FOR CASH COLLATERAL --> '+body);               
                    request.setBody(body);
                    request.setHeader('userId', objCase.Account.PersonEmail);
                    request.setHeader('customerId', objCase.Account.CIF__pc);
                    
                    system.debug('---> request in HR APPROVE FOR BALANCE TRANSFER IN CASH COLLATERAL --> '+request.getBody());
                    HttpResponse response = http.send(request);
                    if (response.getStatusCode() != 200) 
                    {
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        //CH19: Added isAPIFailed parameter in the method
                        lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                    } 
                    else 
                    {
                        System.debug('Response in HR APPROVE FOR BALANCE TRANSFER IN CASH COLLATERAL : '+response.getBody());
                        System.debug(' HR APPROVE FOR BALANCE TRANSFER IN CASH COLLATERAL');
                        if(objCase.cc_HR_Result__c == 'Approved' && objCase.Type == 'Credit Card Cash Collateral Application'){
                            objCase.cc_HR_Result_Date_Time__c = system.now();
                            objCase.OwnerId = System.Label.Credit_Card_Regular_Buyout;
                            objCase.cc_Application_Stages__c = 'Credit Buyout';
                            objCase.Sub_Status__c = 'Approved';
                            objCase.cc_CRM_Stage__c = 'APPROVED';
                        }
                        lstUpdateCase.add(objCase);
                    }
                } 
            }
            //CH08: END
            /*********************************** END : HR APPROVAL RESULT IS APPROVE - BAHRAIN ************************************************************/
            
            /*********************************** START : CASH COLLATERAL DECLINE - (BAHRAIN & JORDAN) ******************************************************************/
            //CH05: Added Type and Sub Type related to Cash Collateral Limit Increase and credit verification Result field in if block
            //CH08: Added a Region Flag, Business Team L2, and Business Team L3 in if condition
            //CH09: Cash Collateral Limit increase JORDAN Added a Region Flag, Business Team L2, and Business Team L3 in if condition
            //CH13: Added a condition Signature Verifier Result = Decline in if condition
            else if(((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')) || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan'))) && (objCase.cc_Credit_Approval_Result__c == 'Decline' || objCase.cc_HR_Result__c == 'Decline' || objCase.cc_Business_Approval_Result__c == 'Decline' ||  objCase.cc_Credit_Pre_Screening_Result__c == 'Decline' || objCase.cc_CEO_Result__c == 'Decline' || objCase.cc_Credit_Verification_Result__c == 'Decline' || objCase.cc_Credit_Business_Team_L2_Result__c == 'Decline' || objCase.cc_Credit_Business_Team_L3_Result__c == 'Decline' || objCase.cc_Signature_Verifier_Result__c == 'Decline')){
                //CH01 : Start
                //CH03: Start
                //CH05 : Start
                if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                    body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                        '","targetType": "CREDIT_CARD_ORDER","status":"DECLINED","cardNature":"secured"}';
                }
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                    //CH17: Start
                    if(objCase.ccol_Hold_Account__c != 'FIXED_DEPOSIT'){
                        body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                        '","targetType": "LIMIT_INCREASE","status":"DECLINED","cardNature":"secured"}';
                    }
                    else if(objCase.ccol_Hold_Account__c == 'FIXED_DEPOSIT'){
                        body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ac_Iban__c+
                        '","holdAccountIdNew":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+ 
                        '","targetType": "LIMIT_INCREASE","status":"DECLINED","cardNature":"secured"}';
                    }
                   //CH17: END 
                }
                //CH05 : END
                //CH03: END
                //CH01 : END
                system.debug('---> BODY IN DECLINE FOR CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in DECLINE FOR CASH COLLATERAL --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                    //CH05: Start
                    if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                        objCase.Status = 'Closed';
                        objCase.Sub_Status__c = 'Declined';
                        objCase.cc_CRM_Stage__c = 'DECLINED';
                        objCase.Awaiting_Customer_Feedback__c = false;
                        //CH25: Start
                     	objCase.cc_Customer_Response__c  = '';
                    	//CH25: END
                        
                        if(objCase.cc_CEO_Result__c == 'Decline'){
                            //CH26: Start
                            if((objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/ && objCase.Region_Flag__c == 'Bahrain'){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                                accListToUpdateRestrictCreditCard.add(acc);
                            }
                        	//CH26: END
                            objCase.cc_CEO_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit CEO';
                        }
                        if(objCase.cc_Credit_Approval_Result__c == 'Decline'){
                            //CH26: Start
                            if((objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/ && objCase.Region_Flag__c == 'Bahrain'){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                                accListToUpdateRestrictCreditCard.add(acc);
                            }
                        	//CH26: END
                            objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Approval';
                        }
                        if(objCase.cc_HR_Result__c == 'Decline')
                            objCase.cc_HR_Result_Date_Time__c = system.now();
                        
                        if(objCase.cc_Business_Approval_Result__c == 'Decline'){
                            //CH26: Start
                            if((objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/ && objCase.Region_Flag__c == 'Bahrain'){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                                accListToUpdateRestrictCreditCard.add(acc);
                            }
                        	//CH26: END
                            objCase.cc_Business_Approval_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Business Team';
                        }
                        if(objCase.cc_Credit_Pre_Screening_Result__c == 'Decline'){
                            //CH26: Start
                            if((objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/ && objCase.Region_Flag__c == 'Bahrain'){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                                accListToUpdateRestrictCreditCard.add(acc);
                            }
                        	//CH26: END
                            objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                        }
                        //CH13: Start
                    	if(objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                            //CH26: Start
                            if((objCase.Type == 'Credit Card Cash Collateral Application' || objCase.Type == 'Cash Collateral Credit Limit Increase Application') /*&& objCase.Reapplying_Restriction_Period__c != null*/ && objCase.Region_Flag__c == 'Bahrain'){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                                accListToUpdateRestrictCreditCard.add(acc);
                            }
                        	//CH26: END
                        	objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        	objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    	}
                        //CH13: END
                        lstUpdateCase.add(objCase);
                    }
                    if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                        System.debug(dataMap);
                        String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                        Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                        Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                        System.debug('Hold Reference Number in CC Limit Increase Decline:'+holdReferenceNumber);
                        System.debug('Hold Account Balance CC Limit Increase Decline:'+holdAccBalance);
                        System.debug('New Hold Amount CC Limit Increase Decline :'+holdAmount);
                        objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                        objCase.ccol_New_Hold_Amount__c = holdAmount;
                        objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber;
                        objCase.Status = 'Closed';
                        objCase.Sub_Status__c = 'Declined';
                        objCase.cc_CRM_Stage__c = 'DECLINED';
                        objCase.Awaiting_Customer_Feedback__c = false;
                        //CH25: Start
                     	objCase.cc_Customer_Response__c  = '';
                    	//CH25: END
                        if(objCase.cc_Credit_Approval_Result__c == 'Decline'){
                            //CH26: Start
                            if(objCase.Region_Flag__c == 'Bahrain' /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            	accListToUpdateRestrictCreditCard.add(acc);
                            }
                            //CH26: END
                            
                            objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Approval';
                        }
                        if(objCase.cc_Business_Approval_Result__c == 'Decline'){
                             //CH26: Start
                            if(objCase.Region_Flag__c == 'Bahrain' /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            	accListToUpdateRestrictCreditCard.add(acc);
                            }
                            //CH26: END
                            objCase.cc_Business_Approval_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Business Team';
                        }
                        if(objCase.cc_HR_Result__c == 'Decline')
                            objCase.cc_HR_Result_Date_Time__c = system.now();
                        if(objCase.cc_Credit_Pre_Screening_Result__c == 'Decline'){
                             //CH26: Start
                            if(objCase.Region_Flag__c == 'Bahrain' /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            	accListToUpdateRestrictCreditCard.add(acc);
                            }
                            //CH26: END
                            objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                        }
                        if(objCase.cc_Credit_Verification_Result__c == 'Decline'){
                            objCase.cc_Credit_Verification_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'CRM Team';
                        }
                        //CH08: Start
                        if(objCase.cc_Credit_Business_Team_L2_Result__c == 'Decline'){
                            objCase.cc_Credit_Business_TeamL2ResultDateTime__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Business Team L2';
                        }
                        if(objCase.cc_Credit_Business_Team_L3_Result__c == 'Decline'){
                            objCase.cc_Credit_Business_TeamL3ResultDateTime__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Business Team L3';
                        }
                        //CH08: END
                        //CH13: Start
                    	if(objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                             //CH26: Start
                            if(objCase.Region_Flag__c == 'Bahrain' /*&& objCase.Reapplying_Restriction_Period__c != null*/){
                                Account acc = restrictAccountToApplyCard(objCase,objCase.AccountId);
                            	accListToUpdateRestrictCreditCard.add(acc);
                            }
                            //CH26: END
                        	objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        	objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    	}
                       //CH13: END
                        lstUpdateCase.add(objCase);
                    }
                    //CH05: END
                }
            }
            //CH08: END
            /*********************************** END : CASH COLLATERAL DECLINE - (BAHRAIN & JORDAN) ******************************************************************/
            
            /*********************************** START: CASH COLLATERAL CANCELLED BY CUSTOMER - (BAHRAIN & JORDAN) ***********************************************************/
           //CH06: Added Type and Sub Type related to Cash Collateral Limit Increase in if block
           //CH08: Start Added a Region Flag
           //CH09: Added Jordan Region Flag
           //CH13: Added a condition Signature Verifier Result = Cancelled by Customer in if condition
           else if(((objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral' && (objCase.Region_Flag__c == 'Bahrain' || objCase.Region_Flag__c == 'Jordan')) || (objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase' && (objCase.Region_Flag__c == 'Bahrain'|| objCase.Region_Flag__c == 'Jordan'))) && (objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer' || objCase.cc_HR_Result__c == 'Cancelled by Customer' || objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer' || objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer')){
               //CH01 : Start
                //CH03: Start
                //CH06: Start
               if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                   body = '{"crmCaseId": "'+objCase.Id +
                       '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                       '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                       '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                       '","targetType": "CREDIT_CARD_ORDER","status":"CANCELLED","cardNature":"secured"}';
                }
                //CH03: END
                if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                    //CH17: Start
                    if(objCase.ccol_Hold_Account__c != 'FIXED_DEPOSIT'){
                        body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ccol_Approved_Hold_Account_IBAN__c+
                        '","targetType": "LIMIT_INCREASE","status":"CANCELLED","cardNature":"secured"}';
                    }
                    else if(objCase.ccol_Hold_Account__c == 'FIXED_DEPOSIT'){
                        body = '{"crmCaseId": "'+objCase.Id +
                        '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                        '","holdAccountType":"'+objCase.ccol_Approved_Hold_Account__c+
                        '","holdAccountId":"'+objCase.ac_Iban__c+
                        '","holdAccountIdNew":"'+objCase.ccol_Hold_Account_IBAN__c+  
                        '","targetType": "LIMIT_INCREASE","status":"CANCELLED","cardNature":"secured"}';
                    }
                    //CH17: END
                }
                //CH06: END
               //CH01 : END
                system.debug('---> BODY IN CANCELLED IN CASH COLLATERAL --> '+body);               
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> request in CANCEL IN CASH COLLATERAL --> '+request.getBody());
                HttpResponse response = http.send(request);
                
                if (response.getStatusCode() != 200) 
                {
                    if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Approval_Result__c = '';
                    if(objCase.cc_HR_Result__c == 'Cancelled by Customer')
                        objCase.cc_HR_Result__c = '';
                    if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer')
                        objCase.cc_Credit_Pre_Screening_Result__c = '';
                    //CH13: Start
                    if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer')
                        objCase.cc_Signature_Verifier_Result__c = '';
                    //CH13: END
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    //CH19: Added isAPIFailed parameter in the method
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Cash Collateral Application', 'New Cash Collateral',true);
                } 
                else 
                {
                    System.debug(response.getBody());
                    //CH06: Start
                    if(objCase.Type == 'Credit Card Cash Collateral Application' && objCase.Sub_Type__c == 'New Cash Collateral'){
                        objCase.Status = 'Closed';
                        objCase.Sub_Status__c = 'Cancelled';
                        objCase.cc_CRM_Stage__c = 'CANCELLED';
                        //CH25: Start
                     	objCase.cc_Customer_Response__c  = '';
                    	//CH25: END
                        
                        if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer'){
                            objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Approval';
                        }
                        if(objCase.cc_HR_Result__c == 'Cancelled by Customer'){
                            objCase.cc_HR_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit HR Team';
                        }
                        if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer'){
                            objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                        }
                        //CH13: Start
                    	if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                        	objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        	objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    	}
                        //CH13: END
                        //CH15: Start
                    	if(objCase.LastModifiedBy.Name == 'AWS Integration' || objCase.LastModifiedBy.Name == 'AWS (Jordan) Integration'){
                        	objCase.Alias_account__c = 'API';
                    	}
                    	else if(objCase.LastModifiedBy.Name != 'AWS Integration' && objCase.LastModifiedBy.Name != 'AWS (Jordan) Integration'){
                        	objCase.Alias_account__c = 'Manual';
                    	}
                    	//CH15: END
                        lstUpdateCase.add(objCase);
                    }
                    if(objCase.Type == 'Cash Collateral Credit Limit Increase Application' && objCase.Sub_Type__c == 'Cash Collateral Credit Limit Increase'){
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                        System.debug(dataMap);
                        String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                        Decimal holdAccBalance = (Decimal)dataMap.get('holdAccountBalance');
                        Decimal holdAmount = (Decimal)dataMap.get('holdAmount');
                        System.debug('Hold Reference Number in CC Limit Increase Cancelled:'+holdReferenceNumber);
                        System.debug('Hold Account Balance CC Limit Increase Cancelled:'+holdAccBalance);
                        System.debug('New Hold Amount CC Limit Increase Cancelled :'+holdAmount);
                        objCase.ccol_Hold_Account_Balance__c = holdAccBalance;
                        objCase.ccol_New_Hold_Amount__c = holdAmount;
                        objCase.ccol_Hold_Reference_Number__c = holdReferenceNumber;
                        objCase.Status = 'Closed';
                        objCase.Sub_Status__c = 'Cancelled';
                        objCase.cc_CRM_Stage__c = 'CANCELLED';
                        objCase.Awaiting_Customer_Feedback__c = false;
                        //CH25: Start
                     	objCase.cc_Customer_Response__c  = '';
                    	//CH25: END
                        
                        if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer'){
                            objCase.cc_Credit_Approval_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Approval';
                        }
                        if(objCase.cc_HR_Result__c == 'Cancelled by Customer')
                            objCase.cc_HR_Result_Date_Time__c = system.now();
                        if(objCase.cc_Credit_Pre_Screening_Result__c == 'Cancelled by Customer'){
                            objCase.cc_Credit_Pre_Screening_Result_Date_Time__c = system.now();
                            objCase.cc_Application_Stages__c = 'Credit Pre-Screening';
                        }
                        //CH13: Start
                    	if(objCase.cc_Signature_Verifier_Result__c == 'Cancelled by Customer'){
                        	objCase.cc_Signature_Verification_Date_Time__c = system.now();
                        	objCase.cc_Application_Stages__c = 'Credit Signature Verification';
                    	}
                        //CH13: END
                        //CH15: Start
                    	if(objCase.LastModifiedBy.Name == 'AWS Integration' || objCase.LastModifiedBy.Name == 'AWS (Jordan) Integration'){
                        	objCase.Alias_account__c = 'API';
                    	}
                    	else if(objCase.LastModifiedBy.Name != 'AWS Integration' && objCase.LastModifiedBy.Name != 'AWS (Jordan) Integration'){
                        	objCase.Alias_account__c = 'Manual';
                    	}
                    	//CH15: END
                        lstUpdateCase.add(objCase);
                    }
                    //CH06: END
                }
            }
            //CH08: END
            /*********************************** END: CASH COLLATERAL CANCELLED BY CUSTOMER - (BAHRAIN & JORDAN) ***********************************************************/
            
        }
        if(lstUpdateCase.size()>0)
            update lstUpdateCase;
        if(lstSA.size()>0)
            insert lstSA;
        //CH18: Start
        if(lstPremiumInvitationCaseToInsert.size()>0){
            insert lstPremiumInvitationCaseToInsert;
        }
        //CH18: END
        //CH26: Start
        if(accListToUpdateRestrictCreditCard.size()>0){
            update accListToUpdateRestrictCreditCard;
        }
        //CH26: END
         //CH31: Start
        if(setUpgradeCaseToInsert.size()>0){
            //insert lstUpgradeCaseToInsert;
            CreateUpgradeCases upgCse = new CreateUpgradeCases(setUpgradeCaseToInsert);
            System.enqueueJob(upgCse);
        }
        //CH31: END
    }
    //CH26: Start
    public static Account restrictAccountToApplyCard(Case objCase, Id accId){
		Account acc = new Account(Id = accId);
		acc.Reapplying_Restriction_Last_Update_Date__pc = system.now();
        if(objCase.Reapplying_Restriction_Period__c != null){
            acc.Reapplying_Restriction_Period__pc = objCase.Reapplying_Restriction_Period__c;
        }else if(objCase.Reapplying_Restriction_Period__c == null){
           acc.Reapplying_Restriction_Period__pc = '1 Month'; 
        }
    	//acc.Reapplying_Restriction_Period__pc = objCase.Reapplying_Restriction_Period__c;
		return acc;
	}
    //CH26: END
}