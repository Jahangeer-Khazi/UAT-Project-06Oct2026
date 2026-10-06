/**
 * @description       : test class for RaffleComponentController.cls
 * @author            : Swapna Reddy
 * @group             : 
 * @last modified on  : 13/04/2022
 * @last modified by  : 
**/
@isTest
public with sharing class RaffleComponentControllerTest {   

    
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
    static void testInit(){

        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);

        Test.startTest();
        RaffleComponentController rc = new RaffleComponentController();
        Test.stopTest();
        System.assertEquals(draw.Id, rc.drawId, 'draw not found');
    }

    @isTest
    static void testRaffleComponentController(){

        Draw__c draw = [SELECT ID FROM Draw__c LIMIT 1];
        PageReference pageRef = Page.RaffleComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', draw.Id);
        RaffleComponentController rc = new RaffleComponentController();
		rc.getItems();
        Pagereference pr;
        Test.startTest();
            pr = rc.navigateToNextPage();
        Test.stopTest();

        System.assertEquals(true, pr != null, 'Cant navigate');
    }
    
     @isTest
    static void testRaffleComponentControllerNegative(){

        //creating draw
        Draw__c drawrec = (Draw__c)TestDataFactory.createSObject(new Draw__c(Status__c='New'), 'TestFactoryDefaults.DrawDefaults',true);
        
        PageReference pageRef = Page.RaffleComponent;
        Test.setCurrentPageReference(pageRef);
        pageRef.getParameters().put('drawId', drawrec.Id);
        RaffleComponentController rc = new RaffleComponentController();
		rc.getItems();
        Pagereference pr;
        Test.startTest();
            pr = rc.navigateToNextPage();
        Test.stopTest();

        System.assertNotEquals(true, pr != null, 'Cant navigate');
    }
}