public class Automate_BidAllocationSchQB01 {
    
    @InvocableMethod(label='Automate QB01 BID Allocation' description='The purpose of this service is to trigger BID Allocation' callout=true )
    public static List<String> processBidAllocation(List<String> InstrumentID){
       Id jobId= System.enqueueJob(new QB01GenerateBIDAllocationReport(False,InstrumentID[0],'Automatic'));
       // Id jobId = Database.executeBatch(new APB09_GenerateBIDAllocationReport(True,BidISINCODE[0],'Automatic')); 
		return null;
    }
}