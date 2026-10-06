/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 23-06-2023
 * @last modified by  : Imane TSIOUCHA
 * Changes History    : CH01: 23/06/2023 Added by Imane Tsioucha 
**/
@isTest
private class customerProductStatusCtrlTest
{
    // Start CH01: Add makeData() Setup
    @TestSetup
    static void makeData(){
        Id accountrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        Account acc1 = new Account(
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com',
            recordtypeId=accountrecordTypeId
        );
        insert acc1; 
        Content__c testDocument1 = new Content__c(
            Person__c = acc1.Id,
            Document_Type__c = 'Bahraini ID',
            Image_Type__c = 'Back',
            Validity__c = true
        );
        
        insert testDocument1;

        ContentVersion content=new ContentVersion(); 
        content.Title='test'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=testDocument1.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        
    }

    // END CH01: Add makeData() Setup

    
    private static testMethod void customerProductStatusCtrl01() {
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'PLA 1';
        acc.LastName = 'Kanz 1';
        acc.PersonEmail = 'test001@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        acc.PLA_Eligibility__pc = 'Yes';
        acc.Has_Kanz_Account__pc = TRUE;
        acc.Has_Kanz_Balance__pc = TRUE;
        acc.Region_Flag__pc = 'Bahrain';
        acc.VVIP__pc = TRUE;
        insert acc;
        
        customerProductStatusCtrl.fetchCustomerDetail(String.valueOf(acc.id));
        customerProductStatusCtrl.fetchCustomerDetailsByCIF(String.valueOf(acc.CIF__pc));
        
    } 

     //// Commenting the method pre RM-2964 release
     // Start CH01: getAccountTest Test Methode for getAccount On customerProductStatusCtrl
  /*  @isTest
    public static void getAccountTest(){
        Test.startTest();
        Id AccountId=[SELECT Id FROM Account LIMIT 1].Id;
        Account result=customerProductStatusCtrl.getAccount(AccountId);
        System.assertEquals(result != null,true);
        Test.stopTest();
    }

    Start CH01: getAccountTest Test Methode for getAccountDocumentsTest On customerProductStatusCtrl
    @IsTest
    public static void getAccountDocumentsTest() {
        Test.startTest();
        Id AccountId=[SELECT Id FROM Account LIMIT 1].Id;
        List<ContentVersion> result = customerProductStatusCtrl.getAccountDocuments(AccountId);
        System.assertEquals(1, result.size());
        Test.stopTest();

    
   }*/

  //// Commenting the method pre RM-2964 release


}