/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 11-09-2025
*       Change History: 
*        
*/
global class DocumentStatusBatchUpdate implements Database.Batchable<sObject>, Database.Stateful{
    
    Integer batchsize = Integer.valueOf(System.Label.ACCOUNT_RECORD_BATCH_SIZE);
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<String> AcctIds = System.Label.Account_ID_S.split(',');
        String query = '';
        if(System.Label.ACCT_SOQL_ENABLE_FOR_TESTING.equalsIgnoreCase('true')){
            query = System.Label.ACCT_RELATED_CONTENT_SOQL + ' '+ 'AND Id IN : AcctIds';
        }
        if(System.Label.ACCT_SOQL_ENABLE_FOR_PROD.equalsIgnoreCase('true')){
            query = System.Label.ACCT_RELATED_CONTENT_SOQL;
        }
        System.debug('********* Account Related Content SOQL Query ********' +query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accList){
        Map<Id,List<Content__c>> mapAccToContent = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListLivenessVeriffVideo = new Map<Id,List<Content__c>>();
    	Map<Id,List<Content__c>> mapAccountRelatedListJumioSelfies = new Map<Id,List<Content__c>>();
    
    	Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
    	Map<Id,List<Content__c>> mapAccountRelatedListFrontPhoto = new Map<Id,List<Content__c>>();
    	Map<Id,List<Content__c>> mapAccountRelatedListBackPhoto = new Map<Id,List<Content__c>>();
        
        Map<Id,List<Content__c>> mapAccountRelatedListJumioSelfiesPassport = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListFacePhotoPassport = new Map<Id,List<Content__c>>();
        Map<Id,List<Content__c>> mapAccountRelatedListFrontPhotoPassport = new Map<Id,List<Content__c>>();
        List<Account> accToUpdate = new List<Account>();
       
        if(accList.size()>0){
            for(Account acc: accList){
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
                }
            }//for loop Ends
            
            for(Account acc : accList){
                if(!mapAccToContent.isEmpty() && mapAccToContent.containsKey(acc.Id)){
                   List<Content__c> cntList = mapAccToContent.get(acc.Id); 
                    if(cntList.size() > 0){
                        for(Content__c ct : cntList){
                           if(ct.Document_Type__c == 'Video Verification' && ct.Image_Type__c == 'Video' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' &&
                                ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
                                if(mapAccountRelatedListLivenessVeriffVideo.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleVideos =  mapAccountRelatedListLivenessVeriffVideo.get(ct.Person__c);
                                    contentListRecordsHavingMultipleVideos.add(ct);
                                    mapAccountRelatedListLivenessVeriffVideo.put(ct.Person__c,contentListRecordsHavingMultipleVideos);
                                }
                                else{
                                    mapAccountRelatedListLivenessVeriffVideo.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            } 
                           else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Selfies' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' &&
                                ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
                                if(mapAccountRelatedListJumioSelfies.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleSelfies =  mapAccountRelatedListJumioSelfies.get(ct.Person__c);
                                    contentListRecordsHavingMultipleSelfies.add(ct);
                                    mapAccountRelatedListJumioSelfies.put(ct.Person__c,contentListRecordsHavingMultipleSelfies);
                                }
                                else{
                                    mapAccountRelatedListJumioSelfies.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            } 
                           else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' &&
                                ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
                                if(mapAccountRelatedListFacePhoto.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleFaces =  mapAccountRelatedListFacePhoto.get(ct.Person__c);
                                    contentListRecordsHavingMultipleFaces.add(ct);
                                    mapAccountRelatedListFacePhoto.put(ct.Person__c,contentListRecordsHavingMultipleFaces);
                                }
                                else{
                                    mapAccountRelatedListFacePhoto.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            }
                            else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && 
                               ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
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
                            else if(ct.Document_Type__c == 'Bahraini ID' && ct.Image_Type__c == 'Back' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' &&
                                ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
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
                            else if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Selfies' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' &&
                                ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
                                if(mapAccountRelatedListJumioSelfies.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleSelfies =  mapAccountRelatedListJumioSelfies.get(ct.Person__c);
                                    contentListRecordsHavingMultipleSelfies.add(ct);
                                    mapAccountRelatedListJumioSelfiesPassport.put(ct.Person__c,contentListRecordsHavingMultipleSelfies);
                                }
                                else{
                                    mapAccountRelatedListJumioSelfiesPassport.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            } 
                            else if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Face' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' &&
                                ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
                                if(mapAccountRelatedListFacePhoto.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleFaces =  mapAccountRelatedListFacePhoto.get(ct.Person__c);
                                    contentListRecordsHavingMultipleFaces.add(ct);
                                    mapAccountRelatedListFacePhotoPassport.put(ct.Person__c,contentListRecordsHavingMultipleFaces);
                                }
                                else{
                                    mapAccountRelatedListFacePhotoPassport.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            }
                            else if(ct.Document_Type__c == 'Passport' && ct.Image_Type__c == 'Front' && ct.Verification_Status__c == 'APPROVED_VERIFIED' && ct.Similarity__c == 'MATCH' && 
                               ct.Validity__c == true && ct.Document_Country__c == 'BH' && ct.Scan_Type__c == 'POI' && (!(ct.Document_Number__c).contains('DUPLICATE'))){
                                System.debug('Front Records');
                                 if(mapAccountRelatedListFrontPhoto.containsKey(ct.Person__c)){
                                    List<Content__c> contentListRecordsHavingMultipleFront =  mapAccountRelatedListFrontPhoto.get(ct.Person__c);
                                    contentListRecordsHavingMultipleFront.add(ct);
                                    mapAccountRelatedListFrontPhotoPassport.put(ct.Person__c,contentListRecordsHavingMultipleFront);
                                }
                                else{
                                    mapAccountRelatedListFrontPhotoPassport.put(ct.Person__c,new List<Content__c>{ct});
                                } 
                            }
                           
                        } //Inner for loop Ends
                    } //If Ends
                }
            } //for loop Ends
            for(Account acc : accList){
                if(acc.ID_Type__pc == 'Bahrani ID'){
                    if((mapAccountRelatedListLivenessVeriffVideo.containsKey(acc.Id) || mapAccountRelatedListJumioSelfies.containsKey(acc.Id)) &&
                       mapAccountRelatedListFacePhoto.containsKey(acc.Id) && mapAccountRelatedListFrontPhoto.containsKey(acc.Id) && mapAccountRelatedListBackPhoto.containsKey(acc.Id)){
                           acc.Documents_Status__pc = 'Complete';
                           accToUpdate.add(acc);
                       }
                    else{
                        acc.Documents_Status__pc = 'Missing';
                        accToUpdate.add(acc);
                    } 
                }
                else if(acc.ID_Type__pc == 'Passport' && acc.Nationality__pc == 'BH'){
                     if((mapAccountRelatedListLivenessVeriffVideo.containsKey(acc.Id) || mapAccountRelatedListJumioSelfiesPassport.containsKey(acc.Id)) &&
                       mapAccountRelatedListFacePhotoPassport.containsKey(acc.Id) && mapAccountRelatedListFrontPhotoPassport.containsKey(acc.Id)){
                           acc.Documents_Status__pc = 'Complete';
                           accToUpdate.add(acc);
                       }
                    else{
                        acc.Documents_Status__pc = 'Missing';
                        accToUpdate.add(acc);
                    } 
                }
                else if(acc.ID_Type__pc == 'Passport' && acc.Nationality__pc != 'BH'){
                    if((mapAccountRelatedListLivenessVeriffVideo.containsKey(acc.Id) || mapAccountRelatedListJumioSelfiesPassport.containsKey(acc.Id)) &&
                       mapAccountRelatedListFacePhotoPassport.containsKey(acc.Id) && mapAccountRelatedListFrontPhotoPassport.containsKey(acc.Id)){
                           acc.Documents_Status__pc = 'Unable to Verify';
                           accToUpdate.add(acc);
                       }
                    else{
                        acc.Documents_Status__pc = 'Unable to Verify';
                        accToUpdate.add(acc);
                    } 
                }
                
            } //for loop Ends
            if(accToUpdate.size() > 0){
                update accToUpdate;
            }
        }
        
    }
    global void finish(Database.BatchableContext BC) {
    }
}