/**
*  @author: Jayanth Kumar
*  @date: 2022-08-24
*  @description:
*      Test methods for NotificationViewCoontroller
*
*/
@isTest(isParallel=true)
private class NotificationViewCoontroller_Test {
    private static final String BAHRAIN_REGION = 'Bahrain';
    private class MyCalloutMock implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 200;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    
    @isTest
    static void testLoadNotificationList() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "PLAS-1000", "message": "Kanz details has been retrieved successfully." },'+
            '"data": {'+
            '"messages": [ '+
            '    { '+
            '    } '+
            ' ] ' +
            '}'+
            '}';
        
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = NotificationViewController.loadAccountTransactions('testCustomerId','{}',BAHRAIN_REGION );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
        
    }
    
    @isTest
    static void testLoadNotificationListException() {
        final MyCalloutMock mock = new MyCalloutMock();
        mock.testBody = '{"meta": { "code": "PLAS-1000", "message": "Kanz details has been retrieved successfully." },'+
            '"data": {'+
            '"message": [ '+
            '    { '+
            '    } '+
            ' ] ' +
            '}'+
            '}';
        
        Test.setMock(HttpCalloutMock.class, mock);
        ApiConnection.Response response = NotificationViewController.loadAccountTransactions('testCustomerId','{}',BAHRAIN_REGION );
        System.assertEquals(true, response.isSuccess);
        System.assertNotEquals(null, response.responseData);
        
    }
}