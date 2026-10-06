@isTest
public with sharing class SC06_CheckPrepaidCardCasesTest {
 
        @isTest
        public static void executeBatchSchedulerTest(){  
            Test.StartTest();
            SC06_CheckPrepaidCardCases testprepaidCard= new SC06_CheckPrepaidCardCases();
            String sch = '0 0 * * * ?';
            System.schedule('Test '+System.today(), sch, testprepaidCard );
            Test.stopTest();
        }
    
}