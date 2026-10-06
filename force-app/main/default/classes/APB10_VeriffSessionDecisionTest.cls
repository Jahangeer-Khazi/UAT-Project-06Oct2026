@isTest
public class APB10_VeriffSessionDecisionTest {

    @testSetup static void setupMethode() {
        Account acc1 = new Account(
                            FirstName = 'TestIla',
                            LastName = 'TestIla',
                            CIF__pc = '123456',
                            PersonEmail = 'testclass@ilatest123.com',
                            Region_Flag__pc = 'Bahrain',
                            ReconciliationStatus__pc = 'Initial'
                        );
        insert acc1;

        Document_Reconciliation_Result__c objCon = new Document_Reconciliation_Result__c();
        objCon.Customer__c = acc1.Id;
        objCon.GetSessionDecision__c = false;
        objCon.SessionId__c = '123456789';
        insert objCon; 
    }

    @isTest public static void batchPassTest(){
        Test.startTest();
            APB10_VeriffSessionDecision crn= new APB10_VeriffSessionDecision();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}