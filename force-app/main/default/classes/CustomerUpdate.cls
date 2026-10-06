/**
 *  @author: SP
 *  @date: 2019-08-02
 *  @description:
 *      controller for update customer field from customer update field
 *
 *  
 */
public class CustomerUpdate {
	
    /*  
     * @description: update customer field from customer update field 
     *      
     *	@param: lstId list of Account Id
     *  
     */
    @InvocableMethod
    public static void updateCustomerFields(List<Id> lstId){
        if(lstId != null && !lstId.isEmpty()){
            List<Cutomer_Fields_Update__c> cutomerFieldsUpdate = Cutomer_Fields_Update__c.getall().values();
            Private_Key__c privateKey = Private_Key__c.getOrgDefaults();
            
        	if(privateKey == null || privateKey.key__c == null) return;
            
            if(!cutomerFieldsUpdate.isEmpty() && privateKey != null && privateKey.key__c != null){
                String sql = 'select Id';
                for(Cutomer_Fields_Update__c cutomerField : cutomerFieldsUpdate){
                    sql += ', ' + cutomerField.Name + ', ' + cutomerField.Field_Update__c ;
                }
                sql += ' from Account where Id in :lstId';
                
                List<Account> lstAcc = database.query(sql);
				Schema.SObjectType sobTypeAccount = Schema.Account.getSObjectType();
				Map<String, Schema.SobjectField> fmap = sobTypeAccount.getDescribe().fields.getMap();   
                for(Account acc : lstAcc){
                    for(Cutomer_Fields_Update__c cutomerField : cutomerFieldsUpdate){
                      //  if(cutomerField.Encrypt__c && acc.get(cutomerField.Field_Update__c) != null && acc.get(cutomerField.Field_Update__c) !=False){
                       if(cutomerField.Encrypt__c && ((acc.get(cutomerField.Field_Update__c) != null && acc.get(cutomerField.Field_Update__c) !=False) || cutomerField.Allow_Null_Empty__c)){
                            String value = String.valueOf(acc.get(cutomerField.Field_Update__c));
                            
                            try{
                                acc.put(cutomerField.Name, Crypto.decryptWithManagedIV(UniqueIdentifierUUID.ALGORITHM_NAME, EncodingUtil.base64Decode(privateKey.key__c), EncodingUtil.base64Decode(value)).toString());
                            }catch(Exception ex){
                                //to avoid error with field that canot encrypt
                                acc.put(cutomerField.Name, acc.get(cutomerField.Field_Update__c));
                            }
                            
                          }else if((acc.get(cutomerField.Field_Update__c) != null && acc.get(cutomerField.Field_Update__c) !=False) || cutomerField.Allow_Null_Empty__c){
                            acc.put(cutomerField.Name, acc.get(cutomerField.Field_Update__c));
                        }
                        acc.put(cutomerField.Field_Update__c, fmap.get(cutomerField.Field_Update__c).getDescribe().getDefaultValue()); 
                    }
                    acc.Bypass_Validations__pc = true;
                    
                }
                
                update lstAcc;
            }
        }
    }
}