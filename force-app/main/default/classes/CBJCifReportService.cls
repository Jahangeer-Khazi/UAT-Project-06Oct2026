public with sharing class CBJCifReportService {
    private static ApiConnection con = new ApiConnection();
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_LIST = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance'
    };

    @AuraEnabled(cacheable=true)
    public static ReportListResponse getReportRequests(String cif, String email, String region) {
       
      /**
        // Mocking the Get List of Reports API
        // For testing purposes, we return data even if CIF is null
        String jsonResponse = '{' +
            '  "meta":{' +
            '    "code": "CRIF20250217123611",' +
            '    "message": "report requested successfully"' +
            '  },' +
            '  "data":[' +
            '    {' +
            '      "refNo": "3541190e-e1f4-4f07-b629-d427b9450dfc",' +
            '      "status": {' +
            '        "id": 1,' +
            '        "name": "Pending"' +
            '      },' +
            '      "generateDate": "13-02-2025",' +
            '      "expiryDate": "13-04-2025"' +
            '    },' +
            '    {' +
            '      "refNo": "CRIF2025030412365",' +
            '      "status": {' +
            '        "id": 1,' +
            '        "name": "expired"' +
            '      },' +
            '      "generateDate": "20-04-2024",' +
            '      "expiryDate": "20-05-2024"' +
            '    },' +
            '    {' +
            '      "refNo": "CRIF-COMPLETED-TEST",' +
            '      "status": {' +
            '        "id": 2,' +
            '        "name": "COMPLETED"' +
            '      },' +
            '      "generateDate": "15-02-2025",' +
            '      "expiryDate": "15-04-2025"' +
            '    },' +
            '    {' +
            '      "refNo": "CRIF-FAILED-TEST",' +
            '      "status": {' +
            '        "id": 3,' +
            '        "name": "FAILED"' +
            '      },' +
            '      "generateDate": "10-02-2025",' +
            '      "expiryDate": "10-04-2025"' +
            '    }' +
            '  ]' +
            '}';
        
        return (ReportListResponse) JSON.deserialize(jsonResponse, ReportListResponse.class);
        
       
*/
         
        // real api start
        final String path = '/api/v1/credit-report/fetch-reports';
        final HttpRequest req = con.createRequest('GET', path, region);

        req.setHeader('userId', email != null ? email : '');
        req.setHeader('customerId', cif != null ? cif : '');

        System.debug('>>>> getReportRequests Request: ' + req.getEndpoint());
        System.debug('>>>> getReportRequests Headers: customerId=' + cif + ', email=' + email);

        final ApiConnection.Response res = con.makeCallout(req);
        System.debug('>>>> getReportRequests Response Success: ' + res.isSuccess);
        
        ReportListResponse response = new ReportListResponse();
        response.meta = new Meta();
        
        if (res.isSuccess && null != res.responseData) {
            System.debug('>>>> getReportRequests Response Data: ' + JSON.serialize(res.responseData));
            response.data = (List<ReportData>) JSON.deserialize(JSON.serialize(res.responseData), List<ReportData>.class);
            response.meta.code = '200';
            response.meta.message = 'Success';
        } else {
            System.debug('>>>> getReportRequests Error Data Raw: ' + res.errorData);
            response.meta.code = 'Error';
            if (res.errorData instanceof String) {
                String errorStr = (String)res.errorData;
                response.meta.message = errorStr.length() > 255 ? errorStr.substring(0, 255) : errorStr;
            } else if (res.errorData != null) {
                try {
                    response.meta = (Meta) JSON.deserialize(JSON.serialize(res.errorData), Meta.class);
                } catch (Exception e) {
                    response.meta.message = 'Error parsing error response: ' + e.getMessage();
                }
            } else {
                response.meta.message = 'Unknown error occurred.';
            }
        }
        return response;
        // real api end
       
        
    }

    @AuraEnabled(cacheable=true)
    public static AccountDetailsResponse getAccountDetails(String cif, String region) {
        System.debug('getAccountDetails >> '+ cif + ' ' + region);
        String customerId = cif;
        String regionName = region;
        List<Account> accounts = [SELECT Region_Flag__pc, x_canary__pc FROM Account WHERE CIF__pc = :cif LIMIT 1];
        
        final String path = '/api/v1/accounts?';
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);

        if(!accounts.isEmpty()){
             regionName = accounts[0].Region_Flag__pc;
             System.debug('x-canary added :'+accounts[0].x_canary__pc);
             if(accounts[0].x_canary__pc != null){
                 req.setHeader('x-canary', accounts[0].x_canary__pc);
             }
        }

        final ApiConnection.Response res = con.makeCallout(req);
        if (res.isSuccess && null != res.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)res.responseData;
            final Object[] accountsObj = (Object[])responseData.get('accounts');
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(accountsObj, SENSITIVE_FIELDS_ACCOUNT_LIST);
            }
        }
        System.debug('Account List Response: ' + res);

        return null;

      
    }

    @AuraEnabled(cacheable=true)
    public static CustomerInfo getCustomerInfo(Id recordId) {
        Account acc = [SELECT Id, Name, CIF__pc, PersonEmail, Region_Flag__pc FROM Account WHERE Id = :recordId LIMIT 1];
        CustomerInfo info = new CustomerInfo();
        info.customerId = acc.Id;
        info.name = acc.Name;
        info.cif = acc.CIF__pc;
        info.email = acc.PersonEmail;
        info.region = acc.Region_Flag__pc;
        return info;
    }

    // Report Wrapper Classes
    public class ReportListResponse {
        @AuraEnabled public Meta meta { get; set; }
        @AuraEnabled public List<ReportData> data { get; set; }
    }

    public class Meta {
        @AuraEnabled public String code { get; set; }
        @AuraEnabled public String message { get; set; }
    }

    public class ReportData {
        @AuraEnabled public String refNo { get; set; }
        @AuraEnabled public Status status { get; set; }
        @AuraEnabled public String generateDate { get; set; }
        @AuraEnabled public String expiryDate { get; set; }
    }

    public class Status {
        @AuraEnabled public Integer id { get; set; }
        @AuraEnabled public String name { get; set; }
    }

    // Account Wrapper Classes
    public class AccountDetailsResponse {
        @AuraEnabled public Meta meta { get; set; }
        @AuraEnabled public AccountData data { get; set; }
    }

    public class AccountData {
        @AuraEnabled public String customerId { get; set; }
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String alias { get; set; }
        @AuraEnabled public String productType { get; set; }
        @AuraEnabled public String productName { get; set; }
        @AuraEnabled public String category1 { get; set; }
        @AuraEnabled public String category2 { get; set; }
        @AuraEnabled public Boolean transferByMobile { get; set; }
        @AuraEnabled public AccountInfo account { get; set; }
        @AuraEnabled public MinimumBalance minimumBalance { get; set; }
    }

    public class AccountInfo {
        @AuraEnabled public String number_z { get; set; }
        @AuraEnabled public String branch { get; set; }
        @AuraEnabled public CurrencyInfo currency_z { get; set; }
        @AuraEnabled public String iban { get; set; }
        @AuraEnabled public Decimal availableBalance { get; set; }
        @AuraEnabled public Decimal ledgerBalance { get; set; }
        @AuraEnabled public String startDate { get; set; }
        @AuraEnabled public String endDate { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public Decimal overdraftLimit { get; set; }
        @AuraEnabled public String overdraftExpiryDate { get; set; }
        @AuraEnabled public Decimal overdraftAvailableLimit { get; set; }
        @AuraEnabled public Boolean paymentsAllowed { get; set; }
        @AuraEnabled public String swiftCode { get; set; }
        @AuraEnabled public Boolean earnInterest { get; set; }
        @AuraEnabled public Decimal creditTotalInterest { get; set; }
        @AuraEnabled public Decimal debitTotalInterest { get; set; }
        @AuraEnabled public Boolean allowInterestConditionUpdate { get; set; }
        @AuraEnabled public InterestRateInfo interestRateInformation { get; set; }
        @AuraEnabled public List<InterestCondition> interestConditions { get; set; }
    }

    public class CurrencyInfo {
        @AuraEnabled public String code { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public Integer decimalPlaces { get; set; }
    }

    public class InterestRateInfo {
        @AuraEnabled public Boolean currentEarnInterest { get; set; }
        @AuraEnabled public Boolean requestedEarnInterest { get; set; }
        @AuraEnabled public String processingStatus { get; set; }
        @AuraEnabled public String effectiveDate { get; set; }
        @AuraEnabled public String modifiedDate { get; set; }
    }

    public class InterestCondition {
        @AuraEnabled public String rateType { get; set; }
        @AuraEnabled public Integer rankOrder { get; set; }
        @AuraEnabled public CurrencyInfo currency_z { get; set; }
        @AuraEnabled public String tier { get; set; }
        @AuraEnabled public Decimal tier_start { get; set; }
        @AuraEnabled public Decimal tier_end { get; set; }
        @AuraEnabled public Decimal rate { get; set; }
        @AuraEnabled public Decimal applicable_balance { get; set; }
        @AuraEnabled public Boolean active { get; set; }
        @AuraEnabled public Boolean show_rate { get; set; }
    }

    public class MinimumBalance {
        @AuraEnabled public Decimal threshold { get; set; }
        @AuraEnabled public Decimal fee { get; set; }
        @AuraEnabled public Decimal averageBalance { get; set; }
        @AuraEnabled public Boolean feeWaiver { get; set; }
        @AuraEnabled public String feeWaiverReason { get; set; }
    }

    public class CustomerInfo {
        @AuraEnabled public String customerId { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String cif { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String region { get; set; } 
    }
}