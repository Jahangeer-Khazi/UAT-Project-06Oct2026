public with sharing class CollateralsHoldsController {
    @TestVisible
    private static ApiConnection con = new ApiConnection();

    // Wrapper classes
    public class AccountHoldWrapper {
        @AuraEnabled public String accountNumber;
        @AuraEnabled public String accountName;          // will hold productType (e.g., "FIXED_DEPOSIT")
        @AuraEnabled public String productName;          // new: human-readable name from API
        @AuraEnabled public String cury;
        @AuraEnabled public Decimal totalHoldAmount;
        @AuraEnabled public List<HoldDetail> holds;

        public AccountHoldWrapper(String accountNumber, String accountName, String productName, String cury, Decimal totalHoldAmount, List<HoldDetail> holds) {
            this.accountNumber = accountNumber;
            this.accountName = accountName;
            this.productName = productName;
            this.cury = cury;
            this.totalHoldAmount = totalHoldAmount;
            this.holds = holds;
        }
    }

    public class HoldDetail {
        @AuraEnabled public String holdId;
        @AuraEnabled public String holdType;
        @AuraEnabled public String holdTypeDescription;  // new
        @AuraEnabled public Decimal holdAmount;
        @AuraEnabled public String cury;
        @AuraEnabled public Date fromDate;
        @AuraEnabled public Date expiryDate;

        public HoldDetail(String holdId, String holdType, String holdTypeDescription, Decimal holdAmount, String cury, Date fromDate, Date expiryDate) {
            this.holdId = holdId;
            this.holdType = holdType;
            this.holdTypeDescription = holdTypeDescription;
            this.holdAmount = holdAmount;
            this.cury = cury;
            this.fromDate = fromDate;
            this.expiryDate = expiryDate;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountHoldWrapper> getCustomerHolds(String cif, String regionName, String xCanaryValue) {
        List<AccountHoldWrapper> result = new List<AccountHoldWrapper>();

        if (String.isBlank(cif)) {
            return result;
        }

        String endpoint = '/api/v1/collaterals';
        HttpRequest req = con.createRequest('GET', endpoint, cif, regionName);
        //req.setHeader('x-canary', xCanaryValue);
        req.setHeader('x-canary', 'cbs');
        req.setTimeout(12000);

        Http http = new Http();
        HttpResponse response = http.send(req);

        System.debug('Response status: ' + response.getStatusCode());
        System.debug('Response body: ' + response.getBody());

        if (response.getStatusCode() == 200 && String.isNotBlank(response.getBody())) {
            try {
                Map<String, Object> root = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> data = (Map<String, Object>) root.get('data');
                List<Object> collaterals = (List<Object>) data.get('collaterals');

                if (collaterals == null || collaterals.isEmpty()) {
                    return result;
                }

                // Group by accountId
                Map<String, List<HoldDetail>> accountHoldsMap = new Map<String, List<HoldDetail>>();
                Map<String, Decimal> accountTotalMap = new Map<String, Decimal>();
                Map<String, String> accountCurrencyMap = new Map<String, String>();
                Map<String, String> accountProductNameMap = new Map<String, String>();   // for human‑readable productName
                Map<String, String> accountTypeMap = new Map<String, String>();         // for productType (used as accountName)

                for (Object collObj : collaterals) {
                    Map<String, Object> collMap = (Map<String, Object>) collObj;

                    String accountId = (String) collMap.get('accountId');
                    String holdId = (String) collMap.get('holdId');
                    String holdType = (String) collMap.get('holdType');
                    String holdTypeDescription = (String) collMap.get('holdTypeDescription');
                    Decimal amount = (Decimal) collMap.get('amount');
                    String cury = (String) collMap.get('currency');
                    String productName = (String) collMap.get('productName');        // new field
                    String productType = (String) collMap.get('productType');        // for accountName

                    // Parse timestamps – supports both milliseconds and "YYYY-MM-DD" string format
                    Date fromDate = null;
                    Date expiryDate = null;
                    Object fromObj = collMap.get('fromDate');
                    Object expiryObj = collMap.get('expiryDate');

                    if (fromObj instanceof String) {
                        String fromStr = (String) fromObj;
                        if (String.isNotBlank(fromStr)) {
                            try {
                                // Try as milliseconds (old format)
                                Long fromMillis = Long.valueOf(fromStr);
                                fromDate = DateTime.newInstance(fromMillis).date();
                            } catch (Exception e) {
                                // Fallback: try as date string (new format)
                                try {
                                    fromDate = Date.valueOf(fromStr);
                                } catch (Exception ex) {
                                    // ignore, leave null
                                }
                            }
                        }
                    }

                    if (expiryObj instanceof String) {
                        String expiryStr = (String) expiryObj;
                        if (String.isNotBlank(expiryStr)) {
                            try {
                                Long expiryMillis = Long.valueOf(expiryStr);
                                expiryDate = DateTime.newInstance(expiryMillis).date();
                            } catch (Exception e) {
                                try {
                                    expiryDate = Date.valueOf(expiryStr);
                                } catch (Exception ex) {
                                    // ignore
                                }
                            }
                        }
                    }

                    // Build HoldDetail
                    HoldDetail hold = new HoldDetail(holdId, holdType, holdTypeDescription, amount, cury, fromDate, expiryDate);

                    // Group by account
                    if (!accountHoldsMap.containsKey(accountId)) {
                        accountHoldsMap.put(accountId, new List<HoldDetail>());
                        accountTotalMap.put(accountId, 0);
                        accountCurrencyMap.put(accountId, cury);
                        accountProductNameMap.put(accountId, String.isNotBlank(productName) ? productName : '');
                        accountTypeMap.put(accountId, String.isNotBlank(productType) ? productType : accountId); // fallback to accountId
                    }
                    accountHoldsMap.get(accountId).add(hold);
                    Decimal currentTotal = accountTotalMap.get(accountId);
                    accountTotalMap.put(accountId, currentTotal + (amount != null ? amount : 0));
                }

                // Build wrappers
                for (String accountId : accountHoldsMap.keySet()) {
                    List<HoldDetail> holds = accountHoldsMap.get(accountId);
                    Decimal total = accountTotalMap.get(accountId);
                    String cury = accountCurrencyMap.get(accountId);
                    String accountName = accountTypeMap.get(accountId);      // productType
                    String productName = accountProductNameMap.get(accountId); // human‑readable
                    result.add(new AccountHoldWrapper(accountId, accountName, productName, cury, total, holds));
                }

            } catch (Exception e) {
                System.debug('Error parsing response: ' + e.getMessage());
                return new List<AccountHoldWrapper>();
            }
        } else {
            System.debug('API call failed with status: ' + response.getStatusCode());
        }

        return result;
    }
}