/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 30/04/2025
*       Change History: 
*/
@isTest
public class walkinCustPopUpResetCounterTest {
 @isTest
    static void unitTest1(){
        Pop_Up_Token_Counter__c custTknCounter = new Pop_Up_Token_Counter__c();
        custTknCounter.Counter__c = 1 ;
        insert custTknCounter;
        Test.startTest();
        walkinCustPopUpResetCounter resetSchedulerCounter = new walkinCustPopUpResetCounter();
        String sch ='0 48 * * * ?'; 
		System.schedule('Schedule to Reset Counter', sch,resetSchedulerCounter);
        Test.stopTest();
    }
}