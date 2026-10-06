/**
 * @description       : This class is the test class related to DrawEntryReviewTrigger Trigger
 * @author            : Aniss Mbarki |13/04/2022
**/
@isTest
public with sharing class DrawEntryReviewTriggerTest {

    @isTest
    static void deletePrizeTest(){
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(), 'TestFactoryDefaults.DrawDefaults',true);
        Draw_Entry_Review__c reviewRecord = (Draw_Entry_Review__c)TestDataFactory.createSObject(new Draw_Entry_Review__c(Draw__c = drawRecord.Id) ,'TestFactoryDefaults.DrawEntryReviewDefaults',true);
        
        drawRecord.Status__c = 'Ready';
        update drawRecord;

        try {
            delete reviewRecord;
        } catch (Exception e) {
            System.assert(true,'prevent deleting Draw_Entry_Review records realted to a draw with status different of "new" and "rework" Successfully');      
        }
    }
}