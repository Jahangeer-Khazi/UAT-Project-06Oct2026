/*     Organization   : ABC Bank
*     Created By     : Jahangeer Mohammed
*    Created Date   : 22/02/2022
*    Description    : This Apex class is used for monitoring IP Addresses of a user, whenever any user is logged in from different IPS
during 24 hours then email will be sent to infosec user.
*      Test Class     : LoginWithDifferentIPNotification_Test
*     Change History : 
*         
*/
public class LoginWithDifferentIPNotification implements TxnSecurity.EventCondition,TxnSecurity.AsyncCondition{
    public boolean evaluate(SObject event) {
        switch on event{
            when LoginEvent loginEvent { 
                return evaluate(loginEvent);
            }
            when null { 
                return false;
            }
            when else{
                return false;
            }
        }
    }
    
    public boolean evaluate(LoginEvent loginEvent) {
        
        AggregateResult[] results = [SELECT SourceIp FROM LoginHistory WHERE UserId = :loginEvent.UserId
                                     AND LoginTime = LAST_N_DAYS:1 GROUP BY SourceIp];
        System.debug('Result size:'+results.size());
        if(!results.isEmpty()) {
            ID jobID = System.enqueueJob(new EmailMessageQueuableIPNotification(loginEvent));
            return true;
        }
        return false; 
    }
}