/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-12-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewSMSAutomatic {
@InvocableMethod(label='sendSMSReminderJOPeriodicReviewCaseCreation' description='API Call for SMS Reminders After Case Creation' callout=true)
       
  //////////////////////////////////////////////////// Start: Logic for Automatic Jordan Case Creation ID Expired & ID Not Expired ////////////////////////////////////////////////////////////////////////////////////////////
 
    public static void sendSMSReminderPeriodicReview (List<Id> caseIds){
       Set<Id> setCaseIds = new Set<Id>(caseIds);
        if(setCaseIds.size() > 0){
            if(Limits.getQueueableJobs() == 1){  
                String hour = String.valueOf(Datetime.now().hour());
                //adding 2 minutes from current time to avoid too many Queuable jobs Exception
                String min = String.valueOf(Datetime.now().addMinutes(2).minute());
                String ss = String.valueOf(Datetime.now().second());
                String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                
                JordanPeriodicReviewSMSSchedulable smsSchedule = new JordanPeriodicReviewSMSSchedulable(setCaseIds);
                System.schedule('Jordan Periodic Review SMS Schedulable',nextFireTime,smsSchedule);
            }
            else if(Limits.getQueueableJobs() < 1){
                JordanPeriodicReviewQueuableSMSAutomatic sendSMS = new JordanPeriodicReviewQueuableSMSAutomatic(setCaseIds);
                System.enqueueJob(sendSMS);
            }
        }
   }
   //////////////////////////////////////////////////// END: Logic for Automatic Jordan Case Creation ID Expired & ID Not Expired ////////////////////////////////////////////////////////////////////////////////////////////

}