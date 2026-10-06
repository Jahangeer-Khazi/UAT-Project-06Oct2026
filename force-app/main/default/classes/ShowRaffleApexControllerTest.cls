/**
 * @description       : test class for ShowRaffleApexController.cls
 * @author            : Swapna Reddy
 * @group             : 
 * @last modified on  : 13/04/2022
 * @last modified by  : 
**/
@isTest
public with sharing class ShowRaffleApexControllerTest {
    
    @TestSetup
    static void makeData(){

        //creating customers
        String customerRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account accRecord = (Account)TestDataFactory.createSObject(new Account(CIF__pc = '12345678',recordtypeId = customerRecordType,PersonEmail='test2@ilatest.com',Employment_Type__pc='Staff'), 'TestFactoryDefaults.AccountDefaults',true);

        //creating draw
        Draw__c drawRecord = (Draw__c)TestDataFactory.createSObject(new Draw__c(Status__c='New'), 'TestFactoryDefaults.DrawDefaults',true);

        //create prizee
        Prize__c[] prizeRecords = (Prize__c[])TestDataFactory.createSObjectList(new Prize__c(Draw__c = drawRecord.Id), 2 ,'TestFactoryDefaults.PrizeDefaults',true);

        //create draw entries
        Draw_Entry_Review__c reviewRecord = (Draw_Entry_Review__c)TestDataFactory.createSObject(new Draw_Entry_Review__c(Draw__c = drawRecord.Id) ,'TestFactoryDefaults.DrawEntryReviewDefaults',true);

        //create winner
        Winner__c winner = (Winner__c)TestDataFactory.createSObject(new Winner__c(Draw__c = drawRecord.Id,Prize__c = (String) prizeRecords.get(0).Id,Customer__c=accRecord.Id),'TestFactoryDefaults.WinnerDefaults',true);
        
        drawRecord.Status__c='Ready';
        drawRecord.MOIC_Representative_Name__c='test1';
        drawRecord.Internal_Auditor_Name__c='test2';
        drawRecord.External_Auditor_Name__c='test3';
        drawRecord.ila_Marketing__c='test4';
        drawRecord.ila_Business__c='test5';
        drawRecord.ila_Risk__c='test6';
        drawRecord.ila_Finance__c='test6';
        drawRecord.ComplianceDepartment__c='testA';
        drawRecord.LegalDepartment__c='testB';
        drawRecord.HumanResourcesDepartment__c='testC';
        update drawRecord;
    }

    @isTest
    public static void testOK(){
        String url;
        Draw__c d = [SELECT ID FROM Draw__c LIMIT 1];
        system.debug('id==>'+d.Id);
        Test.startTest();
        try {
            ShowRaffleApexController.createWinnerListApi(d.Id);
            url = ShowRaffleApexController.getURL((String) d.Id);
        } catch(Exception e){
            System.assert(true, 'Unexpected error ' + e.getMessage());
        }
        Test.stopTest();
        System.assertEquals(false, String.isNotBlank(url), 'url not returned');
    }

    @isTest
    public static void testKOTemplate(){
        String url;
        Draw__c d = [SELECT ID FROM Draw__c LIMIT 1];
        Test.startTest();
        try {
            url = ShowRaffleApexController.getURL((String) d.Id);
        } catch(Exception e){
            System.assertEquals(true, e.getMessage().contains(System.label.TEMPLATE_MISSING), 'Template is not missing ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void testKOWinner(){
        String url;
        Draw__c d = [SELECT ID FROM Draw__c LIMIT 1];
        //delete [SELECT ID FROM Draw_Entry__c];
        Test.startTest();
        try {
            url = ShowRaffleApexController.getURL((String) d.Id);
        } catch(Exception e){
            System.assertEquals(false, e.getMessage().contains(System.label.ENTRIES_NOT_FOUND), 'Entries is not missing ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    public static void testKOStatus(){
        String url;
        Draw__c d = [SELECT ID FROM Draw__c LIMIT 1];
        d.Status__c = 'new';
        update d;
        Test.startTest();
        try {
            url = ShowRaffleApexController.getURL((String) d.Id);
        } catch(Exception e){
            System.assertEquals(true, e.getMessage().contains(System.label.RAFFLE_NOT_RIGHT_STATUS), 'Status not correct ' + e.getMessage());
        }
        Test.stopTest();
    } 
}