global class Schedule_BatchCls_eKYCaseClosure implements schedulable{
    global void execute(SchedulableContext sc){
        batchCls_eKYCCasesClosure myBatch = new batchCls_eKYCCasesClosure();
        Database.executeBatch(myBatch,50);
    }
}