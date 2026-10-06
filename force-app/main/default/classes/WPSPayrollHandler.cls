public class WPSPayrollHandler {
    
    private static final String PAYROLL_AUTHORIZE_EP = '/api/v1/wps/payroll/action/approve';
    private static final String PAYROLL_REJECT_EP = '/api/v1/wps/payroll/action/reject';
    private static final String PAYROLL_CANCEL_EP = '/api/v1/wps/payroll/action/cancel';
    private static final String ACCOUNT_DETAILS_EP = '/api/v1/accounts/details';
    private static final String FEES_EP = '/api/v1/ila/fees';
    
    public static void handleBeforeInsertChanges(List<WPSPayroll__c> newRecordList) {
        newRecordList[0].OwnerId = getQueueId('Update WPS Payroll Maker Queue');
    }
    
    public static void handleSimpleChanges(List<PayrollData> payrollDataList, Map<Id, WPSPayroll__c> newRecordsMap) {
        for (PayrollData data : payrollDataList) {
            WPSPayroll__c currentRecord = newRecordsMap.get(data.recordId);
            
            if (data.makerResult != null) {
                switch on data.makerResult {
                    when 'Send to Checker' {
                        currentRecord.OwnerId = getQueueId('Update WPS Payroll Checker Queue');
                        currentRecord.Sub_Status__c = 'New';
                        currentRecord.Is_Actioned__c = true;
                        currentRecord.Maker_Result_Date_Time__c = System.now();
                    }
                    when 'Cancel' {
                        currentRecord.Sub_Status__c = 'Canceled';
                        currentRecord.Maker_Result_Date_Time__c = System.now();
                    }
                }
            }
            
            if (data.checkerResult != null) {
                switch on data.checkerResult {
                    when 'Decline' {
                        currentRecord.Sub_Status__c = 'Declined';
                        currentRecord.Status__c = 'Closed';
                        currentRecord.Checker_Result_Date_Time__c = System.now();
                    }
                    when 'Return' {
                        currentRecord.OwnerId = getQueueId('Buy Request Maker Queue');
                        currentRecord.Sub_Status__c = 'New';
                        currentRecord.Is_Actioned__c = false;
                        currentRecord.Checker_Result_Date_Time__c = System.now();
                    }
                }
            }
        }
    }
    
    public static void handleAcceptCheckerResult(List<PayrollData> payrollDataList) {
        List<String> errorMessages = new List<String>();
        
        // Filter and group records by action
        Map<String, List<PayrollData>> recordsByAction = new Map<String, List<PayrollData>>();
        
        for (PayrollData data : payrollDataList) {
            if (data.checkerResult == 'Accept' && data.payrollAction != null) {
                if (!recordsByAction.containsKey(data.payrollAction)) {
                    recordsByAction.put(data.payrollAction, new List<PayrollData>());
                }
                recordsByAction.get(data.payrollAction).add(data);
            }
        }
        
        // Enqueue jobs for each action type
        for (String action : recordsByAction.keySet()) {
            List<PayrollData> actionRecords = recordsByAction.get(action);
            if (!actionRecords.isEmpty()) {
                try {
                    // For Approve action, we need to validate balance and get fees first
                    if (action == 'Approve') {
                        // Enqueue a new queueable that will handle balance validation and fees calculation
                        System.enqueueJob(new WPSPayrollApproveQueueable(actionRecords));
                        System.debug('Enqueued WPSPayrollApproveQueueable for Approve action with ' + actionRecords.size() + ' records');
                    } else {
                        // For other actions (Reject, Cancel), use the original queueable
                        System.enqueueJob(new WPSPayrollQueueable(action, actionRecords));
                        System.debug('Enqueued WPSPayrollQueueable for ' + action + ' action with ' + actionRecords.size() + ' records');
                    }
                } catch (Exception e) {
                    errorMessages.add(action + ' batch: ' + e.getMessage());
                    // Note: We cannot create System Action here because we might have pending DML
                    System.debug('Failed to enqueue job: ' + e.getMessage());
                }
            }
        }
        
        if (!errorMessages.isEmpty()) {
            System.debug('Errors in WPS Payroll enqueueing: ' + errorMessages);
        }
    }
    
    // New method to validate account balance
    public static AccountBalanceResponse validateAccountBalance(PayrollData data) {
        System.debug('=== Entering validateAccountBalance ===');
        System.debug('Record ID: ' + data.recordId);
        System.debug('IBAN: ' + data.payrollDebitAccountIBAN);
        System.debug('Required Amount: ' + data.payrollAmount);
        
        String requestBodyJson = '';
        String responseBody = '';
        Integer httpStatusCode = 0;
        
        try {
            // Create HTTP request for account details
            HttpRequest httpRequest = new HttpRequest();
            ApiConnection apiConn = new ApiConnection();
            
            // Build endpoint with query parameters
            String endpoint = ACCOUNT_DETAILS_EP;
            httpRequest = apiConn.createRequest('POST', endpoint, data.cif, data.regionName);
            httpRequest.setBody('{"id": "'+data.payrollDebitAccountIBAN+'"}');
            httpRequest.setHeader('x-canary', 'cbs');
            
            // Set timeout if Alburaq region
            if (data.regionName != null && data.regionName.toLowerCase().contains('alburaq')) {
                httpRequest.setTimeout(60000);
                System.debug('Alburaq region detected, timeout set to 60000ms');
            }
            
            // Set headers
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
            
            System.debug('Request Endpoint: ' + httpRequest.getEndpoint());
            System.debug('Request Method: ' + httpRequest.getMethod());
            
            // Make HTTP callout
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            
            // Get response details
            httpStatusCode = httpResponse.getStatusCode();
            responseBody = httpResponse.getBody();
            
            System.debug('HTTP Status Code: ' + httpStatusCode);
            System.debug('Response Body: ' + responseBody);
            
            // Store System Action data for later creation (no DML here)
            SystemActionData actionData = new SystemActionData(
                'IBAN: ' + data.payrollDebitAccountIBAN,
                responseBody,
                endpoint,
                'POST',
                data.cif,
                data.customerId,
                data.recordId,
                httpStatusCode,
                'Account Balance Check',
                'WPS Payroll'
            );
            
            if (httpStatusCode >= 200 && httpStatusCode < 300) {
                // Parse response to get available balance
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
                Map<String, Object> accountMap = (Map<String, Object>)dataMap.get('account');
                
                Decimal availableBalance = (Decimal)accountMap.get('availableBalance');
                System.debug('Available Balance: ' + availableBalance);
                
                // Check if payroll amount is less than or equal to available balance
                Boolean isBalanceSufficient = (data.payrollAmount <= availableBalance);
                
                return new AccountBalanceResponse(true, isBalanceSufficient, availableBalance, null, actionData);
            } else {
                String errorMsg = 'HTTP Error: ' + httpStatusCode + ' - ' + httpResponse.getStatus();
                System.debug(errorMsg);
                if(Test.isRunningTest()) {
                    actionData = null;
                }
                return new AccountBalanceResponse(false, false, 0, errorMsg, actionData);
            }
            
        } catch (Exception e) {
            System.debug('Exception in validateAccountBalance: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            
            // Store System Action data for exception
            SystemActionData actionData = new SystemActionData(
                'IBAN: ' + data.payrollDebitAccountIBAN,
                'Exception: ' + e.getMessage(),
                ACCOUNT_DETAILS_EP,
                'POST',
                data.cif,
                data.customerId,
                data.recordId,
                500,
                'Account Balance Check',
                'WPS Payroll'
            );
            
            return new AccountBalanceResponse(false, false, 0, 'Exception occurred: ' + e.getMessage(), actionData);
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static FeesResponse getFeesDetails(PayrollData data) {
        System.debug('=== Entering getFeesDetails ===');
        System.debug('Record ID: ' + JSON.serialize(data));
        System.debug('Amount: ' + data.payrollAmount);
        System.debug('Currency: ' + data.payrollCurrency);
        
        String requestBodyJson = '';
        String responseBody = '';
        Integer httpStatusCode = 0;
        
        try {
            // Create HTTP request for fees
            HttpRequest httpRequest = new HttpRequest();
            ApiConnection apiConn = new ApiConnection();
            
            // Build endpoint
            String endpoint = FEES_EP;
            httpRequest = apiConn.createRequest('POST', endpoint, data.regionName);
            
            // Set timeout if Alburaq region
            if (data.regionName != null && data.regionName.toLowerCase().contains('alburaq')) {
                httpRequest.setTimeout(60000);
                System.debug('Alburaq region detected, timeout set to 60000ms');
            }
            
            // Prepare request body
            Map<String, Object> requestBody = new Map<String, Object>{
                'amount' => data.payrollAmount,
                    'country' => 'BH', // Assuming Bahrain, you can make this configurable
                    'currency' => data.payrollCurrency != null ? data.payrollCurrency : 'BHD',
                        'sourceAccountId' => data.payrollDebitAccountIBAN,
                        'transactionType' => 'FawriSalaryWPS',
                        'noOfRecords' => data.payrollNoOfSalaries
                        };
                            
                            requestBodyJson = JSON.serialize(requestBody);
            httpRequest.setBody(requestBodyJson);
            
            // Set headers
            httpRequest.setHeader('Content-Type', 'application/json');
            httpRequest.setHeader('customerId', data.cif);
            httpRequest.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
            
            System.debug('Request Endpoint: ' + httpRequest.getEndpoint());
            System.debug('Request Method: ' + httpRequest.getMethod());
            System.debug('Request Body: ' + requestBodyJson);
            
            // Make HTTP callout
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            
            // Get response details
            httpStatusCode = httpResponse.getStatusCode();
            responseBody = httpResponse.getBody();
            
            System.debug('HTTP Status Code: ' + httpStatusCode);
            System.debug('Response Body: ' + responseBody);
            
            // Store System Action data for later creation
            SystemActionData actionData = new SystemActionData(
                requestBodyJson,
                responseBody,
                endpoint,
                'POST',
                data.cif,
                data.customerId,
                data.recordId,
                httpStatusCode,
                'Fees Calculation',
                'WPS Payroll'
            );
            
            if (httpStatusCode >= 200 && httpStatusCode < 300) {
                // Parse response to get calculated amounts
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                Map<String, Object> dataMap = (Map<String, Object>)responseMap.get('data');
                
                Decimal calculatedAmount = (Decimal)dataMap.get('calculatedAmount');
                Decimal calculatedVAT = (Decimal)dataMap.get('calculatedVAT');
                
                System.debug('Calculated Amount: ' + calculatedAmount);
                System.debug('Calculated VAT: ' + calculatedVAT);
                
                // Create addition array for payload
                List<Map<String, Object>> addition = new List<Map<String, Object>>();
                
                if (calculatedVAT != null) {
                    addition.add(new Map<String, Object>{
                        'key' => 'VAT',
                            'value' => String.valueOf(calculatedVAT)
                            });
                }
                
                if (calculatedAmount != null) {
                    addition.add(new Map<String, Object>{
                        'key' => 'TAX',
                            'value' => String.valueOf(calculatedAmount)
                            });
                }
                
                addition.add(new Map<String, Object>{
                        'key' => 'noOfRecords',
                            'value' => String.valueOf(data.payrollNoOfSalaries)
                            });
                
                addition.add(new Map<String, Object>{
                        'key' => 'salaryMonth',
                            'value' => String.valueOf(data.payrollSalaryMonth)
                            });
                
                return new FeesResponse(true, addition, calculatedAmount, calculatedVAT, null, actionData);
            } else {
                String errorMsg = 'HTTP Error: ' + httpStatusCode + ' - ' + httpResponse.getStatus();
                System.debug(errorMsg);
                return new FeesResponse(false, null, 0, 0, errorMsg, actionData);
            }
            
        } catch (Exception e) {
            System.debug('Exception in getFeesDetails: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            
            // Store System Action data for exception
            SystemActionData actionData = new SystemActionData(
                requestBodyJson,
                'Exception: ' + e.getMessage(),
                FEES_EP,
                'POST',
                data.cif,
                data.customerId,
                data.recordId,
                500,
                'Fees Calculation',
                'WPS Payroll'
            );
            
            return new FeesResponse(false, null, 0, 0, 'Exception occurred: ' + e.getMessage(), actionData);
        }
    }
    
    public static String getEndpointForAction(String action) {
        switch on action {
            when 'Approve' {
                return PAYROLL_AUTHORIZE_EP;
            }
            when 'Reject' {
                return PAYROLL_REJECT_EP;
            }
            when 'Cancel' {
                return PAYROLL_CANCEL_EP;
            }
            when else {
                return 'Unknown Endpoint';
            }
        }
    }
    
    public static Id getQueueId(String queueName) {
        List<Group> queues = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = :queueName LIMIT 1];
        return queues.isEmpty() ? null : queues[0].Id;
    }
    
    @AuraEnabled(cacheable=true)
    public static FeesResponse calculateFees(
        String recordId,
        String regionName,
        Decimal payrollAmount,
        String payrollCurrency,
        String payrollDebitAccountIBAN,
        String payrollNoOfSalaries,
        String cif,
        String customerId
    ) {
        System.debug('=== Entering calculateFees ===');
        System.debug('Record ID: ' + recordId);
        System.debug('Region: ' + regionName);
        System.debug('Amount: ' + payrollAmount);
        System.debug('Currency: ' + payrollCurrency);
        
        try {
            // Create PayrollData object using the constructor
            PayrollData data = new PayrollData(recordId);
            
            // Set the required fields
            data.regionName = regionName;
            data.payrollAmount = payrollAmount;
            data.payrollCurrency = payrollCurrency;
            data.payrollDebitAccountIBAN = payrollDebitAccountIBAN;
            data.payrollNoOfSalaries = payrollNoOfSalaries;
            data.cif = cif;
            data.customerId = customerId;
            
            // Call the original getFeesDetails method
            FeesResponse fees = getFeesDetails(data);
            System.debug('fees --->' +fees);
            return fees;
            
        } catch(Exception e) {
            System.debug('Exception in calculateFees: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            return new FeesResponse(false, null, 0, 0, 'Exception occurred: ' + e.getMessage(), null);
        }
    }
    
    // New Queueable Class for Approve Action (with balance validation and fees calculation)
    public class WPSPayrollApproveQueueable implements Queueable, Database.AllowsCallouts {
        private List<PayrollData> payrollDataList;
        
        public WPSPayrollApproveQueueable(List<PayrollData> payrollDataList) {
            this.payrollDataList = payrollDataList;
        }
        
        public void execute(QueueableContext context) {
            System.debug('=== Executing WPSPayrollApproveQueueable ===');
            System.debug('Record count: ' + payrollDataList.size());
            
            List<WPSPayroll__c> recordsToUpdate = new List<WPSPayroll__c>();
            List<System_Action__c> systemActionsToCreate = new List<System_Action__c>();
            Map<Id, String> recordErrorMessages = new Map<Id, String>();
            
            try {
                // Process each payroll record
                for (PayrollData data : payrollDataList) {
                    String errorMessage = '';
                    Boolean processFailed = false;
                    String failureStep = '';
                    
                    try {
                        System.debug('Processing record for approval: ' + data.recordId);
                        
                        // Step 1: Validate account balance
                        AccountBalanceResponse balanceResponse = validateAccountBalance(data);
                        System.debug('balanceResponse --->'+balanceResponse);
                        
                        
                        // Add System Action data for balance check
                        if (balanceResponse.systemActionData != null) {
                            System_Action__c action = createSystemActionFromData(balanceResponse.systemActionData);
                            systemActionsToCreate.add(action);
                        }
                        System.debug('balanceResponse isSuccess--->'+(!balanceResponse.isSuccess));
                        System.debug('balanceResponse isBalanceSufficient--->'+(!balanceResponse.isBalanceSufficient));
                        
                        if (!balanceResponse.isSuccess) {
                            // Balance check API failed
                            System.debug('Balance check API failed for record: ' + data.recordId);
                            errorMessage = 'This payroll cannot be authorized, due to an issue in balance validation.';
                            failureStep = 'Balance Validation';
                            processFailed = true;
                        } else if (!balanceResponse.isBalanceSufficient) {
                            // Insufficient balance
                            System.debug('Insufficient balance for record: ' + data.recordId);
                            
                            // Create additional System Action for insufficient balance
                            SystemActionData insufficientBalanceData = new SystemActionData(
                                'Insufficient balance check',
                                'Required amount: ' + data.payrollAmount + ', Available balance: ' + balanceResponse.availableBalance,
                                ACCOUNT_DETAILS_EP,
                                'POST',
                                data.cif,
                                data.customerId,
                                data.recordId,
                                400,
                                'Insufficient Balance',
                                'WPS Payroll'
                            );
                            System_Action__c action = createSystemActionFromData(insufficientBalanceData);
                            systemActionsToCreate.add(action);
                            
                            errorMessage = 'This payroll cannot be authorized, due to insufficient funds.';
                            failureStep = 'Insufficient Balance';
                            processFailed = true;
                        }
                        
                        // Step 2: Get fees details (only if balance check passed)
                        FeesResponse feesResponse = null;
                        if (!processFailed) {
                            feesResponse = getFeesDetails(data);
                            
                            // Add System Action data for fees calculation
                            if (feesResponse.systemActionData != null) {
                                System_Action__c action = createSystemActionFromData(feesResponse.systemActionData);
                                systemActionsToCreate.add(action);
                            }
                            
                            if (!feesResponse.isSuccess) {
                                // Fees calculation failed
                                System.debug('Fees calculation failed for record: ' + data.recordId);
                                
                                // Create additional System Action for fees failure
                                SystemActionData feesFailureData = new SystemActionData(
                                    'Fees calculation failed',
                                    'Error: ' + (feesResponse.errorMessage != null ? feesResponse.errorMessage : 'Unknown error'),
                                    FEES_EP,
                                    'POST',
                                    data.cif,
                                    data.customerId,
                                    data.recordId,
                                    400,
                                    'Fees Calculation Failed',
                                    'WPS Payroll'
                                );
                                System_Action__c action = createSystemActionFromData(feesFailureData);
                                systemActionsToCreate.add(action);
                                
                                errorMessage = 'This payroll cannot be authorized, due to an issue in fees calculation.';
                                failureStep = 'Fees Calculation';
                                processFailed = true;
                            }
                        }
                        
                        // Step 3: Call payroll approve API (only if previous steps passed)
                        if (!processFailed) {
                            ApiResponse apiResponse = callPayrollApproveApi(data, feesResponse.addition);
                            
                            // Add System Action data for payroll approve call
                            if (apiResponse.systemActionData != null) {
                                System_Action__c action = createSystemActionFromData(apiResponse.systemActionData);
                                systemActionsToCreate.add(action);
                            }
                            
                            if (apiResponse.isSuccess) {
                                // All steps succeeded - mark as approved
                                WPSPayroll__c successRecord = new WPSPayroll__c(
                                    Id = data.recordId,
                                    Sub_Status__c = 'Approved',
                                    Status__c = 'Closed',
                                    Checker_Result_Date_Time__c = System.now(),
                                    Last_Api_Call_Status__c = 'Success'
                                );
                                recordsToUpdate.add(successRecord);
                                System.debug('All steps succeeded for record: ' + data.recordId);
                            } else {
                                // Approve API call failed
                                System.debug('Approve API call failed for record: ' + data.recordId);
                                errorMessage = 'This payroll cannot be authorized, due to an issue in approval API.';
                                failureStep = 'Approval API';
                                processFailed = true;
                            }
                        }
                        
                        // Create failure record if any step failed
                        if (processFailed) {
                            System.debug('Process failed for record ' + data.recordId + ' at step: ' + failureStep + ' - Error: ' + errorMessage);
                            
                            WPSPayroll__c failedRecord = new WPSPayroll__c(
                                Id = data.recordId,
                                Checker_Result__c = '', // Clear the checker result
                                Checker_Result_Date_Time__c = null, // Clear the date time
                                Last_Api_Call_Status__c = 'Failed'
                            );
                            recordsToUpdate.add(failedRecord);
                            
                            // Store error message for potential notification
                            recordErrorMessages.put(data.recordId, errorMessage + ' (Failed at: ' + failureStep + ')');
                        }
                        
                    } catch (Exception e) {
                        System.debug('Exception for record ' + data.recordId + ': ' + e.getMessage());
                        
                        // Create System Action for general exception
                        SystemActionData exceptionData = new SystemActionData(
                            'Processing exception',
                            'Exception: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString(),
                            PAYROLL_AUTHORIZE_EP,
                            'POST',
                            data.cif,
                            data.customerId,
                            data.recordId,
                            500,
                            'Processing Exception',
                            'WPS Payroll'
                        );
                        System_Action__c action = createSystemActionFromData(exceptionData);
                        systemActionsToCreate.add(action);
                        
                        WPSPayroll__c failedRecord = new WPSPayroll__c(
                            Id = data.recordId,
                            Checker_Result__c = '', // Clear the checker result
                            Checker_Result_Date_Time__c = null, // Clear the date time
                            Last_Api_Call_Status__c = 'Failed'
                        );
                        recordsToUpdate.add(failedRecord);
                        
                        recordErrorMessages.put(data.recordId, 'This payroll cannot be authorized, due to an issue in processing.');
                    }
                }
                
                // Create all System Action records
                if (!systemActionsToCreate.isEmpty()) {
                    insert systemActionsToCreate;
                    System.debug('Created ' + systemActionsToCreate.size() + ' System Action records');
                }
                
                // Update all records (both success and failure)
                if (!recordsToUpdate.isEmpty()) {
                    // Use Database.update with allOrNone = false to ensure partial success
                    List<Database.SaveResult> updateResults = Database.update(recordsToUpdate, false);
                    
                    // Check for any update failures
                    for (Integer i = 0; i < updateResults.size(); i++) {
                        Database.SaveResult sr = updateResults[i];
                        if (!sr.isSuccess()) {
                            System.debug('Failed to update record ' + recordsToUpdate[i].Id + ': ' + 
                                         sr.getErrors()[0].getMessage());
                        } else {
                            System.debug('Successfully updated record: ' + recordsToUpdate[i].Id);
                        }
                    }
                    
                    System.debug('Processed ' + recordsToUpdate.size() + ' records');
                    
                    // Send notifications if there were failures
                    if (!recordErrorMessages.isEmpty()) {
                        sendFailureNotifications(recordErrorMessages);
                    }
                    
                } else {
                    System.debug('No records to update in this batch');
                }
                
            } catch (Exception e) {
                System.debug('Queueable execution failed: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
                
                // Try to create at least one System Action for the queueable failure
                try {
                    if (payrollDataList != null && !payrollDataList.isEmpty()) {
                        PayrollData firstRecord = payrollDataList[0];
                        System_Action__c action = new System_Action__c();
                        action.Account_Number__c = firstRecord.customerId;
                        action.Action__c = 'Approve Queueable Failed';
                        action.Account__c = firstRecord.customerId;
                        action.Endpoint__c = PAYROLL_AUTHORIZE_EP;
                        action.Method__c = 'POST';
                        action.HTTP_Response_Code__c = 500;
                        action.Origin__c = 'CRM';
                        action.Request_Body__c = 'Queueable processing failed';
                        action.Response_Body__c = 'Queueable Error: ' + e.getMessage();
                        action.Target__c = 'Orchestration Layer';
                        action.Type__c = 'WPS Payroll';
                        action.WPSPayroll__c = firstRecord.recordId;
                        
                        insert action;
                        
                        // Also update the record to reflect failure
                        WPSPayroll__c failedRecord = new WPSPayroll__c(
                            Id = firstRecord.recordId,
                            Checker_Result__c = '',
                            Checker_Result_Date_Time__c = null,
                            Last_Api_Call_Status__c = 'Failed'
                        );
                        update failedRecord;
                    }
                } catch (Exception saEx) {
                    System.debug('Failed to create System Action for queueable failure: ' + saEx.getMessage());
                }
            }
        }
        
        private ApiResponse callPayrollApproveApi(PayrollData data, List<Map<String, Object>> addition) {
            System.debug('=== Entering callPayrollApproveApi for Queueable ===');
            System.debug('Record ID: ' + data.recordId);
            
            String requestBodyJson = '';
            String responseBody = '';
            Integer httpStatusCode = 0;
            
            try {
                // Create HTTP request
                HttpRequest httpRequest = new HttpRequest();
                ApiConnection apiConn = new ApiConnection();
                httpRequest = apiConn.createRequest('POST', PAYROLL_AUTHORIZE_EP, data.regionName);
                
                // Set timeout for Alburaq region
                if (data.regionName != null && data.regionName.toLowerCase().contains('alburaq')) {
                    httpRequest.setTimeout(60000);
                    System.debug('Alburaq region detected, timeout set to 60000ms');
                }
                
                // Prepare request body with addition field
                Map<String, Object> requestBody = new Map<String, Object>{
                    'payrollId' => data.payrollReference,
                        'debitIBAN' => data.payrollDebitAccountIBAN,
                        'totalAmount' => data.payrollAmount
                        };
                            
                            // Add addition array if available
                            if (addition != null && !addition.isEmpty()) {
                                requestBody.put('addition', addition);
                            }
                
                requestBodyJson = JSON.serialize(requestBody);
                httpRequest.setBody(requestBodyJson);
                
                // Set headers
                httpRequest.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
                httpRequest.setHeader('customerId', data.customerId);
                httpRequest.setHeader('Content-Type', 'application/json');
                
                System.debug('Request Body => ' + requestBodyJson);
                
                // Make HTTP callout
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                
                // Get response details
                httpStatusCode = httpResponse.getStatusCode();
                responseBody = httpResponse.getBody();
                
                System.debug('HTTP Status Code: ' + httpStatusCode);
                System.debug('Response Body: ' + responseBody);
                
                // Create System Action data object (no DML yet)
                SystemActionData actionData = new SystemActionData(
                    requestBodyJson,
                    responseBody,
                    PAYROLL_AUTHORIZE_EP,
                    'POST',
                    data.cif,
                    data.customerId,
                    data.recordId,
                    httpStatusCode,
                    'Approve',
                    'WPS Payroll'
                );
                
                // Parse response for success/failure determination
                if (httpStatusCode >= 200 && httpStatusCode < 300) {
                    try {
                        Map<String, Object> responseData = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                        System.debug('Parsed responseData => ' + responseData);
                        
                        // Extract meta
                        Map<String, Object> meta = (Map<String, Object>)responseData.get('meta');
                        
                        if (meta == null) {
                            // No meta → treat as failure
                            String errorMsg = 'Invalid API response: missing meta section';
                            System.debug(errorMsg);
                            return new ApiResponse(false, errorMsg, actionData);
                        }
                        
                        // Extract fields
                        String code = String.valueOf(meta.get('code'));
                        String message = String.valueOf(meta.get('message'));
                        
                        System.debug('API Code => ' + code);
                        System.debug('API Message => ' + message);
                        
                        // Success only when code = WPS-1000
                        if (code == 'WPS-1000') {
                            System.debug('Approve action completed successfully');
                            return new ApiResponse(true, null, actionData);
                        } else {
                            // Failure case
                            String errorMsg = 'API returned failure code: ' + code;
                            
                            if (String.isNotBlank(message)) {
                                errorMsg += ' - ' + message;
                            }
                            
                            System.debug(errorMsg);
                            return new ApiResponse(false, errorMsg, actionData);
                        }
                        
                    } catch (Exception parseEx) {
                        System.debug('Error parsing response: ' + parseEx.getMessage());
                        return new ApiResponse(false, 'Failed to parse API response', actionData);
                    }
                } else {
                    System.debug('HTTP call failed with status: ' + httpStatusCode);
                    return new ApiResponse(false, 'HTTP Error: ' + httpStatusCode, actionData);
                }
                
            } catch (Exception e) {
                System.debug('Exception in callPayrollApproveApi: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
                
                // Create System Action data for exception
                SystemActionData actionData = new SystemActionData(
                    requestBodyJson,
                    'Exception: ' + e.getMessage(),
                    PAYROLL_AUTHORIZE_EP,
                    'POST',
                    data.cif,
                    data != null ? data.customerId : 'Unknown',
                    data != null ? data.recordId : null,
                    500,
                    'Approve',
                    'WPS Payroll'
                );
                
                return new ApiResponse(false, 'Exception occurred: ' + e.getMessage(), actionData);
            }
        }
    }
    
    public static void sendFailureNotifications(Map<Id, String> errorMessages) {
        System.debug('Sending failure notifications for ' + errorMessages.size() + ' records');
        
        List<WPS_Payroll_Error__e> errorEvents = new List<WPS_Payroll_Error__e>();
        String currentUserId = UserInfo.getUserId();
        
        for (Id recordId : errorMessages.keySet()) {
            errorEvents.add(new WPS_Payroll_Error__e(
                RecordId__c = recordId,
                ErrorMessage__c = errorMessages.get(recordId),
                UserId__c = currentUserId // Optional: can be used to target specific users
            ));
        }
        
        if (!errorEvents.isEmpty()) {
            // Publish platform events
            List<Database.SaveResult> results = EventBus.publish(errorEvents);
            
            // Log the results
            for (Integer i = 0; i < results.size(); i++) {
                Database.SaveResult sr = results[i];
                if (!sr.isSuccess()) {
                    for (Database.Error err : sr.getErrors()) {
                        System.debug('Error publishing event: ' + err.getMessage());
                    }
                } else {
                    System.debug('Successfully published error event for record: ' + errorEvents[i].RecordId__c);
                }
            }
        }
    }
    
    public class WPSPayrollQueueable implements Queueable, Database.AllowsCallouts {
        private String action;
        private List<PayrollData> payrollDataList;
        
        public WPSPayrollQueueable(String action, List<PayrollData> payrollDataList) {
            this.action = action;
            this.payrollDataList = payrollDataList;
        }
        
        public void execute(QueueableContext context) {
            System.debug('=== Executing WPSPayrollQueueable ===');
            System.debug('Action: ' + action);
            System.debug('Record count: ' + payrollDataList.size());
            
            List<WPSPayroll__c> recordsToUpdate = new List<WPSPayroll__c>();
            List<System_Action__c> systemActionsToCreate = new List<System_Action__c>();
            Map<Id, String> recordErrorMessages = new Map<Id, String>();
            
            try {
                // Process each payroll record
                for (PayrollData data : payrollDataList) {
                    String errorMessage = '';
                    Boolean processFailed = false;
                    String failureStep = '';
                    
                    try {
                        System.debug('Processing record: ' + data.recordId);
                        
                        // STEP 1: Call getPayrollDetailandSalaries API first
                        System.debug('=== Calling getPayrollDetailandSalaries API ===');
                        PayrollController.PayrollDetailWrapper payrollDetails = null;
                        
                        try {
                            payrollDetails = PayrollController.getPayrollDetailandSalaries(
                                data.cif, 
                                data.regionName, 
                                data.payrollReference, 
                                null // recordId is null as per requirement
                            );
                            
                            if (payrollDetails == null) {
                                System.debug('Payroll details API returned null');
                                errorMessage = 'This payroll cannot be ' + action.toLowerCase() + 'ed, due to failure in retrieving payroll details.';
                                failureStep = 'Get Payroll Details API';
                                processFailed = true;
                            } else {
                                System.debug('Payroll details retrieved successfully. Employee count: ' + 
                                             (payrollDetails.salaries != null ? payrollDetails.salaries.size() : 0));
                            }
                        } catch (Exception apiEx) {
                            System.debug('Exception in getPayrollDetailandSalaries: ' + apiEx.getMessage());
                            
                            // Create System Action for payroll details API failure
                            SystemActionData apiFailureData = new SystemActionData(
                                'CustomerId: ' + data.customerId + ', Region: ' + data.regionName + ', Reference: ' + data.payrollReference,
                                'Exception: ' + apiEx.getMessage() + ' | Stack Trace: ' + apiEx.getStackTraceString(),
                                'Payroll Details Endpoint', // You might want to get the actual endpoint from PayrollController
                                'GET',
                                data.cif,
                                data.customerId,
                                data.recordId,
                                500,
                                'Get Payroll Details',
                                'WPS Payroll'
                            );
                            System_Action__c apiActionRecord = createSystemActionFromData(apiFailureData);
                            systemActionsToCreate.add(apiActionRecord);
                            
                            errorMessage = 'This payroll cannot be ' + action.toLowerCase() + 'ed, due to failure in retrieving payroll details.';
                            failureStep = 'Get Payroll Details API';
                            processFailed = true;
                        }
                        
                        // Only proceed with the main API call if payroll details were successfully retrieved
                        if (!processFailed) {
                            // STEP 2: Make main API call with enhanced payload
                            ApiResponse apiResponse = callPayrollApi(data, payrollDetails);
                            
                            System.debug('callPayrollApi apiResponse --->'+apiResponse);
                            
                            // Add System Action data
                            if (apiResponse.systemActionData != null) {
                                System_Action__c actionRecord = createSystemActionFromData(apiResponse.systemActionData);
                                systemActionsToCreate.add(actionRecord);
                            }
                            
                            if (apiResponse.isSuccess) {
                                // Update record status for success
                                WPSPayroll__c successRecord = new WPSPayroll__c(
                                    Id = data.recordId,
                                    Status__c = 'Closed',
                                    Checker_Result_Date_Time__c = System.now(),
                                    Last_Api_Call_Status__c = 'Success'
                                );
                                
                                if (action == 'Reject') {
                                    successRecord.Sub_Status__c = 'Rejected';
                                } else if (action == 'Cancel') {
                                    successRecord.Sub_Status__c = 'Cancelled';
                                } else if (action == 'Approve') {
                                    successRecord.Sub_Status__c = 'Approved';
                                }
                                
                                recordsToUpdate.add(successRecord);
                                System.debug(action + ' action successful for record: ' + data.recordId);
                            } else {
                                // API call failed
                                System.debug(action + ' action failed for record: ' + data.recordId);
                                errorMessage = 'This payroll cannot be ' + action.toLowerCase() + 'ed, due to API failure.';
                                failureStep = action + ' API';
                                processFailed = true;
                            }
                        }
                        
                        // Create failure record if any step failed
                        if (processFailed) {
                            System.debug('Process failed for record ' + data.recordId + ' at step: ' + failureStep + ' - Error: ' + errorMessage);
                            
                            WPSPayroll__c failedRecord = new WPSPayroll__c(
                                Id = data.recordId,
                                Checker_Result__c = '', // Clear the checker result
                                Checker_Result_Date_Time__c = null, // Clear the date time
                                Last_Api_Call_Status__c = 'Failed'
                            );
                            recordsToUpdate.add(failedRecord);
                            
                            // Store error message for notification
                            recordErrorMessages.put(data.recordId, errorMessage + ' (Failed at: ' + failureStep + ')');
                        }
                        
                    } catch (Exception e) {
                        System.debug('Exception for record ' + data.recordId + ': ' + e.getMessage());
                        
                        // Create System Action for exception
                        SystemActionData exceptionData = new SystemActionData(
                            'Processing exception',
                            'Exception: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString(),
                            getEndpointForAction(action),
                            'POST',
                            data.cif,
                            data.customerId,
                            data.recordId,
                            500,
                            action,
                            'WPS Payroll'
                        );
                        System_Action__c actionRecord = createSystemActionFromData(exceptionData);
                        systemActionsToCreate.add(actionRecord);
                        
                        WPSPayroll__c failedRecord = new WPSPayroll__c(
                            Id = data.recordId,
                            Checker_Result__c = '', // Clear the checker result
                            Checker_Result_Date_Time__c = null, // Clear the date time
                            Last_Api_Call_Status__c = 'Failed'
                        );
                        recordsToUpdate.add(failedRecord);
                        
                        recordErrorMessages.put(data.recordId, 'This payroll cannot be ' + action.toLowerCase() + 'ed, due to an issue in processing.');
                    }
                }
                
                // Create all System Action records AFTER all callouts are complete
                if (!systemActionsToCreate.isEmpty()) {
                    insert systemActionsToCreate;
                    System.debug('Created ' + systemActionsToCreate.size() + ' System Action records');
                }
                
                // Update all records (both success and failure)
                if (!recordsToUpdate.isEmpty()) {
                    // Use Database.update with allOrNone = false to ensure partial success
                    List<Database.SaveResult> updateResults = Database.update(recordsToUpdate, false);
                    
                    // Check for any update failures
                    for (Integer i = 0; i < updateResults.size(); i++) {
                        Database.SaveResult sr = updateResults[i];
                        if (!sr.isSuccess()) {
                            System.debug('Failed to update record ' + recordsToUpdate[i].Id + ': ' + 
                                         sr.getErrors()[0].getMessage());
                        } else {
                            System.debug('Successfully updated record: ' + recordsToUpdate[i].Id);
                        }
                    }
                    
                    System.debug('Processed ' + recordsToUpdate.size() + ' records');
                    
                    // Send notifications if there were failures
                    if (!recordErrorMessages.isEmpty()) {
                        sendFailureNotifications(recordErrorMessages, action);
                    }
                    
                } else {
                    System.debug('No records to update in this batch');
                }
                
            } catch (Exception e) {
                System.debug('Queueable execution failed: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
                
                // Try to create at least one System Action for the queueable failure
                try {
                    if (payrollDataList != null && !payrollDataList.isEmpty()) {
                        PayrollData firstRecord = payrollDataList[0];
                        System_Action__c actionRecord = new System_Action__c();
                        actionRecord.Account_Number__c = firstRecord.customerId;
                        actionRecord.Action__c = action + ' Queueable Failed';
                        actionRecord.Account__c = firstRecord.customerId;
                        actionRecord.Endpoint__c = getEndpointForAction(action);
                        actionRecord.Method__c = 'POST';
                        actionRecord.HTTP_Response_Code__c = 500;
                        actionRecord.Origin__c = 'CRM';
                        actionRecord.Request_Body__c = 'Queueable processing failed';
                        actionRecord.Response_Body__c = 'Queueable Error: ' + e.getMessage();
                        actionRecord.Target__c = 'Orchestration Layer';
                        actionRecord.Type__c = 'WPS Payroll';
                        actionRecord.WPSPayroll__c = firstRecord.recordId;
                        
                        insert actionRecord;
                        
                        // Also update the record to reflect failure
                        WPSPayroll__c failedRecord = new WPSPayroll__c(
                            Id = firstRecord.recordId,
                            Checker_Result__c = '',
                            Checker_Result_Date_Time__c = null,
                            Last_Api_Call_Status__c = 'Failed'
                        );
                        update failedRecord;
                    }
                } catch (Exception saEx) {
                    System.debug('Failed to create System Action for queueable failure: ' + saEx.getMessage());
                }
            }
        }
        
        private ApiResponse callPayrollApi(PayrollData data, PayrollController.PayrollDetailWrapper payrollDetails) {
            System.debug('=== Entering callPayrollApi for Queueable ===');
            System.debug('Action: ' + action + ', Record ID: ' + data.recordId);
            
            String requestBodyJson = '';
            String responseBody = '';
            Integer httpStatusCode = 0;
            String endpoint = '';
            
            try {
                // Determine endpoint
                switch on action {
                    when 'Approve' {
                        endpoint = PAYROLL_AUTHORIZE_EP;
                    }
                    when 'Reject' {
                        endpoint = PAYROLL_REJECT_EP;
                    }
                    when 'Cancel' {
                        endpoint = PAYROLL_CANCEL_EP;
                    }
                    when else {
                        throw new IllegalArgumentException('Invalid action: ' + action);
                    }
                }
                
                System.debug('Selected endpoint: ' + endpoint);
                
                // Create HTTP request
                HttpRequest httpRequest = new HttpRequest();
                ApiConnection apiConn = new ApiConnection();
                httpRequest = apiConn.createRequest('POST', endpoint, data.regionName);
                
                // Set timeout for Alburaq region
                if (data.regionName != null && data.regionName.toLowerCase().contains('alburaq')) {
                    httpRequest.setTimeout(60000);
                    System.debug('Alburaq region detected, timeout set to 60000ms');
                }
                
                // Prepare enhanced request body
                Map<String, Object> requestBody = new Map<String, Object>{
                    'payrollId' => data.payrollReference,
                        'debitIBAN' => data.payrollDebitAccountIBAN,
                        'totalAmount' => data.payrollAmount
                        };
                            
                            // Add listOfSalaries based on payrollDetails
                            List<Map<String, String>> listOfSalaries = new List<Map<String, String>>();
                
                if (payrollDetails != null && payrollDetails.salaries != null && !payrollDetails.salaries.isEmpty()) {
                    System.debug('Processing ' + payrollDetails.salaries.size() + ' salary records');
                    
                    for (PayrollController.SalaryWrapper salary : payrollDetails.salaries) {
                        Map<String, String> salaryEntry = new Map<String, String>();
                        
                        // Add recordNo if available
                        if (String.isNotBlank(salary.recordNo)) {
                            salaryEntry.put('recordNo', salary.recordNo);
                        }
                        
                        // Add errorCode for Reject or Cancel actions
                        if (action == 'Reject' || action == 'Cancel') {
                            salaryEntry.put('errorCode', data.payrollReason);
                        }
                        
                        listOfSalaries.add(salaryEntry);
                    }
                } else {
                    System.debug('No salary records found or empty list');
                    // Create a single entry without recordNo as per requirement
                    Map<String, String> salaryEntry = new Map<String, String>();
                    
                    if (action == 'Reject' || action == 'Cancel') {
                        salaryEntry.put('errorCode', data.payrollReason);
                    }
                    
                    listOfSalaries.add(salaryEntry);
                }
                
                // Add listOfSalaries to request body
                requestBody.put('listOfSalaries', listOfSalaries);
                
                // Add errorDescription for Reject or Cancel actions
                if (action == 'Reject' || action == 'Cancel') {
                    requestBody.put('errorCode', data.payrollReason);
                    requestBody.put('errorDescription', '');
                }
                
                requestBodyJson = JSON.serialize(requestBody);
                httpRequest.setBody(requestBodyJson);
                
                // Set headers
                httpRequest.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
                httpRequest.setHeader('customerId', data.customerId);
                httpRequest.setHeader('Content-Type', 'application/json');
                
                System.debug('Request Body => ' + requestBodyJson);
                
                // Make HTTP callout
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                
                // Get response details
                httpStatusCode = httpResponse.getStatusCode();
                responseBody = httpResponse.getBody();
                
                System.debug('HTTP Status Code: ' + httpStatusCode);
                System.debug('Response Body: ' + responseBody);
                
                // Create System Action data object (no DML yet)
                SystemActionData actionData = new SystemActionData(
                    requestBodyJson,
                    responseBody,
                    endpoint,
                    'POST',
                    data.cif,
                    data.customerId,
                    data.recordId,
                    httpStatusCode,
                    action,
                    'WPS Payroll'
                );
                
                // Parse response for success/failure determination
                if (httpStatusCode >= 200 && httpStatusCode < 300) {
                    try {
                        Map<String, Object> responseData = 
                            (Map<String, Object>)JSON.deserializeUntyped(responseBody);
                        System.debug('Parsed responseData => ' + responseData);
                        
                        // Extract meta object
                        Map<String, Object> meta = 
                            (Map<String, Object>) responseData.get('meta');
                        
                        String status = meta != null ? String.valueOf(meta.get('code')) : null;
                        String message = meta != null ? String.valueOf(meta.get('message')) : null;
                        
                        System.debug('API Status Code => ' + status);
                        System.debug('API Message    => ' + message);
                        
                        // SUCCESS CONDITIONS
                        if (status == 'WPS-1000' || status == 'Success' || status == 'true') {
                            System.debug('Action "' + action + '" completed successfully');
                            return new ApiResponse(true, null, actionData);
                        } 
                        // FAILURE BLOCK
                        else {
                            String errorMsg = 'API returned failure status: ' + status;
                            if (String.isNotBlank(message)) {
                                errorMsg += ' - ' + message;
                            }
                            System.debug(errorMsg);
                            return new ApiResponse(false, errorMsg, actionData);
                        }
                        
                    } catch (Exception parseEx) {
                        System.debug('Error parsing API response: ' + parseEx.getMessage());
                        return new ApiResponse(false, 'Failed to parse API response', actionData);
                    }
                } 
                else {
                    System.debug('HTTP call failed with status: ' + httpStatusCode);
                    return new ApiResponse(false, 'HTTP Error: ' + httpStatusCode, actionData);
                }
                
            } catch (Exception e) {
                System.debug('Exception in callPayrollApi: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
                
                // Create System Action data for exception
                SystemActionData actionData = new SystemActionData(
                    requestBodyJson,
                    'Exception: ' + e.getMessage(),
                    endpoint,
                    'POST',
                    data.cif,
                    data != null ? data.customerId : 'Unknown',
                    data != null ? data.recordId : null,
                    500,
                    action,
                    'WPS Payroll'
                );
                
                return new ApiResponse(false, 'Exception occurred: ' + e.getMessage(), actionData);
            }
        }
    }
    
    public static void sendFailureNotifications(Map<Id, String> errorMessages, String actionType) {
        System.debug('Sending failure notifications for ' + errorMessages.size() + ' ' + actionType + ' failures');
        
        List<WPS_Payroll_Error__e> errorEvents = new List<WPS_Payroll_Error__e>();
        
        for (Id recordId : errorMessages.keySet()) {
            String errorMsg = errorMessages.get(recordId);
            String actionDisplay = actionType + ' Failed';
            
            errorEvents.add(new WPS_Payroll_Error__e(
                RecordId__c = recordId,
                ErrorMessage__c = actionDisplay + ': ' + errorMsg
            ));
        }
        
        if (!errorEvents.isEmpty()) {
            try {
                List<Database.SaveResult> results = EventBus.publish(errorEvents);
                
                // Log publishing results
                Integer successCount = 0;
                for (Database.SaveResult sr : results) {
                    if (sr.isSuccess()) {
                        successCount++;
                    } else {
                        for (Database.Error err : sr.getErrors()) {
                            System.debug('Error publishing Platform Event: ' + err.getMessage());
                        }
                    }
                }
                
                System.debug('Published ' + successCount + ' error notification(s) for ' + actionType + ' action');
                
            } catch (Exception e) {
                System.debug('Exception publishing Platform Events for ' + actionType + ': ' + e.getMessage() + 
                             '\nStack Trace: ' + e.getStackTraceString());
            }
        }
    }
    
    // Helper method to create System Action record from data object
    public static System_Action__c createSystemActionFromData(SystemActionData data) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = data.custId;
        action.Action__c = data.strAction;
        action.Account__c = data.custId;
        action.Endpoint__c = data.path;
        action.Method__c = data.method;
        action.HTTP_Response_Code__c = data.statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = data.reqBody;
        action.Response_Body__c = data.resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = data.strType;
        action.WPSPayroll__c = data.wpsPayrollId;
        
        return action;
    }
    
    // Data container class for System Action information
    public class SystemActionData {
        @AuraEnabled public String reqBody;
        @AuraEnabled public String resBody;
        @AuraEnabled public String path;
        @AuraEnabled public String method;
        @AuraEnabled public String cif;
        @AuraEnabled public String custId;
        @AuraEnabled public Id wpsPayrollId;
        @AuraEnabled public Integer statCode;
        @AuraEnabled public String strAction;
        @AuraEnabled public String strType;
        
        public SystemActionData(String reqBody, String resBody, String path, String method, 
                                String cif, String custId, Id wpsPayrollId, Integer statCode, 
                                String strAction, String strType) {
                                    this.reqBody = reqBody;
                                    this.resBody = resBody;
                                    this.path = path;
                                    this.method = method;
                                    this.cif = cif;
                                    this.custId = custId;
                                    this.wpsPayrollId = wpsPayrollId;
                                    this.statCode = statCode;
                                    this.strAction = strAction;
                                    this.strType = strType;
                                }
    }
    
    // Response Classes
    public class AccountBalanceResponse {
        public Boolean isSuccess;
        public Boolean isBalanceSufficient;
        public Decimal availableBalance;
        public String errorMessage;
        public SystemActionData systemActionData;
        
        public AccountBalanceResponse(Boolean isSuccess, Boolean isBalanceSufficient, Decimal availableBalance, 
                                      String errorMessage, SystemActionData systemActionData) {
                                          this.isSuccess = isSuccess;
                                          this.isBalanceSufficient = isBalanceSufficient;
                                          this.availableBalance = availableBalance;
                                          this.errorMessage = errorMessage;
                                          this.systemActionData = systemActionData;
                                      }
    }
    
    public class FeesResponse {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public List<Map<String, Object>> addition;
        @AuraEnabled public Decimal calculatedAmount;
        @AuraEnabled public Decimal calculatedVAT;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public SystemActionData systemActionData;
        
        public FeesResponse(Boolean isSuccess, List<Map<String, Object>> addition, Decimal calculatedAmount, 
                            Decimal calculatedVAT, String errorMessage, SystemActionData systemActionData) {
                                this.isSuccess = isSuccess;
                                this.addition = addition;
                                this.calculatedAmount = calculatedAmount;
                                this.calculatedVAT = calculatedVAT;
                                this.errorMessage = errorMessage;
                                this.systemActionData = systemActionData;
                            }
    }
    
    public class ApiResponse {
        public Boolean isSuccess;
        public String errorMessage;
        public SystemActionData systemActionData;
        
        public ApiResponse(Boolean isSuccess, String errorMessage, SystemActionData systemActionData) {
            this.isSuccess = isSuccess;
            this.errorMessage = errorMessage;
            this.systemActionData = systemActionData;
        }
    }
    
    public class PayrollData {
        @AuraEnabled public Id recordId { get; set; }
        @AuraEnabled public String makerResult { get; set; }
        @AuraEnabled public String checkerResult { get; set; }
        @AuraEnabled public String payrollAction { get; set; }
        @AuraEnabled public String uniquePayrollId { get; set; }
        @AuraEnabled public String cif { get; set; }
        @AuraEnabled public String customerId { get; set; }
        @AuraEnabled public String payrollReference { get; set; }
        @AuraEnabled public String payrollReason { get; set; }
        @AuraEnabled public String regionName { get; set; }
        @AuraEnabled public Decimal payrollTotalDebitAmount { get; set; }
        @AuraEnabled public Decimal payrollDebitAccountBalance { get; set; }
        
        // Payroll fields
        @AuraEnabled public Decimal payrollAmount { get; set; }
        @AuraEnabled public String payrollCurrency { get; set; }
        @AuraEnabled public String payrollDebitAccountIBAN { get; set; }
        @AuraEnabled public String payrollEmployerName { get; set; }
        @AuraEnabled public String payrollNoOfSalaries { get; set; }
        @AuraEnabled public String payrollPaymentDate { get; set; }
        @AuraEnabled public String payrollSalaryMonth { get; set; }
        @AuraEnabled public String payrollStatus { get; set; }
        @AuraEnabled public Decimal payrollTransactionFees { get; set; }
        @AuraEnabled public Decimal payrollVAT { get; set; }
        @AuraEnabled public String payrollCreationDate { get; set; }
        
        public PayrollData(Id recordId) {
            this.recordId = recordId;
        }
    }
}