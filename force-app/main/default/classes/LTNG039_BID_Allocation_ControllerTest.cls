/**
* @author Jayanth Manickam
* @date Création 25/03/2024
* @date Modification
* @description :ALL the functions used in LTNG039_BID_Allocation_ControllerTest
* @history Modifications :   
*  
*/
@isTest
public class LTNG039_BID_Allocation_ControllerTest {
    
    
     @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
         account ac=[SELECT Id FROM account LIMIT 1];
        //ac.Name='JDJDJDD';
        ac.ID_Type__pc='Bahraini ID';
        ac.ID_Number__pc='7382923023';
        update ac;
        Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Temp_Queue;
        cs.bs_Investment_ID__c='d';
        cs.bs_Issue_No__c='12';
        cs.bs_Issue_Amount__c='2052';
        cs.Sub_Status__c='In-Progress';
        cs.Type='New Bond/Sukuk Buy Request';
        cs.bs_ISIN_Code__c='34324';
        //cs.cc_Full_Name__c='FDFFDFDF';
        //cs.ID_Type__c='CPR';
       // cs.cc_ID_Number__c='343423442';
        cs.bs_Invitation_Date__c=System.Today();
        cs.bs_Tender_Date__c=System.Today();
        cs.bs_Issue_Date__c=System.Today();
        cs.bs_Maturity_Date__c=System.Today();
        cs.Case_Model__c='ila';
        cs.bs_Bid_Amount__c=2500;
        update cs;
        Bid_Allocation__c BA = New Bid_Allocation__c();
        BA.Maker_Result__c='Send to Checker';
        BA.OwnerId=System.Label.Ila_Ops_Maker;
        BA.ISIN_Code__c='34324';
        insert BA;
    }
    
   @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
        LTNG039_BID_Allocation_Controller.getBidAllocationRecordType();
        Test.stopTest();
    }
   @isTest
    public static void getInstrumentListViaApiTest(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG039_BID_Allocation_Controller.getInstrumentListViaApi();
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    
    @isTest
    Public static void processBidAllocationTest(){
        Test.StartTest();
        account ac=[SELECT Id FROM account LIMIT 1];
        //ac.Name='JDJDJDD';
        ac.ID_Type__pc='Bahraini ID';
        ac.ID_Number__pc='7382923023';
        update ac;
        Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Temp_Queue;
        cs.bs_Investment_ID__c='d';
        cs.bs_Instrument_Id__c='222';
        cs.bs_Issue_No__c='12';
        cs.bs_Issue_Amount__c='2052';
        cs.Sub_Status__c='In-Progress';
        cs.Type='New Bond/Sukuk Buy Request';
        cs.bs_ISIN_Code__c='34325';
        cs.bs_ISIN_Type__c='Temp';
        //cs.cc_Full_Name__c='FDFFDFDF';
        //cs.ID_Type__c='CPR';
       // cs.cc_ID_Number__c='343423442';
        cs.bs_Invitation_Date__c=System.Today();
        cs.bs_Tender_Date__c=System.Today();
        cs.bs_Issue_Date__c=System.Today();
        cs.bs_Maturity_Date__c=System.Today();
        cs.Case_Model__c='ila';
        cs.bs_Bid_Amount__c=2500;
        update cs;
        Bid_Allocation__c BA = New Bid_Allocation__c();
        BA.Maker_Result__c='Send to Checker';
        BA.OwnerId=System.Label.Ila_Ops_Maker;
        BA.ISIN_Code__c='34325';
        BA.Instrument_ID__c='222';
        insert BA;
        List<String> BidAllocationID = New List<String>();
        BidAllocationID.add(BA.Id);
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG039_BID_Allocation_Controller.processBidAllocation(BidAllocationID);
        BA.Checker_Result__c='Execute Bid Allocation';
        BA.OwnerId=System.Label.Ila_Ops_Checker;
        update BA;
        List<string> bidAllocationIds = new List<String>();
        bidAllocationIds.add(BA.Id);
        LTNG039_BID_Allocation_Controller.executeprocessBids(bidAllocationIds);
        Test.StopTest();
    }
     @isTest
    Public static void CompletedStageProcessingTest(){
        Test.StartTest();
        Bid_Allocation__c BA =[Select Id from Bid_Allocation__c limit 1];
        List<String> BidAllocationID = New List<String>();
        BidAllocationID.add(BA.Id);
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG039_BID_Allocation_Controller.CompletedStageProcessing(BidAllocationID);
        BA.Checker_Result__c='Execute Bid Allocation';
        BA.OwnerId=System.Label.Ila_Ops_Checker;
        update BA;
       // LTNG039_BID_Allocation_Controller.processBidAllocation(BidAllocationID);
        Test.StopTest();
    }
     @isTest
    Public static void CompletedStageBidAllocExecutionEstimateTest(){
        Test.StartTest();
        List<String> BidAllocationID = New List<String>();
        Bid_Allocation__c BA=[Select Id From Bid_Allocation__c limit 1];
        BidAllocationID.add(BA.Id);
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG039_BID_Allocation_Controller.CompletedStageBidAllocExecution(BidAllocationID,'Estimate');
        Test.StopTest();
    }
       @isTest
    Public static void CompletedStageBidAllocExecutionFinalTest(){
        Test.StartTest();
        List<String> BidAllocationID = New List<String>();
        Bid_Allocation__c BA=[Select Id From Bid_Allocation__c limit 1];
        BidAllocationID.add(BA.Id);
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG039_BID_Allocation_Controller.CompletedStageBidAllocExecution(BidAllocationID,'Final');
        Test.StopTest();
    }
     @isTest
    Public static void CloseAllBuyRequestTest(){
        Test.StartTest();
        List<String> BidAllocationID = New List<String>();
         Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Sub_status__c='Active';
        cs.bs_instrument_id__c='222';
        update cs;
        Bid_Allocation__c BA=[Select Id From Bid_Allocation__c limit 1];
        BA.Instrument_ID__c='222';
        BA.ISIN_Type__c='Bill';
        update BA;
        BidAllocationID.add(BA.Id);
        LTNG039_BID_Allocation_Controller.CloseAllBuyRequest(BidAllocationID);
        Test.StopTest();
    }
     @isTest
    Public static void Automate_BidAllocationScheduleTest(){
         Test.StartTest();
        List<String>BidCode= New List<String>{'BNF0000'};
         Automate_BidAllocationSchedule.processBidAllocation(BidCode);
         Test.StopTest();
    }
    
    @isTest
    public static void sendEmailTreasuryOpsTest(){
            Test.StartTest();
        List<String> BidAllocationID = New List<String>();
         Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Sub_status__c='Active';
        cs.bs_instrument_id__c='222';
        update cs;
        Bid_Allocation__c BA=[Select Id From Bid_Allocation__c limit 1];
        BA.Instrument_ID__c='222';
        BA.ISIN_Type__c='Bill';
        update BA;
        BidAllocationID.add(BA.Id);
          ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'pre-issuance',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content')
         
    );
    insert contentVersion_1;
         ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = BA.Id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
        LTNG039_BID_Allocation_Controller.sendEmailTreasuryOps(BidAllocationID,'Pre Issuance');
        Test.stopTest();
    }
    
     @isTest
    Public static void TestCreateBondSystemAction(){
         Test.StartTest();
        LTNG039_BID_Allocation_Controller.createBondSystemAction('Test','Test','Test','Test',200,'Test','Test');
         Test.StopTest();
    }
}