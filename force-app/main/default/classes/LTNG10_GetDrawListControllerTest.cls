/**
 * @author Wissal benqezza
 * @date Création 13/04/2022
 * @date Modification
 * @description :
 */
@isTest
public with sharing class LTNG10_GetDrawListControllerTest {

    @isTest
    static void getDrawListViaApiTest(){
        Test.startTest();
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            ApiConnection.Response res = LTNG10_GetDrawListController.getDrawListViaApi('kanz','Bahrain');
            System.assert(res != null);
        Test.stopTest();
    }

    @isTest
    static void getDrawRecordTypeTest(){
        Test.startTest();
            Id res = LTNG10_GetDrawListController.getDrawRecordType('Bahrain',null);//#CH02
            System.assert(res != null);
        Test.stopTest();
    }
}