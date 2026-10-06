/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 17/03/2025
*       Change History: 
*/
public class walkinCustPopUpResetCounter implements Schedulable{
    public void execute(SchedulableContext ctx) {
        List<Pop_Up_Token_Counter__c> lstToken = [SELECT Id, Name, OwnerId, Today_s_Date__c, Counter__c FROM Pop_Up_Token_Counter__c LIMIT 1];
        if(lstToken.size()>0){
            lstToken[0].Counter__c = 1;
            lstToken[0].Today_s_Date__c = system.today();
            update lstToken[0];
        }
    }

}