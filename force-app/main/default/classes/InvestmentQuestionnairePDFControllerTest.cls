@isTest
public without sharing class InvestmentQuestionnairePDFControllerTest {
    @testSetup
    static void setupTestData() {
        
            // Create test Account
            Account testAccount = (Account)TestDataFactory.createSObject(
                new Account(CIF__pc = '1293779',region_flag__pc='Bahrain'), 
                'TestFactoryDefaults.AccountDefaults', 
                true
            );
            
            // Create test Questionnaire with JSON
            Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
                CIF__c = '1293779',
                Product_Type__c = 'Gold',
                Investment_Questionnaire_JSON__c = '{\"questionnaireName\":\"Gold & Silver Investment Questionnaire\",\"version\":\"1.0\",\"questions\":[{\"questionId\":1,\"questionText\":\"What is your primary objective for opening a Gold/Silver investment account?\",\"category\":\"Investment Objective\",\"type\":\"SingleChoice\",\"options\":[\"Capital preservation\",\"Long term wealth growth\",\"Short to medium term trading\",\"Diversification of investments\",\"Speculation on price movements\"],\"selectedAnswer\":\"Long term wealth growth\",\"manualApprovalRequired\":false},{\"questionId\":2,\"questionText\":\"How long do you intend to hold your Gold/Silver investments?\",\"category\":\"Investment Horizon\",\"type\":\"SingleChoice\",\"options\":[\"Less than 1 year\",\"1 to 3 years\",\"3 to 5 years\",\"More than 5 years\"],\"selectedAnswer\":\"1 to 3 years\",\"manualApprovalRequired\":false},{\"questionId\":3,\"questionText\":\"How would you describe your overall risk tolerance for Gold/Silver investments?\",\"category\":\"Risk Profile\",\"type\":\"SingleChoice\",\"options\":[\"Very conservative\",\"Conservative\",\"Moderate\",\"Aggressive\",\"Very aggressive\"],\"selectedAnswer\":\"Moderate\",\"manualApprovalRequired\":false},{\"questionId\":4,\"questionText\":\"What is your main source of funds for this investment?\",\"category\":\"Source of Funds\",\"type\":\"SingleChoice\",\"options\":[\"Salary / regular income\",\"Business income\",\"Savings\",\"Inheritance / gift\",\"Other\"],\"selectedAnswer\":\"Salary / regular income\",\"manualApprovalRequired\":false},{\"questionId\":5,\"questionText\":\"What proportion of your total investable assets will be allocated to Gold/Silver?\",\"category\":\"Asset Allocation\",\"type\":\"SingleChoice\",\"options\":[\"Less than 10%\",\"10% to 25%\",\"25% to 50%\",\"More than 50%\"],\"selectedAnswer\":\"10% to 25%\",\"manualApprovalRequired\":false},{\"questionId\":6,\"questionText\":\"How frequently do you expect to trade or rebalance your Gold/Silver positions?\",\"category\":\"Trading Behaviour\",\"type\":\"SingleChoice\",\"options\":[\"Rarely (buy and hold)\",\"Occasionally (few times a year)\",\"Regularly (monthly)\",\"Frequently (weekly or more)\"],\"selectedAnswer\":\"Occasionally (few times a year)\",\"manualApprovalRequired\":false},{\"questionId\":7,\"questionText\":\"Which of the following best describes your knowledge and experience with Gold/Silver investments?\",\"category\":\"Knowledge & Experience\",\"type\":\"SingleChoice\",\"options\":[\"No prior experience\",\"Limited experience\",\"Moderate experience\",\"Extensive experience\"],\"selectedAnswer\":\"Limited experience\",\"manualApprovalRequired\":false},{\"questionId\":8,\"questionText\":\"Which types of Gold/Silver products are you interested in?\",\"category\":\"Product Preference\",\"type\":\"MultiChoice\",\"options\":[\"Physical gold (bars/coins)\",\"Physical silver (bars/coins)\",\"Gold-backed accounts / certificates\",\"Silver-backed accounts / certificates\",\"Gold/Silver ETFs or funds\"],\"selectedAnswers\":[\"Gold-backed accounts / certificates\",\"Physical gold (bars/coins)\"],\"manualApprovalRequired\":false},{\"questionId\":9,\"questionText\":\"Would you require manual approval or relationship manager review for high-value or exceptional Gold/Silver transactions?\",\"category\":\"Approval & Controls\",\"type\":\"SingleChoice\",\"options\":[\"Yes, always\",\"Yes, for high-value transactions only\",\"No, standard limits are sufficient\"],\"selectedAnswer\":\"Yes, for high-value transactions only\",\"manualApprovalRequired\":false}]}'
            );
            insert questionnaire;
    }
    
    @isTest
    static void testPDFControllerWithValidData() {
        // Get test questionnaire
        Investment_Questionnaire__c questionnaire = [SELECT Id FROM Investment_Questionnaire__c LIMIT 1];
        
        // Create StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
        
        // Access properties to ensure they're populated
        String todayDate = controller.formattedTodayDate;
        String customerName = controller.customerName;
        String customerCIF = controller.customerCIF;
        String errorMsg = controller.errorMessage;
        
        // Get questions
        List<InvestmentQuestionnairePDFController.QuestionWrapper> questions = controller.questions;
        
        // Get categories
        List<String> categories = controller.getCategories();
        
        // Check questionsByCategory
        Map<String, List<InvestmentQuestionnairePDFController.QuestionWrapper>> questionsByCategory = controller.questionsByCategory;
    }
    
    @isTest
    static void testPDFControllerWithBlankJSON() {
        // Create Account
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '8521470'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Create questionnaire with blank JSON
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521470',
            Product_Type__c = 'Gold',
            Customer__c = testAccount.Id,
            Investment_Questionnaire_JSON__c = ''
        );
        insert questionnaire;
        
        // Create StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
    }
    
    @isTest
    static void testPDFControllerWithNullCustomer() {
        // Create Account
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '8521471'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Create questionnaire with no Customer reference
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521471',
            Product_Type__c = 'Gold',
            Investment_Questionnaire_JSON__c = '{"questions": [{"questionId": 1, "questionText": "Test Question", "type": "SingleChoice", "category": "Test", "manualApprovalRequired": false, "options": ["Option 1", "Option 2"], "selectedAnswer": "Option 1"}]}'
        );
        insert questionnaire;
        
        // Create StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
        
        // Access customer name (should be 'N/A')
        String customerName = controller.customerName;
    }
    
    @isTest
    static void testPDFControllerWithEmptyQuestions() {
        // Create Account
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '8521472'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Create questionnaire with empty questions array
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521472',
            Product_Type__c = 'Gold',
            Customer__c = testAccount.Id,
            Investment_Questionnaire_JSON__c = '{"questions": []}'
        );
        insert questionnaire;
        
        // Create StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
        
        // Get categories (should be empty)
        List<String> categories = controller.getCategories();
    }
    
    @isTest
    static void testPDFControllerWithInvalidJSON() {
        // Create Account
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '8521473'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Create questionnaire with invalid JSON
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521473',
            Product_Type__c = 'Gold',
            Customer__c = testAccount.Id,
            Investment_Questionnaire_JSON__c = '{invalid json}'
        );
        insert questionnaire;
        
        // Create StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller (should set error message)
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
        
        // Access error message
        String errorMsg = controller.errorMessage;
    }
    
    @isTest
    static void testPDFControllerWithNullId() {
        // Create StandardController with null Id
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
        
        // Controller should handle gracefully
    }
    
    @isTest
    static void testPDFControllerWithQuestionWithoutOptions() {
        // Create Account
        Account testAccount = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '8521474'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Create questionnaire with question having no options
        Investment_Questionnaire__c questionnaire = new Investment_Questionnaire__c(
            CIF__c = '8521474',
            Product_Type__c = 'Gold',
            Customer__c = testAccount.Id,
            Investment_Questionnaire_JSON__c = '{"questions": [{"questionId": 1, "questionText": "Question with no options", "type": "Text", "category": "General", "manualApprovalRequired": false, "options": null, "selectedAnswer": "Custom answer"}]}'
        );
        insert questionnaire;
        
        // Create StandardController
        ApexPages.StandardController sc = new ApexPages.StandardController(questionnaire);
        
        // Instantiate controller
        InvestmentQuestionnairePDFController controller = new InvestmentQuestionnairePDFController(sc);
        
        // Get questions
        List<InvestmentQuestionnairePDFController.QuestionWrapper> questions = controller.questions;
        
        // Get categories
        List<String> categories = controller.getCategories();
    }
}