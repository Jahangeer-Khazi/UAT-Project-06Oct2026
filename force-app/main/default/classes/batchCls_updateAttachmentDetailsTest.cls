@isTest(seeAllData=False)
public class batchCls_updateAttachmentDetailsTest {
    
    @TestSetup
    static void setupData(){
         Account acc = new Account();
        acc.recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId() ;
        acc.FirstName = 'Test2';
        acc.LastName = 'Class2';
        acc.PersonEmail = 'test2@ilatest.com';
        acc.Nationality__pc = 'BH';
        acc.Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED';
        acc.CIF__pc = '5464546';
        insert acc;
    
        //Create sample account record
        Content__c cn = New Content__c();
        cn.Region_Flag__c='Bahrain';
        cn.Scan_Type__c='POI';
        cn.Upload_Type__c='Digital';
        cn.has_Attachment__c=True;
        cn.Person__c = acc.id;
        insert cn;
        Content__c cn2 = New Content__c();
        cn2.Scan_Type__c='POI';
        cn2.Upload_Type__c='Manual';
        cn2.has_Attachment__c=True;
        cn2.Region_Flag__c='Bahrain';
        cn2.Person__c = acc.id;
        insert cn2;
        
        ContentVersion cVersion = new ContentVersion(
            Title          = 'Front',
            PathOnClient   = '/Front.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            origin = 'H',
            FirstPublishLocationId = cn2.Id);
        insert cVersion;
        cn2.Attachment_Name__c='';
        update cn2;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId =:cVersion.Id];
        //   List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cVersion.Id];  
        System.debug(testContent.ContentDocumentId);
    }
    public static testMethod void updateAttachmentDetails() 
    {
        Test.startTest(); 
        Content__c cn = [Select Id from Content__c Where Upload_Type__c='Manual' Limit 1];
        ContentVersion cVersion = new ContentVersion(
            Title          = 'Front',
            PathOnClient   = '/Front.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            origin = 'H',
            FirstPublishLocationId = cn.Id);
        insert cVersion;
        
        cn.Attachment_Name__c='';
        update cn;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where LatestPublishedVersionId =:cVersion.Id];
        user u = [Select Id from User where profile.Name='System Administrator'And IsActive=true Limit 1];
        system.runAs(u){
            batchCls_updateAttachmentDetails sh1 = new batchCls_updateAttachmentDetails();
            //system.schedule('Test Schedule Class','0 45 * * * ?',new batchCls_updateAttachmentDetails());
            database.executeBatch(sh1);  
        }
        Test.stopTest(); 
    }
}