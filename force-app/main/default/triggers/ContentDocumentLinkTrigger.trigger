/*
    Change History:
            CH01: Elmustapha, 20/05/2024 // once a document is uploaded to case (loan application) create a content record and attach it to the case

*/

trigger ContentDocumentLinkTrigger on ContentDocumentLink ( after insert, after update, after delete ) {

   // CH01 Start
    if(Trigger.isInsert && Trigger.isAfter ){
        ContentDocumentLinkTriggerHandler.afterInsert(Trigger.newMap);
    }
    // CH01 End

    List<ContentDocumentLink> cdls = ( Trigger.new == null ? Trigger.old : Trigger.new );

    Set<ID> parentIds = new Set<ID>();
    Set<ID> relatedDocumentID = new Set<ID>();
    List<Content__c> lstCon = new List<Content__c>();
    String algoName = 'SHA-512';

    for ( ContentDocumentLink cdl : cdls ) {
        parentIds.add(cdl.LinkedEntityId );
        //relatedDocumentID.add(cdl.ContentDocumentId);
    }

    for(List<Content__c> lstContent : [SELECT Id, No_of_Attachment__c, has_Attachment__c, Attachment_Name__c, Attachment_Content__c, (SELECT Id, ContentDocument.Id, ContentDocument.title, 
                                       ContentDocument.FileType, ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLinks) FROM Content__c WHERE Id IN :parentIds])
    {
        for ( Content__c objCon : lstContent ) 
        {
            objCon.No_of_Attachment__c = objCon.ContentDocumentLinks.size();
            if(objCon.ContentDocumentLinks.size() == 0){
                objCon.has_Attachment__c = false;
            }
            else if(objCon.ContentDocumentLinks.size() >0){
                objCon.has_Attachment__c = true;
            }
            for(ContentDocumentLink objCDL : objCon.ContentDocumentLinks)
            {
                objCon.Attachment_Name__c = objCDL.ContentDocument.title ;
                objCon.Attachment_Type__c = objCDL.ContentDocument.FileType ;
                objCon.ContentVersion_ID__c = objCDL.ContentDocument.LatestPublishedVersionId ;
                Blob encryptedBlob = Crypto.generateDigest(algoName,objCDL.ContentDocument.LatestPublishedVersion.VersionData);
                String finalEncryptedSignature = EncodingUtil.convertToHex(encryptedBlob);
                objCon.Document_Hash__c = finalEncryptedSignature;
                //system.debug('---> '+EncodingUtil.base64Encode(objCDL.ContentDocument.LatestPublishedVersion.VersionData.size()));
                //objCon.Attachment_Base_64_Coding__c =  EncodingUtil.base64Encode(objCDL.ContentDocument.LatestPublishedVersion.VersionData);
            }
            lstCon.add(objCon);
        }
    }
    Update lstCon;
}