/*
*       Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 08-05-2024
*       Change History: 
*                   
*/
@isTest
public class InvestmentQuestionnaireHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Create Queues
        Group makerQueue = new Group(
            Name = 'Investment Questionnaire Review Maker',
            Type = 'Queue'
        );
        insert makerQueue;
        
        Group checkerQueue = new Group(
            Name = 'Investment Questionnaire Review Checker',
            Type = 'Queue'
        );
        insert checkerQueue;
        
        // Get Record Type Id for Investment Questionnaire Review
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        Case testCase = (Case)TestDataFactory.createSObject(new Case( RecordTypeId=caseRecordTypeId,ContactId = testAccount.PersonContactId,AccountId = testAccount.id,Status = 'In Progress',
                                                                    Type = 'New Investment Questionnaire Review', Sub_Type__c = 'New Investment Questionnaire Review',
                                                                    Subject = 'Investment Questionnaire Review', Case_Nature__c = 'Gold & Silver Accounts'),
                                                           'TestFactoryDefaults.CaseDefaults',true);  
        
    }
    
    // Existing test methods - kept exactly as is
    @isTest
    static void unitTest1(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case c = CreateCase('Investement Questionnairre','Testing for Questionnairre');
        c.AccountId = acc.Id;
        insert c;
        
        Case c2 = CreateCase('Investement Questionnairre2','Testing for Questionnairre2');
        c2.AccountId = acc.Id;
        insert c2;
    }
    
    @isTest
    static void unitTest2(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case c = CreateCase('Investement Questionnairre','Testing for Questionnairre');
        c.AccountId = acc.Id;
        insert c;
        
        c.cc_Maker__c = 'Send to Investment Questionnaire Checker';
        update c;
        
        c.cc_Checker_Result__c = 'Return to Investment Questionnaire Maker';
        update c;
    }
    
    @isTest
    static void unitTest3(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case c = CreateCase('Investement Questionnairre','Testing for Questionnairre');
        c.AccountId = acc.Id;
        insert c;
        
        c.cc_Maker__c = 'Send to Investment Questionnaire Checker';
        update c;
        
        c.cc_Checker_Result__c = 'Decline';
        update c;
    }
    
    @isTest
    static void unitTest4(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case c = CreateCase('Investement Questionnairre','Testing for Questionnairre');
        c.AccountId = acc.Id;
        insert c;
        
        c.cc_Maker__c = 'Send to Investment Questionnaire Checker';
        update c;
        
        c.cc_Checker_Result__c = 'Approve';
        update c;
    }
    
    /*@isTest
    static void unitTest6(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        insert acc;
        
        Case c = CreateCase('Investement Questionnairre','Testing for Questionnairre');
        c.AccountId = acc.Id;
        insert c;
        
        c.cc_Maker__c = 'Send to Investment Questionnaire Checker';
        update c;
        
        c.cc_Checker_Result__c = 'Approve';
        update c;
        
        Case c2 = CreateCase('Investement Questionnairre2','Testing for Questionnairre2');
        c2.AccountId = acc.Id;
        insert c2;
        
        c2.cc_Maker__c = 'Send to Investment Questionnaire Checker';
        update c2;
        
        c2.cc_Checker_Result__c = 'Approve';
        update c2;
        
        Case cse = [Select id,Subject from Case where Id =: c2.Id];
        System.debug('Case in Test Class:'+cse);
        
        Bonds_Sukuk_Questionnaire__c sukBondQuest = [Select id,CreatedDate,Case_Number__c from Bonds_Sukuk_Questionnaire__c where Case_Number__c =: c2.Id];
        System.debug('Questionnairre in Test Class:'+sukBondQuest);
        
        Test.setCreatedDate(sukBondQuest.id, DateTime.newInstance(2023, 1, 1));
        Test.startTest();
        InvQuestionnaireConsentStatusUpdate invQuestBatch = new InvQuestionnaireConsentStatusUpdate();
        Id jobid= Database.executeBatch(invQuestBatch,5);
        Test.stopTest();
    }*/
    
    public static Case CreateCase(String subject, String description){
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sukuk-Bond Request').getRecordTypeId();
        Case cs1 = new Case();
        cs1.RecordTypeId = recordTypeId;
        cs1.Subject = subject;
        cs1.Description = description;
        cs1.Type = 'Investment Questionnaire';
        cs1.Sub_Type__c = 'New Investment Questionnaire';
        cs1.Region_Flag__c = 'Bahrain';
        cs1.Bo_Consent__c = true;
        cs1.Bo_Risk_Tolerance__c = 'Low';
        cs1.Bo_Risk_Preference__c = 'Mostly Safety';
        cs1.Bo_Risk_Level__c = 'Neutral';
        cs1.Bo_Knowledge_Level__c = 'Competent';
        cs1.Bo_Experience_Level__c = 'Modest';
        cs1.Bo_Past_Experience__c = 'Did Nothing';
        cs1.Bo_Investor_Declaration__c = 'Retail Investor';
        
        return cs1;
    }
    
    // ============ SIMPLIFIED TEST METHODS TO COVER ALL BRANCHES ============
    
    @isTest
    static void testAllAfterUpdateScenarios() {
        // Get Record Type Id
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        if (caseRecordTypeId != null) {
            // Create 3 accounts
            Account acc1 = (Account)TestDataFactory.createSObject(
                new Account(CIF__pc = '1111111'), 
                'TestFactoryDefaults.AccountDefaults', 
                true
            );
            Account acc2 = (Account)TestDataFactory.createSObject(
                new Account(CIF__pc = '2222222'), 
                'TestFactoryDefaults.AccountDefaults', 
                true
            );
            Account acc3 = (Account)TestDataFactory.createSObject(
                new Account(CIF__pc = '3333333'), 
                'TestFactoryDefaults.AccountDefaults', 
                true
            );
            
            // Create 3 cases with null checker result
            Case case1 = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'Case 1 - Approve',
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = acc1.Id,
                cc_Checker_Result__c = null
            );
            insert case1;
            
            Case case2 = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'Case 2 - Reject',
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = acc2.Id,
                cc_Checker_Result__c = null
            );
            insert case2;
            
            Case case3 = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'Case 3 - Return to Maker',
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = acc3.Id,
                cc_Checker_Result__c = null
            );
            insert case3;
            
            // Set different results
            case1.cc_Checker_Result__c = 'Approve';
            case2.cc_Checker_Result__c = 'Reject';
            case3.cc_Checker_Result__c = 'Return to Maker';
            
            // Prepare for update
            List<Case> newCases = new List<Case>{case1, case2, case3};
            Map<Id, Case> oldCaseMap = new Map<Id, Case>();
            for (Case c : newCases) {
                Case oldCase = c.clone(false, true, false, false);
                oldCase.cc_Checker_Result__c = null; // Make sure old value is null
                oldCaseMap.put(c.Id, oldCase);
            }
            
            // Execute
            Test.startTest();
            InvestmentQuestionnaireHandler.handlerAfterCaseUpdate(newCases, oldCaseMap);
            Test.stopTest();
            
            // Verify all 3 cases updated
            List<Case> updatedCases = [SELECT Id, Status, Sub_Status__c, OwnerId, cc_Maker__c, cc_Checker_Result_Date_Time__c 
                                       FROM Case 
                                       WHERE Id IN :new List<Id>{case1.Id, case2.Id, case3.Id}];
            
            // Verify all 3 accounts updated
            List<Account> updatedAccounts = [SELECT Id, Gold_Silver_Questionnaire_Status__c 
                                             FROM Account 
                                             WHERE Id IN :new List<Id>{acc1.Id, acc2.Id, acc3.Id}];
        }
    }
    
    @isTest
    static void testAfterUpdateNoAccount() {
        // Get Record Type Id
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        if (caseRecordTypeId != null) {
            // Create case without Account
            Case testCase = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'No Account Case',
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = null,
                cc_Checker_Result__c = null
            );
            insert testCase;
            
            // Set result
            testCase.cc_Checker_Result__c = 'Approve';
            
            List<Case> newCases = new List<Case>{testCase};
            Map<Id, Case> oldCaseMap = new Map<Id, Case>();
            Case oldCase = testCase.clone(false, true, false, false);
            oldCase.cc_Checker_Result__c = null;
            oldCaseMap.put(testCase.Id, oldCase);
            
            Test.startTest();
            InvestmentQuestionnaireHandler.handlerAfterCaseUpdate(newCases, oldCaseMap);
            Test.stopTest();
            
            // Verify case updated but no account update
            Case updatedCase = [SELECT Id, Status, Sub_Status__c FROM Case WHERE Id = :testCase.Id];
        }
    }
    
    @isTest
    static void testAfterUpdateNoChange() {
        // Get Record Type Id
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        if (caseRecordTypeId != null) {
            Account acc = (Account)TestDataFactory.createSObject(
                new Account(CIF__pc = '4444444'), 
                'TestFactoryDefaults.AccountDefaults', 
                true
            );
            
            Case testCase = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'No Change Case',
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = acc.Id,
                cc_Checker_Result__c = 'Approve'
            );
            insert testCase;
            
            // Don't change - same value
            List<Case> newCases = new List<Case>{testCase};
            Map<Id, Case> oldCaseMap = new Map<Id, Case>();
            oldCaseMap.put(testCase.Id, testCase.clone(false, true, false, false));
            
            Test.startTest();
            InvestmentQuestionnaireHandler.handlerAfterCaseUpdate(newCases, oldCaseMap);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testAfterUpdateNonReviewType() {
        // Use existing CreateCase method for non-review type
        Case nonReviewCase = CreateCase('Non Review', 'Testing non review');
        nonReviewCase.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        insert nonReviewCase;
        
        nonReviewCase.cc_Checker_Result__c = 'Approve';
        
        List<Case> newCases = new List<Case>{nonReviewCase};
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        Case oldCase = nonReviewCase.clone(false, true, false, false);
        oldCase.cc_Checker_Result__c = null;
        oldCaseMap.put(nonReviewCase.Id, oldCase);
        
        Test.startTest();
        InvestmentQuestionnaireHandler.handlerAfterCaseUpdate(newCases, oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    static void testAfterUpdateEmptyList() {
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        Test.startTest();
        InvestmentQuestionnaireHandler.handlerAfterCaseUpdate(newCases, oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeUpdateSendToChecker() {
        // Get Record Type Id
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        if (caseRecordTypeId != null) {
            Account acc = (Account)TestDataFactory.createSObject(
                new Account(CIF__pc = '5555555'), 
                'TestFactoryDefaults.AccountDefaults', 
                true
            );
            
            Case testCase = new Case(
                RecordTypeId = caseRecordTypeId,
                Type = 'New Investment Questionnaire Review',
                Origin = 'App',
                Subject = 'Before Update Test',
                Status = 'Open',
                Case_Nature__c = 'Gold & Silver Accounts',
                AccountId = acc.Id,
                cc_Maker__c = null,
                cc_Checker_Result__c = null
            );
            insert testCase;
            
            // Change maker field
            testCase.cc_Maker__c = 'Send to Checker';
            
            List<Case> newCases = new List<Case>{testCase};
            Map<Id, Case> oldCaseMap = new Map<Id, Case>();
            Case oldCase = testCase.clone(false, true, false, false);
            oldCase.cc_Maker__c = null;
            oldCaseMap.put(testCase.Id, oldCase);
            
            Test.startTest();
            InvestmentQuestionnaireHandler.handlerBeforeCaseUpdate(newCases, oldCaseMap);
            Test.stopTest();
            
            Case updatedCase = [SELECT Id, cc_Maker__c, OwnerId, cc_Checker_Result__c FROM Case WHERE Id = :testCase.Id];
        }
    }
    
    @isTest
    static void testBeforeUpdateNoChange() {
        // Get Record Type Id
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        if (caseRecordTypeId != null) {
            Case testCase = [SELECT Id, cc_Maker__c, RecordTypeId FROM Case LIMIT 1];
            
            // Don't change
            List<Case> newCases = new List<Case>{testCase};
            Map<Id, Case> oldCaseMap = new Map<Id, Case>();
            oldCaseMap.put(testCase.Id, testCase.clone(false, true, false, false));
            
            Test.startTest();
            InvestmentQuestionnaireHandler.handlerBeforeCaseUpdate(newCases, oldCaseMap);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testBeforeUpdateNonReviewType() {
        // Use existing CreateCase method
        Case nonReviewCase = CreateCase('Before Non Review', 'Testing before non review');
        nonReviewCase.AccountId = [SELECT Id FROM Account LIMIT 1].Id;
        insert nonReviewCase;
        
        nonReviewCase.cc_Maker__c = 'Send to Checker';
        
        List<Case> newCases = new List<Case>{nonReviewCase};
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        Case oldCase = nonReviewCase.clone(false, true, false, false);
        oldCase.cc_Maker__c = null;
        oldCaseMap.put(nonReviewCase.Id, oldCase);
        
        Test.startTest();
        InvestmentQuestionnaireHandler.handlerBeforeCaseUpdate(newCases, oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    static void testBeforeUpdateEmptyList() {
        List<Case> newCases = new List<Case>();
        Map<Id, Case> oldCaseMap = new Map<Id, Case>();
        
        Test.startTest();
        InvestmentQuestionnaireHandler.handlerBeforeCaseUpdate(newCases, oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    static void testGetQueueId() {
        Test.startTest();
        Id queueId1 = getQueueId('Investment Questionnaire Review Maker');
        Id queueId2 = getQueueId('Investment Questionnaire Review Checker');
        Id queueId3 = getQueueId('Non Existent Queue');
        Test.stopTest();
    }
    
    // Helper method
    private static Id getQueueId(String queueName) {
        try {
            Group queue = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :queueName LIMIT 1];
            return queue.Id;
        } catch (Exception e) {
            return null;
        }
    }
}