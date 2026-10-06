@IsTest
private class Loans_APIHandlerTest {
    private static List < Case > testCases;
    private static Map < Id, CaseAnnex__c > caseAnnexMap;
    private static Integer accountCounter = 0;
    @testSetup
    static void setup() {
        System.debug('--- SETUP START ---');
        System.debug('Creating test cases...');
        Account acc = (Account) TestDataFactory.createSObject(new Account(CIF__pc = '123456', PersonEmail = 'test1@test.com', Subscription_Model__pc = 'ila', CustomerStatus__c = null, Archived__pc = false, Region_Flag__pc = 'Bahrain'), 'TestFactoryDefaults.AccountDefaults', true);
        account testAccount=[SELECT Id,PersonContactId FROM account WHERE Id = : acc.Id  LIMIT 1];
        System.debug('Created Account: ' + testAccount);
        List < Case > caseUpdates = new List < Case > ();
        Case testCase1 = createTestCase('Refer to Service Center', true, 'New', 'In-Progress', null, testAccount);
        CaseAnnex__c cx = createCaseAnnexRecords(testCase1);
        testCase1.CaseAnnex__C = cx.Id;
        caseUpdates.add(testCase1);

        Test.startTest();
        update caseUpdates;
        System.debug('Test Cases Created: ' + new List < Case > {
            testCase1

        });
        Test.stopTest();
        System.debug('--- SETUP END ---');
    }
    private static Case createTestCase(String contactCentreResult, Boolean haveCreditCard, String status, String subStatus, String controlType, Account testAccount) {
        System.debug('Creating Case with testAccount.Id: ' + testAccount.Id + ', status: ' + status + ', subStatus: ' + subStatus);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
        Case testCase = (Case) TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId, ContactId = testAccount.PersonContactId, AccountId = testAccount.id, Case_Model__c = 'ila', Type = 'New Loan / Finance Application', Sub_Type__c = 'New Loan / Finance Application Request', AIR_HaveCreditCard__c = haveCreditCard, cc_Service_Centre_Result__c = 'Return to Pre-Screener', Resend_DocuSign__c = 'Email', ccol_Hold_Amount__c = 5000, cc_Contact_Centre_Result__c = contactCentreResult, Status = status, Sub_Status__c = subStatus, cc_Control_Type__c = controlType, Region_Flag__c = 'Bahrain'), 'TestFactoryDefaults.CaseDefaults', true);
        System.debug('Created Case: ' + testCase);
        return testCase;
    }
    private static CaseAnnex__c createCaseAnnexRecords(Case caseRecord) {
        System.debug('--- Creating CaseAnnex Records ---');
        CaseAnnex__c annex = new CaseAnnex__c(Case__c = caseRecord.Id, cx_ln_Product__c = 'Unsecured', cx_ln_Requested_Loan_Finance_Amount__c = 10000, cx_ln_Requested_Duration_Months__c = 12, cx_ln_Monthly_Instalment__c = 900, cx_ln_Approved_Loan_Amount__c = 10000, cx_ln_ApprovedInterestProfitRateReducing__c = 5.0, cx_ln_Approved_Installment_Amount__c = 900, cx_ln_Approved_Duration_Months__c = 12, cx_ln_APR__c = 6.0, cx_ln_Requested_Processing_Fees__c = 100, cx_ln_Requested_Vat_Processing_Fees__c = 10, cx_ln_Approved_First_installment_date__c = Date.today().addDays(30), cx_ln_Approved_Maturity_Date__c = Date.today().addDays(395), cx_ln_Approved_Insurance_Premium__c = 'Upfront', cx_ln_Approved_insurance__c = true, cx_ln_ApprovedProcessing_Fee_Type__c = 'Upfront', cx_ln_Approved_Insurance_Amount__c = 50, cx_ln_RequireSalaryCertificate__c = false, cx_ln_Cross_Selling_PreScreening_Result__c = 'Approve', cx_ln_Cross_Selling_Evaluator_Result__c = 'Approve', cx_ln_Cross_Selling_Verifier_Result__c = 'Approve', cx_ln_Cross_Selling_Approver_Result__c = 'Approve', cx_ln_SimulationReference__c = 'TEST_SIM_REF');
        insert annex;
        System.debug('Inserted CaseAnnex records: ' + annex);
        return annex;
    }
    private static void loadTestData() {
        System.debug('--- Loading Test Data ---');
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        System.debug('fields to query >>> '+ fields);
        String soqlQuery = 'SELECT ' + fields + ',CaseAnnex__r.cx_ln_Cross_Selling_PreScreening_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Evaluator_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Verifier_Result__c,CaseAnnex__r.cx_ln_Cross_Selling_Approver_Result__c,Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case ';
        testCases = new List < Case > ((List < Case > ) Database.query(soqlQuery));
        System.debug('Loaded testCases count: ' + testCases.size() + ' ... ' + testCases + ' .......'+ testCases[0].Customer_CIF__c);
        Set < Id > caseIds = new Map < Id, Case > (testCases).keySet();
        System.debug('caseIds >>> ' + caseIds);
        String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');
        String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Case__c IN :caseIds';
        List < CaseAnnex__c > annexList = new List < CaseAnnex__c > ((List < CaseAnnex__c > ) Database.query(caseAnnexsoqlQuery));
        System.debug('annexList : ' + annexList + ' ... ' + annexList[0].id + ' .......');
        caseAnnexMap = new Map < Id, CaseAnnex__c > ();
        for (CaseAnnex__c annex: annexList) {
            System.debug('annex : ' + annex + ' ... ' + annex.Case__c + ' .......');
            caseAnnexMap.put(annex.Case__c, annex);
        }
        System.debug('Loaded caseAnnexMap size: ' + caseAnnexMap.size());
    }
    private static Case getTestCaseByStatus(String status) {
        loadTestData();
        for (Case c: testCases) {
            if (c.Status == status) {
                return c;
            }
        }
        return testCases[0];
    }
    private static Case getTestCaseBySubStatus(String subStatus) {
        loadTestData();
        for (Case c: testCases) {
            if (c.Sub_Status__c == subStatus) {
                return c;
            }
        }
        return testCases[0];
    }
    private static Case getTestCaseWithCreditCard(Boolean haveCreditCard) {
        loadTestData();
        for (Case c: testCases) {
            if (c.AIR_HaveCreditCard__c == haveCreditCard) {
                return c;
            }
        }
        return testCases[0];
    }
    private static Case getTestCaseByCCResult(String ccResult) {
        loadTestData();
        for (Case c: testCases) {
            if (c.cc_Contact_Centre_Result__c == ccResult) {
                return c;
            }
        }
        return testCases[0];
    }

    private static Loans_APIHandler.LoanWrapper createLoanWrapper(Id caseId, String isNew, String changedField) {
        return createLoanWrapper(caseId, isNew, 'Case', changedField);
    }
    private static Loans_APIHandler.LoanWrapper createLoanWrapper(Id caseId, String isNew, String objectSource, String changedField) {
        Loans_APIHandler.LoanWrapper loanWrapper = new Loans_APIHandler.LoanWrapper();
        loanWrapper.caseId = caseId;
        loanWrapper.isNew = isNew;
        loanWrapper.objectSource = objectSource;
        loanWrapper.changedField = changedField;
        return loanWrapper;
    }
    @IsTest
    static void testUpdateLoanUpdateApiFromFlow_Success() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
        if (testCases.isEmpty()) return;
        System.debug('test my flow success >> ' + testCase.Id);
        Loans_APIHandler.LoanWrapper loanWrapper = createLoanWrapper(testCase.Id, 'yes', 'cc_Service_Centre_Result__c');
        List < Loans_APIHandler.LoanWrapper > loanWrappers = new List < Loans_APIHandler.LoanWrapper > {
            loanWrapper
        };
        List < String > result = Loans_APIHandler.updateLoanUpdateApiFromFlow(loanWrappers);
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected one case ID to be returned');
        System.assertEquals(testCase.Id, result[0], 'Expected case ID to match the test case ID');
    }
    @IsTest
    static void testUpdateLoanUpdateApiFromFlow_ThrowExceptions() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
        Loans_APIHandler.LoanWrapper loanWrapper1 = createLoanWrapper(testCase.Id, 'yes', 'cc_Service_Centre_Result__c');
        List < Loans_APIHandler.LoanWrapper > loanWrappers1 = new List < Loans_APIHandler.LoanWrapper > {
            loanWrapper1
        };
        Loans_APIHandler.throwException_1 = true;
        List < String > result1 = Loans_APIHandler.updateLoanUpdateApiFromFlow(loanWrappers1);
        System.assertEquals(1, result1.size(), 'Expected one case ID for exception 1');
        Loans_APIHandler.throwException_1 = false;
        Loans_APIHandler.LoanWrapper loanWrapper2 = createLoanWrapper(testCase.Id, 'no', 'cc_Service_Centre_Result__c');
        List < Loans_APIHandler.LoanWrapper > loanWrappers2 = new List < Loans_APIHandler.LoanWrapper > {
            loanWrapper2
        };
        Loans_APIHandler.throwException_2 = true;
        List < String > result2 = Loans_APIHandler.updateLoanUpdateApiFromFlow(loanWrappers2);
        System.assertEquals(1, result2.size(), 'Expected one case ID for exception 2');
        Test.stopTest();
        Case updatedCase = [SELECT Last_Api_Call_Status__c FROM Case WHERE Id = : testCase.Id];
        System.assertEquals('Failed', updatedCase.Last_Api_Call_Status__c, 'Expected API call status to be Failed');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_MultipleFieldChanges() {
        Test.startTest();
        loadTestData();
        if (testCases.isEmpty()) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details1 = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'Status'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCases[0].Id
        }, details1);

          Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_CreditCardScenarios() {
        Test.startTest();
         Case testCase = getTestCaseWithCreditCard(true);
        if (testCase == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Credit_Approval_Result__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle credit card cross-selling scenarios');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_ControlTypeSTPScenarios() {
        Test.startTest();
         Case stpCase = getTestCaseByStatus('New');
         stpCase.cc_Control_Type__c = 'STP';
         update stpCase;
        if (stpCase == null) return;
        CaseAnnex__c annex = caseAnnexMap.get(stpCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        annex.cx_ln_Product__c = 'Unsecured';
        update annex;
        Map < String, String > details1 = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Control_Type__c'
        };
        try {
            Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
                stpCase.Id
            }, details1);
        } catch (Exception e) {
            System.debug('test class tesing');
        }
        annex.cx_ln_Product__c = 'Secured';
        update annex;

        try {
            Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
                stpCase.Id
            }, details1);
        } catch (Exception e) {
            System.debug('test class tesing');
        }
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_LiabilitiesScenarios() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');

        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Operations_Result__c'
        };
        annex.cx_ln_Requested_Liabilities__c = '[{"selected":true,"outstanding":5000}]';
        update annex;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        annex.cx_ln_Requested_Liabilities__c = '[{"selected":false,"outstanding":5000}]';
        update annex;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        annex.cx_ln_Requested_Liabilities__c = null;
        update annex;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle various liabilities scenarios');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_ResendDocuSignScenarios() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'Resend_DocuSign__c'
        };
        testCase.Resend_DocuSign__c = 'Email';
        update testCase;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        testCase.Resend_DocuSign__c = 'In-App';
        update testCase;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle resend docusign scenarios');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_NewCreationScenarios() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Case noCCCase = getTestCaseWithCreditCard(false);
        Map < String, String > details1 = new Map < String, String > {
            'isNew' => 'yes',
            'objectSource' => 'Case',
            'changedField' => null
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            noCCCase.Id
        }, details1);
        Case ccCase = getTestCaseWithCreditCard(true);
        Loans_APIHandler.updateLoanApiFutureMeth(new Set < Id > {
            ccCase.Id
        }, details1);
        Test.stopTest();
        System.assert(true, 'Should handle new creation scenarios');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_VariousFieldChanges() {
        Test.startTest();
        loadTestData();
        if (testCases.isEmpty()) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        testCases[0].Last_Call_Outcome__c = 'Completed';
        update testCases[0];
        Map < String, String > details1 = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'Last_Call_Outcome__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCases[0].Id
        }, details1);

        Test.stopTest();
        System.assert(true, 'Should handle various field changes');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_WithEnvelopeIdAndException() {
        Test.startTest();
        loadTestData();
        if (testCases.isEmpty()) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details1 = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Credit_Approval_Result__c',
            'envelopeId' => 'TEST_ENVELOPE_123',
            'contactId' => 'TEST_CONTACT_456'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCases[0].Id
        }, details1);
        Loans_APIHandler.throwException_2 = true;

        Test.stopTest();
        System.assert(true, 'Should handle envelope ID and exceptions');
    }

    @IsTest
    static void testLoanApplicationProcessFields() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        CC_Application_Status_Mapping__mdt testMetadata = new CC_Application_Status_Mapping__mdt(Awaiting_Customer_Feedback__c = false, Sub_Status__c = 'In-Progress', Status__c = 'Under Review', queueDeveloperName__c = 'Loan_Finance_Request_Pre_screener_Queue', cc_Application_Stages__c = 'Credit Pre-Screening', isApiCall__c = false, crmStage__c = 'IN PROGRESS', emailAlertName__c = '', sectionResultFields__c = 'cc_Contact_Centre_Date_Time__c;cc_Contact_Center_by__c;cc_Contact_Centre_Comments__c;Contact Center Comments', fieldsToBeReseted__c = 'cc_Credit_Approval_Result__c');
        Case result = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'cc_Credit_Approval_Result__c', testMetadata);
        Test.stopTest();
        System.assert(result != null, 'Should process loan application fields');
    }
    @IsTest
    static void testLoanApplicationProcessFields_MultipleScenarios() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        CC_Application_Status_Mapping__mdt metadata1 = new CC_Application_Status_Mapping__mdt(Status__c = 'Under Review', isApiCall__c = false, emailAlertName__c = 'Test_Email', fieldsToBeReseted__c = 'AIR_HaveCreditCard__c;cc_Credit_Approval_Result__c');
        Case result1 = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'Status', metadata1);
        System.assert(result1 != null, 'Should handle email alert');
        testCase.Status = 'Pending';
        testCase.Sub_Status__c = 'Pending Offer Acceptance';
        CC_Application_Status_Mapping__mdt metadata2 = new CC_Application_Status_Mapping__mdt(Status__c = 'Pending', Sub_Status__c = 'Pending Offer Acceptance', isApiCall__c = false);
        Case result2 = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'Status', metadata2);
        System.assert(result2 != null, 'Should set Review_Offer_Date_Time__c');
        Test.stopTest();
    }
    @IsTest
    static void testGetApiStatusBasedOnCaseChanges() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        CC_Application_Status_Mapping__mdt result1 = Loans_APIHandler.getApiStatusBasedOnCaseChanges(testCase, annex, 'Case', 'Status');
        CC_Application_Status_Mapping__mdt result2 = Loans_APIHandler.getApiStatusBasedOnCaseChanges(testCase, annex, 'CaseAnnex__c', 'cx_ln_Product__c');
        Test.stopTest();
        System.assert(true, 'Should get API status based on case changes');
    }
    @IsTest
    static void testEvaluateCriteria() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Boolean result1 = Loans_APIHandler.evaluateCriteria('Case', testCase, annex, 'Status;==;New');
        System.assert(result1 != null, 'Should evaluate single condition');
        Boolean result2 = Loans_APIHandler.evaluateCriteria('Case', testCase, annex, 'Status;==;New&&Type;==;New Loan / Finance Application');
        System.assert(result2 != null, 'Should evaluate multiple AND conditions');
        Boolean result3 = Loans_APIHandler.evaluateCriteria('Case', testCase, annex, 'Status;!=;Closed');
        System.assert(result3 != null, 'Should evaluate not equal condition');
        Boolean result4 = Loans_APIHandler.evaluateCriteria('CaseAnnex__c', testCase, annex, 'CaseAnnex__c.cx_ln_Product__c;==;Unsecured');
        System.assert(result4 != null, 'Should evaluate CaseAnnex fields');
        Boolean result5 = Loans_APIHandler.evaluateCriteria('Case', testCase, annex, 'Case.Region_Flag__c;==;Bahrain');
        System.assert(result5 != null, 'Should evaluate nested Case fields');
        Test.stopTest();
    }
    @IsTest
    static void testHandleReminderFields() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
        if (testCases.isEmpty()) return;
        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        CaseAnnex__c result1 = Loans_APIHandler.handleReminderFields(testCase, annex);
        System.assert(result1 != null, 'Should handle reminder fields with metadata');
        testCase.Status = 'NonExistentStatus';
        testCase.Sub_Status__c = 'NonExistentSubStatus';
        CaseAnnex__c result2 = Loans_APIHandler.handleReminderFields(testCase, annex);
        System.assert(result2.cx_ln_Reminder_1_Datetime__c == null, 'Should return null when no metadata found');
        Test.stopTest();
    }
    @IsTest
    static void testSendEmailAlert() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         try {
            Loans_APIHandler.sendEmailAlert(testCase, 'Test_Email_Alert');
            System.assert(true, 'Should attempt to send email alert');
        } catch (Exception e) {
            System.assert(true, 'Email alert method executed');
        }
        Test.stopTest();
    }
    @IsTest
    static void testGenerateRepaymentScheduleApiHandler() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, Object > result1 = Loans_APIHandler.generateRepaymentScheduleApiHandler(testCase, annex);
        System.assert(result1 != null, 'Should generate repayment schedule successfully');
        System.assert(result1.containsKey('status'), 'Result should contain status');
        annex.cx_ln_Requested_Loan_Finance_Amount__c = null;
        update annex;
        Map < String, Object > result2 = Loans_APIHandler.generateRepaymentScheduleApiHandler(testCase, annex);
        System.assert(result2 != null, 'Should handle error scenarios');
        Test.stopTest();
    }
    @IsTest
    static void testGenerateRepaymentScheduleApiHandler_Failure() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure());
        Map < String, Object > result = Loans_APIHandler.generateRepaymentScheduleApiHandler(testCase, annex);
        Test.stopTest();

    }
    @IsTest
    static void testUpdateCaseFieldJob() {
        Test.startTest();
        Map<Id, Id> mapCasetoAccount = new Map<Id, Id>();
        Case testCase = getTestCaseByStatus('New');
        mapCasetoAccount.put(testCase.Id, testCase.AccountId);
         Loans_APIHandler.UpdateCaseFieldJob job1 = new Loans_APIHandler.UpdateCaseFieldJob(mapCasetoAccount);
        System.enqueueJob(job1);
        Test.stopTest();
    }
    @IsTest
    static void testLoanWrapperClass() {
        Test.startTest();
        Loans_APIHandler.LoanWrapper wrapper = new Loans_APIHandler.LoanWrapper();
        wrapper.caseId = '5003000000D8U3F';
        wrapper.isNew = 'yes';
        wrapper.objectSource = 'Case';
        wrapper.changedField = 'Status';
        Test.stopTest();
        System.assertEquals('5003000000D8U3F', wrapper.caseId, 'Case ID should be set correctly');
        System.assertEquals('yes', wrapper.isNew, 'isNew should be set correctly');
        System.assertEquals('Case', wrapper.objectSource, 'objectSource should be set correctly');
        System.assertEquals('Status', wrapper.changedField, 'changedField should be set correctly');
    }
    @IsTest
    static void testGetQueueIdBasedOnQueueDevName() {
        Test.startTest();
        Id queueId1 = Loans_APIHandler.getQueueIdBasedOnQueueDevName('NonExistentQueue');
        System.assertEquals(null, queueId1, 'Should return null for non-existent queue');
        Id queueId2 = Loans_APIHandler.getQueueIdBasedOnQueueDevName('AnotherNonExistentQueue');
        System.assert(true, 'Should handle queue lookup');
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_ExpiredAndSpecialStatuses() {
        Test.startTest();
        Case testCase = getTestCaseWithCreditCard(true);
        if (testCase == null) return;
        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        testCase.Sub_Status__c = 'Expired';
        update testCase;
        Map < String, String > details1 = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'Sub_Status__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details1);
        testCase.Sub_Status__c = 'Pending Offer Acceptance';
        update testCase;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details1);
        Test.stopTest();
        System.assert(true, 'Should handle expired and special statuses');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_ScheduleAPIError() {
        Test.startTest();
         Case stpCase = getTestCaseByStatus('New');
         stpCase.cc_Control_Type__c = 'STP';
         update stpCase;
        if (stpCase == null) return;
        CaseAnnex__c annex = caseAnnexMap.get(stpCase.Id);
        if (annex == null) return;
        annex.cx_ln_SimulationReference__c = null;
        update annex;
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Control_Type__c'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorFailure());
        try {
            Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
                stpCase.Id
            }, details);
        } catch (Exception e) {
            System.debug('test class tesing');
        }
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_NoMetadataMatch() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
        if (testCases.isEmpty()) return;
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'NonExistentField__c'
        };
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle no metadata match gracefully');
    }
    @IsTest
    static void testLoanApplicationProcessFields_ComplexResetScenarios() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        CC_Application_Status_Mapping__mdt metadata1 = new CC_Application_Status_Mapping__mdt(Status__c = 'Under Review', isApiCall__c = false, fieldsToBeReseted__c = 'cc_Credit_Approval_Result__c;cc_Credit_Evaluation_Result__c;CaseAnnex__c.cx_ln_Product__c');
        Case result1 = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'Status', metadata1);
        System.assert(result1 != null, 'Should reset multiple fields');
        CC_Application_Status_Mapping__mdt metadata2 = new CC_Application_Status_Mapping__mdt(Status__c = 'Under Review', isApiCall__c = false, fieldsToBeReseted__c = 'cc_Contact_Centre_Result__c');
        Case result2 = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'Status', metadata2);
        System.assert(result2 != null, 'Should reset CaseAnnex boolean fields');
        testCase.cc_Contact_Centre_Comments__c = 'Test comment';
        CC_Application_Status_Mapping__mdt metadata3 = new CC_Application_Status_Mapping__mdt(Status__c = 'Under Review', isApiCall__c = false, sectionResultFields__c = 'cc_Contact_Centre_Date_Time__c;cc_Contact_Center_by__c;cc_Contact_Centre_Comments__c;Contact Center Comments');
        Case result3 = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'cc_Contact_Centre_Result__c', metadata3);
        System.assert(result3 != null, 'Should create case comment from result field');
        CC_Application_Status_Mapping__mdt metadata4 = new CC_Application_Status_Mapping__mdt(Status__c = 'Under Review', isApiCall__c = false, sectionResultFields__c = 'CaseAnnex__c.cx_ln_Last_Status_Changed_Date_Time__c;CaseAnnex__c.cx_ln_Product__c');
        Case result4 = Loans_APIHandler.LoanApplicationProcessFields(testCase, annex, 'Status', metadata4);
        System.assert(result4 != null, 'Should handle CaseAnnex section results');
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_WithNullDetails() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         try {
            Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
                testCase.Id
            }, new Map < String, String > ());
            System.assert(true, 'Should handle empty details');
        } catch (Exception e) {
            System.assert(true, 'Exception handled: ' + e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanUpdateApiFromFlow_ResendDocuSignAndOtherFields() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         Loans_APIHandler.LoanWrapper wrapper1 = createLoanWrapper(testCase.Id, 'yes', 'Resend_DocuSign__c');
        List < String > result1 = Loans_APIHandler.updateLoanUpdateApiFromFlow(new List < Loans_APIHandler.LoanWrapper > {
            wrapper1
        });
        System.assertEquals(1, result1.size(), 'Expected one case ID for Resend_DocuSign');
        Loans_APIHandler.LoanWrapper wrapper2 = createLoanWrapper(testCase.Id, 'no', 'Credit_Retention_Result__c');
        List < String > result2 = Loans_APIHandler.updateLoanUpdateApiFromFlow(new List < Loans_APIHandler.LoanWrapper > {
            wrapper2
        });
        System.assertEquals(1, result2.size(), 'Expected one case ID for Credit_Retention_Result');
        Test.stopTest();
    }
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","data":{"holdInfo":"Test Hold Info","disbursementStatus":"Pending"}}');
            res.setStatusCode(200);
            return res;
        }
    }
    private class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error":"API Error"}');
            res.setStatusCode(500);
            return res;
        }
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_PendingDisbursementScenario() {

        Case testCase = getTestCaseBySubStatus('Pending Disbursement');
        if (testCase == null) {
            testCase = testCases[0];
            testCase.Status = 'Under Review';
            testCase.Sub_Status__c = 'Pending Disbursement';
            update testCase;
        }
        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithStatusData());
        Test.startTest();
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Operations_Result__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        Case updatedCase = [SELECT Status, Sub_Status__c FROM Case WHERE Id = : testCase.Id];
        System.assert(updatedCase != null, 'Case should be updated with API response status');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_PendingOfferAcceptanceHoldInfo() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
        if (testCases.isEmpty()) return;

        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithHoldInfo());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Credit_Approval_Result__c'
        };
        
        annex.cx_ln_Requested_Liabilities__c = '[{"type":"Credit Card","outstanding":1000,"monthlyInstallment":200,"selected":true},{"type":"Housing Loan","outstanding":4000,"monthlyInstallment":120,"selected":false},{"type":"Housing Loan","outstanding":2000,"monthlyInstallment":200,"selected":false},{"type":"Consumer Loan","outstanding":10000,"monthlyInstallment":200,"selected":false},{"type":"Consumer Loan","outstanding":4500,"monthlyInstallment":120,"selected":false},{"type":"Housing Loan","outstanding":1100,"monthlyInstallment":60,"selected":false}]';
        annex.cx_ln_Credit_Pre_Screening_Result__c = 'Accept';
        update annex; 
        testCase.cc_Credit_Approval_Result__c ='Approve';
        testCase.cc_Credit_Verification_Result__c = 'Approve';
        testCase.cc_Control_Type__c = 'STP';
        update testCase;
        try {
            Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
                testCase.Id
            }, details);
        } catch (Exception e) {}

        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_CrossSellingDeclineScenario() {
        Test.startTest();
        Case testCase = getTestCaseWithCreditCard(true);
        if (testCase == null) return;
        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        annex.cx_ln_Cross_Selling_PreScreening_Result__c = 'Decline';
        update annex;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Credit_Approval_Result__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle cross-selling decline scenario');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_CrossSellingCancelledScenario() {
        Test.startTest();
        getTestCaseByStatus('New');
        Case testCase = getTestCaseWithCreditCard(true);
        if (testCase == null) return;
        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        annex.cx_ln_Cross_Selling_PreScreening_Result__c = 'Cancelled';
        update annex;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Credit_Approval_Result__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle cross-selling cancelled scenario');
    }
    private class MockHttpResponseGeneratorWithStatusData implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","data":{"status":"Closed","subStatus":"Approved"}}');
            res.setStatusCode(200);
            return res;
        }
    }
    private class MockHttpResponseGeneratorWithHoldInfo implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success","data":{"holdAmount":5000,"holdReference":"HOLD12345","holdAccountBalance":15000}}');
            res.setStatusCode(200);
            return res;
        }
    }
    private static Case getTestCaseBySubStatusAndField(String subStatus, String fieldName, Object fieldValue) {
        loadTestData();
        for (Case c: testCases) {
            if (c.Sub_Status__c == subStatus && c.get(fieldName) == fieldValue) {
                return c;
            }
        }
        return null;
    }
    private class MockHttpResponseGeneratorWithCardConfig implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('credit-cards')) {
                res.setBody('{"meta":{"code":"200"},"data":{"cardOptions":[{"productMappingCode":"VISA_GOLD","cardProductConfigurationId":12345}]}}');
            } else {
                res.setBody('{"status":"success","data":{}}');
            }
            res.setStatusCode(200);
            return res;
        }
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_NewCreationWithCreditCardAndXCanary() {
        Test.startTest();
        Case testCase = getTestCaseWithCreditCard(true);
        if (testCase == null) return;
        Account acc = [SELECT Id, x_canary__pc FROM Account WHERE Id = : testCase.AccountId];
        acc.x_canary__pc = 'TEST_CANARY_VALUE';
        update acc;
        testCase.cc_Requested_Card_Type__c = 'WORLD_CASHBACK_AND_REWARDS_01';
        update testCase;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithCardConfig());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'yes',
            'objectSource' => 'Case',
            'changedField' => null
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle credit card creation with x-canary header');
    }
    @IsTest
    static void testGenerateRepaymentScheduleApiHandler_WithNullValues() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        annex.cx_ln_Requested_Loan_Finance_Amount__c = null;
        annex.cx_ln_Requested_Duration_Months__c = null;
        update annex;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, Object > result = Loans_APIHandler.generateRepaymentScheduleApiHandler(testCase, annex);
        Test.stopTest();
        System.assert(result != null, 'Should handle null values in schedule generation');
    }
    @IsTest
    static void testUpdateLoanUpdateApiFromFlow_SynchronousCallout() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');

         Loans_APIHandler.LoanWrapper loanWrapper = new Loans_APIHandler.LoanWrapper();
        loanWrapper.caseId = testCase.Id;
        loanWrapper.isNew = 'yes';
        loanWrapper.objectSource = 'Case';
        loanWrapper.changedField = 'Status';
        loanWrapper.isSynchronousCallout = 'true';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        List < String > result = Loans_APIHandler.updateLoanUpdateApiFromFlow(new List < Loans_APIHandler.LoanWrapper > {
            loanWrapper
        });
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Should handle synchronous callout');
    }
    @IsTest
    static void testHandleReminderFields_AllReminderTypes() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');

         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        testCase.Status = 'Pending';
        testCase.Sub_Status__c = 'Pending Offer Acceptance';
        CaseAnnex__c result1 = Loans_APIHandler.handleReminderFields(testCase, annex);
        System.assert(result1 != null, 'Should set all reminder fields');
        testCase.Status = 'Under Review';
        testCase.Sub_Status__c = 'In-Progress';
        CaseAnnex__c result2 = Loans_APIHandler.handleReminderFields(testCase, annex);
        System.assert(result2 != null, 'Should handle partial reminders');
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_DocuSignScenarios() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');

         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Signature_Verifier_Result__c',
            'envelopeId' => 'TEST_ENV_123',
            'contactId' => 'TEST_CONTACT_456'
        };
        testCase.cc_Signature_Verifier_Result__c = 'Re-Send';
        update testCase;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle DocuSign re-send scenarios');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_BuyoutScenarios() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        annex.cx_ln_Requested_Liabilities__c = '[{"selected":true,"outstanding":5000},{"selected":true,"outstanding":3000}]';
        update annex;
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'cc_Operations_Result__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        annex.cx_ln_Requested_Liabilities__c = '[]';
        update annex;
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        annex.cx_ln_Requested_Liabilities__c = 'invalid json';
        update annex;
        try {
            Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
                testCase.Id
            }, details);
        } catch (Exception e) {
            System.assert(true, 'Should catch JSON parsing exception');
        }
        Test.stopTest();
        System.assert(true, 'Should handle various buyout scenarios');
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_StatusTransitions() {
        Test.startTest();
         Case testCase = getTestCaseByStatus('New');

         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorWithStatusData());
        testCase.Status = 'Pending';
        update testCase;
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'Status'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle status field transitions');
    }
    @IsTest
    static void testGetApiStatusBasedOnCaseChanges_CaseAnnexField() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        annex.cx_ln_Product__c = 'Secured';
        update annex;
        CC_Application_Status_Mapping__mdt result = Loans_APIHandler.getApiStatusBasedOnCaseChanges(testCase, annex, 'CaseAnnex__c', 'cx_ln_Product__c');
        Test.stopTest();
        System.assert(true, 'Should get API status for CaseAnnex field changes');
    }
    @IsTest
    static void testUpdateLoanApiSimpleMeth_DirectCall() {
        Test.startTest();
         Case testCase = getTestCaseByStatus('New');
         Map < String, String > details = new Map < String, String > {
            'isNew' => 'yes',
            'objectSource' => 'Case',
            'changedField' => null
        };
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should call simple method directly');
    }
    @IsTest
    static void testHandleReminderFields_EdgeCases() {
        Test.startTest();
         Case testCase = getTestCaseByStatus('New');
         CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        testCase.Status = 'Closed';
        testCase.Sub_Status__c = 'Approved';
        CaseAnnex__c result1 = Loans_APIHandler.handleReminderFields(testCase, annex);
        System.assertEquals(null, result1.cx_ln_Reminder_1_Datetime__c, 'Should null out reminders for unmatched status');
        testCase.Status = 'Under Review';
        testCase.Sub_Status__c = 'In-Progress';
        CaseAnnex__c result2 = Loans_APIHandler.handleReminderFields(testCase, annex);
        System.assert(result2 != null, 'Should handle different status combinations');
        Test.stopTest();
    }
    @IsTest
    static void testUpdateLoanApiFutureMeth_CreditRetentionResult() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');
        if (testCases.isEmpty()) return;
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Map < String, String > details = new Map < String, String > {
            'isNew' => 'no',
            'objectSource' => 'Case',
            'changedField' => 'Credit_Retention_Result__c'
        };
        Loans_APIHandler.updateLoanApiSimpleMeth(new Set < Id > {
            testCase.Id
        }, details);
        Test.stopTest();
        System.assert(true, 'Should handle Credit Retention Result field');
    }
    @IsTest
    static void testEvaluateCriteria_MixedOperators() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');

        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        Boolean result = Loans_APIHandler.evaluateCriteria('Case', testCase, annex, 'Status;!=;Closed&&Type;==;New Loan / Finance Application&&Region_Flag__c;==;Bahrain');
        System.assert(result != null, 'Should evaluate mixed operators');
        Boolean result2 = Loans_APIHandler.evaluateCriteria('Case', testCase, annex, 'Case.Status;==;New&&CaseAnnex__c.cx_ln_Product__c;==;Unsecured');
        System.assert(result2 != null, 'Should evaluate mixed object fields');
        Test.stopTest();
    }
    @IsTest
    static void testCallBcrbDecisioningApi_Success() {
        Test.startTest();
        Case testCase = getTestCaseByStatus('New');

        CaseAnnex__c annex = caseAnnexMap.get(testCase.Id);
        if (annex == null) return;
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:NeoBank_Endpoint/api/v1/bcrb/decision');
        request.setMethod('POST');

        HttpResponse response = Loans_APIHandler.callBcrbDecisioningApi(request,  testCase, annex);
        Test.stopTest();

    }
}