/**
 *  @author: SP
 *  @date: 2019-08-02 
 *  Description: Test class of UniqueIdentifierUUID
 */

@isTest
private class CustomerUpdateTest {
	
    @testSetup static void setup() {
        List<Cutomer_Fields_Update__c> customerFields = new List<Cutomer_Fields_Update__c>();
        customerFields.add(new Cutomer_Fields_Update__c(Name='Arabic_Name__pc', Field_Update__c='Arabic_Name_Update__pc' , Encrypt__c=true));
        customerFields.add(new Cutomer_Fields_Update__c(Name='Gender__pc', Field_Update__c='Gender_Update__pc' , Encrypt__c=false));
        customerFields.add(new Cutomer_Fields_Update__c(Name='FATCA_Customer__pc', Field_Update__c='Fatca_Customer_Update__pc' , Encrypt__c=false));
        insert customerFields;
        
        Blob key = Crypto.generateAesKey(256);
        Private_Key__c privateKey = new Private_Key__c(key__c = EncodingUtil.base64Encode(key));
        insert privateKey;

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test12', CIF__pc='1234', RecordTypeId=devRecordTypeId, Gender_Update__pc='M');
        acc.Arabic_Name_Update__pc = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV(UniqueIdentifierUUID.ALGORITHM_NAME, EncodingUtil.base64Decode(privateKey.key__c), Blob.valueOf('Test Arabic')));
        insert acc; 
    }
    
    static testMethod void testUpdateCustomerFields() {
        Account acc = [select id from Account limit 1];
        List<Id> lstId = new List<Id>();
        lstId.add(acc.Id);
        
        CustomerUpdate.updateCustomerFields(lstId);
        Account acc2 = [select Arabic_Name_Update__pc, Arabic_Name__pc, Gender__pc, Gender_Update__pc from Account where Id = :acc.id];

        system.assertEquals(acc2.Arabic_Name_Update__pc, null);
        system.assertEquals(acc2.Gender_Update__pc, null);
        system.assertEquals(acc2.Gender__pc, 'M');
        system.assertEquals(acc2.Arabic_Name__pc, 'Test Arabic');
    }
}