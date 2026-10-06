/**
 * @description       :
 * @author            : Jose Caballero
 * @group             :
 * @last modified on  : 22/10/2021
 * @last modified by  : ismael.ocana
**/
@isTest
public with sharing class RaffleRandomizationTest {

    @TestSetup
    static void makeData(){

        Draw__c draw = new Draw__c();
        draw.Name = 'draw-test';
        draw.Number_of_Tiers__c = 3;
        draw.Status__c = 'New';
        draw.Draw_Type__c = 'Kanz';
        draw.Grand_Prize__c = 12000;

        insert draw;

        List <Draw_Entry__c> drawEntryList = new List <Draw_Entry__c>();
        List <Account> customerList = new List <Account>();
        Account tempCustomer;
        Decimal randomCIF;
        for (Integer i = 0; i <= 4; i++) {
            randomCIF = (Integer)(Math.floor(Math.random() * ((9999999 - 1) +1) + 1));
            tempCustomer = TestFactory.createPersonAccount('Name ' + i, randomCIF, null, 'Staff', String.valueOf(randomCIF));
            customerList.add(tempCustomer);
        }
        insert customerList;

        for (Account customer : customerList) {
            Draw_Entry__c drawEntryTemp = new Draw_Entry__c();
            drawEntryTemp.Customer__c = customer.Id;
            drawEntryTemp.No_of_Chances__c = Math.floor(Math.random() * ((2 - 1) +1) + 1);
            drawEntryTemp.Draw__c = draw.Id;
            drawEntryList.add(drawEntryTemp);
        }

        insert drawEntryList;

        List<Prize__c> prizeList= new List<Prize__c>();

        Prize__c firstPrize = new Prize__c();
        firstPrize.Winning_Amount__c = 6000;
        firstPrize.Draw__c = draw.Id;
        firstPrize.Number_of_Winners__c = 1;
        firstPrize.Order__c = '1';
        prizeList.add(firstPrize);

        Prize__c secondPrize = new Prize__c();
        secondPrize.Winning_Amount__c = 4000;
        secondPrize.Draw__c = draw.Id;
        secondPrize.Number_of_Winners__c = 2;
        secondPrize.Order__c = '2';
        prizeList.add(secondPrize);

        Prize__c thirdPrize = new Prize__c();
        thirdPrize.Winning_Amount__c = 2000;
        thirdPrize.Draw__c = draw.Id;
        thirdPrize.Number_of_Winners__c = 4;
        thirdPrize.Order__c = '3';
        prizeList.add(thirdPrize);

        insert prizeList;
    }

    @isTest
    static void executeRaffle() {

        Id drawId = [SELECT Id FROM Draw__c WHERE Name = 'draw-test' LIMIT 1].Id;
        Prize__c [] prizes = [SELECT Name, Tier__c, Order__c, Number_of_Winners__c FROM Prize__c WHERE Draw__r.Name = 'draw-test' ORDER BY Order__c ASC];

        Integer noOfPrizes = 0;

        for(Prize__c prize : prizes) {
            noOfPrizes += (Integer)prize.Number_of_Winners__c;
        }

        Test.startTest();
        Winner__c [] winners = RaffleRandomization.executeRaffle(drawId,prizes);
        Test.stopTest();
        String [] customerIds = new List<String>();
        for(Winner__c winner : winners) {
            customerIds.add(winner.Customer__c);
        }
        Account [] customerList = [SELECT Id FROM Account WHERE Id IN :customerIds];
        System.debug(JSON.serialize(winners));
        System.assert(noOfPrizes>=winners.size(), 'There should be the same or less winners than number of prizes');
        System.assertEquals(customerList.size(),winners.size(), 'There should be the same customer and winners');

    }
}