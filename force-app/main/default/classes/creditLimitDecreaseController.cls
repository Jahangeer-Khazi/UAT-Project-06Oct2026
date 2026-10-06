/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 17-01-2023
* 		Change History: 
*               #CH01 : #Imane Tsioucha# #22-02-2024# add x-canary header
*/
public class creditLimitDecreaseController {
     
    @AuraEnabled
    public static CreditCardLimitDecreaseDetails decreaseCreditLimit(String caseId, String requestedLimit, String cardDetail){
        CreditCardLimitDecreaseDetails limitDecreaseDetails = new CreditCardLimitDecreaseDetails();
        ApiConnection con = new ApiConnection();
        Case objCase = [Select id,Status,cc_Requested_Credit_Limit__c,Region_Flag__c,Account.PersonEmail, Account.CIF__pc,Account.x_canary__pc,Customer_CIF__c from case where id =: caseId];
        
        String body ='';
        Map<String, Object> mapcardDetails = new Map<String, Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();

        List<Object> cardDetails = (List<Object>)JSON.deserializeUntyped(cardDetail);
		System.debug('Card Details in apex class:'+cardDetails);
        for(Object inst : cardDetails){
             mapcardDetails = (Map<String, Object>)inst;
        }
        System.debug('Card Nature:'+mapcardDetails.get('cardNature'));
        Integer cardProductId = Integer.valueof(mapcardDetails.get('cardProductionConfigurationId'));
        System.debug('Card Product Id:'+cardProductId);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('POST','/api/v1/credit-cards/request?',objCase.Region_Flag__c);
        body = '{"cardProductConfigurationId": "'+mapcardDetails.get('cardProductionConfigurationId') +
                 '","employerId": "'+0 +
                 '","cardLimit": "' + requestedLimit +
                 '","isCurrentAddressValid": "'+true +
                 '","hasMemberShip": "'+false +
            	 '","nameOnTheCard": "'+mapcardDetails.get('embossName') +
                 '","pciNumber": "'+mapcardDetails.get('id') +
                 '","cardNature": "'+mapcardDetails.get('cardNature') +
                 '","targetType": "LIMIT_DECREASE"}';
        request.setBody(body);
        request.setTimeout(120000);
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        if(objCase.Account.x_canary__pc != null){
            request.setHeader('x-canary', objCase.Account.x_canary__pc); //CH01
        }
        System.debug('Get body :'+request.getBody());  
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200){
            System.debug('Invalid Status Code from API:'+response.getStatusCode());
            lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','POST',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Limit Decrease', 'Credit Card - FCR');

		}
        else{
            System.debug('Response Body:'+response.getBody());
            objCase.cc_Requested_Credit_Limit__c = Integer.valueOf(requestedLimit);
            objCase.Status = 'Closed';
            update objCase;
            limitDecreaseDetails.successMessageFromApi = 'Credit Limit Decrease Successfully';
        }
        return limitDecreaseDetails;
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
    
    public class CreditCardLimitDecreaseDetails {
    	@AuraEnabled 
        public String successMessageFromApi  {get; set;}
    }

}