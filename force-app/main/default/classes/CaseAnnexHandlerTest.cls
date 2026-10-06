@isTest
public class CaseAnnexHandlerTest {
    // Utility method to create a Case with required lookups
    private static Case createTestCase(Boolean isVerified) {
        Case c = new Case(
            Subject = 'Test Case'
        );
        insert c;

        // Set lookup based on required flag
        if(isVerified){
            c.cc_Credit_Verified_by__c = UserInfo.getUserId();
        } else{
            c.cc_Credit_Pre_Screening_by__c = UserInfo.getUserId();
        }
        update c;
		return c;
    }
    @isTest
    static void testUnsecuredApproveBySameUserUnsecure() {
        // Create Case (Verified_By lookup for Unsecured logic)
        Case c = createTestCase(true);
        System.debug('Case Created:'+c);

        // Create Old CaseAnnex Record
        CaseAnnex__c oldAnnex = new CaseAnnex__c(Case__c = c.Id,cx_ln_Product__c = 'Unsecured',cx_ln_Credit_Approval_Result__c = null);
        insert oldAnnex;
        
		// Create New CaseAnnex Record for update scenario
        CaseAnnex__c newAnnex = oldAnnex.clone(true, true, false, false);
        newAnnex.cx_ln_Credit_Approval_Result__c = 'Approve';
        
 		Map<Id, CaseAnnex__c> oldMapValues = new Map<Id, CaseAnnex__c>{ oldAnnex.Id => oldAnnex };
        Map<Id, CaseAnnex__c> newMapValues = new Map<Id, CaseAnnex__c>{ newAnnex.Id => newAnnex };

        Test.startTest();
        CaseAnnexHandler.loanApproverApproved(newMapValues, oldMapValues);
        Test.stopTest();

        
    }
     @isTest
    static void testUnsecuredApproveBySameUserSecure() {
        // Create Case (Verified_By lookup for Unsecured logic)
        Case c = createTestCase(false);

        // Create Old CaseAnnex Record
        CaseAnnex__c oldAnnex = new CaseAnnex__c(Case__c = c.Id,cx_ln_Product__c = 'Secured',cx_ln_Credit_Approval_Result__c = null);
        insert oldAnnex;
        
		// Create New CaseAnnex Record for update scenario
        CaseAnnex__c newAnnex = oldAnnex.clone(true, true, false, false);
        newAnnex.cx_ln_Credit_Approval_Result__c = 'Approve';
        
		Map<Id, CaseAnnex__c> oldMapValues = new Map<Id, CaseAnnex__c>{ oldAnnex.Id => oldAnnex };
        Map<Id, CaseAnnex__c> newMapValues = new Map<Id, CaseAnnex__c>{ newAnnex.Id => newAnnex };

        Test.startTest();
        CaseAnnexHandler.loanApproverApproved(newMapValues, oldMapValues);
        Test.stopTest();
	}
    
}