/**
 *Schedulable class for the batch responsable of checking alert status using api Get Compliance Case Status API ( Job should be triggered every 1 hour) 
 *@author	ANISS MBARKI
 *@creation	08/12/2021
 */
global class SC001_CheckSupplementaryCardCases implements Schedulable{

    global void execute(SchedulableContext sc) { 
        Database.executebatch(new APB001_CheckSupplementaryCardCases(),200);
    }
}