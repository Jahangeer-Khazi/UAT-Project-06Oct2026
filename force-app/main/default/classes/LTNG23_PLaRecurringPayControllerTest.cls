@isTest

public class LTNG23_PLaRecurringPayControllerTest {

    @isTest
    static void callScheduledPlaPaymentsApiTest(){
        test.startTest();
        MCK001_ApiCalls.statusCodeGlobal = 200;

        ApiConnection.Response response = LTNG23_PLaRecurringPaymentsController.getScheduledPlaPayments('123456' , '{}','Bahrain');
        System.assert(response != null);

        ApiConnection.Response response1 = LTNG23_PLaRecurringPaymentsController.getSchedulRecPayDetails('123456' , '1','Bahrain');
        System.assert(response1 != null);

        test.stopTest();
    }
}