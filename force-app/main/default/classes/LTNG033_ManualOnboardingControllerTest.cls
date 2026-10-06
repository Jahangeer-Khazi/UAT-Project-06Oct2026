/**
 * @author Imane Tsioucha
 * @date Création 23/11/2023
 * @date Modification
 * @description : Test class of LTNG033_ManualOnboardingController.
 */

 @isTest
public with sharing class LTNG033_ManualOnboardingControllerTest {
    @TestSetup
    static void makeData(){
        Id DormancyRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Manual_Onboarding_FCR').getRecordTypeId();
        Account acc1 = new Account(
            FirstName = 'TestCase',
            LastName = 'TestCase',
            PersonEmail = 'test@gmail.com'
        );
        insert acc1; 
        Case objCase = new Case(
            RecordTypeId = DormancyRecordId,
            Subject = 'test case',
            Description = 'test',
            Case_Model__c='ila',
            Origin = 'CRM',
            ContactId = acc1.PersonContactId,
            AccountId = acc1.id
        );
        insert objCase;
    }
    @isTest
    public static void getRecordTypeTest(){
        Test.startTest();
        Id acRecordTypeId = LTNG033_ManualOnboardingController.getAccRequestCaseRecordType();
        System.assertEquals(acRecordTypeId != null,true);
        Test.stopTest();
    }

    @isTest
    static void ProspectArchiveTest () {      
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            try{
                LTNG033_ManualOnboardingController.CloseManualOnboardingCaseViaApi(caseId);
            }catch(Exception e){
                System.debug('ProspectArchiveTest');
            }
        Test.stopTest();

    }

    @isTest
    static void ProspectArchive1_Test () {      
        Id caseId = [SELECT Id FROM Case LIMIT 1 ].Id;  
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 400;
            try{
                LTNG033_ManualOnboardingController.CloseManualOnboardingCaseViaApi(caseId);
            }catch(Exception e){
                System.debug('ProspectArchiveTest');
            }
        Test.stopTest();

    }



}