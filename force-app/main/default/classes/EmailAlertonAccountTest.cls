@isTest
public class EmailAlertonAccountTest {
    static Account accObj;
     @isTest
    static void testLoadCardList(){
        Test.startTest();
         accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        LIST<Id> customerId=new List<Id>();
        customerId.add(accObj.Id);
        EmailAlertonAccount.sendEmailToCustomer(customerId);
        system.assertEquals(customerId[0], accObj.Id);
        Test.stopTest();
    }

}