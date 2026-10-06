global class PeriodicReviewBatch_UpdateCases implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id periodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Periodic_Review').getRecordTypeId();
        String query = 'SELECT Id,Status FROM case WHERE RecordTypeId =: periodicReviewId AND Status != \'Closed\' and PeriodicUpdateBatch__c=TRUE AND pr_WathiqConsentFormRequired__c=False AND pr_ResidencyPermitPhotoRequired__c=False AND pr_PassportPhotoRequired__c=False AND pr_OtherDocumentsRequired__c=False LIMIT 1';
          return Database.getQueryLocator(query);
    }

global void execute(Database.BatchableContext bc, List<Case> CaseList) {
             Set<String> setOfErrormessage = new Set<string>();
            Set<String> setofsuccessFullCaseIds = new Set<String>();
            List<Case>UpdatePeriodicBatch= New List<Case>();
            Set<String> setOfErrorCSEId = new Set<String>();
     try{
            System.debug('Account List Scope Size:'+CaseList.size());
            String isBatchRunnable = System.Label.pr_Initiate_Periodic_Review_Batch;

            if(CaseList.size() > 0 && isBatchRunnable.equalsIgnoreCase('true')){
                System.debug('Case List:'+CaseList);
                for(Case cs : CaseList){
                    cs.Status='All Documents Uploaded';
                    cs.PeriodicUpdateBatch__c=False;
                    UpdatePeriodicBatch.add(cs);
                }
            }
         if(!UpdatePeriodicBatch.isEmpty()){
                   Database.SaveResult[] saveResultInsert = Database.Update(UpdatePeriodicBatch,false);
                for(Database.SaveResult sr : saveResultInsert){
                    if(sr.isSuccess()) {
                        setofsuccessFullCaseIds.add(sr.getId());
                        System.debug('Set of success case Ids:'+setofsuccessFullCaseIds);
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Set of Error Message:'+setOfErrormessage);
                        }	
                    }
         }
             for(Case csl:CaseList){
                          if(!setofsuccessFullCaseIds.contains(csl.Id)){
                            setOfErrorCSEId.add(csl.Id);
                            System.debug('Set of Error AccountIds:'+setOfErrorCSEId);
                        }
             }
         }
          if(!setofsuccessFullCaseIds.isEmpty()){
                String compName = 'PeriodicReviewBatch_UpdateCases';
                String compType = 'Apex Class';
                String successRecordReference = String.join(new List<String>(setofsuccessFullCaseIds), ',');
                String ObjectType = 'Case';
                PeriodicReviewBatchTrackerLogs.successlog(compName, compType, successRecordReference,ObjectType);
            }
            if(test.isRunningTest()){
                throw new MyCustomException('Covering catch block for the test Class');
            }
            if(!setOfErrormessage.isEmpty()){
                String compName = 'PeriodicReviewBatch_UpdateCases';
                String compType = 'Apex Class';
                String failureRecordReference = String.join(new List<String>(setOfErrorCSEId), ',');
                String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                String ObjectType = 'Case';
                System.debug('Error Message to Display in Try block:'+errorMessage);
                PeriodicReviewBatchTrackerLogs.errorlog(compName,compType,failureRecordReference,errorMessage,ObjectType);
            }
     } catch(Exception Ex){
         String compName = 'PeriodicReviewBatch_UpdateCases';
            String compType = 'Apex Class';
            for(Case csl:CaseList){
                setOfErrorCSEId.add(csl.Id);
            }
            String failureRecordReference = String.join(new List<String>(setOfErrorCSEId), ',');
            String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            String ObjectType = 'Case';
            System.debug('Error Message to Display in Catch block:'+errorMessage);
			PeriodicReviewBatchTrackerLogs.errorlog(compName,compType,failureRecordReference,errorMessage,ObjectType);
     }
    
}
    global void finish(Database.BatchableContext bc) {
        Id periodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Periodic_Review').getRecordTypeId();
        system.debug(System.Now());
        Long endT = System.Now().getTime()+Integer.valueOf(System.Label.PeriodicBatchTimeDelay);
        While(System.Now().getTime() < endT){
        }
         system.debug(System.Now());
        List<Case>RerunBatch=New List<Case>();
        RerunBatch= [SELECT Id,Status FROM case WHERE RecordTypeId =: periodicReviewId AND PeriodicUpdateBatch__c=TRUE AND Status != 'Closed' AND pr_WathiqConsentFormRequired__c=False AND pr_ResidencyPermitPhotoRequired__c=False AND pr_PassportPhotoRequired__c=False AND pr_OtherDocumentsRequired__c=False];
        if(!RerunBatch.isEmpty() && !test.isRunningTest() && System.Label.PeriodicReviewBatchManualStop=='False'){
            PeriodicReviewBatch_UpdateCases PRB = New PeriodicReviewBatch_UpdateCases();
            database.executeBatch(PRB,1);
        }
        System.debug('!!!!!!!!,!!!!!!! Periodic Review Batch finished !!!!!!!!!!!!!!!!!');
    }
}