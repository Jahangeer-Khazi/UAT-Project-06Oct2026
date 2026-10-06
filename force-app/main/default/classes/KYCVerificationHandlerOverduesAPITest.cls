@isTest
public class KYCVerificationHandlerOverduesAPITest {
/*
        MOCK CLASS - SUCCESS RESPONSE
    */
    public class SuccessMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Success');

            return res;
        }
    }

    /*
        MOCK CLASS - FAILURE RESPONSE
    */
    public class FailureMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Internal Server Error');

            return res;
        }
    }

    @testSetup
    static void setupData() {

        // Create Account
        Account acc = new Account(LastName = 'Test Customer',PersonEmail = 'test@test.com',CIF__pc = 'CIF001',Region_Flag__pc = 'Bahrain', Subscription_Model__pc = 'ila');

        insert acc;

        // Record Type Id
        Id rtId = Schema.SObjectType.KYC_Verification__c.getRecordTypeInfosByDeveloperName().get('KYC_Verification').getRecordTypeId();

        // Create KYC Verification
        KYC_Verification__c kyc = new KYC_Verification__c(Account_Name__c = acc.Id,RecordTypeId = rtId,Subject__c = 'Test KYC',Type__c = 'KYC_PERIODIC_REVIEW',Overdue_Stage_Enable_L3__c = true,Case_Model__c = 'ila');

        insert kyc;
    }

    @isTest
    static void testUpdateOverdueStageFromFlowSuccess() {

        Test.setMock(HttpCalloutMock.class,new SuccessMock());

        KYC_Verification__c kyc = [SELECT Id FROM KYC_Verification__c LIMIT 1];

        KYCVerificationHandlerOverduesAPI.kycVerification wrapper = new KYCVerificationHandlerOverduesAPI.kycVerification();

        wrapper.kycId = kyc.Id;
        wrapper.apiStatus = 'PR_PENDING_IDV_S2';
        wrapper.overDueStage = 'Stage 2 – Block Debit Cards';

        List<KYCVerificationHandlerOverduesAPI.kycVerification> wrapperList = new List<KYCVerificationHandlerOverduesAPI.kycVerification>{wrapper};

        Test.startTest();

        KYCVerificationHandlerOverduesAPI.updateOverdueStageFromFlow(wrapperList);

        Test.stopTest();

        
    }

    @isTest
    static void testUpdateOverdueStageFromFlowFailure() {

        Test.setMock(HttpCalloutMock.class,new FailureMock());

        KYC_Verification__c kyc = [SELECT Id FROM KYC_Verification__c LIMIT 1];

        KYCVerificationHandlerOverduesAPI.kycVerification wrapper = new KYCVerificationHandlerOverduesAPI.kycVerification();

        wrapper.kycId = kyc.Id;
        wrapper.apiStatus = 'PR_PENDING_IDV_S2';
        wrapper.overDueStage = 'Stage 2 – Block Debit Cards';

        List<KYCVerificationHandlerOverduesAPI.kycVerification> wrapperList = new List<KYCVerificationHandlerOverduesAPI.kycVerification>{wrapper};

        Test.startTest();

        KYCVerificationHandlerOverduesAPI.updateOverdueStageFromFlow(wrapperList);

        Test.stopTest();

        
    }

}