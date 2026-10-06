public class FetchSTPFromBcrbAPI implements Queueable, Database.AllowsCallouts{
    private static ApiConnection con = new ApiConnection();
    set<Id> caseId;
    
    public FetchSTPFromBcrbAPI(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    public void execute(QueueableContext context){
        System.debug('BCRB API Execution Starts');
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> caseToUpdate = new List<Case>();
        List<Case> lstCase = [Select Id,Status,Sub_Status__c,cc_Monthly_Income__c,cc_Requested_Credit_Limit__c,AccountId,Customer_CIF__c,Region_Flag__c,Account.PersonEmail,Account.CIF__pc,Account.cc_Monthly_Income_Actual__pc,Account.Gross_Monthly_Income__pc
                              from Case where Id IN : caseId];
        if(lstCase.size() > 0){
            for(Case objCase : lstCase){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String body = '';
                String monthlyIncome = '';
                if(objCase.cc_Monthly_Income__c != null && objCase.cc_Monthly_Income__c > 0 ){
                    monthlyIncome = String.valueOf(objCase.cc_Monthly_Income__c);
                    System.debug('Monthly Income 1:'+objCase.cc_Monthly_Income__c);
                    System.debug('Monthly Income in String format 1:'+monthlyIncome);
                }
                else if(objCase.Account.cc_Monthly_Income_Actual__pc != null && objCase.Account.cc_Monthly_Income_Actual__pc > 0){
                    monthlyIncome = String.valueOf(objCase.Account.cc_Monthly_Income_Actual__pc);
                     System.debug('Monthly Income 2:'+objCase.Account.cc_Monthly_Income_Actual__pc);
                     System.debug('Monthly Income in String format 2:'+monthlyIncome);
                }
                else if(objCase.Account.Gross_Monthly_Income__pc != null){
                     monthlyIncome = objCase.Account.Gross_Monthly_Income__pc;
                     System.debug('Monthly Income 3:'+objCase.Account.Gross_Monthly_Income__pc);
                     System.debug('Monthly Income in String format 3:'+monthlyIncome);
                }
               
                request = con.createRequest('POST', '/api/v1/bcrb/decision?', objCase.Region_Flag__c);
                body = '{"crmCaseId": "'+objCase.Id +
                    '","facilityAmount":"'+objCase.cc_Requested_Credit_Limit__c+
                    '","monthlySalary":"'+monthlyIncome+
                    '","target": "CREDIT_CARDS","generateReport":true,"facilityDuration":null,"facilityMonthlyInstalment":null}';
                
                System.debug('Person Email :'+objCase.Account.PersonEmail);
                System.debug('Customer ID :'+objCase.Account.CIF__pc);
                request.setBody(body);
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                request.setTimeout(120000);
                system.debug('---> Request Body BCRB --> '+request.getBody());
                HttpResponse response = http.send(request);
                system.debug('---> Response Body BCRB --> '+response.getBody());
                if(response.getStatusCode() != 200){
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card BCRB', 'Credit Card BCRB',true);
                    
                }
                else{
                    system.debug('---> Success Response Body BCRB --> '+response.getBody());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'PUT',objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 'Credit Card BCRB', 'Credit Card BCRB',false);
                    Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                    Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
                    System.debug(dataMap);
                    string controlType = String.valueOf(dataMap.get('decision'));
                    string currentSegment = String.valueOf(dataMap.get('currentCustomerStatus'));
                    Decimal noOfArrearsCurrentHistorical = (Decimal)dataMap.get('totalOfArrearsCurrentAndHistorical');
                    Decimal totalOfPenalties = (Decimal)dataMap.get('totalOfPenaltiesAndContraventionAccounts');
                    objCase.cc_Control_Type__c = controlType;
                    objCase.No_of_Arrears_Current_and_Historical__c = noOfArrearsCurrentHistorical;
                    objCase.cc_Total_Obligations__c = totalOfPenalties;
                    objCase.asc_Current_Segment__c = currentSegment;
                    caseToUpdate.add(objCase);
                }
                
            } //For Loop Ends
        } //If Close
        if(caseToUpdate.size() > 0){
            update caseToUpdate;
        }
        if(lstSA.size()>0){
            insert lstSA;
        }
    }
    public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType, Boolean isAPIFailed) {
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
}