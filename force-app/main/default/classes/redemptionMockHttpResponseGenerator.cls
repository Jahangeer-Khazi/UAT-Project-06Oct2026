@isTest
global class redemptionMockHttpResponseGenerator implements HttpCalloutMock {
    protected Integer code;
    protected String endPoint;
     public redemptionMockHttpResponseGenerator(Integer code, String endPoint) {
			this.code = code;
			this.endPoint = endPoint;
		}
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
      //  System.assertEquals('https://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
       
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(endPoint=='redemption' && code==200){
        res.setBody('{"isSuccess":true,"data":{"redemptionHistory":[{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}}]}}}');
       // res.setBody('{"example":"test"}');
        res.setStatusCode(code);  
        }else if(endPoint=='redemption' && code==500){
        res.setBody('{"isSuccess":false,"data":{"redemptionHistory":[{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"transaction","preferredRewardsOption":"ILA_TOKENS","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"cashback","preferredRewardsOption":"ILA_CASHBACK","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","status":"redeemed","merchant":{"name":"yerte","logoUrl":"1.png"}},{"transactionId":"fdsfsdfsdfs","transactionDateTime":"2022-07-07 09:09:09","amountInCardCurrency":234234.434,"cardCurrency":{"code":"BHD","decimalPlaces":3},"tokens":100,"tokensValue":1,"tokenType":"miles","preferredRewardsOption":"AIRLINE_MILES","status":"pending","merchant":{"name":"yerte","logoUrl":"1.png"}}]}}}');
       // res.setBody('{"example":"test"}');
        res.setStatusCode(code); 
        }else if(endPoint=='payment' && code==200){
            res.setBody('{"isSuccess":true,"data":{"paymentOptionHistory":[{"prefrerredPaymentOption": "ILA_TOKENS","requestedDate": "2022-10-05 09:09:09","effectiveDate": "2022-10-05 09:09:09"},{"prefrerredPaymentOption": "CASHBACK","requestedDate": "2022-09-05 09:09:09","effectiveDate": "2022-09-21 09:09:09"}]}}}}');
        	res.setStatusCode(code); 
        }else{
            res.setBody('{"isSuccess":false,"data":{"paymentOptionHistory":[{"prefrerredPaymentOption": "ILA_TOKENS","requestedDate": "2022-10-05 09:09:09","effectiveDate": "2022-10-05 09:09:09"},{"prefrerredPaymentOption": "CASHBACK","requestedDate": "2022-09-05 09:09:09","effectiveDate": "2022-09-21 09:09:09"}]}}}}');
        	res.setStatusCode(code); 
        }
        return res;
    }
}