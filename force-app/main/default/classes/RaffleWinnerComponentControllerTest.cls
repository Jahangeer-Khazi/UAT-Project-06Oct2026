/**
 * @description       : 
 * @author            : ismael.ocana | 27/10/2021
 * @group             : 
 * @last modified by  : Aniss Mbarki | 13/04/2022
**/
@isTest
public with sharing class RaffleWinnerComponentControllerTest {

    
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
    public static void testInit(){

        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleWinnerComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);

        Test.startTest();
        RaffleWinnerComponentController rc = new RaffleWinnerComponentController();
        Test.stopTest();
        System.assertEquals(draw.Id, rc.drawId, 'draw found');
        System.assertEquals(false, rc.winnerList.isEmpty(), 'Winners found');
    }

    @isTest
    public static void testGetWinnerString(){
        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleWinnerComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);
        RaffleWinnerComponentController rc = new RaffleWinnerComponentController();
        
        String numberString;
        Test.startTest();
            numberString = rc.getWinnerString();
        Test.stopTest();
        System.assertEquals('1st', numberString, 'not the same ' + numberString);
    }

    @isTest
    public static void testGetNameCif(){
        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleWinnerComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);
        RaffleWinnerComponentController rc = new RaffleWinnerComponentController();

        String nameCif;
        Test.startTest();
            nameCif = rc.getNameCif();
        Test.stopTest();
        System.assertEquals(true, String.isNotBlank(nameCif), 'blank name ' + nameCif);
    }

    @isTest
    public static void testButtonActionNoFinish(){
        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleWinnerComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);
        RaffleWinnerComponentController rc = new RaffleWinnerComponentController();
        rc.finish = false;
        Integer num = rc.winnerNum;
        Test.startTest();
            rc.buttonAction();
        Test.stopTest();

        System.assertEquals(num + 1 , rc.winnerNum, 'Numbers not the same ' + rc.winnerNum);
    }

    @isTest
    public static void testButtonActionFinish(){
        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleWinnerComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);
        RaffleWinnerComponentController rc = new RaffleWinnerComponentController();
        rc.finish = true;
        Pagereference ref = null;
        Test.startTest();
            ref = rc.buttonAction();
        Test.stopTest();

        System.assert(ref != null, 'Pagereference not created ');
    }
}