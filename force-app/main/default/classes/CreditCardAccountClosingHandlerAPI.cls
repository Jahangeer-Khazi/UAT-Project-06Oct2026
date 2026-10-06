/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 27-10-2024
*       Change History:
						#CH01# #Jahangeer Mohammed# #14-05-2025# Added Logic for Credit Card Cancellation Process(NBA-13500)
*           
*/
public class CreditCardAccountClosingHandlerAPI {
    private static ApiConnection con = new ApiConnection();
    @InvocableMethod(label='Call API Update Credit Card Request for Closing' description='Update Credit Card Request API for Closing' callout=true )
	public static void updateCreditCardReqApiFromFlow(List<UpgradeCreditCard> upgradeCreditCards){
       UpgradeCreditCard upgCard = upgradeCreditCards.get(0);
       creditCardUpgradeFutureJob(new Set<Id>{upgCard.caseId});

    }
    @future(callout=true)
    public static void creditCardUpgradeFutureJob(Set<Id> caseIds){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> lstCase = [Select id,Account.x_canary__pc,cc_Credit_Card_PCI_Number__c, status, Sub_Status__c,RecordTypeId, Type, Sub_Type__c, cc_Requested_Card_Type__c, Customer_Segment__c, Customer_CIF__c, cc_Name_on_the_Card__c, cc_Approved_Credit_Limit__c,Origin, Account.PersonEmail, Account.CIF__pc,  
                             PrimaryCardProductConfigurationId__c, CaseNumber, Region_Flag__c,Case_Model__c ,cc_Request_Type__c, Operation_Result__c,cc_CRM_Stage__c, cc_Operations_Date_Time__c,Back_Office_Result__c,CaseExecutionNumberB__c,cc_PCI_Id__c FROM Case where Id In: caseIds];
    	for(Case objCase : lstCase)
      	{
            //CH01: Added a condition Operation_Result__c = Credit Card Cancellation Completed
            if((objCase.Type == 'Credit Card Account Closing' || (objCase.Type == 'Credit Card' && objCase.Sub_Type__c == 'Account Closure')) && objCase.Operation_Result__c == 'Credit Card Cancellation Completed'){
                System.debug('Credit Card Closing Completed by Backoffice Team');
                  String body = '';
              	  Http http = new Http();
                  HttpRequest request = new HttpRequest();
                  String regionName = objCase.Region_Flag__c; 
                  if(objCase.Case_Model__c == 'alburaq'){ 
                    regionName += '_alburaq';   
                  } 
             	  //request = con.createRequest('PUT', '/api/v1/credit-cards/request?', regionName); 
              	  request = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                  body = '{"crmCaseId": "'+objCase.CaseExecutionNumberB__c + 
                          '","pciNumber": "'+objCase.cc_PCI_Id__c +
                          '","cardProductConfigurationId":"'+objCase.PrimaryCardProductConfigurationId__c+
						  '","targetType": "CREDIT_CARD_ORDER","status":"TERMINATED"}';
                 
                  request.setBody(body);
                  request.setHeader('userId', objCase.Account.PersonEmail);
                  request.setHeader('customerId', objCase.Account.CIF__pc);
                  System.debug('---> Request Body In Credit Card Account Closing--> '+request.getBody());
                  HttpResponse response = http.send(request);
                  if(response.getStatusCode() != 200)
                  {
                      System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                      lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Account Closure', 'Credit Card Account Closure');
                  }
                 else{
                     //CH01: Start
                     lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card Account Closure', 'Credit Card Account Closure');
					 //CH01: END
                     System.debug('Response Body In Credit Card Account Closing:'+response.getBody());
                     objCase.Status = 'Closed';
                     objCase.Sub_Status__c = 'Completed';
                     objCase.cc_Operations_Date_Time__c = System.now();
                     lstUpdateCase.add(objCase);
                 }
            }
            //CH01: END
        } //for loop Ends
        if(lstUpdateCase.size() > 0){
            update lstUpdateCase;
        }
        if(lstSA.size() > 0){
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
    public class UpgradeCreditCard{
        @InvocableVariable(label='CaseId' description='the Id of the Case' required=true)
        public String caseId;
    }

}