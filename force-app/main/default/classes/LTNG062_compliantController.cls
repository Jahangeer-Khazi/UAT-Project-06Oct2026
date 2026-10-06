public class LTNG062_compliantController {
@AuraEnabled
	public static Id getInternalCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Complaint').getRecordTypeId();
    }
    @AuraEnabled
    public static Id getCustomerDetails(string cif){
        account acnt=[Select Id From account where CIF__pc=:cif];
        return acnt.Id;
    }
}