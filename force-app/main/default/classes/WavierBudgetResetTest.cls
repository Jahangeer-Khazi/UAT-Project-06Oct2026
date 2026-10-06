/********************************************************************************************
* @name                 WavierBudgetResetTest
* @description          This class would responsible code coverage of WavierBudgetReset class
* @date                 09/10/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           09/10/2025     Initial Version
*********************************************************************************************
*/

@isTest
public class WavierBudgetResetTest {

    @testSetup
    static void setupTestData(){
        setupBudgetMatrix();
    }
    
    @isTest
    static void testBudgetReset(){
    	
        Test.startTest();
        WavierBudgetReset schedulableObj = new WavierBudgetReset();
        schedulableObj.execute(null);
        Test.stopTest();
    }
    
    public static void setupBudgetMatrix(){
        List<Budget_Matrix__c> listOfBudgetMatrix = new List<Budget_Matrix__c>();
        
        Budget_Matrix__c bm1 = new Budget_Matrix__c();
        bm1.Budget__c = 50;
        bm1.CRM_Queue__c = 'Team Leaders FAQ';
        bm1.Role_Name__c = 'Team Leaders';
        bm1.Max_Waiver_Amount__c = 0;
        bm1.Utilization__c = 0;
        listOfBudgetMatrix.add(bm1);
        
        Budget_Matrix__c bm2 = new Budget_Matrix__c();
        bm2.Budget__c = 500;
        bm2.CRM_Queue__c = 'Head Of Contact Center FAQ';
        bm2.Role_Name__c = 'Head of Contact Center';
        bm2.Max_Waiver_Amount__c = 0;
        bm2.Utilization__c = 0;
        listOfBudgetMatrix.add(bm2);
        
        insert listOfBudgetMatrix;
        
    }
}