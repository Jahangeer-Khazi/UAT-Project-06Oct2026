/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  : Elmustapha ELGARNI
**/
public with sharing class Loans_RLOSViewController {
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response callLoanOptionsAPI(final String caseId) {

        List<Case> caseList = [SELECT id, Account.CIF__pc, case_Model__c FROM Case WHERE id =:caseId];

        ApiConnection.Response response = new ApiConnection.Response();

        response = Loans_ServiceManagerHandler.callLoansOptionsAPI(caseList[0].Account.CIF__pc, caseList[0].case_Model__c);
       // System.debug('callLoanOptionsAPI##'+JSON.prettresponse);
         System.debug('callLoanOptionsAPI######'+JSON.serializePretty(response));
        
        return response;
        
        
    }

    // @AuraEnabled
    // public static Case getCaseRecord(String caseId) {
    //     List<Case> caseList = [SELECT Id, Loan_Application_ID__c, case_Model__c FROM Case WHERE Id = :caseId LIMIT 1];
	// 	System.debug('caseList found!!! '+ caseList);
    //     System.debug('caseList Loan_Application_ID__c !!! '+ caseList[0].Loan_Application_ID__c);
    //     if(caseList != null && caseList.size() > 0){
    //         return caseList[0];
    //     }
    //     return null;
    // }
}