/**
 * @author Jayanth Manickam
 * @date 02/12/2024
 */
@isTest
public class IDVVerificationServiceTest {
    
     private static ApiConnection con = new ApiConnection();
      @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain',Subscription_Model__pc='ila'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Internal_Case').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='ID&V Verification',Sub_Type__c='Change Mobile Number', Case_Nature__c='Account Maintenance'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    
    @isTest
    public static void getVerificationHistoryTest(){   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK05_IDVVerificationServices());
        account acc1=[Select Id from account limit 1];
        IDVVerificationService.getVerificationHistory(acc1.Id);
        MCK05_IDVVerificationServices mck = new MCK05_IDVVerificationServices();
        Test.stopTest();
    }
    
    @isTest
    public static void UpdateFraudIDVStatusTest(){   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK05_IDVVerificationServices());
        account acc1=[Select Id from account limit 1];
        Case cs= [Select Id, Fraud_Results__c from case limit 1];
        cs.Fraud_Results__c ='Confirm Fraud';
        cs.OwnerId=System.Label.Frauds_Queue;
        update cs;
        List<String> cslst = New List<String>{String.valueOf([Select Id from case limit 1].Id)};
        
        IDVVerificationService.idvVerificationStatus(cslst);
        MCK05_IDVVerificationServices mck = new MCK05_IDVVerificationServices();
        Test.stopTest();
    }
    @isTest
    public static void UpdateCanceledIDVStatusTest(){   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK05_IDVVerificationServices());
        account acc1=[Select Id from account limit 1];
        Case cs= [Select Id, Fraud_Results__c from case limit 1];
        cs.Fraud_Results__c ='Cancel Request';
        cs.OwnerId=System.Label.Frauds_Queue;
        update cs;
        List<String> cslst = New List<String>{String.valueOf([Select Id from case limit 1].Id)};     
        IDVVerificationService.idvVerificationStatus(cslst);
        MCK05_IDVVerificationServices mck = new MCK05_IDVVerificationServices();
        Test.stopTest();
    }
    @isTest
    public static void UpdateSkippedIDVStatusTest(){   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK05_IDVVerificationServices());
        account acc1=[Select Id from account limit 1];
        Case cs= [Select Id, Fraud_Results__c,sub_Type__c from case limit 1];
        cs.sub_Type__c='Login from Unbound Device';
        cs.Fraud_Results__c ='Skip ID&V Next Login';
        cs.OwnerId=System.Label.Frauds_Queue;
        update cs;
        List<String> cslst = New List<String>{String.valueOf([Select Id from case limit 1].Id)}; 
        IDVVerificationService.idvVerificationStatus(cslst);
        MCK05_IDVVerificationServices mck = new MCK05_IDVVerificationServices();
        Test.stopTest();
    }
      
    @isTest
    public static void UpdateCompletedIDVStatusTest(){   
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK05_IDVVerificationServices());
        account acc1=[Select Id from account limit 1];
        Case cs= [Select Id, Fraud_Results__c from case limit 1];
        cs.cc_Contact_Centre_Result__c ='Customer Contacted';
        cs.OwnerId=System.Label.Contact_Center_Internal;
        update cs;
        List<String> cslst = New List<String>{String.valueOf([Select Id from case limit 1].Id)}; 
        IDVVerificationService.idvVerificationStatus(cslst);
        MCK05_IDVVerificationServices mck = new MCK05_IDVVerificationServices();
        Test.stopTest();
    }
     @isTest
    public static void UpdateSkippedIDVStatusLoanTest(){   
        Test.startTest();
        Case testCase2 =createTestCase('Documents Uploaded', true, 'Pending', 'Pending Offer Acceptance');
        Test.setMock(HttpCalloutMock.class, new MCK05_IDVVerificationServices());
        account acc1=[Select Id from account limit 1];
        Case cs= [Select Id, Fraud_Results__c,sub_Type__c from case where Type='ID&V Verification' limit 1];
        cs.sub_Type__c='Personal Loan / Finance';
        cs.Fraud_Results__c ='Skip ID&V Next Login';
        cs.ParentId=testCase2.Id;
        cs.OwnerId=System.Label.Frauds_Queue;
        update cs;
        List<String> cslst = New List<String>{String.valueOf([Select Id from case where Type='ID&V Verification' limit 1].Id)}; 
        IDVVerificationService.idvVerificationStatus(cslst);
        MCK05_IDVVerificationServices mck = new MCK05_IDVVerificationServices();
        Test.stopTest();
    }
    
         private static Case createTestCase(String contactCentreResult, Boolean haveCreditCard, String status, String subStatus) {
        return createTestCase(contactCentreResult, haveCreditCard, status, subStatus, null);
    }

    private static Case createTestCase(String contactCentreResult, Boolean haveCreditCard, String status, String subStatus, String controlType) {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        
        Account testAccount=[Select Id,PersonContactId From ACCOUNT];
        Case testCase = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = acRecordTypeId,
                ContactId = testAccount.PersonContactId,
                AccountId = testAccount.id, 
                Case_Model__c = 'ila',
                Type = 'New Loan / Finance Application', 
                Sub_Type__c = 'New Loan / Finance Application Request', 
                AIR_HaveCreditCard__c = haveCreditCard,
                cc_Service_Centre_Result__c = 'Return to Pre-Screener', 
                Resend_DocuSign__c = 'Email', 
                cc_Contact_Centre_Result__c = contactCentreResult,
                Status = status,
                Sub_Status__c = subStatus,
                cc_Control_Type__c = controlType,
                Region_Flag__c = 'Bahrain'
            ), 
            'TestFactoryDefaults.CaseDefaults',
            true
        );
        return testCase;
    }

    private static void createCaseAnnexRecords(List<Case> caseRecords) {
        List<CaseAnnex__c> caseAnnexes = new List<CaseAnnex__c>();

        for(Case caseRecord : caseRecords) {
            CaseAnnex__c annex = new CaseAnnex__c(
                Case__c = caseRecord.Id,
                cx_ln_Product__c = 'Unsecured',
                cx_ln_Requested_Loan_Finance_Amount__c = 10000,
                cx_ln_Requested_Duration_Months__c = 12,
                cx_ln_Monthly_Instalment__c = 900,
                cx_ln_Approved_Loan_Amount__c = 10000,
                cx_ln_ApprovedInterestProfitRateReducing__c = 5.0,
                cx_ln_Approved_Installment_Amount__c = 900,
                cx_ln_Approved_Duration_Months__c = 12,
                cx_ln_APR__c = 6.0,
                cx_ln_Requested_Processing_Fees__c = 100,
                cx_ln_Requested_Vat_Processing_Fees__c = 10,
                cx_ln_Approved_First_installment_date__c = Date.today().addDays(30),
                cx_ln_Approved_Maturity_Date__c = Date.today().addDays(395),
                cx_ln_Approved_Insurance_Premium__c = 'Upfront',
                cx_ln_Approved_insurance__c = true,
                cx_ln_ApprovedProcessing_Fee_Type__c = 'Upfront',
                cx_ln_Approved_Insurance_Amount__c = 50,
                cx_ln_RequireSalaryCertificate__c = false,
                cx_ln_Cross_Selling_PreScreening_Result__c = 'Approve',
                cx_ln_Cross_Selling_Evaluator_Result__c = 'Approve',
                cx_ln_Cross_Selling_Verifier_Result__c = 'Approve',
                cx_ln_Cross_Selling_Approver_Result__c = 'Approve',
                cx_ln_SimulationReference__c = 'TEST_SIM_REF'
            );
            caseAnnexes.add(annex);
        }

        insert caseAnnexes;
    }
}