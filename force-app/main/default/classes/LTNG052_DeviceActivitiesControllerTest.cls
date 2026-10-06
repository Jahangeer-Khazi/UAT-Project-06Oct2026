@isTest
public without sharing class LTNG052_DeviceActivitiesControllerTest {

    @isTest
    public static void loadDeviceActivitiesTest(){   
        Test.startTest();
            Account acc =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779',Segment__pc='Regular',Region_Flag__c='Bahrain',Subscription_Model__pc='alburaq'), 'TestFactoryDefaults.AccountDefaults',true);
            LTNG052_DeviceActivitiesController.loadDeviceActivities(acc.Id);
        Test.stopTest();
    }

}