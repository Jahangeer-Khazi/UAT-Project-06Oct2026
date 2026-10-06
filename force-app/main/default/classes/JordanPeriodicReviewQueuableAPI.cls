/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 05-12-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewQueuableAPI implements Queueable, Database.AllowsCallouts{
    private static ApiConnection con = new ApiConnection();
    set<Id> caseId;
    public static String fakeBody;
   
    public JordanPeriodicReviewQueuableAPI(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
	public void execute(QueueableContext context){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        List<Case> lstCase = [Select id,Type, Sub_Type__c,Status, Sub_Status__c,Customer_CIF__c,Customer_Segment__c,cc_Name_on_the_Card__c,Account.PersonEmail, Account.CIF__pc, 
                              Region_Flag__c,Case_Model__c,ccjo_ID_Expiry_Date__c,cc_ID_Number__c FROM Case where Id IN : caseId];
        
        for(Case objCase : lstCase)
        {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            String body = '';
            if(System.Label.JO_PERIODIC_REVIEW_ISACTUAL_RESPONSE.equalsIgnoreCase('true')){
                System.debug('Jordan ID Number :'+objCase.cc_ID_Number__c);
                
                request = con.createRequest('PUT', '/api/v1/government-data/jo-civil-service/person?',objCase.Region_Flag__c);
                
                body = '{"uidValue": "'+objCase.cc_ID_Number__c +
                    	'","crmSync": "true","promoteGovernmentDataToCustomerProfile":"false"}';
                
                request.setBody(body); 
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                request.setTimeout(70000);
                system.debug('---> Jordan Request Sending --> '+request.getBody());
                response = http.send(request);
            }
            if(System.Label.JO_PERIODIC_REVIEW_ISDUMMY_RESPONSE.equalsIgnoreCase('true')){
                response = new HttpResponse();
            	body = '{"meta":{"code":"GENE-0001","message":"message"},"data":{"cardInfo":{"jordanianId":"54637635","cexpDt":""}}}';
            	if(test.isRunningTest()){
               		body = fakeBody;
            	}
            	response.setStatus('OK');
            	response.setStatusCode(200);
            	response.setBody(body);
            	response.setHeader('Content-Type', 'application/json');
            }
            
            if(response.getStatusCode() != 200){
                 System.debug('The status code returned was not expected: ' + response.getStatusCode());
                 System.debug('Response Body After API Fails: ' + response.getBody());
                 lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:Jordan_Endpoint/api/v1/government-data/jo-civil-service/person?language=en&unit=jor','GET',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Jordan Civil API', 'Jordan Periodic Review');
            }
            else{
                System.debug('Response Body Civil Integration:'+response.getBody());
                Map<String, Object> mapJSONResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data, customerCivilDetailResponse
                Map<String, Object> mapJSONData = (Map<String, Object>)mapJSONResponse.get('data');
                Map<String, Object> mapJSONCardInfo = (Map<String, Object>)mapJSONData.get('customerCivilDetailResponse');
                System.debug('Map Json Data:'+mapJSONCardInfo);
                String idExpiryDate = (string)mapJSONCardInfo.get('cexpDt');
                Date dateOfExpiry;
                if(String.isNotBlank(idExpiryDate)){
                    dateOfExpiry = Date.valueOf(idExpiryDate);
                    System.debug('ID Expiry Date:'+dateOfExpiry);
                    objCase.ccjo_ID_Expiry_Date__c = dateOfExpiry;
                    lstUpdateCase.add(objCase);
                }
                 
            }
        }//for loop Ends
         if(lstUpdateCase.size()>0){
             update lstUpdateCase;
         }
         if(lstSA.size()>0){
            insert lstSA;
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