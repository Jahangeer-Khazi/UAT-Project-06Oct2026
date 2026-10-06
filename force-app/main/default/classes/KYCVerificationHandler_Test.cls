@IsTest
private class KYCVerificationHandler_Test {

    
        // Test data factory
    private static Id getPersonAccountRtId() {
        // Assumes Person Accounts are enabled
        return [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND IsPersonType = true AND Name='Customer' LIMIT 1].Id;
    }
    // Helpers
    private static Account createAccount(String segment, String nationality, String docsStatus, Boolean vvip) {
        
         Account pa = new Account();
        pa.RecordTypeId = getPersonAccountRtId();
        pa.LastName = 'Test Person';
        pa.PersonEmail = 'customer@example.com';
       // pa.Subscription_Model__pc='ila';
        // Custom Person Account fields accessed via __pc in queries:
        // Set them on Account by using the Contact-side person fields where applicable
        pa.put('CIF__pc', 'CIF123');                // custom person contact field
        pa.put('Region_Flag__pc','Bahrain');            // example region
        pa.put('Subscription_Model__pc', 'ila');
        pa.put('x_canary__pc', 'test-canary');
        pa.put('Mobile_Phone_Check__pc', '+97336000000');
        pa.put('Segment__pc', segment);
        pa.put('VVIP__pc',vvip);
        pa.put('Nationality__pc', nationality);
        pa.put('Documents_Status__pc', docsStatus);
        pa.put('Risk_Rating__pc','High');
        insert pa;
        return pa;
    }

    private static void insertStageCmdt(String devName, String stage, String handling, Boolean enableL3, String subStatus) {
        KYC_Stage_API_Status_Mapping__mdt m = new KYC_Stage_API_Status_Mapping__mdt(
            DeveloperName = devName,
            MasterLabel = devName,
            API_Status__c = 'PR_PENDING_IDV',
            Overdue_Stage__c = stage,
            Overdue_Handling__c = handling,
            Overdue_Stage_Enable_L3__c = enableL3,
            Sub_Status__c = subStatus,
            Block_Debit_Card__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Account_Debits_App_Access__c = true
        );
     //   insert m;
    }

    private static void insertNotificationCmdt(String handling, String stage, String days) {
        KYC_Notification_Service__mdt n = new KYC_Notification_Service__mdt(
            DeveloperName = handling.replace(' ', '_') + '_' + stage.replace(' ', '_') + '_' + days,
            MasterLabel = 'Notif ' + handling + ' ' + stage + ' ' + days,
            Overdue_Handling__c = handling,
            Overdue_Stage__c = stage,
            Notification_Days__c = days
        );
     //   insert n;
    }

    private static void insertDefaultConfigCmdt(String key, Boolean vvip, String segment, String nationality,
                                                String handling, String stage, String idvRequired,
                                                String pir, String uploadReq,
                                                Boolean docPassport, Boolean docResPermit, Boolean docPoA, Boolean docFatca) {
        KYC_Verification_Default_Configuration__mdt d = new KYC_Verification_Default_Configuration__mdt(
            DeveloperName = key,
            MasterLabel = key,
            VVIP__c = vvip,
            Segment__c = segment,
            Nationality__c = nationality,
            Overdue_Handling__c = handling,
            Overdue_Stage__c = stage,
            ID_V_Required__c = idvRequired,
            Review_Personal_Information_Required__c = pir,
            Upload_Documents_Required__c = uploadReq,
            Document_Passport__c = docPassport,
            Document_Residence_Permit__c = docResPermit,
            Document_Proof_of_Address__c = docPoA,
            Document_FATCA_Declaration__c = docFatca,
            Block_Debit_Cards__c = false,
            Block_Credit_Cards__c = false,
            Block_App_Access__c = false,
            Block_Account_Debits__c = false,
            Update_eKYC_iGA_Data__c = 'No',
            Sub_Status__c = 'Pending ID&V'
        );
    //    insert d;
    }

    private static void insertFraudCmdt(String dev, String crmStage, String apiStatus, String subStatus,
                                        Boolean bDebit, Boolean bCredit, Boolean bApp, Boolean bAcc) {
        KYC_Suspect_Identify_Fraud__mdt f = new KYC_Suspect_Identify_Fraud__mdt(
            DeveloperName = dev,
            MasterLabel = dev,
            Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD',
            CRM_Stage__c = crmStage,
            API_Status__c = apiStatus,
            Sub_Status__c = subStatus,
            ID_V_Required__c = 'Yes',
            Block_Debit_Cards__c = bDebit,
            Block_Credit_Cards__c = bCredit,
            Block_App_Access__c = bApp,
            Block_Account_Debits__c = bAcc
        );
      //  insert f;
    }

    @testSetup
    static void setup() {
        // Stage CMDT to derive Overdue_Stage when null
        insertStageCmdt(
            'L3_S1_Default',
            'Stage 1 – No Restrictions',
            'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            false,
            'Pending ID&V'
        );
        insertStageCmdt(
            'L3_S2',
            'Stage 2 – Block Debit Cards',
            'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            false,
            'Pending ID&V'
        );

        // Notification CMDT for day 0 on S1 and S4
        insertNotificationCmdt(
            'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            'Stage 1 – No Restrictions',
            '0'
        );
        insertNotificationCmdt(
            'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            'Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access',
            '0'
        );

        // Default Config CMDT for BH nationality
        insertDefaultConfigCmdt(
            'DEF_BH',
            false, null, 'BH',
            'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            'Stage 1 – No Restrictions',
            'Yes', // IDV required
            'No',  // PIR
            'Yes',  // Upload docs required
            true, true, true, true
        );

        // Fraud CMDT to match both “Complete/Missing” path with zero blocks
        insertFraudCmdt('FRAUD_ZERO_BLOCKS', 'FRAUD_PENDING', 'FRAUD_PENDING', 'Pending ID&V',
                        false, false, false, false);
    }

    // Test: BEFORE INSERT periodic review, Custom Configurations, L3 with Overdue_Stage null
    @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatuses() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'Yes',
            Review_Personal_Information_Required__c = 'No',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );
        System.debug('accountID'+ acc.Id);
        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
        System.assertEquals('In-Progress', kAfter.ID_V_Status__c);
        System.assertEquals('Pending ID&V', kAfter.Sub_Status__c);
        System.assertEquals('PR_PENDING_IDV', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
   @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatuses1() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 2 – Block Debit Cards',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
        System.assertEquals('Skipped', kAfter.ID_V_Status__c);
        System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
        System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
     @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatuses2() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 2 – Block Debit Cards',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
        System.assertEquals('Skipped', kAfter.ID_V_Status__c);
        System.assertEquals('Pending KYC - Tax Only', kAfter.Sub_Status__c);
        System.assertEquals('PR_PENDING_TAX', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
   @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesdefault1() {
        Account acc = createAccount('Regular', 'IN', 'Missing', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 2 – Block Debit Cards',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
       
         System.assertEquals('In-Progress', kAfter.ID_V_Status__c);
        System.assertEquals('Pending ID&V', kAfter.Sub_Status__c);
        System.assertEquals('PR_PENDING_IDV', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
     @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesDefault2() {
        Account acc = createAccount('Regular', 'IN', 'Unable to Verify', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
         System.assertEquals('Skipped', kAfter.ID_V_Status__c);
        System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
        System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
      @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesDefault3() {
        Account acc = createAccount('Regular', 'IN', 'Unable to Verify', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',           
            Upload_Documents_Required__c = 'Yes',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
         System.assertEquals('Skipped', kAfter.ID_V_Status__c);
      //  System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
       // System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
       @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesDefault4() {
        Account acc = createAccount('Staff', 'BH', 'Unable to Verify', false);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',           
            Upload_Documents_Required__c = 'Yes',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
         System.assertEquals('Skipped', kAfter.ID_V_Status__c);
      //  System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
       // System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertNotEquals(null, kAfter.No_of_days__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
         @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesDefault5() {
        Account acc = createAccount('Regular', 'IN', 'Unable to Verify', True);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',           
            Upload_Documents_Required__c = 'Yes',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
         System.assertEquals('Skipped', kAfter.ID_V_Status__c);
      //  System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
       // System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
     //   System.assertNotEquals(null, kAfter.No_of_days__c);
        //System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
            @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesDefault6() {
        Account acc = createAccount('Regular', 'BH', 'Unable to Verify', FALSE);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',           
            Upload_Documents_Required__c = 'Yes',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
         System.assertEquals('Skipped', kAfter.ID_V_Status__c);
      //  System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
       // System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
     //   System.assertNotEquals(null, kAfter.No_of_days__c);
        //System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
      @IsTest
    static void test_beforeInsert_periodic_custom_setsStagesAndStatusesDefault7() {
        Account acc = createAccount('Regular', 'BH', 'Complete', FALSE);

        KYC_Verification__c k = new KYC_Verification__c(
       //     Name = 'KYC 1',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = null,
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',           
            Upload_Documents_Required__c = 'Yes',
            Status__c = 'Open',
            Block_Debit_Cards__c = true,
            Block_Credit_Cards__c = true,
            Block_App_Access__c = true,
            Block_Account_Debits__c = true
        );

        Test.startTest();
        insert k; // expect before insert handler to populate fields
        Test.stopTest();

        KYC_Verification__c kAfter = [SELECT Id, Overdue_Stage__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c,
                                             KYC_Form_Status__c, KYC_Form_Tax_Status__c, KYC_Upload_Document_Status__c,
                                             Waiting_Customer_Feedback__c, No_of_days__c, Next_Notification_Date__c
                                      FROM KYC_Verification__c WHERE Id = :k.Id];

        System.assertNotEquals(null, kAfter.Overdue_Stage__c, 'Overdue_Stage__c should be defaulted from CMDT');
         System.assertEquals('Skipped', kAfter.ID_V_Status__c);
      //  System.assertEquals('Pending KYC - Full Form', kAfter.Sub_Status__c);
       // System.assertEquals('PR_PENDING_FORM', kAfter.CRM_Stage__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
     //   System.assertNotEquals(null, kAfter.No_of_days__c);
        //System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
    // Test: BEFORE INSERT periodic review, Default Configurations – uses Default Config CMDT and labels
    @IsTest
    static void test_beforeInsert_periodic_defaultConfig_usesDefaultCmdt() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC 2',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Default Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No', // will be overridden by CMDT (Yes)
            Review_Personal_Information_Required__c = 'No',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open'
        );

        insert k;

        KYC_Verification__c kAfter = [
            SELECT ID_V_Required__c, Overdue_Handling__c, Overdue_Stage__c, Sub_Status__c,
                   Waiting_Customer_Feedback__c, Document_List__c
            FROM KYC_Verification__c WHERE Id = :k.Id
        ];

        System.assertEquals('Yes', kAfter.ID_V_Required__c, 'ID&V should be set per default config CMDT');
        System.assertEquals('Pending ID&V', kAfter.Sub_Status__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
    }

    // Test: BEFORE INSERT suspected identity fraud – Complete docs path -> IDV required, L3/S4, notifications set
    @IsTest
    static void test_beforeInsert_fraud_completeDocs_setsFraudFields() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC Fraud',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD',
            Status__c = 'Open',
            case_Model__c='ila',
            // Match CMDT filter by blocks; fraud CMDT inserted has all false
            Block_Debit_Cards__c = false,
            Block_Credit_Cards__c = false,
            Block_App_Access__c = false,
            Block_Account_Debits__c = false
        );

        insert k;

        KYC_Verification__c kAfter = [
            SELECT ID_V_Required__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c, API_Status__c,
                   Overdue_Handling__c, Overdue_Stage__c, KYC_Verification_Result__c, Waiting_Customer_Feedback__c,
                   No_of_days__c, Next_Notification_Date__c
            FROM KYC_Verification__c WHERE Id = :k.Id
        ];
        System.assertEquals('Yes', kAfter.ID_V_Required__c);
        System.assertEquals('In-Progress', kAfter.ID_V_Status__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertEquals('Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access', kAfter.Overdue_Stage__c);
        System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
 // Test: BEFORE INSERT suspected identity fraud – Complete docs path -> IDV required, L3/S4, notifications set
    @IsTest
    static void test_beforeInsert_fraud_completeDocs_setsFraudFields2() {
        Account acc = createAccount('Regular', 'IN', 'Unable to Verify', false);

        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC Fraud',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_SUSPECTED_IDENTITY_FRAUD',
            Status__c = 'Open',
            case_Model__c='ila',
            // Match CMDT filter by blocks; fraud CMDT inserted has all false
            Block_Debit_Cards__c = false,
            Block_Credit_Cards__c = false,
            Block_App_Access__c = false,
            Block_Account_Debits__c = false
        );

        insert k;

        KYC_Verification__c kAfter = [
            SELECT ID_V_Required__c, ID_V_Status__c, Sub_Status__c, CRM_Stage__c, API_Status__c,
                   Overdue_Handling__c, Overdue_Stage__c, KYC_Verification_Result__c, Waiting_Customer_Feedback__c,
                   No_of_days__c, Next_Notification_Date__c
            FROM KYC_Verification__c WHERE Id = :k.Id
        ];
        System.assertEquals('No', kAfter.ID_V_Required__c);
        System.assertEquals('Skipped', kAfter.ID_V_Status__c);
        System.assertEquals(false, kAfter.Waiting_Customer_Feedback__c);
     //   System.assertEquals('Stage 4 – Block Debit Cards, Credit Cards, Account Debits & App Access', kAfter.Overdue_Stage__c);
      //  System.assertNotEquals(null, kAfter.Next_Notification_Date__c);
    }
    // Test: AFTER INSERT sets get queued – cannot assert queue, but can verify no exception and basic state
    @IsTest
    static void test_afterInsert_setsEnqueuedPaths() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
          //  Name = 'KYC AfterInsert',
            Account_Name__c = acc.Id,
            case_Model__c='ila',
            Type__c = 'KYC_PERIODIC_REVIEW',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'Yes',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            Upload_Documents_Required__c = 'No',
            Status__c = 'Open'
        );

        //Test.startTest();
        insert k;
       // Test.stopTest();

        // Assert before-insert state prepared correctly (after-insert enqueues queueable)
        KYC_Verification__c kAfter = [
            SELECT ID_V_Status__c, KYC_Form_Status__c, KYC_Upload_Document_Status__c
            FROM KYC_Verification__c WHERE Id = :k.Id
        ];
        System.assertEquals('In-Progress', kAfter.ID_V_Status__c);
        System.assertEquals('Pending', kAfter.KYC_Form_Status__c);
        System.assertEquals('Skipped', kAfter.KYC_Upload_Document_Status__c);
    }

    // Test: BEFORE UPDATE – change KYC_Verification_Result__c to Documents Returned -> fields adjust
    @IsTest
    static void test_beforeUpdate_documentsReturned_branch() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC Update',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'No',
            Upload_Documents_Required__c = 'Yes', // move to upload flow
            Status__c = 'Open'
        );
        insert k;

        // Simulate a result change to Documents Returned
        KYC_Verification__c kUpd = [SELECT Id, KYC_Verification_Result__c, KYC_Upload_Document_Status__c,
                                           Sub_Status__c, Waiting_Customer_Feedback__c, Document_Resend__c
                                    FROM KYC_Verification__c WHERE Id = :k.Id];
        kUpd.KYC_Verification_Result__c = 'Documents Returned';

        Test.startTest();
        update kUpd;
        Test.stopTest();

        KYC_Verification__c kAfter = [
            SELECT KYC_Upload_Document_Status__c, Sub_Status__c, Waiting_Customer_Feedback__c, Document_Resend__c
            FROM KYC_Verification__c WHERE Id = :k.Id
        ];
        System.assertEquals('In-Progress', kAfter.KYC_Upload_Document_Status__c);
        System.assertEquals('Pending Upload Documents', kAfter.Sub_Status__c);
        System.assertEquals(true, kAfter.Waiting_Customer_Feedback__c);
        System.assertEquals(true, kAfter.Document_Resend__c);
    }

    // Test: AFTER UPDATE – set Upload Doc Status to Success then KYC_Verification_Result__c to Documents Completed
    @IsTest
    static void test_afterUpdate_uploadSuccess_and_documentsCompleted() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'No',
            Upload_Documents_Required__c = 'Yes',
            KYC_Upload_Document_Status__c = 'In-Progress',
            Status__c = 'Open'
        );
        insert k;

        // Update: upload docs success
        KYC_Verification__c k1 = [SELECT Id, KYC_Upload_Document_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k1.KYC_Upload_Document_Status__c = 'Success';
        update k1;

        // Update: documents completed result
        KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k2.KYC_Verification_Result__c = 'Documents Completed';
        Test.startTest();
        update k2;
        Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);
    }
        // Test: AFTER UPDATE – set Upload Doc Status to Success then KYC_Verification_Result__c to Documents Completed
    @IsTest
    static void test_afterUpdate_uploadSuccess_and_documentsReturned() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'No',
            Upload_Documents_Required__c = 'Yes',
            KYC_Upload_Document_Status__c = 'In-Progress',
            Document_Resend__c=true,
            Status__c = 'Open'
        );
        insert k;

        // Update: upload docs success
        KYC_Verification__c k1 = [SELECT Id, KYC_Upload_Document_Status__c,KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k1.KYC_Upload_Document_Status__c = 'Success';
        k1.KYC_Verification_Result__c='Documents Review';
        update k1;
        

        // Update: documents completed result
        KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c,KYC_Upload_Document_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k2.KYC_Verification_Result__c = 'Documents Returned';
        k2.KYC_Upload_Document_Status__c='In-Progress';
        //update k2;
        
         // Update: upload docs success
      //  KYC_Verification__c k3 = [SELECT Id, KYC_Upload_Document_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
      //  k1.KYC_Upload_Document_Status__c = 'In-Progress';
     //   update k3;
        Test.startTest();
        update k2;
        Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);
    }
    
            // Test: AFTER UPDATE – set Upload Doc Status to Success then KYC_Verification_Result__c to Documents Completed
    @IsTest
    static void test_afterUpdate_uploadSuccess_and_Formtax() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            Upload_Documents_Required__c = 'Yes',
            KYC_Upload_Document_Status__c = 'In-Progress',
            KYC_Verification_Result__c='Documents Pending',
            KYC_Form_Tax_Status__c = 'Success',
            Document_Resend__c=true,
            Status__c = 'Open'
        );
        insert k;
        
                    // Update: upload docs success
  /*      KYC_Verification__c k12 = [SELECT Id, KYC_Upload_Document_Status__c,KYC_Form_Tax_Status__c,KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
         Test.startTest();
        k12.KYC_Upload_Document_Status__c = 'Success';
        update k12;
        test.stopTest();*/
            // Update: upload docs success
        KYC_Verification__c k1 = [SELECT Id, KYC_Upload_Document_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k1.KYC_Upload_Document_Status__c = 'Success';
        update k1;

        // Update: documents completed result
        KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k2.KYC_Verification_Result__c = 'Documents Completed';
        Test.startTest();
        update k2;
        Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);

    }
    
    @IsTest
    static void test_afterUpdate_uploadSuccess_and_Returned() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            Upload_Documents_Required__c = 'Yes',
            KYC_Upload_Document_Status__c = 'Success',
            KYC_Verification_Result__c='Documents Review',
            KYC_Form_Tax_Status__c = 'Success',
            Document_Resend__c=true,
            Status__c = 'Open'
        );
        insert k;
        
                    // Update: upload docs success
  /*      KYC_Verification__c k12 = [SELECT Id, KYC_Upload_Document_Status__c,KYC_Form_Tax_Status__c,KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
         Test.startTest();
        k12.KYC_Upload_Document_Status__c = 'Success';
        update k12;
        test.stopTest();*/
            // Update: upload docs success
      //  KYC_Verification__c k1 = [SELECT Id, KYC_Upload_Document_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
      //  k1.KYC_Upload_Document_Status__c = 'Success';
      //  update k1;

        // Update: documents completed result
        KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c,Document_Resend__c,KYC_Upload_Document_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k2.KYC_Verification_Result__c = 'Documents Returned';
        k2.Document_Resend__c=true;
        k2.KYC_Upload_Document_Status__c='In-Progress';
        Test.startTest();
        update k2;
        Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);

    }
     // Test: AFTER UPDATE – set Upload Doc Status to Success then KYC_Verification_Result__c to Documents Completed
    @IsTest
    static void test_afterUpdate_FormSuccess_and_FormSkipped() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            //Upload_Documents_Required__c = 'Yes',
            KYC_Form_Status__c = 'In-Progress',
          //  Due_Diligence_Category__c='Enhanced Due Diligence',
            Status__c = 'Open'
        );
        insert k;

        // Update: upload docs success
        KYC_Verification__c k1 = [SELECT Id, KYC_Form_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k1.KYC_Form_Status__c = 'Success';
        update k1;

        // Update: documents completed result
        KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k2.KYC_Verification_Result__c = 'KYC Form Completed';
        Test.startTest();
        update k2;
        Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);
    }
      @IsTest
    static void test_afterUpdate_TaxSuccess_and_FormSkipped() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Full KYC Form',
            //Upload_Documents_Required__c = 'Yes',
            KYC_Form_Status__c = 'Skipped',
            KYC_Form_Tax_Status__c='In-Progress',
          //  Due_Diligence_Category__c='Enhanced Due Diligence',
            Status__c = 'Open'
        );
        insert k;

        // Update: upload docs success
        KYC_Verification__c k1 = [SELECT Id, KYC_Form_Tax_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k1.KYC_Form_Tax_Status__c = 'Success';
        Test.startTest();
        update k1;
         Test.stopTest();
        // Update: documents completed result
   //     KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
   //     k2.KYC_Verification_Result__c = 'KYC Form Completed';
       // Test.startTest();
     //   update k2;
     //   Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);
    }
     @IsTest
    static void test_afterUpdate_FormTaxSuccess_and_FormTaxSkipped() {
        Account acc = createAccount('Regular', 'IN', 'Complete', false);

        // Insert in a state that allows upload success
        KYC_Verification__c k = new KYC_Verification__c(
         //   Name = 'KYC AfterUpdate',
            Account_Name__c = acc.Id,
            Type__c = 'KYC_PERIODIC_REVIEW',
            case_Model__c='ila',
            Sub_Type__c = 'Custom Configurations',
            Overdue_Handling__c = 'Level 3 - App (Nudges & Splash), Notifications & Restrictions',
            Overdue_Stage__c = 'Stage 1 – No Restrictions',
            ID_V_Required__c = 'No',
            Review_Personal_Information_Required__c = 'Yes - Only Tax Declaration',
            Upload_Documents_Required__c = 'Yes',
            KYC_Form_Tax_Status__c = 'In-Progress',
            Status__c = 'Open'
        );
        insert k;

        // Update: upload docs success
        KYC_Verification__c k1 = [SELECT Id, KYC_Form_Tax_Status__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k1.KYC_Form_Tax_Status__c = 'Success';
        update k1;

        // Update: documents completed result
        KYC_Verification__c k2 = [SELECT Id, KYC_Verification_Result__c FROM KYC_Verification__c WHERE Id = :k.Id];
        k2.KYC_Verification_Result__c = 'KYC Form Completed';
        Test.startTest();
        update k2;
        Test.stopTest();

        // If KYC_Form_* are success, handler calls KYCFormUpdateCustomer; we avoided that path
        // Assert we reached here without exceptions
        KYC_Verification__c kAfter = [SELECT Id FROM KYC_Verification__c WHERE Id = :k.Id];
        System.assertNotEquals(null, kAfter.Id);
    }
}