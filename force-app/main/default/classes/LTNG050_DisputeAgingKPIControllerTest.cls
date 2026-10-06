@isTest
public class LTNG050_DisputeAgingKPIControllerTest {
	@testSetup
    static void setupTestData() {
        // Create a test case record
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        insert testCase;
    }
    
    @isTest
    static void testUpdateSubTypeAndComment() {
        // Retrieve the test case record created in testSetup
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Call the method to test
        String subTypeValue = 'Test SubType';
        String commentValue = 'Test Comment';
        
        Test.startTest();
        LTNG050_DisputeAgingKPIController.updateSubTypeAndComment(testCase.Id, subTypeValue, commentValue);
        Test.stopTest();
        
        // Retrieve the updated case record
        Case updatedCase = [SELECT Sub_Type__c, Comments, ac_Pending_Date__c FROM Case WHERE Id = :testCase.Id];
    }
    
    @isTest
    static void testUpdateSubTypeAndComment_ExceptionHandling() {
        // Call the method with invalid record Id to test exception handling
        String invalidRecordId = 'InvalidId';
        String subTypeValue = 'Test SubType';
        String commentValue = 'Test Comment';
        
        Test.startTest();
        try {
            LTNG050_DisputeAgingKPIController.updateSubTypeAndComment(invalidRecordId, subTypeValue, commentValue);
        } catch (Exception e) {
            System.assertEquals('System.QueryException: List has no rows for assignment to SObject', e.getMessage(), 'Exception message should match.');
        }
        Test.stopTest();
    }
}