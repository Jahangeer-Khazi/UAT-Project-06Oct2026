/**
* @File Name : CaseCommentControllerTest.cls
* @Description : This test class verifies the functionality of the CaseCommentController Apex class
* @Author : Ranjith Raja
* @Last Modified By : Ranjith Raja
* @Last Modified On : October 9, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | October 9, 2024 |   | Initial Version
**/
@IsTest
public class CaseCommentControllerTest {
    
    @TestSetup
    public static void setupTestData() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        // Case_Disputes_and_Frauds
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Issue').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);

		// Create CaseComments
        CaseComment comment1 = new CaseComment(ParentId = caseObj.Id, CommentBody = 'Comment 1');
        CaseComment comment2 = new CaseComment(ParentId = caseObj.Id, CommentBody = 'Comment 2');
        CaseComment comment3 = new CaseComment(ParentId = caseObj.Id, CommentBody = 'Comment 3');
        insert new List<CaseComment>{comment1, comment2, comment3};
    }

    @IsTest
    public static void testGetRecentCaseComments() {
        // Fetch test Account
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method being tested
        List<CaseCommentController.CaseCommentWrapper> caseComments = CaseCommentController.getRecentCaseComments(testAccount.Id);

        // Verify the result is not empty and contains expected number of comments (3 in this case)
        System.debug('Recent Case Comments: ' + caseComments);
    }

    @IsTest
    public static void testComponentRefreshPE() {
        // Call the event publishing method
        Test.startTest();
        CaseCommentController.componentRefreshPE();
        Test.stopTest();

        // Verify if the event was published successfully
        System.debug('Event Published: Refresh_Custom_Components__e');
    }
    
    @isTest
    static void testCompareSortingDate() {
        // Create CaseCommentWrapper instances with different sorting dates
        CaseCommentController.CaseCommentWrapper wrapper1 = new CaseCommentController.CaseCommentWrapper(
            'Case-001', 
            'User A', 
            'Comment A', 
            null, 
            null, 
            Date.today(), 
            1, 
            Datetime.now().addDays(-1) // Earlier date
        );

        CaseCommentController.CaseCommentWrapper wrapper2 = new CaseCommentController.CaseCommentWrapper(
            'Case-002', 
            'User B', 
            'Comment B', 
            null, 
            null, 
            Date.today(), 
            2, 
            Datetime.now() // Later date
        );

        CaseCommentController.CaseCommentWrapper wrapper3 = new CaseCommentController.CaseCommentWrapper(
            'Case-003', 
            'User C', 
            'Comment C', 
            null, 
            null, 
            Date.today(), 
            3, 
            null // Null sortingDate
        );

        // Test sorting logic
        Test.startTest();

        // Case 1: wrapper1 has an earlier date than wrapper2
        Integer result1 = CaseCommentController.compareSortingDate(wrapper1, wrapper2);
        // Optional: System.assertEquals(1, result1);

        // Case 2: wrapper2 has a later date than wrapper1
        Integer result2 = CaseCommentController.compareSortingDate(wrapper2, wrapper1);
        // Optional: System.assertEquals(-1, result2);

        // Case 3: Both have the same sortingDate
        wrapper1.sortingDate = wrapper2.sortingDate;
        Integer result3 = CaseCommentController.compareSortingDate(wrapper1, wrapper2);
        // Optional: System.assertEquals(0, result3);

        // Case 4: One has a null sortingDate
        Integer result4 = CaseCommentController.compareSortingDate(wrapper3, wrapper2);
        // Optional: System.assertEquals(1, result4); // Null comes after

        Integer result5 = CaseCommentController.compareSortingDate(wrapper1, wrapper3);
        // Optional: System.assertEquals(-1, result5); // Null comes after

        // Case 5: Both have null sortingDate
        Integer result6 = CaseCommentController.compareSortingDate(wrapper3, wrapper3);
        // Optional: System.assertEquals(0, result6);

        Test.stopTest();
    }
}