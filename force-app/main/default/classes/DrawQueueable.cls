/**
 * @description       : When the raffle DrawEntries are split, the records need to be inserted. 
 * @author            : Navin Muneesamy
 * @group             : 
 * @last modified on  : 08/02/2022
 * @last modified by  : Navin Muneesamy
 * ************************************************
 * @last modified on  : 
 * @last modified by  : 
 * @description       : 
 * ************************************************
**/
public class DrawQueueable implements Queueable {
    public List<Draw_Entry__c> drawEntryList ; 
    public DrawQueueable(List<Draw_Entry__c> drawEntryList){
        this.drawEntryList = drawEntryList ;  
    }
    public void execute(QueueableContext context) {    
        integer i = 0;
        integer splitSize = 8000;
        if(system.test.isRunningTest()){
            splitSize = 2;
        }
        // Instead of sticking to a limit of 10,000 for insertion, we will use 8,000 for an allowance of 2,000 for the caller program
        if(drawEntryList.size()>splitSize){
            // Prepare the records to be inserted
            List<Draw_Entry__c> newDrawEntryInsertList = new List<Draw_Entry__c>();
            for(i=0;i<splitSize;i++){
                newDrawEntryInsertList.add(drawEntryList[i]);
            }
            insert newDrawEntryInsertList;
            
            // Prepare the records for the next queueable job
            List<Draw_Entry__c> newDrawEntryQueueList = new List<Draw_Entry__c>();
            for(i=splitSize;i<drawEntryList.size();i++){
                newDrawEntryQueueList.add(drawEntryList[i]);
            }
            if(!system.test.isRunningTest()){
            	ID jobID = System.enqueueJob(new DrawQueueable(newDrawEntryQueueList));
            }
        }
        else{
            insert drawEntryList;
        }
    }
}