public class Automate_BidAllocationSchedule {
    
    @InvocableMethod(label='Automate BID Allocation' description='The purpose of this service is to trigger BID Allocation' callout=true )
    public static List<String> processBidAllocation(List<String> BidISINCODE){
      //  System.enqueueJob(QB01GenerateBIDAllocationReport(False,BidISINCODE[0],BidISINCODE[0],BidISINCODE[0],'Automatic'));
        Id jobId = Database.executeBatch(new APB09_GenerateBIDAllocationReport(True,BidISINCODE[0],'Automatic')); 
		return null;
    }
}