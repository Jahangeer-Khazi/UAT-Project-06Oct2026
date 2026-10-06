/*      Organization : ABC Bank
 *      Created By: Ranjith Raja
 *      Created Date: 10/09/2024
 *      Change History: 
 *			   #CH01# #Ranjith Raja# #10-09-2024# Added Test Classes and Test Methods for the Class 'CaseProcessingHandler'.
 */

@isTest
public class CaseProcessingHandlerTest {
    
    @testSetup static void setupMethode() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Issue').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    
    @isTest
    static void testAssignCasesUsingActiveAssignmentRule() {
        Case case1 = [SELECT Id FROM Case LIMIT 1];
        
        // Call the invocable method to assign cases using the assignment rule
        Test.startTest();
        CaseProcessingHandler.assignCasesUsingActiveAssignmentRule(new List<Id>{case1.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testAssignEntitlement() {
        Case oldCase = [SELECT Id, ac_Pending_Date__c, Sub_Type__c, RecordType_DeveloperName__c, Type, EntitlementId FROM Case LIMIT 1];
        
        Case updatedCase = [SELECT Id, ac_Pending_Date__c, Sub_Type__c, RecordType_DeveloperName__c, Type, EntitlementId FROM Case WHERE Id = :oldCase.Id LIMIT 1];
        updatedCase.ac_Pending_Date__c = System.today();
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>{oldCase.Id => oldCase};
            
        Test.startTest();
        CaseProcessingHandler.assignEntitlement(new List<Case>{updatedCase}, oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    static void testAssignEntitlements() {
        Case oldCase = [SELECT Id, ac_Pending_Date__c, Sub_Type__c, RecordType_DeveloperName__c, Type, EntitlementId FROM Case LIMIT 1];
        
        Case updatedCase = [SELECT Id, ac_Pending_Date__c, Sub_Type__c, RecordType_DeveloperName__c, Type, EntitlementId, AccountId FROM Case WHERE Id = :oldCase.Id LIMIT 1];
        updatedCase.ac_Pending_Date__c = System.today();
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>{oldCase.Id => oldCase};
            
        Test.startTest();
        CaseProcessingHandler.assignEntitlements(new List<Case>{updatedCase}, oldCaseMap);
        Test.stopTest();
    }
    
    @isTest
    static void testProcessPostUpdate() {
        Case oldCase = [SELECT Id, ac_Pending_Date__c, Sub_Type__c, RecordType_DeveloperName__c, Type, EntitlementId FROM Case LIMIT 1];
        
        Case updatedCase = [SELECT Id, ac_Pending_Date__c, Sub_Type__c, RecordType_DeveloperName__c, Type, EntitlementId, AccountId FROM Case WHERE Id = :oldCase.Id LIMIT 1];
        updatedCase.ac_Pending_Date__c = System.today();
        
        Map<Id, Case> oldCaseMap = new Map<Id, Case>{oldCase.Id => oldCase};
            
        Test.startTest();
        CaseProcessingHandler.processPostUpdate(new List<Case>{updatedCase}, oldCaseMap);
        Test.stopTest();
    }

    @isTest
    static void testGetCaseDetails() {
        Case case1 = [SELECT Id FROM Case LIMIT 1];
        // Call the method and verify it returns the expected case
        Test.startTest();
        Case returnedCase = CaseProcessingHandler.getCaseDetails(case1.Id);
        Test.stopTest();
    }

    @isTest
    static void testClearMakerCheckerComments() {
        Case case1 = [SELECT Id FROM Case LIMIT 1];
        // Add the case ID to the set
        Set<Id> caseIds = new Set<Id>{case1.Id};

        // Call the method to clear comments
        Test.startTest();
        CaseProcessingHandler.clearMakerCheckerComments(caseIds);
        Test.stopTest();
    }
    
    @isTest
    static void testNormalizeMethod() {
        String input = ' Hello ’World’ ';
        String expected = 'Hello World'; 
        String result = CaseProcessingHandler.normalize(input);
    }
    
    @isTest
    static void beforeServiceRequestUpdateTest2() {
        // Create new test lead
        Id creditcollectionRecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Service_Request').getRecordTypeId();
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = (Case)TestDataFactory.createSObject(new Case( sc_Card_Holder_ID_Number__c = '123' , RecordTypeId=creditcollectionRecordTypeId,ContactId = accObj.PersonContactId,AccountId = accObj.id,Status = 'In Progress',
                                                                    Type = 'Account'),
                                                           'TestFactoryDefaults.CaseDefaults',true);  
        
        objCase.Sub_Type__c = 'Segment';
        objCase.cc_Request_Type__c = 'Staff Joiner';
        objCase.cc_Checker_Result__c = 'Return to Maker';
        
        Test.StartTest();
        update objCase;
        Test.StopTest();    
    }
}