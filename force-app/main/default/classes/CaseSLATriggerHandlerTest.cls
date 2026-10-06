/**
 * @File Name : CaseSLATriggerHandlerTest.cls
 * @Description : Test class for CaseSLATriggerHandler
 * @Author :
 * @Last Modified On : June 24, 2025
 * @Modification Log :
 *==============================================================================
 * Ver | Date | Author | Modification
 *==============================================================================
 * 1.0 | June 24, 2025 |   | Initial Version
 * 1.1 | June 24, 2025 |   | Fixed System.runAs error with active admin user
 */
@isTest
private class CaseSLATriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create System Administrator user for queue creation
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'admusr',
            Email = 'admin@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Admin',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'admin@testorg.com' + System.currentTimeMillis(),
            IsActive = true
        );
        insert adminUser;
        
        // Create Account using TestDataFactory
        Account acc = (Account)TestDataFactory.createSObject(
            new Account(CIF__pc = '1293779'), 
            'TestFactoryDefaults.AccountDefaults', 
            true
        );
        
        // Get RecordType ID for Case
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Case_Disputes_and_Frauds').getRecordTypeId();
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create Users for owner changes using TestDataFactory
        User user1 = (User)TestDataFactory.createSObject(
            new User(
            ProfileId = standardProfile.Id,
            IsActive = true,
            Username = 'user1@testorg.com' + System.currentTimeMillis(),
            Email = 'user1@testorg.com',
            LastName = 'User1',
            Alias = 'usr1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        ),
            'TestFactoryDefaults.UserDefaults',
            true
        );
        User user2 = (User)TestDataFactory.createSObject(
            new User(
            ProfileId = standardProfile.Id,
            IsActive = true,
            Username = 'user2@testorg.com' + System.currentTimeMillis(),
            Email = 'user2@testorg.com',
            LastName = 'User2',
            Alias = 'usr2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        ),
            'TestFactoryDefaults.UserDefaults',
            true
        );
        
        // Create Queue for testing Group ownership
        Group testQueue;
        System.runAs(adminUser) {
            testQueue = new Group(Name = 'TestQueue', Type = 'Queue');
            insert testQueue;
            QueueSObject queueSObj = new QueueSObject(QueueId = testQueue.Id, SObjectType = 'Case');
            insert queueSObj;
        }
        
        // Create Case using TestDataFactory
        Case caseObj = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = caseRecordTypeId,
                ContactId = acc.PersonContactId,
                AccountId = acc.Id,
                Case_Model__c = 'ila',
                OwnerId = user1.Id
            ), 
            'TestFactoryDefaults.CaseDefaults', 
            true
        );
        
        // Create Case_Aging__c record
        Case_Aging__c caseAging = new Case_Aging__c(
            Case__c = caseObj.Id
        );
        insert caseAging;
        
        // Create Case_Aging_Line_Item__c
        Case_Aging_Line_Item__c lineItem = new Case_Aging_Line_Item__c(
            Case_Aging__c = caseAging.Id,
            Time__c = System.now().addHours(-1),
            Total_Time__c = 0
        );
        insert lineItem;
    }
    
    @isTest
    static void testHandleOwnerChangeToUser() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        User newOwner = [SELECT Id FROM User WHERE Id != :testCase.OwnerId AND LastName != 'Admin' LIMIT 1];
        Map<Id, Case> oldMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id]);
        
        testCase.OwnerId = newOwner.Id;
        
        Test.startTest();
        CaseSLATriggerHandler.handleOwnerChange(new List<Case>{testCase}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleOwnerChangeToQueue() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        Group testQueue = [SELECT Id FROM Group WHERE Name = 'TestQueue' LIMIT 1];
        Map<Id, Case> oldMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id]);
        
        testCase.OwnerId = testQueue.Id;
        
        Test.startTest();
        CaseSLATriggerHandler.handleOwnerChange(new List<Case>{testCase}, oldMap);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleOwnerChangeNoChange() {
        Case testCase = [SELECT Id, OwnerId FROM Case LIMIT 1];
        Map<Id, Case> oldMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case WHERE Id = :testCase.Id]);
        
        // No owner change
        Test.startTest();
        CaseSLATriggerHandler.handleOwnerChange(new List<Case>{testCase}, oldMap);
        Test.stopTest();
    }
    
    /*@isTest
    static void testHandleOwnerChangeNoAging() {
        Account acc = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
            .get('Case_Disputes_and_Frauds').getRecordTypeId();
        User user1 = [SELECT Id FROM User WHERE LastName != 'Admin' LIMIT 1];
        User user2 = [SELECT Id FROM User WHERE Id != :user1.Id AND LastName != 'Admin' LIMIT 1];
        
        Case caseWithoutAging = (Case)TestDataFactory.createSObject(
            new Case(
                RecordTypeId = caseRecordTypeId,
                ContactId = acc.PersonContactId,
                AccountId = acc.Id,
                Case_Model__c = 'ila',
                OwnerId = user1.Id
            ), 
            'TestFactoryDefaults.CaseDefaults', 
            true
        );
        
        Map<Id, Case> oldMap = new Map<Id, Case>([SELECT Id, OwnerId FROM Case WHERE Id = :caseWithoutAging.Id]);
        caseWithoutAging.OwnerId = user2.Id;
        
        Test.startTest();
        CaseSLATriggerHandler.handleOwnerChange(new List<Case>{caseWithoutAging}, oldMap);
        Test.stopTest();
    } */
    
    @isTest
    static void testPopulateOwnerAndGroupQueue() {
        Case_Aging__c caseAging = [SELECT Id FROM Case_Aging__c LIMIT 1];
        Case_Aging_Line_Item__c lineItem = new Case_Aging_Line_Item__c(
            Case_Aging__c = caseAging.Id,
            Time__c = System.now()
        );
        
        Test.startTest();
        CaseSLATriggerHandler.populateOwnerAndGroupQueue(new List<Case_Aging_Line_Item__c>{lineItem});
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateOwnerAndGroupQueueEmpty() {
        Test.startTest();
        CaseSLATriggerHandler.populateOwnerAndGroupQueue(new List<Case_Aging_Line_Item__c>());
        Test.stopTest();
    }
    
    @isTest
    static void testPopulateOwnerAndGroupQueuePopulatedFields() {
        Case_Aging__c caseAging = [SELECT Id FROM Case_Aging__c LIMIT 1];
        Case_Aging_Line_Item__c lineItem = new Case_Aging_Line_Item__c(
            Case_Aging__c = caseAging.Id,
            New_Owner__c = 'TestOwner',
            Group_Queue__c = 'TestGroup',
            Time__c = System.now()
        );
        
        Test.startTest();
        CaseSLATriggerHandler.populateOwnerAndGroupQueue(new List<Case_Aging_Line_Item__c>{lineItem});
        Test.stopTest();
    }
}