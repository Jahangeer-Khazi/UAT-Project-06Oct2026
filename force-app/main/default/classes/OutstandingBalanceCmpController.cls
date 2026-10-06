/********************************************************************************************
* @name                 OutstandingBalanceCmpController
* @description          This class would help to render the credit card and loan details on visualforce components
* @date                 10/09/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           10/09/2025     Initial Version
*********************************************************************************************
*/

public class OutstandingBalanceCmpController {

    public OutstandingBalanceWrapper obWrapper { get; set; }
    public String formattedTotalCreditCardBalance { get; set; }
    public String formattedTotalLoanBalance { get; set; }
    
    public void setWrapperObject(Object obj){
        obWrapper = (OutstandingBalanceWrapper)obj;
    }
    
    public Object getWrapperObject(){
        return obWrapper;
    }
    
    public String getTotalCreditCardBalance(){
        if(obWrapper.cardWrapperList.isEmpty()){
            return '';
        }
        else {
            return formattedTotalCreditCardBalance;
        }
    }
    
    public String getTotalLoanBalance(){
       if(obWrapper.ilaLoanWrapperList.isEmpty() && obWrapper.alburaqLoanWrapperList.isEmpty()){
           return '';
       }
       else {
            return formattedTotalLoanBalance;
       }
    }
}