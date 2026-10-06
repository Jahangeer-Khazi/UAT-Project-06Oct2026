/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 05-10-2025
* 		Change History: 
*	     
*/
global class KYCVerificationBatchCreation implements Database.Batchable<sObject>, Database.Stateful{
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = '';
        List<String> AcctIds = System.Label.Account_ID_S_KYC_VERIF_BATCH.split(',');
        /*SELECT Id,(Select id,Account_Name__c from KYC_Verifications__r WHERE Status__c != 'Closed' ), Name,Segment__pc,VVIP__pc,
            Passport_Expiry_Date__pc,Residency_Permit_Expiry__pc,On_boarding_type__pc,Onboarding_Stage__pc,Region_Flag__pc,CustomerStatus__c,
            pr_NextReviewDate__c from Account where Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Region_Flag__pc = 'Bahrain' AND 
            Blacklisted__c != true AND CustomerStatus__c = 'Active' AND pr_NextReviewDate__c <= TODAY*/
        
       /////////////////////////////////////////////////////// Query is used for Pilot Testing ////////////////////////////////////////
        if(System.Label.ACCT_RELATED_KYC_VERIF_ENABLE_TESTING.equalsIgnoreCase('true')){
             query = System.Label.ACCT_RELATED_KYC_VERIF_BATCH_SOQL + ' '+ 'AND Id IN : AcctIds';
		}
       /////////////////////////////////////////////////////// Query is used for Pilot Testing  ////////////////////////////////////////
              
       /////////////////////////////////////////////////////// Actual Query which runs based on Next Review Date ////////////////////////////////////////
       if(System.Label.ACCT_RELATED_KYC_VERIF_ENABLE_PROD.equalsIgnoreCase('true')){
             query = System.Label.ACCT_RELATED_KYC_VERIF_BATCH_SOQL;
		}
       /////////////////////////////////////////////////////// Actual Query which runs based on Next Review Date ////////////////////////////////////////

        system.debug('Query******'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList){
        Id periodicReviewId = Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId();
		List<KYC_Verification__c> lstKycVerification = new List<KYC_Verification__c>();
        List<System_Action__c> lstAction = new List<System_Action__c>();
        System.debug('Account List:'+accList);
        if(accList.size()>0){
            for(Account acc: accList){
                try{
                    if(acc.KYC_Verifications__r.size() == 0){
                        KYC_Verification__c kycVer = new KYC_Verification__c();
                        kycVer.Account_Name__c = acc.Id;
                        kycVer.Subject__c = 'Automatic KYC Verification Case for Periodic Review';
                        kycVer.Type__c = 'KYC_PERIODIC_REVIEW';
                        kycVer.Sub_Type__c = 'Default Configurations';
                        kycVer.Case_Origin__c = 'CRM';
                        kycVer.Case_Nature__c = 'Account Maintenance';
                        kycVer.Case_Model__c = 'ila';
                        kycVer.Trigger_Type__c = 'Automatically';
                        kycVer.RecordTypeId = periodicReviewId;
                        Date caseCreationDate = Date.today(); 
                        String formattedDate = DateTime.newInstance(caseCreationDate, Time.newInstance(0, 0, 0, 0)).format('dd-MM-yyyy');
                        kycVer.Description__c = 'Periodic Review due by' + ' ' + '{' + formattedDate + '}';
                        lstKycVerification.add(kycVer);
                    }
                    else if(acc.KYC_Verifications__r.size() > 0){
                        System_Action__c action = new System_Action__c();
                        action.Account__c = acc.Id;
                        action.Account_Number__c = acc.CIF__pc;
                        action.Type__c = 'KYC Verification';
                        action.Action__c = 'Periodic Review';
                        action.Origin__c = 'CRM';
                        action.Response_Body__c = 'Periodic Review case is already existing for this customer';
                        lstAction.add(action);
                    } 
                }catch(Exception ex){
                    System_Action__c errorAction = new System_Action__c();
                    errorAction.Account__c = acc.Id;
                    errorAction.Account_Number__c = acc.CIF__pc;
                    errorAction.Type__c = 'KYC Verification';
                    errorAction.Action__c = 'Periodic Review';
                    errorAction.Origin__c = 'CRM';
                    errorAction.Response_Body__c = 'Error while processing account ' + acc.Id + ': ' + ex.getMessage();
                    lstAction.add(errorAction);
                }
                
          }//for loop Ends
        } //If Ends
        
        // Insert new KYC verification records with error handling
        if(!lstKycVerification.isEmpty()) {
            Database.SaveResult[] kycResults = Database.insert(lstKycVerification, false);
            for(Integer i = 0; i < kycResults.size(); i++) {
                if (!kycResults[i].isSuccess()) {
                    for (Database.Error err : kycResults[i].getErrors()) {
                        System_Action__c errorAction = new System_Action__c();
                        errorAction.Account__c = lstKycVerification[i].Account_Name__c;
                        errorAction.Account_Number__c = lstKycVerification[i].CIF__c;
                        errorAction.Type__c = 'KYC Verification';
                        errorAction.Action__c = 'Periodic Review';
                        errorAction.Origin__c = 'CRM';
                        errorAction.Response_Body__c = 'Error inserting KYC record: ' + err.getMessage();
                        lstAction.add(errorAction);
                    }
                }
            }
        }
        if(!lstAction.isEmpty()){
            try{
                insert lstAction;
            }catch(Exception ex){
                System.debug('Error inserting System_Action__c logs: ' + ex.getMessage());
            }
            
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}