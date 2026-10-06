public  with sharing class FCRCaseController {
  private static String CLASS_NAME =FCRCaseController.class.getName();
   
  @AuraEnabled
  public static Id getFCRRecordType() {
      return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('FCR').getRecordTypeId();
  }
}