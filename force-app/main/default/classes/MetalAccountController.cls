public with sharing class MetalAccountController {
    @TestVisible
    private static ApiConnection con = new ApiConnection();
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMetalAccounts(
        String metalType, 
        final String customerId, 
        String regionName,
        String xCanary,
        String segment
    ) {
        Map<String, Object> defaultResponse = new Map<String, Object>{
            'success' => false,
                'accounts' => new List<Object>(),
                'message' => ''
                };
                    
                    try {
                        // Validate required parameters
                        if (String.isBlank(customerId)) {
                            defaultResponse.put('message', 'Customer ID is required');
                            return defaultResponse;
                        }
                        
                        // Build query parameters
                        String path = '/api/v1/precious-metals/accounts?segment=' + EncodingUtil.urlEncode(segment, 'UTF-8');
                        
                        // Use dynamic xCanary value instead of hardcoded 'cbs'
                        String xCanaryValue = String.isNotBlank(xCanary) ? xCanary : 'cbs';
                        
                        // Send request with timeout protection
                        HttpRequest req = con.createRequest('GET', path, customerId, regionName);
                        req.setHeader('x-canary', xCanaryValue);
                        req.setTimeout(12000); // 12 seconds timeout
                        
                        System.debug('Request ---> ' + req);
                        System.debug('x-canary header value: ' + xCanaryValue);
                        
                        Http http = new Http();
                        HttpResponse response = http.send(req);
                        System.debug('Response ---> ' + response);
                        System.debug('Response status code ---> ' + response.getStatusCode());
                        
                        // Process response
                        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                            Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                            System.debug('parsedResponse ---> ' + parsedResponse);
                            parsedResponse.put('success', true);
                            return parsedResponse;
                        } else {
                            System.debug('defaultResponse ---> ' + defaultResponse);
                            defaultResponse.put('message', 'API returned status: ' + response.getStatusCode());
                            return defaultResponse;
                        }
                        
                    } catch (JSONException je) {
                        defaultResponse.put('message', 'Invalid response format: ' + je.getMessage());
                    } catch (Exception e) {
                        defaultResponse.put('message', 'System error: ' + e.getMessage());
                    }
        System.debug('defaultResponse 2---> ' + defaultResponse);
        return defaultResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMetalTransactions(
        String metalCurrency, 
        Integer pageNumber, 
        Integer pageSize, 
        Decimal fromAmount, 
        Decimal toAmount, 
        String fromDate, 
        String toDate, 
        String tradeType, 
        final String customerId, 
        String regionName,
        String xCanary
    ) {
        // LOG: Method entry with all parameters
        System.debug('========== getMetalTransactions START ==========');
        System.debug('Parameter - metalCurrency: ' + metalCurrency);
        System.debug('Parameter - pageNumber: ' + pageNumber);
        System.debug('Parameter - pageSize: ' + pageSize);
        System.debug('Parameter - fromAmount: ' + fromAmount);
        System.debug('Parameter - toAmount: ' + toAmount);
        System.debug('Parameter - fromDate: ' + fromDate);
        System.debug('Parameter - toDate: ' + toDate);
        System.debug('Parameter - tradeType: ' + tradeType);
        System.debug('Parameter - customerId: ' + customerId);
        System.debug('Parameter - regionName: ' + regionName);
        System.debug('Parameter - xCanary: ' + xCanary);
        System.debug('Parameter - Is customerId blank? ' + String.isBlank(customerId));
        
        Map<String, Object> defaultResponse = new Map<String, Object>{
            'success' => false,
                'transactions' => new List<Object>(),
                'message' => ''
                };
                    
                    try {
                        // Validate required parameters
                        if (String.isBlank(customerId)) {
                            System.debug('ERROR: Customer ID is required - validation failed');
                            defaultResponse.put('message', 'Customer ID is required');
                            System.debug('========== getMetalTransactions END (Validation Failed) ==========');
                            return defaultResponse;
                        }
                        
                        System.debug('Customer ID validation passed');
                        
                        // Build base path
                        String path = '/api/v1/precious-metals/trades';
                        System.debug('Initial path: ' + path);
                        
                        // Build query parameters
                        List<String> params = new List<String>();
                        
                        if (String.isNotBlank(metalCurrency)) {
                            params.add('metalCurrency=' + metalCurrency);
                            System.debug('Added metalCurrency parameter: ' + metalCurrency);
                        }
                        
                        if (pageNumber != null) {
                            params.add('pageNumber=' + pageNumber);
                            System.debug('Added pageNumber parameter: ' + pageNumber);
                        } else {
                            params.add('pageNumber=1');
                            System.debug('Using default pageNumber: 1');
                        }
                        
                        if (pageSize != null) {
                            params.add('pageSize=' + pageSize);
                            System.debug('Added pageSize parameter: ' + pageSize);
                        } else {
                            params.add('pageSize=20');
                            System.debug('Using default pageSize: 20');
                        }
                        
                        if (fromAmount != null) {
                            params.add('fromAmount=' + fromAmount);
                            System.debug('Added fromAmount parameter: ' + fromAmount);
                        }
                        
                        if (toAmount != null) {
                            params.add('toAmount=' + toAmount);
                            System.debug('Added toAmount parameter: ' + toAmount);
                        }
                        
                        if (String.isNotBlank(fromDate)) {
                            params.add('fromDate=' + fromDate);
                            System.debug('Added fromDate parameter: ' + fromDate);
                        }
                        
                        if (String.isNotBlank(toDate)) {
                            params.add('toDate=' + toDate);
                            System.debug('Added toDate parameter: ' + toDate);
                        }
                        
                        if (String.isNotBlank(tradeType)) {
                            params.add('tradeType=' + tradeType);
                            System.debug('Added tradeType parameter: ' + tradeType);
                        } else {
                            params.add('tradeType=all');
                            System.debug('Using default tradeType: all');
                        }
                        
                        // Append parameters to path
                        if (!params.isEmpty()) {
                            path += '?' + String.join(params, '&');
                            System.debug('Full path with parameters: ' + path);
                        }
                        
                        // Use dynamic xCanary value
                        String xCanaryValue = String.isNotBlank(xCanary) ? xCanary : 'cbs';
                        
                        // Send request with timeout protection
                        HttpRequest req = con.createRequest('GET', path, customerId, regionName);
                        req.setHeader('x-canary', xCanaryValue);
                        req.setTimeout(12000);
                        
                        System.debug('Request Method: ' + req.getMethod());
                        System.debug('Request Endpoint: ' + req.getEndpoint());
                        System.debug('x-canary header value: ' + xCanaryValue);
                        
                        Http http = new Http();
                        HttpResponse response = http.send(req);
                        
                        System.debug('Response Status Code: ' + response.getStatusCode());
                        System.debug('Response Status: ' + response.getStatus());
                        
                        // Process response
                        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                            Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                            System.debug('Successfully parsed JSON response');
                            parsedResponse.put('success', true);
                            System.debug('========== getMetalTransactions END (Success) ==========');
                            return parsedResponse;
                        } else {
                            System.debug('ERROR: Non-200 response or empty body');
                            defaultResponse.put('message', 'API returned status: ' + response.getStatusCode());
                            System.debug('========== getMetalTransactions END (API Error) ==========');
                            return defaultResponse;
                        }
                        
                    } catch (JSONException je) {
                        System.debug('EXCEPTION: JSONException caught: ' + je.getMessage());
                        defaultResponse.put('message', 'Invalid response format: ' + je.getMessage());
                        System.debug('========== getMetalTransactions END (JSON Exception) ==========');
                        return defaultResponse;
                    } catch (Exception e) {
                        System.debug('EXCEPTION: General Exception caught: ' + e.getMessage());
                        defaultResponse.put('message', 'System error: ' + e.getMessage());
                        System.debug('========== getMetalTransactions END (System Exception) ==========');
                        return defaultResponse;
                    }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMetalStatements(
        String accountId,
        String statementType,
        final String customerId,
        String regionName,
        String xCanary
    ) {
        System.debug('========== getMetalStatements START ==========');
        System.debug('Parameter - accountId: ' + accountId);
        System.debug('Parameter - statementType: ' + statementType);
        System.debug('Parameter - customerId: ' + customerId);
        System.debug('Parameter - regionName: ' + regionName);
        System.debug('Parameter - xCanary: ' + xCanary);
        
        Map<String, Object> defaultResponse = new Map<String, Object>{
            'success' => false,
                'statements' => new List<Object>(),
                'message' => ''
                };
                    
                    try {
                        // Validate required parameters
                        if (String.isBlank(customerId)) {
                            System.debug('ERROR: Customer ID is required');
                            defaultResponse.put('message', 'Customer ID is required');
                            return defaultResponse;
                        }
                        
                        if (String.isBlank(accountId)) {
                            System.debug('ERROR: Account ID is required');
                            defaultResponse.put('message', 'Account ID is required');
                            return defaultResponse;
                        }
                        
                        // Build endpoint
                        String path = '/api/v1/statements';
                        
                        // Build request body with dynamic accountId
                        Map<String, Object> requestBodyMap = new Map<String, Object>();
                        requestBodyMap.put('accountId', accountId);
                        
                        if (String.isNotBlank(statementType)) {
                            requestBodyMap.put('statementType', statementType);
                        } else {
                            requestBodyMap.put('statementType', 'Statement');
                        }
                        
                        String requestBody = JSON.serialize(requestBodyMap);
                        System.debug('Request Body: ' + requestBody);
                        
                        // Use dynamic xCanary value
                        String xCanaryValue = String.isNotBlank(xCanary) ? xCanary : 'cbs';
                        
                        // Send request with timeout protection
                        HttpRequest req = con.createRequest('POST', path, customerId, regionName);
                        req.setBody(requestBody);
                        req.setHeader('x-canary', xCanaryValue);
                        req.setHeader('Content-Type', 'application/json');
                        req.setTimeout(12000);
                        
                        System.debug('Request Method: ' + req.getMethod());
                        System.debug('Request Endpoint: ' + req.getEndpoint());
                        System.debug('x-canary header value: ' + xCanaryValue);
                        
                        Http http = new Http();
                        HttpResponse response = http.send(req);
                        
                        System.debug('Response Status Code: ' + response.getStatusCode());
                        System.debug('Response Body: ' + response.getBody());
                        System.debug('Response Body Deserialized: ' + (Map<String, Object>) JSON.deserializeUntyped(response.getBody()));
                        
                        // Process response
                        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
                            Map<String, Object> parsedResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                            System.debug('Successfully parsed JSON response');
                            parsedResponse.put('success', true);
                            System.debug('========== getMetalStatements END (Success) ==========');
                            return parsedResponse;
                        } else {
                            defaultResponse.put('message', 'API returned status: ' + response.getStatusCode());
                            return defaultResponse;
                        }
                        
                    } catch (JSONException je) {
                        defaultResponse.put('message', 'Invalid response format: ' + je.getMessage());
                        return defaultResponse;
                    } catch (Exception e) {
                        defaultResponse.put('message', 'System error: ' + e.getMessage());
                        return defaultResponse;
                    }
    }
    
    @AuraEnabled
    public static SettingResponse getUserSettings(String userId, String customerId) {
        try {
            SettingResponse response = new SettingResponse();
            System.debug('Method --->');
            // Check if customerId is provided
            if (String.isNotBlank(customerId)) {
                // Query the Account to get Segment__pc
                System.debug('Reached --->');
                String accountQuery = 'SELECT Id, Segment__pc FROM Account WHERE Id = :customerId LIMIT 1';
                System.debug('accountQuery --->'+accountQuery);
                List<Account> accounts = Database.query(accountQuery);
                System.debug('accounts --->'+accounts);
                if (!accounts.isEmpty()) {
                    Account acc = accounts[0];
                    String segment = acc.Segment__pc;
                    
                    // If segment is 'Regular' or 'Premium', return true for both flags
                    if ('Regular'.equalsIgnoreCase(segment) || 'Premium'.equalsIgnoreCase(segment)) {
                        response.success = true;
                        response.data = new SettingData();
                        response.data.viewStaffData = true;
                        response.data.viewStaffDataJordan = true;
                        response.message = 'Regular/Premium segment - access granted';
                        return response;
                    }
                    // If segment is 'Staff', continue to check custom settings
                    else if ('Staff'.equalsIgnoreCase(segment)) {
                        // Staff segment - proceed to check custom settings
                        // Continue to custom settings logic below
                    } else {
                        // Unknown segment - fallback to custom settings
                        // Continue to custom settings logic below
                    }
                } else {
                    // No account found with this CIF - fallback to custom settings
                    // Continue to custom settings logic below
                }
            }
            
            // ============ EXISTING LOGIC FOR CUSTOM SETTINGS ============
            // This runs when:
            // 1. customerId is null
            // 2. Segment is 'Staff'
            // 3. No account found with the CIF
            // 4. Unknown segment
            
            // Query the custom setting for the specific user
            String query = 'SELECT Id, View_Staff_Data__c, View_Staff_Data_Jordan__c, SetupOwnerId ' +
                'FROM Setting__c ' +
                'WHERE SetupOwnerId = :userId ' +
                'LIMIT 1';
            
            List<Setting__c> settings = Database.query(query);
            
            if (!settings.isEmpty()) {
                Setting__c setting = settings[0];
                response.success = true;
                response.data = new SettingData();
                response.data.viewStaffData = setting.View_Staff_Data__c;
                response.data.viewStaffDataJordan = setting.View_Staff_Data_Jordan__c;
                response.message = 'Settings retrieved successfully from custom settings';
            } else {
                // No settings found for this user, return empty data
                response.success = true;
                response.data = new SettingData();
                response.data.viewStaffData = false;
                response.data.viewStaffDataJordan = false;
                response.message = 'No settings found for user, defaulting to false';
            }
            System.debug('Response --->'+response);
            return response;
            
        } catch (Exception e) {
            SettingResponse response = new SettingResponse();
            response.success = false;
            response.message = 'Error retrieving user settings: ' + e.getMessage();
            return response;
        }
    }
    
    // Inner classes for response structure
    public class SettingResponse {
        @AuraEnabled public Boolean success;
        @AuraEnabled public SettingData data;
        @AuraEnabled public String message;
    }
    
    public class SettingData {
        @AuraEnabled public Boolean viewStaffData;
        @AuraEnabled public Boolean viewStaffDataJordan;
    }
}