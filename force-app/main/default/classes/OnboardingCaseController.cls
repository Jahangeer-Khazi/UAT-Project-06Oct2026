/**
*  @author: Andrey Gavrikov (westbrook)
*  @date: 2019-03-21 12:55:49
*  @description:
*      controller for aura component: onboardingCaseClosure
*          
*  Version History :
*  2021-11-27 - #CH02# - YZ Region Name changes
*  2019-03-21 - CRM-121 - AG  CRM-121- Identification Approve or Reject
*  #CH3# 2024-11-19 - PI-3713 Fix
*/
public with sharing virtual class OnboardingCaseController {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    
    
    @TestVisible
    private static OnboardingCaseController DAO = new OnboardingCaseController();
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadCase(final Id recordId) {
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = DAO.loadCaseDml(recordId);
        return response;
    }
    
    /**
*  @param: actionName - e.g. 'Identification'
*/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendOnboardingContinueRequest(final Id caseId, final String customerId,
                                                                       final String actionName, final String requestBody, final String email, String regionName) {
                                                                           final String path = '/api/v1/onboarding/continue?';
                                                                           System.debug('path --->'+path);
                                                                           System.debug('customerId --->'+customerId);
                                                                           System.debug('email --->'+email);
                                                                           System.debug('regionName --->'+regionName);
                                                                           System.debug('caseId --->'+caseId);
                                                                           
                                                                           System.debug('actionName --->'+actionName);
                                                                           
                                                                           final HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
                                                                           req.setBody(requestBody);
                                                                           
                                                                           System.debug('>>>>>>>>> sendComplianceCheckRequest req header with email: '+ req.getHeader('userId'));
                                                                           final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionName);
                                                                           action.Type__c = 'Onboarding';
                                                                           
                                                                           return makeCallout(req, action);
                                                                       }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendOnboardingContinueRequestForEkey(final Id caseId, final String customerId,
                                                                       final String actionName, final String requestBody, final String email, String regionName) {
                                                                           final String path = '/api/v1/onboarding?';
                                                                           System.debug('path --->'+path);
                                                                           System.debug('customerId --->'+customerId);
                                                                           System.debug('email --->'+email);
                                                                           System.debug('regionName --->'+regionName);
                                                                           System.debug('caseId --->'+caseId);
                                                                           
                                                                           System.debug('actionName --->'+actionName);
                                                                           
                                                                           final HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
                                                                           req.setBody(requestBody);
                                                                           
                                                                           System.debug('>>>>>>>>> sendComplianceCheckRequest req header with email: '+ req.getHeader('userId'));
                                                                           final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionName);
                                                                           action.Type__c = 'Onboarding';
                                                                           
                                                                           return makeCallout(req, action);
                                                                       }
    /**
*  @param: actionName - e.g. 'Identification'
*/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response sendComplianceCheckRequest(final Id caseId, final String customerId, final String actionName, final String email, String regionName) {
        final String path = '/api/v1/compliances?';
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        //req.setBody(requestBody);
        
        //TODO remove debug code once API is available
        /*    ApiConnection.Response response = new ApiConnection.Response();
response.isSuccess = true;
String str = '{' +
'    "meta": {' +
'        "code": "COMP-1001",' +
'        "message": "Case status has been retrieved successfully."' +
'    },' +
'    "data": {' +
'        "status": "released",' +
'        "screeningResults": "P",' +
'        "decision": "EDD"' +
'    }'+
'}';
response.responseData = JSON.deserializeUntyped(str);
if (true) return response;
// END DEBUG
*/
        System.debug('>>>>>>>>> sendComplianceCheckRequest');
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionName);
        action.Type__c = 'Onboarding';
        
        return makeCallout(req, action);
    }
    
    /**
*  Modified by SP
*  Date 08/06/19
*  comment code : response.isSuccess = true
*/
    public static ApiConnection.Response makeCallout(final HttpRequest req, final System_Action__c action) {
        req.setTimeout(120000);
        final ApiConnection.Response response = con.makeCallout(req, action);
        //response.isSuccess = true; //TODO - remove when API is available
        System.debug('>>>>>>>response req: ' + JSON.serializePretty(response));
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response setNameScreeningResult(final Id accountId, final String result) {
        final Account acc = new Account(Id = accountId, Name_Screening_Result__pc = result, Bypass_Validations__pc = true);
        final List<String> errors = DAO.updateRecords(new List<Account>{acc});
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = errors.isEmpty();
        response.errorData = JSON.serialize(errors);
        return response;
        
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response updateCaseStatus(final Id caseId, final String status, final String closureType,
                                                          final String rejectReason, final Date fatcaDocumentExpiryDate, 
                                                          final String formType) {
                                                              final Case caseRec = new Case(
                                                                  Id = caseId,
                                                                  Status = status,
                                                                 // Sub_Status__c = status,
                                                                  Closure_Type__c = closureType,
                                                                  Case_Reject_Reason__c = rejectReason,
                                                                  FATCA_Document_Expiry_Date__c = fatcaDocumentExpiryDate
                                                              );
                                                              final List<String> errors = DAO.updateRecords(new List<Case>{caseRec});
                                                              final ApiConnection.Response response = new ApiConnection.Response();
                                                              response.isSuccess = errors.isEmpty();
                                                              response.errorData = JSON.serialize(errors);
                                                             // CH3 - START 
                                                              if(errors.isEmpty()){
                                                                  List<Case> caseObj = [Select Id, AccountId From Case Where Id =: caseId and type='FATCA' LIMIT 1]; 
                                                                 if(!caseObj.isEmpty()){
                                                                  List<Account> accList = new List<Account>();                                                                                                    
                                                                  Account acc = new Account();
                                                                  acc.Id = caseObj[0].AccountId;
                                                                  acc.FATCA_Declaration_Form_Type__pc =(status=='Approved'?formType:''); 
                                                                  acc.FATCA_Declaration_Last_Update__pc = (status=='Approved'?System.now():null);
                                                                  acc.FATCA_Customer__pc=(status=='Approved'?true:false);
                                                                  acc.US_Indicia__pc=(status=='Approved'?true:false);
                                                                  acc.Applicable_Residency_Tax__pc=(status=='Approved'?'Yes':'No');
                                                                     if(status=='Rejected'){
                                                                         acc.Tax_Country_1__pc='';
                                                                         acc.Tax_Country_1_ID__pc='';
                                                                         acc.Tax_Country_2__pc='';
                                                                         acc.Tax_Country_2_ID__pc='';
                                                                         acc.Tax_Country_3__pc='';
                                                                         acc.Tax_Country_3_ID__pc='';
                                                                         acc.Tax_Country_4__pc='';
                                                                         acc.Tax_Country_4_ID__pc='';
                                                                     }
                                                                 
                                                                  accList.add(acc);
                                                                  if(!accList.isEmpty()){
                                                                      UPDATE accList;
                                                                  }  
                                                                }   
                                                              }
                                                                                                              
                                                             // CH3 - END
                                                              return response;
                                                              
                                                          }
    
    protected virtual Case loadCaseDml(final Id caseId) {
        return [select Id, Account.Id, Account.Name, Account.CIF__pc, Account.Onboarding_Stage__pc, Account.PersonEmail,Sub_Type__c,
                Status, Type, RecordType.DeveloperName, RecordTypeId, Region_Flag__c, // #CH02#
                Closure_Type__c, Case_Reject_Reason__c, FATCA_Document_Expiry_Date__c, Lead_Created_Account__c
                from Case where Id = :caseId limit 1];
    }
    
    
    protected virtual List<String> updateRecords(final List<SObject> recs) {
        final List<String> errors = new List<String>();
        for(Database.SaveResult res : Database.update(recs, /*all_or_none=*/false)) {
            if (!res.isSuccess()) {
                errors.add(res.getErrors()[0].getMessage());
            }
        }
        return errors;
    }
}