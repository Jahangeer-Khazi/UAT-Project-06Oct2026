/**
 * @author Aniss Mbarki
 * @date Création 07/03/2022
 * @date Modification
 * @description : apex trigger used to prevent deleting Prize records realted to a draw with status different of "new" and "rework"
 */
trigger PrizeTrigger on Prize__c (before delete) {
    for(Prize__c prize : trigger.old){
        if(prize.Draw_Status__c != 'New' && prize.Draw_Status__c != 'Rework'){
            prize.adderror(System.Label.Prize_PreventDeleteMsg);
        }
    }
}