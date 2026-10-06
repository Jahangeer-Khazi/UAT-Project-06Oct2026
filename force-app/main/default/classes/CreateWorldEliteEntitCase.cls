public class CreateWorldEliteEntitCase {
    public static World_Elite_Entitlement__c createWorldEntitlementCase(Account acc, Case cse){
        Id worldEliteRecordTypeId = Schema.SObjectType.World_Elite_Entitlement__c.getRecordTypeInfosByDeveloperName().get('World_Elite_Entitlement').getRecordTypeId();
        World_Elite_Entitlement__c wtt = new World_Elite_Entitlement__c();
        wtt.Contact_Name__c = acc.Id;
        wtt.Case__c = cse.Id;
        wtt.Type__c = 'World Elite Benefits';
        wtt.Sub_Type__c = 'Update Membership No';
        wtt.RecordTypeId = worldEliteRecordTypeId;
        wtt.Case_Origin__c = 'CRM';
        wtt.Case_Nature__c = 'FCR';
        return wtt;
    }
    @AuraEnabled
    public static void clearMembershipNumber(Id accountId){
        System.debug('Account Id:'+accountId);
        if(accountId == null){
            throw new AuraHandledException('Account Id is required');
        }
        Account acc = new Account(Id = accountId,World_Elite_Benefit_Membership_No__pc = false);
        update acc;
    }

}