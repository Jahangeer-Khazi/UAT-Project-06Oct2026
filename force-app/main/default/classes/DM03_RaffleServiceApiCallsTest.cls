/**
 * @author Wissal benqezza
 * @date Création 13/04/2022
 * @date Modification
 * @description :
 */
@isTest
public with sharing class DM03_RaffleServiceApiCallsTest {

    //test class related to DM03_RaffleServiceApiCalls.cls
    
    @isTest
    static void callAllApisTest(){
        Test.startTest();
            MCK03_RaffleServiceApiCalls.statusCodeGlobal = 200;
            Test.setMock(HttpCalloutMock.class, new MCK03_RaffleServiceApiCalls());

            ApiConnection.Response response1 = DM03_RaffleServiceApiCalls.callGetDrawListApi(new ApiConnection(),new HttpRequest(),200);
            System.assert(response1 != null );

            ApiConnection.Response response2 = DM03_RaffleServiceApiCalls.callGetDrawDataApi(new ApiConnection(),new HttpRequest(),200);
            System.assert(response2 != null );

            HttpResponse response3 = DM03_RaffleServiceApiCalls.callGetDrawWinnersApi(new HttpRequest(),200);
            System.assert(response3 != null );

            HttpResponse response4 = DM03_RaffleServiceApiCalls.callGetDrawSummaryApi(new HttpRequest(),200);
            System.assert(response4 != null );

            HttpResponse response5 = DM03_RaffleServiceApiCalls.callCreateDrawApi(new HttpRequest(),200);
            System.assert(response5 != null );

            HttpResponse response6 = DM03_RaffleServiceApiCalls.updateDrawStatusApi(new HttpRequest(),200);
            System.assert(response6 != null );
        Test.stopTest();
    }
}