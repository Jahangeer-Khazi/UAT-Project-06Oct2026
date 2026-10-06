/**
 *  #CH01# Added by Amina BENABDELKRIM 20-06-2022 *** to add new field (case model) with the value of subscription model
 * 
 */
public class PremiumHandler {

    public static void afterinsert(List<Premium_Retention_Request__c> premiumRetentions){

        Set<String> allCifs = new Set<String>();
        Map<String,Account> mapAccountDetailsPerCif = new Map<String,Account>();
        Id premiumInvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Invitation').getRecordTypeId();
        Id premiumRetentionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Retention').getRecordTypeId();
        List<Case> casesToCreate = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();

        for(Premium_Retention_Request__c premiumRetention:premiumRetentions){
            allCifs.add(premiumRetention.CIF__c);
        }

        //CH01 : Add Subscription_Model__pc on soql query
        for( Account acc : [SELECT Id,CIF__pc,Segment__pc,FirstName,LastName ,Subscription_Model__pc,
                (SELECT Id,RecordType.DeveloperName,Status FROM Cases WHERE RecordType.DeveloperName IN ('Premium_Retention','Premium_Invitation') AND Status != 'Closed' ) FROM Account WHERE CIF__pc IN: allCifs ]){
            mapAccountDetailsPerCif.put(acc.CIF__pc , acc);
        }

        for(Premium_Retention_Request__c premiumRetention:premiumRetentions){

            Account currentCustomer = mapAccountDetailsPerCif.get(premiumRetention.CIF__c);

            //CH01 : Start
            
            String caseModelValue;
            if(currentCustomer.Subscription_Model__pc=='alburaq'){
                caseModelValue='alburaq';
            }
            else{
                caseModelValue='ila';
            }
           
            //CH01 : End

            Decimal expiryDays = 0;
            Decimal discountAmount = 0;

            if(premiumRetention.Expiry_Days__c != null ){
                expiryDays = premiumRetention.Expiry_Days__c;
            }
            if(premiumRetention.Discount_Amount__c != null ){
                discountAmount = premiumRetention.Discount_Amount__c;
            }

            if(premiumRetention.Type__c == 'Retention' && currentCustomer.Segment__pc != 'Regular' ){
                //check if there is no existing open “Premium Retention“ case under the current cif
                if( !checkOpenRetentionCases(currentCustomer) ){
                    Case cs = new Case(Subject='Premium Retention Application',Description='Premium Retention Application',
                                   Origin='App',Reason='Service',Type='Premium Retention Application',
                                   ac_RequestedBy__c='Bank / CBB',
                                   Case_Model__c=caseModelValue, // CH01
                                   cc_Name_on_the_Card__c=currentCustomer.FirstName +' '+currentCustomer.LastName,
                                   Expiry_Days__c = expiryDays,
                                   Discount_Amount__c = discountAmount,
                                   RecordTypeId = premiumRetentionRecordTypeId,
                                   OwnerId = system.Label.Invitation_temp_Queue,
                                   Awaiting_Customer_Feedback__c = TRUE,
                                   Sub_Status__c = 'Pending Customer', AccountId=currentCustomer.Id);

                    casesToCreate.add(cs);
                }
            }
            if(premiumRetention.Type__c == 'Invitation' && currentCustomer.Segment__pc != 'Premium'){
                //check if there is no existing open “Premium Invite“ case under the current cif
                if( !checkOpenInvitationCases(currentCustomer) ){
                    Case cs = new Case(Subject='Premium Invitation Application',Description='Premium Invitation Application',
                               Origin='App',Reason='Service',Type='Premium Invitation Application',
                               ac_RequestedBy__c='Bank / CBB',
                               Case_Model__c=caseModelValue, // CH01
                               cc_Name_on_the_Card__c=currentCustomer.FirstName +' '+currentCustomer.LastName,
                                Discount_Amount__c = discountAmount,
                               Expiry_Days__c = expiryDays,
                               RecordTypeId=premiumInvRecordTypeId,
                               OwnerId = system.Label.Invitation_temp_Queue,
                               Awaiting_Customer_Feedback__c = TRUE,
                               Sub_Status__c='Pending Customer', AccountId=currentCustomer.Id);

                    casesToCreate.add(cs);
                }
            }
            if(premiumRetention.Type__c == 'Retention Rollback'){
                //check if there is an existing open “Premium Retention“ case under the current cif
                if( checkOpenRetentionCases(currentCustomer) ){
                    for(Case caseRec : currentCustomer.Cases){
                        if( caseRec.RecordType.DeveloperName == 'Premium_Retention' ){
                            caseRec.Sub_Status__c='Rolled Back by Bank';
                            if(!test.isRunningTest() ){
                                PremiumRetentionController.updateDiscountRequest(caseRec.Id,null,null,system.now(),null,null,'Closed','RETENTION');
                            }
                            casesToUpdate.add(caseRec);
                        }
                    }
                }
            }
            if(premiumRetention.Type__c == 'Invitation Rollback'){
                //check if there is an existing open “Premium Invite“ case under the current cif
                if( checkOpenInvitationCases(currentCustomer) ){
                    for(Case caseRec : currentCustomer.Cases){
                        if( caseRec.RecordType.DeveloperName == 'Premium_Invitation' ){
                            caseRec.Sub_Status__c='Rolled Back by Bank';
                            if(!test.isRunningTest() ){
                                PremiumRetentionController.updateDiscountRequest(caseRec.Id,null,null,system.now(),null,null,'Closed','INVITATION');
                            }
                            casesToUpdate.add(caseRec);
                        }
                    }
                }
            }
        }

        if( casesToCreate.size() > 0 ){
            insert casesToCreate;
        }

        if( casesToUpdate.size() > 0 ){
            update casesToUpdate;
        }

    }

    public static Boolean checkOpenRetentionCases(Account acc){
        if( acc!= null && acc.Cases != null && acc.Cases.size()>0 ){
            for(Case caseRec : acc.Cases){
                if( caseRec.RecordType.DeveloperName == 'Premium_Retention' ){
                    return true;
                }
            }
        }
        return false;
    }

    public static Boolean checkOpenInvitationCases(Account acc){
        if( acc!= null && acc.Cases != null && acc.Cases.size()>0 ){
            for(Case caseRec : acc.Cases){
                if( caseRec.RecordType.DeveloperName == 'Premium_Invitation' ){
                    return true;
                }
            }
        }
        return false;
    }
}