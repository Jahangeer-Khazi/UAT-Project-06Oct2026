/**
 *  @author: SP
 *  @date: 2019-07-17 
 *  Description: Test class of UniqueIdentifierUUID
 */

@isTest
private class UniqueIdentifierUUIDTest {

    @testSetup static void setup() {
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acc = new Account(LastName='Test', CIF__pc='1234', RecordTypeId=devRecordTypeId);
        insert acc; 
    }
    
    static testMethod void testUpdatePersonAccountUUID() {
        Account acc = [select id from Account limit 1];
        List<Id> lstId = new List<Id>();
        lstId.add(acc.Id);
        
        UniqueIdentifierUUID.UpdatePersonAccountUUID(lstId);
        
        Private_Key__c privateKey = Private_Key__c.getOrgDefaults();
        acc = [select CIF__pc, UUID__pc from Account where id = :acc.Id];
        Blob decrypted = Crypto.decryptWithManagedIV(UniqueIdentifierUUID.ALGORITHM_NAME, EncodingUtil.base64Decode(privateKey.key__c), EncodingUtil.base64Decode(acc.UUID__pc));
        String decryptedString = decrypted.toString();
        system.assertEquals(acc.CIF__pc, decryptedString);
    }
}