/*      Organization : ABC Bank
*       Description  : Test class for AssignRandomNumberToQuestions
*/
@isTest
private class AssignRandomNumberToQuestionsTest {

    @isTest
    static void assignsRandomNumbersAndSkipsMandatoryQuestions() {
        List<Security_Question__c> questions = new List<Security_Question__c>{
            new Security_Question__c(Type__c = 'Mandatory'),
            new Security_Question__c(Type__c = 'Public'),
            new Security_Question__c(Type__c = 'Private'),
            new Security_Question__c(Type__c = 'Private')
        };

        Test.startTest();
        List<List<Security_Question__c>> result = AssignRandomNumberToQuestions.assignRandomNumbers(
            new List<List<Security_Question__c>>{ questions }
        );
        Test.stopTest();

        System.assertEquals(1, result.size(), 'One collection in, one collection out');
        System.assertEquals(3, result[0].size(), 'The Mandatory question is left out');
        for (Security_Question__c ques : result[0]) {
            System.assertNotEquals('Mandatory', ques.Type__c);
            System.assertNotEquals(null, ques.Random_Number__c, 'Every optional question gets a random number');
            System.assert(ques.Random_Number__c >= 0 && ques.Random_Number__c < 1000, 'Random number is between 0 and 999');
        }
    }

    @isTest
    static void handlesSeveralAndEmptyCollections() {
        List<List<Security_Question__c>> input = new List<List<Security_Question__c>>{
            new List<Security_Question__c>{ new Security_Question__c(Type__c = 'Public') },
            new List<Security_Question__c>(),
            new List<Security_Question__c>{ new Security_Question__c(Type__c = 'Mandatory') }
        };

        List<List<Security_Question__c>> result = AssignRandomNumberToQuestions.assignRandomNumbers(input);

        System.assertEquals(3, result.size());
        System.assertEquals(1, result[0].size());
        System.assertEquals(0, result[1].size());
        System.assertEquals(0, result[2].size(), 'A collection with only a Mandatory question comes back empty');
    }
}
