/**
 * @description       : Used to randomize and generate winners for a Draw__c raffle
 * @author            : Jose Caballero
 * @group             : 
 * @last modified on  : 27/10/2021
 * @last modified by  : Jose Caballero
 * 
**/

global class ShuffleDraw {
    
    @InvocableMethod
    public static void shuffleDrawEntries(List<Id> drawIds){
        // RaffleRandomization.splitDrawEntries(drawIds[0]);
        SplitDrawEntriesBatch sde = new SplitDrawEntriesBatch(drawIds[0]); 
        database.executeBatch(sde); 
    }

}