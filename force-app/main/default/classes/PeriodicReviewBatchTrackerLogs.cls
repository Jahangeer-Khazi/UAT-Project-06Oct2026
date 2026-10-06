/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 26-11-2022
* 		Change History: 
*	     
*/
global class PeriodicReviewBatchTrackerLogs {
	global static void successlog(String compName,String compType,String sucessRecordReference,String objType){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Success_Account_Records__c = sucessRecordReference;
        periodicRev.Object_Type__c = objType;
        insert periodicRev;
    }
    global static void errorlog(String compName,String compType,String failureErrorRecordReference,String errMessage,String objType){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Failure_Account_Records__c = failureErrorRecordReference;
        periodicRev.Error_Message__c = errMessage;
        periodicRev.Object_Type__c = objType;
		insert periodicRev;
    }
    global static void existingPeriodicReviewCaseExist(String compName,String compType,String sucessRecordReference,String objType,String Category){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Success_Account_Records__c = sucessRecordReference;
        periodicRev.Object_Type__c = objType;
        periodicRev.Case_Category__c = Category;
        insert periodicRev;
    }
    global static void successCaselog(String compName,String compType,String sucessRecordReference,String objType){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Success_Case_Records__c = sucessRecordReference;
        periodicRev.Object_Type__c = objType;
        insert periodicRev;
    }
    global static void errorCaselog(String compName,String compType,String failureErrorRecordReference,String errMessage,String objType){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Failure_Case_Records__c = failureErrorRecordReference;
        periodicRev.Error_Message__c = errMessage;
        periodicRev.Object_Type__c = objType;
		insert periodicRev;
    }
     global static void successCaselogWithUpdatedDocHash(String compName,String compType,String sucessRecordReference,String objType,Boolean b){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Success_Case_Records__c = sucessRecordReference;
        periodicRev.Object_Type__c = objType;
        periodicRev.IDandV_Document_Hash_Updated__c = b;
        insert periodicRev;
    }
     global static void successCaselogWithCategory(String compName,String compType,String sucessRecordReference,String objType,String Category){
        Periodic_Review_Batch_Tracker__c periodicRev = new Periodic_Review_Batch_Tracker__c();
        periodicRev.Component_Name__c = compName;
        periodicRev.Component_Type__c = compType;
        periodicRev.Success_Case_Records__c = sucessRecordReference;
        periodicRev.Object_Type__c = objType;
        periodicRev.Case_Category__c = Category;
        insert periodicRev;
    }

}