/* @description       : 
* @author            : Imane TSIOUCHA
* @group             : 
* @last modified on  : 14/03/2023
* @last modified by  : 
**/
@isTest
public with sharing class LTNG029_CalculationSummaryReportTest {
  
    @TestSetup
    static void makeData(){
        Id creditCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        // Case cs1 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = creditCardRecordId,Type = 'Credit Card Application') ,'TestFactoryDefaults.CaseDefaults',true);
        // Id creditCashRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Cash_Collateral_Staff').getRecordTypeId();
        // Case cs2 = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = creditCardRecordId) ,'TestFactoryDefaults.CaseDefaults',true);   
        Account acc1 = new Account(
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com'
        );
        insert acc1; 
        Case objCase = new Case(
            RecordTypeId = creditCardRecordId,
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
        Id caseRecordId=[SELECT Id FROM CASE LIMIT 1].Id;
        String result=LTNG029_CalculationSummaryReport.getRecordType(caseRecordId);
        System.assertEquals(result,'VF02_CalculationSummaryReportPdf');
        Test.stopTest();
    }
  
}