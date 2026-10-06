public with sharing class CacheServiceController {
    
    private static ApiConnection con = new ApiConnection();
    
    //=============================================================================
    // MAIN METHODS
    //=============================================================================
    
    @AuraEnabled
    public static Map<String, Object> processCSVFile(String contentDocumentId) {
        Map<String, Object> result = new Map<String, Object>();
        List<String> cifList = new List<String>();
        
        try {
            // Get file content
            ContentVersion contentVersion = [
                SELECT VersionData, Title, FileExtension, ContentSize
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true
                LIMIT 1
            ];
            
            String fileContent = contentVersion.VersionData.toString();
            String fileName = contentVersion.Title;
            
            // Process CSV content
            List<String> lines = fileContent.split('\n');
            
            // Validate header
            if (lines.size() < 2) {
                throw new AuraHandledException('CSV file must contain header and at least one CIF');
            }
            
            String header = lines[0].trim().replaceAll('[\\u200B-\\u200D\\uFEFF]', '');
            
            if (!header.equalsIgnoreCase('CIF')) {
                throw new AuraHandledException('CSV must have "CIF" as the first column');
            }
            
            // Process data rows
            for (Integer i = 1; i < lines.size(); i++) {
                String line = lines[i].trim();
                if (String.isBlank(line)) {
                    continue;
                }
                
                List<String> values = parseCSVLine(line);
                
                if (values.size() > 0 && String.isNotBlank(values[0])) {
                    String cif = values[0].trim();
                    if (cif.isNumeric()) {
                        cifList.add(cif);
                    }
                }
            }
            
            if (cifList.isEmpty()) {
                throw new AuraHandledException('No valid CIF numbers found in the file');
            }
            
            result.put('success', true);
            result.put('cifList', cifList);
            result.put('fileName', fileName);
            result.put('totalCount', cifList.size());
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('error', e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> clearCache(String cacheType, List<String> cifList, String fileName, String contentDocumentId) {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Validate inputs
            if (String.isBlank(cacheType)) {
                throw new AuraHandledException('Cache type is required');
            }
            if (cifList == null || cifList.isEmpty()) {
                throw new AuraHandledException('CIF list cannot be empty');
            }
            
            // Create log record
            Cache_Clearing_Log__c logRecord = new Cache_Clearing_Log__c();
            logRecord.Cache_Type__c = cacheType;
            logRecord.Total_CIFs__c = cifList.size();
            logRecord.Status__c = 'In Progress';
            logRecord.Started_By__c = UserInfo.getUserId();
            logRecord.Started_Date__c = System.now();
            logRecord.File_Name__c = fileName;
            
            Map<String, Object> requestPayload = new Map<String, Object>();
            requestPayload.put('customerIds', cifList);
            requestPayload.put('cacheType', cacheType);
            requestPayload.put('totalCIFs', cifList.size());
            logRecord.Request_Payload__c = JSON.serializePretty(requestPayload);
            
            // Insert the log record BEFORE callout
            insert logRecord;

            // Associate the ContentDocument to the Bulk_Operation__c record
            if (String.isNotBlank(contentDocumentId)) {
                ContentDocumentLink contentLink = new ContentDocumentLink(
                    ContentDocumentId = contentDocumentId,
                    LinkedEntityId = logRecord.Id,
                    ShareType = 'I'
                );
                insert contentLink;
            }
            
            // Call the async method to perform the callout
            System.enqueueJob(new CacheClearingQueueable(logRecord.Id, cacheType, cifList));
            
            result.put('success', true);
            result.put('message', 'Cache clearing process has been initiated.');
            result.put('logId', logRecord.Id);
            
        } catch (Exception e) {
            result.put('success', false);
            result.put('message', 'Failed to initiate cache clearing: ' + e.getMessage());
        }
        
        return result;
    }
    
    //=============================================================================
    // QUEUEABLE CLASS
    //=============================================================================
    
    public class CacheClearingQueueable implements Queueable, Database.AllowsCallouts {
        private Id logId;
        private String cacheType;
        private List<String> cifList;
        
        public CacheClearingQueueable(Id logId, String cacheType, List<String> cifList) {
            this.logId = logId;
            this.cacheType = cacheType;
            this.cifList = cifList;
        }
        
        public void execute(QueueableContext context) {
            List<Map<String, Object>> apiResults = new List<Map<String, Object>>();
            
            try {
                Cache_Clearing_Log__c logRecord = [
                    SELECT Id, Status__c, Total_CIFs__c 
                    FROM Cache_Clearing_Log__c 
                    WHERE Id = :logId
                    LIMIT 1
                ];
                
                // Determine which APIs to call based on cache type
                List<ApiEndpoint> endpointsToCall = getEndpoints(cacheType);
                
                Integer totalSuccess = 0;
                Integer totalFailed = 0;
                List<String> errorMessages = new List<String>();
                
                for (ApiEndpoint apiEndpoint : endpointsToCall) {
                    Map<String, Object> apiResult = callCacheAPI(apiEndpoint, cifList);
                    apiResults.add(apiResult);
                    
                    if (apiResult.containsKey('success') && (Boolean)apiResult.get('success') == true) {
                        totalSuccess++;
                    } else {
                        totalFailed++;
                        String errorMsg = apiResult.containsKey('message') ? (String)apiResult.get('message') : 'Unknown error';
                        errorMessages.add(apiEndpoint.name + ': ' + errorMsg);
                    }
                }
                
                // Update log record with results
                logRecord.Completed_Date__c = System.now();
                logRecord.Response_Details__c = JSON.serializePretty(apiResults);
                
                if (totalFailed == 0) {
                    logRecord.Status__c = 'Completed';
                    logRecord.Successful_CIFs__c = cifList.size();
                    logRecord.Failed_CIFs__c = 0;
                } else if (totalSuccess > 0) {
                    logRecord.Status__c = 'Partial Success';
                    logRecord.Successful_CIFs__c = cifList.size();
                    logRecord.Failed_CIFs__c = cifList.size();
                    logRecord.Error_Message__c = String.join(errorMessages, '; ');
                } else {
                    logRecord.Status__c = 'Failed';
                    logRecord.Successful_CIFs__c = 0;
                    logRecord.Failed_CIFs__c = cifList.size();
                    logRecord.Error_Message__c = String.join(errorMessages, '; ');
                }
                
                update logRecord;
                
            } catch (Exception e) {
                try {
                    Cache_Clearing_Log__c logRecord = new Cache_Clearing_Log__c(
                        Id = logId,
                        Status__c = 'Failed',
                        Error_Message__c = e.getMessage(),
                        Failed_CIFs__c = cifList != null ? cifList.size() : 0,
                        Completed_Date__c = System.now()
                    );
                    update logRecord;
                } catch (Exception updateEx) {
                    // Silent fail - can't log
                }
            }
        }
        
        private List<ApiEndpoint> getEndpoints(String cacheType) {
            List<ApiEndpoint> endpoints = new List<ApiEndpoint>();
            String bulkPath = '/bulk';
            String queryParams = '?language=en&unit=neo';
            
            if (cacheType == 'All') {
                endpoints.add(new ApiEndpoint(
                    'Credit Card Bulk',
                    '/api/v1/credit-cards' + bulkPath + '/customer/cache'
                ));
                endpoints.add(new ApiEndpoint(
                    'Debit Card Bulk',
                    '/api/v1/cards' + bulkPath + '/customer/cache'
                ));
            } else if (cacheType == 'Credit Card') {
                endpoints.add(new ApiEndpoint(
                    'Credit Card Bulk',
                    '/api/v1/credit-cards' + bulkPath + '/customer/cache'
                ));
            } else if (cacheType == 'Debit Card') {
                endpoints.add(new ApiEndpoint(
                    'Debit Card Bulk',
                    '/api/v1/cards' + bulkPath + '/customer/cache'
                ));
            }
            
            return endpoints;
        }
        
        private Map<String, Object> callCacheAPI(ApiEndpoint apiEndpoint, List<String> cifList) {
            Map<String, Object> result = new Map<String, Object>();
            Long startTime = DateTime.now().getTime();
            
            try {
                Http http = new Http();
                
                // Use the common createRequest method from ApiConnection
                HttpRequest request = con.createRequest('DELETE', apiEndpoint.path, 'Bahrain');
                
                // Set additional headers
                // request.setHeader('x-canary', 'pi');

                /*if(cacheType == 'Debit Card' || cacheType == 'All') {
                    request.setHeader('customerId', '6195522');
                }*/
                
                // Prepare request body
                Map<String, Object> requestBody = new Map<String, Object>();
                requestBody.put('customerIds', cifList);
                String requestBodyJson = JSON.serialize(requestBody);
                request.setBody(requestBodyJson);
                
                // Log request (minimal)
                System.debug('=== API REQUEST ===');
                System.debug('Method: ' + request.getMethod());
                System.debug('URL: ' + request.getEndpoint());
                System.debug('Headers: Content-Type=' + request.getHeader('Content-Type') + 
                           ', x-canary=' + request.getHeader('x-canary'));
                System.debug('Body: ' + requestBodyJson);
                
                // Send request
                HttpResponse response = http.send(request);
                Long endTime = DateTime.now().getTime();
                Long duration = endTime - startTime;
                
                // Log response (minimal)
                System.debug('=== API RESPONSE ===');
                System.debug('Status Code: ' + response.getStatusCode());
                System.debug('Duration: ' + duration + 'ms');
                System.debug('Body: ' + response.getBody());
                System.debug('=== END ===');
                
                result.put('apiName', apiEndpoint.name);
                result.put('endpoint', apiEndpoint.path);
                result.put('statusCode', response.getStatusCode());
                result.put('response', response.getBody());
                result.put('duration_ms', duration);
                
                if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                    result.put('success', true);
                    result.put('message', 'API call successful');
                } else {
                    result.put('success', false);
                    result.put('message', 'HTTP ' + response.getStatusCode() + ': ' + response.getBody());
                }
                
            } catch (Exception e) {
                Long endTime = DateTime.now().getTime();
                Long duration = endTime - startTime;
                
                // Log exception (minimal)
                System.debug('=== API EXCEPTION ===');
                System.debug('Error: ' + e.getMessage());
                System.debug('=== END ===');
                
                result.put('success', false);
                result.put('message', e.getMessage());
                result.put('apiName', apiEndpoint.name);
                result.put('endpoint', apiEndpoint.path);
                result.put('duration_ms', duration);
            }
            
            return result;
        }
    }
    
    //=============================================================================
    // HELPER METHODS
    //=============================================================================
    
    private static List<String> parseCSVLine(String line) {
        List<String> result = new List<String>();
        Boolean inQuotes = false;
        String currentValue = '';
        
        for (Integer i = 0; i < line.length(); i++) {
            String c = line.substring(i, i+1);
            
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ',' && !inQuotes) {
                result.add(currentValue);
                currentValue = '';
            } else {
                currentValue += c;
            }
        }
        
        result.add(currentValue);
        return result;
    }
    
    @AuraEnabled
    public static List<Cache_Clearing_Log__c> getRecentCacheLogs() {
        try {
            List<Cache_Clearing_Log__c> logs = [
                SELECT Id, Name, Cache_Type__c, Status__c, Total_CIFs__c, 
                       Successful_CIFs__c, Failed_CIFs__c, CreatedDate,
                       Started_By__r.Name, Completed_Date__c, Error_Message__c,
                       Request_Payload__c, Response_Details__c
                FROM Cache_Clearing_Log__c
                ORDER BY CreatedDate DESC
                LIMIT 20
            ];
            
            return logs;
            
        } catch (Exception e) {
            return new List<Cache_Clearing_Log__c>();
        }
    }
    
    //=============================================================================
    // INNER CLASSES
    //=============================================================================
    
    public class ApiEndpoint {
        public String name { get; set; }
        public String path { get; set; }
        
        public ApiEndpoint(String name, String path) {
            this.name = name;
            this.path = path;
        }
    }
}