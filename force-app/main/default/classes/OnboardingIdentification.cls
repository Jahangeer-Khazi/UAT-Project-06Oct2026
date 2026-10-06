/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 10/10/2024
*       Change History: 
*/
public class OnboardingIdentification {
    
    @InvocableMethod(label='Update Field on Identification Request' description='Update Identification Field Update' callout=true )
    public static void updateIdentificationFieldFromFlow(List<UpdateIdentificationCaseField> updateIden){
        UpdateIdentificationCaseField upgCard = updateIden.get(0);
        System.debug('Case Id Coming from Flow:'+upgCard.caseId);
        List<Case> cseList = [Select Id, Status, Origin, Sales_Call_Log__c,Account.ID_Validation_Status__pc,Account.Nationality__pc,Account.Passport_Expiry_Date__pc,Account.Residency_Permit_Expiry__pc,
                              Account.Place_of_Birth__pc from Case where Id =: upgCard.caseId];
        List<Case> cseFieldUpdate = new List<Case>();
        if(cseList.size()>0){
            for(Case c : cseList){
                String dynamicText = '';
                if(c.Account.ID_Validation_Status__pc != 'APPROVED_VERIFIED' && c.Account.ID_Validation_Status__pc != 'MANUAL_ENTRY_APPROVED'){
                    System.debug('Coming in 1 condition');
                    dynamicText = '&#8226; A copy of your valid CPR or valid Bahraini Passport<br><br>&nbsp;&nbsp;';
                }
                if(c.Account.Nationality__pc != 'BH' && (c.Account.Passport_Expiry_Date__pc < System.today() || c.Account.Passport_Expiry_Date__pc == null || c.Account.Place_of_Birth__pc == null)) {
                    System.debug('Coming in 2 condition');
                    dynamicText = dynamicText + '&#8226; Valid Passport<br><br>&nbsp;&nbsp;';
                }
                if(c.Account.Nationality__pc != 'BH' && (c.Account.Residency_Permit_Expiry__pc < System.today() || c.Account.Residency_Permit_Expiry__pc == null)){
                    System.debug('Coming in 3 condition');
                    dynamicText = dynamicText + '&#8226; Valid Residency Permit<br>';
                }
                c.Sales_Call_Log__c = dynamicText;


                 // omar change start
                if(c.Status == 'In Progress' && c.Origin == 'eKey'){
                    c.OwnerId = System.Label.Service_Centre_Onboarding_Queue;
                    c.Awaiting_Customer_Feedback__c = true;
                }
                // omar - end
                cseFieldUpdate.add(c);
            }
        }
        if(cseFieldUpdate.size()>0){
            upsert cseFieldUpdate;
        }
    }
    public class UpdateIdentificationCaseField{
        @InvocableVariable(label='CaseId' description='the Id of the Case' required=true)
        public String caseId;
    }
    
}