/**
* @File Name : CustomRelatedListController.cls
* @Description :
* @Author : Krishan
* @Last Modified By :
* @Last Modified On : October 10, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 10, 2024 |   | Initial Version
**/
public class CustomRelatedListController {
    
    @AuraEnabled(cacheable=true)
    public static List<Content__c> getRelatedList(String accountId,String caseId) {
        if (String.isEmpty(accountId)) {
            return null;
        }

        try {
            Set<String> caseTypes = new Set<String>{'Credit Card Application', 'Credit Limit Increase Application'};
            Set<String> caseSubTypes = new Set<String>{'New Credit Card', 'Credit Limit Increase'};
            String caseStatus = 'Closed';
            List<String> caseSubStatus = New List<String>{'Approved','Balance Transfer Processed'};

            if (String.isNotEmpty(accountId)) {
                Case caseObj = [
                    SELECT Id, AccountId, Type, Sub_Type__c, Status, Sub_Status__c, ClosedDate,
                    (SELECT Id, Name, Document_Type__c, Scan_Type__c, Attachment_Name__c, 
                    CreatedDate, Case__r.CaseNumber, Document_Model__c, 
                    Document_Number__c, Attachment_Type__c FROM Content__r) FROM Case
                    WHERE AccountId = :accountId 
                    AND Type IN :caseTypes 
                    AND Sub_Type__c IN :caseSubTypes 
                    AND Status = :caseStatus 
                    AND Sub_Status__c IN :caseSubStatus
                    AND Id IN (SELECT Case__c FROM Content__c) 
                    AND Id !=:caseId
                    ORDER BY ClosedDate DESC LIMIT 1
                ];
                return caseObj.Content__r;
            }
        } catch (Exception e) {
            return new List<Content__c>();
        }       
        return new List<Content__c>();
    }
    
    @AuraEnabled
    public static Boolean updateContentRecord(String contentId, String caseId) {
        System.debug('updateContentRecord-contentId'+contentId);
        System.debug('updateContentRecord-caseId'+caseId);
         if (String.isEmpty(contentId) && String.isEmpty(caseId)) {
            return null;
        }
        try {
           UPDATE new Content__c(Id = contentId, Clicked_From_Case__c = caseId);
            return true;
        }catch (Exception e) {
            return false;
        }
    } 
}