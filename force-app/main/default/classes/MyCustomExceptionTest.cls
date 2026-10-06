/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 27-12-2022
* 		Change History: 
*	   
*/
@isTest
public class MyCustomExceptionTest {
   @isTest
    static void unitTest2(){
        Test.startTest();
        	MyCustomException e = new MyCustomException('Bad Code', true);
           // e.addError('Bad Code', true);
    	Test.stopTest();
    }

}