/*      Organization : ABC Bank
*      Created By: Ashish Pandey
*      Created Date: 30-10-2022
*      Description : Updated Historic Data - DocumentType
*/

global class batchCls_UpdateContentVerifictionSatus implements Database.Batchable<sObject>
{
    //where Id = \'a0O1j000002s3cxEAA\'
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Verification_Status__c, Similarity__c , Document_Hash__c, Image_Type__c, Updated__c FROM Content__c where Updated__c=TRUE AND (Image_Type__c = \'Front\' OR Image_Type__c = \'Back\' OR Image_Type__c = \'Face\') AND (Verification_Status__c=null OR Similarity__c=null) AND Customer_OB_Stage__c=\'ACCOUNT_ACTIVATED\' AND Customer_Archived_Status__c=False';
        system.debug('---> '+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        System.debug('inside execur##'+scope);
        List<Content__c> lstContent = (List<Content__c>)scope;
        List<Content__c> lstContentUpdate = new List<Content__c>();
        for(Content__c objCon:lstContent)
        {
            objCon.Verification_Status__c = 'APPROVED_VERIFIED';
            objCon.Similarity__c = 'MATCH';  
            lstContentUpdate.add(objCon);
        }
            //objCon.Updated__c = TRUE;
        System.debug('---> '+lstContentUpdate);
        if( lstContentUpdate.size()>0)
         Update lstContentUpdate; 
        //System.debug('---> '+lstContent);
    }
    public void finish(Database.BatchableContext BC) {
    }
}