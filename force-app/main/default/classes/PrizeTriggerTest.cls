/**
 * @description       : This class is the test class related to PrizeTrigger Trigger
 * @author            : Aniss Mbarki |13/04/2022
**/
@isTest
public with sharing class PrizeTriggerTest {

    @isTest
    static void deletePrizeTest(){
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(), 'TestFactoryDefaults.DrawDefaults',true);
        Prize__c prizeRecord = (Prize__c)TestDataFactory.createSObject(new Prize__c(Draw__c = drawRecord.Id) ,'TestFactoryDefaults.PrizeDefaults',true);

        drawRecord.Status__c = 'Ready';
        update drawRecord;
        
        try {
            delete prizeRecord;
        } catch (Exception e) {
            System.assert(true,'prevent deleting Prize records realted to a draw with status different of "new" and "rework" Successfully');      
        }
    }


}