/**
 * @description       : 
 * @author            : AITOGRAM Omar
 * @group             : 
 * @last modified on  : 05-20-2024
 * @last modified by  : AITOGRAM Omar
**/
public class loanTransactionsPdfController {
    public String accName { get; set; }
    public String selLoanId { get; set; }
    public String customerId { get; set; }
    public String regionName{get; set;}
    public String searchParametersJson{get; set;}
    public String decodedaccName { get; set; }
    public String decodedcustomerId { get; set; }
    public String decodedselLoanId { get; set; }
    public String decodedregionName{get;set;}
    public String decodedsearchParametersJson{get;set;}
   // public RequestParams filter {get;set;}
    // List to hold the deserialized transactions data
    public List<TransactionData> transactionList { get; set; }
    
    private static ApiConnection con = new ApiConnection();
    
    public loanTransactionsPdfController() {

   	    String accName = ApexPages.currentPage().getParameters().get('accName');
        System.debug('Account Name: ' + accName);
        
        String customerId = ApexPages.currentPage().getParameters().get('customerId');
        System.debug('Customer ID: ' + customerId);
        
        String searchFilterConditions = ApexPages.currentPage().getParameters().get('stngifyFilters');
        System.debug('Selected searchFilterConditions: ' + searchFilterConditions);
         
        String selLoanId = ApexPages.currentPage().getParameters().get('selLoanId');
        System.debug('Selected Loan ID: ' + selLoanId);
        
        String regionName = ApexPages.currentPage().getParameters().get('regionName');
        System.debug('Region Name: ' + regionName);

        
        // Decode the parameters from base64
        decodedaccName = EncodingUtil.base64Decode(accName).toString();
        decodedcustomerId = EncodingUtil.base64Decode(customerId).toString();
        decodedselLoanId = EncodingUtil.base64Decode(selLoanId).toString();
        decodedregionName = EncodingUtil.base64Decode(regionName).toString();
     
        ApiConnection.Response response = new ApiConnection.Response();
        response = loadTransactionResponse(decodedcustomerId, searchFilterConditions, decodedregionName);
        System.debug('Response in constructor:'+response);
        String jsonString =  JSON.serializePretty(response);
        System.debug('JSON String in constructor:'+jsonString);
        
        TransactionResponse payResponse = (TransactionResponse)System.JSON.deserialize(jsonString, TransactionResponse.class);
        System.debug('Pay Response:'+PayResponse);
        if (PayResponse != null && PayResponse.responseData != null) {
            transactionList = new List<TransactionData>(PayResponse.responseData);
        } else {
            transactionList = new List<TransactionData>();
        }
        System.debug('Transaction List :'+transactionList);
        
    }
    
    public ApiConnection.Response loadTransactionResponse(String customerId, final String searchParametersJson, String regionName){
        ApiConnection.Response response = new ApiConnection.Response();
        response.responseData = new List<Object>();
    

        System.debug('Selected Loan Id:'+ customerId + regionName+ searchParametersJson);
        
        String requestBody = searchParametersJson;
        
        system.debug('Request Body:'+requestBody);
        response = Loans_ServiceManagerHandler.loadLoanTransactions(customerId, requestBody, regionName);
        System.debug('Response Body for transactions schedule' + JSON.serializePretty(response));
        return response;
    }

    
    // Wrapper class to represent transaction data
    public class TransactionData {
        
        public String transactionDate { get; set; }
        public String transactionType { get; set; }
        public String status{get;set;}
        public String originalAmount { get; set; }
        public CurrencyData accountCurrency { get; set; }
        public String transactionDescription1 { get; set; }
        public String transactionDescription2 { get; set; }
        public String reference { get; set; }
     
    }
   public class CurrencyData {
        public Integer decimalPlaces { get; set; }
        public String code { get; set; }
    }
  //  public class RequestParams {
   //     public String id { get; set; }
     //   public Integer offSet { get; set; }
      //  public Integer pageSize { get; set; }
      //  public Date fromDate { get; set; }
      //  public Date toDate { get; set; }
	 //   public String debitCreditIndicator { get; set; }
     //   public String status { get; set; }
   // }

    public class TransactionResponse {
        public List<TransactionData> responseData { get; set; }
    }
    
}