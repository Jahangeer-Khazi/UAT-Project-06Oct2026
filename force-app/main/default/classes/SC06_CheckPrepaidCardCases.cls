/**
 *Schedulable class for the batch responsable of checking alert status using api Get Compliance Case Status API ( Job should be triggered every 1 hour) --Prepaid Card
 *@author	ANISS MBARKI
 *@creation	04-07-2022
 */
global class SC06_CheckPrepaidCardCases implements Schedulable{

    global void execute(SchedulableContext sc) { 
        Database.executebatch(new APB06_CheckPrepaidCardCases(),200);
    }
}