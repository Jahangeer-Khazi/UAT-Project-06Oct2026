/**
 * @description       : test class related to LTNG11_DrawDataCsvController.cls
 * @author            : Swapna Reddy
 * @group             : 
 * @last modified on  : 12/04/2022
 * @last modified by  : 
 * @history : 
 *			#CH01 : 6/01/2022 Ad-hoc & Recurring Raffle Automation
**/
@isTest
public with sharing class LTNG11_DrawDataCsvControllerTest {

    public static String CASH_PRIZE_TYPE = 'CASH';
    @testSetup static void setupMethode() {
        //#CH01
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(Prize_Type__c = CASH_PRIZE_TYPE), 'TestFactoryDefaults.DrawDefaults',true);
        //insert 2 prizes
        Prize__c[] prizeRecords = (Prize__c[])TestDataFactory.createSObjectList(new Prize__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE), 2 ,'TestFactoryDefaults.PrizeDefaults',true);
        //insert 1 Draw_Entry_Review__c
        Draw_Entry_Review__c reviewRecord = (Draw_Entry_Review__c)TestDataFactory.createSObject(new Draw_Entry_Review__c(Draw__c = drawRecord.Id,Prize_Type__c = CASH_PRIZE_TYPE) ,'TestFactoryDefaults.DrawEntryReviewDefaults',true);
    }
     @isTest
    static void testgetDrawDataViaApi(){
        Test.startTest();
        Draw__c drawRecord=[Select Id from Draw__c Limit 1];
        MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
        LTNG11_DrawDataCsvController.getDrawDataViaApi(drawRecord.Id, 'modified');
        LTNG11_DrawDataCsvController.trackClickedButton(drawRecord.Id, 'View Files Button');
        LTNG11_DrawDataCsvController.checkDrawDataVisibilityForKanzStaff(drawRecord.Id);
        Test.stopTest();
    }
}