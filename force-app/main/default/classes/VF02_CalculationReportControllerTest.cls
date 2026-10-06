/**
 *  @author: Imane Tsioucha
 *  @date: 2023-03-16  
 *  @description: Test Class for  VF02_CalculationSummaryReportController
 *         
 */
@isTest
public with sharing class VF02_CalculationReportControllerTest {
    @TestSetup
    static void makeData(){
        Id creditCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        Account acc1 = new Account(
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com',
            PersonBirthdate= Date.newInstance(2022, 06, 09)
        );
        insert acc1; 
        Case objCase = new Case(
            RecordTypeId = creditCardRecordId,
            Subject = 'test case',
            Description = 'test',
            Case_Model__c='ila',
            Origin = 'CRM',
            cc_Approved_Salary__c=200,
            cc_Approved_Credit_Limit__c=200,   
            Total_Internal_Loans__c=2,
            Total_Consumer_Loans__c=2,
            Total_Mortgage_Loans__c=2,
            Total_Credit_Cards__c=1,
            Total_Government_Loans__c=1,
            Existing_ila_Credit_Card_Deduction__c=1,
            Other_Deductions__c=0,
            cc_Total_Obligations__c=0,     
            ContactId = acc1.PersonContactId,
            AccountId = acc1.id
        );
        insert objCase;
        Content__c testDocument = new Content__c(
            Document_Type__c = 'Passport',
            Case__c = objCase.Id,
            Document_Model__c='ila'

        );
        insert testDocument;
        //Create a new file
          ContentVersion newFile = new ContentVersion();
          newFile.PathOnClient = 'TestFile';
          newFile.Title = 'TestFile';
          newFile.VersionData = Blob.valueOf('sample content');
          insert newFile;
          
          
          //Query the contentDocumentId
          ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
          
          //Link the file with the product
          ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=objCase.Id, ContentDocumentId=insertedFile.ContentDocumentId);
          insert linkedFile;
    }
    @isTest
    public static void VF02_CalculationSummaryReportControllerTest() {

        Test.startTest();
        Case cs =[Select Id from Case Limit 1];
        ApexPages.currentPage().getParameters().put('id',String.valueOf(cs.Id));
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        VF02_CalculationSummaryReportController calcul = new VF02_CalculationSummaryReportController(sc1);
        

        Test.stopTest();
       
    }
        @IsTest
     public static void testGetCaseDocuments() {
        Case cs =[Select Id from Case Limit 1];

        ApexPages.currentPage().getParameters().put('id',String.valueOf(cs.Id));
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        List<Content__c> result = VF02_CalculationSummaryReportController.getCaseDocuments();
        
       
        System.assertEquals(1, result.size());
     
    }

    @IsTest
    public static void getCaseFilesTest() {
       Case cs =[Select Id from Case Limit 1];

       ApexPages.currentPage().getParameters().put('id',String.valueOf(cs.Id));
       ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
       List<ContentDocumentLink> result = VF02_CalculationSummaryReportController.getCaseFiles();
       
      
       System.assertEquals(1, result.size());
    
   }
}