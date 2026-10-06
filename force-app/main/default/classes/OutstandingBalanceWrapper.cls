/********************************************************************************************
* @name                 OutstandingBalanceWrapper
* @description          This wrapper class would store the loan and credit card details return by respective apis.
* @date                 10/09/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           10/09/2025     Initial Version
*********************************************************************************************
*/

public class OutstandingBalanceWrapper {
    
    public List<CreditCardWrapper> cardWrapperList { get; set; }
    public List<LoanWrapper> ilaLoanWrapperList { get; set; }
    public List<LoanWrapper> alburaqLoanWrapperList { get; set; }
    
    public void OutstandingBalanceWrapper(){}
    
    public class CreditCardWrapper {
        public String cardType { get; set; }
        public String cardNumber { get; set; }
        public String formattedCreditLimit { get; set; } //currency with 3 decimal point
        public String formattedOutstandingBalance { get; set; } //currency with 3 decimal point
        
        public Decimal creditLimit { get; set; }
        public Decimal outstandingBalance { get; set; }
        
        
        public CreditCardWrapper() { }
        
    }
    
    public class LoanWrapper {
        public String financeType { get; set; }
        public String financeAccount { get; set; }
        public String formattedOutstandingBalance { get; set; } //currency with 3 decimal point
        public String productType { get; set; }
        public String productName { get; set; }
        
        public Decimal outstandingBalance { get; set; }
        
        public LoanWrapper(){}
        
        public LoanWrapper(String financeType,String financeAccount,Decimal outstandingBalance){}
    }
}