/*
Author :
Date :
Description : Test class to cover code of the Batch classes responsible for updating the Region Flag on existing records
    #CH01# Creation #03-02-2022# - YZ
*/

@isTest(isParallel = true)
public class UpdateRegionBatchTest
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
    static void testUpdateRegionFlagAccount() {        
        insert new Setting__c(Bypass_Validation_Rules__c = true);     
        Account a = createAccount();
        a.Region_Flag__c = ''; // We need a separate DML for the Before Insert Trigger Flow updating the Region Flag do not execute
        a.Region_Flag__pc = '';
        update a;        
        a = [Select Region_Flag__c, Region_Flag__pc from Account limit 1];
        System.assertEquals(null, a.Region_Flag__c, 'Expected an empty Region Flag on the Account');
        System.assertEquals(null, a.Region_Flag__pc, 'Expected an empty Region Flag on the Contact');
        
        Test.startTest();
        Setting__c s = [Select Id from Setting__c limit 1];
        s.Bypass_Process_Builder__c = true;
        update s;           
        UpdateRegionBatch cs =  new UpdateRegionBatch();
        Database.executeBatch(cs, 100);
        Test.stopTest();
        
        a = [Select Region_Flag__c, Region_Flag__pc, PersonMobilePhone, PLA_Eligibility__pc from Account limit 1];
        System.assertEquals('Bahrain', a.Region_Flag__c, 'Expected the Bahrain Region Flag on the Account');
        System.assertEquals('Bahrain', a.Region_Flag__pc, 'Expected the Bahrain Region Flag on the Contact');
        System.assertEquals('Yes', a.PLA_Eligibility__pc, 'Expected the PLA Eligibility');
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
        UpdateRegionBatch cs =  new UpdateRegionBatch();
        Database.executeBatch(cs, 100);
        Test.stopTest();
        
        a = [Select Region_Flag__c, Region_Flag__pc, Mobile_Phone_Check__pc, Mobile_Country_Code__pc, PersonMobilePhone, PLA_Eligibility__pc from Account limit 1];
        System.assertEquals(a.Mobile_Country_Code__pc+a.PersonMobilePhone+'-Bahrain', a.Mobile_Phone_Check__pc, 'Expected the Mobile Phone Check fielf to be populated with the Region');        
    }
    
    @isTest
    static void testUpdateRegionFlagCase() {        
        insert new Setting__c(Bypass_Validation_Rules__c = true);        
        Account a = createAccount();
        Case c = new Case();
        c.accountid = a.Id;
        insert c;        
        c.Region_Flag__c = ''; // We need a separate DML for the Before Insert Trigger Flow updating the Region Flag do not execute
        update c;        
        c = [Select Region_Flag__c from Case limit 1];
        System.assertEquals(null, c.Region_Flag__c, 'Expected an empty Region Flag on the Case');
        
        Test.startTest(); 
        Setting__c s = [Select Id from Setting__c limit 1];
        s.Bypass_Process_Builder__c = true;
        update s;       
        UpdateRegionBatchCase cs =  new UpdateRegionBatchCase();
        Database.executeBatch(cs, 100);
        Test.stopTest();
        
        c = [Select Region_Flag__c from Case limit 1];
        System.assertEquals('Bahrain', c.Region_Flag__c, 'Expected the Bahrain Region Flag on the Case');        
    }
    
    @isTest
    static void testUpdateRegionFlagContent() {        
        insert new Setting__c(Bypass_Validation_Rules__c = true);
        Content__c c = new Content__c();
        insert c;
        c.Region_Flag__c = ''; // We need a separate DML for the Before Insert Trigger Flow updating the Region Flag do not execute
        update c;   
        c = [Select Region_Flag__c from Content__c limit 1];
        System.assertEquals(null, c.Region_Flag__c, 'Expected an empty Region Flag on the Content');
        
        Test.startTest();  
        Setting__c s = [Select Id from Setting__c limit 1];
        s.Bypass_Process_Builder__c = true;
        update s;      
        UpdateRegionBatchContent cs =  new UpdateRegionBatchContent();
        Database.executeBatch(cs, 100);
        Test.stopTest();
        
        c = [Select Region_Flag__c from Content__c limit 1];
        System.assertEquals('Bahrain', c.Region_Flag__c, 'Expected the Bahrain Region Flag on the Content');        
    }
    
    @isTest
    static void testUpdateRegionFlagLead() {        
        insert new Setting__c(Bypass_Validation_Rules__c = true);
        Lead l = new Lead(LastName = 'Smith');
        insert l;
        l.Region_Flag__c = ''; // We need a separate DML for the Before Insert Trigger Flow updating the Region Flag do not execute
        update l;        
        l = [Select Region_Flag__c from Lead limit 1];
        System.assertEquals(null, l.Region_Flag__c, 'Expected an empty Region Flag on the Lead');
        
        Test.startTest(); 
        Setting__c s = [Select Id from Setting__c limit 1];
        s.Bypass_Process_Builder__c = true;
        update s;  
        UpdateRegionBatchLead cs =  new UpdateRegionBatchLead();
        Database.executeBatch(cs, 100);
        Test.stopTest();
        
        l = [Select Region_Flag__c from Lead limit 1];
        System.assertEquals('Bahrain', l.Region_Flag__c, 'Expected the Bahrain Region Flag on the Lead');        
    }
}