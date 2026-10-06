/**
 * @description       : test class related to DM004_Draw.cls
 * @author            : Swapna Reddy
 * @group             : 
 * @last modified on  : 12/04/2022
 * @last modified by  : 
 * @history : 
 *				#CH01 : 4/01/2022 Ad-hoc & Recurring Raffle Automation 
**/
@isTest
public with sharing class DM004_DrawTest {
	
    public static String CASH_PRIZE_TYPE = 'CASH'; 
    @testSetup static void setupMethode() {
        //#CH01 : add prize Type
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(Prize_Type__c = CASH_PRIZE_TYPE), 'TestFactoryDefaults.DrawDefaults',true);
        //insert 2 prizes
        Prize__c[] prizeRecords = (Prize__c[])TestDataFactory.createSObjectList(new Prize__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE), 2 ,'TestFactoryDefaults.PrizeDefaults',true);
        //insert 1 Draw_Entry_Review__c
        Draw_Entry_Review__c reviewRecord = (Draw_Entry_Review__c)TestDataFactory.createSObject(new Draw_Entry_Review__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE) ,'TestFactoryDefaults.DrawEntryReviewDefaults',true);
    }
    
    @isTest
    static void testDM004_Draw(){
        Set<Id> drawIds= new Set<Id>();
        List<Draw__c> drawRecord = [Select Id from Draw__c];
        drawIds.add(drawRecord[0].Id);
        Test.startTest();
        DM004_Draw.getDrawByIds(drawIds);
        DM004_Draw.getDrawWithHistoriesAndProcessStepsByIds(drawIds);
        DM004_Draw.getDrawWithWinnersOrderByPrizeWinningAmount(drawIds);
        Test.stopTest();
    }
    
    //#CH01 : Start
    @isTest
    static void test2DM004_Draw(){
        Set<Id> drawIds= new Set<Id>();
        List<Draw__c> drawRecord = [Select Id from Draw__c];
        drawIds.add(drawRecord[0].Id);
        Test.startTest();
        DM004_Draw.getDrawWithPrizesAndReviewsByIds(drawIds);
        DM004_Draw.getDrawWithPrizesAndWinnersByIds(drawIds);
        DM004_Draw.getDrawWithWinnersOrderByPrizeOrder(drawIds);
        Test.stopTest();
    }
    //#CH01 : End
}