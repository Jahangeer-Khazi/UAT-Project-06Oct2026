/*
* @author Hamza CHAOUI
 * @date Création 30-05-2022

 * @description : test batch class that modify the new field document model to ila 
Version History :
    #CH01# Added #22-06-2022# Document Model changes - HC
*/
@isTest
public without sharing class APB04_UpdateToIlaModelForCDocumentTest {
    @testSetup static void setupMethode() {

        Setting__c st = new Setting__c();
        st.Bypass_Validation_Rules__c = true;
        st.SetupOwnerId = UserInfo.getUserId();
        insert st;


        List<Content__c> lstContent = new List<Content__c>();
        Content__c objCon = new Content__c();
        objCon.ID_Number__c = '123456789000';
        objCon.Region_Flag__c = 'Bahrain';
        objCon.Upload_Type__c = 'Manual';
        objCon.Scan_Type__c = 'POI';
        //objCon.byPassVR__c = True;
        objCon.Document_Model__c='ila';
        lstContent.add(objCon);
         
        insert lstContent;
    }

    @isTest public static void batchTest(){
      
         Test.startTest();
            APB04_UpdateToIlaModelForCustDocument crn= new APB04_UpdateToIlaModelForCustDocument();
            Id jobId = Database.executeBatch(crn,200);
         Test.stopTest();
        
    }
}