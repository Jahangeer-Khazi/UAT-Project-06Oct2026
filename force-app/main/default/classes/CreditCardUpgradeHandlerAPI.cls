/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 23-10-2023
*       Change History:
*						#CH01# #Jahangeer Mohammed# #04-02-2025# Added Membership Parameter in Case Creation(UATNB-153526)
						#CH02# #Jahangeer Mohammed# #01-02-2026# Added Logic for World Entitlement Project(NBA-15929)
*           
*/
public class CreditCardUpgradeHandlerAPI {
  private static ApiConnection con = new ApiConnection();
    
  @InvocableMethod(label='Call API Update Credit Card Request' description='Update Credit Card Request API' callout=true )
  public static void updateCreditCardReqApiFromFlow(List<UpgradeCreditCard> upgradeCreditCards){
       Map<String,String> details = new Map<String,String>();
       System.debug('Upgrade Credit Card Case:'+upgradeCreditCards);
       UpgradeCreditCard upgCard = upgradeCreditCards.get(0);
       details.put('isNew',upgCard.isNew);
       details.put('caseId',upgCard.caseId);
       details.put('isResultFieldChange',upgCard.isResultFieldChange);
       System.debug('Map Details:'+details);
       creditCardUpgradeFutureJob(new Set<Id>{upgCard.caseId},details);

  }
  @future(callout=true)
  public static void creditCardUpgradeFutureJob(Set<Id> caseIds , Map<String,String> details){
      List<Case> lstUpdateCase = new List<Case>();
      String isNew = details.get('isNew');
      String changedField = details.get('isResultFieldChange');
      System.debug('Change Field:'+changedField);
      Integer cardProductConfigurationIdString;
      List<System_Action__c> lstSA = new List<System_Action__c>();
      
	  List<Case> lstCase = [Select id,Account.x_canary__pc,cc_Credit_Card_PCI_Number__c, status, Sub_Status__c,RecordTypeId, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c, Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc, cc_Credit_Approval_Result__c, cc_Credit_Approval_Result_Date_Time__c, cc_Application_Stages__c, 
                            cc_Approved_Balance_Transfer_Amount__c,cc_Approved_Requested_Card_Type__c,cc_Approved_Name_on_the_card__c,cc_HR_Result__c, cc_HR_Result_Date_Time__c,Account.Segment__pc,
                            PrimaryCardProductConfigurationId__c, CaseNumber, Region_Flag__c,Case_Model__c ,cc_Request_Type__c,cc_Current_Credit_Limit__c,Card_Type__c,Selected_Supplementary_Cards__c,cc_PCI_Id__c,
                            cc_Requested_Credit_Limit__c,Operation_Result__c,cc_CRM_Stage__c, cc_Operations_Date_Time__c,Has_Co_Brand_Membership_Number__c,cc_Approved_Embossing_line_4__c,cc_Embossing_Line_4__c FROM Case where Id In: caseIds];
      
      //CH02: Start
        List<World_Elite_Entitlement__c> lstWorldEntitCase = new List<World_Elite_Entitlement__c>();
      //CH02: END
      for(Case objCase : lstCase)
      {
          ///////////////////////////////////////////////////////////////// START: CREDIT CARD UPGRADE CASE CREATION //////////////////////////////////////////////////////////////////
          if(isNew != null && isNew.equalsIgnoreCase('yes') ){
              System.debug('Credit Card Upgrade Case Creation');
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
                  lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
                  
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
              String upgradedSupplementaryCardsJson;
              List<SupplementaryCard> upgradedSupplementaryCards = new List<SupplementaryCard>();
              
              if(objCase.Selected_Supplementary_Cards__c != null){
                  // Parse the Selected_Supplementary_Cards__c field
                  if (!String.isEmpty(objCase.Selected_Supplementary_Cards__c)) {
                      List<String> cardDetails = objCase.Selected_Supplementary_Cards__c.split(';');
                      for (String cardDetail : cardDetails) {
                          List<String> parts = cardDetail.split(' - ');
                          if (parts.size() == 2) {
                              String pciNumber = parts[0].trim();
                              String cardholderName = parts[1].trim();
                              upgradedSupplementaryCards.add(new SupplementaryCard(pciNumber, cardholderName));
                          }
                      }
                  }
                  System.debug('Upgraded Supp Cards:'+upgradedSupplementaryCards);
                  // Convert upgradedSupplementaryCards to JSON
                  upgradedSupplementaryCardsJson = JSON.serialize(upgradedSupplementaryCards);
              }
              else if(objCase.Selected_Supplementary_Cards__c == null || objCase.Selected_Supplementary_Cards__c == ''){
                   upgradedSupplementaryCardsJson = JSON.serialize(upgradedSupplementaryCards);
			  }
              /////////////////////////////////// Upgrade Credit Cards ////////////////////////////////////
              if(objCase.cc_Name_on_the_Card__c != null && objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                  body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_PCI_Id__c +
                      '","currentCardLimit": "'+objCase.cc_Current_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                      ',"targetType": "CARD_UPGRADE","status":"IN_PROGRESS","requestedLimitIncrease":false}';
              }
              else if(objCase.cc_Name_on_the_Card__c == null && objCase.cc_Requested_Card_Type__c != 'ILA_GULF_AIR_COBRAND_01'){
                  body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+null +
                      '","currentMaskedCardNumber": "'+objCase.cc_PCI_Id__c +
                      '","currentCardLimit": "'+objCase.cc_Current_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                      ',"targetType": "CARD_UPGRADE", "status":"IN_PROGRESS","requestedLimitIncrease":false}';
              }
              else if(objCase.cc_Name_on_the_Card__c != null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                  //CH01: Start
                  if(objCase.cc_Approved_Embossing_line_4__c != null){
                      body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_PCI_Id__c +
                      '","currentCardLimit": "'+objCase.cc_Current_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                      '","upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                      ',"targetType": "CARD_UPGRADE","status":"IN_PROGRESS","requestedLimitIncrease":false}';
                  }
                  else if(objCase.cc_Approved_Embossing_line_4__c == null){
                      body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                      '","currentMaskedCardNumber": "'+objCase.cc_PCI_Id__c +
                      '","currentCardLimit": "'+objCase.cc_Current_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                      ',"targetType": "CARD_UPGRADE","membershipNumber": null,"status":"IN_PROGRESS","requestedLimitIncrease":false}';
                  }
                  //CH01: END
                  
              }
              else if(objCase.cc_Name_on_the_Card__c == null && objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                  //CH01: Start
                  if(objCase.cc_Approved_Embossing_line_4__c != null){
                       body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+null +
                      '","currentMaskedCardNumber": "'+objCase.cc_PCI_Id__c +
                      '","currentCardLimit": "'+objCase.cc_Current_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                      '","upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                      ',"targetType": "CARD_UPGRADE","status":"IN_PROGRESS","requestedLimitIncrease":false}';
                  }
                  else if(objCase.cc_Approved_Embossing_line_4__c == null){
                       body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                      '","crmCaseId": "'+objCase.Id +
                      '","embossName": "'+null +
                      '","currentMaskedCardNumber": "'+objCase.cc_PCI_Id__c +
                      '","currentCardLimit": "'+objCase.cc_Current_Credit_Limit__c +
                      '","currentCardType": "'+objCase.Card_Type__c +
                      '","upgradeCardTo": "'+objCase.cc_Requested_Card_Type__c +
                      '","hasMembership": "'+objCase.Has_Co_Brand_Membership_Number__c +
                      '","upgradedSupplementaryCards":' + upgradedSupplementaryCardsJson +
                      ',"targetType": "CARD_UPGRADE","membershipNumber": null,"status":"IN_PROGRESS","requestedLimitIncrease":false}';
                  }
                  //CH01: END
              }
              /////////////////////////////////// Upgrade Credit Cards ////////////////////////////////////
                             
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
                  lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
              }
              else
              {
                  System.debug(response1.getBody());
                  //CH02: Start
                    if(System.Label.ILA_WORLD_ENTITLEMENT_ENABLE.equalsIgnoreCase('true') && objCase.Type == 'Credit Card Upgrade' && objCase.Sub_Type__c == 'Credit Card Upgrade - No Limit Increase' && (objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01' || objCase.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02')){
                          World_Elite_Entitlement__c wtlToInsert = CreateWorldEliteEntitCase.createWorldEntitlementCase(objCase.Account, objCase);
                    	  lstWorldEntitCase.add(wtlToInsert);
                    }
                  //CH02: END
                  objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
				  lstUpdateCase.add(objCase);
                  lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');

              }

          } //If Ends
         ///////////////////////////////////////////////////////////////// END: CREDIT CARD UPGRADE CASE CREATION //////////////////////////////////////////////////////////////////

          ///////////////////////////////////////////////////////////////// START: CREDIT APPROVER / HR RESULT ACTIONS ////////////////////////////////////////////////////////
          else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && (changedField.equalsIgnoreCase('cc_Credit_Approval_Result__c') || changedField.equalsIgnoreCase('cc_HR_Result__c'))){
             if(objCase.cc_Credit_Approval_Result__c == 'Approve' || objCase.cc_HR_Result__c == 'Approved'){
                  System.debug('Credit Card Upgrade Case Approved by Approver/HR');
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      	  '","creditLimit": "'+objCase.cc_Current_Credit_Limit__c +
                          '","targetType": "CARD_UPGRADE","status":"IN_PROGRESS"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);
                  }
                  
                  System.debug('---> Request Body In Credit Card Upgrade Approver/HR--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
                  }
                 else{
                     System.debug('Response Body In Credit Card Upgrade Approver/HR:'+response.getBody());
                     lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');

                 }
              } //If Ends
              else if(objCase.cc_Credit_Approval_Result__c == 'Decline' || objCase.cc_HR_Result__c == 'Decline'){
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
                  body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                      	  '","creditLimit": "'+objCase.cc_Current_Credit_Limit__c +
                          '","declineReasons": "'+decReason +
                          '","targetType": "CARD_UPGRADE","status":"DECLINED"}';
                 
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
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
                  }
                 else{
                      System.debug('Response Body In Credit Card Upgrade Decline:'+response.getBody());
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Declined';
                      objCase.cc_CRM_Stage__c = 'DECLINED';
                     
                      if(objCase.cc_Credit_Approval_Result__c == 'Decline'){
                        objCase.cc_Application_Stages__c = 'Credit Approval';
                      	objCase.cc_Credit_Approval_Result_Date_Time__c = System.now();
                      }
                      else if(objCase.cc_HR_Result__c == 'Decline'){
                        objCase.cc_Application_Stages__c = 'Credit HR Team';
                      	objCase.cc_HR_Result_Date_Time__c = System.now();
                      }
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');

                 }
              } //Inner Else If Ends
              else if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer' || objCase.cc_HR_Result__c == 'Cancelled by Customer'){
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","creditLimit": "'+objCase.cc_Current_Credit_Limit__c +
                          '","targetType": "CARD_UPGRADE","status":"CANCELLED"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc); //CH22
                  }
                  System.debug('---> Request Body In Credit Card Upgrade CANCELLED by Approver/HR Result--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
                  }
                 else{
                      System.debug('Response Body In Credit Card Upgrade CANCELLED:'+response.getBody());
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Cancelled';
                      objCase.cc_CRM_Stage__c = 'CANCELLED';
                     
                      if(objCase.cc_Credit_Approval_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Application_Stages__c = 'Credit Approval';
                      	objCase.cc_Credit_Approval_Result_Date_Time__c = System.now();
                      }
                      else if(objCase.cc_HR_Result__c == 'Cancelled by Customer'){
                        objCase.cc_Application_Stages__c = 'Credit HR Team';
                      	objCase.cc_HR_Result_Date_Time__c = System.now();
                      }
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');

                 }
              } //Inner Else If Ends
              
          } //Else If Ends
          ///////////////////////////////////////////////////////////////// END: CREDIT APPROVER / HR RESULT ACTIONS ////////////////////////////////////////////////////////

          //////////////////////////////////////////////////////////// START: OPERATION RESULT ACTIONS ////////////////////////////////////////////
          else if(isNew != null && isNew.equalsIgnoreCase('no') && changedField != null && changedField.equalsIgnoreCase('Operation_Result__c')){
              System.debug('Credit Operation Result Value:'+objCase.Operation_Result__c);
              if(objCase.Operation_Result__c == 'Upgrade Completed'){
                  System.debug('Credit Card Upgrade Case Completed by Operations');
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
                      body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","creditLimit": "'+objCase.cc_Current_Credit_Limit__c +
                          '","targetType": "CARD_UPGRADE","status":"APPROVED"}';
                  }
                  else if(objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                      if(objCase.cc_Approved_Embossing_line_4__c != null){
                           body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","creditLimit": "'+objCase.cc_Current_Credit_Limit__c +
                          '","membershipNumber": "'+objCase.cc_Approved_Embossing_line_4__c +
                          '","targetType": "CARD_UPGRADE","status":"APPROVED"}';
                      }
                      /*else if(objCase.cc_Approved_Embossing_line_4__c == null || objCase.cc_Approved_Embossing_line_4__c == ''){
                          body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","targetType": "CREDIT_CARD_UPGRADE","membershipNumber": null,"status":"APPROVED"}';
                      }*/
                       
                  }
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc); //CH22
                  }
                  System.debug('---> Request Body In Credit Card Upgrade Completed--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      objCase.cc_Operations_Date_Time__c = System.now();
                      objCase.Operation_Result__c = '';
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
                  }
                 else{
                     System.debug('Response Body In Credit Card Upgrade Completed:'+response.getBody());
                     if(objCase.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                         if(objCase.cc_Approved_Embossing_line_4__c == null || objCase.cc_Approved_Embossing_line_4__c == ''){
                             Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                             Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                             System.debug('Success Response Membership number:'+dataMap);
                             String membershipNumber = String.valueOf(dataMap.get('membershipNumber'));
                             objCase.cc_Approved_Embossing_line_4__c = membershipNumber;
                         }
                     }
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Approved';
                      objCase.cc_Application_Stages__c = 'Completed';
                      objCase.cc_CRM_Stage__c = 'APPROVED';
                      objCase.cc_Operations_Date_Time__c = System.now();
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');

                 }
              }//If Ends
              else if(objCase.Operation_Result__c == 'Cancelled by Customer'){
                  System.debug('Credit Card Upgrade Case Cancelled by Customer by Operations');
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"crmCaseId": "'+objCase.Id + 
                          '","cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                          '","targetType": "CARD_UPGRADE","status":"CANCELLED"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);
                  }
                  System.debug('---> Request Body In Credit Card Upgrade Cancelled By Customer by Operations--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');
                  }
                 else{
                      System.debug('Response Body In Credit Card Upgrade Completed:'+response.getBody());
                      objCase.Status = 'Closed';
                      objCase.Sub_Status__c = 'Cancelled';
                      objCase.cc_Application_Stages__c = 'Credit Operation';
                      objCase.cc_CRM_Stage__c = 'CANCELLED';
                      objCase.cc_Operations_Date_Time__c = System.now();
                      lstUpdateCase.add(objCase);
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Upgrade', 'Credit Card Upgrade');

                 }
              } //Inner Else If Ends
          } //Else If Ends
         //////////////////////////////////////////////////////////// END: OPERATION RESULT ACTIONS ////////////////////////////////////////////

      } //for loop Ends
      if(lstUpdateCase.size()>0){
          update lstUpdateCase;
      }
      if(lstSA.size()>0){
          insert lstSA;
      }
      //CH02: Start
      if(lstWorldEntitCase.size()>0){
          insert lstWorldEntitCase;
      }
      //CH02: END
            
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
    
   public class UpgradeCreditCard{
        @InvocableVariable(label='CaseId' description='the Id of the Case' required=true)
        public String caseId;
        
        @InvocableVariable(label='isNew' description='used after insert (yes or no)')
        public String isNew;
       
       @InvocableVariable(label='Result Field Change' description='used to Capture Change Field')
        public String isResultFieldChange;
  }
   public class SupplementaryCard {
        public String cardholderName;
        public String pciNumber;
        public String status;

        public SupplementaryCard(String pciNumber, String cardholderName) {
            this.pciNumber = pciNumber;
            this.cardholderName = cardholderName;
            this.status = 'Upgrade';
        }
    }

}