/**
 * @author Imane Tsioucha
 * @date Création 07/09/2023
 * @date Modification
 * @description : Test class of LTNG028_ShowUncollectedFeesController.
 * 
 */

 @isTest
public with sharing class LTNG028_ShowUncollectedFeeControllerTest {
    @TestSetup
    static void makeData(){
        Account acc1 = new Account(
            FirstName = 'TestDocument',
            LastName = 'TestDocument',
            PersonEmail = 'test@gmail.com'
        );
        insert acc1; 
    }

    @isTest
    public static void getAccountForFeeViaApiTest(){   
        Id accId = [SELECT Id FROM Account LIMIT 1 ].Id;
        Test.startTest();
            MCK001_ApiCalls.statusCodeGlobal = 200;
        try{
            LTNG028_ShowUncollectedFeesController.callUncollectedFeesApi(accId,null,null);
        }catch(Exception e){
            System.debug('getAccountForFeeViaApiTest');
        }
            
        Test.stopTest();
    }
    
}