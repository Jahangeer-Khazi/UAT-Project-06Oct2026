/**
 * @author Imane Tsioucha
 * @date Création 22/06/2023
 * @date Modification
 * @description : Test class of LTNG026_DormancyStatusController.
 */

 @isTest
public with sharing class LTNG026_DormancyStatusControllerTest {
    @TestSetup
    static void makeData(){
        Id DormancyRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Dormancy_Status').getRecordTypeId();
        Account acc1 = new Account(
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
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
        Id acRecordTypeId = LTNG026_DormancyStatusController.getAccRequestCaseRecordType();
        System.assertEquals(acRecordTypeId != null,true);
        Test.stopTest();
    }
}