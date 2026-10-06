/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 08-07-2025
*      Description : 
*      Change History: 
 					#CH01# #Jahangeer Mohammed# 23-07-2026# Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query and it is not required for reminder notifications(NBA-17560)

*/
public class ConvertCreditCardCreation {
    private static ApiConnection con = new ApiConnection();
    @InvocableMethod(label='Call API Credit Card Request to Convert Credit Card While Creation' description='Credit Card Request API to Convert Credit Card While Creation' callout=true )
    public static void createCreditCardReqApiFromFlow(List<convertCreditCard> createCreditCards){
        Map<String,String> details = new Map<String,String>();
        System.debug('Convert Credit Card Case Creation:'+createCreditCards);
        convertCreditCard conCard = createCreditCards.get(0);
        details.put('isNew',conCard.isNew);
        details.put('caseId',conCard.caseId);
        details.put('isResultFieldChange',conCard.isResultFieldChange);
        System.debug('Map Details:'+details);
        convertCreditCardCreationFutureJob(new Set<Id>{conCard.caseId},details);
        
    }
    @future(callout=true)
    public static void convertCreditCardCreationFutureJob(Set<Id> caseIds , Map<String,String> details){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        String isNew = details.get('isNew');
        String changedField = details.get('isResultFieldChange');
        //CH01: Commented cc_Activate_Reminders_for_Pending_Cases__c in the SOQL Query
        List<Case> lstCase = [Select id, AccountId,Account.ID_Type__pc,Account.x_canary__pc,Account.ID_Number__pc,Account.ID_Expiry_Date__pc,Account.iGA_Passport_Number__pc,cc_Passport_Number__c,cc_CPR_Number__c,cc_CPR_Expiry_Date__c, status, Sub_Status__c, Type, Sub_Type__c, 
                              cc_Requested_Card_Type__c, Customer_Segment__c,Customer_CIF__c, cc_Name_on_the_Card__c, Origin, Account.PersonEmail, Account.CIF__pc,cc_Credit_Card_PCI_Number__c,cc_CC_Application_Source__c,/*cc_Activate_Reminders_for_Pending_Cases__c,*/ 
                              PrimaryCardProductConfigurationId__c, PrimaryCard__c, sc_Card_Holder_Mobile_No__c, sc_Card_Holder_Email_Address__c, sc_Relationship__c, Region_Flag__c,Case_Model__c,cc_Request_Type__c,cc_Temporary_Limit_Increase_Duration__c,
                              cc_Temporary_Limit_Increase_Expiry_Date__c,cc_Reminder_Triggered__c,Has_Co_Brand_Membership_Number__c,Is_Balance_Transfer__c,cc_Approved_Embossing_line_4__c  from Case where id in: caseIds];
        for(Case objCase : lstCase){
            if(isNew != null && isNew.equalsIgnoreCase('yes')){
                String body ='';
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                
                String regionName = objCase.Region_Flag__c;    
                if(objCase.Case_Model__c == 'alburaq'){    
                    regionName += '_alburaq';  
                }
                
                //request1 = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName);
                request1 = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                request1.setHeader('userId', objCase.Account.PersonEmail);
                request1.setHeader('customerId', objCase.Account.CIF__pc);
                if(objCase.Account.x_canary__pc != null){
                    request1.setHeader('x-canary', objCase.Account.x_canary__pc);
                }
                if(objCase.Sub_Status__c == 'In-Progress'){
                    system.debug('--> Check inside In Progress --> ');
                    
                    ////////////////////////////////////////////////// START: NON CO-BRAND CARDS /////////////////////////////////////////////////
                    if(objCase.Type == 'Convert Credit Card Nature Application' && objCase.Sub_Type__c == 'Convert to Unsecured'){
                        if(objCase.cc_Name_on_the_Card__c !=null){
                            body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","crmCaseId": "'+objCase.Id +
                                '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                                '","pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                                '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                        }
                        else{
                            body = '{"cardProductConfigurationId": "'+objCase.PrimaryCardProductConfigurationId__c +
                                '","crmCaseId": "'+objCase.Id +
                                '","embossName": "'+null +
                                '","pciNumber": "'+objCase.cc_Credit_Card_PCI_Number__c +
                                '","targetType": "CONVERT_TO_UNSECURED","status":"IN_PROGRESS"}';
                        }
                    }
                    ////////////////////////////////////////////////// END: NON CO-BRAND CARDS /////////////////////////////////////////////////

                    
                    system.debug('---> BODY --> '+body);               
                    request1.setBody(body);
                    request1.setHeader('userId', objCase.Account.PersonEmail);
                    request1.setHeader('customerId', objCase.Account.CIF__pc);
                    
                    system.debug('---> Request --> '+request1.getBody());
                    HttpResponse response1 = http1.send(request1);
                    system.debug('---> Responce New --> '+response1.getBody());
                    
                    if (response1.getStatusCode() != 200)
                    {
                        System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                        lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',true);
                    }
                    else
                    {
                        System.debug(response1.getBody());
                        if(objCase.Account.ID_Type__pc == 'Bahraini ID'){
                            objCase.cc_CPR_Number__c = objCase.Account.ID_Number__pc;
                            objCase.cc_CPR_Expiry_Date__c = objCase.Account.ID_Expiry_Date__pc;
                            objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
                            lstUpdateCase.add(objCase);
                        }
                        else{
                            objCase.cc_Passport_Number__c = objCase.Account.iGA_Passport_Number__pc;
                            lstUpdateCase.add(objCase);
                        }
                        lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(), 'Convert Credit Card Application', 'Convert Credit Card Application',false);

                    }
                }
                
            } //If Ends
        }//for loop Ends
        if(lstUpdateCase.size()>0){
            System.debug('List Upsert:'+lstUpdateCase);
            upsert lstUpdateCase;
        }
        if(lstSA.size()>0)
            insert lstSA;
        
    } //Future Method Ends
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