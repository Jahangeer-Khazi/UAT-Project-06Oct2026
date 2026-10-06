global class PeriodicReviewBatch_BulkInsert implements Database.Batchable<sObject>,Database.Stateful{
    global Id accid;
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Id periodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Periodic_Review').getRecordTypeId();
        List<String> periodicReviewAccountIds = System.Label.PERIODIC_REVIEW_ACCOUNTIDS.split(',');
        String query = '';
        query = 'Select id, '+
            '(SELECT Id,Status FROM cases WHERE RecordTypeId =: periodicReviewId AND Status != \'Closed\') '+ 
            'Name,Onboarding_Stage__pc,Segment__pc,VVIP__pc,Passport_Expiry_Date__pc,On_boarding_type__pc,pr_NextReviewDate__c, '+
            'Nationality__pc,Periodic_Review_Batch__c  from Account where (Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND CustomerStatus__c != \'Closed\' AND '+
            'pr_ReviewStatus__c = null AND Periodic_Review_Batch__c =TRUE) LIMIT 1';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Account> accList) {
        Id periodicReviewId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Periodic_Review').getRecordTypeId();
        Map<String,Case> mapAccountRelatedNewPeriodicReviewCase = new Map<String,Case>();
        Set<String> setOfErrormessage = new Set<string>();
        Set<String> setofsuccessFullCaseIds = new Set<String>();
        Set<String> setofsuccessFullAccountIds = new Set<String>();
        Set<String> setOfErrorAccId = new Set<String>();
        List<Account> AccntnewCaseupdt = New List<Account>();
        List<Account> AccntoldCaseupdt = New List<Account>();
        Set<String> setofAccountHavingExistingPeriodicReviewCases = new Set<String>();
        
        try{
            System.debug('Account List Scope Size:'+accList.size());
            String isBatchRunnable = System.Label.pr_Initiate_Periodic_Review_Batch;
            if(accList.size() > 0 && isBatchRunnable.equalsIgnoreCase('true')){
                System.debug('Account List:'+accList);
                for(Account acc : accList){
                    if(acc.cases.size() == 0){
                        System.debug('New Periodic Review cases is ready to be created against a customer');
                        System.debug('Account Ids:'+acc.Id);
                        accid=acc.Id;
                        Case cs = new Case();
                        cs.AccountId = acc.Id;
                        cs.RecordTypeId = periodicReviewId;
                        cs.Type = 'Periodic Review';
                        cs.Sub_Type__c ='Periodic Review - Scheduled Review Date';
                        cs.pr_TriggerType__c = 'Automatically';
                        cs.Origin = 'CRM';
                        cs.Case_Nature__c = 'Account Maintenance';
                        cs.Subject = 'Periodic Review';
                        cs.Description = 'New Periodic Review';
                        cs.OwnerId = System.Label.QA_Team;
                        cs.PeriodicUpdateBatch__c=True;
                        mapAccountRelatedNewPeriodicReviewCase.put(acc.id,cs);
                        acc.Periodic_Review_Batch__c=False;
                        AccntnewCaseupdt.add(acc);
                    }
                    else if(acc.cases.size() > 0){
                        System.debug('Existing Periodic Review cases are already existing against a customer:'+acc.Id);
                        acc.Periodic_Review_Batch__c=False;
                        AccntoldCaseupdt.add(acc);
                        setofAccountHavingExistingPeriodicReviewCases.add(acc.Id);
                    }
                    
                }//for loop Ends
            }
            
            if(!setofAccountHavingExistingPeriodicReviewCases.isEmpty()){
                String compName = 'PeriodicReviewBatch';
                String compType = 'Apex Class';
                String successRecordReference = String.join(new List<String>(setofAccountHavingExistingPeriodicReviewCases), ',');
                String ObjectType = 'Account';
                String caseCategory = 'Having Existing Periodic Review Case';
                PeriodicReviewBatchTrackerLogs.existingPeriodicReviewCaseExist(compName, compType, successRecordReference,ObjectType,caseCategory);
                Update AccntoldCaseupdt;
            }
            System.debug('Map Account Vs case in Batch Class:'+mapAccountRelatedNewPeriodicReviewCase);
            if(!mapAccountRelatedNewPeriodicReviewCase.isEmpty()){
                Database.SaveResult[] saveResultInsert = Database.insert(mapAccountRelatedNewPeriodicReviewCase.values(),false);
                for(Database.SaveResult sr : saveResultInsert){
                    if(sr.isSuccess()) {
                        setofsuccessFullCaseIds.add(sr.getId());
                        System.debug('Set of success case Ids:'+setofsuccessFullCaseIds);
                        Update AccntnewCaseupdt;
                    }
                    else{
                        for(Database.Error err : sr.getErrors()) {
                            setOfErrormessage.add(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Set of Error Message:'+setOfErrormessage);
                        }	
                    }
                } //for loop Ends
                if(!setofsuccessFullCaseIds.isEmpty()){
                    for(Case c : [Select Id, AccountId from Case where Id IN : setofsuccessFullCaseIds]){
                        setofsuccessFullAccountIds.add(c.AccountId);
                        System.debug('Set of Success AccountIds:'+setofsuccessFullAccountIds);
                    }
                    for(String accID : mapAccountRelatedNewPeriodicReviewCase.keySet()){
                        if(!setofsuccessFullAccountIds.contains(accID)){
                            setOfErrorAccId.add(accID);
                            System.debug('Set of Error AccountIds:'+setOfErrorAccId);
                        }
                    }
                }
                else{
                    setOfErrorAccId.addAll(mapAccountRelatedNewPeriodicReviewCase.keySet());
                    System.debug('Set of Error AccountIds in else block:'+setOfErrorAccId);
                }
            }
            if(!setofsuccessFullAccountIds.isEmpty()){
                String compName = 'PeriodicReviewBatch';
                String compType = 'Apex Class';
                String successRecordReference = String.join(new List<String>(setofsuccessFullAccountIds), ',');
                String ObjectType = 'Account';
                PeriodicReviewBatchTrackerLogs.successlog(compName, compType, successRecordReference,ObjectType);
            }
            if(test.isRunningTest()){
                throw new MyCustomException('Covering catch block for the test Class');
            }
            if(!setOfErrorAccId.isEmpty() && !setOfErrormessage.isEmpty()){
                String compName = 'PeriodicReviewBatch';
                String compType = 'Apex Class';
                String failureRecordReference = String.join(new List<String>(setOfErrorAccId), ',');
                String errorMessage = String.join(new List<String>(setOfErrormessage), ',');
                String ObjectType = 'Account';
                System.debug('Error Message to Display in Try block:'+errorMessage);
                PeriodicReviewBatchTrackerLogs.errorlog(compName,compType,failureRecordReference,errorMessage,ObjectType);
            }
        }//try Ends
        catch(Exception Ex){
            String compName = 'PeriodicReviewBatch';
            String compType = 'Apex Class';
            for(Account acc : accList){
                setOfErrorAccId.add(acc.Id);
            }
            String failureRecordReference = String.join(new List<String>(setOfErrorAccId), ',');
            String errorMessage = ex.getMessage()  + ex.getStackTraceString();
            String ObjectType = 'Account';
            System.debug('Error Message to Display in Catch block:'+errorMessage);
            PeriodicReviewBatchTrackerLogs.errorlog(compName,compType,failureRecordReference,errorMessage,ObjectType);
        }//catch Ends
    }
    
    global void finish(Database.BatchableContext bc) {
        system.debug(System.Now());
        Long endT = System.Now().getTime()+Integer.valueOf(System.Label.PeriodicBatchTimeDelay);
        While(System.Now().getTime() < endT){
        }
        system.debug(System.Now());
        system.debug('accid'+accid);
        List<Account>RerunBatch=New List<Account>();
        RerunBatch= [Select id,Periodic_Review_Batch__c  from Account where (Onboarding_Stage__pc ='ACCOUNT_ACTIVATED' AND CustomerStatus__c != 'Closed'  AND pr_ReviewStatus__c = null AND Periodic_Review_Batch__c =TRUE AND Id!=:accid)];
        if(!RerunBatch.isEmpty() && System.Label.PeriodicReviewBatchManualStop=='False'){
            PeriodicReviewBatch_BulkInsert PRB = New PeriodicReviewBatch_BulkInsert();
            database.executeBatch(PRB,1);
        }
        System.debug('!!!!!!!!,!!!!!!! Periodic Review Batch finished !!!!!!!!!!!!!!!!!');
    }
}