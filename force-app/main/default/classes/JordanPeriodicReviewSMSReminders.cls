/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 20-11-2023
*       Change History: 
*                   
*/
public class JordanPeriodicReviewSMSReminders {
     
    @InvocableMethod(label='sendSMSReminderJOPeriodicReview' description='API Call for SMS Reminders After Case Creation Plus 7 Days' callout=true)
    
   //////////////////////////////////////////////////// Start: Logic for First Reminder, Second Reminder, Third Reminder & Customer Block ////////////////////////////////////////////////////////////////////////////////////////////

    public static void sendSMSReminderPeriodicReview (List<Id> caseIds){
       JordanPeriodicReviewQueuableSMSReminders sendSMS = new JordanPeriodicReviewQueuableSMSReminders(new Set<Id>(caseIds));
       System.enqueueJob(sendSMS);
    }
    
   //////////////////////////////////////////////////// END: Logic for First Reminder, Second Reminder, Third Reminder & Customer Block ////////////////////////////////////////////////////////////////////////////////////////////

}