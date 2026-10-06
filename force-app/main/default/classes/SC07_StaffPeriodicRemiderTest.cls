@isTest
public class SC07_StaffPeriodicRemiderTest {
    
    @isTest
    public static void executeBatchSchedulerTest(){  
        Test.StartTest();
            SC07_StaffPeriodicRemider testsche = new SC07_StaffPeriodicRemider();
            String sch = '0 0 8 1 11 ?';
            String sch1 = '0 0 8 1 5 ?';
            System.schedule('PLA - Periodic Email Reminder to be Sent to Staff to Update Relatives 1st November every year'+System.today(), sch, testsche );
            System.schedule('PLA - Periodic Email Reminder to be Sent to Staff to Update Relatives 1st May every year'+System.today(), sch1, testsche );
        Test.stopTest();
    }

}