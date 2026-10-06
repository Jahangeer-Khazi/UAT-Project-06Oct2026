/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 02-12-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewHandlerAPI {
    private static ApiConnection con = new ApiConnection();
     
    @future(callout=true)
     public static void callJordanCivilAPI(Set<Id> setCaseId){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        List<Case> lstCase = [Select id,Type, Sub_Type__c,Status, Sub_Status__c,Customer_CIF__c,Customer_Segment__c,cc_Name_on_the_Card__c,Account.PersonEmail, Account.CIF__pc, 
                              Region_Flag__c,Case_Model__c,ccjo_ID_Expiry_Date__c FROM Case where Id IN : setCaseId];
        
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            String body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"cardInfo":{"jordanianId":"54637635","cexpDt":"03/12/2023"}}}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
            if(response.getStatusCode() != 200){
                 System.debug('The status code returned was not expected: ' + response.getStatusCode());
                 System.debug('Response Body After API Fails: ' + response.getBody());
                 lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/customer-products/request?language=en&unit=neo','PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Jordan Civil API', 'Jordan Periodic Review');
            }
            else{
                System.debug('Response Body Civil Integration:'+response.getBody());
                Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data, cardInfo
                Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                Map<String, Object> mapJSONCardInfo = (Map<String, Object>)mapJSONData.get('cardInfo');
                System.debug('Map Json Data:'+mapJSONCardInfo);
                String idExpiryDate = (string)mapJSONCardInfo.get('cexpDt');
                Date dateOfExpiry;
                if(String.isNotBlank(idExpiryDate)){
                    dateOfExpiry = Date.parse(idExpiryDate);
                    System.debug('ID Expiry Date:'+dateOfExpiry);
                    objCase.ccjo_ID_Expiry_Date__c = dateOfExpiry;
                    lstUpdateCase.add(objCase);
                }
                 
            }
        }//for loop Ends
         if(lstUpdateCase.size()>0){
             update lstUpdateCase;
         }
     }
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, final String method, final Id CaseId, final String custId, final Id AccId, final Integer statCode, final String strAction, final String strType) {
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

}