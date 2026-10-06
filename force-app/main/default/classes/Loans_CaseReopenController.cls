public with sharing class Loans_CaseReopenController {
    private static final String CLASS_NAME = 'Loans_CaseReopenController';
    private static ApiConnection con = new ApiConnection();
    private static String lastEndpoint;

    @AuraEnabled
    public static Map<String, Object> updateCaseStatus(String caseId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        List<System_Action__c> systemActions = new List<System_Action__c>();
        List<CaseAnnex__c> caseAnnexesToUpdate = new List<CaseAnnex__c>();
        
        try {
            Case caseObj = getCaseWithAnnexes(caseId);
            
            Map<String, Object> paramsMap = new Map<String, Object>{
                'crmCaseId' => caseObj.Id,
                'status' => 'Under Review',
                'subStatus' => 'In-Progress',
                'crmCaseNo' => caseObj.CaseNumber
            };
            
            HttpResponse apiResponse = updateLoanApplicationApi(caseObj, paramsMap);
            
            if (apiResponse.getStatusCode() == 200) {
                updateCaseFields(caseObj, caseObj.Case_Annexs__r);
                
                caseAnnexesToUpdate = updateCaseAnnexFields(caseObj.Case_Annexs__r);
                
                systemActions.add(createSystemActionForSuccess(caseObj, paramsMap, apiResponse));
                
                update caseObj;
                if (!caseAnnexesToUpdate.isEmpty()) {
                    update caseAnnexesToUpdate;
                }
                
                responseMap.put('statusCode', apiResponse.getStatusCode());
                responseMap.put('message', 'Case reopened successfully');
            } else {
                handleApiError(apiResponse);
            }
        } catch (Exception e) {
            Case caseObj = getCaseForErrorHandling(caseId);
            systemActions.add(createSystemActionForError(caseId, caseObj, e));
            
            responseMap.put('statusCode', 500);
            responseMap.put('message', e.getMessage());
            responseMap.put('isError', true);
        }
        
        if (!systemActions.isEmpty()) {
            insert systemActions;
        }
        
        return responseMap;
    }
    
    public static Case getCaseWithAnnexes(String caseId) {
        return [
            SELECT Id, Status, Sub_Status__c, cc_CRM_Stage__c, cc_Application_Stages__c,
                   OwnerId, Customer_CIF__c, AccountId, Region_Flag__c, Case_Model__c,
                   Type, Card_Product_Configuration_Id__c, cc_Credit_Pre_Screening_Result__c,
                   cc_Credit_Evaluation_Result__c, cc_Credit_Approval_Result__c, cc_Credit_Verification_Result__c,
            		CaseNumber,
                   (SELECT Id, cx_ln_Credit_Pre_Screening_Result__c, cx_ln_Credit_Approval_Result__c, 
                    cx_ln_Product__c, cx_ln_APR__c FROM Case_Annexs__r)
            FROM Case 
            WHERE Id = :caseId 
            LIMIT 1
        ];
    }
    
    public static void updateCaseFields(Case caseObj, List<CaseAnnex__c> caseAnnexes) {
        caseObj.Status = 'Under Review';
        caseObj.Sub_Status__c = 'In-Progress';
        caseObj.cc_CRM_Stage__c = 'IN PROGRESS';
        caseObj.cc_Application_Stages__c = 'Credit Pre-Screening';
        
        if (caseObj.cc_Credit_Pre_Screening_Result__c == 'Accept') {
            caseObj.cc_Credit_Pre_Screening_Result__c = null;
        }
        
        if (caseObj.cc_Credit_Approval_Result__c == 'Approve') {
            caseObj.cc_Credit_Approval_Result__c = null;
        }
        
        caseObj.cc_Credit_Evaluation_Result__c = null;
        caseObj.cc_Credit_Verification_Result__c = null;
        caseObj.cc_Contact_Centre_Result__c = null;
        caseObj.cc_Service_Centre_Result__c = null;
        caseObj.cc_Business_Approval_Result__c = null;
        caseObj.Credit_Retention_Result__c = null;
        caseObj.OwnerId = getPreScreenerQueueId();
        
        for (CaseAnnex__c caseAnnex : caseAnnexes) {
            if (caseAnnex.cx_ln_Product__c == 'Secured') {
                caseObj.cc_Control_Type__c = 'Manual';
            }
        }
    }
    
    public static List<CaseAnnex__c> updateCaseAnnexFields(List<CaseAnnex__c> caseAnnexes) {
        List<CaseAnnex__c> annexesToUpdate = new List<CaseAnnex__c>();
        
        for (CaseAnnex__c caseAnnex : caseAnnexes) {
            Boolean needsUpdate = false;
            
            if (caseAnnex.cx_ln_Credit_Pre_Screening_Result__c == 'Accept') {
                caseAnnex.cx_ln_Credit_Pre_Screening_Result__c = null;
                needsUpdate = true;
            }
            
            if (caseAnnex.cx_ln_Credit_Approval_Result__c == 'Approve') {
                caseAnnex.cx_ln_Credit_Approval_Result__c = null;
                needsUpdate = true;
            }

            if (caseAnnex.cx_ln_APR__c != null && caseAnnex.cx_ln_Product__c == 'Unsecured') {
                caseAnnex.cx_ln_APR__c = null;
                needsUpdate = true;
            }

            caseAnnex.cx_ln_Contact_Center_Result__c = null;
            caseAnnex.cx_ln_Service_Centre_Result__c = null;
            caseAnnex.cx_ln_Credit_Retention_Result__c = null;
            
            if (needsUpdate) {
                annexesToUpdate.add(caseAnnex);
            }
        }
        
        return annexesToUpdate;
    }
    
    public static HttpResponse updateLoanApplicationApi(Case caseObj, Map<String, Object> paramsMap) {
        String regionName = caseObj.Region_Flag__c;
        
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }

        HttpRequest request = con.createRequest('PUT', '/api/v1/loans/application', regionName);
        request.setHeader('customerId', caseObj.Customer_CIF__c);
        request.setTimeout(60000);  
        
        if (caseObj.Card_Product_Configuration_Id__c != null) {
            paramsMap.put('loanProductConfigurationId', caseObj.Card_Product_Configuration_Id__c);
        }
        
        String requestBodyJson = JSON.serialize(paramsMap);
        request.setBody(requestBodyJson);
        lastEndpoint = request.getEndpoint();
        
        System.debug(CLASS_NAME + ' Request Endpoint: ' + request.getEndpoint());
        System.debug(CLASS_NAME + ' Request Method: ' + request.getMethod());
        System.debug(CLASS_NAME + ' Request Body:' + request.getBody());
        
        HttpResponse response = Loans_ServiceApiCallsEM.updateLoanApplicationApi(request,200);
        System.debug(CLASS_NAME + ' Response:' + response);
        return response;
    }
    
    public static String getPreScreenerQueueId() {
        Group preScreenerQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Loan Pre-Screening Queue' LIMIT 1];
        return preScreenerQueue.Id;
    }
    
    public static Case getCaseForErrorHandling(String caseId) {
        try {
            return [SELECT Id, Customer_CIF__c, AccountId FROM Case WHERE Id = :caseId LIMIT 1];
        } catch (QueryException qe) {
            return new Case(Id = caseId);
        }
    }
    
    public static void handleApiError(HttpResponse apiResponse) {
        throw new CalloutException('API returned status: ' + apiResponse.getStatusCode() + '. Message: ' + apiResponse.getBody());
    }
    
    public static System_Action__c createSystemActionForSuccess(Case caseObj, Map<String, Object> paramsMap, HttpResponse apiResponse) {
        return setSystemAction(
            JSON.serialize(paramsMap),
            apiResponse.getBody(),
            lastEndpoint,
            'PUT',
            caseObj.Id,
            caseObj.Customer_CIF__c,
            caseObj.AccountId,
            apiResponse.getStatusCode(),
            'Case Reopened Successfully',
            'API Success'
        );
    }
    
    public static System_Action__c createSystemActionForError(String caseId, Case caseObj, Exception e) {
        return setSystemAction(
            'Error: ' + e.getMessage(),
            e.getStackTraceString(),
            lastEndpoint != null ? lastEndpoint : '/api/v1/loans/application',
            'PUT',
            caseId,
            caseObj.Customer_CIF__c,
            caseObj.AccountId,
            500,
            'Case Reopen Failed',
            'API Error'
        );
    }
    
    public static System_Action__c setSystemAction(final String reqBody, final String resBody, final String path, 
                                                  final String method, final Id CaseId, final String custId, 
                                                  final Id AccId, final Integer statCode, final String strAction, 
                                                  final String strType) {
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
        
        return action; 
    }
}