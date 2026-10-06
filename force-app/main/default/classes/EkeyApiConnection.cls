public class EkeyApiConnection {
    /**
     * Makes a callout and processes the response with standardized error handling
     * Returns a map with 'success' and 'data' fields matching your Aura expectations
     * @param req The HTTP request to send
     * @param action Optional System_Action__c record for logging
     * @return Map<String, Object> with success flag and data/error message
     */
    public Map<String, Object> makeCalloutAndProcessResponse(final HttpRequest req, final System_Action__c action) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            System.debug('Callout start time: ' + System.now());
            
            // Make the callout
            final Http http = new Http();
            final HTTPResponse res = http.send(req);
            
            System.debug('Callout end time: ' + System.now());
            System.debug('Request Body: ' + req.getBody());
            System.debug('Response Status Code: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody());
            
            // Log the response if action is provided
            if (null != action) {
                SystemActionLogger.logResponse(res, action);
            }
            
            // Process the response for Aura
            return processApiResponse(res);
            
        } catch (Exception e) {
            System.debug('Exception in callout: ' + e.getMessage());
            result.put('success', false);
            result.put('message', 'System error occurred while making API call: ' + e.getMessage());
            return result;
        }
    }
    
    /**
     * Overloaded method without action parameter
     */
    public Map<String, Object> makeCalloutAndProcessResponse(final HttpRequest req) {
        return makeCalloutAndProcessResponse(req, null);
    }
    
    /**
     * Processes the API response and formats it for Aura consumption
     * @param res The HTTP response
     * @return Map<String, Object> with success flag and appropriate data/message
     */
    private Map<String, Object> processApiResponse(final HTTPResponse res) {
        Map<String, Object> result = new Map<String, Object>();
        Integer statusCode = res.getStatusCode();
        
        try {
            // Parse response body
            Map<String, Object> responseMap = new Map<String, Object>();
            if (String.isNotBlank(res.getBody())) {
                responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            }
            
            // Extract meta and data
            Map<String, Object> meta = (Map<String, Object>)responseMap.get('meta');
            Map<String, Object> data = (Map<String, Object>)responseMap.get('data');
            
            String responseCode = meta != null && meta.containsKey('code') ? (String)meta.get('code') : '';
            String responseMessage = meta != null && meta.containsKey('message') ? (String)meta.get('message') : '';
            
            System.debug('Response Code: ' + responseCode);
            System.debug('Response Message: ' + responseMessage);
            
            // Handle successful response (status 200)
            if (statusCode == 200) {
                // Check if it's GOVEKEY-1003 success
                if (responseCode == 'GOVEKEY-1003') {
                    result.put('success', true);
                    result.put('data', responseMap); // Return full response map including meta and data
                    result.put('message', 'Consent registered and IGA data retrieved successfully');
                    
                    System.debug('E-Key verification SUCCESS - Full response: ' + JSON.serialize(responseMap));
                    
                } else {
                    // Other 200 responses
                    result.put('success', true);
                    result.put('data', responseMap);
                    result.put('message', responseMessage);
                }
            } else {
                // Handle error responses
                result.put('success', false);
                
                // Get appropriate error message
                String errorMessage = getErrorMessageByCode(responseCode, responseMessage, statusCode);
                result.put('message', errorMessage);
                
                // Include full response data for debugging if needed
                result.put('responseData', responseMap);
                
                System.debug('API Error - Code: ' + responseCode + ', Message: ' + errorMessage);
            }
            
        } catch (Exception e) {
            System.debug('Error processing response: ' + e.getMessage());
            result.put('success', false);
            result.put('message', 'Error processing API response: ' + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * Maps error codes to user-friendly messages
     */
    private String getErrorMessageByCode(String code, String defaultMessage, Integer statusCode) {
        // Map of error codes to messages
        Map<String, String> errorCodeMap = new Map<String, String>{
            'GOVEKEY-2003' => 'Invalid request body',
            'GOVEKEY-2004' => 'Identity or guardian validation failed',
            'GOVEKEY-2005' => 'Rate limit exceeded. Please try again later',
            'GOVEKEY-2002' => 'Beyond Connect service error. Please contact support',
            'GOVEKEY-2006' => 'ID number is required',
            'GOVEKEY-2007' => 'ID country is required',
            'GOVEKEY-2008' => 'Expiry date is required',
            'GOVEKEY-2009' => 'Date of birth is required',
            'GOVEKEY-2010' => 'Gender is required',
            'GOVEKEY-2011' => 'Nationality is required',
            'GOVEKEY-2012' => 'Consent reference is required',
            'GOVEKEY-2013' => 'Transaction reference is required',
            'GOVEKEY-2014' => 'Requestor reference is required'
        };
        
        // Check if we have a specific error message for this code
        if (String.isNotBlank(code) && errorCodeMap.containsKey(code)) {
            return errorCodeMap.get(code);
        }
        
        // Handle based on status code if no specific error code matches
        if (statusCode == 400) {
            return 'Bad request: ' + (String.isNotBlank(defaultMessage) ? defaultMessage : 'Invalid request parameters');
        } else if (statusCode == 429) {
            return 'Rate limit exceeded. Please try again later';
        } else if (statusCode >= 500) {
            return 'Server error occurred. Please try again later or contact support';
        }
        
        // Return default message if nothing else matches
        return String.isNotBlank(defaultMessage) ? defaultMessage : 'E-Key API call failed with status code: ' + statusCode;
    }
}