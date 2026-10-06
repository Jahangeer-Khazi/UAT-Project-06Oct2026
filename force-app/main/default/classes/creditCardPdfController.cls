/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 16-08-2023
*       Change History:
*         #CH01 : #Imane Tsioucha# #22-02-2024# add x-canary header

*/
public class creditCardPdfController {
    public String accName { get; set; }
    public String customerId { get; set; }
    public String selCardId { get; set; }
    public String regionName{get; set;}
    
    public String decodedaccName { get; set; }
    public String decodedcustomerId { get; set; }
    public String decodedselCardId { get; set; }
    public String decodedregionName{get;set;}
    
    // List to hold the deserialized transaction data
    public List<TransactionData> transactionList { get; set; }
    List<Object> alldataList = new List<Object>();
    
    private static ApiConnection con = new ApiConnection();
    public creditCardPdfController() {
        System.debug('Inside Credit Card Pdf 2 Class');
        accName = ApexPages.currentPage().getParameters().get('accName');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        selCardId = ApexPages.currentPage().getParameters().get('selCardId');
        regionName = ApexPages.currentPage().getParameters().get('regionName');
        
        // Decode the parameters from base64
        decodedaccName = EncodingUtil.base64Decode(accName).toString();
        decodedcustomerId = EncodingUtil.base64Decode(customerId).toString();
        decodedselCardId = EncodingUtil.base64Decode(selCardId).toString();
        decodedregionName = EncodingUtil.base64Decode(regionName).toString();
        
        ApiConnection.Response response = new ApiConnection.Response();
        Date currentDatePlusOne = Date.today() + 1;
        Date currentDate = Date.today();
        Date lastThreeMonths = currentDate.addMonths(-3);
        String formattedCurrentDate = convertToString(currentDatePlusOne);
        String formattedThreeMonthsDate = convertToString(lastThreeMonths);
        Integer offset = 1;
        List<Object> prevTransactions = new List<Object>();
        response = loadCreditCardTransactions(decodedselCardId,formattedCurrentDate,formattedThreeMonthsDate,decodedcustomerId,offset,decodedregionName,prevTransactions);
        System.debug('Credit Card Transaction Response in constructor:'+response);
        String JsonString =  JSON.serializePretty(response);
        System.debug('JSON String in constructor:'+JsonString);//responseData
        
        TransactionResponse tranresponse = (TransactionResponse)System.JSON.deserialize(JsonString, TransactionResponse.class);
        System.debug('Trans Response:'+tranresponse);
        if (tranresponse != null && tranresponse.responseData != null) {
            transactionList = new List<TransactionData>(tranresponse.responseData);
        } else {
            transactionList = new List<TransactionData>();
        }
        System.debug('Transaction List :'+transactionList);
        
    }
    
    public ApiConnection.Response loadCreditCardTransactions(String selCardId, String currentDate, String lastThreeMonthsDate, final String customerId,Integer offsetValue, String regionName, Object[] prevTransactions){
        ApiConnection.Response response = new ApiConnection.Response();
        response.responseData = new List<Object>();
        Account accObj = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc=: customerId];//CH01

        final String path = '/api/v1/credit-cards/transactions?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        if(accObj.x_canary__pc != null){
            req.setHeader('x-canary', accObj.x_canary__pc); //CH01
        }

        System.debug('Selected Card Id:'+selCardId);
        
        String jsonString = '{"pciNumber": "'+selCardId+'" '+
            ', "fromDate": "'+lastThreeMonthsDate+'" '+
            ', "toDate": "'+currentDate+'" '+
            ', "debitCreditIndicator": "ALL" '+
            ', "cardAccountIndicator": "ALL" '+
            ', "offset": "'+offsetValue +'" '+
            ', "pageSize": 20 '+
            ',"status": "ALL" '+
            ' }';
        req.setBody(jsonString);
        system.debug('Request Body:'+req.getBody());
        
        response = con.makeCallout(req);
        System.debug('Response Body for Credit Card Transactions' + JSON.serializePretty(response));
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        
        if(responseData != null){
            List<Object> transactions = (List<Object>)responseData.get('transactions');
            if(response.responseData != null){
                response.recordLength = transactions.size();
                System.debug('Transaction Size:'+transactions.size());
                System.debug('Transactions Data:'+JSON.serializePretty(transactions));
                if(prevTransactions != null){
                    System.debug('Previous Transaction Data Size:'+prevTransactions.size());
                    System.debug('Previous Transaction Data:'+JSON.serializePretty(prevTransactions));
                    alldataList.addAll(prevTransactions);
                    System.debug('All Data List Size:'+alldataList.size());
                    System.debug('Loading All Data List format:'+JSON.serializePretty(alldataList));
                    
                }
                System.debug('Record Length:'+response.recordLength); //Always Check the Current Transaction Size
                if(response.recordLength > 0){
                    if(offsetValue < Integer.valueOf(System.Label.DEFAULT_OFFSET)){
                        offsetValue = offsetValue + 1;
                        System.debug('Offset Value:'+offsetValue);
                        loadCreditCardTransactions(selCardId,currentDate,lastThreeMonthsDate,customerId,offsetValue,regionName,transactions);
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
            
        } // If Ends
        
        system.debug('response after filter for Staff View Visibility:'+JSON.serializePretty(response));
        return response;
    }
    public static String convertToString(Date inputDate) {
        String formattedDateString = '';
        if (inputDate != null) {
            Integer year = inputDate.year();
            Integer month = inputDate.month();
            Integer day = inputDate.day();
            
            String yearString = String.valueOf(year);
            String monthString = (month < 10) ? '0' + String.valueOf(month) : String.valueOf(month);
            String dayString = (day < 10) ? '0' + String.valueOf(day) : String.valueOf(day);
            
            formattedDateString = yearString + '-' + monthString + '-' + dayString;
        }
        
        return formattedDateString;
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
    }
    public class CurrencyData {
        public Integer decimalPlaces { get; set; }
        public String code { get; set; }
    }
    public class TransactionResponse {
        public List<TransactionData> responseData { get; set; }
    }
    
}