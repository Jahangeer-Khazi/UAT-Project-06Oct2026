public class PrizeoutController {
    @AuraEnabled
    public static Id getPremiumInvitationRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Prizeout').getRecordTypeId();
    }
}