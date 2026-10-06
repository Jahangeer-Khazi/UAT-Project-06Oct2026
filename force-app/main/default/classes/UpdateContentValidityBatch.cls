/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 15-05-2023
*       Change History: 
*        
*/
global class UpdateContentValidityBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> contentDocumentAccountIds = System.Label.CONTENT_ACCOUNTIDS.split(',');
        String query = '';
        if(System.Label.CONTENT_SOQL_ENABLE_FOR_TESTING.equalsIgnoreCase('true')){
            query = System.Label.CONTENT_VALIDITY_SOQL + ' '+ 'AND Id IN : contentDocumentAccountIds' ;
        }
        if(System.Label.CONTENT_SOQL_ENABLE_FOR_PROD.equalsIgnoreCase('true')){
             query = System.Label.CONTENT_VALIDITY_SOQL + ' ' + 'LIMIT' + ' '+System.Label.CONTENT_SIZE;
        }
        
        /*if(System.Label.CONTENT_SOQL_ENABLE_FOR_TESTING.equalsIgnoreCase('true')){
            query = 'Select id, '+
            '(SELECT Id,Person__c,Document_Type__c,Verification_Status__c,Validity__c,Similarity__c,Document_Hash__c,Image_Type__c FROM Content__r where (Document_Type__c = \'Wathiq Consent Form\' OR Document_Type__c = \'Bahraini ID\') AND Updated__c=TRUE AND Region_Flag__c = \'Bahrain\' order by CreatedDate ASC) '+
             'Onboarding_Stage__pc,Region_Flag__pc from Account where Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND Region_Flag__pc = \'Bahrain\' AND Blacklisted__c != true AND Id IN : contentDocumentAccountIds';
        } */
        /*if(System.Label.CONTENT_SOQL_ENABLE_FOR_PROD.equalsIgnoreCase('true')){
            query = 'Select id, '+
            '(SELECT Id,Person__c,Document_Type__c,Verification_Status__c,Validity__c,Similarity__c,Document_Hash__c,Image_Type__c FROM Content__r where (Document_Type__c = \'Wathiq Consent Form\' OR Document_Type__c = \'Bahraini ID\') AND Updated__c=TRUE AND Region_Flag__c = \'Bahrain\' order by CreatedDate ASC) '+
             'Onboarding_Stage__pc,Region_Flag__pc from Account where Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND Region_Flag__pc = \'Bahrain\' AND Blacklisted__c != true';
        } */
        System.debug('*********Soql Query ********' +query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accList)
    {
        System.debug('inside execute##'+accList);
        System.debug('Acc List Size ##'+accList.size());
        List<Content__c> lstContentToUpdate = new List<Content__c>();
        Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListFrontPhoto = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListBackPhoto = new Map<Id,List<Content__c>>();
        if(accList.size()>0){
            for(Account acc : accList){
                System.debug('Account Ids:'+acc.Id);
                if(acc.Content__r.size() > 0){
                    for(Content__c ct : acc.Content__r){
                        System.debug('Content Doc:' + ct);
                        if(mapAccToContent.containsKey(ct.Person__c)){
                            List<Content__c> contentList =  mapAccToContent.get(ct.Person__c);
                            contentList.add(ct);
                            mapAccToContent.put(ct.Person__c,contentList);
                        }
                        else{
                            mapAccToContent.put(ct.Person__c,new List<Content__c>{ct});
                        }
                    } //Inner for loop Ends
                } //If Ends
            } //for loop Ends
            for(Account acc : accList){
                if(!mapAccToContent.isEmpty() && mapAccToContent.containsKey(acc.Id)){
                   List<Content__c> cntList = mapAccToContent.get(acc.Id); 
                    if(cntList.size() > 0){
                        for(Content__c ct : cntList){
                            if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH'){
                                System.debug('Front Records');
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
                        } //Inner for loop Ends
                    } //If Ends
                }
            } //for loop Ends
            
            for(Account acc : accList){
                if(!mapAccountRelatedListFacePhoto.isEmpty() && mapAccountRelatedListFacePhoto.containsKey(acc.Id)){
                    List<Content__c> lstContentFaceRecords = mapAccountRelatedListFacePhoto.get(acc.Id);
                    System.debug('Multiple face Record Size in accounts:'+lstContentFaceRecords.size());
                    if(lstContentFaceRecords.size() >= 3){
                        System.debug('Face Records Greater then 3');
                        Content__c cnt = lstContentFaceRecords.get(2);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt);
                    }
                    else if(lstContentFaceRecords.size() == 2){
                        System.debug('Face Records Equal to 2');
                        Content__c cnt = lstContentFaceRecords.get(1);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt);
                    }
                    else if(lstContentFaceRecords.size() == 1){
                        System.debug('Face Records Equal to 1');
                        Content__c cnt = lstContentFaceRecords.get(0);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt);  
                    }
                } //If Ends
                if(!mapAccountRelatedListFrontPhoto.isEmpty() && mapAccountRelatedListFrontPhoto.containsKey(acc.Id)){
                    List<Content__c> lstContentFrontRecords = mapAccountRelatedListFrontPhoto.get(acc.Id);
                    if(lstContentFrontRecords.size() > 0){
                        Content__c cnt = lstContentFrontRecords.get(lstContentFrontRecords.size() - 1);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt); 
                    }
                }
                if(!mapAccountRelatedListBackPhoto.isEmpty() && mapAccountRelatedListBackPhoto.containsKey(acc.Id)){
                    List<Content__c> lstContentBackRecords = mapAccountRelatedListBackPhoto.get(acc.Id);
                    if(lstContentBackRecords.size() > 0){
                        Content__c cnt = lstContentBackRecords.get(lstContentBackRecords.size() - 1);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt); 
                    }
                }
            } //for loop Ends
            
        } //Main If Ends
        
        if(lstContentToUpdate.size() > 0){
            update lstContentToUpdate;
        }
        
    }
    public void finish(Database.BatchableContext BC) {
    }
}