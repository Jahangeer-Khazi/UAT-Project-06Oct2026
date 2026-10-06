/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 27-12-2022
* 		Change History: 
*	   
*/
public class MyCustomException extends Exception {
    boolean status ;
    String errMsg ; 
   
    public MyCustomException(String errMsg,boolean status)
    {
       this.errMsg = errMsg;
       this.status = status;
    } 
    
}