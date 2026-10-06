/*
Author :
Date :
Description : Test class to cover code of the Batch classes responsible for updating the Region Flag on existing records
    #CH01# Creation #03-02-2022# - YZ
    #CH02# #24-02-2022# - YZ
*/

@isTest(isParallel = true)
public class UpdateRegionBatchAccount2Test
{
    static Account createAccount() {
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'John';
        acc.LastName = 'Smith';
        acc.PersonEmail = 'john.smith.test@ilatest.com';
        acc.Nationality__pc = 'JO';
        acc.CIF__pc = '123123';
        insert acc;
        return acc;
    }     
    
    @isTest
    static void testUpdateMobilePhoneAccount() {        
        insert new Setting__c(Bypass_Validation_Rules__c = true);     
        Account a = createAccount();
        a.Mobile_Country_Code__pc = '+44';
        a.PersonMobilePhone = '7973748377';
        update a;        
        
        Test.startTest();
        Setting__c s = [Select Id from Setting__c limit 1];
        s.Bypass_Process_Builder__c = true;
        update s;           
        UpdateRegionBatchAccount2 cs =  new UpdateRegionBatchAccount2 ();
        Database.executeBatch(cs, 100);
        Test.stopTest();
        
        a = [Select Region_Flag__c, Region_Flag__pc, Mobile_Phone_Check__pc, Mobile_Phone_Check_Region__pc, Mobile_Country_Code__pc, PersonMobilePhone, PLA_Eligibility__pc from Account limit 1];
        System.assertEquals(a.Mobile_Country_Code__pc+a.PersonMobilePhone, a.Mobile_Phone_Check__pc, 'Expected the Mobile Phone Check field to be populated with the Country Code and Number');
        System.assertEquals(a.Mobile_Country_Code__pc+a.PersonMobilePhone+'-Bahrain', a.Mobile_Phone_Check_Region__pc, 'Expected the Mobile Phone Check fielf to be populated with the Region');        
    }
}