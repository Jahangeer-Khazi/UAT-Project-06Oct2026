/**
* @author Jayanth Manickam
* @date Création 25/12/2023
* @date Modification
* @description :ALL the functions used in LTNG037_BondSukukBuyRequestTest
* @history Modifications :   
*  
*/
@isTest
public class LTNG037_BondSukukControllerTest {
 private static ApiConnection con = new ApiConnection();
      @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Sukuk_Bond_Request').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='New Bond/Sukuk Buy Request',Sub_Type__c='New Bond/Sukuk Buy Request'), 'TestFactoryDefaults.CaseDefaults',true);//CH01
    }
    
    @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
        LTNG037_BondSukukController.getAccRequestCaseRecordType();
        Test.stopTest();
    }
    
    @isTest
    public static void validateAccountBalanceTest(){
        Test.startTest();
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        LTNG037_BondSukukController.validateAccountBalance(cseId);
        Test.stopTest();
    }
    @isTest
    public static void getInvestmentDetailsSourceAppTest(){
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        Test.startTest();
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('GET','/api/v1/bond/investments/d','Bahrain');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Case cs = [SELECT Id,Origin,OwnerId FROM case LIMIT 1];
        cs.Origin='APP';
        cs.OwnerId=System.Label.Investment_Temp_Queue;
        cs.bs_Investment_ID__c='d';
        update cs;
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        LTNG037_BondSukukController.getInvestmentDetailsSourceApp(cseId);
        Test.stopTest();
    }
    @isTest
    public static void getInstrumentListViaApiTest(){
       Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        String accountId = String.valueOf([SELECT Id FROM account LIMIT 1].Id);
        LTNG037_BondSukukController.getInstrumentListViaApi(accountId,'ila');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
     @isTest
    public static void getAccountListViaApiTest(){
       Test.startTest();
         Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        String accountId = String.valueOf([SELECT Id FROM account LIMIT 1].Id);
        LTNG037_BondSukukController.getAccountListViaApi(accountId,'ila');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    
     @isTest
     public static void validateAccountBalancewithBIDTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        List<String>cseId = New List<String>{String.valueOf([SELECT Id,bs_Total_Bid_Amount__c FROM case LIMIT 1].Id)};
        Case cs = [SELECT Id,Origin,OwnerId FROM case Where Id=:cseId[0] LIMIT 1];
        cs.bs_Total_Bid_Amount__c=20;
        update cs;
        LTNG037_BondSukukController.validateAccountBalancewithBID(cseId);
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
     @isTest
     public static void SimulateBidCalculation(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        String accountId = String.valueOf([SELECT Id FROM account LIMIT 1].Id);
        LTNG037_BondSukukController.getBondListViaApi(1000.00,'ahs','7843jdjs',accountId,'ila');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    @isTest
     public static void releaseBidHoldAmount(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        List<String>cseId = New List<String>{String.valueOf([SELECT Id FROM case LIMIT 1].Id)};
        LTNG037_BondSukukController.ReleaseHoldAccountBalance(cseId,'Cancelled By Customer');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.stopTest();
    }
    @isTest
    Public static void getBondConfigurationTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        String accountId = String.valueOf([SELECT Id FROM account LIMIT 1].Id);
        LTNG037_BondSukukController.getBondConfiguration(accountId,'ila');
        MCK04_Bonds_SukukServiceApiCalls mck = new MCK04_Bonds_SukukServiceApiCalls();
        Test.StopTest();
    }
    
  /*   private class RestMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"meta":{"code":"bond-1000","message":"Resultsfetchedsuccessfully."},"data":{"instruments":[{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"12-01-2024","tenderDateCBB":"12-01-2024","issueDateCBB":"12-01-2024","maturityDateCBB":"12-01-2024","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"12-01-2024","minimumOrderAmount":5,"maximumOrderAmount":1000000000,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}]}}}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }*/

}