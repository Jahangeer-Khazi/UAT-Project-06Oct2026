public class CreditCardDeclineCasesController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCreditCardDeclineCases(Id caseId) {
        System.debug('Case Id:'+caseId);
        Case cseAccId = [SELECT Id,AccountId FROM Case Where Id  =: caseId LIMIT 1];
        List<Case> cseList = [SELECT Id,Subject,CaseNumber, AccountId, Status,Sub_Status__c,Type, Sub_Type__c,CreatedDate,ClosedDate,Owner.Name FROM CASE Where AccountId =:cseAccId.AccountId AND Sub_Status__c = 'Declined' AND TYPE IN('Credit Card Application','Credit Limit Increase Application','Credit Card Cash Collateral Application','Cash Collateral Credit Limit Increase Application') AND Customer_Segment__c IN('Regular','Premium')];
        System.debug('Case List:'+cseList.size());
        return cseList;
    }
    @AuraEnabled(cacheable=true)
    public static List<Case> getCreditCardCancelledCases(Id caseId) {
        System.debug('Case Id:'+caseId);
        Case cseAccId = [SELECT Id,AccountId FROM Case Where Id  =: caseId LIMIT 1];
        List<Case> cseList = [SELECT Id,Subject,CaseNumber, AccountId, Status,Sub_Status__c,Type, Sub_Type__c,CreatedDate,ClosedDate,Owner.Name FROM CASE Where AccountId =:cseAccId.AccountId AND Sub_Status__c = 'Cancelled' AND TYPE IN('Credit Card Application','Credit Limit Increase Application','Credit Card Cash Collateral Application','Cash Collateral Credit Limit Increase Application') AND Customer_Segment__c IN('Regular','Premium')];
        System.debug('Case List:'+cseList.size());
        return cseList;
    }
    @AuraEnabled
    public static Contact getContactFromRecord(Id cseId) {
        System.debug('Case Id:'+cseId);
        Case cse = [SELECT Id,ContactId FROM CASE WHERE Id = :cseId LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Id = :cse.ContactId];
        return cnt;
    }
}