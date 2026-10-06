/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-12-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewQueuableSMSAutomatic implements Queueable, Database.AllowsCallouts{
private static ApiConnection con = new ApiConnection();
    set<Id> caseId;
    
    public JordanPeriodicReviewQueuableSMSAutomatic(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
   //////////////////////////////////////////////////// Start: Logic for Automatic Jordan Case Creation ID Expired & ID Not Expired ////////////////////////////////////////////////////////////////////////////////////////////

    public void execute(QueueableContext context){
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        for(Case caseObj : [SELECT Id,Status,Region_Flag__c,Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c,Sub_Status__c,Account.CIF__pc,Customer_CIF__c,cc_Email_Address__c,Account.PersonEmail,cc_Mobile_Number__c,Case_Model__c FROM Case WHERE Id In:caseId]){
            Http http = new Http();
            HttpRequest request1 = new HttpRequest(); 
            request1 =con.createRequest('POST','/api/v1/notifications?',caseObj.Region_Flag__c);
            
            
            String sms = 'sms';
            String tempCodeIDNotExpired = 'AUTOMATIC_CASE_CREATE_SUCCESS_NOT_EXPIRED';
            String tempCodeIDExpired = 'AUTOMATIC_CASE_CREATE_SUCCESS_EXPIRED';
            String body = '';
            
            if(caseObj.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c > 0){
                Integer noOfDays = Integer.valueOf(caseObj.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c);
                body = 
                '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+tempCodeIDNotExpired +
                '","placeholderReplacements": [ '+
                '   { '+
                '    "fieldName":"NumberofDays", '+
                '    "fieldText":"'+noOfDays+'" '+
                '   } '+
                ' ] '+
                ' }';
            }
            else if(caseObj.Jopr_No_of_Day_bet_ID_Exp_Case_Creation__c <= 0){
                body = 
                '{"phoneNumber": "'+caseObj.cc_Mobile_Number__c + 
                '","type": "'+sms +
                '","subject": "'+null +
                '","templateCode": "'+tempCodeIDExpired +'"}';
            }
            
            request1.setBody(body);
            request1.setHeader('userId', caseObj.Account.PersonEmail);
            request1.setHeader('customerId', caseObj.Account.CIF__pc);
            System.debug('---> Jordan SMS Request Body --> '+request1.getBody());  
            HttpResponse response1 = http.send(request1);
            if(response1.getStatusCode() != 200){
                System.debug('Invalid Status Code from API');
                lstSA = createSystemAction(request1.getBody(),response1.getBody(),'callout:Jordan_Endpoint/api/v1/notifications?language=en&unit=jor','POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 'Jordan SMS API', 'Jordan Periodic Review');
                
            }
            else{
                System.debug('Getting Success Status Code from API:'+response1.getBody());
            }
        }
        if(lstSA.size()>0)
            insert lstSA;
        
    }
    
    //////////////////////////////////////////////////// END: Logic for Automatic Jordan Case Creation ID Expired & ID Not Expired ////////////////////////////////////////////////////////////////////////////////////////////

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