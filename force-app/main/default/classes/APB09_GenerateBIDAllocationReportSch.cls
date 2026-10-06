global class APB09_GenerateBIDAllocationReportSch  implements Schedulable {
   // Execute at regular intervals
    global void execute(SchedulableContext ctx){
      APB09_GenerateBIDAllocationReport batch = new APB09_GenerateBIDAllocationReport(True,'Automatic');
      Database.executebatch(batch, 200);
    }
}