/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 25-08-2023
*       Change History: 
*           #CH01 : #Imane Tsioucha# #22-02-2024# add x-canary header
*			#CH02 : #Maksud Ali# #28-09-2025# Added a code for excel export functionality.
*/
public class creditCardPdfController2 {
   // Store the JSON data passed from the Lightning Component
    public String searchFilterConditions { get; set; }
    
    public String accName { get; set; }
    public String customerId { get; set; }
    public String selCardId { get; set; }
    public String regionName{get; set;}
    
    public String decodedaccName { get; set; }
    public String decodedcustomerId { get; set; }
    public String decodedselCardId { get; set; }
    public String decodedregionName{get;set;}
    public String decodedCardType{get;set;}
    
    //CH02 Start 
    public String maskedCardNo { get; set; }
    public String fromDate { get; set; }
    public String toDate { get; set; }
    public Boolean isFromDateIncludedInFilter { get; set; }
    //CH02 End
    
    public SearchFilter filter {get;set;}
    
     // List to hold the deserialized transaction data
    public List<TransactionData> transactionList { get; set; }
    List<Object> alldataList = new List<Object>();
    public Integer offsetValue = 1;
    private static ApiConnection con = new ApiConnection();
    
    public creditCardPdfController2() {
        accName = ApexPages.currentPage().getParameters().get('accName');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        selCardId = ApexPages.currentPage().getParameters().get('selCardId');
        regionName = ApexPages.currentPage().getParameters().get('regionName');
        searchFilterConditions = ApexPages.currentPage().getParameters().get('stngifyFilters');
        decodedCardType = ApexPages.currentPage().getParameters().get('cardType');
        // Decode the parameters from base64
        decodedaccName = EncodingUtil.base64Decode(accName).toString();
        decodedcustomerId = EncodingUtil.base64Decode(customerId).toString();
        decodedselCardId = EncodingUtil.base64Decode(selCardId).toString();
        decodedregionName = EncodingUtil.base64Decode(regionName).toString();
        decodedCardType = EncodingUtil.base64Decode(decodedCardType).toString();
        ApiConnection.Response response = new ApiConnection.Response();
        List<Object> prevTransactions = new List<Object>();
       
        decodedCardType = decodedCardType + ' Transactions';
        
        if(searchFilterConditions != null){
            // Deserialize the JSON Search data into a Search Filter Object
            filter = (SearchFilter)JSON.deserialize(searchFilterConditions,SearchFilter.class);
            filter.offset = 1;
            String reqBody = JSON.serialize(filter);
            response = loadCreditCardTransactions(decodedselCardId,reqBody,decodedcustomerId,decodedregionName,prevTransactions);
 			String JsonString =  JSON.serializePretty(response);
        	
        	TransactionResponse tranresponse = (TransactionResponse)System.JSON.deserialize(JsonString, TransactionResponse.class);
        	
            if (tranresponse != null && tranresponse.responseData != null) {
            	transactionList = new List<TransactionData>(tranresponse.responseData);
        	} else {
            	transactionList = new List<TransactionData>();
        	}
            
            //CH02 - Start
            String urlPath = ApexPages.currentPage().getURL();
            if(urlPath.containsIgnoreCase('CreditCardTransactionExcel')){
                
                if(!transactionList.isEmpty()){
                   maskedCardNo = transactionList[0].maskedCardNumber;
                    
                    for(TransactionData transObj : transactionList){
                        if(!String.isBlank(transObj.transactionDate)){
                            //setting the date format to DD MMM YYYY HH:mm Example: 21 Apr 2026 17:30.
                            List<String> dateComponent = transObj.transactionDate.split('T');
                            List<String> ddmmyy = dateComponent[0].split('-');
                            
                            Integer yyyy = Integer.valueOf(ddmmyy[0]);
                            Integer mm = Integer.valueOf(ddmmyy[1]);
                            Integer dd = Integer.valueOf(ddmmyy[2]);
                            DateTime transationDate = DateTime.newInstance(yyyy,mm,dd);
                            transObj.transactionDate = dateComponent[1].substring(0, dateComponent[1].length() - 3); //Removing last 3 digit from datetime e.g. '2025-08-06T10:43:31' in the sample date :31 would removed.
            				transObj.transactionDate = transationDate.format('dd MMM yyyy') + ' ' + transObj.transactionDate; 
                        }
                    }
                }
                
                String datePopulated = ApexPages.currentPage().getParameters().get('datePopulated');
                datePopulated = EncodingUtil.base64Decode(datePopulated).toString();
            	
                if(datePopulated == 'Y'){
                    isFromDateIncludedInFilter = true;
                    fromDate = filter.fromDate;
                    toDate = filter.toDate;
                }
                ApexPages.currentPage().getHeaders().put('Content-Disposition', 'attachment; filename="' + decodedcustomerId + '_Cards_'+ DateTime.now().format('ddMMyyyy') +'.xls"');	
            }
            //CH02 - End
        }
    }
    
    public ApiConnection.Response loadCreditCardTransactions(String selCardId, String jsonString,final String customerId, String regionName, Object[] prevTransactions){
        ApiConnection.Response response = new ApiConnection.Response();
        Account accObj = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc=: customerId];//CH01

        response.responseData = new List<Object>();
		final String path = '/api/v1/credit-cards/transactions?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        if(accObj.x_canary__pc != null){
            req.setHeader('x-canary', accObj.x_canary__pc); //CH01
        }

        req.setBody(jsonString);
        
        response = con.makeCallout(req);
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        
        if(responseData != null){
            List<Object> transactions = (List<Object>)responseData.get('transactions');
            if(response.responseData != null){
                response.recordLength = transactions.size();
                if(prevTransactions != null){
                    alldataList.addAll(prevTransactions);
                }
                
                //Always Check the Current Transaction Size
                if(response.recordLength > 0){
                    if(offsetValue < Integer.valueOf(System.Label.SEARCH_OFFSET)){
                        offsetValue = offsetValue + 1;
                        String incrCounterInRequestBody = increaseOffset(jsonString,offsetValue);
                        loadCreditCardTransactions(selCardId,incrCounterInRequestBody,customerId,regionName,transactions);
                    }
                }
                //if view staff = true, we will display all transactions
                if(CreditCard_SensitiveDataCleaner.isAllowedViewStaffData(customerId)){
                    response.responseData = alldataList;
                }
                else{ //if view staff = false, we will display only transaction during Segment != staff
                    List<Map<String, Datetime>> lstBanedDate = CreditCard_SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                    response.responseData = CreditCard_SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, alldataList);
                }
                
            }
            
        } //If Ends
       
        return response;
    }
    
    public String increaseOffset(String req, Integer offsetCount){
        SearchFilter reqdes = (SearchFilter)JSON.deserialize(req,SearchFilter.class);
        reqdes.offset = offsetCount;
        String offsetIncremReq = JSON.serialize(reqdes);
        return offsetIncremReq;
    }
    
    // Wrapper class to represent transaction data
    public class TransactionData {
        public Decimal originalAmount { get; set; }
        //public DateTime transactionDate { get; set; }
        public String transactionDate { get; set; }
        public String transactionDescription1 { get; set; }
        public String transactionReference { get; set; }
        public CurrencyData originalCurrency { get; set; }
        public String transactionType {get;set;}
        public String status{get;set;}
        public String maskedCardNumber { get; set; }
    }
    public class CurrencyData {
        public Integer decimalPlaces { get; set; }
        public String code { get; set; }
    }
    public class TransactionResponse {
        public List<TransactionData> responseData { get; set; }
    }
    
    public class SearchFilter {
    	public String pciNumber { get; set; }
    	public String debitCreditIndicator { get; set; }
    	public String cardAccountIndicator { get; set; }
    	public Integer offset { get; set; }
    	public Integer pageSize { get; set; }
   	 	public String status { get; set; }
    	public String fromDate { get; set; }
    	public String toDate { get; set; }
        public String fromAmount { get; set; }//CH02 - added fromAmount props
        public String toAmount { get; set; }//CH02 - added toAmount props
	}
    
}