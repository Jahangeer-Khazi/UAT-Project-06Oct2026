/*     Organization  : ABC Bank
 *     Created By    : Jahangeer Mohammed
 *    Created Date  : 22/02/2022
 *    Description   : This Apex class is used for monitoring Report viewing and Report Extractions.
 *    Test Class    : ExportLargeDataUsingReportTest
 *     Change History: 
 *         
 */
global class ExportLargeDataUsingReport implements TxnSecurity.EventCondition,TxnSecurity.AsyncCondition {
  public boolean evaluate(SObject event) {
        switch on event{
            when ReportEvent reportEvent {
                return evaluate(reportEvent);
            }
            when null {
                // Don't take policy action when event is null
                return false;
            }
            when else{
                // Don't take policy action when event is not handled
                return false;
            }
        }
    }
    /**
     * Handle evaluating ReportEvent
     */
    public boolean evaluate(ReportEvent reportEvent){
        if(reportEvent.RowsProcessed > Integer.valueOf(system.Label.RECORD_COUNT) && reportEvent.Operation == 'ReportExported'){
            ID jobID = System.enqueueJob(new EmailMessageQueuable(reportEvent));
            //System.debug('Job Id:'+jobID);
            return true;
        }
       return false; 
    }
   
}