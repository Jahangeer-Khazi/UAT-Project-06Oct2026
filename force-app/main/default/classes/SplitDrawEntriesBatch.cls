/**
 * @description       : Batch Program to handle the multiple Draw Entries. Called from shuffleDrawEntries
 * @author            : Navin Muneesamy
 * @group             :
 * @last modified on  : 10/02/2022
 * @last modified by  : Navin Muneesamy
 *
**/
global class SplitDrawEntriesBatch implements Database.Batchable<sObject> {
    private String strDrawId;
    private static RandomValueWrapper [] randomizedEntries = new List<RandomValueWrapper>();

    public SplitDrawEntriesBatch(String strParam) {
        this.strDrawId = strParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Name, Customer__c , CIF_ID__c, No_of_Chances__c, Draw_Entry_Approved__c, Draw__c, Draw__r.Name, Balance__c, From_Date__c, To_Date__c, Issue_Date__c, Justification__c, Kanz_Ticket_Balance__c, Last_deposit_date__c, Status__c FROM Draw_Entry__c WHERE No_of_Chances__c > 1 AND Draw__c = '+'\''+strDrawId+'\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Draw_Entry__c> scope) {
        Integer i = 0;
        List<Draw_Entry__c> dwList = new List<Draw_Entry__c>();

        for(Draw_Entry__c entry : scope) {
            Integer noOfChances = Integer.valueOf(entry.No_of_Chances__c);
            String entryName = entry.Name;
            Decimal entryBalance = entry.Balance__c;
            Decimal kanzTicketBalance = entry.Kanz_Ticket_Balance__c;
            for(i=0;i<noOfChances;i++) {
                // entry.Id = null;
                // entry.No_of_Chances__c = 1;
                // entry.Name = entryName + ' - '+ (i+1);
                Draw_Entry__c newDE;
                if(i==0){
                    // newDE = new Draw_Entry__c(Name=entryName + ' - '+ (i+1), Customer__c = entry.Customer__c, No_of_Chances__c = 1, Draw_Entry_Approved__c = entry.Draw_Entry_Approved__c, Draw__c = entry.Draw__c, Balance__c = entry.Balance__c - ((noOfChances-1) * (entry.Balance__c/noOfChances).setScale(2, RoundingMode.HALF_UP)));
                    // entry.Name = entryName + ' - '+ (i+1);
                    entry.No_of_Chances__c = 1;
                    entry.Balance__c = (entryBalance==0||entryBalance==null?0:entryBalance - ((noOfChances-1) * (entryBalance/noOfChances).setScale(2, RoundingMode.HALF_UP)));
                    entry.Kanz_Ticket_Balance__c = (kanzTicketBalance==0||kanzTicketBalance==null?0:kanzTicketBalance - ((noOfChances-1) * (kanzTicketBalance/noOfChances).setScale(2, RoundingMode.HALF_UP)));
                }
                else{
                   //newDE = new Draw_Entry__c(Name=entryName + ' - '+ (i+1), Customer__c = entry.Customer__c, No_of_Chances__c = 1, Draw_Entry_Approved__c = entry.Draw_Entry_Approved__c, Draw__c = entry.Draw__c, Balance__c = (entryBalance==0||entryBalance==null?0:(entryBalance/noOfChances).setScale(2, RoundingMode.HALF_UP)),
                    newDE = new Draw_Entry__c(Customer__c = entry.Customer__c, CIF_ID__c = entry.CIF_ID__c, No_of_Chances__c = 1, Draw_Entry_Approved__c = entry.Draw_Entry_Approved__c, Draw__c = entry.Draw__c, Balance__c = (entryBalance==0||entryBalance==null?0:(entryBalance/noOfChances).setScale(2, RoundingMode.HALF_UP)),
                                             From_Date__c = entry.From_Date__c, To_Date__c = entry.To_Date__c, Issue_Date__c = entry.Issue_Date__c, Justification__c = entry.Justification__c, Kanz_Ticket_Balance__c = (kanzTicketBalance==0|kanzTicketBalance==null?0:(kanzTicketBalance/noOfChances).setScale(2, RoundingMode.HALF_UP)), Last_deposit_date__c = entry.Last_deposit_date__c, Status__c = entry.Status__c);
                }
                if(newDE<>null){
                    randomizedEntries.add(new RandomValueWrapper(newDE)); // Random number is associated on creation
                }
            }
        }

        // List is sorted based on random number
        randomizedEntries.sort();

        for(i=0;i<randomizedEntries.size();i++){
            dwList.add((Draw_Entry__c)randomizedEntries[i].value);
        }

        ID jobID = System.enqueueJob(new DrawQueueable(dwList));
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
    }
}