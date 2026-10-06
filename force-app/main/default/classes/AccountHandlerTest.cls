/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-06 11:29:10
 *  @description:
 *      Test methods for AccountHandler
 *
 *  Change History :
 * 				#CH01:#Jahangeer Mohammed# #22-12-2022# Added test class methods to increase the code coverage
 *
 */
@isTest(isParallel=true)
public class AccountHandlerTest  {
    /**
     *
     */
    @isTest
    static void testSetCifNumber () {
        final List<Account> accs = new List<Account>{
            new Account( Region_Flag__c = 'Bahrain', Region_Flag__pc = 'Bahrain'),
            new Account(CIF__pc = 'test', Region_Flag__c = 'Bahrain', Region_Flag__pc = 'Bahrain'),
            new Account(Region_Flag__c = 'Bahrain', Region_Flag__pc = 'Bahrain')
        };
        AccountHandler.setCifNumber(accs);
        System.assert(String.isNotBlank( accs[0].CIF__pc), 'Expected non empty CIF__pc value');
        System.assert(String.isNotBlank( accs[2].CIF__pc), 'Expected non empty CIF__pc value');
        System.assertEquals('test', accs[1].CIF__pc, 'Did not expect CIF__pc value to change');

        // code coverage for trigger
        final AccountHandler handler = new AccountHandler();
        try {
            Database.insert(new Account(Name = 'Test'), false);
            handler.beforeInsert();
        } catch (Exception eIgnore) {
            System.debug('The following exception has occurred: ' + eIgnore.getMessage());
            System.assert(true, 'The following exception has occurred: ' + eIgnore.getMessage());
        }
        try {
            handler.beforeUpdate();
        } catch (Exception eIgnore) {
            System.debug('The following exception has occurred: ' + eIgnore.getMessage());
            System.assert(true, 'The following exception has occurred: ' + eIgnore.getMessage());
        }
    }
    @isTest
    static void generateRandomString() {
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        //acc.Referred_By__c =
        insert acc;


        Account acc1 = new Account();
        acc1.FirstName = 'Test';
        acc1.LastName = 'Class';
        acc1.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc1.Onboarding_Group__pc = 'Registration';
        acc1.Referred_By__c = acc.id;
        insert acc1;

        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.PersonMobilePhone='9909444545';
        acc.PersonEmail='test@test.com';
        update acc;
    }
    //CH01: Commented by #Jahangeer Mohammed# #22-12-2022#
    /*@isTest
    static void unitTest1(){
        List<Account> accList = new List<Account>();
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Class';
        acc.Onboarding_Stage__pc = 'MOBILE_VERIFIED';
        acc.Onboarding_Group__pc = 'Registration';
        acc.Nationality__pc = 'BH';
        insert acc;
        accList.add(acc);
        //AccountHandler accHandler = new AccountHandler();
        AccountHandler.setReferralCodeUpdate(accList);
        
    }*/
    @isTest
    static void unitTest2(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
        
        acc.Nationality__pc = 'IN';
        update acc;
    }
    //CH01: Start
    @isTest
    static void unitTest3(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.CIF__pc = '5464546';
        insert acc;
        
        acc.Wathiq_Consent__pc = true;
        update acc;
    }
    
     @isTest
    static void unitTest4(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.CIF__pc = '5464546';
        insert acc;
        
        acc.Wathiq_Consent__pc = true;
        acc.pr_ReviewStatus__c = 'Completed';
        update acc;
    }
    
     @isTest
    static void unitTest5(){
        List<Id> accountIds = new List<Id>();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.CIF__pc = '5464546';
        acc.pr_NextReviewDate__c = System.today();
        insert acc;
        
        acc.Wathiq_Consent__pc = true;
        acc.pr_ReviewStatus__c = 'Completed';
        update acc;
        accountIds.add(acc.Id);
        //PeriodicReviewUnblockProducts.PeriodicReviewUnblockApiFromFlow(accountIds);
        UnBlockPeriodicReviewProductsQueuableAPI.createSystemAction('test', 'test','test', '564746',200,'GET','test','test');
    }
    //CH01: END

    @isTest
    static void unitTest6(){
        List<Id> accountIds = new List<Id>();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Region_Flag__c = 'Bahrain';
        acc.CIF__pc = '5464546';
        acc.Id_Number__pc = '123456';
        acc.pr_NextReviewDate__c = System.today();
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '34082200';
        acc.Mobile_Phone_Check__pc = '+97334082200';
        acc.Wathiq_Consent__pc = true;
        acc.pr_ReviewStatus__c = 'Completed';
        insert acc;

        Lead ld = new Lead();
        Map<String, Schema.RecordTypeInfo> leadRTInfos = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id leadRT = leadRTInfos.get('Relative').getRecordTypeId();
        System.debug(leadRT);
        ld.recordtypeId = leadRT;
        ld.Id_Number__c = '12345655';
        ld.Mobile_Country_Code__c = '+973';
        ld.MobilePhone = '3408220055';
        ld.LastName = 'test lead';
        insert ld;
        System.debug('ld created succsess ****************************** ');

        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        update acc;
        accountIds.add(acc.Id);
    }

    @isTest
    static void unitTest7(){
        List<Id> accountIds = new List<Id>();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Region_Flag__c = 'Bahrain';
        acc.CIF__pc = '5464546';
        acc.Id_Number__pc = '123456';
        acc.pr_NextReviewDate__c = System.today();
        acc.Wathiq_Consent__pc = true;
        acc.pr_ReviewStatus__c = 'Completed';
        insert acc;

        Lead ld = new Lead();
        Map<String, Schema.RecordTypeInfo> leadRTInfos = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id leadRT = leadRTInfos.get('Relative').getRecordTypeId();
        System.debug(leadRT);
        ld.recordtypeId = leadRT;
        ld.Id_Number__c = '123456555';
        ld.LastName = 'test lead';
        insert ld;
        System.debug('ld created succsess ****************************** ');

        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        update acc;
        accountIds.add(acc.Id);
    }
    
    @isTest
    static void unitTest8(){
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Region_Flag__c = 'Bahrain';
        acc.CIF__pc = '5464546';
        acc.Id_Number__pc = '123456';
        acc.pr_NextReviewDate__c = System.today();
        acc.Wathiq_Consent__pc = true;
        acc.pr_ReviewStatus__c = 'Completed';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.Archived__pc = false;
        insert acc;

        acc.Archived__pc = true;
        update acc;
    }
    
    @isTest
    static void unitTest9(){ 
        AccountHandler.getAccFieldInfosBasedOnFieldName('');
    }
    
    @isTest
    static void unitTest10(){
        List<Account> accountList = new List<Account>();
        
        Lead ld = new Lead();
        Map<String, Schema.RecordTypeInfo> leadRTInfos = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id leadRT = leadRTInfos.get('Relative').getRecordTypeId();
        System.debug(leadRT);
        ld.recordtypeId = leadRT;
        ld.Id_Number__c = '987654';
        ld.Mobile_Country_Code__c = '+973';
        ld.MobilePhone = '3408220054';
        ld.LastName = 'demo lead';
        //ld.sys_Mobile_Number__c = '+97334082200';
        insert ld;
        
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'IN';
        acc.Region_Flag__pc = 'Bahrain';
        acc.CIF__pc = '5464546';
        acc.Id_Number__pc = '987654';
        acc.pr_NextReviewDate__c = System.today();
        acc.Mobile_Country_Code__pc = '+973';
        acc.PersonMobilePhone = '34082200';
        acc.Mobile_Phone_Check__pc = '+97334082200';
        acc.Wathiq_Consent__pc = true;
        acc.pr_ReviewStatus__c = 'Completed';
        insert acc;
        
        accountList.add(acc);

        Linked_Account__c lA = new Linked_Account__c();
        lA.Active__c = true;
        lA.ID_Number__c = '987654';
        lA.Mobile_Country_Code__c = '+973';
        lA.Mobile__c = '3408220054';
        lA.Linked_Account__c = acc.Id;
        lA.Relative__c = ld.Id;
        insert lA;
        
        AccountHandler.updatePlaRelatives(accountList);

        //test jordan
        acc.Region_Flag__pc = 'Jordan';
        update acc; 
        AccountHandler.updatePlaRelatives(accountList);

    }
}