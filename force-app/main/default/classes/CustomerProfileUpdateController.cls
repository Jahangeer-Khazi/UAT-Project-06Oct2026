public class CustomerProfileUpdateController {

    @AuraEnabled
    public static Account getAccountDetails(Id recordId){
    	return [Select Id,Name,Is_Business_Light_Customer__c,
                Is_ABCI__c,Region_Flag__pc,PersonContact.Id, CustomerStatus__c,Subscription_Model__pc
                FROM Account 
                WHERE Id =: recordId];
    }
}