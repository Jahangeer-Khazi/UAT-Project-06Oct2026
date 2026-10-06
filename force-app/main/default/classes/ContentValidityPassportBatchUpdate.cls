/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 18-07-2023
*       Change History: 
*        
*/
global class ContentValidityPassportBatchUpdate implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> contentDocumentAccountIds = System.Label.CONTENT_ACCOUNTIDS.split(',');
        String query = '';
        
        if(System.Label.CONTENT_SOQL_ENABLE_FOR_PROD.equalsIgnoreCase('true') && !test.isRunningTest()){
            query = System.Label.CONTENT_UPDATE_VALIDITY_PASSPORT_SOQL + ' '+ 'AND Id IN : contentDocumentAccountIds' ;
        }
        if(test.isRunningTest()){
            query = System.Label.CONTENT_UPDATE_VALIDITY_PASSPORT_SOQL;
        }
       
        system.debug('---> '+query);
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext BC, List<Account> accList)
    {
        System.debug('inside execute##'+accList);
        System.debug('Acc List Size ##'+accList.size());
        Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
    	Map<Id,List<Content__c>> mapAccountRelatedListFrontPhoto = new Map<Id,List<Content__c>>();
        List<Content__c> lstContentToUpdate = new List<Content__c>();
		if(accList.size() > 0){
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
                            if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI'){
                                if(mapAccountRelatedListFrontPhoto.containsKey(ct.Person__c)){
                                     List<Content__c> contentListRecordsHavingMultipleFront =  mapAccountRelatedListFrontPhoto.get(ct.Person__c);
									 contentListRecordsHavingMultipleFront.add(ct);
                                     mapAccountRelatedListFrontPhoto.put(ct.Person__c,contentListRecordsHavingMultipleFront);
                                }
                                else{
                                    mapAccountRelatedListFrontPhoto.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            }
                            
                            else if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI'){
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
                    } //inner If loop Ends
                } //If Ends
            } //for Ends
            
            for(Account acc : accList){
                if(!mapAccountRelatedListFacePhoto.isEmpty() && mapAccountRelatedListFacePhoto.containsKey(acc.Id)){
                    List<Content__c> lstContentFaceRecords = mapAccountRelatedListFacePhoto.get(acc.Id);
                    System.debug('Multiple face Record Size in case creation:'+lstContentFaceRecords.size());
                    if(lstContentFaceRecords.size() >= 3){
                        Content__c cnt = lstContentFaceRecords.get(2);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt);
                    }
                    else if(lstContentFaceRecords.size() == 2){
                        Content__c cnt = lstContentFaceRecords.get(1);
                        cnt.Validity__c = true;
                        lstContentToUpdate.add(cnt);
                    }
                    else if(lstContentFaceRecords.size() == 1){
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
            } //for loop Ends
        } //Main If Ends
        if(lstContentToUpdate.size() > 0){
            update lstContentToUpdate;
        }
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}