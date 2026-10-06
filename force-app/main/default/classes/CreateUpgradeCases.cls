/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 02-08-2026
*      Description : Creating Upgrade Cases from Limit Increase Application
*      Change History: 

*/ 
global class CreateUpgradeCases implements Queueable{
    Set<Id> caseId;
    
    public CreateUpgradeCases(set<Id> setCaseIdsSet){
        this.caseId = setCaseIdsSet;
    }
    public void execute(QueueableContext context){
        List<Case> caseToInsert = new List<Case>();
        List<Case> lstCase = [Select id, AccountId, Type, Sub_Type__c,cc_Name_on_the_Card__c,cc_Approved_Credit_Limit__c,cc_Credit_Card_PCI_Number__c,cc_Approved_Requested_Card_Type__c,Card_Type__c,Selected_Supplementary_Cards__c,Is_Cash_Collateral__c,cc_PCI_Id__c,Target_Upgrade_Credit_Card_Type__c from Case Where Id IN : caseId];
        if(lstCase.size() > 0){
            for(Case c : lstCase){
               Id upgradeRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Upgrade_Request').getRecordTypeId();
			   Case cs = new Case();
               cs.AccountId = c.AccountId;
        	   cs.RecordTypeId = upgradeRecordTypeId;
        	   cs.Type = 'Credit Card Upgrade';
        	   cs.Sub_Type__c = 'Credit Card Upgrade - No Limit Increase';
        	   cs.Origin = 'CRM';
        	   cs.Case_Nature__c = 'Credit Card';
               cs.cc_Name_on_the_Card__c = c.cc_Name_on_the_Card__c;
               cs.cc_PCI_Id__c = c.cc_Credit_Card_PCI_Number__c;
               cs.cc_Credit_Card_PCI_Number__c = c.cc_PCI_Id__c;
        	   cs.cc_Current_Credit_Limit__c = c.cc_Approved_Credit_Limit__c;
		       cs.Card_Type__c = c.cc_Approved_Requested_Card_Type__c;
               cs.cc_Requested_Card_Type__c = c.Target_Upgrade_Credit_Card_Type__c;
               cs.Selected_Supplementary_Cards__c = c.Selected_Supplementary_Cards__c;
               cs.ParentId = c.id;
               cs.Is_Initiated_from_Limit_Increase_Case__c = true;
               caseToInsert.add(cs);
            }
        }
        if(caseToInsert.size()>0){
            insert caseToInsert;
        }
    }
    
}