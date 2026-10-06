@isTest(seeAllData = true)
public class CSVFileReadLWCCntrlTest {
    
    @isTest
    static void testReadExcelFile(){
        User thisUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        system.runAs(thisUser){
            
            Set<Id> contentDocumentIds = new Set<Id>();
            Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
            Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Issue').getRecordTypeId();
            Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);
            
            Content__c objCon = new Content__c();
            objCon.Scan_Type__c = 'POA';
            objCon.Upload_Type__c = 'Manual';
            objCon.Document_Type__c = 'CPR Extract';
            objCon.has_Attachment__c = true;
            objCon.Document_Model__c='ila'; // #CH01#
            objCon.Case__c = caseObj.id;
            insert objCon;
            
            ContentVersion content=new ContentVersion();
            content.Title='Tax Invoice';
            content.PathOnClient='/' + content.Title + '.jpg';
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
            content.VersionData=bodyBlob;
            content.origin = 'H';
            insert content;
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=caseObj.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers';
            
            insert contentlink;
            
            contentDocumentIds.add(contentlink.ContentDocumentId);
            
            Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentDocumentIds]);
            
            ContentDocument contentDoc = contentDocMap.get(contentlink.ContentDocumentId);
            
            Test.startTest();
            CSVFileReadLWCCntrl.readExcelFile(contentlink.ContentDocumentId);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testSaveBulkOperation() {
        User thisUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        system.runAs(thisUser) {
            List<Map<String, Object>> finalList = new List<Map<String, Object>>();
            Map<String, Object> record = new Map<String, Object>();
            record.put('CIF', '123456');
            record.put('Subject', 'John Doe Testing');
            record.put('Model', 'ila');
            record.put('Type', 'Block Account');
            record.put('SubType', 'Block for credit');
            record.put('CaseNature', 'Block');
            record.put('Reason', 'Testing');
            record.put('Origin', 'CRM');
            record.put('IBAN', 'IBAN123;IBAN456');
            record.put('AllAccounts', true);
            record.put('BlockAppAccess', true);
            record.put('Blacklist', true);
            record.put('isFraud', true);
            
            finalList.add(record);
            
            Set<Id> contentDocumentIds = new Set<Id>();
            
            Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779'), 'TestFactoryDefaults.AccountDefaults',true);
            Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Issue').getRecordTypeId();
            Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila'), 'TestFactoryDefaults.CaseDefaults',true);
            
            Content__c objCon = new Content__c();
            objCon.Scan_Type__c = 'POA';
            objCon.Upload_Type__c = 'Manual';
            objCon.Document_Type__c = 'CPR Extract';
            objCon.has_Attachment__c = true;
            objCon.Document_Model__c='ila'; // #CH01#
            objCon.Case__c = caseObj.id;
            insert objCon;
            
            ContentVersion content=new ContentVersion();
            content.Title='Tax Invoice';
            content.PathOnClient='/' + content.Title + '.jpg';
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
            content.VersionData=bodyBlob;
            content.origin = 'H';
            insert content;
            
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=caseObj.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers';
            
            insert contentlink;
            
            contentDocumentIds.add(contentlink.ContentDocumentId);
            
            Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentDocumentIds]);
            
            ContentDocument contentDoc = contentDocMap.get(contentlink.ContentDocumentId);
            
            Test.startTest();
            CSVFileReadLWCCntrl.saveBulkOperation(finalList,'Block Account',contentlink.ContentDocumentId);   
            Test.stopTest();
        }
    }
}