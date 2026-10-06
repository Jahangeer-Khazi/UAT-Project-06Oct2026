/**
 *Schedulable class ( Job should be triggered 1st November and 1st May of every year) 
        --PLA - CRM - Staff Relatives - Periodic Email Reminder to be Sent to Staff to Update Relatives - CR
 *@author	ANISS MBARKI
 *@creation	15-07-2022
 */
global class SC07_StaffPeriodicRemider implements Schedulable{

    global void execute(SchedulableContext sc) { 
        Database.executebatch(new APB07_StaffPeriodicRemider(),200);
    }
}