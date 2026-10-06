/**
 * @author ANISS MBARKI
 * @date Creation 16/12/2021
 * @date Modification
 * @description
 */
@isTest
public class SC001_CheckSuppCardCasesTest {

    @isTest
    public static void executeBatchSchedulerTest(){  
        Test.StartTest();
        SC001_CheckSupplementaryCardCases testsche = new SC001_CheckSupplementaryCardCases();
        String sch = '0 0 * * * ?';
        system.schedule('Test checking alert status using Get_Compliance_Case_Status API Hourly : '+System.today(), sch, testsche );
        Test.stopTest();
    }
}