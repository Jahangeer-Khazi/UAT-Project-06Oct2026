/**
*  @author: Jayanth Kumar
*  @date: 03/12/2022
*  @description: Test class for RedemptionHistoryController
*/
@isTest
public class RedemptionHistoryControllerTest {
    
    
    @isTest static void testredemptionHistorySuccessCallout() {
        // Set mock callout class 
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.CIF__pc='test';
        //acc.Referred_By__c =
        insert acc;
        redemptionMockHttpResponseGenerator fakeResponse = new redemptionMockHttpResponseGenerator(200,
                                                                                                   'Redemption');
        Test.setMock(HttpCalloutMock.class,fakeResponse);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        String ParamJson='{"cardId":2545555,"fromDate":"2022-12-25","toDate":"2022-12-28","status":"Completed","fromAmount":"200","toAmount":"250"}';
        RedemptionHistoryController.loadRedemptionHistory('test',ParamJson,'Bahrain','ILA_TOKENS');
        Test.stopTest();
    }
    @isTest static void testredemptionHistoryfailureCallout() {
        // Set mock callout class 
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.CIF__pc='test';
        //acc.Referred_By__c =
        insert acc;
        redemptionMockHttpResponseGenerator fakeResponse = new redemptionMockHttpResponseGenerator(500,
                                                                                                   'Redemption');
        Test.setMock(HttpCalloutMock.class,fakeResponse);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        String ParamJson='{"cardId":2545555,"fromDate":"2022-12-25","toDate":"2022-12-28","status":"Completed","fromAmount":"200","toAmount":"250"}';
        RedemptionHistoryController.loadRedemptionHistory('test',ParamJson,'Bahrain','test');
        Test.stopTest();
    }
    @isTest static void testredemptionPaymentSuccessCallout() {
        // Set mock callout class 
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.CIF__pc='test';
        //acc.Referred_By__c =
        insert acc;
        redemptionMockHttpResponseGenerator fakeResponse = new redemptionMockHttpResponseGenerator(200,
                                                                                                   'Payment');
        Test.setMock(HttpCalloutMock.class,fakeResponse);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        String ParamJson='{"cardId":2545555,"fromDate":"2022-12-25","toDate":"2022-12-28","status":"Completed","fromAmount":"200","toAmount":"250"}';
        RedemptionHistoryController.loadRewardHistory('test','Bahrain','2545555');
        Test.stopTest();
    }
    @isTest static void testredemptionPaymentfailureCallout() {
        // Set mock callout class 
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.PersonEmail = 'aws@ilabank.com';
        acc.RecordtypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.CIF__pc='test';
        //acc.Referred_By__c =
        insert acc;
        redemptionMockHttpResponseGenerator fakeResponse = new redemptionMockHttpResponseGenerator(500,
                                                                                                   'Payment');
        Test.setMock(HttpCalloutMock.class,fakeResponse);
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        Test.startTest();
        String ParamJson='{"cardId":2545555,"fromdate":"2022-12-25","todate":"2022-12-28","status":"Completed","fromAmount":"200","toAmount":"250"}';
        RedemptionHistoryController.loadRewardHistory('test','Bahrain','2545555');
        Test.stopTest();
    }
    
    
}