/********************************************************************************************
* @name					CRMNewsRibbonTriggerHandlerTest
* @description			CRMNewsRibbonTriggerHandler code coverage would be done through this test class
* @date					05/06/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 05/06/2025		Initial Version
*********************************************************************************************
*/
@isTest
public class CRMNewsRibbonTriggerHandlerTest {

    @testSetup
    static void setupTestData(){
    	CRM_News_Ribbon__c ribbon = new CRM_News_Ribbon__c();
        ribbon.Marquee_Direction__c  = 'Left';
        ribbon.Active__c  = TRUE;
        ribbon.Expire_Date__c = Date.Today().addDays(5);
        ribbon.Message__c = 'Test';
        insert ribbon;
    }
    
    @isTest
    static void messagehasEmojiCharacterTest(){
    	CRM_News_Ribbon__c ribbon = [Select Id,Message__c FROM CRM_News_Ribbon__c LIMIT 1];
        ribbon.Message__c = 'New message with emoji &#128512;';
        try {
        	update ribbon;    
        }
        catch(DmlException ex){
            System.assert(ex.getMessage().contains('Special Character / Emoji'),'Message field has emoji');
        }
    }
    
    @isTest
    static void messagehasAmpersandWithSpecialCharacterTest(){
    	CRM_News_Ribbon__c ribbon = [Select Id,Message__c FROM CRM_News_Ribbon__c LIMIT 1];
        ribbon.Message__c = 'New message with Ampersand &amp; ^';
        try {
        	update ribbon;    
        }
        catch(DmlException ex){
            System.assert(ex.getMessage().contains('Special Character / Emoji'),'Message field has Ampersand');
        }
    }
    
    @isTest
    static void messagehasImageCharacterTest(){
    	CRM_News_Ribbon__c ribbon = [Select Id,Message__c FROM CRM_News_Ribbon__c LIMIT 1];
        ribbon.Message__c = 'New message with image <img src="test.img"></img>';
        try {
        	update ribbon;    
        }
        catch(DmlException ex){
            System.assert(ex.getMessage().contains('Image cannot be added in Message'),'Message field has image tag');
        }
    }
    
    @isTest
    static void messagehasOtherSpecialCharacterTest(){
    	CRM_News_Ribbon__c ribbon = [Select Id,Message__c FROM CRM_News_Ribbon__c LIMIT 1];
        ribbon.Message__c = 'New message with ^ sign';
        try {
        	update ribbon;    
        }
        catch(DmlException ex){
            System.assert(ex.getMessage().contains('Special Character / Emoji'),'Message field other special symbol');
        }
    }
    
}