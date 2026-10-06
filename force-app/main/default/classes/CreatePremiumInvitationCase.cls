/*     Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 05-01-2025
*      Description : Creating Premium Invitation case from Co-brand Credit Card Application
*      Change History: 
				#CH01 : #Jahangeer Mohammed #08-07-2026# Added Logic for Ila White, Ila Black and Ila Black Metal Cards (NBA-16947)

*/ 

public class CreatePremiumInvitationCase {
    public static Case createPremiumCase(Account acc,String appReqCardType,String appNameOnCard){
        Id premiumInvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Invitation').getRecordTypeId();
        List<Case> cseList = new List<Case>();
        
        Case cse = new Case();
        cse.AccountId = acc.Id;
        cse.RecordTypeId = premiumInvRecordTypeId;
        if(appReqCardType == 'ILA_GULF_AIR_COBRAND_01'){
            cse.Subject = 'Premium Invitation Application - Co-Branded Credit Card';
        	cse.Description = 'Gulf Air Cross Sell Premium';
            cse.Discount_Amount__c = Integer.valueOf(System.Label.CROSS_SELLING_DISCOUNT);
        	cse.Expiry_Days__c  = Integer.valueOf(System.Label.CROSS_SELLING_EXPIRY);
        }
        else if(appReqCardType == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
            //CH01: Start
            //cse.Subject = 'Premium Invitation Application - Ila World Elite';
            cse.Subject = 'Premium Invitation Application - Ila Black';
        	//cse.Description = 'Ila World Elite Cross Sell Premium';
        	cse.Description = 'Ila Black Cross Sell Premium';
            //CH01: END
            cse.Discount_Amount__c = Integer.valueOf(System.Label.CROSS_SELLING_DISCOUNT_WORLD_ELITE);
        	cse.Expiry_Days__c  = Integer.valueOf(System.Label.CROSS_SELLING_EXPIRY_WORLD_ELITE);
        }
        else if(appReqCardType == 'WORLD_ELITE_CASHBACK_AND_REWARDS_02'){
            //CH01: Start
            //cse.Subject = 'Premium Invitation Application - Ila World Elite Metal';
            cse.Subject = 'Premium Invitation Application - Ila Black Metal';
        	//cse.Description = 'Ila World Elite Metal Cross Sell Premium';
        	cse.Description = 'Ila Black Metal Cross Sell Premium';
            //CH01: END
            cse.Discount_Amount__c = Integer.valueOf(System.Label.CROSS_SELLING_DISCOUNT_WORLD_ELITE_METAL);
        	cse.Expiry_Days__c  = Integer.valueOf(System.Label.CROSS_SELLING_EXPIRY_WORLD_ELITE_METAL);
        }
        
        cse.Origin = 'CRM';
        cse.Reason = 'Service';
        cse.Type = 'Premium Invitation Application';
        cse.Sub_Status__c = 'Pending Customer';
        cse.ac_RequestedBy__c = 'Bank / CBB';
        cse.Case_Model__c = 'ila';
        cse.Case_Nature__c = 'Premium';
        cse.Awaiting_Customer_Feedback__c = true;
        cse.BUA_Reason__c = 'Pending on customer response ';
        cse.cc_Name_on_the_Card__c = appNameOnCard;
        cse.OwnerId = system.Label.Invitation_temp_Queue;
        return cse;
    }

}