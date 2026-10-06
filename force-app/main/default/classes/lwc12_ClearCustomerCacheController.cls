/* 		 
 * 		Created By:  Omar AITOGRAM
 *		Created Date: 2026-02-27
 * 		Description: Controller for clearing customer cache in multiple card systems. (lwc12_)
*/
public with sharing class lwc12_ClearCustomerCacheController {
    
    @AuraEnabled
    public static Map<String, Object> clearCache(Id accountId) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            Account acc = [SELECT Id, CIF__pc, PersonEmail, Region_Flag__c FROM Account WHERE Id = :accountId LIMIT 1];
            
            if (acc == null) {
                result.put('isSuccess', false);
                result.put('message', 'Account not found.');
                return result;
            }

            ApiConnection con = new ApiConnection();
            String queryParams = '?language=en&unit=neo';
            
            // Clear Credit Cards Cache
            HttpRequest req1 = con.createRequest('DELETE', '/api/v1/credit-cards/customer/cache' , acc.Region_Flag__c);
            req1.setHeader('customerId', acc.CIF__pc);
            req1.setHeader('x-canary', 'pi');
            req1.setTimeout(120000);
            ApiConnection.Response res1 = con.makeCallout(req1);
            
            // Clear Cards Cache
            HttpRequest req2 = con.createRequest('DELETE', '/api/v1/cards/customer/cache' , acc.Region_Flag__c);
            req2.setHeader('customerId', acc.CIF__pc);
            req2.setHeader('x-canary', 'pi');
            req2.setTimeout(120000);
            ApiConnection.Response res2 = con.makeCallout(req2);

            // Clear Customer Cache
            HttpRequest req3 = con.createRequest('DELETE', '/api/v1/customers/cache' , acc.Region_Flag__c);
            req3.setHeader('customerId', acc.CIF__pc);
            req3.setHeader('x-canary', 'pi');
            req3.setTimeout(120000);
            ApiConnection.Response res3 = con.makeCallout(req3);

            if (res1.isSuccess && res2.isSuccess && res3.isSuccess) {
                result.put('isSuccess', true);
                result.put('message', 'Customer cache cleared successfully.');
            } else {
                String errorMsg = 'Failed to clear some caches: ';
                List<String> failures = new List<String>();
                if (!res1.isSuccess) failures.add('Credit Cards');
                if (!res2.isSuccess) failures.add('Cards');
                if (!res3.isSuccess) failures.add('Customer');
                errorMsg += String.join(failures, ', ') + ' (Failed)';
                result.put('isSuccess', false);
                result.put('message', errorMsg);
            }
            
        } catch (Exception e) {
            result.put('isSuccess', false);
            result.put('message', 'An error occurred: ' + e.getMessage());
            System.debug('Error in lwc12_ClearCustomerCacheController.clearCache: ' + e.getMessage());
        }
        return result;
    }
}