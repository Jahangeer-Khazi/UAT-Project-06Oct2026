@isTest
public class APB06_CheckPrepaidCardCasesTest {

    @testSetup static void setupMethode() {
        Account acc1 = new Account(
                            FirstName = 'Test',
                            LastName = 'Test',
                            PersonEmail = 'testclass@ilatest123.com',
                            CIF__pc = '123456',
                            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId()
                        );
        insert acc1;

        Id prepaidCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ppc_Prepaid_Card').getRecordTypeId();
        Case objCase = new Case(
            sc_Card_Holder_ID_Number__c = '123',
            RecordTypeId = prepaidCardRecordId,
            Subject = 'test case',
            Description = 'A technical issue has occurred at an API level.',
            Status = 'In Progress',
            Sub_Status__c = 'Screening',
            Priority = 'High',
            Type = 'Credit Card Prepaid Application',
            Sub_Type__c = 'New Prepaid Application',
            Origin = 'Phone',
            ContactId = acc1.PersonContactId,
            sc_Card_Holder_First_Name__c = 'test firstName',
            sc_Card_Holder_Last_Name__c = 'test lastName',
            AccountId = acc1.id,
            ppc_Approved_Name_On_The_Card__c='tesst',
            Case_Model__c='ila'

        );
        insert objCase;
        
        objCase.Sub_Status__c = 'Screening';
        update objCase;
           
        Prepaid_CreditCard__c objPrepaidCard = new Prepaid_CreditCard__c(Status__c='In Progress',Related_Case__c = objCase.Id,Applicant__c=acc1.id);
        insert objPrepaidCard;

       // System.debug('Check *************************************');
        //System.debug([SELECT Id FROM Account LIMIT 1]);
        //System.debug([SELECT Id,RecordType.DeveloperName,Status,Sub_Status__c FROM Case LIMIT 1]);
        //System.debug([SELECT Id,Status__c FROM Prepaid_CreditCard__c LIMIT 1]);
    } 
    @isTest public static void batchPassTest(){
        
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            MCK001_ApiCalls.decision = 'PASS';//toCheck
            APB06_CheckPrepaidCardCases crn= new APB06_CheckPrepaidCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
    @isTest public static void batchTestStatutCode(){//toCheck
         Test.startTest();
         MCK001_ApiCalls.statusCodeGlobal = 430;
             MCK001_ApiCalls.decision = 'PASS';
             APB06_CheckPrepaidCardCases crn= new APB06_CheckPrepaidCardCases();
             Id jobId = Database.executeBatch(crn,200);
         Test.stopTest();
     }
         

    @isTest public static void batchRejectTest(){
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            MCK001_ApiCalls.decision = 'REJECT';
            APB06_CheckPrepaidCardCases crn= new APB06_CheckPrepaidCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }

    @isTest public static void batchErrorTest(){
        Test.startTest();
             
            MCK001_ApiCalls.statusCodeGlobal = 400;
            APB06_CheckPrepaidCardCases crn= new APB06_CheckPrepaidCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }

    @isTest public static void batchPendingTest(){
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            MCK001_ApiCalls.decision = 'PENDING';
            APB06_CheckPrepaidCardCases crn= new APB06_CheckPrepaidCardCases();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}