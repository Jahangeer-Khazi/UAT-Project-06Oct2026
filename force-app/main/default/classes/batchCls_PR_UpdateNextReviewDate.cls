global class batchCls_PR_UpdateNextReviewDate implements Database.Batchable<sObject>
{
    //where Id = \'a0O1j000002s3cxEAA\'
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Account.Bank_Account_Opening_Date__c, Due_Diligence_Category__c, Account.pr_NextReviewDate__c, Archived__c, Onboarding_Stage__c FROM Contact where Onboarding_Stage__c=\'ACCOUNT_ACTIVATED\' AND Archived__c=FALSE AND Account.Bank_Account_Opening_Date__c != null AND Account.pr_NextReviewDate__c = null';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Contact> lstContact = (List<Contact>)scope;
        List<Account> newLstAccount = new List<Account>();
        for(Contact objCon:lstContact)
        {
            if(objCon.Due_Diligence_Category__c == 'Standard Due Diligence')
                objCon.Account.pr_NextReviewDate__c = (objCon.Account.Bank_Account_Opening_Date__c).date().addDays(1095);   
            if(objCon.Due_Diligence_Category__c == 'Enhanced Due Diligence')
                objCon.Account.pr_NextReviewDate__c = (objCon.Account.Bank_Account_Opening_Date__c).date().addDays(365);      
            newLstAccount.add(objCon.Account);
        }
        
        if( newLstAccount.size()>0)
             update newLstAccount; 
    }
    public void finish(Database.BatchableContext BC) {
    }
}