@isTest
public class Loans_ServiceManagerHandlerTest {
    
    @testSetup
    static void setup() {
        Case testCase = createTestCase();
    }

    private static Case createTestCase() {
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('LoanFinanceServiceRequest').getRecordTypeId();
        Account testAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456', CustomerStatus__c=null, Archived__pc=false, Region_Flag__c = 'Bahrain' ,Subscription_Model__pc = 'ila',x_canary__pc='cbs'), 'TestFactoryDefaults.AccountDefaults', true);
        Case testCase = (Case)TestDataFactory.createSObject(new Case(RecordTypeId=acRecordTypeId, ContactId=testAccount.PersonContactId, AccountId=testAccount.Id), 'TestFactoryDefaults.CaseDefaults', true);
        Case testCase2 = (Case)TestDataFactory.createSObject(new Case(ContactId=testAccount.PersonContactId, AccountId=testAccount.Id), 'TestFactoryDefaults.CaseDefaults', true);
        
        CaseAnnex__c testRecord = new CaseAnnex__c(Case__c = testCase.Id, cx_ln_Product__c = 'Unsecured' );
        insert testRecord;
        
        CaseAnnex__c testRecord2 = new CaseAnnex__c(Case__c = testCase2.Id,cx_ln_Product__c = 'Unsecured');
        insert testRecord2;
        
        return testCase;
    }
    
    @isTest
    static void testLoadLoanTransactions() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        String regionName = 'bahrain';
        String searchParametersJson = '';
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.loadLoanTransactions(customerId, searchParametersJson, regionName);
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetLoanPaymentsSchedule() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        String regionName = 'bahrain';
        String searchParametersJson = '';
        Test.startTest();
        Loans_ServiceManagerHandler.APIResponse response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(testCase.Id,customerId, searchParametersJson, regionName,true);
        Test.stopTest();
        
    }
    
    @isTest
    static void testLoansOptionsAPI() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        String regionName = 'bahrain';
        String searchParametersJson = '';
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.callLoansOptionsAPI(customerId,'ila');
        Test.stopTest();   
    }
    
    @isTest
    static void testLoanApplicationApi() { 
    	Case testCase = [SELECT Id, Region_Flag__c, AccountId, Type, Product_Type__c, Customer_CIF__c, Case_Model__c, Card_Product_Configuration_Id__c, cc_Employment_Status__c,
                          cc_Employer_Name__c, cc_Monthly_Income__c, cc_Residence_Occupancy_Status__c, 
                          cc_Number_of_Years_at_Current_Residence__c, cc_Marital_Status__c, cc_Number_of_Dependents__c, cc_Academic_Qualifications__c, 
                         cc_Friend_s_Contact_Number__c, cc_Friend_s_Name__c,cc_Use_Current_Address__c,ccol_Hold_Account_IBAN__c,
                         cc_Number_years_at_current_residence_jo__c,caseNumber,ccol_Hold_Account__c,ccol_Hold_Amount__c,
                         ccol_Hold_Account_Balance__c,Last_Api_Call_Status__c,Loan_Application_ID__c,External_Id__c,
                         ccol_Hold_Reference_Number__c,
                         Extra_information__c, Customer_Segment__c, cc_Nationality__c FROM Case LIMIT 1];
        
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.createLoanApplicationApi(testCase);
        Test.stopTest();   
    }
    
    @isTest
    static void testUserApplicationInfoAPI() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        String regionName = 'bahrain';
        String searchParametersJson = '';
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.getUserApplicationInfoAPI(customerId,'','ila');
        Test.stopTest();   
    }
    
    @isTest
    static void testPopulateAppFulfillmentIdAPI() {
    	Case testCase = [SELECT Id, Region_Flag__c,Customer_CIF__c,Case_Model__c,Loan_Application_ID__c,
                         Card_Product_Configuration_Id__c,Last_Api_Call_Status__c,accountId,Type FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        String regionName = 'bahrain';
        String searchParametersJson = '';
        Test.startTest();
        String response = Loans_ServiceManagerHandler.populateAppFulfillmentIdAPI(testCase);
        Test.stopTest();   
    }
    
    @isTest
    static void testGetExistingLiabilitiesAPI() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.getExistingLiabilitiesAPI(customerId,'ila',null,null,null);
        Test.stopTest();   
    }
    
    @isTest
    static void testUpdateLoanApplicationApi() {
    	Case testCase = [SELECT Id, Region_Flag__c,Customer_CIF__c,Case_Model__c,Account.x_canary__pc,
                         Card_Product_Configuration_Id__c,accountId,Type FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        Test.startTest();
        HttpResponse response = Loans_ServiceManagerHandler.updateLoanApplicationApi(testCase,new Map<String, Object>());
        Test.stopTest();   
    }
    
    @isTest
    static void testGetCustomerProductsAPI() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.getCustomerProductsAPI(customerId,'ila');
        Test.stopTest();   
    }
    
    @isTest
    static void testGetLoanCalculatorMatrixAPI() {
    	Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        String customerId = testCase.Customer_CIF__c;
        Test.startTest();
        ApiConnection.Response response = Loans_ServiceManagerHandler.getLoanCalculatorMatrixAPI(customerId,'ila');
        Test.stopTest();   
    }
    
    @isTest
    static void testCreateDocuSignEnvelope() {
    	/*Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
        
        Test.startTest();
        Loan_DocuSignEnvelopeReqWrapper requestWrapper = new Loan_DocuSignEnvelopeReqWrapper();
        requestWrapper.cif = testCase.Customer_CIF__c;
        requestWrapper.caseId = testCase.Id;
        requestWrapper.channel = 'Email';
        requestWrapper.caseModel = 'ila';
        Loan_DocuSignEnvelopeResponseWrapper resp = Loans_ServiceManagerHandler.createDocuSignEnvelope(requestWrapper);
        Test.stopTest();*/  
    }
    
    
    @isTest
    static void testValidateGlobalVariables(){
        Loans_ServiceManagerHandler obj = new Loans_ServiceManagerHandler();
        Loans_ServiceManagerHandler.numberToWordsUtilsClass util = new Loans_ServiceManagerHandler.numberToWordsUtilsClass();
        String num1 = util.numberToWords(0);
        String num2 = util.numberToWords(1250);
    }
    
    
    
    @isTest
    static void testThowException(){
        try {
        	Loans_ServiceManagerHandler.thowException('Invalid Error');    
        }
        catch(Exception ex){
         	System.debug(ex.getMessage());   
        }
    }
    
    @isTest
     static void testSetSystemAction() {
         Case testCase = [SELECT Id, Customer_CIF__c, AccountId FROM Case LIMIT 1];
         String reqBody = '{"request": "body"}';
         String resBody = '{"response": "body"}';
         String path = '/api/v1/test';
         String method = 'POST';
         Id caseId = testCase.Id;
         String custId = testCase.Customer_CIF__c;
         Id accId = testCase.AccountId;
         Integer statCode = 200;
         String strAction = 'TestAction';
         String strType = 'TestType';

         Test.startTest();
         System_Action__c action = Loans_ServiceManagerHandler.setSystemAction(reqBody, resBody, path, method, caseId, custId, accId, statCode, strAction, strType);
         Test.stopTest();

         System.assertNotEquals(null, action, 'Expected action to be not null');
         System.assertEquals(strAction, action.Action__c, 'Expected Action to match');
         System.assertEquals(strType, action.Type__c, 'Expected Type to match');
     }
    
    
//     @isTest  
//     static void testLoadLoanTransactions() {
//         Case testCase = [SELECT Id, Customer_CIF__c FROM Case LIMIT 1];
//         String customerId = testCase.Customer_CIF__c;
//         String searchParametersJson = '{ "id": "1234", "offSet": 0,"pageSize": 50,"fromDate": "2023-06-24","toDate": "2024-06-25","debitCreditIndicator": "ALL"}';
//         String regionName = 'bahrain';

//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//       //  mockResponse.setBody('{"data": {"transactions": [{"transactionDate": "2024-06-22T00:00:00.000Z"}, {"transactionDate": "2024-06-21T00:00:00.000Z"}]}}');

//         Test.startTest();
//         ApiConnection.Response response = Loans_ServiceManagerHandler.loadLoanTransactions(customerId, searchParametersJson, regionName);
//         Test.stopTest();

//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
//         List<Object> transactions = (List<Object>)response.responseData;
//      }

//     @isTest
//     static void testSetSystemAction() {
//         Case testCase = [SELECT Id, Customer_CIF__c, AccountId FROM Case LIMIT 1];
//         String reqBody = '{"request": "body"}';
//         String resBody = '{"response": "body"}';
//         String path = '/api/v1/test';
//         String method = 'POST';
//         Id caseId = testCase.Id;
//         String custId = testCase.Customer_CIF__c;
//         Id accId = testCase.AccountId;
//         Integer statCode = 200;
//         String strAction = 'TestAction';
//         String strType = 'TestType';

//         Test.startTest();
//         System_Action__c action = Loans_ServiceManagerHandler.setSystemAction(reqBody, resBody, path, method, caseId, custId, accId, statCode, strAction, strType);
//         Test.stopTest();

//         System.assertNotEquals(null, action, 'Expected action to be not null');
//         System.assertEquals(strAction, action.Action__c, 'Expected Action to match');
//         System.assertEquals(strType, action.Type__c, 'Expected Type to match');
//     }
    
//     @isTest
//     static void testThrowException() {
//         Test.startTest();
//         try {
//             Loans_ServiceManagerHandler.thowException('Test exception');
//             System.assert(false, 'Exception should have been thrown');
//         } catch (AuraHandledException e) {
//             System.assertEquals('Test exception', e.getMessage(), 'Expected exception message to be set');
//         }
//         Test.stopTest();
//     }
    
//     @isTest
//     static void testCallGetLoanPaymentsSchedule() {
//         Case testCase = [SELECT Id, Customer_CIF__c, AccountId, Account.CIF__pc, Account.Region_Flag__c, Account.Subscription_Model__pc FROM Case LIMIT 1];
//         String customerId = testCase.Account.CIF__pc;
//         String searchParametersJson = '{"arrangementId":"1234","loanFacilityNumber":"AA23341Q80J1","type":"Schedule"}';
//         String body = '{"meta": {"code": "LOAN-2300", "message": "Successfully retrieved loan payment schedules."}, "data": [{"outstandingAmount": -9552.967, "paymentDate": "2023-10-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "Settled", "settleDate": "2023-10-20"}, {"outstandingAmount": -9174.431, "paymentDate": "2023-11-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -8792.741, "paymentDate": "2023-12-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -8407.87, "paymentDate": "2024-01-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -8019.792, "paymentDate": "2024-02-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -7628.48, "paymentDate": "2024-03-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -7233.907, "paymentDate": "2024-04-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -6836.046, "paymentDate": "2024-05-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -6434.869, "paymentDate": "2024-06-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -6030.349, "paymentDate": "2024-07-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -5622.458, "paymentDate": "2024-08-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -5211.168, "paymentDate": "2024-09-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -4796.45, "paymentDate": "2024-10-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -4378.276, "paymentDate": "2024-11-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -3956.618, "paymentDate": "2024-12-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -3531.446, "paymentDate": "2025-01-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -3102.731, "paymentDate": "2025-02-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -2670.443, "paymentDate": "2025-03-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -2234.553, "paymentDate": "2025-04-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -1795.03, "paymentDate": "2025-05-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -1351.845, "paymentDate": "2025-06-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -904.966, "paymentDate": "2025-07-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": -454.363, "paymentDate": "2025-08-20", "totalAmount": 458.144, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}, {"outstandingAmount": 0, "paymentDate": "2025-09-20", "totalAmount": 458.149, "transactionType": "Installment", "scheduleType": "FUTURE", "settleDate": ""}]}';

//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//         mockResponse.setStatus('OK');
//         mockResponse.setBody(body);

//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));
//         System.debug('customerId >> '+customerId + 'searchParametersJson >> '+searchParametersJson);
//         ApiConnection.Response response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(customerId, searchParametersJson);
//         Test.stopTest();
 
//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
//            if (response.responseData != null) {
//         Map<String, Object> responseData = (Map<String, Object>)response.responseData;
//         List<Object> schedule = (List<Object>)responseData.get('data');
      
//     }
//     }

//     @isTest
//     static void testCallLoansOptionsAPI() {
//         Case testCase = [SELECT Id, Customer_CIF__c, AccountId, Case_Model__c, Account.CIF__pc FROM Case LIMIT 1];
//         String customerId = testCase.Account.CIF__pc;
//         String caseModel = testCase.Case_Model__c;
 
//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//         mockResponse.setBody('{"meta":{"code":"200","message":"Success"},"data":{"currentLoans":[{"arrangementId":"1234","loanFacilityNumber":"AA23341Q80J1","loanProductConfigurationId":"5678","productType":"Personal Loan","productNature":"Installment Loan","status":"Active","tenor":"12 months","totalInstallments":12,"paidInstallments":6,"principalLoanAmount":5000,"loanOutstandingAmount":2500,"totalPaidAmount":2500,"monthlyInstallment":250,"payOffAmount":2500,"loanStartDate":"2023-01-01","loanMaturityDate":"2023-12-31","interestRate":"5%","apr":"5.25%","insurance":100,"fee":50,"vat":10,"applicationsubmissionDateTime":"2023-01-01T08:00:00Z","cashInHand":3000,"mainActions":[{"mainAction":"Repay","status":"Available","sortOrder":1}]},{"arrangementId":"5678","loanProductConfigurationId":"9876","productType":"Mortgage","productNature":"Fixed-rate","status":"Overdue","tenor":"24 months","totalInstallments":24,"paidInstallments":12,"principalLoanAmount":10000,"loanOutstandingAmount":5000,"totalPaidAmount":5000,"monthlyInstallment":250,"payOffAmount":5000,"loanStartDate":"2022-06-01","loanMaturityDate":"2024-05-31","interestRate":"4%","apr":"4.25%","insurance":150,"fee":75,"vat":15,"applicationsubmissionDateTime":"2022-06-01T10:30:00Z","cashInHand":6000,"mainActions":[{"mainAction":"Extend","status":"Available","sortOrder":1}]}],"pendingLoans":[{"applicationId":"ABCD1234","loanProductConfigurationId":"EFGH5678","productType":"Auto Loan","productNature":"Lease","status":"Pending Approval","subStatus":"Credit Verification","amount":"15000","currency":"USD","tenor":"36 months","applicationsubmissionDateTime":"2023-02-15T14:45:00Z","cashInHand":"8000","employmentStatus":"Employed","proofOfNewAdress":"Utility Bill","infinityPreScreener":{"cprNumber":"123456789","cprExpiryDate":"2024-05-31","passportNumber":"P123456","passportExpiryDate":"2023-12-31","residencePermitNo":"RP987654","residencePermitExpiryDate":"2023-06-30","sameResidenceAddress":true,"employmentStatus":"Employed","employerBusinessName":"ABC Corp","employerBusinessAddressHouseFlatNumber":"123","employerBusinessAddressBuilding":"Tower A","employerBusinessAddressStreetRoadNo":"Main Street","employerBusinessAddressBlockNo":"Block B","employerBusinessAddressCity":"Cityville","employerBusinessAddressCountry":"USA","occupation":"Software Engineer","lengthOfServiceYears":"5","crLicenseNumber":"CR123456","crExpiryDate":"2023-12-31","businessOperationsStartingDate":"2010-01-01","businessSector":"Technology","businessNatureType":"Private Limited","totalInternalLoans":"2","totalConsumerLoans":"1","totalMortgageLoans":"0","totalCreditCards":"2","totalGovernmentLoans":"0","otherDeductions":"50","totalCurrentObligations":"500","totalObligations":"800","totalCreditExposure":"1500","creditBureauScore":"750","creditBureauRiskRating":"Low","basicSalary":"6000","fixedAllowances":"1000","variableAllowances":"500","businessIncome":"3000","totalApprovedIncome":"10500","finalTotalObligations":"600","finalDBR":"0.57","salaryTransfertoIla":true,"blacklisted":false,"preScreenerDeclineReason":"Insufficient Income","otherPreScreenerDeclineReason":"Not Enough Work Experience","creditPreScreeningComments":"Customer has a good credit history","creditPreScreeningResult":"Approved","creditPreScreeningResultDateAndTime":"2023-02-20T15:30:00Z","creditPreScreeningResultUpdatedBy":"Credit Analyst"},"infinityCreditEvaluator":{"hasExistingLoan":false,"approvedLoanAmount":"15000","approvedLoanDuration":"36 months","approvedLoanMonthlyInstalment":"500","approvedInterestRate":"4.5%","approvedAPR":"4.75%","approvedInsuranceAmount":"100","approvedProcessingFees":"50","approvedVatProcessingFees":"10","approvedFirstPaymentDate":"2023-02-28","approvedMaturityDate":"2026-02-28","approvedCashInHand":"8000","approvedLiabilities":"0","commodity":"Auto","approvedEmploymentStatus":"Employed","deviationOneType":"Income","otherDeviationOneType":"Additional income not considered","deviationTwoType":"Credit Score","otherDeviationTwoType":"Slightly lower credit score","evaluatorDeclineReason":"","otherEvaluatorDeclineReason":"","creditExceptions":"","creditEvaluationComments":"Positive credit history, stable employment","creditEvaluationResult":"Approved","creditEvaluationResultDateAndTime":"2023-02-15T15:30:00Z","creditEvaluationResultUpdatedBy":"Credit Analyst1"},"infinityCreditVerifier":{"customerContacted":true,"customerFriendContacted":true,"customerEmployerContacted":true,"verificationDeclineReason":"","otherVerificationDeclineReason":"","creditVerificationComments":"Verification successful. Customer confirmed details.","creditVerificationResult":"Verified","creditVerificationResultDateAndTime":"2023-02-17T09:15:00Z","creditVerificationResultUpdatedBy":"Verifier1"},"infinityCreditorApprover":{"approverDeclineReason":"","otherApproverDeclineReason":"","creditApproverComments":"Some comments from the approver","creditApproverResult":"Approved","creditApproverResultDateAndTime":"2023-02-18T10:30:00Z","creditApproverResultUpdatedBy":"Approver1"},"infinityCreditBusinessTeam":{"businessTeamDeclineReason":"","otherBusinessTeamDeclineReason":"","creditBusinessTeamComments":"Comments from the business team","creditBusinessTeamResult":"Approved","creditBusinessTeamResultDateAndTime":"2023-02-19T11:45:00Z","creditBusinessTeamResultUpdatedBy":"BusinessTeam1"},"ceo":{"ceoDeclineReason":"","otherCeoDeclineReason":"","ceoComments":"Comments from the CEO","ceoResult":"Approved","ceoResultDateAndTime":"2023-02-19T12:30:00Z","ceoResultUpdatedBy":"CEO1"},"operation":{"buyoutLiabilitiesReferenceNumber":"REF12345","operationsTeamComments":"Comments from Operations Team","operationsTeamResult":"Completed","operationsResultDateAndTime":"2023-02-20T09:45:00Z","operationsResultUpdatedBy":"OpsTeam1"}},{"applicationId":"KXWJY7Q","loanProductConfigurationId":"EFGH5678","productType":"Auto Loan","productNature":"Lease","status":"Pending Approval","subStatus":"Credit Verification","amount":"15000","currency":"USD","tenor":"36 months","applicationsubmissionDateTime":"2023-02-15T14:45:00Z","cashInHand":"8000","employmentStatus":"Employed","proofOfNewAdress":"Utility Bill","infinityPreScreener":{"cprNumber":"123456789","cprExpiryDate":"2024-05-31","passportNumber":"P123456","passportExpiryDate":"2023-12-31","residencePermitNo":"RP987654","residencePermitExpiryDate":"2023-06-30","sameResidenceAddress":true,"employmentStatus":"Employed","employerBusinessName":"ABC Corp","employerBusinessAddressHouseFlatNumber":"123","employerBusinessAddressBuilding":"Tower A","employerBusinessAddressStreetRoadNo":"Main Street","employerBusinessAddressBlockNo":"Block B","employerBusinessAddressCity":"Cityville","employerBusinessAddressCountry":"USA","occupation":"Software Engineer","lengthOfServiceYears":"5","crLicenseNumber":"CR123456","crExpiryDate":"2023-12-31","businessOperationsStartingDate":"2010-01-01","businessSector":"Technology","businessNatureType":"Private Limited","totalInternalLoans":"2","totalConsumerLoans":"1","totalMortgageLoans":"0","totalCreditCards":"2","totalGovernmentLoans":"0","otherDeductions":"50","totalCurrentObligations":"500","totalObligations":"800","totalCreditExposure":"1500","creditBureauScore":"750","creditBureauRiskRating":"Low","basicSalary":"6000","fixedAllowances":"1000","variableAllowances":"500","businessIncome":"3000","totalApprovedIncome":"10500","finalTotalObligations":"600","finalDBR":"0.57","salaryTransfertoIla":true,"blacklisted":false,"preScreenerDeclineReason":"Insufficient Income","otherPreScreenerDeclineReason":"Not Enough Work Experience","creditPreScreeningComments":"Customer has a good credit history","creditPreScreeningResult":"Approved","creditPreScreeningResultDateAndTime":"2023-02-20T15:30:00Z","creditPreScreeningResultUpdatedBy":"Credit Analyst"},"infinityCreditEvaluator":{"hasExistingLoan":false,"approvedLoanAmount":"15000","approvedLoanDuration":"36 months","approvedLoanMonthlyInstalment":"500","approvedInterestRate":"4.5%","approvedAPR":"4.75%","approvedInsuranceAmount":"100","approvedProcessingFees":"50","approvedVatProcessingFees":"10","approvedFirstPaymentDate":"2023-02-28","approvedMaturityDate":"2026-02-28","approvedCashInHand":"8000","approvedLiabilities":"0","commodity":"Auto","approvedEmploymentStatus":"Employed","deviationOneType":"Income","otherDeviationOneType":"Additional income not considered","deviationTwoType":"Credit Score","otherDeviationTwoType":"Slightly lower credit score","evaluatorDeclineReason":"","otherEvaluatorDeclineReason":"","creditExceptions":"","creditEvaluationComments":"Positive credit history, stable employment","creditEvaluationResult":"Approved","creditEvaluationResultDateAndTime":"2023-02-15T15:30:00Z","creditEvaluationResultUpdatedBy":"Credit Analyst1"},"infinityCreditVerifier":{"customerContacted":true,"customerFriendContacted":true,"customerEmployerContacted":true,"verificationDeclineReason":"","otherVerificationDeclineReason":"","creditVerificationComments":"Verification successful. Customer confirmed details.","creditVerificationResult":"Verified","creditVerificationResultDateAndTime":"2023-02-17T09:15:00Z","creditVerificationResultUpdatedBy":"Verifier1"},"infinityCreditorApprover":{"approverDeclineReason":"","otherApproverDeclineReason":"","creditApproverComments":"Some comments from the approver","creditApproverResult":"Approved","creditApproverResultDateAndTime":"2023-02-18T10:30:00Z","creditApproverResultUpdatedBy":"Approver1"},"infinityCreditBusinessTeam":{"businessTeamDeclineReason":"","otherBusinessTeamDeclineReason":"","creditBusinessTeamComments":"Comments from the business team","creditBusinessTeamResult":"Approved","creditBusinessTeamResultDateAndTime":"2023-02-19T11:45:00Z","creditBusinessTeamResultUpdatedBy":"BusinessTeam1"},"ceo":{"ceoDeclineReason":"","otherCeoDeclineReason":"","ceoComments":"Comments from the CEO","ceoResult":"Approved","ceoResultDateAndTime":"2023-02-19T12:30:00Z","ceoResultUpdatedBy":"CEO1"},"operation":{"buyoutLiabilitiesReferenceNumber":"REF12345","operationsTeamComments":"Comments from Operations Team","operationsTeamResult":"Completed","operationsResultDateAndTime":"2023-02-20T09:45:00Z","operationsResultUpdatedBy":"OpsTeam1"}}],"loansOptions":[{"type":"personal","loansItems":[{"loanProductConfigurationId":1,"loanDisplayName":"personal loan","transactProductRef":"PERSONAL.LOAN","order":1,"nature":"unsecured","loanConfiguration":[{"configCode":"","configValue":""}]},{"loanProductConfigurationId":2,"loanDisplayName":"personal loan","transactProductRef":"PERSONAL.LOAN","order":2,"nature":"secured","loanConfiguration":[{"configCode":"","configValue":""}]}]}]}}');
 
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));
//         ApiConnection.Response response = Loans_ServiceManagerHandler.callLoansOptionsAPI(customerId, caseModel);
//         Test.stopTest(); 
        
//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
//         Map<String, Object> options = (Map<String, Object>)response.responseData;

//      }
//     @isTest
// 	static void testGetUserApplicationInfoAPI() {
//     Case testCase = [SELECT Id, Customer_CIF__c, AccountId, Case_Model__c FROM Case LIMIT 1];
//     String customerId = testCase.Customer_CIF__c;
//     String loanProductConfigurationId = '123456';
//     String caseModel = testCase.Case_Model__c;
 
//     HttpResponse mockResponse = new HttpResponse();
//     mockResponse.setStatusCode(200);
//     mockResponse.setBody('{"data": {"userInfo": {"name": "Karim Derd", "applicationId": "12345"}}}');
 
//     Test.startTest();
//     Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));
//     ApiConnection.Response response = Loans_ServiceManagerHandler.getUserApplicationInfoAPI(customerId, loanProductConfigurationId, caseModel);
//     Test.stopTest();

   
//     System.assert(response.isSuccess, 'Expected response to be successful');
//     System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
    
//     List<Object> responseDataList = (List<Object>) response.responseData;
//     if (responseDataList != null && !responseDataList.isEmpty()) {
//         Map<String, Object> responseDataMap = (Map<String, Object>) responseDataList[0];
//         if (responseDataMap != null) {
//             Map<String, Object> userInfoData = (Map<String, Object>) responseDataMap.get('userInfo');
//             if (userInfoData != null) {
//                 System.assertEquals('Karim Derd', userInfoData.get('name'), 'Expected user name to be Karim Derd');
//             } else {
//                 System.debug('userInfo is null');
//             }
//         } else {
//             System.debug('responseDataMap is null');
//         }
//     } else {
//         System.debug('responseDataList is null or empty');
//     }
// }

    
//        @isTest
//     static void testCreateLoanApplicationApi() {
//         Case testCase = [SELECT Id, Region_Flag__c, AccountId, Type, Product_Type__c, Customer_CIF__c, Case_Model__c, Card_Product_Configuration_Id__c, cc_Employment_Status__c,
//                          cc_Employer_Name__c, cc_Monthly_Income__c, Loans_Current_Address_confirmation__c, cc_Residence_Occupancy_Status__c, 
//                          cc_Number_of_Years_at_Current_Residence__c, cc_Marital_Status__c, cc_Number_of_Dependents__c, cc_Academic_Qualifications__c, cc_Friend_s_Contact_Number__c, cc_Friend_s_Name__c, Loans_Requested_Loan_Finance_Amount__c, Loans_Requested_Duration__c, Loans_Requested_Monthly_Instalment__c, Extra_information__c, Customer_Segment__c, cc_Nationality__c FROM Case LIMIT 1];
        
       
//         HttpResponse mainMockResponse = new HttpResponse();
//         mainMockResponse.setStatusCode(200);
//         mainMockResponse.setBody('{"data": {"applicationId": "12345", "entityId": "67890"}}');
    
      
//         HttpResponse secondaryMockResponse = new HttpResponse();
//         secondaryMockResponse.setStatusCode(200);
//         secondaryMockResponse.setBody('{"data": {"appFulfilmentId": "54321"}}');
    
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock2(mainMockResponse, secondaryMockResponse));
    
//         Map<String, Object> paramsMap = new Map<String, Object>{
//             'productType' => testCase.Product_Type__c,
//             'accountId' => testCase.AccountId,
//             'availableBalance' => '1000'
//         };
    
//         ApiConnection.Response response = Loans_ServiceManagerHandler.createLoanApplicationApi(testCase, paramsMap);
//         Test.stopTest();
    
//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
     
//     }
//        @isTest
//      static void testGetExistingLiabilitiesAPI() {
      
//         Case testCase = [SELECT Id, Customer_CIF__c, AccountId, Case_Model__c FROM Case LIMIT 1];
//         String customerId = testCase.Customer_CIF__c;
//         String caseModel = testCase.Case_Model__c;
 
//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//         mockResponse.setBody('{"data": {"existingLiabilities": [{"liabilityType": "Type1", "amount": 1000}, {"liabilityType": "Type2", "amount": 2000}]}}');

//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));
 
//         ApiConnection.Response response = Loans_ServiceManagerHandler.getExistingLiabilitiesAPI(customerId, caseModel);
//         Test.stopTest();
 
//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
//         List<Object> existingLiabilities = (List<Object>) response.responseData;

//      }
    
//   @isTest
//     static void testGetLoanCalculatorMatrixAPI() {
        
//          Case testCase = [SELECT Id, Customer_CIF__c, AccountId, Case_Model__c FROM Case LIMIT 1];
//         String customerId = testCase.Customer_CIF__c;
//         String caseModel = testCase.Case_Model__c;
 
//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//         mockResponse.setBody('{"data": {"matrix": [{"value": 1000}, {"value": 2000}]}}');

//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));

         
//         ApiConnection.Response response = Loans_ServiceManagerHandler.getLoanCalculatorMatrixAPI(customerId, caseModel);
//         Test.stopTest();

//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
        
//         Map<String, Object> responseDataMap = (Map<String, Object>) response.responseData;
//         List<Object> matrix = (List<Object>) responseDataMap.get('matrix');
  
//      }
    
//      @isTest
//     static void testGetCustomerProductsAPI() {
//         Case testCase = [SELECT Id, Customer_CIF__c, Case_Model__c FROM Case LIMIT 1];
//         String customerId = testCase.Customer_CIF__c;
//         String caseModel = testCase.Case_Model__c;
    
//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//         mockResponse.setBody('{"data": {"products": [{"productName": "Product1"}, {"productName": "Product2"}]}}');
    
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));
//         ApiConnection.Response response = Loans_ServiceManagerHandler.getCustomerProductsAPI(customerId, caseModel);
//         Test.stopTest();
    
//         System.assert(response.isSuccess, 'Expected response to be successful');
//         System.assertNotEquals(null, response.responseData, 'Expected response data to be not null');
//         Map<String, Object> responseDataMap = (Map<String, Object>) response.responseData;
//         List<Object> products = (List<Object>) responseDataMap.get('products');
//      }

//       @isTest
//      static void testUpdateLoanApplicationApi() {
//         Case testCase = [SELECT Id, Customer_CIF__c, Case_Model__c, Region_Flag__c, Loan_Application_ID__c, External_Id__c FROM Case LIMIT 1];
    
//         Map<String, String> paramsMap = new Map<String, String>();
//         paramsMap.put('status', 'In Progress');
//         paramsMap.put('subStatus', 'In-Progress');
    
//         HttpResponse mockResponse = new HttpResponse();
//         mockResponse.setStatusCode(200);
//         mockResponse.setBody('{"data": "success"}');
    
//         Test.startTest();
//         Test.setMock(HttpCalloutMock.class, new Loans_ServiceApiCallsMock(mockResponse));
//         HttpResponse response = Loans_ServiceManagerHandler.updateLoanApplicationApi(testCase, 'no', paramsMap);
//         Test.stopTest();
    
//         System.assertEquals(200, response.getStatusCode(), 'Expected response status code to be 200');
//      }
    
//     @isTest
//     static void testUpdateLoanApplicationApiFuture() {
//         Case testCase = [SELECT Id, AccountId FROM Case LIMIT 1];
//         Map<String, String> paramsMap = new Map<String, String>();
//         paramsMap.put('status', 'In Progress');
//         paramsMap.put('subStatus', 'In-Progress');
    
//         Test.startTest();
//         Loans_ServiceManagerHandler.updateLoanApplicationApiFuture(testCase.Id, 'no', paramsMap);
//         Test.stopTest();
    
//     }

//        @isTest
//     static void testCreateDocuSignEnvelope() {
//         Loan_DocuSignEnvelopeReqWrapper requestRecord = new Loan_DocuSignEnvelopeReqWrapper();
//         requestRecord.caseId = [SELECT Id FROM Case LIMIT 1].Id;
//         requestRecord.channel = 'In-App';  
//         User testUser = dfsle.UserMock.createDocuSignSender();// to avoid error : "dfsle.UnauthorizedException: DocuSign has not yet been configured for this account."
//         dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());//to avoid error : "Methods defined as TestMethod do not support Web service callouts"
//         testUser.Region_Flag__c = 'Bahrain';
//         update testUser;
//         System.runAs(testUser) {
//             Test.startTest();
            
//               Loans_ServiceManagerHandler.createDocuSignEnvelope(requestRecord);
           
//             Test.stopTest();
//         }
     
//     }

    
    
// 	//first mock
//     private class Loans_ServiceApiCallsMock implements HttpCalloutMock {
//         private HttpResponse mockResponse;

//         public Loans_ServiceApiCallsMock(HttpResponse mockResponse) {
//             this.mockResponse = mockResponse;
//         }

//         public HTTPResponse respond(HTTPRequest req) {
//             return mockResponse;
//         }
//     }
   
//     //second Mock
//       private class Loans_ServiceApiCallsMock2 implements HttpCalloutMock {
//         private HttpResponse mainMockResponse;
//         private HttpResponse secondaryMockResponse;

//         public Loans_ServiceApiCallsMock2(HttpResponse mainMockResponse, HttpResponse secondaryMockResponse) {
//             this.mainMockResponse = mainMockResponse;
//             this.secondaryMockResponse = secondaryMockResponse;
//         }

//         public HTTPResponse respond(HTTPRequest req) {
//             if (req.getEndpoint().contains('/api/v1/loans/application')) {
//                 return mainMockResponse;
//             } else if (req.getEndpoint().contains('/api/v1/loans/infinity/fulfillment')) {
//                 return secondaryMockResponse;
//             } else {
//                 return null;
//             }
//         }
//     }
}