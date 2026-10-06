/**
 * Created by Himanshu on 15/03/2022.
 */
public with sharing class CliqAPIHandler {
    private static ApiConnection con = new ApiConnection();
    public static void callOutToCliqAPI(List<Case> newCases, Map<Id, Case> oldMap) {
        Set<Id> lstUpdateCaseIds = new Set<Id>();
        for (Case newCase : newCases) {
            System.debug('Cases >> ' +newCase);
            Case oldCase = oldMap.get(newCase.Id) ;
            if (newCase.Status != oldCase.Status && newCase.Status == 'Closed' && newCase.Origin == 'CliQ') {
                System.debug('Cliq case ');
                lstUpdateCaseIds.add(newCase.Id);
            }
        }
        if(lstUpdateCaseIds.size()>0){
        	callOut(lstUpdateCaseIds);            
        }
            
    }
    @future(callout=true)
    public static void callOut(Set<Id> lstUpdateCaseIds) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System.debug('CASE LIST:' + lstUpdateCaseIds);
        for (Id caseId : lstUpdateCaseIds) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/distribution/customer/' + caseId, 'Jordan'); //only jordan region require cliq callout

            // con.makeCallout(request, action);
            // /customers/case/{crmCaseId}
            system.debug('---> Request --> ' + request.getBody());
            HttpResponse response = http.send(request);
            system.debug('---> Responce New --> ' + response.getBody());
            if (response.getStatusCode() != 200) {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, request, 'POST');
                action.HTTP_Response_Code__c = response.getStatusCode();
                insert action;
            } else {
                System.debug(response.getBody());
            }
        }
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //  action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
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