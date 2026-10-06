/**
 * @author Imane Tsioucha
 * @date Création 29/11/2023
 * @date Modification
 * @description : The class used in LTNG035_CollectionLegalActionFCR.
 */
public with sharing class LTNG035_CollectionLegalActionController {
    private static String CLASS_NAME =LTNG035_CollectionLegalActionController.class.getName();
   
    @AuraEnabled
    public static Id getCollectionLegalCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Collection_Legal_Action_FCR').getRecordTypeId();
    }

    @AuraEnabled
    public static Account getAccount(String accountId) {
        Account acc = [SELECT Id, Name, Collection_Case__c, Legal_Action__c FROM Account WHERE Id=: accountId ];
        return acc;
        
    }
    @AuraEnabled
    public static Boolean updateCheckboxCustomer(String accountId, Boolean isCollectionChecked, Boolean isLegalChecked, Boolean isLoanCollectionChecked, Boolean isLoanLegalChecked) {
        // Update the checkbox on the Account
        Account acc = [SELECT Id, Collection_Case__c, Legal_Action__c, Loan_Collection_Case__c, Loan_Legal_Action__c FROM Account WHERE Id = :accountId];
        Boolean isSucess=false;
        if (acc != null) {
            if(isCollectionChecked != null && acc.Collection_Case__c != isCollectionChecked){
                acc.Collection_Case__c = isCollectionChecked;
                update acc;
                isSucess=true;
            }
            if(isLegalChecked != null && acc.Legal_Action__c != isLegalChecked){
                acc.Legal_Action__c = isLegalChecked;
                update acc;
                isSucess=true;
            }
            if(isLoanCollectionChecked != null && acc.Loan_Collection_Case__c != isLoanCollectionChecked){
                acc.Loan_Collection_Case__c = isLoanCollectionChecked;
                update acc;
                isSucess=true;
            }
            if(isLoanLegalChecked != null && acc.Loan_Legal_Action__c != isLoanLegalChecked){
                acc.Loan_Legal_Action__c = isLoanLegalChecked;
                update acc;
                isSucess=true;
            }
          
        }
        System.debug('isSucess==>'+isSucess);
        return isSucess;
    }
}