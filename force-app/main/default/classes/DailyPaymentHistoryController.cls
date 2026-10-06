public class DailyPaymentHistoryController {
    private static ApiConnection con = new ApiConnection();
    // Wrapper matching the JSON structure
    public class PaymentLimitResponse {
        @AuraEnabled public MetaWrapper meta { get; set; }
        @AuraEnabled public DataWrapper data { get; set; }
    }

    public class MetaWrapper {
        @AuraEnabled public String code { get; set; }
        @AuraEnabled public String message { get; set; }
    }

    public class DataWrapper {
        @AuraEnabled public Decimal maxDailyLimit { get; set; }
        @AuraEnabled public Decimal consumedDailyLimit { get; set; }
        @AuraEnabled public Decimal remainingDailyLimit { get; set; }
    }

    @AuraEnabled
    public static PaymentLimitResponse getDailyPaymentLimit(String accountId) {
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];
        String regionName = accObj.Region_Flag__c;
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('GET','/api/v1/credit-cards/payment/limit', regionName);
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            if(accObj.x_canary__pc != null){
            	request.setHeader('x-canary', accObj.x_canary__pc); 
        	}
            request.setTimeout(60000);
			HttpResponse res = http.send(request);
			System.debug('Response:'+res.getBody());
            if(res.getStatusCode() == 200) {
                PaymentLimitResponse responseObj = (PaymentLimitResponse) JSON.deserialize(res.getBody(),PaymentLimitResponse.class);
                System.debug('Response Object:'+responseObj);
                return responseObj;
            }else{
                throw new AuraHandledException('Callout failed with status code: ' + res.getStatusCode() + ' - ' + res.getStatus());
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static HistoryLogsResponse getHistoryLogs(String accountId, String selectedDate) {

        HistoryLogsResponse result = new HistoryLogsResponse();
 		Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];
        String regionName = accObj.Region_Flag__c;

        try {

            // =================================================
            // Validate Customer Id
            // =================================================

            if (String.isBlank(accountId)) {

                result.success = false;

                result.message = 'Customer Id is required.';

                return result;
            }


            // =================================================
            // Validate Date
            // =================================================

            if(String.isBlank(selectedDate)) {

                result.success = false;

                result.message = 'Selected date is required.';

                return result;
            }


            // =================================================
            // Validate Date Format
            // =================================================

            Date requestedDate;

            try {

                requestedDate = Date.valueOf(selectedDate);

            } catch (Exception e) {

                result.success = false;

                result.message ='Invalid date format. Expected yyyy-MM-dd.';

                return result;
            }


            System.debug('Customer Id: ' + accountId);

            System.debug('Selected Date: ' + requestedDate);


            // =================================================
            // Create HTTP Request
            // =================================================

            HttpRequest request = new HttpRequest();
            String Url = '/api/v1/credit-cards/payment/restriction/history';
            String fullEndPoint = Url + '?fromDate='+ EncodingUtil.urlEncode(selectedDate,'UTF-8') + '&toDate='+ EncodingUtil.urlEncode(selectedDate,'UTF-8');

            request = con.createRequest('GET',fullEndPoint, regionName);
            System.debug('History API Endpoint: '+ request.getEndPoint());
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            if(accObj.x_canary__pc != null){
            	request.setHeader('x-canary', accObj.x_canary__pc); 
        	}
            request.setTimeout(60000);
			Http http = new Http();
			HttpResponse response = http.send(request);
			System.debug('History API Status Code: '+ response.getStatusCode());
			System.debug('History API Response: '+ response.getBody());


            // =================================================
            // Successful Response
            // =================================================

            if(response.getStatusCode() == 200){
				Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

				Map<String, Object> metaMap;
				if(responseMap.containsKey('meta') && responseMap.get('meta') != null) {
					metaMap = (Map<String, Object>)responseMap.get('meta');
                }
				if (metaMap != null && metaMap.containsKey('message')) {
					result.message = String.valueOf(metaMap.get('message'));
                }

				List<Object> historyList = new List<Object>();
				if(responseMap.containsKey('data') && responseMap.get('data') != null) {
					historyList = (List<Object>)responseMap.get('data');
                }
				System.debug('History List: '+ JSON.serialize(historyList));

				List<HistoryRecord> records = new List<HistoryRecord>();
				for(Object historyObject : historyList) {
					Map<String, Object> historyMap = (Map<String, Object>)historyObject;
					HistoryRecord record = new HistoryRecord();
					record.previousTotalPaymentAmount = getDecimal(historyMap,'previousTotalPaymentAmount');
					record.maxDailyPaymentCap = getDecimal(historyMap,'maxDailyPaymentCap');
					record.paymentAmount = getDecimal(historyMap,'paymentAmount');
                    record.remainingDailyLimit = getDecimal(historyMap,'remainingDailyLimit');
					record.maskedCardNumber = getString(historyMap,'maskedCardNumber');
					record.pciNumber = getString(historyMap,'pciNumber');
					record.status = getString(historyMap,'status');
					record.creationDatetime = getString(historyMap,'creationDatetime');
					records.add(record);
                }


                // ==========================================
                // Create History Data
                // ==========================================

                HistoryData historyData = new HistoryData();
				historyData.history = records;
				result.success = true;
				result.data = historyData;


            }

            // =================================================
            // API Error
            // =================================================

            else{
				result.success = false;
				result.message = 'History API returned HTTP status ' + response.getStatusCode() + '.';
            }

		}catch(Exception e) {
			System.debug('History API Exception: '+ e.getMessage());
			result.success = false;
			result.message = 'Unable to retrieve payment history: ' + e.getMessage();
        }
		return result;
    }
	private static Decimal getDecimal(Map<String, Object> data,String fieldName) {
		if(!data.containsKey(fieldName) || data.get(fieldName) == null) {
			return null;
        }
		return Decimal.valueOf(String.valueOf(data.get(fieldName)));
    }
	private static String getString(Map<String, Object> data, String fieldName){
		if(!data.containsKey(fieldName) || data.get(fieldName) == null) {
			return null;
        }
		return String.valueOf(data.get(fieldName));
    }

	public class HistoryData {
        @AuraEnabled
		public List<HistoryRecord> history;
    }


    // =====================================================
    // History Record
    // =====================================================

    public class HistoryRecord {
		@AuraEnabled
        public Decimal previousTotalPaymentAmount;
		@AuraEnabled
        public Decimal maxDailyPaymentCap;
		@AuraEnabled
        public Decimal paymentAmount;
        @AuraEnabled
        public Decimal remainingDailyLimit;
		@AuraEnabled
		public String maskedCardNumber;
		@AuraEnabled
        public String pciNumber;	
		@AuraEnabled
        public String status;
		@AuraEnabled
        public String creationDatetime;
    }


    // =====================================================
    // Aura Response
    // =====================================================

    public class HistoryLogsResponse {

        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public HistoryData data;
    }
    
    @AuraEnabled
    public static WhitelistResponse getWhitelistDetails(String accountId) {
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id =: accountId];
		String regionName = accObj.Region_Flag__c;

        WhitelistResponse result = new WhitelistResponse();

        try {
			HttpRequest request = new HttpRequest();
			request = con.createRequest('GET','/api/v1/credit-cards/payment/whitelisted-customer', regionName);
			request.setHeader('userId', accObj.PersonEmail);
			request.setHeader('customerId', accObj.CIF__pc);
			if(accObj.x_canary__pc != null){
   				request.setHeader('x-canary', accObj.x_canary__pc); 
			}
			request.setTimeout(60000);
            Http http = new Http();
			HttpResponse response = http.send(request);
			System.debug('Whitelist API Status Code: ' +response.getStatusCode());

            if(response.getStatusCode() == 200 ){
                System.debug('Whitelist API Response: ' +response.getBody());
				ApiResponse apiResponse = (ApiResponse) JSON.deserialize(response.getBody(),ApiResponse.class);
				result.success = true;
				result.message = apiResponse.meta != null ? apiResponse.meta.message: null;
                result.data =apiResponse.data;

            }else{
				result.success = false;
				result.message = 'Whitelist API failed. Status Code: ' +response.getStatusCode();
            }

        }catch (Exception ex) {
			System.debug('Whitelist API Exception: ' +ex.getMessage());
			System.debug('Trace Exception:'+ex.getStackTraceString());
			result.success = false;
			result.message ='Unable to retrieve whitelist details: ' +ex.getMessage();
        }
		return result;
    }
    
    public class ApiResponse {
		public Meta meta;
		public WhitelistData data;
    }
    
    public class Meta {
		public String code;
		public String message;
    }
    
    public class WhitelistData {

        @AuraEnabled
        public List<WhitelistRecord> whitelists;
    }
    
    public class WhitelistRecord {

        @AuraEnabled
        public Integer id;

        @AuraEnabled
        public String pciNumber;

        @AuraEnabled
        public String whitelistedBy;

        @AuraEnabled
        public String fromDate;

        @AuraEnabled
        public String toDate;

        @AuraEnabled
        public String creationDatetime;

        @AuraEnabled
        public String expired;
    }
    
    public class WhitelistResponse {

        @AuraEnabled
        public Boolean success;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public WhitelistData data;
    }
    
    @AuraEnabled
    public static WhitelistResponse createWhitelist(String accountId,String fromDate,String toDate) {
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id =: accountId];
		String regionName = accObj.Region_Flag__c;
        
        WhitelistResponse result = new WhitelistResponse();
        try{
            String currentUserName = UserInfo.getName();
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('whitelistedBy',currentUserName);
            requestBody.put('fromDate',fromDate);
            requestBody.put('toDate',toDate);
            String requestBodyJson = JSON.serialize(requestBody);
            System.debug('Whitelist Request Body: ' + requestBodyJson);
            HttpRequest request = new HttpRequest();
            request = con.createRequest('POST', '/api/v1/credit-cards/payment/whitelisted-customer', accObj.CIF__pc, regionName);
            request.setBody(requestBodyJson);
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug('Whitelist POST Status Code: ' +response.getStatusCode());
            System.debug('Whitelist POST Response: ' +response.getBody());
            
            if(response.getStatusCode() == 200){
                result.success = true;
                result.message = 'Customer whitelisted successfully.';
            }else{
                result.success = false;
                result.message = 'Whitelist API failed. Status Code: ' +response.getStatusCode();
            }
        }catch(Exception ex){
            System.debug('Whitelist POST Exception: ' +ex.getMessage());
            System.debug('Trace Whitelist:'+ex.getStackTraceString());
            result.success = false;
            result.message ='Unable to whitelist customer: ' +ex.getMessage();
        }
        return result;
    }

}