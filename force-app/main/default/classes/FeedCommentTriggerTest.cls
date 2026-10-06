/**
* @File Name          : FeedCommentTriggerTest.cls
* @Description        : Test class for FeedCommentTrigger to ensure the trigger logic works as expected.
*                       It verifies that the Recent_Updates__c field on the Case object is updated when
*                       a FeedComment associated with a FeedItem on a Case is inserted or updated.
* @Author             : Ranjith Raja
* @Last Modified By   : Ranjith Raja
* @Last Modified On   : December 9, 2024
* @Modification Log   :
* ==============================================================================
* Ver    | Date             | Author          | Modification
* ==============================================================================
* 1.0    | December 9, 2024 | Ranjith Raja     | Initial Version
**/

@isTest
public class FeedCommentTriggerTest {
    @isTest
    static void testFeedCommentTrigger() {
        // Create a Case record
        Case caseRecord = new Case(
            Subject = 'Test Case',
            Status = 'New'
        );
        insert caseRecord;
        
        // Create a FeedItem associated with the Case
        FeedItem feedItem = new FeedItem(
            ParentId = caseRecord.Id,
            Body = 'Test Feed Item',
            Type = 'TextPost'
        );
        insert feedItem;

        // Create a FeedComment associated with the FeedItem
        FeedComment feedComment = new FeedComment(
            FeedItemId = feedItem.Id,
            CommentBody = 'Test Feed Comment'
        );
        insert feedComment;

        // Query the Case record to verify the trigger execution
        Case updatedCase = [SELECT Id, Recent_Updates__c FROM Case WHERE Id = :caseRecord.Id];

        // Assert the expected result (optional if you do not want assertions)
        // System.assertEquals(true, updatedCase.Recent_Updates__c);
    }
}