/**
* @author Jayanth Manickam
* @date Création 25/06/2024
* @date Modification
* @description :ALL the functions used inLTNG048_GovtSecuritiesCntrlTest
* @history Modifications :   
*  
*/


@isTest
public class LTNG048_GovtSecuritiesCntrlTest {

      @testSetup static void setupMethod() {
        Account acc1 =(Account)TestDataFactory.createSObject(new Account(CIF__pc='123456',region_flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
        
    }    
    @isTest
    Public static void getCustomerDetailsTest(){
        Test.StartTest();
        LTNG048_GovtSecuritiesCntrl.getCustomerDetails('Bahrain','123456');
        Test.StopTest();
    }
     @isTest
    Public static void loadGovSecuritiesTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG048_GovtSecuritiesCntrl.loadGovSecurities('Bahrain','123456');
        Test.StopTest();
    }
    
    @isTest
        public static void customLookUpControllerTest(){
            Test.StartTest();
            customLookUpController.fetchLookUpValues('helllo','Account');
            Test.stopTest();
        }
      @isTest
    Public static void getHistoryDetailsTest(){
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        LTNG048_GovtSecuritiesCntrl.getHistoryDetails('Bahrain','123456');
        Test.StopTest();
    }
}