/*      Organization   : ABC Bank
 *      Created By     : Jahangeer Mohammed
 *      Created Date   : 04/01/2024
 *      Description    : This trigger fires whenever there is a new user creation and user modification.
 *      Change History : 
 *                      
 *             
 */
trigger InvestmentQuestionnaireTrigger on Bonds_Sukuk_Questionnaire__c (before insert,after insert,before update, after update, after delete) {
    
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('Before Insert in Investment Questionnairre');
        // InvestmentQuestionnaireTriggerHandler.handlerBeforeQuestionnaireCreation(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        System.debug('After Insert in Investment Questionnairre');
        InvestmentQuestionnaireTriggerHandler.handlerAfterQuestionnaireCreation(Trigger.new);
    }
    if(Trigger.isDelete){
         System.debug('After Delete in Investment Questionnairre');
         InvestmentQuestionnaireTriggerHandler.handlerAfterQuestionnaireDeletion(Trigger.old);
    }
}