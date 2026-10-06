/**
 * @description       : test class related to VF01_DrawDetailsController.cls
 * @author            : Swapna Reddy
 * @group             : 
 * @last modified on  : 12/04/2022
 * @last modified by  : 
**/
@isTest
public with sharing class VF01_DrawDetailsControllerTest {

    public static String CASH_PRIZE_TYPE = 'CASH';
    @testSetup static void setupMethode() {
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(Prize_Type__c = CASH_PRIZE_TYPE), 'TestFactoryDefaults.DrawDefaults',true);
        //insert 2 prizes
        Prize__c[] prizeRecords = (Prize__c[])TestDataFactory.createSObjectList(new Prize__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE), 2 ,'TestFactoryDefaults.PrizeDefaults',true);
        //insert 1 Draw_Entry_Review__c
        Draw_Entry_Review__c reviewRecord = (Draw_Entry_Review__c)TestDataFactory.createSObject(new Draw_Entry_Review__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE) ,'TestFactoryDefaults.DrawEntryReviewDefaults',true);
    }
    
     @isTest
    static void testVF01_DrawDetailsController(){
        Test.startTest();
        Draw__c drawRecord =[Select Id from Draw__c Limit 1];
         ApexPages.StandardController sc1 = new ApexPages.StandardController(drawRecord);
        VF01_DrawDetailsController drawDetails = new VF01_DrawDetailsController(sc1);
        drawDetails.getDrawHistories();
        drawDetails.getDrawProcessSteps();
        drawDetails.getReviewsSize();
        drawDetails.getWinnersSize();
        Test.stopTest();
    }
}