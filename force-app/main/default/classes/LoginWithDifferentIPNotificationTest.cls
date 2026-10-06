/*     Organization  : ABC Bank
 *     Created By    : Jahangeer Mohammed
 *    Created Date  : 01/07/2022
 *    Description   : This test class is covering the following classes
            1) LoginWithDifferentIPNotification
 *     Change History: 
 *         
 */
@isTest (SeeAllData=true)
public class LoginWithDifferentIPNotificationTest {
  static testMethod void unitTest1(){
         LoginWithDifferentIPNotification  eventCondition = new LoginWithDifferentIPNotification();
         eventCondition.evaluate(new Account());
         
    }
    static testMethod void unitTest2() {
          LoginEvent loginEvent = new LoginEvent();
          LoginWithDifferentIPNotification  eventCondition = new LoginWithDifferentIPNotification();
          eventCondition.evaluate(loginEvent); 
      }
    static testMethod void unitTest3(){
        LoginEvent loginEvent = new LoginEvent();
        AggregateResult[] results = [SELECT SourceIp FROM LoginHistory WHERE UserId = :loginEvent.UserId
                                     AND LoginTime = LAST_N_DAYS:1 GROUP BY SourceIp];
        LoginWithDifferentIPNotification  eventCondition = new LoginWithDifferentIPNotification();
		eventCondition.evaluate(loginEvent);
    }
   
}