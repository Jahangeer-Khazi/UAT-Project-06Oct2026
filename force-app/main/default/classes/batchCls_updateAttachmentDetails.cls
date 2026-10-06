/*      Organization : ABC Bank
*      Created By: Ashish Pandey
*      Created Date: 30-10-2022
*      Description : Updated Historic Data - DocumentType
*/

global class batchCls_updateAttachmentDetails implements Database.Batchable<sObject>
{
    //where Id = \'a0O1j000002s3cxEAA\'
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, No_of_Attachment__c, Attachment_Type__c,has_Attachment__c,Attachment_Name__c, Attachment_Content__c, Scan_Type__c, ContentVersion_ID__c, Document_Hash__c,(SELECT Id, ContentDocument.Id, ContentDocument.title, ContentDocument.FileType, ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks) FROM Content__c where '+system.label.criteriaUpdateDocDetails;
        system.debug('---> '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        System.debug('inside execur##'+scope);
        List<Content__c> lstContent = (List<Content__c>)scope;
        List<Content__c> lstContentUpdate = new List<Content__c>();
        //String algoName = 'SHA-512';
        for(Content__c objCon:lstContent)
        {
            objCon.No_of_Attachment__c = objCon.ContentDocumentLinks.size();
            if(objCon.ContentDocumentLinks.size() == 0){
                objCon.has_Attachment__c = false;
            }
            else if(objCon.ContentDocumentLinks.size() >0){
                objCon.has_Attachment__c = true;
            }
            System.debug('objCon##'+objCon.ContentDocumentLinks);
            for(ContentDocumentLink objCDL : objCon.ContentDocumentLinks)
            {
                System.debug('objCDL.ContentDocument##'+objCDL.ContentDocument);
                objCon.Attachment_Name__c = objCDL.ContentDocument.title ;
                System.debug('objCon.Attachment_Name__c'+objCon.Attachment_Name__c+ '##'+objCon.Attachment_Name__c.containsIgnoreCase('Front'));
                if(objCon.Attachment_Name__c.containsIgnoreCase('Front'))
                {
                    objCon.Image_Type__c = 'Front';
                }
                if(objCon.Attachment_Name__c.containsIgnoreCase('Back'))
                {
                    objCon.Image_Type__c = 'Back';
                }
                if(objCon.Attachment_Name__c.containsIgnoreCase('Liveness'))
                {
                    objCon.Image_Type__c = 'Face';
                }
                if(objCon.Attachment_Name__c.containsIgnoreCase('face'))
                {
                    objCon.Image_Type__c = 'Face';
                }
                if(objCon.Attachment_Name__c.containsIgnoreCase('selfie'))
                {
                    objCon.Image_Type__c = 'Selfies';
                }
                if(objCon.Attachment_Name__c.containsIgnoreCase('facemap'))
                {
                    objCon.Image_Type__c = 'FaceMap';
                }
                objCon.Attachment_Type__c = objCDL.ContentDocument.FileType ;
                objCon.ContentVersion_ID__c = objCDL.ContentDocument.LatestPublishedVersionId ;
               // Blob encryptedBlob = Crypto.generateDigest(algoName,objCDL.ContentDocument.LatestPublishedVersion.VersionData);
               // String finalEncryptedSignature = EncodingUtil.convertToHex(encryptedBlob);
               // objCon.Document_Hash__c = finalEncryptedSignature;  
            }
            objCon.Updated__c = TRUE;
            lstContentUpdate.add(objCon);
        }
        System.debug('---> '+lstContentUpdate);
        if( lstContentUpdate.size()>0)
         Update lstContentUpdate; 
        //System.debug('---> '+lstContent);
    }
    public void finish(Database.BatchableContext BC) {
    }
}