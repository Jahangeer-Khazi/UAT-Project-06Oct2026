@isTest
public class CaseFieldDependencyControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test User
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testmockuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'samplemockuser@example.com'
        );
        insert testUser;
        
        // Insert Test Case_Field_Values_Configuration__c records
        insert new Case_Field_Values_Configuration__c(
            Type__c = 'Account',
            Sub_Type__c = 'Profile Update',
            Request_Type__c = 'Address',
            Record_Type_Name__c = 'Request'
        );

        insert new Case_Field_Values_Configuration__c(
            Type__c = 'Account',
            Sub_Type__c = 'Balance requires investigation',
            Request_Type__c = 'Amount Credited',
            Record_Type_Name__c = 'Request'
        );
    }
    
    @isTest
    static void testGetPicklistDataByProfile() {
        // Fetch test user
        User testUser = [SELECT Id FROM User WHERE UserName = 'samplemockuser@example.com' LIMIT 1];

        // Run the test as the test user
        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> response = CaseFieldDependencyController.getPicklistDataByProfile();
            Test.stopTest();
        }
    }

    @isTest
    static void testFetchCaseNatureAndRouting() {
        Test.startTest();
        Map<String, String> response = CaseFieldDependencyController.fetchCaseNatureAndRouting('Account', 'Balance requires investigation', 'Amount Credited');
        Test.stopTest();
    }

    @isTest
    static void testFetchCaseNatureAndRoutingUsingSubType() {
        Test.startTest();
        Map<String, String> response = CaseFieldDependencyController.fetchCaseNatureAndRoutingUsingSubType('Account', 'Balance requires investigation');
        Test.stopTest();
    }

    @isTest
    static void testGetQueueNameToIdMap() {
        // Insert a test queue (Group)
        Group queue = new Group(Name = 'Test Queue', Type = 'Queue');
        insert queue;

        Test.startTest();
        Map<String, Id> queueMap = CaseFieldDependencyController.getQueueNameToIdMap();
        Test.stopTest();
    }

}