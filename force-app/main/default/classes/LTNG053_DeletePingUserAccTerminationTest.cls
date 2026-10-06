@isTest
public without sharing class LTNG053_DeletePingUserAccTerminationTest {

    @isTest
    public static void loadDeviceActivitiesTest(){   
        Test.startTest();
            Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779',Segment__pc='Regular',Region_Flag__c='Bahrain',Subscription_Model__pc='alburaq'), 'TestFactoryDefaults.AccountDefaults',true);
            Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Block_Unblock_Account').getRecordTypeId();
            Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='alburaq',Created_by_Contact_Center_Flag__c=true), 'TestFactoryDefaults.CaseDefaults',true);
            List<String> strLst = LTNG053_DeletePingUserAccTermination.deletePingUserApiFromFlow(new List<Id>{caseObj.Id});
            System.assert(strLst!=null);
        Test.stopTest();
    }


    @isTest
    public static void loadDeviceActivitiesCase2Test(){   
        Test.startTest();
            Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779',Segment__pc='Regular',Region_Flag__c='Bahrain',Subscription_Model__pc='alburaq'), 'TestFactoryDefaults.AccountDefaults',true);
            Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('New_Update_Customer_Profile').getRecordTypeId();
            Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='alburaq',Sub_Type__c = 'Relationship Termination - By Bank',Final_Black_Listed__c = true,Closure_Reason__c = 'Death Confirmed'), 'TestFactoryDefaults.CaseDefaults',true);
            List<String> strLst = LTNG053_DeletePingUserAccTermination.deletePingUserApiFromFlow(new List<Id>{caseObj.Id});
            System.assert(strLst!=null);
        Test.stopTest();
    }

}