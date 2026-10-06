/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 11-01-2024
*       Change History: 
*                   
*/
global class InvQuestionnaireConsentStatusUpdate implements Database.Batchable<sObject>,Database.Stateful, Schedulable{
    
    global void execute(SchedulableContext SC) { 
        database.executeBatch(new InvQuestionnaireConsentStatusUpdate(),200);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        query = 'Select id,CreatedDate,Customer__c,Latest_Questionnaire__c,Submitted_On__c from Bonds_Sukuk_Questionnaire__c Where Latest_Questionnaire__c = TRUE';
        System.debug('SOQL Query:'+query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Bonds_Sukuk_Questionnaire__c> invQuestionnaireList) {
        System.debug('Investment Questionnaire List Size:'+invQuestionnaireList.size());
        System.debug('Investment Questionnaire List :'+invQuestionnaireList);
        List<Account> accListToUpdate = new List<Account>();
        if(invQuestionnaireList.size()>0){
            for(Bonds_Sukuk_Questionnaire__c bonds : invQuestionnaireList){
                //DateTime dt = bonds.Submitted_On__c; //Converting date/time to date
                DateTime dt = bonds.CreatedDate;
                Date d = dt.date();
                Integer noOfDaysRemaining = d.daysBetween(System.today());
                System.debug('Number of Days between Bond Created date and today:'+noOfDaysRemaining);
                // QUESTIONNAIRE_VALIDITY is 365 Days
                if(noOfDaysRemaining > Integer.valueOf(System.Label.QUESTIONNAIRE_VALIDITY)){
                    Account acc = new Account(Id = bonds.Customer__c);
                    acc.Bonds_Sukuk_Consent_Status__pc = 'EXPIRED';
                    accListToUpdate.add(acc);
                }
            }//for Ends
        }//If Ends
        if(!accListToUpdate.isEmpty()){
            System.debug('Acc List to update:'+accListToUpdate);
            update accListToUpdate;
        }
    }
    global void finish(Database.BatchableContext bc) {
        System.debug('!!!!!!!!!!!!!!! Investment Questionnaire Batch finished !!!!!!!!!!!!!!!!!');
    }

}