/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 07-02-2024
 * @last modified by  : Elmustapha ELGARNI
**/
public without sharing class ContentDocumentLinkTriggerHandler {
    
    public static void afterInsert(Map<Id, ContentDocumentLink> newMap) {
        Set<Id> linkedEntityIds = new Set<Id>();
        Set<Id> contentDocumentIds = new Set<Id>();
        List<ContentDocumentLink> CDLsList = new List<ContentDocumentLink>();
    
        // Add LinkedEntityId and ContentDocumentId to sets
        for(ContentDocumentLink CDL : newMap.values()){
            linkedEntityIds.add(CDL.LinkedEntityId);
            contentDocumentIds.add(CDL.ContentDocumentId);
        }
    
        // Retrieve cases with required fields
        Map<Id, Case> caseMap = new Map<Id, Case>([
            SELECT Id, AccountId, RecordType.DeveloperName, Region_Flag__c, case_model__c 
            FROM Case 
            WHERE Id IN :linkedEntityIds
        ]);
    
        // Retrieve content documents with their names
        Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>([
            SELECT Id, Title, LatestPublishedVersionId
            FROM ContentDocument 
            WHERE Id IN :contentDocumentIds
        ]);

        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([
            SELECT Id, VersionData
            FROM ContentVersion 
            WHERE ContentDocumentId IN :contentDocumentIds
        ]);
    
        // Define the words to check
        String words = System.Label.Loans_DocuSignFilesKeywords;
        List<String> wordList = words.split(';');
    
        List<Content__c> contentRecordsToInsert = new List<Content__c>();
    
        // Loop through ContentDocumentLink records
        for(ContentDocumentLink CDL : newMap.values()){
            Case caseRecord = caseMap.get(CDL.LinkedEntityId);
            ContentDocument contentDoc = contentDocMap.get(CDL.ContentDocumentId);
    
            System.debug('caseRecord --> ' + caseRecord);
            
            System.debug('contentDoc --> ' + contentDoc);
            
            if(caseRecord != null && caseRecord.RecordType.DeveloperName == 'Loan_Application' && contentDoc != null) {
                Boolean shouldCreateContentRecord = false;
    
                // Check if content document title contains any of the specified words
                for(String word : wordList) {
                    if(contentDoc.Title != null && contentDoc.Title.toLowerCase().contains(word.toLowerCase())) {
                        shouldCreateContentRecord = true;
                        break;
                    }
                }

                if(shouldCreateContentRecord) {
                    Content__c contentObj = new Content__c(
                        Person__c = caseRecord.AccountId,
                        Scan_Type__c = 'Loan Application',
                        Document_Type__c = 'DocuSign Document',
                        Upload_Type__c = 'Digital',
                        Region_Flag__c = caseRecord.Region_Flag__c,
                        //Image_Type__c = 'Front',
                        Verification_Status__c = 'APPROVED_VERIFIED',
                        Similarity__c = 'MATCH',
                        Validity__c = true,
                        Case__c = CDL.LinkedEntityId,
                        Document_Model__c = caseRecord.case_model__c
                    );
                    contentRecordsToInsert.add(contentObj);

                    

                    // Call Upload document 
                    // Loans_UploadDocumentController.uploadDocumentFutureMethod(caseRecord.Id, 'DocuSign Document', contentDoc.Title, EncodingUtil.base64Encode(contentVersionMap.get(contentDoc.LatestPublishedVersionId).VersionData) );
                    
                }
            }
        }
    
        // Insert Content__c records in a single DML operation
        if(!contentRecordsToInsert.isEmpty()){
            insert contentRecordsToInsert;
    
            // Create corresponding ContentDocumentLink records
            for(Content__c contentObj : contentRecordsToInsert){
                for(ContentDocumentLink CDL : newMap.values()){
                    if(CDL.LinkedEntityId == contentObj.Case__c){
                        CDLsList.add(new ContentDocumentLink(
                            LinkedEntityId = contentObj.Id,
                            ContentDocumentId = CDL.ContentDocumentId,
                            ShareType = 'V'
                        ));
                    }
                }
            }
        }
    
        // Insert ContentDocumentLink records in a single DML operation
        if(!CDLsList.isEmpty()){
            insert CDLsList;
        }
    }
}