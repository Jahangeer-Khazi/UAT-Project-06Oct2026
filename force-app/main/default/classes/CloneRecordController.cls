/**
* @File Name : CloneRecordController.cls
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

public class CloneRecordController {
    @AuraEnabled(cacheable=true)
    public static CloneWrapper cloneRecordWithFiles(String recordId) {
        if (String.isEmpty(recordId)) {
            return null;
        }

        CloneWrapper cw = new CloneWrapper();
        try {

            Content__c parentRecord = [
                SELECT Id, Case__r.CaseNumber, Attachment_Content__c, Attachment_Name__c, Attachment_Type__c,Clicked_From_Case__c,
                       Content_Created_By__c, Customer_CIF__c, Customer_Document_Country__c, Document_Country__c,
                       Document_Expiry_Date__c, Document_Issuer__c, Document_Model__c, Document_Number__c, Document_Type__c,
                       has_Attachment__c, ID_Expiry_Date__c, ID_Number__c, ID_Type__c, Image_Type__c, Issuing_Date__c,
                       Jumio_Reference_Number__c, Lead__c, Name, No_of_Attachment__c, Other_Form__c, Person__c, Is_Already_Clicked__c,
                       Proof_of_Address_ID_Type__c, Region_Flag__c, Reject_Reason__c, Reject_Reason_Details__c, Scan_Type__c, Similarity__c,
                       Upload_Type__c, Validity__c, Verification_Status__c
                FROM Content__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            List<ContentDocumentLink> fileLinks = [
                SELECT Id, ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :recordId
            ];

            cw.cloneContentRecord = parentRecord;
            cw.cloneContentDocumentLinkList = fileLinks;  
            system.debug('###cw##'+cw);
        } catch (Exception e) {
            System.debug('Error in cloneRecordWithFiles: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while cloning the record: ' + e.getMessage());
        }
        
        return cw;
    }
    
    @AuraEnabled
    public static Boolean insertClonedRecord(String cloneJSON, String caseRecordId) {
        if (String.isEmpty(cloneJSON)) {
            return false;
        }
        System.debug('##cloneJSON##'+cloneJSON);
        CloneWrapper cw = (CloneWrapper) System.JSON.deserialize(cloneJSON, CloneWrapper.class);
        List<Content__c> contentList = new List<Content__c>();
        Content__c clonedRecord = cw.cloneContentRecord.clone(false, true, false, false);
        clonedRecord.Is_Already_Linked_to_Case__c = true;
        clonedRecord.Linked_Case_Reference_Number__c = cw.cloneContentRecord.Case__r.CaseNumber;
        clonedRecord.Case__c = cw.cloneContentRecord.Clicked_From_Case__c;

        contentList.add(clonedRecord);

        if (!contentList.isEmpty()) {
            try {
                INSERT contentList; 
            } catch (DmlException e) {
                System.debug('DML error while inserting cloned records: ' + e.getMessage());
                throw new AuraHandledException('Failed to insert cloned record: ' + e.getMessage());
            }
        }
        
        List<ContentDocumentLink> clonedLinks = new List<ContentDocumentLink>();
        for (ContentDocumentLink clonedFile : cw.cloneContentDocumentLinkList) {
            ContentDocumentLink cloneCDL = clonedFile.clone(false, true, false, false);
            cloneCDL.LinkedEntityId = clonedRecord.Id;
            clonedLinks.add(cloneCDL);
        }
       system.debug('###clonedLinks##'+clonedLinks);
        if (!clonedLinks.isEmpty()) {
            try {
                INSERT clonedLinks; 
            } catch (DmlException e) {
                System.debug('DML error while inserting cloned links: ' + e.getMessage());
                throw new AuraHandledException('Failed to insert cloned links: ' + e.getMessage());
            }
        }
        
        if (cw.cloneContentRecord.Id != null) {
            try {
                UPDATE new Content__c(Is_Already_Clicked__c = true, Id = cw.cloneContentRecord.Id); 
            } catch (DmlException e) {
                System.debug('DML error while updating original record: ' + e.getMessage());
                throw new AuraHandledException('Failed to update the original record: ' + e.getMessage());
            }
        }

        return true;
    }
    
    public class CloneWrapper {
        @AuraEnabled public Content__c cloneContentRecord { get; set; }
        @AuraEnabled public List<ContentDocumentLink> cloneContentDocumentLinkList { get; set; }
    }
}