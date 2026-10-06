@isTest
public class loanPaymentPdfControllerTest {

    @isTest
    static void testCaseLoanPayment(){
    	
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',CustomerStatus__c=null,Subscription_Model__pc = 'alburaq',Archived__pc = false), 'TestFactoryDefaults.AccountDefaults',true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id, Case_Model__c = 'alburaq',isSubmitted__c = true), 'TestFactoryDefaults.CaseDefaults',true);

         CaseAnnex__c annex = new CaseAnnex__c(
                Case__c = testCase.Id,
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
           
        insert annex;
		String pageName = EncodingUtil.base64Encode(Blob.valueOf('case')); 
        String caseId = EncodingUtil.base64Encode(Blob.valueOf(testCase.Id));
        
        PageReference pageRef = new PageReference('/apex/MockPage');
        Test.setCurrentPage(pageRef);
 		ApexPages.currentPage().getParameters().put('pageName', pageName);
        ApexPages.currentPage().getParameters().put('caseId', caseId);
        Test.startTest();
        
        loanPaymentPdfController controller = new loanPaymentPdfController();
        System.assertNotEquals(null, controller.header.principleAmount, 'principleAmount must not be empty');
        System.assertNotEquals(null, controller.header.totalCostOfLoan, 'totalCostOfLoan must not be empty');
        
        if(controller.header.totalCostOfLoan != null){
            String formattedCurrency = controller.header.getFormattedTotalCostOfLoan();
            System.assertNotEquals(null, formattedCurrency, 'totalLoanAmount currency not set.');
        }
        
        if(controller.header.interestRate != null){
            String formattedCurrency = controller.header.getFormattedInterestRate();
            System.assertNotEquals(null, formattedCurrency, 'interestRate currency not set.');
        }
        
        if(controller.header.lifeInsuranceRate != null){
            String formattedCurrency = controller.header.getFormattedLifeInsuranceRate();
            System.assertNotEquals(null, formattedCurrency, 'lifeInsuranceRate currency not set.');
        }
        
        if(controller.header.apr != null){
            String formattedCurrency = controller.header.getFormattedApr();
            System.assertNotEquals(null, formattedCurrency, 'apr currency not set.');
        }
        
        if(controller.header.principleAmount != null){
            String formattedCurrency = controller.header.getFormattedPrincipleAmount();
            System.assertNotEquals(null, formattedCurrency, 'principleAmount currency not set.');
        }
        
        
        if(controller.header.monthlyInstallment != null){
            String formattedCurrency = controller.header.getFormattedMonthlyInstallment();
            System.assertNotEquals(null, formattedCurrency, 'monthlyInstallment currency not set.');
        }
        
        if(controller.header.cashInHand != null){
            String formattedCurrency = controller.header.getFormattedCashInHand();
            System.assertNotEquals(null, formattedCurrency, 'cashInHand currency not set.');
        }
        
        if(controller.header.totalInterest != null){
            String formattedCurrency = controller.header.getFormattedTotalInterest();
            System.assertNotEquals(null, formattedCurrency, 'totalInterest currency not set.');
        }
        
        if(controller.header.insuranceAmount != null){
            String formattedCurrency = controller.header.getFormattedInsuranceAmount();
            System.assertNotEquals(null, formattedCurrency, 'insuranceAmount currency not set.');
        }
        
        if(controller.header.administrationFees != null){
            String formattedCurrency = controller.header.getFormattedAdministrationFees();
            System.assertNotEquals(null, formattedCurrency, 'administrationFees currency not set.');
        }
        
        if(controller.header.administrationFeesVat != null){
            String formattedCurrency = controller.header.getFormattedAdministrationFeesVat();
            System.assertNotEquals(null, formattedCurrency, 'administrationFeesVat currency not set.');
        }
        
        if(controller.paymentsList != null && !controller.paymentsList.isEmpty()){
            if(controller.paymentsList[0].adminFeesVat != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedAdminFeesVat();
                System.assertNotEquals(null, formattedCurrency, 'adminFeesVat currency not set.');
            }
            
            if(controller.paymentsList[0].adminFeesFlat != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedAdminFeesFlat();
                System.assertNotEquals(null, formattedCurrency, 'adminFeesFlat currency not set.');
            }
            
            if(controller.paymentsList[0].outstandingAmount != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedOutstandingAmount();
                System.assertNotEquals(null, formattedCurrency, 'outstandingAmount currency not set.');
            }
            
            if(controller.paymentsList[0].monthlyInstallmentFull != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedMonthlyInstallmentFull();
                System.assertNotEquals(null, formattedCurrency, 'monthlyInstallmentFull currency not set.');
            }
            
            if(controller.paymentsList[0].monthlyInstallmentExcludingCharges != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedMonthlyInstallmentExcludingCharges();
                System.assertNotEquals(null, formattedCurrency, 'monthlyInstallmentExcludingCharges currency not set.');
            }
            
            if(controller.paymentsList[0].monthlyInsuranceFeesReducing != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedMonthlyInsuranceFeesReducing();
                System.assertNotEquals(null, formattedCurrency, 'monthlyInsuranceFeesReducing currency not set.');
            }
            
            if(controller.paymentsList[0].endingBalance != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedEndingBalance();
                System.assertNotEquals(null, formattedCurrency, 'endingBalance currency not set.');
            }
            
            if(controller.paymentsList[0].interestAmount != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedInterestAmount();
                System.assertNotEquals(null, formattedCurrency, 'interestAmount currency not set.');
            }
            
            if(controller.paymentsList[0].principalAmount != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedPrincipalAmount();
                System.assertNotEquals(null, formattedCurrency, 'principalAmount currency not set.');
            }
            
            if(controller.paymentsList[0].beginningBalance != null){
                String formattedCurrency = controller.paymentsList[0].getFormattedBeginningBalance();
                System.assertNotEquals(null, formattedCurrency, 'beginningBalance currency not set.');
            }
        }
        
    }
    
    @isTest
    static void testConstructor() {
  
        String accName = EncodingUtil.base64Encode(Blob.valueOf('TestAccount'));
        String customerId = EncodingUtil.base64Encode(Blob.valueOf('12345'));
        String selLoanId = EncodingUtil.base64Encode(Blob.valueOf('67890'));
        String regionName = EncodingUtil.base64Encode(Blob.valueOf('Bahrain'));
        String loanFacilityNumber = EncodingUtil.base64Encode(Blob.valueOf('Loan123'));
 		String pageName = EncodingUtil.base64Encode(Blob.valueOf('Account'));
        String isAlburaq = EncodingUtil.base64Encode(Blob.valueOf('false'));
        String scheduleType = EncodingUtil.base64Encode(Blob.valueOf('Schedule'));
        
        PageReference pageRef = new PageReference('/apex/MockPage');
        Test.setCurrentPage(pageRef);
 
        ApexPages.currentPage().getParameters().put('accName', accName);
        ApexPages.currentPage().getParameters().put('customerId', customerId);
        ApexPages.currentPage().getParameters().put('customerCIFNo', customerId);
        ApexPages.currentPage().getParameters().put('selLoanId', selLoanId);
        ApexPages.currentPage().getParameters().put('regionName', regionName);
        ApexPages.currentPage().getParameters().put('loanFacilityNumber', loanFacilityNumber);
 		ApexPages.currentPage().getParameters().put('pageName', pageName);
        ApexPages.currentPage().getParameters().put('isAlburaq', isAlburaq);
        ApexPages.currentPage().getParameters().put('scheduleType', scheduleType);
        Test.startTest();

        // Mock the response from the Loans_ServiceManagerHandler
        ApiConnection.Response mockResponse = new ApiConnection.Response();
        loanPaymentPdfController.PaymentData paymentData = new loanPaymentPdfController.PaymentData();
        paymentData.transactionType = 'Loan';
        paymentData.scheduleType = 'Monthly';
        paymentData.paymentDate = '2024-06-01';
        paymentData.settleDate = '2024-06-15';
        paymentData.outstandingAmount = 1000;
        mockResponse.responseData = new List<Object>{paymentData};
 
        loanPaymentPdfController controller = new loanPaymentPdfController();
        Test.stopTest();
 
        System.assertEquals('TestAccount', controller.decodedaccName);
        System.assertEquals('12345', controller.decodedcustomerId);
        System.assertEquals('67890', controller.decodedselLoanId);
        System.assertEquals('Bahrain', controller.decodedregionName);
        System.assertEquals('Loan123', controller.decodedloanFacilityNumber);
    }
}