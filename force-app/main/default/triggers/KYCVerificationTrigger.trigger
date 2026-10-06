/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 27-10-2025
* 		Change History: 
*	     
*/
trigger KYCVerificationTrigger on KYC_Verification__c (Before insert,Before update,after insert, after update) {
    if(Trigger.isInsert){
         if(Trigger.isBefore){
           KYCVerificationHandler.handlerBeforeKYCCreation(Trigger.new); 
        }
        if(Trigger.isAfter){
           KYCVerificationHandler.handlerAfterKYCCreation(Trigger.new); 
        }
        
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
          KYCVerificationHandler.handlerBeforeKYCUpdate(Trigger.new); 
        }
        if(Trigger.isAfter){
         KYCVerificationHandler.handlerAfterKYCUpdate(Trigger.new);
        }
    }

}