/**
 * @author Imane Tsioucha
 * @date Création 07/09/2023
 * @date Modification
 * @description : Test class of LTNG027_MinimumBalanceFeeController.
 * 
 */

 @isTest
public with sharing class LTNG027_MinimumBalanceFeeControllerTest {
    @TestSetup
    static void makeData(){
        Id MinimumBalanceRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Minimum_Balance_Management').getRecordTypeId();
        Account acc1 = new Account(
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com'
        );
        insert acc1; 
        Case objCase = new Case(
            RecordTypeId = MinimumBalanceRecordId,
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
    public static void getMinimumBalanceManagementCaseRecordTypeTest(){
        Test.startTest();
        Id acRecordTypeId = LTNG027_MinimumBalanceFeeController.getMinimumBalanceManagementCaseRecordType();
        System.assertEquals(acRecordTypeId != null,true);
        Test.stopTest();
    }

    @isTest
    public static void getAccountForFeeViaApiTest(){   
        Id accId = [SELECT Id FROM Account LIMIT 1 ].Id;
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
        try{
            LTNG027_MinimumBalanceFeeController.getAccountForFeeViaApi(accId,null);
        }catch(Exception e){
            System.debug('getAccountForFeeViaApiTest');
        }
            
        Test.stopTest();
    }

    @isTest
    public static void UpdateFeeWaiverFlagReasonViaApiTest(){   
        List<Case> caseList = [SELECT Id,Sub_Status__c,Status, cc_Checker_Result_Date_Time__c FROM Case ];
        Set<Id> caseIds = new Set<Id>();
        for (Case caseRecord : caseList) {
            caseIds.add(caseRecord.Id);
        }
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
            try{
                LTNG027_MinimumBalanceFeeController.UpdateFeeWaiverFlagReasonViaApi(caseIds);
            }catch(Exception e){
                System.debug('UpdateFeeWaiverFlagReasonViaApiTest');
            }
        Test.stopTest();
    }

    @isTest
    public static void sendEmailAlertTest(){
       Case cases= [SELECT Id,Case_Model__c,RecordType_DeveloperName__c FROM Case];
       String emailAlertName = 'MIN_FEE_WAIVER_COMPLETED_ALBURAQ';
       Test.startTest();

       LTNG027_MinimumBalanceFeeController.sendEmailAlert(cases, emailAlertName);

        Test.stopTest();
    }
}