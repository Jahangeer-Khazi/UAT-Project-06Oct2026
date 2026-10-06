@isTest
public class CloneRecordControllerTest {
    
    @isTest
    static void customRelatedList() {
        Id recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Credit Card').getRecordTypeId();
        Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.CIF__pc = '5464546';
        insert acc;
        
        Case cs2 = new Case();
        cs2.RecordTypeId = recordTypeId;
        cs2.Subject = 'NewCreditCardApplicationTest';
        cs2.Description = 'Credit card Application Test for Duplicate Cards';
        cs2.Type = 'Credit Card Application';
        cs2.Sub_Type__c = 'New Credit Card';
        cs2.Status = 'Closed';
        cs2.Sub_Status__c = 'Approved';
        cs2.Priority = 'High';
        cs2.Origin = 'Phone';
        cs2.AccountId = acc.Id;
        cs2.Case_Model__c = 'ila';
        insert cs2;
        
        Content__c objCon = new Content__c();
        objCon.Case__c = cs2.id;
        objCon.Scan_Type__c = 'POA';
        objCon.Upload_Type__c = 'Manual';
        objCon.Document_Type__c = 'CPR Extract';
        objCon.has_Attachment__c = true;
        objCon.Document_Model__c='ila'; // #CH01#
        insert objCon;
        
        ContentVersion content=new ContentVersion();
        content.Title='Header_Picture1';
        content.PathOnClient='/' + content.Title + '.jpg';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
        content.VersionData=bodyBlob;
        content.origin = 'H';
        insert content;
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=objCon.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers';
        
        insert contentlink;
        
        CloneRecordController.CloneWrapper cw = CloneRecordController.cloneRecordWithFiles(objCon.Id);
        Boolean flag = CloneRecordController.insertClonedRecord(JSON.serialize(cw), cs2.Id);
        System.Assert.isTrue(flag);
    }

}