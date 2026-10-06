/**
* 
*  Change History :
*       
*         #CH01 : #D&A Team #24-06-2022# Added case model parameter
*/
@isTest
public class LTNG003_BlockProcessControllerTest {

    private class RestMock implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = 'your Json Response';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"meta":{"code":"PROD-1023","message":"Requested blocked amounts have been retrieved successfully."},"data":{"blockAmountDetailsList":[{"blockid":955,"caseNumber":"1","letterReferenceNumber":"468913","blockStatus":"BLOCKED","blockedAmount":100.500,"reminaingAmount":0.000,"currency":{"code":"BHD","decimalPlaces":"3"},"accounts":[{"iban":"BH35ABCO20612569101001","currency":{"code":"BHD","decimalPlaces":"3"},"holdAmountInAccountCurrency":"9672.573","holdAmount":261.0}]},{"blockid":7,"caseNumber":"1","letterReferenceNumber":"468915","blockStatus":"BLOCKED","blockedAmount":100.500,"reminaingAmount":0.000,"currency":{"code":"BHD","decimalPlaces":"3"},"accounts":[{"iban":"BH35ABCO20612569101001","currency":{"code":"BHD","decimalPlaces":"3"},"holdAmountInAccountCurrency":"9672.573","holdAmount":261.0}]},{"blockid":4953,"caseNumber":"1","letterReferenceNumber":"469331","blockStatus":"BLOCKED","blockedAmount":60.000,"reminaingAmount":0.000,"currency":{"code":"BHD","decimalPlaces":"3"},"accounts":[{"iban":"BH35ABCO20612569101001","currency":{"code":"BHD","decimalPlaces":"3"},"holdAmountInAccountCurrency":"9672.573","holdAmount":261.0}]}]}}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    public static void getBlockUnblockCaseRecordTypeTest(){   
        Test.startTest();
            Id cbbCaseRecordTypeId = LTNG003_BlockUnblockProcessController.getBlockUnblockCaseRecordType();
        Test.stopTest();
        System.assert(cbbCaseRecordTypeId != null);
    }

    @isTest
    public static void getExistingCbbBlocksViaApiTest(){   
        Account accObj = (Account)TestDataFactory.createSObject(new Account(CIF__pc='123456'), 'TestFactoryDefaults.AccountDefaults',true);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        
        Test.startTest();           
        List<LTNG003_BlockUnblockProcessController.BlockAmountDetails> cbbCaseRecordTypeId = LTNG003_BlockUnblockProcessController.getExistingCbbBlocksViaApi(accObj.Id,null);//CH01
        Test.stopTest();
        
        System.assert(cbbCaseRecordTypeId != null);
    }
}