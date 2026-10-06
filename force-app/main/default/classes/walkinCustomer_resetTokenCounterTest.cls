/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 21/12/2022
*       Change History: 
*/
@isTest
public class walkinCustomer_resetTokenCounterTest {
    @isTest
    static void unitTest1(){
        Customer_TokenCounter__c custTknCounter = new Customer_TokenCounter__c();
        custTknCounter.Counter__c = 1 ;
        insert custTknCounter;
        Test.startTest();
        walkinCustomer_resetTokenCounter resetSchedulerCounter = new walkinCustomer_resetTokenCounter();
        String sch ='0 48 * * * ?'; 
		System.schedule('Schedule to Reset Counter', sch,resetSchedulerCounter);
        Test.stopTest();
    }

}