/*
Author : 
Date : 
Description : batchCls_UpdateContentVerifictionTest
    #CH01# Added #27-11-2021# Region Flag changes - YZ
    #CH02# Added #22-06-2022# Document Model changes - HC
*/

@isTest(seeAllData=false)
public class batchCls_UpdateContentVerifictionTest
{
    static testMethod void updateContentVerifictionTest() 
    {
         Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.Archived__pc = FALSE;
        insert acc;
        
        List<Content__c> lstContent = new List<Content__c>();
        Content__c objCon = new Content__c();
        objCon.ID_Number__c = '123456789000';
        objCon.ID_Expiry_Date__c = system.today()+300;
        objCon.Person__c = acc.id;
        objCon.ID_Type__c = 'Bahraini ID';
        objCon.Proof_of_Address_ID_Type__c = 'Utility Bill';
        objCon.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon.Document_Model__c='ila'; // #CH02#
        objCon.Updated__c = TRUE;
        objCon.Image_Type__c = 'Front';
        objCon.Similarity__c = '';
        
        lstContent.add(objCon);
        
        Content__c objCon1 = new Content__c();
        objCon1.ID_Number__c = '123456789123';
        objCon1.ID_Expiry_Date__c = system.today()+300;
        objCon1.ID_Type__c = 'Passport';
        objCon1.Proof_of_Address_ID_Type__c = 'CPR Extract';
        objCon1.Person__c = acc.id;
        objCon1.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon1.Document_Model__c='ila'; // #CH02#
        objCon.Updated__c = TRUE;
        objCon.Image_Type__c = 'Back';
        objCon.Verification_Status__c = '';
        lstContent.add(objCon1);
        
        Content__c objCon2 = new Content__c();
        objCon2.ID_Number__c = '123456789234';
        objCon2.ID_Expiry_Date__c = system.today()+300;
        objCon2.ID_Type__c = 'GCC ID';
        objCon2.Person__c = acc.id;
        objCon2.Proof_of_Address_ID_Type__c = 'Bahraini Drivers Licence';
        objCon2.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon2.Document_Model__c='ila'; // #CH02#
        objCon.Updated__c = TRUE;
        objCon.Image_Type__c = 'Face';
        lstContent.add(objCon2);
        
       

        insert lstContent;
        
        Test.startTest();
            batchCls_UpdateContentVerifictionSatus obj = new batchCls_UpdateContentVerifictionSatus();
            DataBase.executeBatch(obj);                    
        Test.stopTest();
        
    }
    
        
}