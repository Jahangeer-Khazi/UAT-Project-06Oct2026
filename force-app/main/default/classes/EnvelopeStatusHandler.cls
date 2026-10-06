/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:15-08-2024
 * 		Change History: 
 * 					#CH01# #19-08-2026# #Jahangeer Mohammed# Added Last Call Outcome condition(PI-5106)

 *  
 *			  
 */
public class EnvelopeStatusHandler extends BaseTriggerHandler {
    
    //override public void beforeInsert () {
    //... your code here
    //}
    
    //override public void beforeUpdate () {
    //... your code here
    //}
    
    override public void afterInsert () {
        documentReceived((list<dfsle__EnvelopeStatus__c>) trigger.New);
    }
    
    override public void afterUpdate () {
        documentSent((list<dfsle__EnvelopeStatus__c>) trigger.New) ;
    }
    
    //override public void afterDelete () {
    //... your code here
    //}
    
    //override public void afterUnDelete () {
    //... your code here
    //}
    public static void documentSent(list<dfsle__EnvelopeStatus__c> documentStatusList){
        Set<Id> caseIdSetCompleted = new Set<Id>();
        for(dfsle__EnvelopeStatus__c vItem : documentStatusList){
            system.debug('EnvelopeStatusTrigger||'+vItem.dfsle__Status__c +'||'+ vItem.dfsle__SourceId__c);
            if(vItem.dfsle__Status__c =='Completed'){
                caseIdSetCompleted.add(vItem.dfsle__SourceId__c);
            }
            
        }
        if(!caseIdSetCompleted.isEmpty()){
            //CH01: Start : Added Type,Sub_Type__c,AIR_HaveCreditCard__c,Last_Call_Outcome__c,Status in SOQL
            List<Case> caseList = [SELECT Id,Type,Sub_Type__c,AIR_HaveCreditCard__c,Last_Call_Outcome__c,Status,cc_isDocumentReceived__c,cc_isDocumentSent__c,cc_Signature_Verifier_Result__c FROM Case WHERE Id In: caseIdSetCompleted];
            //CH01: END
            for(Case xItem: caseList){
                xItem.cc_isDocumentReceived__c = true;
                xItem.cc_isDocumentSent__c = false;
                xItem.Awaiting_Customer_Feedback__c = false;
                //CH01: Start
                System.debug('Document Status Completed');
                if(xItem.Type == 'New Loan / Finance Application' && xItem.Sub_Type__c == 'New Loan / Finance Application Request' && xItem.AIR_HaveCreditCard__c == true){
                   System.debug('Document Status Completed inside if condition');
                   xItem.Last_Call_Outcome__c = 'Completed'; 
                   xItem.Status = 'Under Review';
                   xItem.Sub_Status__c = 'Pending Signature Verification';
                }
                //CH01: END
                if(xItem.cc_Signature_Verifier_Result__c=='Re-Send'){
                    xItem.cc_Signature_Verifier_Result__c = '';
                }
                update caseList;
            }
        }
    }
    
    public static void documentReceived(list<dfsle__EnvelopeStatus__c> documentStatusList){
        Set<Id> caseIdSetCompleted = new Set<Id>();
        for(dfsle__EnvelopeStatus__c vItem : documentStatusList){
            system.debug('EnvelopeStatusTrigger||'+vItem.dfsle__Status__c +'||'+ vItem.dfsle__SourceId__c);
            if(vItem.dfsle__Status__c =='Sent'){
                caseIdSetCompleted.add(vItem.dfsle__SourceId__c);
            }
            
        }
        if(!caseIdSetCompleted .isEmpty()){
            List<Case> caseList = [SELECT Id,cc_isDocumentReceived__c,cc_isDocumentSent__c,cc_Signature_Verifier_Result__c FROM Case WHERE Id In: caseIdSetCompleted];
            for(Case xItem: caseList){
                xItem.cc_isDocumentReceived__c = false;
                xItem.cc_isDocumentSent__c = true;
            }
            update caseList;
        }
    }
}