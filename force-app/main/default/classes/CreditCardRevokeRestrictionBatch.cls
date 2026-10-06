global class CreditCardRevokeRestrictionBatch implements Database.Batchable<sObject>  {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> revokeAccountIds = System.Label.REVOKE_ACCOUNT_IDS.split(',');
        DateTime now = System.now();
		String currentDate = now.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        System.debug('Current Date Time:'+currentDate);
        String query = '';
        if(System.Label.REVOKE_ACCOUNT_SOQL_ENABLE_ALL.equalsIgnoreCase('true')){
            query = 'Select id,Onboarding_Stage__pc,Segment__pc,VVIP__pc,On_boarding_type__pc,Reapplying_Restriction_Period__pc,Revoke_Restriction_Date__pc, '+
			 'Nationality__pc,Reapplying_Restriction_Last_Update_Date__pc from Account where (Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND CustomerStatus__c != \'Closed\' AND '+
             'Reapplying_Restriction_Period__pc != null AND Revoke_Restriction_Date__pc != null AND Revoke_Restriction_Date__pc < ' + currentDate + ' AND Id IN : revokeAccountIds)';
        }
        if(System.Label.REVOKE_ACCOUNT_SOQL_ENABLE_TESTING.equalsIgnoreCase('true')){
          query = 'Select id,Onboarding_Stage__pc,Segment__pc,VVIP__pc,On_boarding_type__pc,Reapplying_Restriction_Period__pc,Revoke_Restriction_Date__pc, '+
			 'Nationality__pc,Reapplying_Restriction_Last_Update_Date__pc from Account where (Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND CustomerStatus__c != \'Closed\' AND '+
             'Reapplying_Restriction_Period__pc != null AND Revoke_Restriction_Date__pc != null AND Revoke_Restriction_Date__pc < ' + currentDate + ')';  
        }
        System.debug('Query in Batch:'+query);
        return Database.getQueryLocator(query);
	}
    global void execute(Database.BatchableContext bc, List<Account> accList) {
        List<Account> accListToUpdate = new List<Account>();
        System.debug('Revoke Account List Scope Size:'+accList.size());
        System.debug('Revoke Account List:'+accList);
        try{
            if(accList.size()>0){
                for(Account acc : accList){
                    if(acc.Reapplying_Restriction_Period__pc != null && acc.Revoke_Restriction_Date__pc != null){
                        acc.Reapplying_Restriction_Period__pc = '';
                        acc.Reapplying_Restriction_Last_Update_Date__pc = null;
                        acc.Revoke_Restriction_Date__pc = null;
                        accListToUpdate.add(acc);
                    }
                }//for loop Ends
            }//If Ends
            if(accListToUpdate.size()>0){
                //update accListToUpdate;
            }
        }catch(Exception ex){
            System.debug('Message in Catch Block:'+ex.getMessage());
            System.debug('Line Number in Catch Block:'+ex.getLineNumber());
        }
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('!!!!!!!!!!!!!!! CreditCard RevokeRestriction Batch finished !!!!!!!!!!!!!!!!!');
    }
}