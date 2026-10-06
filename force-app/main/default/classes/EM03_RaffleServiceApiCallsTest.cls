/**
 * @author Wissal benqezza
 * @date Création 13/04/2022
 * @date Modification
 * @description :
 */
@isTest
public with sharing class EM03_RaffleServiceApiCallsTest {

    //test class related to EM03_RaffleServiceApiCalls.cls
    @isTest
    static void callAllApisTest(){
        Test.startTest();
            ApiConnection.Response response1 = EM03_RaffleServiceApiCalls.callGetDrawListApi(new ApiConnection(),new HttpRequest(),200);
            System.assert(response1.isSuccess == true);

            ApiConnection.Response response2 = EM03_RaffleServiceApiCalls.callGetDrawDataApi(new ApiConnection(),new HttpRequest(),200);
            System.assert(response2.isSuccess == true);

            HttpResponse response3 = EM03_RaffleServiceApiCalls.callGetDrawWinnersApi(new HttpRequest(),200);
            System.assert(response3.getStatusCode() == 200);

            HttpResponse response4 = EM03_RaffleServiceApiCalls.callGetDrawSummaryApi(new HttpRequest(),200);
            System.assert(response4.getStatusCode() == 200);

            HttpResponse response5 = EM03_RaffleServiceApiCalls.callCreateDrawApi(new HttpRequest(),200);
            System.assert(response5.getStatusCode() == 200);

            HttpResponse response6 = EM03_RaffleServiceApiCalls.updateDrawStatusApi(new HttpRequest(),200);
            System.assert(response6.getStatusCode() == 200);
        Test.stopTest();
    }
}