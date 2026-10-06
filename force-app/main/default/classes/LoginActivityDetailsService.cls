public with sharing class LoginActivityDetailsService {

    @AuraEnabled
    public static List<LoginActivityDetailWrapper> getLatestActivityDetails(Id customerId) {
        return mapItems(LoginActivityService.fetchLatestItems(customerId, 5), null);
    }

    @AuraEnabled
    public static List<LoginActivityDetailWrapper> getRecentActivityDetails(
        Id customerId,
        Integer startDaysAgo,
        Integer daysToScan
    ) {
        LoginActivityService.FetchResult fetched = LoginActivityService.scanLoginDays(
            customerId,
            startDaysAgo,
            daysToScan
        );
        return mapItems(fetched, null);
    }

    @AuraEnabled
    public static LoginActivityDetailsResponse getLoginActivities(
        Id customerId,
        Integer pageSize,
        Integer pageNumber,
        Date fromDate,
        Date toDate,
        String channel
    ) {
        LoginActivityService.FetchResult fetched;
        if (fromDate != null && toDate != null && fromDate.daysBetween(toDate) <= 8) {
            Integer startDaysAgo = toDate.daysBetween(Date.today());
            if (startDaysAgo < 0) {
                startDaysAgo = 0;
            }
            Integer daysToScan = fromDate.daysBetween(toDate) + 1;
            fetched = LoginActivityService.scanLoginDays(customerId, startDaysAgo, daysToScan);
        } else {
            fetched = LoginActivityService.scanLoginDays(customerId, 0, 8);
        }
        List<LoginActivityDetailWrapper> filtered = mapItems(fetched, channel);

        Integer totalRecords = filtered.size();
        Integer size = (pageSize == null || pageSize < 1) ? 50 : pageSize;
        Integer current = (pageNumber == null || pageNumber < 1) ? 1 : pageNumber;
        Integer totalPages = totalRecords == 0 ? 1 : (Integer) Math.ceil((Decimal) totalRecords / size);
        if (current > totalPages) {
            current = totalPages;
        }

        List<LoginActivityDetailWrapper> pagedRecords = new List<LoginActivityDetailWrapper>();
        if (totalRecords > 0) {
            Integer startIndex = (current - 1) * size;
            Integer endIndex = Math.min(startIndex + size, totalRecords);
            for (Integer i = startIndex; i < endIndex; i++) {
                pagedRecords.add(filtered[i]);
            }
        }

        LoginActivityDetailsResponse response = new LoginActivityDetailsResponse();
        response.records = pagedRecords;
        response.totalRecords = totalRecords;
        response.currentPage = current;
        response.totalPages = totalPages;
        return response;
    }

    private static List<LoginActivityDetailWrapper> mapItems(LoginActivityService.FetchResult fetched, String channel) {
        List<LoginActivityDetailWrapper> details = new List<LoginActivityDetailWrapper>();
        Integer index = 0;
        for (Map<String, Object> item : fetched.items) {
            LoginActivityDetailWrapper detail = mapToDetail(item, fetched.region, index);
            if (String.isNotBlank(channel) && channel != 'All' && detail.result != channel) {
                index++;
                continue;
            }
            details.add(detail);
            index++;
        }
        return details;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, String> getCustomerExportInfo(Id customerId) {
        if (customerId == null) {
            throw new AuraHandledException('Customer Id is required.');
        }
        List<Account> accounts = [
            SELECT Name, CIF__pc
            FROM Account
            WHERE Id = :customerId
            LIMIT 1
        ];
        if (accounts.isEmpty()) {
            throw new AuraHandledException('Customer account was not found.');
        }
        return new Map<String, String>{
            'name' => accounts[0].Name,
            'cif' => accounts[0].CIF__pc
        };
    }

    private static LoginActivityDetailWrapper mapToDetail(Map<String, Object> item, String region, Integer index) {
        LoginActivityDetailWrapper detail = new LoginActivityDetailWrapper();
        detail.timestamp = LoginActivityService.parseTimestamp(item.get('timestamp'));
        detail.result = LoginActivityService.mapOutcome(LoginActivityService.toStringValue(item.get('outcome')));
        detail.channel = LoginActivityService.toStringValue(item.get('deviceId'));
        detail.category = LoginActivityService.toStringValue(item.get('ipAddress'));
        detail.unit = LoginActivityService.toStringValue(item.get('city'));
        if (String.isBlank(detail.unit)) {
            detail.unit = region;
        }
        detail.description = detail.result == 'Failed' ? 'Failed Login' : 'Successful Login';
        detail.errorCode = detail.result == 'Failed' ? LoginActivityService.toStringValue(item.get('errorCode')) : '';
        return detail;
    }

 @AuraEnabled(cacheable=true)
public static EmailAlignmentWrapper getEmailAlignmentDetails(Id customerId) {
    // 1. Get CRM Email and CIF
    Account c = [SELECT PersonEmail, CIF__pc FROM Account WHERE Id = :customerId LIMIT 1];
    String crmEmail = c.PersonEmail;
    String cif = c.CIF__pc;

    // 2. Get DB Email from API
    String dbEmail = null; 
    ApiConnection connection = new ApiConnection();

    HttpRequest req = connection.createRequest('GET', '/api/v1/customers/users', cif, null);
    System.debug('Alignment >>> : HttpRequest Created: ' + req);
    System.debug('Alignment >>> : Endpoint: ' + req.getEndpoint());

    // Making the callout
    ApiConnection.Response response = connection.makeCallout(req);
    System.debug('Alignment >>> : Callout Completed.');
    System.debug('Alignment >>> : Response Success: ' + response.isSuccess);

    if (response.isSuccess && response.responseData != null) {
        System.debug('Alignment >>> Response Data: ' + response.responseData);
        
        try {
            // Parse the response to extract the email
            Map<String, Object> responseMap = (Map<String, Object>) response.responseData;
            
            if (responseMap.containsKey('user')) {
                Map<String, Object> userMap = (Map<String, Object>) responseMap.get('user');
                
                if (userMap.containsKey('email')) {
                    dbEmail = (String) userMap.get('email');
                    System.debug('Alignment >>> Extracted Email: ' + dbEmail);
                }
            }
        } catch (Exception e) {
            System.debug('Error parsing response: ' + e.getMessage());
            throw new CalloutException('Failed to parse API response: ' + e.getMessage());
        }
    } else {
        System.debug('Error in Alignment >>> : ' + response.errorData);
        CalloutException e = new CalloutException();
        e.setMessage('Callout Error: ' + response.errorData);
        throw e;
    }

    // Create the wrapper with the extracted dbEmail
    EmailAlignmentWrapper result = new EmailAlignmentWrapper(crmEmail, dbEmail, cif);
    
    // 3. Get Real Counts from AccountHistory
    AggregateResult[] results = [
        SELECT Field, COUNT(Id) cnt 
        FROM AccountHistory 
        WHERE AccountId = :customerId 
        AND Field IN ('PersonEmail', 'PersonMobilePhone') 
        GROUP BY Field
    ];

    for (AggregateResult ar : results) {
        String field = (String)ar.get('Field');
        Integer count = (Integer)ar.get('cnt');
        if (field == 'PersonMobilePhone') {
            result.mobileChangeCount = count;
        } else if (field == 'PersonEmail') {
            result.emailChangeCount = count;
        }
    }
    
    return result;
}

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getMobileChangeHistory(Id customerId) {
        return getFieldHistory(customerId, 'PersonMobilePhone');
    }

    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getEmailChangeHistory(Id customerId) {
        return getFieldHistory(customerId, 'PersonEmail');
    }

    private static List<Map<String, String>> getFieldHistory(Id customerId, String fieldName) {
        List<AccountHistory> histories = [
            SELECT CreatedDate, OldValue, NewValue, CreatedBy.Name 
            FROM AccountHistory 
            WHERE AccountId = :customerId 
            AND Field = :fieldName 
            ORDER BY CreatedDate DESC
        ];

        List<Map<String, String>> historyList = new List<Map<String, String>>();
        for(AccountHistory h : histories) {
            Map<String, String> item = new Map<String, String>();
            item.put('Date', String.valueOf(h.CreatedDate));
            item.put('OldValue', String.valueOf(h.OldValue));
            item.put('NewValue', String.valueOf(h.NewValue));
            item.put('ChangedBy', h.CreatedBy.Name);
            historyList.add(item);
        }
        return historyList;
    }
}