public class QueuableSleep implements Queueable, Database.AllowsCallouts  {
    public void execute(QueueableContext context){
        DateTime nextExecutionTime = DateTime.now().addSeconds(10);
        System.debug('Next Execution Time 1:'+nextExecutionTime);
        
        for(Integer i = 0; i<=5; i++){
            DateTime currentTime = DateTime.now();
            if(currentTime < nextExecutionTime) {
                System.debug('I value is populating:'+i);
                System.debug('Current Time:'+System.now());
            }
            nextExecutionTime = DateTime.now().addSeconds(10);
            System.debug('Next Execution Time 2:'+nextExecutionTime);
        }
    }
    
}