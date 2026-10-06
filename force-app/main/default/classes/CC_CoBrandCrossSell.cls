/**
 *  #CH01# Added by ASHISH 02-01-2025 *** Class to create Cross selling products, once the Co-Branded Credit card is approved.
 * 
 */
public class CC_CoBrandCrossSell {

    public List<Case> crossSell_PremiumInvitation(Id crmAccountID, String customerFname, String customerLname){
        
        /*** Creating Premium Invitation case, once the Co-Branded Credit card is approved.  **/
        
        Id premiumInvRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Premium_Invitation').getRecordTypeId();
        List<Case> lstCaseCreate = new List<Case>();
        Case cs = new Case();   
        cs.Subject = 'Premium Invitation Application - Co-Brand Credit Card';
        cs.Description = 'Premium Invitation Application - Co-Brand Credit Card';
        cs.Origin = 'CRM';
        cs.Reason = 'Service';
        cs.Type = 'Premium Invitation Application'; 
        cs.ac_RequestedBy__c = 'Bank / CBB';
        cs.Case_Model__c = 'ila';
        cs.cc_Name_on_the_Card__c = customerFname +' '+customerLname;
        cs.Discount_Amount__c = Integer.valueOf(system.label.CoBranded_CrossSell_DiscountAmount);
        cs.Expiry_Days__c = Integer.valueOf(system.label.CoBranded_CrossSell_ExpiryDays);
        cs.RecordTypeId = premiumInvRecordTypeId;
        cs.OwnerId = system.Label.Invitation_temp_Queue;
        cs.Awaiting_Customer_Feedback__c = TRUE;
        cs.Sub_Status__c = 'Pending Customer';
        cs.ContactId = crmAccountID;
        cs.Card_Nature__c = 'Premium';
        lstCaseCreate.add(cs);
        
        return lstCaseCreate;          
    }
}