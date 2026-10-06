public with sharing class LoginActivityService {

    private static final String LOGIN_HISTORY_PATH = '/api/v1/login-history';
    private static final Integer DEFAULT_LOOKBACK_DAYS = 30;
    private static final Integer DEFAULT_RANGE_LIMIT = 20;
    private static final Integer LAST_LOGIN_LIMIT = 1;
    private static final Integer RECENT_LOGIN_LIMIT = 5;
    private static final Integer MAX_PAGES = 10;
    private static final String BACKGROUND_TASKS_PATH = '/api/v1/background-tasks';
    private static final String REPORT_CALLBACK_URL = 'https://example.com/callback';

    @TestVisible
    private static ApiConnection connection = new ApiConnection();

    public class FetchResult {
        public List<Map<String, Object>> items = new List<Map<String, Object>>();
        public String region;
        public String cif;
    }

    /**
     * Latest login only: cif + limit=1, no startDate/endDate.
     * Extra integers are ignored so existing LWC calls still compile.
     */
    @AuraEnabled
    public static LoginActivityWrapper getLastLoginAttempt(Id customerId, Integer startDaysAgo, Integer daysToScan) {
        Account customer = getCustomer(customerId);
        ApiPage page = callLoginHistory(customer, null, null, LAST_LOGIN_LIMIT, null);
        if (!page.isSuccess) {
            throwAura('Login history API call failed: ' + page.errorMessage);
        }
        if (page.items.isEmpty()) {
            return null;
        }
        return pickLatest(page.items, resolveRegion(customer));
    }

    public static FetchResult fetchLatestItems(Id customerId, Integer limitVal) {
        Account customer = getCustomer(customerId);
        Integer limitToUse = limitVal == null || limitVal < 1 ? RECENT_LOGIN_LIMIT : limitVal;
        FetchResult result = new FetchResult();
        result.cif = customer.CIF__pc.trim();
        result.region = resolveRegion(customer);

        ApiPage page = callLoginHistory(customer, null, null, limitToUse, null);
        if (!page.isSuccess) {
            throwAura('Login history API call failed: ' + page.errorMessage);
        }
        result.items.addAll(page.items);
        return result;
    }

    public static FetchResult scanLoginDays(Id customerId, Integer startDaysAgo, Integer daysToScan) {
        Account customer = getCustomer(customerId);
        Integer start = startDaysAgo == null || startDaysAgo < 0 ? 0 : startDaysAgo;
        Integer scan = daysToScan == null || daysToScan < 1 ? 8 : daysToScan;
        if (scan > 8) {
            scan = 8;
        }

        FetchResult result = new FetchResult();
        result.cif = customer.CIF__pc.trim();
        result.region = resolveRegion(customer);

        Date startDay = Date.today().addDays(-start);
        for (Integer i = 0; i < scan; i++) {
            Date day = startDay.addDays(-i);
            ApiPage page = callLoginHistory(customer, day, day, DEFAULT_RANGE_LIMIT, null);
            if (!page.isSuccess) {
                if (isRetryableApiError(page)) {
                    break;
                }
                throwAura('Login history API call failed: ' + page.errorMessage);
            }
            result.items.addAll(page.items);
        }
        return result;
    }

    @AuraEnabled
    public static List<LoginActivityWrapper> getLoginHistory(Id customerId, Date fromDate, Date toDate, String status) {
        FetchResult fetched = fetchLoginHistoryItems(
            customerId,
            fromDate,
            toDate,
            DEFAULT_RANGE_LIMIT,
            true
        );

        List<LoginActivityWrapper> mapped = new List<LoginActivityWrapper>();
        for (Map<String, Object> item : fetched.items) {
            LoginActivityWrapper row = mapToWrapper(item, fetched.region);
            if (matchesStatus(row.status, status)) {
                mapped.add(row);
            }
        }
        return mapped;
    }

    @AuraEnabled
    public static String generateExportUrl(Id customerId, Date fromDate, Date toDate, String status) {
        return 'https://mock-api.arabbank.com/reports/login-activity?customerId=' + customerId + '&from=' + fromDate + '&to=' + toDate + '&format=excel';
    }

    @AuraEnabled
    public static String requestLoginHistoryReport(Id customerId, Date fromDate, Date toDate) {
        if (fromDate == null || toDate == null) {
            throwAura('Please select both start and end dates.');
        }
        if (fromDate > toDate) {
            throwAura('Start date must be before end date.');
        }
        if (fromDate.daysBetween(toDate) > 90) {
            throwAura('The date range cannot exceed 90 days (3 months).');
        }

        Account customer = getCustomer(customerId);
        String cif = customer.CIF__pc.trim();
        String region = resolveRegion(customer);

        Map<String, Object> body = new Map<String, Object>{
            'type' => 'LOGIN_HISTORY_REPORT',
            'payload' => new Map<String, Object>{
                'startDate' => String.valueOf(fromDate),
                'endDate' => String.valueOf(toDate),
                'format' => 'EXCEL',
                'cif' => cif
            },
            'callbackUrl' => REPORT_CALLBACK_URL
        };

        HttpRequest req = connection.createRequest('POST', BACKGROUND_TASKS_PATH, cif, region);
        req.setHeader('Accept', 'application/json');
        req.setBody(JSON.serialize(body));
        req.setTimeout(120000);

        System.debug('--- Background Task (Login History Report) ---');
        System.debug('LoginHistoryReport >>> CIF: ' + cif);
        System.debug('LoginHistoryReport >>> Region: ' + region);
        System.debug('LoginHistoryReport >>> Account Id: ' + customerId);
        System.debug('LoginHistoryReport >>> Method: ' + req.getMethod());
        System.debug('LoginHistoryReport >>> Endpoint: ' + req.getEndpoint());
        System.debug('LoginHistoryReport >>> Header customerId: ' + req.getHeader('customerId'));
        System.debug('LoginHistoryReport >>> Header x-apikey set: ' + String.isNotBlank(req.getHeader('x-apikey')));
        System.debug('LoginHistoryReport >>> Header Content-Type: ' + req.getHeader('Content-Type'));
        System.debug('LoginHistoryReport >>> Header Accept: ' + req.getHeader('Accept'));
        System.debug('LoginHistoryReport >>> Request Body: ' + req.getBody());

        ApiConnection.Response res = connection.makeCallout(req);

        System.debug('LoginHistoryReport >>> Response is null: ' + (res == null));
        if (res != null) {
            System.debug('LoginHistoryReport >>> Success: ' + res.isSuccess);
            System.debug('LoginHistoryReport >>> Response Data: ' + JSON.serializePretty(res.responseData));
            System.debug('LoginHistoryReport >>> Error Data: ' + JSON.serializePretty(res.errorData));
        }
        System.debug('---------------------------------------------------');

        if (res == null || !res.isSuccess) {
            String errorMessage = stringifyError(res);
            System.debug('LoginHistoryReport >>> POST Failed: ' + errorMessage);
            throwAura('Login history report request failed: ' + errorMessage);
        }

        String taskId = extractTaskId(res.responseData);
        System.debug('LoginHistoryReport >>> Extracted taskId: ' + taskId);
        if (String.isBlank(taskId)) {
            throwAura('Login history report request succeeded but taskId was missing.');
        }
        return taskId;
    }

    @AuraEnabled
    public static Map<String, String> getLoginHistoryReportStatus(Id customerId, String taskId) {
        if (String.isBlank(taskId)) {
            throwAura('Task Id is required to check the report status.');
        }
        Account customer = getCustomer(customerId);
        String cif = customer.CIF__pc.trim();
        String region = resolveRegion(customer);
        return getBackgroundTask(cif, region, taskId);
    }

    private static Map<String, String> getBackgroundTask(String cif, String region, String taskId) {
        String path = BACKGROUND_TASKS_PATH + '/' + taskId;
        HttpRequest req = connection.createRequest('GET', path, cif, region);
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);

        System.debug('--- Background Task Status (Login History Report) ---');
        System.debug('LoginHistoryReport GET >>> CIF: ' + cif);
        System.debug('LoginHistoryReport GET >>> Region: ' + region);
        System.debug('LoginHistoryReport GET >>> Task Id: ' + taskId);
        System.debug('LoginHistoryReport GET >>> Method: ' + req.getMethod());
        System.debug('LoginHistoryReport GET >>> Endpoint: ' + req.getEndpoint());
        System.debug('LoginHistoryReport GET >>> Header customerId: ' + req.getHeader('customerId'));
        System.debug('LoginHistoryReport GET >>> Header x-apikey set: ' + String.isNotBlank(req.getHeader('x-apikey')));
        System.debug('LoginHistoryReport GET >>> Header Content-Type: ' + req.getHeader('Content-Type'));
        System.debug('LoginHistoryReport GET >>> Header Accept: ' + req.getHeader('Accept'));

        HTTPResponse httpRes = new Http().send(req);
        Integer statusCode = httpRes == null ? 0 : httpRes.getStatusCode();
        String rawBody = httpRes == null ? null : httpRes.getBody();
        System.debug('LoginHistoryReport GET >>> HTTP Status: ' + statusCode);
        System.debug('LoginHistoryReport GET >>> Raw Body: ' + rawBody);

        if (statusCode != 200 && statusCode != 201 && statusCode != 202) {
            String errorMessage = extractHttpError(httpRes);
            System.debug('LoginHistoryReport GET >>> Failed: ' + errorMessage);
            throwAura('Login history report status request failed: ' + errorMessage);
        }

        Map<String, Object> payload = parseTaskPayload(rawBody);
        Map<String, Object> resultNode = asMap(payload.get('result'));
        String downloadUrl = firstValue(resultNode, new List<String>{ 'downloadUrl', 'resultUrl', 'fileUrl', 'url' });
        if (String.isBlank(downloadUrl)) {
            downloadUrl = firstValue(payload, new List<String>{ 'downloadUrl', 'resultUrl', 'fileUrl', 'url' });
        }
        Map<String, String> result = new Map<String, String>{
            'taskId' => firstValue(payload, new List<String>{ 'taskId', 'id' }),
            'status' => firstValue(payload, new List<String>{ 'status' }),
            'type' => firstValue(payload, new List<String>{ 'type' }),
            'downloadUrl' => downloadUrl,
            'expiresAt' => firstValue(resultNode, new List<String>{ 'expiresAt', 'expires' })
        };
        System.debug('LoginHistoryReport GET >>> Parsed status: ' + result.get('status'));
        System.debug('LoginHistoryReport GET >>> Download URL present: ' + String.isNotBlank(downloadUrl));
        System.debug('LoginHistoryReport GET >>> Expires At: ' + result.get('expiresAt'));
        System.debug('---------------------------------------------------');
        return result;
    }

    private static Map<String, Object> parseTaskPayload(String rawBody) {
        if (String.isBlank(rawBody)) {
            return new Map<String, Object>();
        }
        Object parsed = JSON.deserializeUntyped(rawBody);
        Map<String, Object> root = asMap(parsed);
        if (root == null) {
            return new Map<String, Object>();
        }
        Map<String, Object> nested = asMap(root.get('data'));
        return nested != null ? nested : root;
    }

    private static String firstValue(Map<String, Object> payload, List<String> keys) {
        if (payload == null) {
            return null;
        }
        for (String key : keys) {
            if (payload.get(key) != null && String.isNotBlank(String.valueOf(payload.get(key)))) {
                return String.valueOf(payload.get(key));
            }
        }
        return null;
    }

    private static String extractTaskId(Object responseData) {
        Map<String, Object> data = asMap(responseData);
        if (data == null) {
            return null;
        }
        if (data.get('taskId') != null) {
            return String.valueOf(data.get('taskId'));
        }
        if (data.get('id') != null) {
            return String.valueOf(data.get('id'));
        }
        return null;
    }

    private static Map<String, Object> asMap(Object value) {
        return value instanceof Map<String, Object> ? (Map<String, Object>) value : null;
    }

    private static String stringifyError(ApiConnection.Response res) {
        if (res == null || res.errorData == null) {
            return 'Unknown error';
        }
        if (res.errorData instanceof Map<String, Object>) {
            Map<String, Object> errorMap = (Map<String, Object>) res.errorData;
            if (errorMap.get('message') != null) {
                return String.valueOf(errorMap.get('message'));
            }
        }
        return String.valueOf(res.errorData);
    }

    public static FetchResult fetchLoginHistoryItems(
        Id customerId,
        Date fromDate,
        Date toDate,
        Integer limitVal,
        Boolean followAllPages
    ) {
        Account customer = getCustomer(customerId);
        Date effectiveTo = toDate != null ? toDate : Date.today();
        Date effectiveFrom = fromDate != null ? fromDate : effectiveTo.addDays(-DEFAULT_LOOKBACK_DAYS);
        if (effectiveFrom > effectiveTo) {
            Date swapped = effectiveFrom;
            effectiveFrom = effectiveTo;
            effectiveTo = swapped;
        }

        FetchResult result = new FetchResult();
        result.cif = customer.CIF__pc.trim();
        result.region = resolveRegion(customer);

        Integer originalSpan = effectiveFrom.daysBetween(effectiveTo);
        List<Integer> windows = new List<Integer>{ originalSpan };
        if (originalSpan > 7) {
            windows.add(7);
        }
        if (originalSpan > 1) {
            windows.add(1);
        }

        ApiPage lastPage;
        for (Integer windowDays : windows) {
            if (windowDays == null || windowDays < 0) {
                continue;
            }
            Date windowFrom = effectiveTo.addDays(-windowDays);
            if (windowFrom < effectiveFrom) {
                windowFrom = effectiveFrom;
            }
            lastPage = fetchRange(customer, windowFrom, effectiveTo, DEFAULT_RANGE_LIMIT, followAllPages);
            if (lastPage.isSuccess) {
                result.items.addAll(lastPage.items);
                return result;
            }
            if (!isRetryableApiError(lastPage)) {
                throwAura('Login history API call failed: ' + lastPage.errorMessage);
            }
        }

        if (lastPage != null && !lastPage.isSuccess && followAllPages == true) {
            throwAura('Login history API call failed: ' + lastPage.errorMessage);
        }
        return result;
    }

    private class ApiPage {
        public List<Map<String, Object>> items = new List<Map<String, Object>>();
        public String nextToken;
        public Integer statusCode;
        public String errorMessage;
        public Boolean isSuccess;
    }

    private static ApiPage fetchRange(
        Account customer,
        Date fromDate,
        Date toDate,
        Integer limitVal,
        Boolean followAllPages
    ) {
        ApiPage combined = new ApiPage();
        combined.items = new List<Map<String, Object>>();
        combined.isSuccess = true;
        combined.statusCode = 200;

        String nextToken = null;
        Integer page = 0;
        Integer pagesToFetch = followAllPages == true ? MAX_PAGES : 1;

        do {
            page++;
            ApiPage apiPage = callLoginHistory(customer, fromDate, toDate, limitVal, nextToken);
            if (!apiPage.isSuccess) {
                return apiPage;
            }
            combined.items.addAll(apiPage.items);
            nextToken = apiPage.nextToken;
        } while (followAllPages == true && String.isNotBlank(nextToken) && page < pagesToFetch);

        return combined;
    }

    private static ApiPage callLoginHistory(
        Account customer,
        Date fromDate,
        Date toDate,
        Integer limitVal,
        String nextToken
    ) {
        String cif = customer.CIF__pc.trim();
        String region = resolveRegion(customer);

        List<String> parts = new List<String>{
            'cif=' + EncodingUtil.urlEncode(cif, 'UTF-8')
        };
        if (fromDate != null && toDate != null) {
            parts.add('startDate=' + EncodingUtil.urlEncode(toStartOfDayUtc(fromDate), 'UTF-8'));
            parts.add('endDate=' + EncodingUtil.urlEncode(toExclusiveEndUtc(toDate), 'UTF-8'));
        }
        if (limitVal != null) {
            parts.add('limit=' + String.valueOf(limitVal));
        }
        if (String.isNotBlank(nextToken)) {
            parts.add('nextToken=' + EncodingUtil.urlEncode(nextToken, 'UTF-8'));
        }

        String path = LOGIN_HISTORY_PATH + '?' + String.join(parts, '&');
        HttpRequest req = connection.createRequest('GET', path, region);
        req.setHeader('Accept', 'application/json');
        req.setTimeout(120000);

        System.debug('Login history endpoint: ' + req.getEndpoint());
        HTTPResponse httpRes = new Http().send(req);
        System.debug('Login history status: ' + (httpRes == null ? null : httpRes.getStatusCode()));
        System.debug('Login history body: ' + (httpRes == null ? null : httpRes.getBody()));

        ApiPage page = new ApiPage();
        page.statusCode = httpRes == null ? 0 : httpRes.getStatusCode();
        page.isSuccess = page.statusCode == 200;
        if (!page.isSuccess) {
            page.errorMessage = extractHttpError(httpRes);
            page.items = new List<Map<String, Object>>();
            return page;
        }

        Object payload = null;
        if (httpRes != null && String.isNotBlank(httpRes.getBody())) {
            payload = JSON.deserializeUntyped(httpRes.getBody());
        }
        ApiPage parsed = parseApiPage(payload);
        parsed.statusCode = 200;
        parsed.isSuccess = true;
        return parsed;
    }

    private static Boolean isRetryableApiError(ApiPage page) {
        if (page == null || page.isSuccess) {
            return false;
        }
        String message = page.errorMessage == null ? '' : page.errorMessage;
        return page.statusCode == 500
            || message.contains('GENE-3001')
            || message.containsIgnoreCase('unable to provide access');
    }

    @TestVisible
    static ApiPage parseApiPage(Object responseData) {
        ApiPage page = new ApiPage();
        Map<String, Object> payload = extractPayload(responseData);
        if (payload == null) {
            return page;
        }

        Object rawItems = payload.get('items');
        if (rawItems instanceof List<Object>) {
            for (Object rawItem : (List<Object>) rawItems) {
                if (rawItem instanceof Map<String, Object>) {
                    page.items.add((Map<String, Object>) rawItem);
                }
            }
        }

        Object tokenObj = payload.get('nextToken');
        if (tokenObj != null) {
            String token = String.valueOf(tokenObj);
            if (String.isNotBlank(token) && token != 'null') {
                page.nextToken = token;
            }
        }
        return page;
    }

    private static Map<String, Object> extractPayload(Object responseData) {
        if (!(responseData instanceof Map<String, Object>)) {
            return null;
        }
        Map<String, Object> payload = (Map<String, Object>) responseData;
        if (payload.containsKey('items')) {
            return payload;
        }
        Object nested = payload.get('data');
        if (nested instanceof Map<String, Object>) {
            return (Map<String, Object>) nested;
        }
        return payload;
    }

    private static LoginActivityWrapper pickLatest(List<Map<String, Object>> items, String region) {
        LoginActivityWrapper latest = null;
        for (Map<String, Object> item : items) {
            LoginActivityWrapper row = mapToWrapper(item, region);
            if (latest == null
                || (row.loginTimestamp != null
                    && (latest.loginTimestamp == null || row.loginTimestamp > latest.loginTimestamp))) {
                latest = row;
            }
        }
        return latest;
    }

    private static LoginActivityWrapper mapToWrapper(Map<String, Object> item, String region) {
        LoginActivityWrapper row = new LoginActivityWrapper();
        row.loginTimestamp = parseTimestamp(item.get('timestamp'));
        row.status = mapOutcome(toStringValue(item.get('outcome')));
        row.deviceIp = toStringValue(item.get('ipAddress'));
        row.deviceModel = toStringValue(item.get('deviceId'));
        row.location = toStringValue(item.get('city'));
        if (String.isBlank(row.location)) {
            row.location = toStringValue(item.get('location'));
        }
        if (String.isBlank(row.location)) {
            row.location = region;
        }
        row.unit = region;
        row.errorCode = row.status == 'Failed' ? toStringValue(item.get('errorCode')) : '';
        row.vpnUsed = false;
        return row;
    }

    private static Boolean matchesStatus(String actualStatus, String requestedStatus) {
        return String.isBlank(requestedStatus)
            || requestedStatus == 'All'
            || actualStatus == requestedStatus;
    }

    private static Account getCustomer(Id customerId) {
        if (customerId == null) {
            throwAura('Customer Id is required to load login history.');
        }
        List<Account> accounts = [
            SELECT CIF__pc, Region_Flag__c, Region_Flag__pc
            FROM Account
            WHERE Id = :customerId
            LIMIT 1
        ];
        if (accounts.isEmpty()) {
            throwAura('Customer account was not found.');
        }
        if (String.isBlank(accounts[0].CIF__pc)) {
            throwAura('CIF is missing on the customer account.');
        }
        return accounts[0];
    }

    private static String resolveRegion(Account customer) {
        if (String.isNotBlank(customer.Region_Flag__c)) {
            return customer.Region_Flag__c;
        }
        if (String.isNotBlank(customer.Region_Flag__pc)) {
            return customer.Region_Flag__pc;
        }
        return 'Bahrain';
    }

    private static String toStartOfDayUtc(Date value) {
        Datetime dt = Datetime.newInstanceGmt(value.year(), value.month(), value.day(), 0, 0, 0);
        return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    private static String toExclusiveEndUtc(Date value) {
        Date nextDay = value.addDays(1);
        Datetime dt = Datetime.newInstanceGmt(nextDay.year(), nextDay.month(), nextDay.day(), 0, 0, 0);
        return dt.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    public static String mapOutcome(String outcome) {
        if (String.isBlank(outcome)) {
            return '';
        }
        if (outcome.equalsIgnoreCase('SUCCESS')) {
            return 'Success';
        }
        if (outcome.equalsIgnoreCase('FAILED')
            || outcome.equalsIgnoreCase('FAILURE')
            || outcome.equalsIgnoreCase('FAIL')) {
            return 'Failed';
        }
        return outcome.substring(0, 1).toUpperCase() + outcome.substring(1).toLowerCase();
    }

    public static Datetime parseTimestamp(Object raw) {
        if (raw == null) {
            return null;
        }
        String value = String.valueOf(raw);
        if (String.isBlank(value)) {
            return null;
        }
        try {
            return (Datetime) JSON.deserialize('"' + value + '"', Datetime.class);
        } catch (Exception e) {
            return null;
        }
    }

    public static String toStringValue(Object raw) {
        return raw == null ? '' : String.valueOf(raw);
    }

    private static String extractHttpError(HTTPResponse httpRes) {
        if (httpRes == null) {
            return 'Unknown error';
        }
        String body = httpRes.getBody();
        if (String.isNotBlank(body)) {
            try {
                Object parsed = JSON.deserializeUntyped(body);
                if (parsed instanceof Map<String, Object>) {
                    Map<String, Object> errorMap = (Map<String, Object>) parsed;
                    Object meta = errorMap.containsKey('meta') ? errorMap.get('meta') : errorMap;
                    if (meta instanceof Map<String, Object>) {
                        Map<String, Object> metaMap = (Map<String, Object>) meta;
                        if (metaMap.get('message') != null) {
                            return String.valueOf(metaMap.get('message'));
                        }
                    }
                    return String.valueOf(meta);
                }
            } catch (Exception e) {
                return body;
            }
            return body;
        }
        return 'HTTP ' + String.valueOf(httpRes.getStatusCode());
    }

    private static void throwAura(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        throw ex;
    }
}