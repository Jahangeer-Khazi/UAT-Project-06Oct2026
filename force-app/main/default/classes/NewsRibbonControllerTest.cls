/********************************************************************************************
* @name					NewsRibbonControllerTest
* @description			NewsRibbonController code coverage would be done through this test class
* @date					05/06/2025
* @cretaedby			Maksud
*********************************************************************************************
* version				Author				Date			Comments
* 1.0					Maksud	 		 05/06/2025		Initial Version
*********************************************************************************************
*/

@isTest
public class NewsRibbonControllerTest {

    @testSetup
    static void setupTestData(){
    	CRM_News_Ribbon__c ribbon = new CRM_News_Ribbon__c();
        ribbon.Marquee_Direction__c  = 'Left';
        ribbon.Active__c  = TRUE;
        ribbon.Expire_Date__c = Date.Today().addDays(-1);
        ribbon.Message__c = 'Test';
        insert ribbon;
    }
    
    @isTest
    static void getActiveRibbonTest(){
		ApiConnection.Response response = NewsRibbonController.getActiveNewsRibbon(null);
        System.assertEquals(FALSE,response.isSuccess,'Headline Ribbon record date has expired.');
        
        CRM_News_Ribbon__c ribbon = [Select Id,Message__c,Expire_Date__c FROM CRM_News_Ribbon__c LIMIT 1];
        ribbon.Expire_Date__c = Date.Today();
        update ribbon;
        
        response = NewsRibbonController.getActiveNewsRibbon(null);
        System.assertEquals(TRUE,response.isSuccess,'Headline Ribbon record returned.');
        
    }
    
    
}