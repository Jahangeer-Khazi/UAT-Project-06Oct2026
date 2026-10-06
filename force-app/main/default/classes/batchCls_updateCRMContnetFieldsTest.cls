/*
Author : 
Date : 
Description : batchCls_updateCRMContnetFieldsTest
    #CH01# Added #27-11-2021# Region Flag changes - YZ
    #CH02# Added #22-06-2022# Document Model changes - HC
*/

@isTest(seeAllData=false)
public class batchCls_updateCRMContnetFieldsTest
{
    static testMethod void updateCRMContnetFieldsTest() 
    {
        List<Content__c> lstContent = new List<Content__c>();
        Content__c objCon = new Content__c();
        objCon.ID_Number__c = '123456789000';
        objCon.ID_Expiry_Date__c = system.today()+300;
        objCon.ID_Type__c = 'Bahraini ID';
        objCon.Proof_of_Address_ID_Type__c = 'Utility Bill';
        objCon.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon.Document_Model__c='ila'; // #CH02#
        lstContent.add(objCon);
        
        Content__c objCon1 = new Content__c();
        objCon1.ID_Number__c = '123456789123';
        objCon1.ID_Expiry_Date__c = system.today()+300;
        objCon1.ID_Type__c = 'Passport';
        objCon1.Proof_of_Address_ID_Type__c = 'CPR Extract';
        objCon1.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon1.Document_Model__c='ila'; // #CH02#
        lstContent.add(objCon1);
        
        Content__c objCon2 = new Content__c();
        objCon2.ID_Number__c = '123456789234';
        objCon2.ID_Expiry_Date__c = system.today()+300;
        objCon2.ID_Type__c = 'GCC ID';
        objCon2.Proof_of_Address_ID_Type__c = 'Bahraini Drivers Licence';
        objCon2.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon2.Document_Model__c='ila'; // #CH02#
        lstContent.add(objCon2);
        
        Content__c objCon3 = new Content__c();
        objCon3.ID_Number__c = '123456789456';
        objCon3.ID_Expiry_Date__c = system.today()+300;
        objCon3.ID_Type__c = 'Bahraini ID';
        objCon3.Proof_of_Address_ID_Type__c = 'Bank Statement';
        objCon3.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon3.Document_Model__c='ila'; // #CH02#
        lstContent.add(objCon3);
        
        Content__c objCon4 = new Content__c();
        objCon4.ID_Number__c = '123456784560';
        objCon4.ID_Expiry_Date__c = system.today()+300;
        objCon4.ID_Type__c = 'Bahraini ID';
        objCon4.Proof_of_Address_ID_Type__c = 'Tenancy Agreement';
        objCon4.Region_Flag__c = 'Bahrain'; // #CH01#
        objCon4.Document_Model__c='ila'; // #CH02#
        lstContent.add(objCon4);

        insert lstContent;
        
        Test.startTest();
            batchCls_updateCRMContnetFields obj = new batchCls_updateCRMContnetFields();
            DataBase.executeBatch(obj);                    
        Test.stopTest();
        
    }
    
        
}