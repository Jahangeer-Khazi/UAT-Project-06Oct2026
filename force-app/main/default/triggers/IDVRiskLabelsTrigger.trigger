/**
 * @author Imane Tsioucha
 * @date 18/05/2023
 */
trigger IDVRiskLabelsTrigger on IDV_RiskLabels__c (before insert,after update) {

    //AFTER INSERT
    if(Trigger.isInsert && Trigger.isBefore){
        IDVRiskLabelsTriggerHandler.fetchAccountWhenIDVinserted(Trigger.new);
    }

    
}