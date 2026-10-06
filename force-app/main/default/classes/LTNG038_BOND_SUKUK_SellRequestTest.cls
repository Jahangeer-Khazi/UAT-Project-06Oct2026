/**
* @author Jayanth Manickam
* @date Création 25/12/2023
* @date Modification
* @description :ALL the functions used in LTNG038_BOND_SUKUK_SellRequestTest
* @history Modifications :   
*  
*/
@isTest
public class LTNG038_BOND_SUKUK_SellRequestTest {
  @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);      
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    
    @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
        LTNG038_BOND_SUKUK_SellRequestController.getAccRequestCaseRecordType();
        Test.stopTest();
    }
    
    @isTest
    public static void SellBondRequestListTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Sell_Request_Queue;
        cs.bs_Investment_ID__c='d';
        update cs;
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        LTNG038_BOND_SUKUK_SellRequestController.SellBondRequestList(cseId);
        Test.stopTest();
    }
       @isTest
    public static void getInstrumentListViaApiTest(){
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        String accountId = String.valueOf([SELECT Id FROM account LIMIT 1].Id);
        LTNG038_BOND_SUKUK_SellRequestController.getAccountBondListViaApi(accountId,'ila');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    @isTest
    public static void SellBondRequestSoldTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.cc_Checker_result__c='Accept';
        cs.OwnerId=System.Label.Investment_Sell_Request_Checker;
        cs.Type='New Bond/Sukuk Sell Request';
        update cs;
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        LTNG038_BOND_SUKUK_SellRequestController.SellBondRequestList(cseId);
        Test.stopTest();
    }
}