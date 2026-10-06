/*      Organization : ABC Bank
*       Created By: Jayanth Manickam
*       Created Date: 15-06-2022
*       Change History: 
*    
*/

global class APB11_ProcessBulkCaseClosure implements Queueable  {
    global void execute(QueueableContext context) {
        Database.QueryLocator q;
        if(Test.isRunningTest()){
              q= Database.getQueryLocator([SELECT Id, eKYC_Decision__c, CreatedDate, Subject, Origin  FROM Case where Origin='EKYC-SIGNOFF' and status!='Closed'  AND account.eKYC_case_Signed_off__pc=False And eKYC_Decision__c!='Manual Retry' Order by CreatedDate LIMIT 5]);
        }else{
              q = Database.getQueryLocator([SELECT Id, eKYC_Decision__c, CreatedDate, Subject, Origin  FROM Case where Origin='EKYC-SIGNOFF' and status!='Closed'  AND account.eKYC_case_Signed_off__pc=False And eKYC_Decision__c!='Manual Retry' AND CreatedDate>=2024-01-01T00:00:00z AND CreatedDate<=2024-04-25T23:59:59z Order by CreatedDate LIMIT 5]);
        }
       
        Database.QueryLocatorIterator it =  q.iterator();
        while (it.hasNext())
        {
            Case a = (Case)it.next();
            a.eKYC_Decision__c='Manual Retry';
            system.debug(System.Now());
            Long endT = System.Now().getTime()+Integer.valueOf(System.Label.PeriodicBatchTimeDelay);
            While(System.Now().getTime() < endT){
            }
            if(!Test.isRunningTest()){
            update a;
            }    
            System.debug(a);
        }
        
        List<Case>PendingList = [SELECT Id, eKYC_Decision__c, CreatedDate, Subject, Origin  FROM Case where Origin='EKYC-SIGNOFF' and status!='Closed' AND CreatedDate>=2024-01-01T00:00:00z AND CreatedDate<=2024-04-25T23:59:59z  AND account.eKYC_case_Signed_off__pc=False And eKYC_Decision__c!='Manual Retry' Order by CreatedDate];
        if(!PendingList.isEmpty()){
            System.enqueueJob(new APB11_ProcessBulkCaseClosure()); 
        }
    }
    
}