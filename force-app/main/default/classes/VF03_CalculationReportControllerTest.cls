/**
 *  @author: Imane Tsioucha
 *  @date: 2023-03-16  
 *  @description: Test Class for  VF03_CalculationSummaryReportController
 *         
 */
@isTest
public with sharing class VF03_CalculationReportControllerTest {
    @TestSetup
    static void makeData(){
       /* Id creditCardRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Cash_Collateral_Staff').getRecordTypeId();
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
            Type='Credit Card Cash Collateral Application',
            Sub_Type__c='New Cash Collateral',
            cc_Approved_Credit_Limit__c=20,
            ccol_Approved_Hold_Amount__c=200,
            ContactId = acc1.PersonContactId,
            AccountId = acc1.id
        );
        insert objCase;*/
        
        CashCollateralHandlerTest.unitTest1();
        
        /*  Content__c testDocument = new Content__c(
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
        insert linkedFile;*/
    }
    @isTest
    public static void VF03_CalculationReportControllerTest() {

        Test.startTest();
        Case cs =[Select Id from Case Limit 1];
        ApexPages.currentPage().getParameters().put('id',String.valueOf(cs.Id));
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        VF03_CalculationSummaryReportController calcul = new VF03_CalculationSummaryReportController(sc1);
        

        Test.stopTest();
       
    }
     @IsTest
     public static void testGetCaseDocuments() {
        Case cs =[Select Id from Case Limit 1];

        ApexPages.currentPage().getParameters().put('id',String.valueOf(cs.Id));
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
        List<Content__c> result = VF03_CalculationSummaryReportController.getCaseDocuments();
        
       
        System.assertEquals(1, result.size());
     
    }

    @IsTest
    public static void getCaseFilesTest() {
       Case cs =[Select Id from Case Limit 1];

       ApexPages.currentPage().getParameters().put('id',String.valueOf(cs.Id));
       ApexPages.StandardController sc1 = new ApexPages.StandardController(cs);
       List<ContentDocumentLink> result = VF03_CalculationSummaryReportController.getCaseFiles();
       
      
       System.assertEquals(1, result.size());
    
   }
}