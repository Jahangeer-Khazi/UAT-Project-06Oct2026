/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 24-07-2023
*       Change History: 
*        
*/
@isTest
public class ContentValidityPassportBatchUpdateTest {
    @isTest
    static void unitTest1(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        insert acc; 
        
        Content__c cnt1 = new Content__c();
        cnt1.Person__c = acc.Id;
        cnt1.Document_Type__c = 'Passport';
        cnt1.Document_Expiry_Date__c = System.today() + 60;
        cnt1.Image_Type__c = 'Face';
        cnt1.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt1.Similarity__c = 'MATCH';
        cnt1.Updated__c = true;
        cnt1.Region_Flag__c = 'Bahrain';
        cnt1.Document_Country__c = 'BH';
        cnt1.Scan_Type__c = 'POI';
        insert cnt1;
        
        Content__c cnt2 = new Content__c();
        cnt2.Person__c = acc.Id;
        cnt2.Document_Type__c = 'Passport';
        cnt2.Document_Expiry_Date__c = System.today() + 60;
        cnt2.Image_Type__c = 'Front';
        cnt2.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2.Similarity__c = 'MATCH';
        cnt2.Updated__c = true;
        cnt2.Region_Flag__c = 'Bahrain';
        cnt2.Document_Country__c = 'BH';
        cnt2.Scan_Type__c = 'POI';
        insert cnt2;
        
        Test.startTest();
        ContentValidityPassportBatchUpdate conValidity = new ContentValidityPassportBatchUpdate();
        Id jobid= Database.executeBatch(conValidity,5);
        Test.stopTest();
        }
     @isTest
    static void unitTest2(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Wathiq_Consent__pc = true;
        acc.eKYC_IDandV_Document_Upload_Hash__pc = 'Dummy Test Value';
        acc.Region_Flag__pc = 'Bahrain';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        insert acc; 
        
        Content__c cnt1 = new Content__c();
        cnt1.Person__c = acc.Id;
        cnt1.Document_Type__c = 'Passport';
        cnt1.Document_Expiry_Date__c = System.today() + 60;
        cnt1.Image_Type__c = 'Face';
        cnt1.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt1.Similarity__c = 'MATCH';
        cnt1.Updated__c = true;
        cnt1.Region_Flag__c = 'Bahrain';
        cnt1.Document_Country__c = 'BH';
        cnt1.Scan_Type__c = 'POI';
        insert cnt1;
        
        Content__c cnt2 = new Content__c();
        cnt2.Person__c = acc.Id;
        cnt2.Document_Type__c = 'Passport';
        cnt2.Document_Expiry_Date__c = System.today() + 60;
        cnt2.Image_Type__c = 'Front';
        cnt2.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt2.Similarity__c = 'MATCH';
        cnt2.Updated__c = true;
        cnt2.Region_Flag__c = 'Bahrain';
        cnt2.Document_Country__c = 'BH';
        cnt2.Scan_Type__c = 'POI';
        insert cnt2;
        
        Content__c cnt22 = new Content__c();
        cnt22.Person__c = acc.Id;
        cnt22.Document_Type__c = 'Passport';
        cnt22.Document_Expiry_Date__c = System.today() + 60;
        cnt22.Image_Type__c = 'Front';
        cnt22.Verification_Status__c = 'APPROVED_VERIFIED';
        cnt22.Similarity__c = 'MATCH';
        cnt22.Updated__c = true;
        cnt22.Region_Flag__c = 'Bahrain';
        cnt22.Document_Country__c = 'BH';
        cnt22.Scan_Type__c = 'POI';
        insert cnt22;
        
        Test.startTest();
       
        ContentValidityPassportBatchUpdate conValidity = new ContentValidityPassportBatchUpdate();
        Id jobid= Database.executeBatch(conValidity);
        Test.stopTest();
        }

}