public class HandleCheckerApprovalQueueable implements Queueable, Database.AllowsCallouts {

    private Set<Id> caseIds;

    // Constructor to accept Case Ids
    public HandleCheckerApprovalQueueable(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }

    public void execute(QueueableContext context) {
        if (caseIds == null || caseIds.isEmpty()) {
            return;
        }
        List<Case> caseList = [
            SELECT Id, cc_Checker_Result__c, RecordTypeId, Type, Sub_Type__c,
                   cc_Request_Type__c, Region_Flag__c, Case_Model__c,
                   asc_Current_Segment__c, AccountId, Customer_CIF__c
            FROM Case
            WHERE Id IN :caseIds
        ];

        Id serviceRequestRecordTypeId = Schema.SObjectType.Case
            .getRecordTypeInfosByDeveloperName()
            .get('Service_Request')
            .getRecordTypeId();

        for (Case newCase : caseList) {
            if (newCase.cc_Checker_Result__c == 'Approve' &&
                newCase.RecordTypeId == serviceRequestRecordTypeId &&
                newCase.Type == 'Account' &&
                newCase.Sub_Type__c == 'Segment' &&
                (newCase.cc_Request_Type__c == 'Staff Joiner' || newCase.cc_Request_Type__c == 'Staff Leaver')) {
                
                String regionName = newCase.Region_Flag__c;
                
                if (newCase.Case_Model__c == 'both' &&
                    (newCase.asc_Current_Segment__c == 'Staff' || newCase.asc_Current_Segment__c == 'STAFF')) {
                        
                    ApiConnection.Response response1 = SegmentAPIHandler.updateSegment(
                        newCase.Customer_CIF__c, newCase.asc_Current_Segment__c, newCase.Id, regionName
                    );

                    ApiConnection.Response response2 = SegmentAPIHandler.updateSegment(
                        newCase.Customer_CIF__c, newCase.asc_Current_Segment__c, newCase.Id, regionName + '_alburaq'
                    );
                        
                } else {
                    if (newCase.Case_Model__c == 'alburaq') {
                        regionName += '_alburaq';
                    }
                    
                    ApiConnection.Response response3 = SegmentAPIHandler.updateSegment(
                        newCase.Customer_CIF__c, newCase.asc_Current_Segment__c, newCase.Id, regionName
                    );
                    
                }
            } else {
                System.debug('Case does not match Service Request conditions or Checker Result not Approve.');
            }
        }
    }
}