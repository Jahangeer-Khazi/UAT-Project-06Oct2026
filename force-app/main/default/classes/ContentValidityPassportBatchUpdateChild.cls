/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 18-07-2023
*       Change History: 
*        
*/
global class ContentValidityPassportBatchUpdateChild implements Database.Batchable<sObject>, Database.Stateful {
    Map<Id,List<Content__c>> mapAccountRelatedListFacePhoto = new Map<Id,List<Content__c>>();
    Map<Id,List<Content__c>> mapAccountRelatedListFrontPhoto = new Map<Id,List<Content__c>>();
    List<String> contentIds = new List<String>();
    
    public ContentValidityPassportBatchUpdateChild(Map<Id,List<Content__c>> mapAccountRelatedListFacePhotoPassed, Map<Id,List<Content__c>> mapAccountRelatedListFrontPhotoPassed){
        
        mapAccountRelatedListFacePhoto = mapAccountRelatedListFacePhotoPassed;
        mapAccountRelatedListFrontPhoto = mapAccountRelatedListFrontPhotoPassed;
       
        
        /**************************************************** Start : Multiple Face Records ************************************************/

        if(!mapAccountRelatedListFacePhoto.isEmpty()){
                for(Id accIds : mapAccountRelatedListFacePhoto.keySet()){
                   List<Content__c> lstContentFaceRecords = mapAccountRelatedListFacePhoto.get(accIds); 
                   System.debug('Multiple face Record Size in case creation:'+lstContentFaceRecords.size());
                    
                   if(lstContentFaceRecords.size() >= 3){
                       Content__c cnt = lstContentFaceRecords.get(2);
                       contentIds.add(cnt.Id);
                   }
                   else if(lstContentFaceRecords.size() == 2){
                       Content__c cnt = lstContentFaceRecords.get(1);
                       contentIds.add(cnt.Id);
                   }
                   else if(lstContentFaceRecords.size() == 1){
                       Content__c cnt = lstContentFaceRecords.get(0);
                       contentIds.add(cnt.Id);
                   }
                } //for loop Ends
          } //If Ends
        
        /**************************************************** END : Multiple Face Records ************************************************/

        /**************************************************** Start : Multiple Front Records **********************************************/
 
         if(!mapAccountRelatedListFrontPhoto.isEmpty()){
                for(Id accIds : mapAccountRelatedListFrontPhoto.keySet()){
                    List<Content__c> lstContentFrontRecords = mapAccountRelatedListFrontPhoto.get(accIds); 
                    if(lstContentFrontRecords.size() > 0){
                        Content__c cnt = lstContentFrontRecords.get(lstContentFrontRecords.size() - 1);
                        contentIds.add(cnt.Id);
                    }
                } //for loop Ends
         } //If Ends
        
       /**************************************************** END : Multiple Front Records **********************************************/

      
        System.debug('Contents Ids Size in Child Batch:'+contentIds.size());
        System.debug('Contents Ids details in Child Batch:'+contentIds);
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        query = 'Select id,Person__c,Validity__c from Content__c where id IN : contentIds';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Content__c> lstContent)
    {
        List<Content__c> cntList = new List<Content__c>();
        if(lstContent.size() > 0){
            for(Content__c cnt : lstContent){
                cnt.Validity__c = true;
                cntList.add(cnt);
            }
        }
        if(cntList.size() > 0)
            update cntList;
    }
    public void finish(Database.BatchableContext BC) {
    }

}