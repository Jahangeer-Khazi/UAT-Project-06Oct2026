@IsTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);

        // Define a mock JSON response based on the expected format
        Map<String, Object> configurationsMap = new Map<String, Object>();
        configurationsMap.put('interestRate', 5.0);
        configurationsMap.put('processingFee', 100.0);
        configurationsMap.put('vatProcessingFee', 15.0);
        configurationsMap.put('firstPaymentDate', '2025-11-15');

        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('configurations', new List<Object>{configurationsMap});
        
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put('data', dataMap);
        
        res.setBody(JSON.serialize(responseMap));
        return res;
    }
}