@isTest
public class MobileNumberClaimHandlerTest {
@isTest
    static void unitTest1() {
        Account acc = new Account();
        acc.LastName = 'LastName new';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        insert acc;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(acc.id, yesterday); 
        System.debug('Account Id in test Class:'+acc.id);
        System.debug('CIF in test Class:'+acc.CIF__pc);
        System.debug('Acc Created Date:'+acc.CreatedDate);
        Mobile_Number_Claim__c m = new Mobile_Number_Claim__c();
        m.Owner_CIF__c = '1234567';
        insert m;
        MobileNumberClaimHandler.calculate();
    }
    
}