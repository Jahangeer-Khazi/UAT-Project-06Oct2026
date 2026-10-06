/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 10-01-2023
*       Change History: 
*        
*/
@isTest
public class batchCls_PR_UpdateNextReviewDateTest {
    @isTest
     static void unitTest1(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Segment__pc = 'Regular';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.On_boarding_type__pc = 'Manual';
        acc.Passport_Expiry_Date__pc = System.today() + 10;
        acc.Wathiq_Consent__pc = false;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = '';
        acc.Risk_Rating__pc  = 'Prohibited';
        acc.Bank_Account_Opening_Date__c = System.today() - 500;
        insert acc;
        
        Test.startTest();
        batchCls_PR_UpdateNextReviewDate updateNextReviewDate = new batchCls_PR_UpdateNextReviewDate();
        Id jobid= Database.executeBatch(updateNextReviewDate,5);
        Test.stopTest();
    }

}