/**
 * @author Charlie Nash (Westbrook)
 * @date 30th January 2022
 *
 * @description
 *
 * Used for testing the GiftingAPIController class. Created by Charlie Nash (Westbrook).
 */

@IsTest
private class GiftingAPIControllerTest {


    @TestSetup
    public static void testDataSetup(){


        //TEST SETUP DATA WILL GO HERE.


    }


    @IsTest
    static void testGiftingAPIResponse() {
        Test.startTest();
        //TEST THE AWS CALLOUT TO TEST RESPONSE
        Test.setMock(HttpCalloutMock.class, new CalloutMock());
        GiftingAPIController.getSentGifts('12345');
        Test.stopTest();
    }
}