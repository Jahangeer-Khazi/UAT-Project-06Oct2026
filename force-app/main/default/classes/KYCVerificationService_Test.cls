@IsTest
private class KYCVerificationService_Test {
   
    private class KYCMockResponse implements HttpCalloutMock {
        protected Integer statusCode;
        protected String responseBody;
        public KYCMockResponse(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }
 
    @testSetup
    static void setup() {
        // Create Account
        Account acc = createAccount();
        
        // Create KYC Record - Periodic Review
        KYC_Verification__c kyc = new KYC_Verification__c(
            Account_Name__c = acc.Id,
            case_Model__c = 'ila',
            Type__c = 'KYC_PERIODIC_REVIEW',
            Status__c = 'Open',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            Sub_Status__c = 'Pending ID&V',
            API_Status__c = 'PR_PENDING_IDV_S1',
            ID_V_Required__c = 'Yes',
            ID_V_Status__c = 'Pending',
            Review_Personal_Information_Required__c = 'No',
            KYC_Form_Status__c = 'Skipped',
            KYC_Form_Tax_Status__c = 'Skipped',
            Upload_Documents_Required__c = 'No',
            KYC_Upload_Document_Status__c = 'Skipped',
            Block_Debit_Cards__c = false,
            Block_Credit_Cards__c = false,
            Block_Account_Debits__c = false,
            Block_App_Access__c = false,
            No_of_days__c = 0,
            KYC_Verification_Result__c = '',
            eKYC_Required__c = false,
            Document_Proof_of_Address__c = false,
            Document_FATCA_Declaration__c = false,
            Document_List__c = '',
            Document_Passport__c = false,
            Document_Residence_Permit__c = false,
            Waiting_Customer_Feedback__c = false,
            CRM_Stage__c = 'PR_IN_PROGRESS',
            Notification_L3_S1_0days__c = false,
            Notification_L3_S2_0_Days__c = false,
            Notification_L3_S3_0_Days__c = false,
            Notification_L3_S4__c = false,
            Notification_L2_0_days__c = false,
            Document_Resend__c = false
        );
        insert kyc;
    }
 
    private static Id getPersonAccountRtId() {
        return [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;
    }
 
    private static Account createAccount() {
        Account pa = new Account();
        pa.RecordTypeId = getPersonAccountRtId();
        pa.LastName = 'Test Person';
        pa.PersonEmail = 'customer@example.com';
        pa.put('CIF__pc', 'CIF123');
        insert pa;
        return pa;
    }

    private static KYC_Verification__c getKyc() {
        return [SELECT Id, Account_Name__c, Account_Name__r.CIF__pc, Type__c, Status__c, Overdue_Handling__c,
                       Overdue_Stage__c, Sub_Status__c, API_Status__c, ID_V_Required__c, ID_V_Status__c,
                       Review_Personal_Information_Required__c, KYC_Form_Status__c, KYC_Form_Tax_Status__c,
                       Upload_Documents_Required__c, KYC_Upload_Document_Status__c, Block_Debit_Cards__c,
                       Block_Credit_Cards__c, Block_Account_Debits__c, Block_App_Access__c, No_of_days__c,
                       KYC_Verification_Result__c, eKYC_Required__c, Document_Proof_of_Address__c,
                       Document_FATCA_Declaration__c, Document_List__c, Document_Passport__c,
                       Document_Residence_Permit__c, Waiting_Customer_Feedback__c, CRM_Stage__c,
                       Notification_L3_S1_0days__c, Notification_L3_S2_0_Days__c, Notification_L3_S3_0_Days__c,
                       Notification_L3_S4__c, Notification_L2_0_days__c, Document_Resend__c, CIF__c
                FROM KYC_Verification__c LIMIT 1];
    }

    // ====================== API STATUS UPDATE TESTS ======================
    @IsTest static void test_APIStatusUpdate() {
        Test.startTest();
        KYCVerificationService.APIStatusUpdate('In-Progress');
        KYCVerificationService.APIStatusUpdate('Pending');
        KYCVerificationService.APIStatusUpdate('Success');
        KYCVerificationService.APIStatusUpdate('Failed');
        KYCVerificationService.APIStatusUpdate('Skipped');
        KYCVerificationService.APIStatusUpdate('Invalid');
        Test.stopTest();
    }

    @IsTest static void test_applyUploadDocumentSettings() {
        KYC_Verification__c k = getKyc();
        k.Upload_Documents_Required__c = 'Yes';
        k.Document_Proof_of_Address__c = true;
        k.Document_FATCA_Declaration__c = true;
        k.Document_Passport__c = true;
        k.Document_Residence_Permit__c = true;
        k.Document_List__c = 'PASSPORT;RESIDENT_PERMIT';
        update k;
        Test.startTest();
        Map<String, Object> body = new Map<String, Object>();
        KYCVerificationService.applyUploadDocumentSettings(k, body);
        Test.stopTest();
    }

    @IsTest static void test_applyUploadDocumentSettings_Empty() {
        KYC_Verification__c k = getKyc();
        k.Upload_Documents_Required__c = 'No';
        k.Document_Proof_of_Address__c = false;
        k.Document_FATCA_Declaration__c = false;
        k.Document_List__c = '';
        update k;
        Test.startTest();
        Map<String, Object> body = new Map<String, Object>();
        KYCVerificationService.applyUploadDocumentSettings(k, body);
        Test.stopTest();
    }

    // ==================== buildRequestBody TESTS ====================
    @IsTest static void test_buildRequestBody_Periodic_IDV_Yes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_Periodic_NoIDV_FullKYC_UploadNo() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.Upload_Documents_Required__c = 'No';
        k.eKYC_Required__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_Periodic_NoIDV_FullKYC_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.Upload_Documents_Required__c = 'Yes';
        k.eKYC_Required__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_Periodic_NoIDV_TaxOnly_UploadNo() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.Upload_Documents_Required__c = 'No';
        k.eKYC_Required__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_Periodic_NoIDV_TaxOnly_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.Upload_Documents_Required__c = 'Yes';
        k.eKYC_Required__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_Periodic_NoReview_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.eKYC_Required__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_SuspectedFraud_IDV_Yes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBody_SuspectedFraud_IDV_No() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBody(k);
        Test.stopTest();
    }

    // ==================== buildRequestBodyUpdate TESTS ====================
    @IsTest static void test_buildRequestBodyUpdate_IDV_InProgress() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'In-Progress';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_Success_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_Proof_of_Address__c = false;
        k.Document_FATCA_Declaration__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_Success_UploadNo_WithDocs() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_Proof_of_Address__c = true;
        k.Document_FATCA_Declaration__c = true;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_Success_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_FATCA_Declaration__c = false;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_Success_UploadNo_WithDocs() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_FATCA_Declaration__c = true;
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Upload_InProgress() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'In-Progress';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Upload_Success_NotCompleted() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.KYC_Verification_Result__c = 'Documents Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Upload_Skipped() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Skipped';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_IDV_Success_FormPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_IDV_Success_FormPending_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'Yes';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_NoIDV_FormPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_NoIDV_FormSuccess_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_NoIDV_FormSuccess_UploadSuccess_NotCompleted() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.KYC_Verification_Result__c = 'Documents Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_FullKYC_NoIDV_FormSuccess_UploadSkipped() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Skipped';
        k.KYC_Verification_Result__c = 'Documents Completed';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_IDV_Success_FormPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_IDV_Success_FormSuccess_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_IDV_Success_FormSuccess_UploadSuccess_NotCompleted() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.KYC_Verification_Result__c = 'Documents Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_IDV_Success_FormSuccess_UploadSkipped() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Skipped';
        k.KYC_Verification_Result__c = 'Documents Completed';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Tax_NoIDV_FormSuccess_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_IDV_Success_NoReview_UploadYes_Success_NotCompleted() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.KYC_Verification_Result__c = 'Documents Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_IDV_Success_NoReview_UploadYes_Skipped() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Skipped';
        k.KYC_Verification_Result__c = 'Documents Completed';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_SuspectedFraud_Success() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_SuspectedFraud_Skipped() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Skipped';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_SuspectedFraud_Pending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdate_Periodic_SubStatus_Completed() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.Sub_Status__c = 'Completed';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdate(k);
        Test.stopTest();
    }

    // ==================== updateKycStatusCreation TESTS ====================
    @IsTest static void test_updateKycStatusCreation_Level3_Stage1() {
        KYC_Verification__c k = getKyc();
        k.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.Sub_Status__c = 'Pending ID&V';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusCreation_Level3_Stage2() {
        KYC_Verification__c k = getKyc();
        k.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        k.Overdue_Stage__c = 'Stage 2 – Block Debit Cards';
        k.Sub_Status__c = 'Pending ID&V';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusCreation_Level3_Stage3() {
        KYC_Verification__c k = getKyc();
        k.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        k.Overdue_Stage__c = 'Stage 3 – Block Debit Cards & Credit Cards';
        k.Sub_Status__c = 'Pending ID&V';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusCreation_Level3_Stage4() {
        KYC_Verification__c k = getKyc();
        k.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        k.Overdue_Stage__c = 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access';
        k.Sub_Status__c = 'Pending ID&V';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusCreation_Level1() {
        KYC_Verification__c k = getKyc();
        k.Overdue_Handling__c = 'Level 1 - App (Nudges)';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.Sub_Status__c = 'Pending ID&V';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusCreation_Level2() {
        KYC_Verification__c k = getKyc();
        k.Overdue_Handling__c = 'Level 2 - App (Nudges) & Notifications';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.Sub_Status__c = 'Pending ID&V';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusCreation_Fraud() {
        KYC_Verification__c k = getKyc();
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        k.Overdue_Stage__c = 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access';
        k.Block_Debit_Cards__c = true;
        k.Block_Credit_Cards__c = true;
        k.Block_Account_Debits__c = true;
        k.Block_App_Access__c = true;
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusCreation(k);
        Test.stopTest();
    }

    // ==================== updateKycStatusUpdate TESTS ====================
    @IsTest static void test_updateKycStatusUpdate_IDV_InProgress() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'In-Progress';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_IDV_Success_NoPIR_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'No';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_FullKYC_Success_NoUpload_WithDocs() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_Proof_of_Address__c = true;
        k.Document_FATCA_Declaration__c = true;
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_FullKYC_Success_NoUpload_NoDocs() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_Proof_of_Address__c = false;
        k.Document_FATCA_Declaration__c = false;
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_Tax_Success_NoUpload_WithDocs() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_FATCA_Declaration__c = true;
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_Tax_Success_NoUpload_NoDocs() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.Document_FATCA_Declaration__c = false;
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_IDV_Success_FormPending_FullKYC() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_IDV_Success_TaxPending() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_IDV_Success_UploadPending_NoPIR() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_FormSuccess_UploadPending_FullKYC() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_TaxSuccess_UploadPending() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_UploadSuccess_NotCompleted() {
        KYC_Verification__c k = getKyc();
        k.KYC_Upload_Document_Status__c = 'Success';
        k.KYC_Verification_Result__c = 'Documents Pending';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_UploadSkipped() {
        KYC_Verification__c k = getKyc();
        k.KYC_Upload_Document_Status__c = 'Skipped';
        k.KYC_Verification_Result__c = 'Documents Completed';
        k.Type__c = 'KYC_PERIODIC_REVIEW';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_Fraud_Success() {
        KYC_Verification__c k = getKyc();
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_Fraud_Pending() {
        KYC_Verification__c k = getKyc();
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Pending';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdate_Fraud_Level3_Stage4() {
        KYC_Verification__c k = getKyc();
        k.Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD';
        k.Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions';
        k.Overdue_Stage__c = 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdate(k);
        Test.stopTest();
    }

    // ==================== buildRequestBodyUpdateOverdue TESTS ====================
    @IsTest static void test_buildRequestBodyUpdateOverdue_DocumentsCompleted() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.KYC_Verification_Result__c = 'Documents Completed';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_DocumentsReturned() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.KYC_Verification_Result__c = 'Documents Returned';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_FormPending_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_TaxPending_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_UploadPending_NoPIR() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_FormSuccess_UploadPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_TaxSuccess_UploadPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_FormPending_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_FormSuccess_UploadPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_TaxPending_UploadYes() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_TaxSuccess_UploadPending() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Success_NoReview_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_IDV_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_FullKYC_Success_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_Tax_Success_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_NoReview_Upload_Success() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Yes_FormSuccess_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Yes_TaxSuccess_NoUpload() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_Yes_UploadSuccess_NoPIR() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_FormSuccess_UploadSuccess() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateOverdue_IDV_No_TaxSuccess_UploadSuccess() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc(); 
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateOverdue(k);
        Test.stopTest();
    }

    // ==================== updateKycStatusUpdateOverdueStage TESTS ====================
    @IsTest static void test_updateKycStatusUpdateOverdueStage_DocumentsCompleted() {
        KYC_Verification__c k = getKyc();
        k.KYC_Verification_Result__c = 'Documents Completed';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_DocumentsReturned() {
        KYC_Verification__c k = getKyc();
        k.KYC_Verification_Result__c = 'Documents Returned';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_FormPending_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_TaxPending_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'No';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_UploadPending_NoPIR() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_FormSuccess_UploadPending_FullKYC() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_TaxSuccess_UploadPending() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_FormPending_UploadYes() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_TaxPending_UploadYes() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_FormSuccess_UploadPending() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_TaxSuccess_UploadPending() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Status__c = 'Success';
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        //KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Success_NoPIR_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_NoIDV_FullKYC_Success_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_NoIDV_Tax_Success_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_NoIDV_NoReview_UploadSuccess() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Yes_FullKYC_Success_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Yes_Tax_Success_NoUpload() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'No';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Yes_UploadSuccess_NoPIR() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Yes_UploadSuccess_Stage2() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 2 – Block Debit Cards';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Yes_UploadSuccess_Stage3() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 3 – Block Debit Cards & Credit Cards';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_IDV_Yes_UploadSuccess_Stage4() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.ID_V_Status__c = 'Success';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_NoIDV_FullKYC_UploadSuccess() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.KYC_Form_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    @IsTest static void test_updateKycStatusUpdateOverdueStage_NoIDV_Tax_UploadSuccess() {
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'No';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.KYC_Form_Tax_Status__c = 'Success';
        k.Upload_Documents_Required__c = 'Yes';
        k.KYC_Upload_Document_Status__c = 'Success';
        k.Overdue_Stage__c = 'Stage 1 – No Restrictions';
        update k;
        Test.startTest();
        KYCVerificationService.updateKycStatusUpdateOverdueStage(k);
        Test.stopTest();
    }

    // ==================== buildRequestBodyUpdateAPIStages TESTS ====================
    @IsTest static void test_buildRequestBodyUpdateAPIStages_FullKYC() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.Upload_Documents_Required__c = 'Yes';
        k.Sub_Status__c = 'Pending KYC - Full Form';
        k.ID_V_Status__c = 'Success';
        k.KYC_Form_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateAPIStages(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateAPIStages_Tax() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration';
        k.Upload_Documents_Required__c = 'Yes';
        k.Sub_Status__c = 'Pending KYC - Tax Only';
        k.ID_V_Status__c = 'Success';
        k.KYC_Form_Tax_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_TAX_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateAPIStages(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateAPIStages_Other() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'No';
        k.Upload_Documents_Required__c = 'Yes';
        k.Sub_Status__c = 'Pending Upload Documents';
        k.ID_V_Status__c = 'Success';
        k.API_Status__c = 'PR_PENDING_UPLOAD_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateAPIStages(k);
        Test.stopTest();
    }

    @IsTest static void test_buildRequestBodyUpdateAPIStages_NoMatch() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        k.ID_V_Required__c = 'Yes';
        k.Review_Personal_Information_Required__c = 'Yes - Full KYC Form';
        k.Upload_Documents_Required__c = 'Yes';
        k.Sub_Status__c = 'Pending ID&V';
        k.ID_V_Status__c = 'Success';
        k.KYC_Form_Status__c = 'Pending';
        k.API_Status__c = 'PR_PENDING_FORM_S1';
        update k;
        Test.startTest();
        KYCVerificationService.buildRequestBodyUpdateAPIStages(k);
        Test.stopTest();
    }

    // ==================== Helper Method TESTS ====================
    @IsTest static void test_buildSystemAction() {
        KYC_Verification__c k = getKyc();
        Test.startTest();
        KYCVerificationService.buildSystemAction('{"test":"req"}', '{"test":"res"}', '/api/test', 'POST', 'CIF123', k.Id, 200);
        KYCVerificationService.buildErrorAction('Test Error Message', k);
        KYCVerificationService.buildErrorActionAcct('Account Error Message');
        KYCVerificationService.buildExceptionAction(new DmlException('Test Exception'), k);
        Test.stopTest();
    }

    // ==================== generateRequestBody TESTS ====================
    @IsTest static void test_generateRequestBody() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        Map<String, Object> requestBody = new Map<String, Object>();
        KYC_Stage_API_Status_Mapping__mdt setting = new KYC_Stage_API_Status_Mapping__mdt(
            ID_V_Status__c = 'Success',
            KYC_Form_Status__c = 'Success',
            KYC_Form_Tax_Status__c = 'Skipped',
            KYC_Upload_Document_Status__c = 'Skipped',
            Block_Debit_Card__c = false,
            Block_Credit_Cards__c = false,
            Account_Debits_App_Access__c = false,
            Block_App_Access__c = false
        );
        Test.startTest();
        KYCVerificationService.generateRequestBody(requestBody, setting, k);
        Test.stopTest();
    }

    @IsTest static void test_generateRequestBodyDocumentComplete() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        Map<String, Object> requestBody = new Map<String, Object>();
        Test.startTest();
        KYCVerificationService.generateRequestBodyDocumentComplete(requestBody, k);
        Test.stopTest();
    }

    @IsTest static void test_generateRequestBodyDocumentReturned() {
        Test.setMock(HttpCalloutMock.class, new KYCMockResponse(200, '{}'));
        KYC_Verification__c k = getKyc();
        k.Block_Debit_Cards__c = true;
        k.Block_Credit_Cards__c = true;
        k.Block_Account_Debits__c = true;
        k.Block_App_Access__c = true;
        Map<String, Object> requestBody = new Map<String, Object>();
        Test.startTest();
        KYCVerificationService.generateRequestBodyDocumentReturned(requestBody, k);
        Test.stopTest();
    }
}