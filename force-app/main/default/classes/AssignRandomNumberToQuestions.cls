/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 18-06-2026
*       Change History: 
*        
*/
public class AssignRandomNumberToQuestions {
    
   @InvocableMethod(label='Assign Random Numbers To Questions')
    public static List<List<Security_Question__c>> assignRandomNumbers(List<List<Security_Question__c>> inputsOfOptionalQuestions) {
        System.debug('List of Random Questions:'+inputsOfOptionalQuestions);
         System.debug('List of Random Questions Size:'+inputsOfOptionalQuestions.size());
        // This is the outer list that Flow expects back
        List<List<Security_Question__c>> responseWrapper = new List<List<Security_Question__c>>();
        
        // Loop through each collection sent by the Flow transaction
        for (List<Security_Question__c> currentCollection : inputsOfOptionalQuestions) {
            List<Security_Question__c> lstQuestionsUpdatedRandomNumbers = new List<Security_Question__c>();
            
            // Loop through the actual records inside your OptionalQuestionList
            for (Security_Question__c ques : currentCollection) {
                System.debug('Current Question:'+ques);
                if (ques.Type__c != 'Mandatory') {
                    ques.Random_Number__c = Math.mod(Math.abs(Crypto.getRandomInteger()), 1000);
                    lstQuestionsUpdatedRandomNumbers.add(ques);
                }
            }
            
            // Add the processed collection to our final wrapper
            responseWrapper.add(lstQuestionsUpdatedRandomNumbers);
        }

        return responseWrapper;
    }

}