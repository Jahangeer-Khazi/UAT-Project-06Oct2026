/*      Organization : ABC Bank
*       Created By: Jayanth Manickam
*       Created Date: 16-08-2023
*       Change History: 
*/
public class creditCardPdfRewardController {
	// Store the JSON data passed from the Lightning Component
    public String jsonData { get; set; }
    
    public String accName { get; set; }
    public String customerId { get; set; }
    public String selCardId { get; set; }
    
    public String decodedaccName { get; set; }
    public String decodedcustomerId { get; set; }
    public String decodedselCardId { get; set; }
    
    // List to hold the deserialized transaction data
    public List<TransactionData> transactionList { get; set; }

    // Constructor to initialize and parse the JSON data
    public creditCardPdfRewardController() {
        jsonData = ApexPages.currentPage().getParameters().get('data');
        
        accName = ApexPages.currentPage().getParameters().get('accName');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        selCardId = ApexPages.currentPage().getParameters().get('selCardId');
        
        // Decode the parameters from base64
        decodedaccName = EncodingUtil.base64Decode(accName).toString();
        decodedcustomerId = EncodingUtil.base64Decode(customerId).toString();
        decodedselCardId = EncodingUtil.base64Decode(selCardId).toString();
        
        System.debug('Acc Name:'+decodedaccName);
        System.debug('Customer Id:'+decodedcustomerId);
        System.debug('Selected Card Id:'+decodedselCardId);
        if (jsonData != null) {
            // Deserialize the JSON data into a list of TransactionData objects
            transactionList = (List<TransactionData>)JSON.deserialize(jsonData, List<TransactionData>.class);
        } else {
            transactionList = new List<TransactionData>();
        }
    }

    // Wrapper class to represent transaction data
    public class TransactionData {
        public String RedemptionDate { get; set; }
        public String RewardsOption { get; set; }
        public String ilaTokensType  { get; set; }
        public String RedeemedTokens { get; set; }
        public String RedeemedTokensValue { get; set; }
        public String Curren {get;set;}
        public String status{get;set;}
        public String ReferenceNumber{get;set;}
        public String Airline{get;set;}
        public String AirlineMembershipNumber{get;set;}
    }

}