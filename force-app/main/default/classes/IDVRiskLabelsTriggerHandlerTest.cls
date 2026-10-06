/**
 * @author Imane Tsioucha
 * @date Creation 28/06/2023
 * @date Modification
 * @description : Test class of IDVRiskLabelsTriggerHandler.
 */

 @isTest
public with sharing class IDVRiskLabelsTriggerHandlerTest {
    static Account testAccount;
    static IDV_RiskLabels__c testIDV;

  
    static {
        testAccount = new Account(
            CIF__pc = '5544458',
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com'
        );
        insert testAccount;

        testIDV = new IDV_RiskLabels__c(
            CIF__c = '5544458',
            Process_Type__c = 'TestProcess',
            Reference_No__c = 'TestReference'
        );
        insert testIDV;
    }

    @isTest
    public static void fetchAccountWhenIDVinsertedTest() {       
        Test.startTest();
        system.debug('testIDV==> '+testIDV);
        IDVRiskLabelsTriggerHandler.fetchAccountWhenIDVinserted(new List<IDV_RiskLabels__c>{testIDV});
        Test.stopTest();
    }
}