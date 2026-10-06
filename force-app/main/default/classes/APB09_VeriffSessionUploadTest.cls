@isTest
public class APB09_VeriffSessionUploadTest {

    @testSetup static void setupMethode() {
        Account acc1 = new Account(
                            FirstName = 'TestIla',
                            LastName = 'TestIla',
                            CIF__pc = '123456',
                            PersonEmail = 'testclass@ilatest123.com',
                            Region_Flag__pc = 'Bahrain',
                            ReconciliationStatus__pc = 'Initial'
                        );
        insert acc1;

        Content__c objCon = new Content__c();
        objCon.Person__c = acc1.Id;
        objCon.ID_Number__c = '123456789000';
        objCon.Region_Flag__c = 'Bahrain';
        objCon.Upload_Type__c = 'Manual';
        objCon.Scan_Type__c = 'POI';
        objCon.Document_Model__c='ila';
        objCon.Image_Type__c='Front';
        objCon.Document_Type__c='Bahraini ID';
        objCon.Validity__c=true;
        insert objCon; 

        ContentVersion content=new ContentVersion();
        content.Title='Header_Picture1';
        content.PathOnClient='/' + content.Title + '.jpg';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData=bodyBlob;
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=objCon.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        insert contentlink;

    }

    @isTest public static void batchPassTest(){
        Test.startTest();
            APB09_VeriffSessionUpload crn= new APB09_VeriffSessionUpload();
            Id jobId = Database.executeBatch(crn,200);
        Test.stopTest();
    }
}