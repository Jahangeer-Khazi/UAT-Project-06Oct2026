@isTest
private class ReturnedCardsDestroySchedulerTest {

    @isTest
    static void testScheduler() {
        Test.startTest();

        String cronExp = '0 0 0 1 1 ? 2099';
        System.schedule(
            'ReturnedCardsDestroySchedulerTest',
            cronExp,
            new ReturnedCardsDestroyScheduler()
        );

        Test.stopTest();
    }
}