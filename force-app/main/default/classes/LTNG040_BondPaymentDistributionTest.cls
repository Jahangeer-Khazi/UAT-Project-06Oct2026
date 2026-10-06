/**
* @author Jayanth Manickam
* @date Création 25/04/2024
* @date Modification
* @description :ALL the functions used in LTNG040_BondPaymentDistributionTest
* @history Modifications :   
*  
*/
@isTest
public class LTNG040_BondPaymentDistributionTest {
    
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
        //Investment_Distribution__c IDObj :[SELECT Id,Amount__c,Checker_Result__c,ISIN_Code__c,ISIN_Type__c,Maker__c,Maker_Result__c,type__c,Status__c,OwnerId FROM Investment_Distribution__c WHERE Id IN:invstDistId]
        Investment_Distribution__c InD = New Investment_Distribution__c();
        InD.Maker_Result__c='Send to Checker';
        InD.OwnerId=System.Label.Ila_Ops_Maker;
        InD.type__c='Maturity';
        InD.Distribution_Id__c='1';
        Insert InD;
    }

     @isTest
    public static void getInstrumentListViaApiTest(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG040_BondPaymentDistribution.getInstrumentListViaApi();
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    
    @isTest
    Public static void executeDistributionProcessTest(){
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
        //Investment_Distribution__c IDObj :[SELECT Id,Amount__c,Checker_Result__c,ISIN_Code__c,ISIN_Type__c,Maker__c,Maker_Result__c,type__c,Status__c,OwnerId FROM Investment_Distribution__c WHERE Id IN:invstDistId]
        Investment_Distribution__c InD = New Investment_Distribution__c();
        InD.Maker_Result__c='Send to Checker';
        InD.OwnerId=System.Label.Ila_Ops_Maker;
        InD.type__c='Maturity';
        insert InD;
        //BA.ISIN_Code__c='34324';
        List<String> InvstDistID = New List<String>();
        InvstDistID.add(InD.Id);
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG040_BondPaymentDistribution.executeDistributionProcess(InvstDistID);
        InD.Checker_Result__c='Execute Process';
        InD.OwnerId=System.Label.Ila_Ops_Checker;
        update InD;
        LTNG040_BondPaymentDistribution.executeDistributionProcess(InvstDistID);
        Test.StopTest();
    }
      @isTest
    public static void CompletedProcessingExecuteTest(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
         List<String> InvstDistID = New List<String>();
        Investment_Distribution__c IDObj =[SELECT Id,Amount__c,Checker_Result__c,ISIN_Code__c,ISIN_Type__c,Maker__c,Maker_Result__c,type__c,Status__c,OwnerId FROM Investment_Distribution__c limit 1];
        InvstDistID.add(IDObj.Id);
        LTNG040_BondPaymentDistribution.CompletedProcessing(InvstDistID,'execute');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
     @isTest
    public static void CompletedProcessingCalTest(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
         List<String> InvstDistID = New List<String>();
        Investment_Distribution__c IDObj =[SELECT Id,Amount__c,Checker_Result__c,ISIN_Code__c,ISIN_Type__c,Maker__c,Maker_Result__c,type__c,Status__c,OwnerId FROM Investment_Distribution__c limit 1];
        InvstDistID.add(IDObj.Id);
        LTNG040_BondPaymentDistribution.CompletedProcessing(InvstDistID,'calculate_distribution');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    @isTest
    public static void createSystemActionTest(){
         Test.startTest();
        Case cs=[Select Id from case limit 1];
        Account ac=[Select Id from Account limit 1];
        Investment_Distribution__c IND = [select Id from Investment_Distribution__c limit 1];
        LTNG040_BondPaymentDistribution.createBondSystemAction('reqBody', 'resBody', 'path', 'method', IND.Id, 400, 'strAction', 'strType');
      //  (final String reqBody, final String resBody, final String path, Final String method, Final Id invsId,Final Integer statCode, Final String strAction, Final String strType)
         Test.stopTest();
    }
}