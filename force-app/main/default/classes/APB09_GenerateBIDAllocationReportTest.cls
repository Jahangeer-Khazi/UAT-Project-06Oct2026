/**
* @author Jayanth Manickam
* @date Création 25/04/2024
* @date Modification
* @description :ALL the functions used in APB09_GenerateBIDAllocationReportTest
* @history Modifications :   
*  
*/

@isTest
public class APB09_GenerateBIDAllocationReportTest {
    
      @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
	
    @isTest
    Public static void processMinimumBidAllocationTest(){
        Test.StartTest();
        account acc1=[SELECT Id,PersonContactId FROM account LIMIT 1];
        //ac.Name='JDJDJDD';
        acc1.ID_Type__pc='Bahraini ID';
        acc1.ID_Number__pc='7382923023';
        update acc1;
          Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case cs = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
       // Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Temp_Queue;
        cs.bs_Investment_ID__c='2';
        cs.bs_Instrument_Id__c='20';
        cs.bs_Issue_No__c='12';
        cs.bs_Issue_Amount__c='2052';
        cs.Sub_Status__c='In-Progress';
        cs.Type='New Bond/Sukuk Buy Request';
        cs.bs_ISIN_Code__c='3434';
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
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        APB09_GenerateBIDAllocationReport PR = New APB09_GenerateBIDAllocationReport(True,'3434','','Manual');
        Database.executeBatch(PR);
        Test.StopTest();
    }
    @isTest
    Public static void processBidAllocationTest(){
        Test.StartTest();
         account acc1=[SELECT Id,PersonContactId FROM account LIMIT 1];
        //ac.Name='JDJDJDD';
        acc1.ID_Type__pc='Bahraini ID';
        acc1.ID_Number__pc='7382923023';
        update acc1;
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case cs = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Temp_Queue;
        cs.bs_Investment_ID__c='d';
         cs.bs_Instrument_Id__c='25';
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
        cs.bs_Bid_Amount__c=50000;
        update cs;
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        APB09_GenerateBIDAllocationReport PR = New APB09_GenerateBIDAllocationReport(True,'34324','Manual');
        Database.executeBatch(PR);
        Test.StopTest();
    }
       @isTest
    Public static void processCancelBidAllocationTest(){
        Test.StartTest();
      account acc1=[SELECT Id,PersonContactId FROM account LIMIT 1];
        //ac.Name='JDJDJDD';
        acc1.ID_Type__pc='Bahraini ID';
        acc1.ID_Number__pc='7382923023';
        update acc1;
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case cs = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Temp_Queue;
        cs.bs_Investment_ID__c='5';
        cs.bs_Instrument_Id__c='26';
        cs.bs_Issue_No__c='12';
        cs.bs_Issue_Amount__c='2052';
        cs.Sub_Status__c='In-Progress';
        cs.Type='New Bond/Sukuk Buy Request';
        cs.bs_ISIN_Code__c='434';
        //cs.cc_Full_Name__c='FDFFDFDF';
        //cs.ID_Type__c='CPR';
       // cs.cc_ID_Number__c='343423442';
        cs.bs_Invitation_Date__c=System.Today();
        cs.bs_Tender_Date__c=System.Today();
        cs.bs_Issue_Date__c=System.Today();
        cs.bs_Maturity_Date__c=System.Today();
        cs.Case_Model__c='ila';
        cs.bs_Bid_Amount__c=50000;
        update cs;
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        APB09_GenerateBIDAllocationReport PR = New APB09_GenerateBIDAllocationReport(True,'434','Manual');
        Database.executeBatch(PR);
        Test.StopTest();
    }
   @isTest
    Public static void processNoBidAllocationTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        APB09_GenerateBIDAllocationReport PR = New APB09_GenerateBIDAllocationReport(True,'555','Manual');
        Database.executeBatch(PR);
        Test.StopTest();
    }
    @isTest
    Public static void processBidAllocationTriggerTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        APB09_GenerateBIDAllocationReport PR = New APB09_GenerateBIDAllocationReport(True,'Manual');
        Database.executeBatch(PR);
        Test.StopTest();
    }
   @isTest
    Public static void processBidAllocationSysAction(){
         Test.StartTest();
        Case cs=[Select Id from case limit 1];
        Account ac=[Select Id from Account limit 1];
        APB09_GenerateBIDAllocationReport.createSystemAction('reqBody', 'resBody', 'path', 'method', cs.Id, 'custId', ac.Id, 400, 'strAction', 'strType');
        APB09_GenerateBIDAllocationReport.createBondSystemAction('reqBody', 'resBody', 'path', 'method', 400, 'strType', 'strAction');
         Test.StopTest();
    }
}