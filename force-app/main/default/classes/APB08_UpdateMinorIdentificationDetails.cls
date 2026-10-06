/*    Organization:ABC Bank
 *      Created By:Jayanth Manickam
 *      Created Date:09-02-2022
 *      Change History: 
 *            
*/

global class APB08_UpdateMinorIdentificationDetails implements Database.Batchable<SObject>, Schedulable  {
    
    global void execute(SchedulableContext SC) { 
        database.executeBatch(new APB08_UpdateMinorIdentificationDetails());
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'SELECT Id,Minor__pc,Guardian_CIF__pc,Guardian_CPR__pc FROM Account where Minor__pc=True and age__pc>=18 AND CIF__Pc IN (\'5545093\',\'5545094\',\'5545095\',\'5545096\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> accList) {
        
        // process each batch of records default size is 200
        for(Account acc : accList) {        
            // Update the Account Name 
            acc.Minor__pc =false;
            acc.Guardian_CIF__pc='';
            acc.Guardian_CPR__pc='';
        }
        try {
            // Update the Account Record
            //Database.update(accList,true);
            Update accList;
            
        } catch(Exception e) {
            System.debug(e);
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}