/**
*  @author: Jayanth Kumar
*  @date: 03/12/2022
*  @description: controller for redemption reward history details and change of reward option
*/

public with sharing virtual class RedemptionHistoryController {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    public static String regionName;
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadRedemptionHistory(final String customerId,final String searchParametersJson, String regionName, String option) {
        // setup default response with no data
        ApiConnection.Response response = new ApiConnection.Response();
        //response.isSuccess = true;
        response.responseData = new List<Object>();
        System.debug('searchParametersJson'+searchParametersJson);
        Map<String, Object> obj = (Map<String, Object>)JSON.deserializeUntyped(searchParametersJson);
        String path = '/api/v1/rewards/redemption-history?pciNumber='+obj.get('cardId');
        If(obj.get('fromDate')!=Null)
            path=path+'&fromDate='+obj.get('fromDate');
        If(option!='')
            path=path+'&preferredRewardsOption='+option;
        If(obj.get('toDate')!=Null)
            path=path+'&toDate='+obj.get('toDate');
        If(obj.get('fromAmount')!=Null)
            path=path+'&fromAmount='+obj.get('fromAmount');
        If(obj.get('toAmount')!=Null)
            path=path+'&toAmount='+obj.get('toAmount');
        If(obj.get('status')!=Null && obj.get('status')!='All' )
            path=path+'&status='+obj.get('status');
        If(obj.get('type')!=Null && obj.get('type')!='All')
            path=path+'&tokenType='+obj.get('type');
        If(obj.get('aircode')!=Null && obj.get('aircode')!='All')
            path=path+'&airlinesCode='+obj.get('aircode');
        If(obj.get('flynum')!=Null )
            path=path+'&flyNumber='+obj.get('flynum');
        If(obj.get('pageSize')!=Null)
            path=path+'&pageSize='+obj.get('pageSize');
        final HttpRequest req;
        // final String path = '/api/v1/rewards/redemption-history?pciNumber='+obj.get('cardId')+'&preferredRewardsOption='+option;
        if(Option=='ILA_TOKENS' || Option=='CASHBACK' || Option=='AIRLINE_MILES'){
            req= con.createRequest('GET', path, customerId, regionName);
            req.setTimeout(120000);
        	response = con.makeCallout(req);
        	System.debug('$$$Response'+ JSON.serializePretty(response));
        }
        //req.setTimeout(30000);
       
        //response.isSuccess=true;
        //response.responseData=(Map<String, Object>)JSON.deserializeUntyped('{"meta":{"code":"RWRD-1022","message":"RewardsTransactionshavebeenretrievedsuccessfully"},"data":{"transactions":[{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}}]}}');
        //if there are requried clean data, it means segment is staff and view staff = false
        //we will filter staff transaction from it
        if(req!=null){
            if (response.isSuccess && null != response.responseData && null==response.errorData){
                Map<String, Object> responseData = (Map<String, Object>)response.responseData;
                //Map<String, Object> transactiondata =  (Map<String, Object>)responseData.get('redemptionHistory');
                System.debug('Response data keys:'+responseData);
                Object[] transactions = (Object[])responseData.get('redemptionHistory');
                System.debug('Transaction Length after getting response:'+transactions.size());
                response.recordLength = transactions.size();
                //if view staff = true, we will display all transactions
                if(SensitiveDataCleaner.isAllowedViewStaffData(customerId)){
                    response.responseData = transactions;
                }
                //if view staff = false, we will display only transaction during Segment != staff
                else{
                    List<Map<String, Datetime>> lstBanedDate = SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                    response.responseData = SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, transactions);
                }
            }else{
                System.debug('The status code returned was not expected: ' + JSON.serializePretty(response.errorData));
                System_Action__c logObject = new System_Action__c();
                logObject.Account__c = [SELECT Id FROM ACCOUNT WHERE CIF__pc =:customerId].Id;
                logObject.Action__c = 'Redpemtion History Details';
                logObject.Endpoint__c ='/rewards/redemption-history?pciNumber=';
                logObject.Method__c='GET';
                logObject.Request_Body__c= String.valueOf(req);
                logObject.Response_Body__c=JSON.serializePretty(response.errorData);
                
                insert logObject;
             /*   response.responseData = new List<Object>();
                response.isSuccess=true;
                response.responseData=(Map<String, Object>)JSON.deserializeUntyped('{"meta":{"code":"RWRD-1022","message":"RewardsTransactionshavebeenretrievedsuccessfully"},"data":{"transactions":[{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","airlines":"GULF_AIR","flyNumber":"2155","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","airlines":"GULF_AIR","flyNumber":"2155","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}}]}}');
                Map<String, Object> responseData = (Map<String, Object>)response.responseData;
                Map<String, Object> transactiondata =  (Map<String, Object>)responseData.get('data');
                System.debug('Response data keys:'+transactiondata.keySet());
                Object[] transactions = (Object[])transactiondata.get('transactions');
                System.debug('Transaction Length after getting response:'+transactions.size());
                response.responseData = transactions;
                response.errorData = '';*/
            }
        }
        System.debug('Response object:'+response);
        return response;
        
        
        
    }
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadRewardHistory(final String customerId, String regionName, String cardId) {
        // setup default response with no data
        ApiConnection.Response response = new ApiConnection.Response();
        // response.isSuccess = true;
        response.responseData = new List<Object>();
        final String path = '/api/v1/rewards/payment/option?pciNumber='+cardId;
        final HttpRequest req = con.createRequest('GET',path, customerId, regionName);
        //req.setTimeout(30000);
        req.setTimeout(120000);
        response = con.makeCallout(req);
        system.debug('response##'+response);
        //if there are requried clean data, it means segment is staff and view staff = false
        //we will filter staff transaction from it
        if (response.isSuccess && null != response.responseData && null==response.errorData){
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            //  Map<String, Object> transactiondata =  (Map<String, Object>)responseData.get('data');
            // System.debug('Response data keys:'+transactiondata.keySet());
            Object[] transactions = (Object[])responseData.get('paymentOptionHistory');
            System.debug('Transaction Length after getting response:'+transactions.size());
            response.recordLength = transactions.size();
            //if view staff = true, we will display all transactions
            if(SensitiveDataCleaner.isAllowedViewStaffData(customerId)){
                response.responseData = transactions;
            }
            //if view staff = false, we will display only transaction during Segment != staff
            else{
                List<Map<String, Datetime>> lstBanedDate = SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                response.responseData = SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, transactions);
            }
        }else{
            System.debug('The status code returned was not expected: ' + JSON.serializePretty(response.errorData));
            System_Action__c logObject = new System_Action__c();
            logObject.Account__c = [SELECT Id FROM ACCOUNT WHERE CIF__pc =:customerId].Id;
            logObject.Action__c = 'Choose Reward Details';
            logObject.Endpoint__c ='/rewards/payment/option?pciNumber=';
            logObject.Method__c='GET';
            logObject.Request_Body__c= String.valueOf(req);
            logObject.Response_Body__c=JSON.serializePretty(response.errorData);
            
            insert logObject;
          /*  response.responseData = new List<Object>();
            response.isSuccess=true;
            response.responseData=(Map<String, Object>)JSON.deserializeUntyped('{"meta":{"code": "RWRD-1030","message": "Rewards payment options history has been retrieved successfully"},"data":{"paymentOptionsHistory":[{"prefrerredPaymentOption": "ILA_TOKENS","requestedDate": "2022-10-05 09:09:09","effectiveDate": "2022-10-05 09:09:09"},{"prefrerredPaymentOption": "CASHBACK","requestedDate": "2022-09-05 09:09:09","effectiveDate": "2022-09-21 09:09:09"}]}}');
            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            Map<String, Object> transactiondata =  (Map<String, Object>)responseData.get('data');
            System.debug('Response data keys:'+transactiondata.keySet());
            Object[] transactions = (Object[])transactiondata.get('paymentOptionsHistory');
            System.debug('Transaction Length after getting response:'+transactions.size());
            response.recordLength = transactions.size();
            response.responseData = transactions;
            response.errorData = '';*/
        }
        System.debug('Response object:'+response);
        return response;
        
        
        
    }
    
    
}