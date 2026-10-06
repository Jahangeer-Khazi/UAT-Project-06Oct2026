/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 28-12-2022
* 		Change History: 
*	     
*/
@isTest
public class PeriodicReviewBatch_UpdateCasesTest {
    
      @isTest
    static void unitTest2(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Segment__pc = 'Regular';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.On_boarding_type__pc = 'Manual';
        acc.CustomerStatus__c = 'Active';
        //acc.Passport_Expiry_Date__pc = System.today() + 10;
        //acc.Wathiq_Consent__pc = false;
        //acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        acc.pr_NextReviewDate__c = System.today();
        acc.Periodic_Review_Batch__c=True;
        insert acc;
        
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Periodic Review').getRecordTypeId();
		Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.accountId = acc.Id;
        cs1.Subject = 'New Periodic Review';
        cs1.Description = 'Testing for Periodic Review';
        cs1.Type = 'Periodic Review';
        cs1.PeriodicUpdateBatch__c=True;
        insert cs1;
        Account acc1 = new Account();
        acc1.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc1.FirstName = 'Test2';
        acc1.LastName = 'Class2';
        acc1.PersonEmail = 'test2@ilatest.com';
        acc1.Nationality__pc = 'IN';
        acc1.Segment__pc = 'Regular';
        acc1.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc1.On_boarding_type__pc = 'Manual';
        acc1.CustomerStatus__c = 'Active';
        //acc.Passport_Expiry_Date__pc = System.today() + 10;
        //acc.Wathiq_Consent__pc = false;
        //acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        acc1.pr_NextReviewDate__c = System.today();
        acc1.Periodic_Review_Batch__c=True;
        insert acc1;
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordTypeId;
        cs2.accountId = acc1.Id;
        cs2.Subject = 'New Periodic Review';
        cs2.Description = 'Testing for Periodic Review';
        cs2.Type = 'Periodic Review';
        cs2.PeriodicUpdateBatch__c=True;
        insert cs2;
        
        Test.startTest();
        PeriodicReviewBatch_UpdateCases periodicReview = new PeriodicReviewBatch_UpdateCases();
        Id jobid= Database.executeBatch(periodicReview,1);
        Test.stopTest();
    }

}