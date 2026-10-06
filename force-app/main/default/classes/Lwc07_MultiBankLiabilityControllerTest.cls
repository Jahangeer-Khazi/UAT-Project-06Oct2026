@IsTest
public class Lwc07_MultiBankLiabilityControllerTest {

    private static final String PRE_SCREENER_QUEUE = 'Loan_Pre_Screer_Queue';
    private static final String OPERATIONS_QUEUE = 'Loan_Operations_Team';
    private static final String BASE_CASE_SUBJECT = 'Multi-Bank Liability Test Case';

    @TestSetup
    static void setupTestData() {
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(
                CIF__pc = '123456',
                Subscription_Model__pc = 'alburaq',
                CustomerStatus__c = null,
                Archived__pc = false
            ),
            'TestFactoryDefaults.AccountDefaults',
            true
        );

        Id loanRecordTypeId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Loan_Application')
            .getRecordTypeId();

        Case testCase = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = loanRecordTypeId,
                Type = 'New Loan / Finance Application',
                ContactId = testAccount.PersonContactId,
                AccountId = testAccount.Id,
                Case_Model__c = 'alburaq',
                //Type = 'Loan Application',
                Subject = BASE_CASE_SUBJECT,
                Region_Flag__c = 'Bahrain'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        String firstEntity = getFirstActiveEntity();
        String initialJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 1000,
                'liabilityID' => 'LN111111'
            }
        });

        CaseAnnex__c testCaseAnnex = new CaseAnnex__c(
            Case__c = testCase.Id,
            cx_ln_Requested_Loan_Finance_Amount__c = 50000,
            cx_ln_Requested_Duration_Months__c = 24,
            cx_ln_Monthly_Instalment__c = 2200,
            cx_ln_Approved_Loan_Amount__c = 50000,
            cx_ln_Approved_Duration_Months__c = 24,
            cx_ln_Approved_Installment_Amount__c = 2200,
            cx_ln_ApprovedInterestProfitRateReducing__c = 5.5,
            cx_ln_Requested_Processing_Fees__c = 100,
            cx_ln_Requested_Vat_Processing_Fees__c = 10,
            cx_ln_Requested_MultiBankLiabilities__c = initialJson,
            cx_ln_Approved_Buyout_Amount__c = 1000,
            cx_ln_TotalLiabilitiesAmount__c = 0,
            cx_ln_Approved_PreInsuranceStatus__c = 'Approved',
            cx_ln_Approved_Insurance_Premium__c = 'Upfront',
            cx_ln_Approved_insurance__c = true,
            cx_ln_APR__c = 6.2,
            cx_ln_ApprovedProcessing_Fee_Type__c = 'Upfront',
            cx_ln_Approved_First_installment_date__c = Date.today().addDays(30),
            cx_ln_Product__c = 'Unsecured'
        );
        insert testCaseAnnex;
    }

    @IsTest
    static void testGetInitializationData_CurrentUser() {
        Case testCase = getBaseCase();
        Boolean expectedAdmin = isCurrentUserAdmin();

        Test.startTest();
        Lwc07_MultiBankLiabilityController.InitializationResponse result =
            Lwc07_MultiBankLiabilityController.getInitializationData(testCase.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Initialization response should not be null.');
        System.assertNotEquals(null, result.caseAnnexId, 'Case Annex Id should be returned.');
        System.assertNotEquals(null, result.multiBankLiabilitiesJson, 'Stored JSON should be returned.');
        System.assertEquals(1000, result.approvedBuyoutAmount, 'Stored buyout amount should be returned.');
        System.assertNotEquals(null, result.entityOptions, 'Metadata options should be returned.');
        System.assert(result.entityOptions.size() > 0, 'At least one active Entity/Bank option is expected.');
        System.assertNotEquals(null, result.permissions, 'Permissions should be returned.');
        System.assertEquals(expectedAdmin, result.permissions.isAdmin, 'Admin flag must match the current running user.');
    }

    @IsTest
    static void testGetInitializationData_PreScreenerOwner() {
        Case testCase = getBaseCase();
        testCase.OwnerId = getQueueId(PRE_SCREENER_QUEUE);
        update testCase;

        Test.startTest();
        Lwc07_MultiBankLiabilityController.InitializationResponse result =
            Lwc07_MultiBankLiabilityController.getInitializationData(testCase.Id);
        Test.stopTest();

        System.assertEquals(true, result.permissions.isPreScreenerContext,
            'Pre-Screener queue ownership should be detected.');
        System.assertEquals(false, result.permissions.isOperationsContext,
            'Operations context should be false.');
        System.assertEquals(true, result.permissions.canEditEntityOutstanding,
            'Pre-Screener context can edit Entity/Outstanding.');
        System.assertEquals(true, result.permissions.canAddRow,
            'Pre-Screener context can add rows.');
        System.assertEquals(true, result.permissions.canModifySelection,
            'Pre-Screener context can modify selection.');
        System.assertEquals(true, result.permissions.canModifyTable,
            'Pre-Screener context can modify the table.');

        if (result.permissions.isAdmin) {
            System.assertEquals(true, result.permissions.showLiabilityId,
                'Admin override keeps Liability ID visible.');
            System.assertEquals(true, result.permissions.canEditLiabilityId,
                'Admin override allows Liability ID editing.');
        } else {
            System.assertEquals(false, result.permissions.showLiabilityId,
                'Liability ID should be hidden for non-admin Pre-Screener context.');
            System.assertEquals(false, result.permissions.canEditLiabilityId,
                'Liability ID should not be editable for non-admin Pre-Screener context.');
        }
    }

    @IsTest
    static void testGetInitializationData_OperationsOwner() {
        Case testCase = getBaseCase();
        testCase.OwnerId = getQueueId(OPERATIONS_QUEUE);
        update testCase;

        Test.startTest();
        Lwc07_MultiBankLiabilityController.InitializationResponse result =
            Lwc07_MultiBankLiabilityController.getInitializationData(testCase.Id);
        Test.stopTest();

        System.assertEquals(false, result.permissions.isPreScreenerContext,
            'Pre-Screener context should be false.');
        System.assertEquals(true, result.permissions.isOperationsContext,
            'Operations queue ownership should be detected.');
        System.assertEquals(true, result.permissions.canEditLiabilityId,
            'Operations context can edit Liability ID.');
        System.assertEquals(true, result.permissions.showLiabilityId,
            'Liability ID should be visible in Operations context.');
        System.assertEquals(true, result.permissions.canModifySelection,
            'Operations context can modify selection.');
        System.assertEquals(true, result.permissions.canModifyTable,
            'Operations context can modify the table.');

        System.assertEquals(result.permissions.isAdmin, result.permissions.canEditEntityOutstanding,
            'Only an Admin override can edit Entity/Outstanding in Operations context.');
        System.assertEquals(result.permissions.isAdmin, result.permissions.canAddRow,
            'Only an Admin override can add rows in Operations context.');
    }

    @IsTest
    static void testSaveMultiBankLiabilities_PreScreenerAddRowAndCalculate() {
        Case testCase = getBaseCase();
        testCase.OwnerId = getQueueId(PRE_SCREENER_QUEUE);
        update testCase;

        String firstEntity = getPersistedEntity(testCase.Id);
        String secondEntity = getActiveEntityExcluding(firstEntity);
        Boolean currentUserIsAdmin = isCurrentUserAdmin();

        String submittedJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 1250,
                'liabilityID' => 'LN111111'
            },
            new Map<String, Object>{
                'Id' => '2',
                'selected' => true,
                'entity' => secondEntity,
                'outstanding' => 500,
                'liabilityID' => currentUserIsAdmin ? 'LN222222' : ''
            }
        });

        Test.startTest();
        Lwc07_MultiBankLiabilityController.SaveResponse result =
            Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities(testCase.Id, submittedJson);
        Test.stopTest();

        System.assertEquals(1750, result.approvedBuyoutAmount,
            'Approved Buyout Amount should be calculated from both selected rows.');

        CaseAnnex__c updatedAnnex = [
            SELECT cx_ln_Requested_MultiBankLiabilities__c,
                   cx_ln_Approved_Buyout_Amount__c
            FROM CaseAnnex__c
            WHERE Case__c = :testCase.Id
            LIMIT 1
        ];
        System.assertEquals(1750, updatedAnnex.cx_ln_Approved_Buyout_Amount__c,
            'Approved Buyout Amount should be persisted.');

        List<Object> rows = (List<Object>)JSON.deserializeUntyped(
            updatedAnnex.cx_ln_Requested_MultiBankLiabilities__c
        );
        System.assertEquals(2, rows.size(), 'Two rows should be stored after Add Row.');
    }

    @IsTest
    static void testSaveMultiBankLiabilities_OperationsEditAndSelection() {
        Case testCase = getBaseCase();
        testCase.OwnerId = getQueueId(OPERATIONS_QUEUE);
        update testCase;

        String firstEntity = getPersistedEntity(testCase.Id);
        String submittedJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => false,
                'entity' => firstEntity,
                'outstanding' => 1000,
                'liabilityID' => 'LN-OPS-UPDATED'
            }
        });

        Test.startTest();
        Lwc07_MultiBankLiabilityController.SaveResponse result =
            Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities(testCase.Id, submittedJson);
        Test.stopTest();

        System.assertEquals(0, result.approvedBuyoutAmount,
            'Deselected rows should not contribute to Approved Buyout Amount.');

        List<Object> rows = (List<Object>)JSON.deserializeUntyped(result.multiBankLiabilitiesJson);
        Map<String, Object> savedRow = (Map<String, Object>)rows[0];
        System.assertEquals('LN-OPS-UPDATED', String.valueOf(savedRow.get('liabilityID')),
            'Liability ID should be updated in Operations context.');
        System.assertEquals(false, (Boolean)savedRow.get('selected'),
            'Selection state should be saved.');
    }

    @IsTest
    static void testSaveMultiBankLiabilities_DuplicateEntityRejected() {
        Case testCase = moveBaseCaseToPreScreener();
        String firstEntity = getPersistedEntity(testCase.Id);

        String submittedJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 1000,
                'liabilityID' => 'LN111111'
            },
            new Map<String, Object>{
                'Id' => '2',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 500,
                'liabilityID' => ''
            }
        });

        Test.startTest();
        assertSaveThrows(testCase.Id, submittedJson, 'Duplicate Entity/Bank should be rejected.');
        Test.stopTest();
    }

    @IsTest
    static void testSaveMultiBankLiabilities_NegativeOutstandingRejected() {
        Case testCase = moveBaseCaseToPreScreener();
        String firstEntity = getPersistedEntity(testCase.Id);

        String submittedJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => -1,
                'liabilityID' => 'LN111111'
            }
        });

        Test.startTest();
        assertSaveThrows(testCase.Id, submittedJson, 'Negative Outstanding Amount should be rejected.');
        Test.stopTest();
    }

    @IsTest
    static void testSaveMultiBankLiabilities_InvalidJsonShapesRejected() {
        Case testCase = moveBaseCaseToPreScreener();

        Test.startTest();
        assertSaveThrows(testCase.Id, '{invalidJson', 'Malformed JSON should be rejected.');
        assertSaveThrows(testCase.Id, '{"Id":"1"}', 'A JSON object instead of an array should be rejected.');
        assertSaveThrows(testCase.Id, '["invalid row"]', 'A non-object row should be rejected.');
        Test.stopTest();
    }

    @IsTest
    static void testSaveMultiBankLiabilities_RowValidationRejected() {
        Case testCase = moveBaseCaseToPreScreener();
        String firstEntity = getPersistedEntity(testCase.Id);
        String secondEntity = getActiveEntityExcluding(firstEntity);
        Boolean currentUserIsAdmin = isCurrentUserAdmin();

        String missingIdJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 1000,
                'liabilityID' => 'LN111111'
            }
        });

        String duplicateIdJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 1000,
                'liabilityID' => 'LN111111'
            },
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => secondEntity,
                'outstanding' => 500,
                'liabilityID' => currentUserIsAdmin ? 'LN222222' : ''
            }
        });

        String invalidNumberJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 'NOT_A_NUMBER',
                'liabilityID' => 'LN111111'
            }
        });

        String blankEntityJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => '',
                'outstanding' => 1000,
                'liabilityID' => 'LN111111'
            }
        });

        String nullOutstandingJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => null,
                'liabilityID' => 'LN111111'
            }
        });

        String inactiveEntityJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => firstEntity,
                'outstanding' => 1000,
                'liabilityID' => 'LN111111'
            },
            new Map<String, Object>{
                'Id' => '2',
                'selected' => true,
                'entity' => 'NOT_CONFIGURED_TEST_BANK',
                'outstanding' => 500,
                'liabilityID' => currentUserIsAdmin ? 'LN222222' : ''
            }
        });

        Test.startTest();
        assertSaveThrows(testCase.Id, missingIdJson, 'Missing row Id should be rejected.');
        assertSaveThrows(testCase.Id, duplicateIdJson, 'Duplicate row Id should be rejected.');
        assertSaveThrows(testCase.Id, invalidNumberJson, 'Invalid numeric Outstanding should be rejected.');
        assertSaveThrows(testCase.Id, blankEntityJson, 'Blank Entity/Bank should be rejected.');
        assertSaveThrows(testCase.Id, nullOutstandingJson, 'Null Outstanding should be rejected.');
        assertSaveThrows(testCase.Id, inactiveEntityJson, 'Inactive/unconfigured Entity/Bank should be rejected.');
        Test.stopTest();
    }

    @IsTest
    static void testSaveMultiBankLiabilities_DeletionRejected() {
        Case testCase = moveBaseCaseToPreScreener();

        Test.startTest();
        assertSaveThrows(testCase.Id, '[]', 'Removing a persisted row should be rejected.');
        Test.stopTest();
    }

    @IsTest
    static void testGetInitializationData_NoCaseAnnex() {
        Account testAccount = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        Id loanRecordTypeId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Loan_Application')
            .getRecordTypeId();

        Case caseWithoutAnnex = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = loanRecordTypeId,
                ContactId = testAccount.PersonContactId,
                AccountId = testAccount.Id,
                Case_Model__c = 'alburaq',
                Type = 'Loan Application',
                Subject = 'Case Without Annex',
                Region_Flag__c = 'Bahrain'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        Test.startTest();
        try {
            Lwc07_MultiBankLiabilityController.getInitializationData(caseWithoutAnnex.Id);
            System.assert(false, 'Case without Case Annex should throw AuraHandledException.');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException,
                'Expected AuraHandledException when Case Annex is missing.');
        }
        Test.stopTest();
    }

    @IsTest
    static void testSaveMultiBankLiabilities_NoCaseAnnex() {
        Account testAccount = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        Id loanRecordTypeId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Loan_Application')
            .getRecordTypeId();

        Case caseWithoutAnnex = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = loanRecordTypeId,
                ContactId = testAccount.PersonContactId,
                AccountId = testAccount.Id,
                OwnerId = getQueueId(PRE_SCREENER_QUEUE),
                Case_Model__c = 'alburaq',
                Type = 'Loan Application',
                Subject = 'Save Case Without Annex',
                Region_Flag__c = 'Bahrain'
            ),
            'TestFactoryDefaults.CaseDefaults',
            true
        );

        String entity = getFirstActiveEntity();
        String submittedJson = JSON.serialize(new List<Object>{
            new Map<String, Object>{
                'Id' => '1',
                'selected' => true,
                'entity' => entity,
                'outstanding' => 100,
                'liabilityID' => isCurrentUserAdmin() ? 'LN-NO-ANNEX' : ''
            }
        });

        Test.startTest();
        assertSaveThrows(caseWithoutAnnex.Id, submittedJson,
            'Save should fail when no Case Annex exists.');
        Test.stopTest();
    }

    @IsTest
    static void testPublicMethodInputValidation() {
        Case testCase = getBaseCase();

        Test.startTest();
        try {
            Lwc07_MultiBankLiabilityController.getInitializationData(null);
            System.assert(false, 'Null Case Id should be rejected.');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException,
                'getInitializationData(null) should throw AuraHandledException.');
        }

        try {
            Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities(null, '[]');
            System.assert(false, 'Null Case Id should be rejected for save.');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException,
                'saveMultiBankLiabilities(null, ...) should throw AuraHandledException.');
        }

        try {
            Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities(testCase.Id, '');
            System.assert(false, 'Blank JSON should be rejected.');
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException,
                'Blank JSON should throw AuraHandledException.');
        }
        Test.stopTest();
    }

    // -------------------------
    // Helpers - current executing user only; no setup-object DML
    // -------------------------

    private static Case getBaseCase() {
        return [
            SELECT Id, OwnerId
            FROM Case
            WHERE Subject = :BASE_CASE_SUBJECT
            LIMIT 1
        ];
    }

    private static Case moveBaseCaseToPreScreener() {
        Case testCase = getBaseCase();
        testCase.OwnerId = getQueueId(PRE_SCREENER_QUEUE);
        update testCase;
        return testCase;
    }

    private static Id getQueueId(String developerName) {
        List<Group> queues = [
            SELECT Id
            FROM Group
            WHERE Type = 'Queue'
            AND DeveloperName = :developerName
            LIMIT 1
        ];

        System.assert(!queues.isEmpty(),
            'Required queue is missing from the org: ' + developerName);
        return queues[0].Id;
    }

    private static Boolean isCurrentUserAdmin() {
        Profile currentProfile = [
            SELECT PermissionsModifyAllData
            FROM Profile
            WHERE Id = :UserInfo.getProfileId()
            LIMIT 1
        ];
        return currentProfile.PermissionsModifyAllData;
    }

    private static String getFirstActiveEntity() {
        List<Loan_MultiBankLiability__mdt> configs = [
            SELECT EntityBankName__c
            FROM Loan_MultiBankLiability__mdt
            WHERE IsActive__c = true
            AND EntityBankName__c != null
            ORDER BY EntityBankName__c
            LIMIT 1
        ];

        System.assert(!configs.isEmpty(),
            'At least one active Loan_MultiBankLiability__mdt record is required.');
        return configs[0].EntityBankName__c.trim();
    }

    private static String getActiveEntityExcluding(String excludedEntity) {
        List<Loan_MultiBankLiability__mdt> configs = [
            SELECT EntityBankName__c
            FROM Loan_MultiBankLiability__mdt
            WHERE IsActive__c = true
            AND EntityBankName__c != null
            AND EntityBankName__c != :excludedEntity
            ORDER BY EntityBankName__c
            LIMIT 1
        ];

        System.assert(!configs.isEmpty(),
            'At least two active Loan_MultiBankLiability__mdt records are required for this test.');
        return configs[0].EntityBankName__c.trim();
    }

    private static String getPersistedEntity(Id caseId) {
        CaseAnnex__c annex = [
            SELECT cx_ln_Requested_MultiBankLiabilities__c
            FROM CaseAnnex__c
            WHERE Case__c = :caseId
            LIMIT 1
        ];

        List<Object> rows = (List<Object>)JSON.deserializeUntyped(
            annex.cx_ln_Requested_MultiBankLiabilities__c
        );
        Map<String, Object> firstRow = (Map<String, Object>)rows[0];
        return String.valueOf(firstRow.get('entity'));
    }

    private static void assertSaveThrows(Id caseId, String jsonValue, String assertionMessage) {
        try {
            Lwc07_MultiBankLiabilityController.saveMultiBankLiabilities(caseId, jsonValue);
            System.assert(false, assertionMessage);
        } catch (Exception e) {
            System.assert(e instanceof AuraHandledException,
                assertionMessage + ' Expected AuraHandledException but got: ' + e.getTypeName());
        }
    }
    @IsTest
    static void testIsUserMemberOfQueue_CurrentUserOwner() {
    
        // Use the Case already created in @TestSetup
        Case testCase = [
            SELECT Id, OwnerId
            FROM Case
            WHERE Subject = 'Multi-Bank Liability Test Case'
            LIMIT 1
        ];
    
        if (testCase.OwnerId != UserInfo.getUserId()) {
            testCase.OwnerId = UserInfo.getUserId();
            update testCase;
        }
    
        Test.startTest();
    
        Lwc07_MultiBankLiabilityController.InitializationResponse result = Lwc07_MultiBankLiabilityController.getInitializationData(testCase.Id);
        Test.stopTest();
        System.assertNotEquals(
            null,
            result,
            'Initialization response should not be null.'
        );
        System.assertNotEquals(
            null,
            result.permissions,
            'Permissions should be calculated.'
        );
    }
}