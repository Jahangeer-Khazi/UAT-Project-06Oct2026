/**
* @author Imane Tsioucha
* @date Création 14/11/2023
**
* @description : The class used in LTNG033_ManualOnboardingCase.
*/

public with sharing class LTNG033_ManualOnboardingController {
    
    private static String CLASS_NAME = LTNG033_ManualOnboardingController.class.getName();
    
    @AuraEnabled
    public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Manual_Onboarding_FCR').getRecordTypeId();
    }
    
    @AuraEnabled
    public static void CloseManualOnboardingCaseViaApi(Id caseId){
        System.debug(CLASS_NAME + ' - Starting closeManualOnboardingCaseViaApi for Case Id: ' + caseId);
        
        List<Case> cases = DM002_Case.getListByIds(new Set<Id>{caseId});
        if (cases.isEmpty()) {
            System.debug(CLASS_NAME + ' - No case found for Id: ' + caseId);
            return;
        }
        
        Case caseObj = cases[0];
        Account acc = [SELECT Id, CIF__pc, PersonEmail, Mobile_Country_Code__pc, PersonMobilePhone, Region_Flag__c, 
                       x_canary__pc FROM Account WHERE Id = :caseObj.AccountId LIMIT 1];
        
        ApiConnection con = new ApiConnection();
        String regionName = caseObj.Region_Flag__c;
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }
        
        System.debug(CLASS_NAME + ' - Region name: ' + regionName + ' CIF: ' + acc.CIF__pc);
        
        Http http = new Http();
        HttpRequest requestOne = con.createRequest('DELETE', '/api/v1/distribution/customer/archive', regionName);
        requestOne.setHeader('customerId', acc.CIF__pc);
        
        if(acc.x_canary__pc != null){
            requestOne.setHeader('x-canary', acc.x_canary__pc);
        }
        
        requestOne.setTimeout(30000);
        
        HttpResponse responseOne = http.send(requestOne);
        System.debug(CLASS_NAME + ' - First API Response: ' + responseOne.getStatusCode());
        
        List<System_Action__c> systemActions = new List<System_Action__c>();
        List<Case> casesToUpdate = new List<Case>();
        
        if (responseOne.getStatusCode() == 200) {
        Integer delay =5000;
            Long start = DateTime.now().getTime();
            while(DateTime.now().getTime()-start<delay);
            HttpRequest request = con.createRequest('POST', '/api/v1/onboarding/manual/start?archive=true', regionName);
            HttpResponse response = SM001_ApiCalls.ManualOnboardingAPI(request, acc);
            System.debug(CLASS_NAME + ' - Second API Response: ' + response.getStatusCode());
            
            if (response.getStatusCode() == 200) {
                caseObj.Status = 'Closed';
                casesToUpdate.add(caseObj);
            } else {
                systemActions.add(SM001_ApiCalls.setSystemAction(
                    request.getBody(), response.getBody(), request.getEndpoint(), request.getMethod(),
                    caseObj.Id, caseObj.Customer_CIF__c, caseObj.AccountId, response.getStatusCode(), 
                    'Archival', 'On-boarding'
                ));
            }
        } else {
            systemActions.add(SM001_ApiCalls.setSystemAction(
                requestOne.getBody(), responseOne.getBody(), requestOne.getEndpoint(), requestOne.getMethod(),
                caseObj.Id, caseObj.Customer_CIF__c, caseObj.AccountId, responseOne.getStatusCode(), 
                'Manual Onboarding', 'On-boarding'
            ));
        }
        
        if (!systemActions.isEmpty()) {
            insert systemActions;
            System.debug(CLASS_NAME + ' - Inserted System Actions: ' + systemActions.size());
        }
        
        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
            System.debug(CLASS_NAME + ' - Updated Cases: ' + casesToUpdate.size());
        }
        
        System.debug(CLASS_NAME + ' - Finished closeManualOnboardingCaseViaApi for Case Id: ' + caseId);
    }
}