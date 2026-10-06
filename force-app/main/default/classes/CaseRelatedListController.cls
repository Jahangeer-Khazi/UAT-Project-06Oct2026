/********************************************************************************************
* @name                 CaseRelatedListController
* @description          This controller is responsible to return the list of case records for Whitelist employer
* @date                 17/07/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           17/07/2025     Initial Version
*********************************************************************************************
*/

public class CaseRelatedListController {

    @AuraEnabled(Cacheable=true)
    public static ApiConnection.Response getCaseRecords(Id recordId,String caseRecordType){
        final ApiConnection.Response response = new ApiConnection.Response();
        
        system.debug('caseRecordType ' + caseRecordType);
        
        List<Case> listOfCases = new List<Case>();
        //commented for Loans - NBA-13013
        /*if(caseRecordType == 'Loan_Application'){
        	listOfCases = [SELECT Id,CaseNumber,CaseAnnex__r.cx_ln_Loan_Finance_Type__c,Case_Model__c,
                                  CaseAnnex__r.cx_ln_Product__c,CaseAnnex__r.cx_ln_Business_Nature_Type__c,
                                  Customer_CIF__c,Status, Sub_Status__c,CreatedDate,ClosedDate,Contact_Name__c
                                  FROM Case WHERE Listed_Employer_Name__c =:recordId AND RecordType.DeveloperName =:caseRecordType];    
        }
        else {*/
        
            listOfCases = [SELECT Id,CaseNumber,cc_Approved_Requested_Card_Type__c,cc_Requested_Card_Type__c,cc_Credit_Card_PCI_Number__c,
                                  Status, Sub_Status__c,CreatedDate,ClosedDate,PrimaryMaskedCardNumber__c 
                                  FROM Case WHERE Listed_Employer_Name__c =:recordId AND RecordType.DeveloperName =:caseRecordType];
            
            Map<String,String> approvedRequestedCardTypeMap = getPicklistKeyValueMap('Case','cc_Approved_Requested_Card_Type__c');
            Map<String,String> requestedCardTypeMap = getPicklistKeyValueMap('Case','cc_Requested_Card_Type__c');
            
            for(Case caseRecord: listOfCases){
                String approvedRequestedCardType = caseRecord.cc_Approved_Requested_Card_Type__c;
                String requestedCardType = caseRecord.cc_Requested_Card_Type__c;
                caseRecord.cc_Approved_Requested_Card_Type__c = (String)approvedRequestedCardTypeMap.get(approvedRequestedCardType);
                caseRecord.cc_Requested_Card_Type__c = (String)requestedCardTypeMap.get(requestedCardType);
            }
      //  }//commented for Loans - NBA-13013
                
        
        if(listOfCases.isEmpty()){
            response.isSuccess = false;
        }
        else {
            response.isSuccess = true;
            response.responseData = listOfCases;
        }
        return response;
    }
    
    public static Map<String,String> getPicklistKeyValueMap(String objectName,String fieldName){
        Map<String,String> picklistMap = new Map<String,String>();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult fieldResult = describeResult.fields.getMap().get(fieldName).getDescribe();
        
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : picklistValues) {
            picklistMap.put(entry.getValue(),entry.getLabel());
        }
        return picklistMap;
    }
}