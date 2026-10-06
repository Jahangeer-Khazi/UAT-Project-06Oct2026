/*
Author : 
Date : 
Description : ContentTriggerHandlerTest
    #CH01# Added #22-06-2022# Document Model changes - HC
*/

@isTest(seeAllData = true)
private class ContentTriggerHandlerTest
{
    static testMethod void ContentTriggerHandler(){
        User thisUser = [Select id from User where id =: UserInfo.getUserId() limit 1];
        system.runAs(thisUser){

            List<Lead> leadList = new List<Lead>();
            Lead ld1 = new Lead();
            ld1.LastName = 'Lead Lastname';
            ld1.Email = 'lead@test.t1';
            ld1.MobilePhone = '8767887456';
            ld1.Proof_of_Address_ID_Number__c = '353110012';
            ld1.Birthdate__c = Date.parse('12/12/2000');
            ld1.ID_Number__c = '353110012';
            ld1.ID_Expiry_Date__c = Date.parse('12/12/2025');
            ld1.Residency__c = 'BH';
            ld1.Region_Flag__c = 'Bahrain';
            ld1.Address_ID_Expiry_Date__c = Date.parse('12/12/2025');

            leadList.add(ld1);

            insert leadList;

            Content__c objCon = new Content__c();
            objCon.Lead__c = ld1.id;
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
    }
    
    static testMethod void ContentTriggerHandler1(){
        User thisUser = [Select id from User where id =: UserInfo.getUserId() limit 1];
        system.runAs(thisUser){

            Set<Id> contentDocumentIds = new Set<Id>();
            Account acc = (Account)TestDataFactory.createSObject(new Account());
 
            Contact con = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                Email = 'test@gmail.com',
                AccountId = acc.Id
            );
            insert con;

            Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Loan_Application').getRecordTypeId();
            Case baseCase = new Case(
            RecordTypeId = acRecordTypeId,
            Subject = 'Loan Case',
            Type = 'New Loan / Finance Application',
            Sub_Type__c = 'New Loan / Finance Application Request',
            AccountId = acc.Id,
            AIR_HaveCreditCard__c = true,
            cc_Requested_Card_Type__c = 'PLATINUM_CASHBACK_AND_REWARD_01',
            cc_Requested_Credit_Limit__c = 5000,
            cc_Name_on_the_Card__c = 'Test User');
            insert baseCase;
            
            


            Content__c objCon = new Content__c();
            objCon.Scan_Type__c = 'POA';
            objCon.Upload_Type__c = 'Manual';
            objCon.Document_Type__c = 'CPR Extract';
            objCon.has_Attachment__c = true;
            objCon.Document_Model__c='ila'; // #CH01#
            objCon.Case__c = baseCase.id;
            insert objCon;

            ContentVersion content=new ContentVersion();
            content.Title='Tax Invoice';
            content.PathOnClient='/' + content.Title + '.jpg';
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body');
            content.VersionData=bodyBlob;
            //content.FirstPublishLocationId=baseCase.id;
            content.origin = 'H';
            insert content;

            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=baseCase.id;
            contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers';

            insert contentlink;
            
            contentDocumentIds.add(contentlink.ContentDocumentId);
            
            Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>([SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id IN :contentDocumentIds]);
            
            ContentDocument contentDoc = contentDocMap.get(contentlink.ContentDocumentId);

        }
    }
}