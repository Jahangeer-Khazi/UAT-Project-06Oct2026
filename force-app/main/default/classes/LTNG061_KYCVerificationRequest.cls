public class LTNG061_KYCVerificationRequest {
    
    private static String CLASS_NAME = LTNG061_KYCVerificationRequest.class.getName();
    
    @AuraEnabled
    public static Id getKycRecordType() {
        System.debug(Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId());
        return Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId();
    }
      @AuraEnabled
    public static Id getTypeBasedRecordType(String Type) {
        if(Type=='KYC_PERIODIC_REVIEW'){
        System.debug(Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId());
        return Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId();
        }else{
              System.debug(Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('Suspected_Identity_Fraud').getRecordTypeId());
        return Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('Suspected_Identity_Fraud').getRecordTypeId();
        }
    }
     @AuraEnabled
    public static Boolean validateCaseCreationRequest(String accountId){
        List <Kyc_Verification__C>kyc = [Select Id from Kyc_Verification__C where Account_Name__c=:AccountId and status__c='Open'];
        if(!kyc.isEmpty()){
            return false;
        }else{
            return true;
        }
    }
}