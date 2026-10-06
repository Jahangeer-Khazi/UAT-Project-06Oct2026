/**
 *  @author: Imane Tsioucha
 *  @date: 07-05-2024  
 *  @description:
 *      controller for aura component "LTNG050_ShowCustomerId"
 *     
 *      
 */
public with sharing class LTNG050_ShowCustomerIdController {
    private static ApiConnection con = new ApiConnection();
    public static String regionName;
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_DETAILS = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance',
        'account.holdAmount'
    };
 
    @AuraEnabled
    public static Account getAccountDetails(Id recordId){
        return [Select Id,CIF__pc,Region_Flag__c From Account where id=:recordId];
      
    }
    @AuraEnabled(cacheable=false)
    public static String loadAccountDetails(final String accountId, String regionName) {
        String customerIban;
        String path = '/api/v1/accounts/customerId?iban=' +accountId;
        if (String.isBlank(regionName)) { 
            regionName = 'Bahrain';
        }
        
        final Http http = new Http();
        final HttpRequest req = con.createRequest('GET', path, regionName);
        req.setHeader('x-canary', 'cbs');//CH22
        final HTTPResponse response = http.send(req);
        System.debug('Request Details --->'+req);
        System.debug('Response Details --->'+response);

        if (response.getStatusCode() == 200 && null != response.getBody()) {
            
            // 1. Get the raw JSON string
    		String responseBody = (String) response.getBody();
            
            // 2. Deserialize the JSON into a Map
    		Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            // 3. Access nested data
    		Map<String, Object> customerData = (Map<String, Object>) responseData.get('customerData');
    		String cif = (String) customerData.get('cif');
            customerIban = cif;

        }

        return customerIban;
    }

    @AuraEnabled(cacheable=true)
    public static Account getAccountByCIF(String cif) {
        try {
            return [SELECT Id, Name, CIF__pc, Mobile_Phone_Check__pc, Archived__pc, CustomerStatus__c, Segment__pc
                    FROM Account 
                    WHERE CIF__pc = :cif 
                    LIMIT 1];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
        }
    }
}