/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 22-05-2023
*       Change History: 
*        
*/
global class ContentValidityBatchUpdate implements Database.Batchable<sObject>, Database.Stateful{
    List<String> contentIds = new List<String>();
    Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
    Map<Id,List<Content__c>> mapAccountRelatedListFrontPhoto = new Map<Id,List<Content__c>>();
    Map<Id,List<Content__c>> mapAccountRelatedListBackPhoto = new Map<Id,List<Content__c>>();
    Integer batchsize = Integer.valueOf(System.Label.BATCH_SIZE);
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> contentDocumentIds = System.Label.CONTENT_IDS.split(',');
        String query = '';
        if(System.Label.CONTENT_SOQL_ENABLE_FOR_TESTING.equalsIgnoreCase('true')){
            query = System.Label.CONTENT_UPDATE_VALIDITY_SOQL + ' '+ 'AND Id IN : contentDocumentIds order by CreatedDate ASC';
        }
        if(System.Label.CONTENT_SOQL_ENABLE_FOR_PROD.equalsIgnoreCase('true')){
            query = System.Label.CONTENT_UPDATE_VALIDITY_SOQL + ' '+ 'order by CreatedDate ASC';
        }
        system.debug('---> '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Content__c> lstContent)
    {
        
        Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
        System.debug('inside execute##'+lstContent);
        System.debug('List Content Size :' +lstContent.size());
        if(lstContent.size() > 0){
           for(Content__c ct : lstContent){ //Content For Loop Start
                if(mapAccToContent.containsKey(ct.Person__c)){
                    List<Content__c> contentList =  mapAccToContent.get(ct.Person__c);
                    contentList.add(ct);
                    mapAccToContent.put(ct.Person__c,contentList);
                }
                else{
                    mapAccToContent.put(ct.Person__c,new List<Content__c>{ct});
                }
            } //Content For Loop END
            if(!mapAccToContent.isEmpty()){
                for(Id accId : mapAccToContent.keySet()){
                    List<Content__c> cntList = mapAccToContent.get(accId);
                    if(cntList.size()>0){
                        for(Content__c ct : cntList){
                            if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH'){
                                if(mapAccountRelatedListFrontPhoto.containsKey(ct.Person__c)){
                                     List<Content__c> contentListRecordsHavingMultipleFront =  mapAccountRelatedListFrontPhoto.get(ct.Person__c);
									 contentListRecordsHavingMultipleFront.add(ct);
                                     mapAccountRelatedListFrontPhoto.put(ct.Person__c,contentListRecordsHavingMultipleFront);
                                }
                                else{
                                    mapAccountRelatedListFrontPhoto.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            }
                            else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Back' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH'){
                                System.debug('Back Records');
                                 if(mapAccountRelatedListBackPhoto.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleBack =  mapAccountRelatedListBackPhoto.get(ct.Person__c);
                                    contentListRecordsHavingMultipleBack.add(ct);
                                    mapAccountRelatedListBackPhoto.put(ct.Person__c,contentListRecordsHavingMultipleBack);
                                }
                                else{
                                    mapAccountRelatedListBackPhoto.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            }
                            else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH'){
                                if(mapAccountRelatedListFacePhoto.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleFaces =  mapAccountRelatedListFacePhoto.get(ct.Person__c);
                                    contentListRecordsHavingMultipleFaces.add(ct);
                                    mapAccountRelatedListFacePhoto.put(ct.Person__c,contentListRecordsHavingMultipleFaces);
                                }
                                else{
                                    mapAccountRelatedListFacePhoto.put(ct.Person__c,new List<Content__c>{ct});
                                }
                            }
                            
                        } //inner for loop Ends
                    }
                } //Outer for loop Ends
            } //If Ends
         } //Main If Ends
    }
    global void finish(Database.BatchableContext BC) {
        System.debug('Face Photo:'+mapAccountRelatedListFacePhoto.values());
        System.debug('Front Photo Size:'+mapAccountRelatedListFrontPhoto.values());
        System.debug('Back Photo Size:'+mapAccountRelatedListBackPhoto.values());
        ContentValidityBatchUpdateChild cvChildBatch = new ContentValidityBatchUpdateChild(mapAccountRelatedListFacePhoto,mapAccountRelatedListFrontPhoto,mapAccountRelatedListBackPhoto);
        ID childBatchId = Database.executeBatch(cvChildBatch,batchsize);
    }

}