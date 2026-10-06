/*    
Version History :
 *            #CH01 Amina BENABDELKRIM  add add new field (case model) with default value 'ila'
*/
@isTest
public class APB001_CheckSupplCardCasesTest {

    @testSetup static void setupMethode() {
        Account acc1 = new Account(
                            FirstName = 'TestIla',
                            LastName = 'TestIla',
                            PersonEmail = 'testclass@ilatest123.com'
                        );
        insert acc1;
        Id suppCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Supplementary').getRecordTypeId();
        Case objCase = new Case(
            sc_Card_Holder_ID_Number__c = '123',
            RecordTypeId = suppCardRecordId,
            Subject = 'test case',
            Description = 'A technical issue has occurred at an API level.',
            Status = 'In Progress',
            Sub_Status__c = 'Screening',
            Priority = 'High',
            Type = 'Credit Card Supplementary Application',
            Case_Model__c='ila',//CH01
            Sub_Type__c = 'New Supplementary Card',
            Origin = 'Phone',
            ContactId = acc1.PersonContactId,
            sc_Card_Holder_First_Name__c = 'test firstName',
            sc_Card_Holder_Last_Name__c = 'test lastName',
            AccountId = acc1.id
        );
        insert objCase;

        Supplementary_Card__c objSuppCard = new Supplementary_Card__c(Status__c='In Progress',Related_Case__c = objCase.Id,Primary_Customer__c=objCase.AccountId);
        insert objSuppCard;
    }

    @isTest public static void batchPassTest(){
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            APB001_CheckSupplementaryCardCases crn= new APB001_CheckSupplementaryCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }


    @isTest public static void batchRejectTest(){
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            MCK001_ApiCalls.decision = 'REJECT';
            APB001_CheckSupplementaryCardCases crn= new APB001_CheckSupplementaryCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }

    @isTest public static void batchErrorTest(){
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 400;
            APB001_CheckSupplementaryCardCases crn= new APB001_CheckSupplementaryCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }

    @isTest public static void batchPendingTest(){
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            MCK001_ApiCalls.decision = 'PENDING';
            APB001_CheckSupplementaryCardCases crn= new APB001_CheckSupplementaryCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}