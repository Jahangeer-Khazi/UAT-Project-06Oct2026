trigger ContentTrigger on Content__c (before delete) {

    if (Trigger.isBefore && Trigger.isDelete) {
        String currentUserProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        for (Content__c content : Trigger.old) {
            if (content.Scan_Type__c != 'Loan Application' || currentUserProfileName == 'System Administrator' || currentUserProfileName.containsIgnoreCase('integration') ) {
                continue; 
            }
            if (content.CreatedById != UserInfo.getUserId()) {
                content.addError('You can only delete records that you have created.');
            }
        }
    }
}