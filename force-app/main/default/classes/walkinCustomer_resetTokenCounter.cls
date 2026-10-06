public class walkinCustomer_resetTokenCounter implements Schedulable {
    public void execute(SchedulableContext ctx) {
        List< Customer_TokenCounter__c > lstToken = [SELECT Id, Name, OwnerId, Today_s_Date__c, Counter__c FROM Customer_TokenCounter__c LIMIT 1];
        if(lstToken.size()>0){
            lstToken[0].Counter__c = 1;
            lstToken[0].Today_s_Date__c = system.Today();
            update lstToken[0];
        }
    }
}