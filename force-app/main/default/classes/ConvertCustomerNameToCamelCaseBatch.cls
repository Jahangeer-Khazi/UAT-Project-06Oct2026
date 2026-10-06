/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date:15-03-2023
* 		Change History: 
* 	 							  
*/
global class ConvertCustomerNameToCamelCaseBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id,Onboarding_Stage__pc,Ila_Customer_Name__c,mkt_Customer_Name_Camel_Case__pc from Account where Onboarding_Stage__pc = \'ACCOUNT_ACTIVATED\' AND mkt_Customer_Name_Camel_Case__pc = null ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        System.debug('Account List size:'+accList.size());
        System.debug('Account Detail:'+accList);
        for(Account a : accList){
            System.debug('Account Ids :'+a.Id);
            System.debug('Ila Customer Name:'+a.Ila_Customer_Name__c);
            a.mkt_Customer_Name_Camel_Case__pc = ConvertCustomerNameToCamelCase.convert(a.Ila_Customer_Name__c);
        }
        try{
            update accList;
        }catch(Exception e){
            System.debug(e);
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
    
}