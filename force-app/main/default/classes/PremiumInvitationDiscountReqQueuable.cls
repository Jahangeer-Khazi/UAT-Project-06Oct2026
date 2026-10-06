public class PremiumInvitationDiscountReqQueuable implements Queueable, Database.AllowsCallouts{
    private static ApiConnection con = new ApiConnection();
    set<Id> caseId;
    public PremiumInvitationDiscountReqQueuable(set<Id> setCaseId){
        this.caseId = setCaseId;
    }
    public void execute(QueueableContext context){
       List<Case> cseList = [Select Id,Expiry_Days__c,Region_Flag__c,Customer_CIF__c,Account.CIF__pc,Account.x_canary__pc,Account.Region_Flag__c,accountId,RMT_Results_Date_Time__c,Discount_Amount__c,ac_RequestedBy__c,Premium_Substatus_Changed__c,Status,Sub_Status__c,cc_Contact_Centre_Date_Time__c,ownerId,Waiting_for_customer_feedback__c,LastModifiedByID from Case where Id=:caseId];
       List<Case> cseToUpdate = new List<Case>();
       List<System_Action__c> lstSA = new List<System_Action__c>();
        for(Case cs : cseList){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('PUT', '/api/v1/membership/discount/request', cs.Region_Flag__c);
            String body = '';
            body = '{"caseType": "INVITATION","expiryDays":"'+cs.Expiry_Days__c+'","crmCaseId":"'+cs.Id+'","status":"PENDING_CUSTOMER","discountAmount":'+cs.Discount_Amount__c+',"requestedBy":"BANK"}';
 			request.setBody(body);
            request.setHeader('customerId', cs.Account.CIF__pc);
            request.setHeader('regionName', cs.Account.Region_Flag__c);
            
            if(cs.Account.x_canary__pc != null){
                request.setHeader('x-canary', cs.Account.x_canary__pc);
            }
            System.debug('---> Request Body Premium Invitation--> '+request.getBody());
            HttpResponse response = http.send(request);
            if(response.getStatusCode() != 200){
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/membership/discount/request?language=en&unit=neo','PUT',cs.Id,cs.Account.CIF__pc,cs.accountId,response.getStatusCode(), 'Premium Retention/Invitation Application', 'premium Application');
            }
            else{
                System.debug('Response body:'+response.getBody());
                if(cs.Sub_Status__c == 'Pending Customer'){
                    cs.Waiting_for_customer_feedback__c = true;
                    cs.Premium_Substatus_Changed__c = system.today().addDays(Integer.valueOf(cs.Expiry_Days__c));
                    cseToUpdate.add(cs);
                }else{
                    cs.Waiting_for_customer_feedback__c = false;
                    cseToUpdate.add(cs);
                }
                lstSA = createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/membership/discount/request?language=en&unit=neo','PUT',cs.Id,cs.Account.CIF__pc,cs.accountId,response.getStatusCode(), 'Premium Retention/Invitation Application', 'premium Application');

            }
        }//for loop Ends
        if(cseToUpdate.size() > 0){
            upsert cseToUpdate;
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
}