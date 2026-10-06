@isTest
public without sharing class InvestmentQuestionnaireHelperTest {
@testSetup
    static void setupTestData() {
        
        Account testAccount =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        
        // Create test Questionnaire
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '1293779',
            Product_Type__c = 'Gold'
        );
        insert questionnaire;
        
        // Create Queue for case assignment
        Group testQueue = new Group(
            Name = 'Investment Questionnaire Review Maker',
            Type = 'Queue'
        );
        insert testQueue;
    }
    
    @isTest
    static void testGetAccountIdsByCIF() {
        // Test with valid CIF
        Set<String> cifSet = new Set<String>{'1293779'};
        Map<String, Id> result = InvestmentQuestionnaireHelper.getAccountIdsByCIF(cifSet);
        
        // Test with empty set
        InvestmentQuestionnaireHelper.getAccountIdsByCIF(new Set<String>());
        
        // Test with invalid CIF
        Set<String> invalidCifSet = new Set<String>{'INVALIDCIF'};
        InvestmentQuestionnaireHelper.getAccountIdsByCIF(invalidCifSet);
    }
    
    @isTest
    static void testCreateQuestionnaireResponses() {
        Account anotherAccount =(Account)TestDataFactory.createSObject(new Account(CIF__pc='8521470'), 'TestFactoryDefaults.AccountDefaults',true);
        
        // Create test questionnaire with JSON
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521470',
            Product_Type__c = 'Gold',
            Investment_Questionnaire_JSON__c = '{"questions": [{"questionId": 1, "questionText": "Test Question", "type": "SingleChoice", "category": "Investment", "manualApprovalRequired": true, "options": ["Option 1", "Option 2"], "selectedAnswer": "Option 1"}]}'
        );
        insert questionnaire;
        
        // Test successful response creation
        List<Questionnaire_Response__c> responses = InvestmentQuestionnaireHelper.createQuestionnaireResponses(
            questionnaire, 
            anotherAccount.Id
        );
    }
    
    @isTest
    static void testCreateManualApprovalCases() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE CIF__pc = '1293779' LIMIT 1];
        
        // Get test questionnaire
        Investment_Questionnaire__c questionnaire = [SELECT Id, CIF__c, Product_Type__c 
                                                     FROM Investment_Questionnaire__c 
                                                     LIMIT 1];
        
        // Get Record Type Id
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Investment_Questionnaire_Review')?.getRecordTypeId();
        
        
        Set<Id> questionnaireIds = new Set<Id>{questionnaire.Id};
        List<Investment_Questionnaire__c> questionnaires = new List<Investment_Questionnaire__c>{questionnaire};
          // Query the System Administrator Profile
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create a user record with the Admin Profile
        User adminUser = new User(
            Alias = 'admin', 
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com'
        );
        
        // Execute the test block as the System Administrator
        System.runAs(adminUser) {
        // Test case creation
        InvestmentQuestionnaireHelper.createManualApprovalCases(
            questionnaireIds, 
            questionnaires, 
            testAccount.Id
        );
        
        // Test with invalid Account ID
        InvestmentQuestionnaireHelper.createManualApprovalCases(
            questionnaireIds, 
            questionnaires, 
            null
        );
        
        // Test with no record type - this will trigger a debug but should continue
        // We'll just call the method with a set that won't be processed
        Set<Id> emptyQuestionnaireIds = new Set<Id>();
        InvestmentQuestionnaireHelper.createManualApprovalCases(
            emptyQuestionnaireIds, 
            new List<Investment_Questionnaire__c>(), 
            testAccount.Id
        );
        }
    }
    
    @isTest
    static void testUpdateAccountGoldSilverStatus() {
        // Get test account
        Account testAccount = [SELECT Id FROM Account WHERE CIF__pc = '1293779' LIMIT 1];
        
        // Test with isCaseCreated = true
        Map<Id, Id> accountMap = new Map<Id, Id>();
        accountMap.put(testAccount.Id, testAccount.Id);
        
        InvestmentQuestionnaireHelper.isCaseCreated = true;
        InvestmentQuestionnaireHelper.updateAccountGoldSilverStatus(accountMap);
        
        // Test with isCaseCreated = false
        InvestmentQuestionnaireHelper.isCaseCreated = false;
        InvestmentQuestionnaireHelper.updateAccountGoldSilverStatus(accountMap);
        
        // Test with empty map
        InvestmentQuestionnaireHelper.updateAccountGoldSilverStatus(new Map<Id, Id>());
    }
    
    @isTest
    static void testResetCaseCreatedFlag() {
                  // Query the System Administrator Profile
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create a user record with the Admin Profile
        User adminUser = new User(
            Alias = 'admin', 
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com'
        );
        
        // Execute the test block as the System Administrator
        System.runAs(adminUser) {
        // Set flag to true
        InvestmentQuestionnaireHelper.isCaseCreated = true;
        
        // Reset flag
        InvestmentQuestionnaireHelper.resetCaseCreatedFlag();
        
        // Set flag to true again and test reset
        InvestmentQuestionnaireHelper.isCaseCreated = true;
        InvestmentQuestionnaireHelper.resetCaseCreatedFlag();
        }
    }
    
    @isTest
    static void testGetAccountIdsByCIFWithValidData() {
                  // Query the System Administrator Profile
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create a user record with the Admin Profile
        User adminUser = new User(
            Alias = 'admin', 
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com'
        );
        
        // Execute the test block as the System Administrator
        System.runAs(adminUser) {
        Account anotherAccount =(Account)TestDataFactory.createSObject(new Account(CIF__pc='8521478'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Set<String> cifSet = new Set<String>{'1293779', '8521478'};
        InvestmentQuestionnaireHelper.getAccountIdsByCIF(cifSet);
        
        // Test with one valid and one invalid CIF
        Set<String> mixedCifSet = new Set<String>{'1293779', 'INVALIDCIF789'};
        InvestmentQuestionnaireHelper.getAccountIdsByCIF(mixedCifSet);
        }
    }
    
    @isTest
    static void testCreateQuestionnaireResponsesWithNullValues() {
                  // Query the System Administrator Profile
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create a user record with the Admin Profile
        User adminUser = new User(
            Alias = 'admin', 
            Email = 'adminuser@testorg.com',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', 
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com'
        );
        
        // Execute the test block as the System Administrator
        System.runAs(adminUser) {
        Account anotherAccount =(Account)TestDataFactory.createSObject(new Account(CIF__pc='8521473'), 'TestFactoryDefaults.AccountDefaults',true);
        
        // Test with null options
        Investment_Questionnaire__c nullOptionsQuestionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521473',
            Product_Type__c = 'Gold',
            Investment_Questionnaire_JSON__c = '{"questions": [{"questionId": 3, "questionText": "Question with no options", "type": "Text", "category": "General", "manualApprovalRequired": false, "options": null}]}'
        );
        insert nullOptionsQuestionnaire;
        
        InvestmentQuestionnaireHelper.createQuestionnaireResponses(
            nullOptionsQuestionnaire, 
            anotherAccount.Id
        );
        }
    }
}