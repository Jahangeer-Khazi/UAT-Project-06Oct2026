/*      Organization   : ABC Bank
 *      Created By     : Jahangeer Mohammed
 *      Created Date   : 22/02/2022
 *      Description    : This trigger fires whenever there is a new user creation and user modification.
 *      Change History : 
 * 						#CH01# #Jahangeer Mohammed# #09-07-2023# Added a Before Update Event in a trigger
 *             
 */
trigger UserTrigger on User (after insert,before Update,after Update) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        UserTriggerHandler.sendEmailToInfosecForUserCreation(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        UserTriggerHandler.sendEmailToInfosecForUserUpdate(Trigger.newMap, Trigger.oldMap);
    }
    //CH01: Start
    if(Trigger.isUpdate && Trigger.isBefore){
        UserTriggerHandler.assignUserToTerritory(Trigger.newMap, Trigger.oldMap);
    }
    //CH01: END
}