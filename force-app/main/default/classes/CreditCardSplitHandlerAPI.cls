public class CreditCardSplitHandlerAPI {
    
    private static ApiConnection con = new ApiConnection();
    
    @InvocableMethod(label='Call API Update Credit Card Request for Split' description='Update Credit Card Request API Split' callout=true )
    public static void updateCreditCardReqApiFromFlow(List<splitCreditCard> upgradeCreditCards){
        Map<String,String> details = new Map<String,String>();
        System.debug('Upgrade Credit Card Case:'+upgradeCreditCards);
        splitCreditCard upgCard = upgradeCreditCards.get(0);
        details.put('isNew',upgCard.isNew);
        details.put('caseId',upgCard.caseId);
        details.put('isResultFieldChange',upgCard.isResultFieldChange);
        System.debug('Map Details:'+details);
        creditCardSplitFutureJob(new Set<Id>{upgCard.caseId},details);
        
    }
    @future(callout=true)
    public static void creditCardSplitFutureJob(Set<Id> caseIds , Map<String,String> details){
        List<Case> lstUpdateCase = new List<Case>();
        List<Case> lstPremiumInvitationCaseToInsert = new List<Case>();
        String isNew = details.get('isNew');
        String changedField = details.get('isResultFieldChange');
        System.debug('Change Field:'+changedField);
        Integer cardProductConfigurationIdString;
        Set<Id> setCasesRelatedToDocusign  = new Set<Id>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        List<Case> lstCase = [Select id,Account.x_canary__pc,cc_Credit_Card_PCI_Number__c, status, Sub_Status__c,RecordTypeId, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c, Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc, cc_Credit_Approval_Result__c, cc_Credit_Approval_Result_Date_Time__c, cc_Application_Stages__c, 
                              cc_Approved_Balance_Transfer_Amount__c,cc_Approved_Requested_Card_Type__c,cc_Approved_Name_on_the_card__c,cc_HR_Result__c, cc_HR_Result_Date_Time__c,Account.Segment__pc,
                              PrimaryCardProductConfigurationId__c, CaseNumber, Region_Flag__c,Case_Model__c ,cc_Request_Type__c,cc_Current_Credit_Limit__c,Card_Type__c,Selected_Supplementary_Cards__c,cc_PCI_Id__c,
                              cc_Requested_Credit_Limit__c,Operation_Result__c,cc_CRM_Stage__c, cc_Operations_Date_Time__c,Has_Co_Brand_Membership_Number__c,cc_Approved_Embossing_line_4__c,cc_Embossing_Line_4__c,cc_Maker__c,Account.FirstName, Account.LastName,
                              cc_Checker_Result__c,AIR_CreditCardLimit__c,Is_Cash_Collateral__c,cc_Checker_Result_Date_Time__c,cc_Signature_Verifier_Result__c,cc_Signature_Verification_Date_Time__c,cc_Maker_Result_Date_Time__c,Existing_Card_New_Credit_Limit__c,RHA_HoldTransactionsReferenceNo__c FROM Case where Id In: caseIds];
        
    
        for(Case objCase : lstCase)
        {
            ///////////////////////////////////////////////////////////////// START: CREDIT CARD Split CASE CREATION //////////////////////////////////////////////////////////////////
            String cardNature;
            if(objCase.Is_Cash_Collateral__c == false){
                cardNature = 'unsecured';
            }else if(objCase.Is_Cash_Collateral__c == true){
                cardNature = 'secured';
            }
            if(isNew != null && isNew.equalsIgnoreCase('yes') ){
              System.debug('Credit Card Split Case Creation');
              Http http = new Http();
              HttpRequest request = new HttpRequest();
              String regionName = objCase.Region_Flag__c;    
              if(objCase.Case_Model__c == 'alburaq'){    
                  regionName += '_alburaq';  
              }
              //request = con.createRequest('GET', '/api/v1/credit-cards?', regionName ); 
              request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards, regionName);
              request.setHeader('userId', objCase.Account.PersonEmail);
              request.setHeader('customerId', objCase.Account.CIF__pc);
              if(objCase.Account.x_canary__pc != null){
                request.setHeader('x-canary', objCase.Account.x_canary__pc);
              }
              system.debug('---> Request --> '+request.getBody());
              HttpResponse response = http.send(request);
              system.debug('---> Responce New --> '+response.getBody());
              if (response.getStatusCode() != 200)
              {
                  System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                  lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
                  
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
                  
                  for(Map<String, Object> map1 : a)
                  {
                      System.debug('Map of Product Mapping Code:'+map1.get('productMappingCode'));
                      System.debug('Requested Card Type:'+objCase.cc_Requested_Card_Type__c);
                      if(map1.get('productMappingCode') == objCase.cc_Requested_Card_Type__c)
                      {
                          system.debug('---> FINALL 1111 --> '+(Integer)map1.get('cardProductConfigurationId'));
                          cardProductConfigurationIdString = (Integer)map1.get('cardProductConfigurationId');
                          system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationIdString);
                      }
                  }
              } //else Ends
              String body = '';
              Http http1 = new Http();
              HttpRequest request1 = new HttpRequest();
              //request1 = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName);
              request1 = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                
              /////////////////////////////////// Split Credit Cards Creation ////////////////////////////////////
              if(objCase.cc_Name_on_the_Card__c != null && objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                  body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","status":"IN_PROGRESS"}';
              }
              else if(objCase.cc_Name_on_the_Card__c == null && objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                  body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+null +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT", "status":"IN_PROGRESS"}';
              }
              else if(objCase.cc_Name_on_the_Card__c != null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                  if(objCase.cc_Approved_Embossing_line_4__c != null){
                      body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                      '","targetType": "LIMIT_SPLIT","status":"IN_PROGRESS"}';
                  }
                  else if(objCase.cc_Approved_Embossing_line_4__c == null){
                      body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","targetType": "LIMIT_SPLIT","membershipNumber": null,"status":"IN_PROGRESS"}';
                  }
                  
              }
              else if(objCase.cc_Name_on_the_Card__c == null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                  if(objCase.cc_Approved_Embossing_line_4__c != null){
                      body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+null +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                      '","targetType": "LIMIT_SPLIT","status":"IN_PROGRESS"}';
                  }
                  else if(objCase.cc_Approved_Embossing_line_4__c == null){
                      body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+null +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","membershipNumber": null,"status":"IN_PROGRESS"}';
                  }
              }
              /////////////////////////////////// Split Credit Cards Creation ////////////////////////////////////
                             
              System.debug('---> BODY --> '+body);               
              request1.setBody(body);
              request1.setHeader('userId', objCase.Account.PersonEmail);
              request1.setHeader('customerId', objCase.Account.CIF__pc);
              
              if(objCase.Account.x_canary__pc != null){
                request1.setHeader('x-canary', objCase.Account.x_canary__pc);
              }
              
              system.debug('---> Request --> '+request1.getBody());
              HttpResponse response1 = http1.send(request1);
              system.debug('---> Responce New --> '+response1.getBody());
              
              if (response1.getStatusCode() != 200)
              {
                  System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                  lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
              }
              else
              {
                  System.debug(response1.getBody());
                  objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
				  lstUpdateCase.add(objCase);
                  lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');

              }
                
            }    
           ///////////////////////////////////////////////////////////////// END: CREDIT CARD Split CASE CREATION //////////////////////////////////////////////////////////////////
            
          ////////////////////////////////////////////////////////////////// START: CREDIT CARD Split Maker Send to Checker //////////////////////////////////////////////////////////////
            
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('cc_Maker__c') && objCase.cc_Maker__c != 'Cancel'){
                if(objCase.cc_Maker__c == 'Send to Checker'){
                    System.debug('Credit Card Split When Maker Send to Checker');
                    String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      '","crmCaseId": "'+objCase.Id +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","status":"IN_PROGRESS"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);
                  }
                  System.debug('---> Request Body In Credit Card Split Maker Send to Checker--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
                  }
                 else{
                      System.debug('Response Body In Credit Card Split Maker Send to Checker:'+response.getBody());
                      
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');

                 }
                }
            }
            
         ////////////////////////////////////////////////////////////////// END: CREDIT CARD Split Maker Send to Checker //////////////////////////////////////////////////////////////
   
            
          ////////////////////////////////////////////////////////////////// START: CREDIT CARD Split Checker Accept OR Signature Verifier Re-send OR HR Accept OR Signature Verifier Accept ///////////////////////////////////////////////////////////////
          
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && (changedField.equalsIgnoreCase('cc_Checker_Result__c') || changedField.equalsIgnoreCase('cc_Signature_Verifier_Result__c') || changedField.equalsIgnoreCase('cc_HR_Result__c'))  && objCase.cc_Signature_Verifier_Result__c != 'Decline' && objCase.cc_Checker_Result__c != 'Decline' && objCase.cc_Checker_Result__c != 'Cancel' && objCase.cc_HR_Result__c != 'Decline'){
                if((objCase.cc_Checker_Result__c == 'Accept' || objCase.cc_Signature_Verifier_Result__c == 'Re-Send' || objCase.cc_HR_Result__c == 'Approved') && objCase.cc_Signature_Verifier_Result__c != 'Accept'){
                  System.debug('Credit Card Split When Checker Accepts or Signature Verifier Re-send and Call Docusign');
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      '","crmCaseId": "'+objCase.Id +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","status":"APPROVED_PENDING_SIGNATURE"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);
                  }
                  System.debug('---> Request Body In Credit Card Split by Checker/Signature/HR Result--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
                  }
                 else{
                      System.debug('Response Body In Credit Card Split Checker Accept/Signature Verifier Resend/HR Accept:'+response.getBody());
                      setCasesRelatedToDocusign.add(objCase.id);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');

                 }
                }
                else if(objCase.cc_Signature_Verifier_Result__c == 'Accept'){
                  System.debug('Credit Card Split When Signature Verifier Accepts and Case Close');
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  if(objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                     body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","status":"APPROVED"}';
                  }
                  else if(objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                      if(objCase.cc_Approved_Embossing_line_4__c != null){
                           body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                          '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                          '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                          '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                          '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                          '","currentCardType": "'+objCase.Card_Type__c +
                          '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                          '","cardNature":"'+cardNature +
                          '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                          '","targetType": "LIMIT_SPLIT","status":"APPROVED"}';
                      }
                      if(objCase.cc_Approved_Embossing_line_4__c == null){
                           body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                          '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                          '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                          '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                          '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                          '","currentCardType": "'+objCase.Card_Type__c +
                          '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                          '","cardNature":"'+cardNature +
                          '","targetType": "LIMIT_SPLIT","membershipNumber": null,"status":"APPROVED"}';
                      }
                  }
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc); //CH22
                  }
                  request.setTimeout(60000);  
                  System.debug('---> Request Body In Credit Card Split Completed--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      objCase.cc_Signature_Verification_Date_Time__c = System.now();
                      objCase.cc_Signature_Verifier_Result__c = '';
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
                  }
                 else{
                     System.debug('Response Body In Credit Card Limit Split Completed:'+response.getBody());
                     if(objCase.Is_Cash_Collateral__c == true){
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                        String holdReferenceNumber = String.valueOf(dataMap.get('holdReferenceNumber'));
                        objCase.RHA_HoldTransactionsReferenceNo__c = holdReferenceNumber;
                     }
                     
                     if(objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' && (objCase.cc_Approved_Embossing_line_4__c == '' || objCase.cc_Approved_Embossing_line_4__c == null)){
                        Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                        Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                        String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                        objCase.cc_Embossing_Line_4__c = membershipNumber;
                        objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                        if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                               Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Requested_Card_Type__c,objCase.cc_Name_on_the_Card__c);
                               lstPremiumInvitationCaseToInsert.add(cseToInsert);
                        }
                     }
                     else if(objCase.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01' && objCase.cc_Approved_Requested_Card_Type__c != null && objCase.cc_Approved_Embossing_line_4__c != null){
                         if(System.Label.ENABLE_CROSS_SELLING_GULF.equalsIgnoreCase('true') && objCase.Customer_Segment__c == 'Regular'){
                             Case cseToInsert = CreatePremiumInvitationCase.createPremiumCase(objCase.Account,objCase.cc_Requested_Card_Type__c,objCase.cc_Name_on_the_Card__c);
                             lstPremiumInvitationCaseToInsert.add(cseToInsert);
                         }
                     }
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Approved';
                      //objCase.cc_Application_Stages__c = 'Completed';
                      objCase.cc_CRM_Stage__c = 'APPROVED';
                      objCase.cc_Signature_Verification_Date_Time__c = System.now();
                      objCase.cc_Signature_Verification_Comments__c = '';
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');

                }
                }
            } 
            
          ////////////////////////////////////////////////////////////////// END: CREDIT CARD Split Checker Accept OR Signature Verifier Re-send OR HR Accept OR Signature Verifier Accept///////////////////////////////////////////////////////////////
  
          
          ///////////////////////////////////////////////////////////////// START: CREDIT CARD Split CASE CANCEL //////////////////////////////////////////////////////////////////
  
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && (changedField.equalsIgnoreCase('cc_Maker__c') || changedField.equalsIgnoreCase('cc_Checker_Result__c'))  && objCase.cc_Checker_Result__c != 'Decline' && objCase.cc_Checker_Result__c != 'Accept' && objCase.cc_HR_Result__c != 'Approved' && objCase.cc_HR_Result__c != 'Decline'){
                if(objCase.cc_Maker__c == 'Cancel' || objCase.cc_Checker_Result__c == 'Cancel' || objCase.cc_HR_Result__c == 'Cancelled by Customer'){
                  System.debug('Credit Card Split in Cancel');
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      '","crmCaseId": "'+objCase.Id +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","status":"CANCELLED"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);
                  }
                  System.debug('---> Request Body In Credit Card Split Cancel by Maker Or Checker--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
                  }
                 else{
                      System.debug('Response Body In Credit Card Split Cancel:'+response.getBody());
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Cancelled';
                      objCase.cc_CRM_Stage__c = 'CANCELLED';
                     
                      if(objCase.cc_Checker_Result__c == 'Cancel'){
                        //objCase.cc_Application_Stages__c = 'Credit Approval';
                      	objCase.cc_Checker_Result_Date_Time__c = System.now();
                      }
                      else if(objCase.cc_Maker__c == 'Cancel'){
                        //objCase.cc_Application_Stages__c = 'Credit HR Team';
                      	objCase.cc_Maker_Result_Date_Time__c = System.now();
                      }
                     else if(objCase.cc_HR_Result__c == 'Cancelled by Customer'){
                         objCase.cc_HR_Result_Date_Time__c = System.now();
                         objCase.cc_HR_Comments__c = '';
                     }
                      
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');

                 }
                }
            }  
            
         ///////////////////////////////////////////////////////////////// END: CREDIT CARD Split CASE CANCEL //////////////////////////////////////////////////////////////////

        ///////////////////////////////////////////////////////////////// START: CREDIT CARD Split CASE DECLINE //////////////////////////////////////////////////////////////////
  
            else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && (changedField.equalsIgnoreCase('cc_Checker_Result__c') || changedField.equalsIgnoreCase('cc_Signature_Verifier_Result__c') || changedField.equalsIgnoreCase('cc_HR_Result__c')) && objCase.cc_Checker_Result__c != 'Cancel' && objCase.cc_Signature_Verifier_Result__c != 'Accept' && objCase.cc_HR_Result__c != 'Approved'){
                if(objCase.cc_Checker_Result__c == 'Decline' || objCase.cc_Signature_Verifier_Result__c == 'Decline' || objCase.cc_HR_Result__c == 'Decline'){
                  System.debug('Credit Card Split in Decline');
                  String decReason = DeclineReasonMapping.fetchDeclineMappingValue(objCase.id);
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      '","crmCaseId": "'+objCase.Id +
                      '","currentMaskedCardNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                      '","currentCardPciNumber": "'+objCase.cc_PCI_Id__c +
                      '","creditLimit": "'+objCase.AIR_CreditCardLimit__c +
                      '","newCreditLimit": "'+objCase.Existing_Card_New_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","cardNature":"'+cardNature +
                      '","targetType": "LIMIT_SPLIT","status":"DECLINED"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);
                  }
                  System.debug('---> Request Body In Credit Card Upgrade Declined by Approver/HR Result--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');
                  }
                 else{
                      System.debug('Response Body In Credit Card Upgrade Decline:'+response.getBody());
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Declined';
                      objCase.cc_CRM_Stage__c = 'DECLINED';
                     
                      if(objCase.cc_Checker_Result__c == 'Decline'){
                        //objCase.cc_Application_Stages__c = 'Credit Approval';
                      	objCase.cc_Checker_Result_Date_Time__c = System.now();
                      }
                      else if(objCase.cc_HR_Result__c == 'Decline'){
                        //objCase.cc_Application_Stages__c = 'Credit HR Team';
                      	objCase.cc_HR_Result_Date_Time__c = System.now();
                        objCase.cc_HR_Comments__c = '';
                      }
                      else if(objCase.cc_Signature_Verifier_Result__c == 'Decline'){
                        //objCase.cc_Application_Stages__c = 'Credit HR Team';
                      	objCase.cc_Signature_Verification_Date_Time__c = System.now();
                        objCase.cc_Signature_Verification_Comments__c = '';
                      }
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Limit Split', 'Credit Card Limit Split');

                 }
                }
            }  
            
         ///////////////////////////////////////////////////////////////// END: CREDIT CARD Split CASE DECLINE //////////////////////////////////////////////////////////////////      
       }//for loop Ends 
       if(lstUpdateCase.size()>0){
          update lstUpdateCase;
      }
      if(setCasesRelatedToDocusign.size()>0 && !Test.isRunningTest()){
            DocuSignApexToolKit autoSendDocSign =  new DocuSignApexToolKit(setCasesRelatedToDocusign);
            System.enqueueJob(autoSendDocSign);
      }
        if(lstPremiumInvitationCaseToInsert.size()>0){
            insert lstPremiumInvitationCaseToInsert;
        }
      if(lstSA.size()>0){
          insert lstSA;
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
    
    public class splitCreditCard{
        @InvocableVariable(label='CaseId' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
        
        @InvocableVariable(label='Result Field Change' description='used to Capture Change Field')
        public String isResultFieldChange;
    }
    
}