public with sharing class PDFHandlerController {
    @AuraEnabled(cacheable=true)
    public static List<String> getData(String caseId) {
        List<String> fileData = new List<String>();
        
        try {
            if (caseId != null) {
                // Fetch Content Object related documents first
                List<Case> caseList = [
                    SELECT Id, (SELECT Id FROM Content__r)
                    FROM Case 
                    WHERE Id = :caseId
                    LIMIT 1
                ];
                
                Set<Id> contentIds = new Set<Id>();
                for (Case cs : caseList) {
                    if (cs.Content__r != null && !cs.Content__r.isEmpty()) {
                        for (Content__c cont : cs.Content__r) {
                            contentIds.add(cont.Id);
                        }
                    }
                }
                
                if (!contentIds.isEmpty()) {
                    List<ContentDocumentLink> cdlList = [
                        SELECT ContentDocumentId 
                        FROM ContentDocumentLink 
                        WHERE LinkedEntityId IN :contentIds
                    ];
                    
                    Set<Id> contentDocumentIds = new Set<Id>();
                    for (ContentDocumentLink cdl : cdlList) {
                        contentDocumentIds.add(cdl.ContentDocumentId);
                    }
                    
                    if (!contentDocumentIds.isEmpty()) {
                        List<ContentVersion> cvList = [
                            SELECT Id, VersionData, FileExtension
                            FROM ContentVersion 
                            WHERE ContentDocumentId IN :contentDocumentIds
                            ORDER BY CreatedDate DESC
                        ];
                        
                        for (ContentVersion cv : cvList) {
                            String base64Data = EncodingUtil.base64Encode(cv.VersionData);
                            fileData.add(base64Data);
                        }
                    }
                }
                
                // Fetch Case related documents after Content Object
                List<ContentDocumentLink> cdlList1 = [
                    SELECT ContentDocumentId
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId =: caseId
                ];
                
                Set<Id> contentDocumentIds1 = new Set<Id>();
                for (ContentDocumentLink cdl : cdlList1) {
                    contentDocumentIds1.add(cdl.ContentDocumentId);
                }
                
                if (!contentDocumentIds1.isEmpty()) {
                    List<ContentVersion> cvList1 = [
                        SELECT Id, VersionData, FileExtension
                        FROM ContentVersion 
                        WHERE ContentDocumentId IN :contentDocumentIds1
                        ORDER BY CreatedDate DESC
                    ];
                    
                    for (ContentVersion cv : cvList1) {
                        String base64Data = EncodingUtil.base64Encode(cv.VersionData);
                        fileData.add(base64Data);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error in getData method: ' + e.getMessage());
        }
        
        return fileData;
    }
    
    
    @AuraEnabled
    public static String generateUARDetailsPDF(Id recordId) {
        PageReference pdfPage = Page.VF02_CalculationSummaryReportPdf;
        pdfPage.getParameters().put('Id', recordId);
        Blob pdfBlob;
        
        try {
            pdfBlob = pdfPage.getContentAsPDF();
        } catch (Exception e) {
            System.debug('Error -->'+e.getMessage());
            System.debug('Error Line -->'+e.getLineNumber());
        }
        
        String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;
    }
}