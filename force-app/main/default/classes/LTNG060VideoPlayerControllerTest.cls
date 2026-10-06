/**
 * @author Jayanth Manickam
 * @date 22/05/2025
 */
@isTest
public class LTNG060VideoPlayerControllerTest {
     @isTest
    public static void getVideoUrlTest(){ 
       Content__c cntFront = new Content__c();
        cntFront.Document_Type__c = 'Bahraini ID';
        cntFront.Region_Flag__c='Bahrain';
        cntFront.Document_Expiry_Date__c = System.today() + 60;
        cntFront.Scan_Type__c = 'POI';
        cntFront.Image_Type__c = 'Front';
        cntFront.Verification_Status__c = 'APPROVED_VERIFIED';
        cntFront.Similarity__c = 'MATCH';
        insert cntFront;
      ContentVersion contentVersion_1 = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content')
         
    );
    insert contentVersion_1;
         ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = cntFront.id;
        contentlink.contentdocumentid = contentVersion_2.contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink; 
    Test.startTest();
        LTNG060VideoPlayerController.getVideoUrl(cntFront.id);
    Test.stopTest();
    }

}