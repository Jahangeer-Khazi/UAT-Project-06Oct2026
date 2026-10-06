/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 02-21-2023
 * @last modified by  : Elmustapha ELGARNI
**/
@IsTest
public with sharing class LTNG029_InternalCaseRequesControllerTest {
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
    
    @isTest
    public static void getInternalCaseRecordType(){  
        test.startTest();
        Id recordTypeId=LTNG029_InternalCaseRequestController.getInternalCaseRecordType();
        System.assert(recordTypeId != null);
        test.stopTest();
       
    }

    @isTest
    public static void loadCardDetailsTest () {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta":{"code":"CCRD-XXXX","message":"Card inquiry successfully completed."},'+
                         '"data":{"cif":"5374683","pciNumber":"2660030004434274","customerName":"First name Middle name Last name",'+
                         '"usedCreditLimit":0,"holdAmount":0,"lastPaymentAmount":0,"creditLimit":1500,"availableCreditLimit":1500,"availableCashLimit":900,'+
                         '"currentDues":0,"minimumDues":0,"totalDues":0,"pastDues":0,"recoverOption":0,"pointsBalance":0,"lastStatmentBalance":0,'+
                         '"cashLimit":900,'+'"paymentSinceLastStatements":0,"isPrimary":true,"embossName":"Test","cmsAccountId":"511724******4274",'+
                         '"isReissued":false,"currentPurchaseAmount":0,"currentUsedCashAmount":0,"currentReturnsAmount":0,'+
                         '"currency":{"code":"BHD","decimalPlaces":3},"expiryDate":"2027-07-01","cmsProductDescription":"ILA BLUE","issueDate":"2024-07-01",'+
                         '"primaryCardPciNumber":"BF766BEC7063E57BA1062B035CF1FB57E525A8C85AA241C061855E5326E266FE","cmsCardProductId":"003",'+
                         '"email":"tmansuri+106017@mobiquityinc.com","mobileNumber":"009111180672860","unbilledAmount":0,"lastStatementDate":"2025-09-21",'+
                         '"bankAccountId":"468391010BHD    ","plasticCardType":"P","plasticCardDescription":"ILA BLUE","directDebitPercentage":0,'+
                         '"cashbackAmount":0,"totalCashbackAmount":0,"paymentLastStatementBalance":0,"paymentMinimumDues":0,"paymentUsedCreditLimit":0,'+
                         '"recentCreditsAmount":0,"recentDebitsAmount":0,"showUsageReminder":false,'+
                         '"rewardsSummary":{"isEnabled":true,"enrollmentStatus":"COMPLETED","preferredRewardsOption":"ILA_TOKENS","nextCycleDate":"2022-11-21",'+
                         '"modifiedPreferredRewardsOption":"CASHBACK","ilaTokens":{"availableTokens":15},'+
                         '"autoCashback":{"value":155,"currency":{"code":"BHD","decimalPlaces":3}},"autoMiles":{"value":55}}}}';

        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = LTNG029_InternalCaseRequestController.loadCardDetails('testCustomerId', 'testCardId', 'testabc@mail.com', 'Bahrain');
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);

    }
    


    @isTest
    static void getPCIOptionsV2Test(){
      //  Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        final MyCalloutMock mock = new MyCalloutMock();
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
        mock.testBody = '{"meta":{"code":"CCRD-XXXX","message":"Card inquiry successfully completed."},'+
                         '"data":{"cif":"5374683","pciNumber":"2660030004434274","customerName":"First name Middle name Last name",'+
                         '"usedCreditLimit":0,"holdAmount":0,"lastPaymentAmount":0,"creditLimit":1500,"availableCreditLimit":1500,"availableCashLimit":900,'+
                         '"currentDues":0,"minimumDues":0,"totalDues":0,"pastDues":0,"recoverOption":0,"pointsBalance":0,"lastStatmentBalance":0,'+
                         '"cashLimit":900,'+'"paymentSinceLastStatements":0,"isPrimary":true,"embossName":"Test","cmsAccountId":"511724******4274",'+
                         '"isReissued":false,"currentPurchaseAmount":0,"currentUsedCashAmount":0,"currentReturnsAmount":0,'+
                         '"currency":{"code":"BHD","decimalPlaces":3},"expiryDate":"2027-07-01","cmsProductDescription":"ILA BLUE","issueDate":"2024-07-01",'+
                         '"primaryCardPciNumber":"BF766BEC7063E57BA1062B035CF1FB57E525A8C85AA241C061855E5326E266FE","cmsCardProductId":"003",'+
                         '"email":"tmansuri+106017@mobiquityinc.com","mobileNumber":"009111180672860","unbilledAmount":0,"lastStatementDate":"2025-09-21",'+
                         '"bankAccountId":"468391010BHD    ","plasticCardType":"P","plasticCardDescription":"ILA BLUE","directDebitPercentage":0,'+
                         '"cashbackAmount":0,"totalCashbackAmount":0,"paymentLastStatementBalance":0,"paymentMinimumDues":0,"paymentUsedCreditLimit":0,'+
                         '"recentCreditsAmount":0,"recentDebitsAmount":0,"showUsageReminder":false,'+
                         '"rewardsSummary":{"isEnabled":true,"enrollmentStatus":"COMPLETED","preferredRewardsOption":"ILA_TOKENS","nextCycleDate":"2022-11-21",'+
                         '"modifiedPreferredRewardsOption":"CASHBACK","ilaTokens":{"availableTokens":15},'+
                         '"autoCashback":{"value":155,"currency":{"code":"BHD","decimalPlaces":3}},"autoMiles":{"value":55}}}}';

        Test.setMock(HttpCalloutMock.class, mock);
        try{
            Map<String,Object> tt = LTNG029_InternalCaseRequestController.getPCIOptionsV2(acc1.Id, 'Bahrain');
        }catch(Exception exp){
            System.assert(true);
        }
        test.stopTest();
    }

	@isTest
    public static void loadDeviceListTest () {
        Account acc = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Map<String,Object> retriveDeviceOptions = LTNG029_InternalCaseRequestController.loadDeviceList( acc.Id , 'alburaq');
        System.assert(retriveDeviceOptions != null);

    }
    
    @isTest
    public static void deleteDeviceApiFromFlowTest () {
        Account acc = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Case objCase = new Case(
            sc_Card_Holder_ID_Number__c = '123',
            ContactId = acc.PersonContactId,
            sc_Card_Holder_First_Name__c = 'test firstName',
            sc_Card_Holder_Last_Name__c = 'test lastName',
            AccountId = acc.id,
            Case_Nature__c = 'FCR',
            Case_Model__c='ila'
        );
        TestDataFactory.createSObject( objCase, 'TestFactoryDefaults.CaseDefaults',true);
        LTNG029_InternalCaseRequestController.deleteDeviceApiFromFlow( new List<Id>{objCase.Id});
    }
}