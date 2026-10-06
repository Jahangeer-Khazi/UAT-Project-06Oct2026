public class PremiumInvitationController {
    @AuraEnabled
    public static Id getPremiumInvitationRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Invitation').getRecordTypeId();
    }
    
     @AuraEnabled
    public static String getCustomerName(Id accId) {
        Account accreocrd= [SELECT Id,name,FirstName,LastName FROM Account WHERE Id=:accId];
        return accreocrd.FirstName +' '+accreocrd.LastName;
    }
    

}