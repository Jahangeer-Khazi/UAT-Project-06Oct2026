public class LTNG064_ReassignAgent {
		  @AuraEnabled
    public static List<Case> getCases(String AgentId) {
        List<Case> cccases = [SELECT Id,Subject,Status,Contact_Name__c,Type,Sales_Agent__c,cc_Case_Create_Date_Time__c,cc_Application_Submission_Date_Time__c,CreatedDate,ClosedDate,Case_Nature__c,Customer_CIF__c,Sub_Status__c,Origin,sub_type__c,RecordType_Name__c FROM Case Where
                              Status NOT IN('Closed','Approved','Rejected','All Child Cases Closed','Cancelled','Completed') AND OWNERID =:AgentId
                              Order by CreatedDate Desc ];
        return cccases;
    } 
    
    @auraEnabled
    public static List<Group>getCCqueue(){
        //String ccQueue=System.Label.CCQueue;
        List<String> ccQueue = System.Label.CCQueue.split(',');
        List<Group> allQueues = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name in:ccQueue];
    	return allQueues;
    }
    
    @AuraEnabled
    public static void assignCases(List<case>assignedSA){
        List<CaseShare> cslist = New List<CaseShare>();
        If(!assignedSA.isEmpty()){
            Update assignedSA; 
        }
        
    }
    
      @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchKey) {
        String key = (searchKey == null) ? '' : searchKey.trim();
        if (key.length() < 2) {
            return new List<User>();
        }

      /*  // Basic SOSL for speed; adjust fields as needed
        List<List<SObject>> results = Search.query(
            'FIND :key IN ALL FIELDS RETURNING User(Id, Name, Email, Title, SmallPhotoUrl LIMIT 10)'
        );*/
        String likeValue = '%'+key+'%';
        System.debug('likeValue'+likeValue);
      //   List<User> users = [Select Id, Name, Email from User where Name like:likeValue AND Profile.Name in('Contact Centre','RMT')];
        List<User> users = [Select Id, Name, Email from User where Name like:likeValue AND Profile.Name in('Contact Centre','RMT','System Administrator','Restricted System Admin')];
       // List<User> users = (results.isEmpty()) ? new List<User>() : (List<User>)results[0];

        // Enforce field-level security
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE, users
        );
        return (List<User>)decision.getRecords();
    }
}