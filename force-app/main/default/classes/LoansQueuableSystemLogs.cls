public class LoansQueuableSystemLogs implements Queueable {
    private static ApiConnection con = new ApiConnection();
    List<System_Action__c> lstSystemActions;
    public LoansQueuableSystemLogs(List<System_Action__c> lstSA){
        this.lstSystemActions = lstSA;
    }
    public void execute(QueueableContext qc) {
        if(lstSystemActions.size()>0){
            insert lstSystemActions;
        }
    }
}