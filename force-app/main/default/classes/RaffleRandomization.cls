/**
 * @description       : Used to randomize and generate winners for a Draw__c raffle
 * @author            : Jose Caballero
 * @group             :
 * @last modified on  : 27/10/2021
 * @last modified by  : Jose Caballero
 * ************************************************
 * @last modified on  : 11/01/2022
 * @last modified by  : Navin Muneesamy
 * @description       : Show the Draw Entries after they have been split
 * ************************************************
**/
public with sharing class RaffleRandomization {

    private static RandomValueWrapper [] randomizedEntries = new List<RandomValueWrapper>();
    private static Draw_Entry__c [] drawEntriesList = new List<Draw_Entry__c>();
    private static Map<String,Winner__c> winnersByCustomer = new Map<String,Winner__c>();
    private static Prize__c [] prizeList = new List<Prize__c>();

    /**
    * @description Executes all the raffle logic, receives the draw needed data, and returns the winners.
    * @author Jose Caballero | 26/10/2021
    * @param drawId Draw id to be raffled
    * @param prizes Prize list to raffle
    * @return Winner__c list of Winners after raffle execution
    **/
    public static Winner__c [] executeRaffle(Id drawId, Prize__c [] prizes) {
        if(String.isNotBlank(drawId)) {
            drawEntriesList = [SELECT Customer__c,  No_of_Chances__c, Draw__r.Id, Draw__r.Name FROM Draw_Entry__c WHERE Draw__c = :drawId AND No_of_Chances__c > 0 AND Status__c IN (NULL,'Eligible')];
            prizeList = prizes;
            generateRandomEntriesList();
            getWinners();
        }
        return winnersByCustomer.values();
    }

    /**
    * @description Splits draw entries and randomize order so winners can be determined
    * @author Jose Caballero | 26/10/2021
    **/
    private static void generateRandomEntriesList() {
        Integer i = 0;
        for(Draw_Entry__c entry : drawEntriesList) {
            for(i=0;i<entry.No_of_Chances__c;i++) {
                randomizedEntries.add(new RandomValueWrapper(entry)); // Random number is associated on creation
            }
        }

        // List is sorted based on random number
        randomizedEntries.sort();
    }

    /**
    * @description Splits draw entries and randomize order. The result are individual chances i.e every resultant draw entry will have a number of chances of 1
    * @author Navin Muneesamy | 11/01/2022
    **/
    /* private static void generateRandomEntriesListChance1() {
        Integer i = 0;
        for(Draw_Entry__c entry : drawEntriesList) {
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
                    entry.Name = entryName + ' - '+ (i+1);
                    entry.No_of_Chances__c = 1;
                    entry.Balance__c = entryBalance - ((noOfChances-1) * (entryBalance/noOfChances).setScale(2, RoundingMode.HALF_UP));
                    entry.Kanz_Ticket_Balance__c = kanzTicketBalance - ((noOfChances-1) * (kanzTicketBalance/noOfChances).setScale(2, RoundingMode.HALF_UP));
                }
                else{
                	newDE = new Draw_Entry__c(Name=entryName + ' - '+ (i+1), Customer__c = entry.Customer__c, No_of_Chances__c = 1, Draw_Entry_Approved__c = entry.Draw_Entry_Approved__c, Draw__c = entry.Draw__c, Balance__c = (entryBalance/noOfChances).setScale(2, RoundingMode.HALF_UP),
                                             From_Date__c = entry.From_Date__c, To_Date__c = entry.To_Date__c, Issue_Date__c = entry.Issue_Date__c, Justification__c = entry.Justification__c, Kanz_Ticket_Balance__c = (kanzTicketBalance/noOfChances).setScale(2, RoundingMode.HALF_UP), Last_deposit_date__c = entry.Last_deposit_date__c, Status__c = entry.Status__c);
                }
                if(newDE<>null){
                	randomizedEntries.add(new RandomValueWrapper(newDE)); // Random number is associated on creation
                }
            }
        }

        // List is sorted based on random number
        randomizedEntries.sort();
    } */

    /**
    * @description Show the Draw Entries after they have been split
    * @author Navin Muneesamy | 11/01/2022
    **/
    /*public static void splitDrawEntries(Id drawId) {
        integer i = 0;
        List<Draw_Entry__c> dwList = new List<Draw_Entry__c>();
        if(String.isNotBlank(drawId)) {
            drawEntriesList = [SELECT Name, Customer_CIF__c, Customer__c, No_of_Chances__c, Draw_Entry_Approved__c, Draw__c, Draw__r.Name, Balance__c, From_Date__c, To_Date__c, Issue_Date__c, Justification__c, Kanz_Ticket_Balance__c, Last_deposit_date__c, Status__c FROM Draw_Entry__c WHERE Draw__c = :drawId AND No_of_Chances__c > 1];
            generateRandomEntriesListChance1();
            for(i=0;i<randomizedEntries.size();i++){
                dwList.add((Draw_Entry__c)randomizedEntries[i].value);
            }

            ID jobID = System.enqueueJob(new DrawQueueable(dwList));
            update drawEntriesList;
        }
    } */

    /**
    * @description Iterate over Prizes > Number of Winners > Entries, to obtain the Winners
    * @author Jose Caballero | 26/10/2021
    **/
    private static void getWinners () {

        Winner__c [] winners = new List<Winner__c>();
        Winner__c tempWinner;
        Draw_Entry__c tempDrawEntry;
        Integer i = 0;
        for(Prize__c prize : prizeList) {
            for(i=0;i<prize.Number_of_Winners__c;i++) {
                for(RandomValueWrapper randomEntry : randomizedEntries) {
                    tempDrawEntry = (Draw_Entry__c)randomEntry.value;
                    if(!winnersByCustomer.keySet().contains(String.valueOf(tempDrawEntry.Customer__c))) {
                        tempWinner = new Winner__c();
                        tempWinner.Prize__c = prize.Id;
                        tempWinner.Draw__c = tempDrawEntry.Draw__r.Id;
                        tempWinner.Draw_Entry__c = tempDrawEntry.Id;
                        tempWinner.Customer__c = tempDrawEntry.Customer__c;
                        winnersByCustomer.put(String.valueOf(tempWinner.Customer__c),tempWinner);
                        break;
                    }
                }
            }
        }
    }
}