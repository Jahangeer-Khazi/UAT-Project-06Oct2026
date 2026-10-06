/**
 * @description       : Test class for DrawEntriesApprovalBatch and DrawEntriesApprovalHelper
 * @author            : Jose Caballero
 * @group             : 
 * @last modified on  : 26/10/2021
 * @last modified by  : Jose Caballero
**/
@isTest
public with sharing class DrawEntriesApprovalTest {
    
    /**
    * @description prepares test data
    * @author Jose Caballero | 26/10/2021 
    **/
    @TestSetup
    static void makeData(){
        Account [] customerList = new List<Account>();
        Account tempAccount;
        Integer randomCIF;
        Draw_Entry__c [] drawEntryList = new List<Draw_Entry__c>();
        Draw_Entry__c tempDrawEntry;
        Draw__c draw = TestFactory.createDraw();
        insert draw;
        
        for(Integer i=0;i<20;i++) {
            randomCIF = (Integer)(Math.floor(Math.random() * ((9999999 - 1) +1) + 1));
            tempAccount = TestFactory.createPersonAccount('TestCustomer ' + String.valueOf(i),(Decimal)randomCIF,String.valueOf(randomCIF),'Staff',String.valueOf(randomCIF));
            customerList.add(tempAccount);
        }
        insert customerList;

        for(Account cust : customerList) {
            tempDrawEntry = TestFactory.createDrawEntry((String)draw.Id,'TestDrawEntry '+cust.Name,(String)cust.Id);
            drawEntryList.add(tempDrawEntry);
        }
        insert drawEntryList;
    }

    /**
    * @description test the job execution
    * @author Jose Caballero | 26/10/2021 
    **/
    @isTest
    static void batchIsExecuted() {

        Draw__c draw = [SELECT Id FROM Draw__c WHERE Draw_Name__c = 'Test'];

        DrawEntriesApprovalHelper.FlowInputs flowInput = new DrawEntriesApprovalHelper.FlowInputs();
        flowInput.drawId = draw.Id;

        DrawEntriesApprovalHelper.FlowInputs [] flowInputList = new List<DrawEntriesApprovalHelper.FlowInputs>();
        flowInputList.add(flowInput);
        
        List<String> batchJobIdList = DrawEntriesApprovalHelper.updateDrawEntries(flowInputList);
        System.Assert(!batchJobIdList.isEmpty(),'Job Id should be returned');
    }

    /**
    * @description tests the job results, checking the draw entries field after execution
    * @author Jose Caballero | 26/10/2021 
    **/
    @isTest 
    static void batchUpdatesDrawEntries() {

        Draw_Entry__c [] drawEntryList = [SELECT Id, Draw__c FROM Draw_Entry__c WHERE Draw__r.Draw_Name__c = 'Test'];
        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new DrawEntriesApprovalBatch(drawEntryList[0].Draw__c), 200);
        Test.stopTest();
        
        Draw_Entry__c [] resultDrawEntryList = [SELECT Id FROM Draw_Entry__c WHERE Draw__r.Draw_Name__c = 'Test' AND Draw_Entry_Approved__c = true];

        System.Assert(!resultDrawEntryList.isEmpty(),'Draw Entries should be Approved');
    }
}