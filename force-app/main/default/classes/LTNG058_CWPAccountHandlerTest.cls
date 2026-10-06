/**
* @author Jayanth Manickam
* @date Création 25/02/2025
* @date Modification
* @description :ALL the functions used in LTNG058_CWPAccountHandlerTest
* @history Modifications :   
*  
*/
@isTest
public class LTNG058_CWPAccountHandlerTest {
    
    private static ApiConnection con = new ApiConnection();
      @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        Id acRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Canceled_Work_Permit').getRecordTypeId();
        Case caseObj = (Case)TestDataFactory.createSObject(new Case(RecordTypeId = acRecordTypeId,ContactId = acc1.PersonContactId,AccountId = acc1.id,Case_Model__c='ila',Type ='Canceled Work Permit',Sub_Type__c='Canceled Work Permit',ac_RequestedBy__c='',cc_Request_Type__c=''), 'TestFactoryDefaults.CaseDefaults',true);//CH01
        Canceled_WP__c CWPObbj= New Canceled_WP__c();
          CWPObbj.Customer__c = acc1.id;
          CWPObbj.Case__c=caseObj.id;
          CWPObbj.Status__c='Confirmed_Fraud';
          CWPObbj.Customer_CIF__c='52545544';
          insert CWPObbj;
      }
    
     @isTest
    public static void getAccRequestCaseRecordTypeTest(){   
        Test.startTest();
        Canceled_WP__c cwp=[Select ID from Canceled_WP__c limit 1];
        List<String>CWPId=New List<string>{cwp.Id};
        LTNG058_CWPAccountHandler.blockunblockAccountApiFromFlow(CWPId);
        Test.stopTest();
    }
    

}