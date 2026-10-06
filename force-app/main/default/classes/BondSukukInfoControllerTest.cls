/**
* @author Jayanth Manickam
* @date Création 25/04/2024
* @date Modification
* @description :ALL the functions used in BondSukukInfoControllerTest
* @history Modifications :   
*  
*/
@isTest
public class BondSukukInfoControllerTest {
    @isTest
    public static void loadBondListTest(){
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        Test.startTest();
        BondSukukInfoController.loadBondList('ASDDSDSD','Bahrain');
        Test.stopTest();
    }
    @isTest
    public static void loadBondDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        Test.startTest();
        BondSukukInfoController.loadBondDetails('ASDDSDSD','32323','Bahrain');
        Test.stopTest();
    }
     @isTest
    public static void loadCouponDetailsTest(){
        Test.setMock(HttpCalloutMock.class, new MCK04_Bonds_SukukServiceApiCalls());
        Test.startTest();
        BondSukukInfoController.loadCouponDetails('54445','Bahrain','ASDDSDSD');
        Test.stopTest();
    }
}