@isTest
public class LoanServiceRequestActionControllerTest {
    
     private static void createTestData() {
         RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'LoanFinanceServiceRequest' LIMIT 1];
        
    }

 
    @isTest
    static void testGetLoanFinanceServiceRequestRecordType() {
         createTestData();
        
         Test.startTest();
 
        Id recordTypeId = LoanServiceRequestActionController.getAccRequestCaseRecordType();
        
        Test.stopTest();
        
        System.assertNotEquals(null, recordTypeId, 'The record type ID should not be null');

        RecordType expectedRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'LoanFinanceServiceRequest' LIMIT 1];
        System.assertEquals(expectedRT.Id, recordTypeId, 'The record type ID should match the expected record type ID');
    }
}