public Without Sharing class CaseCommentController {
    @AuraEnabled(cacheable=true)
    public static List<CaseCommentWrapper> getRecentCaseComments(String accountId) {
        List<CaseCommentWrapper> caseCommentsList = new List<CaseCommentWrapper>();
        
        Map<Id, Integer> caseCommentCounts = new Map<Id, Integer>();
        List<AggregateResult> caseCommentAggregates = [
            SELECT ParentId, COUNT(Id) commentCount
            FROM CaseComment
            WHERE Parent.AccountId = :accountId
            GROUP BY ParentId
        ];
        
        for (AggregateResult ar : caseCommentAggregates) {
            caseCommentCounts.put((Id)ar.get('ParentId'), (Integer)ar.get('commentCount'));
        }
        
        List<CaseComment> caseComments = [
            SELECT Id, CommentBody, ParentId, CreatedDate, Parent.CaseNumber, 
            Parent.CreatedBy.Name, Parent.Recent_Updates__c, CreatedBy.Name
            FROM CaseComment
            WHERE Parent.AccountId = :accountId
            AND ParentId IN (SELECT Id FROM Case WHERE AccountId = :accountId) 
            AND Parent.Recent_Updates__c = TRUE
            ORDER BY LastModifiedDate DESC
            LIMIT 100
        ];
        
        Map<Id, CaseCommentWrapper> recentCommentsMap = new Map<Id, CaseCommentWrapper>();
        
        List<FeedItem> feedItems = [SELECT Id, ParentId FROM FeedItem
                                    WHERE ParentId IN :caseCommentCounts.keySet() 
                                    AND Type = 'CaseCommentPost' // To filter case comment posts
                                   ];
        
        Map<Id, Id> feedItemToCaseCommentMap = new Map<Id, Id>(); // Map<FeedItemId, CaseCommentId>
        for (FeedItem item : feedItems) {
            if (item.ParentId != null) {
                feedItemToCaseCommentMap.put(item.Id, item.ParentId); // FeedItemId -> CaseCommentId
            }
        }
        
        List<FeedComment> feedComments = [
            SELECT FeedItemId, CommentBody, CreatedDate, CreatedBy.Name
            FROM FeedComment
            WHERE FeedItemId IN (SELECT Id FROM FeedItem WHERE ParentId = :caseCommentCounts.keyset())
            ORDER BY CreatedDate DESC
        ];
        
        Map<Id, FeedComment> caseCommentToFeedCommentsMap = new Map<Id, FeedComment>(); 
        for (FeedComment feedComment : feedComments) {
            Id caseCommentId = feedItemToCaseCommentMap.get(feedComment.FeedItemId);
            
            if (!caseCommentToFeedCommentsMap.containsKey(caseCommentId)) {
                caseCommentToFeedCommentsMap.put(caseCommentId, feedComment);
            }
        }
        
  /*      for (CaseComment comment : caseComments) {
            DateTime latestActivityDate = comment.CreatedDate;
            if (!recentCommentsMap.containsKey(comment.ParentId)) {
                Integer commentCount = caseCommentCounts.get(comment.ParentId);
                
                String subCommentBody = '';
                if (caseCommentToFeedCommentsMap.containsKey(comment.ParentId)) {
                    FeedComment subComment = caseCommentToFeedCommentsMap.get(comment.ParentId);
                    subCommentBody += subComment.CommentBody.stripHtmlTags();
                    if(subComment.CreatedDate > latestActivityDate) {
                        latestActivityDate = subComment.CreatedDate;
                    }
                }
                
                String fullCommentBody = comment.CommentBody;
                // if (String.isNotBlank(subCommentBody)) {
                //     fullCommentBody += ' (' + subCommentBody + ')';
                // }
                
                recentCommentsMap.put(comment.ParentId, 
                                      new CaseCommentWrapper(comment.Parent.CaseNumber, comment.CreatedBy.Name, fullCommentBody, subCommentBody,
                                                             comment.ParentId, comment.CreatedDate.date(), commentCount, latestActivityDate));
            }
            
            // if (recentCommentsMap.size() == 3) {
            //     break;
            // }
        }
        
        caseCommentsList.addAll(recentCommentsMap.values());
        
        // Sort caseCommentsList by sortingDate manually
        sortCaseCommentsList(caseCommentsList);
        
        System.debug('Final caseCommentsList: ' + caseCommentsList);
        // Create a new list to hold the top 3 objects
        List<CaseCommentWrapper> topThreeComments = new List<CaseCommentWrapper>();
        
        // Add up to 3 objects from the sorted list
        for (Integer i = 0; i < Math.min(3, caseCommentsList.size()); i++) {
            topThreeComments.add(caseCommentsList[i]);
        }
          */
          List<CaseCommentWrapper> topThreeComments = new List<CaseCommentWrapper>();
        return topThreeComments;
    }
    
    // Manual sorting method
    private static void sortCaseCommentsList(List<CaseCommentWrapper> caseCommentList) {
        for (Integer i = 0; i < caseCommentList.size() - 1; i++) {
            for (Integer j = 0; j < caseCommentList.size() - 1 - i; j++) {
                if (compareSortingDate(caseCommentList[j], caseCommentList[j + 1]) > 0) {
                    // Swap
                    CaseCommentWrapper temp = caseCommentList[j];
                    caseCommentList[j] = caseCommentList[j + 1];
                    caseCommentList[j + 1] = temp;
                }
            }
        }
    }
    
    public static Integer compareSortingDate(CaseCommentWrapper a, CaseCommentWrapper b) {
        // Handle null sortingDate
        if (a.sortingDate == null && b.sortingDate == null) {
            return 0; // Both are null
        }
        if (a.sortingDate == null) {
            return 1; // a comes after b
        }
        if (b.sortingDate == null) {
            return -1; // b comes after a
        }
        // Compare Datetime values for descending order
        if (a.sortingDate > b.sortingDate) {
            return -1; // a is later, so it should come first
        } else if (a.sortingDate < b.sortingDate) {
            return 1; // b is later, so a should come after b
        } else {
            return 0; // They are equal
        }
    }
    
    
    public class CaseCommentWrapper {
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String createdBy;
        @AuraEnabled public String commentBody;
        @AuraEnabled public String subComment;
        @AuraEnabled public Id caseId;
        @AuraEnabled public Date createdDate;
        @AuraEnabled public Integer commentCount;
        @AuraEnabled public Datetime sortingDate;
        
        public CaseCommentWrapper(String caseNumber, String createdBy, String commentBody, String subComment, Id caseId, Date createdDate, Integer commentCount, Datetime sortingDate) {
            this.caseNumber = caseNumber;
            this.createdBy = createdBy;
            this.commentBody = commentBody;
            this.subComment = subComment;
            this.caseId = caseId;
            this.createdDate = createdDate;
            this.commentCount = commentCount;
            this.sortingDate = sortingDate;
        }
    }
    
    public static void componentRefreshPE() {

        /*for(Case caseObj : lstCase){
           Case caseOldObj = (Case)trigger.oldMap.get(caseObj.id);
            if(caseObj.RecordType_DeveloperName__c != 'Loan_Application'){ */
                Refresh_Custom_Components__e refreshEvent = new Refresh_Custom_Components__e();
                System.debug('Publishing Refresh_Custom_Components__e event.');
                EventBus.publish(refreshEvent);
           // }
        //} 
    }
}