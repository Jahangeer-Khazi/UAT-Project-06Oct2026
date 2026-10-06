/***
 * @description       : 
 * @author            : Aniss Mbarki
 * @group             : 
 * @last modified on  : 08-07-2024
 * last modified by  : 
**/
public without sharing class LTNG046_DeceasedCustomerController {
    
    @AuraEnabled
	public static Id getDeceasedCustomerCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Deceased_Customer').getRecordTypeId();
    }

    @InvocableMethod(label='Deceased Custumer Initialisation' description='Deceased Custumer Initialisation' )
    public static List<String> deceasedCustomerInitFromFlow(List<Id> caseIds)
    {
        deceasedCustomerInitFuture (new Set<Id>(caseIds));
        return caseIds;
    }

    @future(callout=true)
    public static void deceasedCustomerInitFuture (Set<Id> caseIds)
    {
        List<Case> casesUpdate = new List<Case>();
        for(Id caseId : caseIds){
            Case cs = new Case(Id=caseId);
            cs.OwnerId = system.Label.Deceased_Customer_Contact_Center;
            cs.Sub_Status__c = 'Pending';
            cs.Awaiting_Customer_Feedback__c = true;
            cs.Status = 'Open';
            cs.Date_Awaiting_Customer_Feedback__c = System.now();
            casesUpdate.add(cs);
        }
        if( casesUpdate.size() > 0 ){
            update casesUpdate;
        }
    }
}