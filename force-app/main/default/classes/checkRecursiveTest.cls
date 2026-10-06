/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:
 * 		Change History: 
 * 	 				 #CH01# #Jahangeer Mohammed# #13-07-2022# Added a method unitTest1(CRM22-108)
 *
 *			  
*/
@isTest
private class checkRecursiveTest {

private static testMethod void checkRecursive1test() {
    System.assert(checkRecursive.runOnce(), 'Recursion check failed. Please review checkRecursive recursion logic');
}
     //CH01: Start
    @isTest
    static void unitTest1(){
        checkRecursive.runOnceForCache();
    }
    //CH01: END
}