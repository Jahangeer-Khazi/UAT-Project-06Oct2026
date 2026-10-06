/*
    change history:
                    - CH01: By elmustapha on 02/08/2024  // Bypass trigger for loan application record type
    
*/

trigger Cases on Case (before insert, before update, before delete, 
                                                    after insert, after update, after delete, after undelete) {
    
    // Start CH01
    if(Trigger.isInsert && (Trigger.New.size() == 1 && Trigger.New[0].RecordType_DeveloperName__c == 'Loan_Application' )){
        System.debug('Skip CaseHandler for Loan_Application');
    }
    else{
        BaseTriggerHandler.process('CaseHandler');
    }        
    // End CH01
   
}