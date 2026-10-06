public class CaseSLATriggerHandler {
    public static void handleOwnerChange(List<Case> newCases, Map<Id, Case> oldMap) {
        Map<Id, Id> caseToAgingMap = new Map<Id, Id>(); // CaseId -> Case_Aging__c Id
        Map<Id, String> ownerIdToNameMap = new Map<Id, String>();
        Map<String, String> queueGroupingMap = new Map<String, String>();
        Set<Id> ownerIds = new Set<Id>();
        List<Case_Aging_Line_Item__c> newLineItems = new List<Case_Aging_Line_Item__c>();
        
        Set<Id> caseIds = new Set<Id>();
        for (Case c : newCases) {
            if (oldMap != null && oldMap.containsKey(c.Id)) {
                Case oldCase = oldMap.get(c.Id);
                if (c.OwnerId != oldCase.OwnerId) {
                    caseIds.add(c.Id);
                    ownerIds.add(c.OwnerId);
                    ownerIds.add(oldCase.OwnerId);
                }
            }
        }
        
        for (Queue_Grouping__mdt qg : [SELECT Name__c, Grouping__c FROM Queue_Grouping__mdt]) {
            queueGroupingMap.put(qg.Name__c, qg.Grouping__c);
        }
        
        if (caseIds.isEmpty()) return;
        
        if (!ownerIds.isEmpty()) {
            for (User u : [SELECT Id, Name FROM User WHERE Id IN :ownerIds]) {
                ownerIdToNameMap.put(u.Id, u.Name);
            }
            for (Group g : [SELECT Id, Name FROM Group WHERE Id IN :ownerIds]) {
                ownerIdToNameMap.put(g.Id, g.Name);
            }
        }
        
        // Get related Case_Aging__c records
        Map<Id, Case_Aging__c> agingMap = new Map<Id, Case_Aging__c>();
        for (Case_Aging__c aging : [
            SELECT Id, Case__c, Owner__c, Previous_Owner__c, Group_Queue__c, Date_Assigned_to_New_Owner__c,
            Changed_By__c, Changed_Date_Time__c
            FROM Case_Aging__c 
            WHERE Case__c IN :caseIds
        ]) {
            caseToAgingMap.put(aging.Case__c, aging.Id);
            agingMap.put(aging.Id, aging); // 🔹 Storing full record for update
        }
        
        // Get latest Case_Aging_Line_Item__c per Case_Aging__c using CreatedDate DESC
        Map<Id, Case_Aging_Line_Item__c> latestLineItemMap = new Map<Id, Case_Aging_Line_Item__c>();
        List<Case_Aging_Line_Item__c> recentItems = [
            SELECT Id, Case_Aging__c, Time__c, CreatedDate 
            FROM Case_Aging_Line_Item__c 
            WHERE Case_Aging__c IN :caseToAgingMap.values()
            ORDER BY CreatedDate DESC
        ];
        
        for (Case_Aging_Line_Item__c item : recentItems) {
            if (!latestLineItemMap.containsKey(item.Case_Aging__c)) {
                latestLineItemMap.put(item.Case_Aging__c, item);
            }
        }
        
        // 🔹 Prepare Case_Aging__c records for update
        List<Case_Aging__c> agingRecordsToUpdate = new List<Case_Aging__c>();
        
        // Create new line items based on owner changes
        for (Case c : newCases) {
            Case oldCase = oldMap != null ? oldMap.get(c.Id) : null;
            
            Id agingId = caseToAgingMap.get(c.Id);
            if (agingId == null) continue;
            
            DateTime currentTime = System.now();
            DateTime previousTime = null;
            Decimal totalMinutes = null;
            Decimal totalHours = null;
            
            if (latestLineItemMap.containsKey(agingId) && latestLineItemMap.get(agingId) != null) {
                previousTime = latestLineItemMap.get(agingId).Time__c;
                if (previousTime != null) {
                    totalMinutes = (currentTime.getTime() - previousTime.getTime()) / (1000 * 60);
                    totalHours = totalMinutes / 60;
                }
            }
            
            String previousOwnerName = ownerIdToNameMap.get(oldCase.OwnerId);
            String newOwnerName = ownerIdToNameMap.get(c.OwnerId);
            
            // 🔹 Create new Line Item
            newLineItems.add(new Case_Aging_Line_Item__c(
                Case_Aging__c = agingId,
                Previous_Owner__c = previousOwnerName,
                New_Owner__c = newOwnerName,
                Time__c = currentTime,
                Total_Time__c = totalHours,
                Changed_By__c = UserInfo.getUserId(),
                Group_Queue__c = queueGroupingMap.get(previousOwnerName) != null ? queueGroupingMap.get(previousOwnerName) : 'Individuals'
            ));
            
            // 🔹 Update parent Case_Aging__c record
            Case_Aging__c aging = agingMap.get(agingId);
            if (aging != null) {
                aging.Previous_Owner__c = previousOwnerName;
                aging.Owner__c = newOwnerName;
                aging.Group_Queue__c = queueGroupingMap.get(previousOwnerName) != null ? queueGroupingMap.get(previousOwnerName) : 'Individuals';
                aging.Date_Assigned_to_New_Owner__c = currentTime;
                aging.Changed_By__c = UserInfo.getUserId();
                aging.Changed_Date_Time__c = currentTime;
                agingRecordsToUpdate.add(aging);
            }
        }
        
        if (!newLineItems.isEmpty()) {
            insert newLineItems;
        }
        
        // 🔹 Perform the update on Case_Aging__c records
        if (!agingRecordsToUpdate.isEmpty()) {
            update agingRecordsToUpdate;
        }
    }
    
    public static void populateOwnerAndGroupQueue(List<Case_Aging_Line_Item__c> newItems) {
        List<Case_Aging__c> caseAgingList = new List<Case_Aging__c>();
        
        // Step 1: Collect Case_Aging__c IDs
        Set<Id> caseAgingIds = new Set<Id>();
        for (Case_Aging_Line_Item__c item : newItems) {
            if (item.Case_Aging__c != null) {
                caseAgingIds.add(item.Case_Aging__c);
            } else {
                System.debug('Item missing Case_Aging__c reference: ' + item);
            }
        }
        
        if (caseAgingIds.isEmpty()) {
            return;
        }
        
        // Step 2: Query Case_Aging__c to get Case__c
        Map<Id, Id> agingIdToCaseIdMap = new Map<Id, Id>();
        for (Case_Aging__c aging : [SELECT Id, Case__c FROM Case_Aging__c WHERE Id IN :caseAgingIds]) {
            agingIdToCaseIdMap.put(aging.Id, aging.Case__c);
        }
        
        // Step 3: Collect Case IDs and query Case Owners
        Set<Id> caseIds = new Set<Id>(agingIdToCaseIdMap.values());
        
        if (caseIds.isEmpty()) {
            return;
        }
        
        Map<Id, Case> caseMap = new Map<Id, Case>([
            SELECT Id, OwnerId FROM Case WHERE Id IN :caseIds
        ]);
        
        
        // Step 4: Fetch Metadata Records
        Map<String, String> queueGroupingMap = new Map<String, String>();
        for (Queue_Grouping__mdt qg : [SELECT Name__c, Grouping__c FROM Queue_Grouping__mdt]) {
            queueGroupingMap.put(qg.Name__c, qg.Grouping__c);
        }
        
        // Step 5: Collect OwnerIds and resolve Names
        Set<Id> ownerIds = new Set<Id>();
        for (Case c : caseMap.values()) {
            if (c.OwnerId != null) {
                ownerIds.add(c.OwnerId);
            }
        }
        
        Map<Id, String> ownerIdToNameMap = new Map<Id, String>();
        if (!ownerIds.isEmpty()) {
            for (User u : [SELECT Id, Name FROM User WHERE Id IN :ownerIds]) {
                ownerIdToNameMap.put(u.Id, u.Name);
            }
            for (Group g : [SELECT Id, Name FROM Group WHERE Id IN :ownerIds]) {
                ownerIdToNameMap.put(g.Id, g.Name);
            }
        }
        
        // Step 6: Update newItems
        for (Case_Aging_Line_Item__c item : newItems) {
            if (item.New_Owner__c == null && String.isBlank(item.Group_Queue__c)) {
                Id agingId = item.Case_Aging__c;
                Id caseId = agingIdToCaseIdMap.get(agingId);
                
                
                
                if (caseId != null && caseMap.containsKey(caseId)) {
                    Id ownerId = caseMap.get(caseId).OwnerId;
                    String ownerName = ownerIdToNameMap.get(ownerId);
                    String groupValue = queueGroupingMap.get(ownerName);
                    
                    Case_Aging__c caseAge = new Case_Aging__c();
                    caseAge.Id = agingId;
                    caseAge.Owner__c = ownerName;
                    caseAge.Group_Queue__c = queueGroupingMap.get(ownerName);
                    caseAgingList.add(caseAge);
                    
                    item.New_Owner__c = ownerName;
                    item.Group_Queue__c = (groupValue != null) ? groupValue : 'Individuals';
                    
                } else {
                    System.debug('CaseId is null or not found for agingId: ' + agingId);
                }
            } else {
                System.debug('Skipping item as fields are already populated: ' + item.Id);
            }
        }
        if(caseAgingList.size() > 0) {
            update caseAgingList;
        }
    }
    
}