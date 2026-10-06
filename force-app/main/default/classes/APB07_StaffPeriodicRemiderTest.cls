@isTest
public class APB07_StaffPeriodicRemiderTest {

    @testSetup static void setupMethode() {
        Account acc1 = new Account(
                            FirstName = 'TestIla',
                            LastName = 'TestIla',
                            PersonEmail = 'testclass@ilatest123.com',
                            Segment__pc = 'Staff',
                            Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED',
                            Archived__pc = false,
                            Staff_Corporate_Email__pc = 'test@gmail.com'
                        );
        insert acc1;
    }

    @isTest public static void batchPassTest(){
        Test.startTest();
            APB07_StaffPeriodicRemider crn= new APB07_StaffPeriodicRemider();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}