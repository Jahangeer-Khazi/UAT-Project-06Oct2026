/**
 * Created by AHSISH on 15/12/2022.
 * //Test class - Update the MoEngage fields - RM-1936: https://bank-abc.atlassian.net/browse/RM-1936
 */
@isTest(seeAllData=false)
public class BatchCls_UpdatePushNotificationTest
{
    static testMethod void testUpdateMobilePhoneAccount() 
    {        
       // insert new Setting__c(Bypass_Validation_Rules__c = true);
       // 
        
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        //acc.Referred_By__c =
        insert acc;
        Account acc1 = new Account();
        acc1.FirstName = 'Test';
        acc1.LastName = 'Class';
        acc1.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc1.Onboarding_Group__pc = 'Registration';
        acc1.Referred_By__c = acc.id;
        insert acc1;

        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.PersonMobilePhone='9909444545';
        acc.PersonEmail='test@test.com';
        acc.Archived__pc=FALSE;
        acc.Push_Notifications__pc=FALSE;
        update acc;
        
        Test.startTest();
        BatchCls_UpdatePushNotificationFields cs =  new BatchCls_UpdatePushNotificationFields();
        Database.executeBatch(cs, 1);
        Test.stopTest();
        
    }
}