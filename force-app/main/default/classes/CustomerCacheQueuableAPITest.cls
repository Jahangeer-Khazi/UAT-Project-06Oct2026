/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:13-07-2022
 * 		Change History: 
 *			  
*/
@isTest
public class CustomerCacheQueuableAPITest {
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
    private class MyCalloutMock2 implements HttpCalloutMock{
        public String testBody;
        public Integer testStatusCode = 400;
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus(' NOT OK');
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(testStatusCode);
            if (null != testBody) {
                res.setBody(testBody);
            }
            return res;
        }
    }
    @isTest
    static void unitTest1(){
        Set<Id> setIds = new Set<Id>();
        Account acc = new Account();
        acc.LastName = 'LastName Test';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        insert acc;
        setIds.add(acc.Id);
        test.startTest();
        final MyCalloutMock mock = new MyCalloutMock();
        Test.setMock(HttpCalloutMock.class, mock);
        //CustomerCacheQueuableAPI cache = new CustomerCacheQueuableAPI(setIds);
        System.enqueueJob(new CustomerCacheQueuableAPI(setIds));
        test.stoptest();
    }
     @isTest
    static void unitTest2(){
        Set<Id> setIds = new Set<Id>();
        Account acc = new Account();
        acc.LastName = 'LastName Test';
        acc.PersonEmail= 'testAcc11@gmail.test';
        acc.Mobile_Country_Code__pc = '973';
        acc.PersonMobilePhone = '645383334000';
        acc.CIF__pc = '1234567';
        acc.Referral_Code__pc='abc1234';
        acc.Segment__pc = 'Regular';
        insert acc;
        setIds.add(acc.Id);
        test.startTest();
        final MyCalloutMock2 mock = new MyCalloutMock2();
        Test.setMock(HttpCalloutMock.class, mock);
        //CustomerCacheQueuableAPI cache = new CustomerCacheQueuableAPI(setIds);
        System.enqueueJob(new CustomerCacheQueuableAPI(setIds));
        test.stoptest();
    }

}