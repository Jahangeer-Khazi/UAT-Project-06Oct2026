/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 05-03-2025
*       Change History: 
				#CH01 : #Jahangeer Mohammed #08-07-2026# Added Logic for Ila White, Ila Black and Ila Black Metal Cards (NBA-16947)

*/
public class CreatePremiumRetentionCase {
    public static Case createPremiumCase(Account acc, String appReqCardType, String appNameOnCard){
        Id premiumRetentionRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Retention').getRecordTypeId();
        List<Case> cseList = new List<Case>();
        
        Case cse = new Case();
        cse.AccountId = acc.Id;
        cse.RecordTypeId = premiumRetentionRecordTypeId;
        
        if(appReqCardType == 'ILA_GULF_AIR_COBRAND_01'){
             cse.Subject = 'Premium Retention Application - Co-Branded Credit Card';
        	 cse.Description = 'Gulf Air Cross Sell Premium Renewal Discount';
             cse.Discount_Amount__c = Integer.valueOf(System.Label.CROSS_SELLING_DISCOUNT);
             cse.Expiry_Days__c  = Integer.valueOf(System.Label.CROSS_SELLING_EXPIRY);
        }
        else if(appReqCardType == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
            //CH01: Start
            //cse.Subject = 'Premium Retention Application - Ila World Elite';
            cse.Subject = 'Premium Retention Application - Ila Black';
            //cse.Description = 'Ila World Elite Cross Sell Premium Renewal Discount';
            cse.Description = 'Ila Black Cross Sell Premium Renewal Discount';
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
        cse.Type = 'Premium Retention Application';
        cse.Sub_Status__c = 'Pending Customer';
        cse.ac_RequestedBy__c = 'Bank / CBB';
        cse.Case_Model__c = 'ila';
        cse.Case_Nature__c = 'Premium';
        cse.Waiting_for_customer_feedback__c = true;
        cse.BUA_Reason__c = 'Pending on customer response ';
        cse.cc_Name_on_the_Card__c = appNameOnCard;
        cse.OwnerId = system.Label.temp_Queue;
        cse.Premium_Substatus_Changed__c=system.today().addDays(Integer.valueOf(System.Label.CROSS_SELLING_EXPIRY));
        return cse;
    }

}