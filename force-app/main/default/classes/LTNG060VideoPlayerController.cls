public with sharing class LTNG060VideoPlayerController {
    @AuraEnabled
    public static String getVideoUrl(Id recordId) {
        // Find the latest video file attached to the record
        ContentDocumentLink link = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            ORDER BY ContentDocument.CreatedDate DESC
            LIMIT 1
        ];
        
        // Get the ContentVersion URL
        ContentVersion version = [
            SELECT Id, ContentDocumentId, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :link.ContentDocumentId
            ORDER BY VersionNumber DESC
            LIMIT 1
        ];
        
        return '/sfc/servlet.shepherd/version/download/' + version.Id;
    }
}