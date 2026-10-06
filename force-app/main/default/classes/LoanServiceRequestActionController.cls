public with sharing class LoanServiceRequestActionController {
    private static String CLASS_NAME =LoanServiceRequestActionController.class.getName();
   
  @AuraEnabled
  public static Id getAccRequestCaseRecordType() {
      return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
  }

 
 


}