/**
 *  @author: SP
 *  @date: 2019-07-17 
 *  Description: Update UUID of Contact
 */
public class UniqueIdentifierUUID {
	public static final String ALGORITHM_NAME = 'AES256';
	
    /**
	 * define the person account by Id and set UUID__pc to a salted hash of the CIF_pc
	 * 
	 * @param	lstId	Id of Account
	 */ 
    @InvocableMethod
    public static void UpdatePersonAccountUUID(List<Id> lstId){
        if(!lstId.isEmpty()){
            Private_Key__c privateKey = Private_Key__c.getOrgDefaults();
            if(privateKey == null || privateKey.key__c == null){
                Blob key = Crypto.generateAesKey(256);
                privateKey.key__c = EncodingUtil.base64Encode(key);
                insert privateKey;
            }
            
            List<Account> lstAccount = new List<Account>();
            for(Account acc : [select CIF__pc from Account where id in :lstId]){
                acc.UUID__pc = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV(ALGORITHM_NAME, EncodingUtil.base64Decode(privateKey.key__c), Blob.valueOf(acc.CIF__pc)));
                lstAccount.add(acc);
            }
            update lstAccount;
        }
    }
}