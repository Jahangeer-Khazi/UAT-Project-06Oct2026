/**
 * @description       : This is the batch class responsable of :
 *                      Al Kanz updates staff relatives’ email to be sent automatically on 1st November and 1st May of every year.
 * @author            : ANISS MBARKI
 * @creation date     : 15-07-2022
 * History Changes :  
 * #CH01 : Aniss Mbarki NBA-9970 PLA - Relatives Declaration - CRM Changes 
**/
global without sharing class APB07_StaffPeriodicRemider implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {//#CH01 : remove region fla restriction 
        return Database.getQueryLocator('SELECT Id,Staff_Corporate_Email__pc,PersonContactId,Region_Flag__pc FROM Account WHERE (Segment__pc = \'Staff\') '+
                'AND Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND Archived__pc = false' );
    }

    global void execute(Database.BatchableContext bc, List<Account> accList) {
        System.debug('execute**********************');

        for(Account objAcc : accList){
            if( objAcc.Staff_Corporate_Email__pc != null && objAcc.Staff_Corporate_Email__pc != '' ){
                Map<String, Object> Params = new Map<String, Object>();
                Params.put('recordId',objAcc.PersonContactId);
                
                //#CH01 :Start
                String emailAlertName;
                if(objAcc.Region_Flag__pc == 'Jordan'){
                    emailAlertName = 'PLA_JO_StaffPeriodicReminderEmail';
                }else {
                    emailAlertName = 'PLA_StaffPeriodicReminderEmail';
                }
                //#CH01 :End
                
                Params.put('emailAlertName',emailAlertName);
                //create instance of Interview
                Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
                //Invoke start method
                stage.start();
            }
            
        }

    }

    global void finish(Database.BatchableContext bc) {
        System.debug('APB07_StaffPeriodicRemider finished !');
    }
}