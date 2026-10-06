/**
 * @author Wissal benqezza
 * @date Création 13/04/2022
 * @date Modification
 * @description :
 * @history : 
 *			#CH01 : 4/01/2022 Ad-hoc & Recurring Raffle Automation 
 */
@isTest
public with sharing class LTNG14_CallDrawApisControllerTest {

    //test class related to LTNG14_CallDrawApisController.cls
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
    static void createDrawApiTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            Boolean isError = LTNG14_CallDrawApisController.createDrawApi(drawRecord.Id);
            System.assert(isError == false);
        Test.stopTest();
    }

    @isTest
    static void updateDrawStatusTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            
            //test status 200
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            Boolean isError = LTNG14_CallDrawApisController.updateDrawStatus(drawRecord.Id,'APPROVED');
            System.assert(isError == false);

            //test error case status 500
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 500;
            Boolean isError1 = LTNG14_CallDrawApisController.updateDrawStatus(drawRecord.Id,'APPROVED');
            System.assert(isError1 == true);
        Test.stopTest();
    }

    @isTest
    static void updateDrawStatusApiTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            Boolean isError = LTNG14_CallDrawApisController.updateDrawStatusApi(drawRecord.Id,'APPROVED');
            System.assert(isError == false);
        Test.stopTest();
    }

    @isTest
    static void updateDrawStatusApiFromFlowTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            LTNG14_CallDrawApisController.RequestStatusUpdate req = new LTNG14_CallDrawApisController.RequestStatusUpdate();
            req.drawId = drawRecord.Id;
            req.status = 'APPROVED';
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            LTNG14_CallDrawApisController.updateDrawStatusApiFromFlow(new List<LTNG14_CallDrawApisController.RequestStatusUpdate>{req});
        Test.stopTest();
    }

    @isTest
    static void triggerApprovalProcessesFlowPendingValidationTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            drawRecord.Status__c = 'Pending Validation';
            update drawRecord;
        Test.stopTest();
    }

    @isTest
    static void triggerApprovalProcessesFlowApprovedTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            drawRecord.Status__c = 'Approved';
            update drawRecord;
        Test.stopTest();
    }

    @isTest
    static void triggerApprovalProcessesFlowRejectedTest(){
        Test.startTest();
            Draw__c drawRecord = [SELECT Id FROM Draw__c LIMIT 1];
            drawRecord.Status__c = 'Rejected';
            update drawRecord;
        Test.stopTest();
    }

}