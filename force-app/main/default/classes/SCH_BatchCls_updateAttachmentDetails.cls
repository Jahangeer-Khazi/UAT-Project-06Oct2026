global class SCH_BatchCls_updateAttachmentDetails implements schedulable{
    global void execute(SchedulableContext sc){
        batchCls_updateAttachmentDetails myBatch = new batchCls_updateAttachmentDetails();
        Database.executeBatch(myBatch,Integer.valueOf(system.Label.SCH_batchSize));
    }
}