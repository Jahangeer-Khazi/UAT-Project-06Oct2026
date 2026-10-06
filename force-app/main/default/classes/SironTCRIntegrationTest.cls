@IsTest
public class SironTCRIntegrationTest {

    // Setup test data
    @TestSetup
    static void setupTestData() {
        // Create test Accounts
        Account acc1 = new Account(
            PersonEmail = 'test1@example.com',
            CIF__pc = '5376356',
            Region_Flag__pc = 'Bahrain',
            Nationality__pc = 'BH',
            Employment_Status__pc = 'Employed',
            Gross_Monthly_Income__pc = '1500',
            US_Indicia__pc = false,
            Expected_Monthly_deposits__pc = 10000,
            FirstName = 'John',
            MiddleName = 'M',
            LastName = 'Doe',
            Mobile_Country_Code__pc = '941',
            PersonMobilePhone = '1234567890',
            PersonMailingStreet = '123 Main St',
            PersonMailingCity = 'Manama',
            PersonMailingCountry = 'BH'
        );
        insert acc1;
    }

    public class SironTCRMockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public SironTCRMockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    // Test method for successful HTTP response
    @IsTest
    public static void testUpdateCustomerInSiron_Success() {
        // Arrange
        Account acc1 = [SELECT Id FROM Account WHERE CIF__pc = '5376356'];
        List<SironTCRIntegration.FlowInputs> inputs = new List<SironTCRIntegration.FlowInputs>();
        SironTCRIntegration.FlowInputs flowInp = new SironTCRIntegration.FlowInputs();
        flowInp.customerId = acc1.Id.toString();
        inputs.add(flowInp);
        
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new SironTCRMockHttpResponseGenerator(200, '{"status":"success"}'));
        
        // Act
        Test.startTest();
        List<String> results = SironTCRIntegration.updateCustomerInSiron(inputs);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals('Callout initiated for ' + acc1.Id, results.get(0));
        
        // Ensure no System_Action__c records are created
        List<System_Action__c> systemActions = [SELECT Id FROM System_Action__c];
        System.assertEquals(0, systemActions.size());
    }

    // Test method for error HTTP response
    @IsTest
    public static void testUpdateCustomerInSiron_Error() {
        // Arrange
        Account acc1 = [SELECT Id FROM Account WHERE CIF__pc = '5376356'];
        List<SironTCRIntegration.FlowInputs> inputs = new List<SironTCRIntegration.FlowInputs>();
        SironTCRIntegration.FlowInputs flowInp = new SironTCRIntegration.FlowInputs();
        flowInp.customerId = acc1.Id.toString();
        inputs.add(flowInp);
        
        // Mock HTTP response with error
        Test.setMock(HttpCalloutMock.class, new SironTCRMockHttpResponseGenerator(500, '{"error":"Internal Server Error"}'));
        
        // Act
        Test.startTest();
        List<String> results = SironTCRIntegration.updateCustomerInSiron(inputs);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals('Callout initiated for ' + acc1.Id, results.get(0));
        
        // Ensure System_Action__c records are created
        List<System_Action__c> systemActions = [SELECT Id FROM System_Action__c];
        System.assertEquals(1, systemActions.size());
    }

    // Test method for exception handling
    // @IsTest
    // public static void testUpdateCustomerInSiron_Exception() {
    //     // Arrange
    //     Account acc1 = [SELECT Id FROM Account WHERE CIF__pc = '5376356'];
    //     List<SironTCRIntegration.FlowInputs> inputs = new List<SironTCRIntegration.FlowInputs>();
    //     SironTCRIntegration.FlowInputs flowInp = new SironTCRIntegration.FlowInputs();
    //     flowInp.customerId = acc1.Id.toString();
    //     inputs.add(flowInp);
        
    //     // Mock HTTP response to throw an exception
    //     Test.setMock(HttpCalloutMock.class, new HttpCalloutMock() {
    //         global HttpResponse respond(HTTPRequest req) {
    //             throw new CalloutException('Mock Callout Exception');
    //         }
    //     });
        
    //     // Act
    //     Test.startTest();
    //     List<String> results = SironTCRIntegration.updateCustomerInSiron(inputs);
    //     Test.stopTest();
        
    //     // Assert
    //     System.assertEquals(1, results.size());
    //     System.assertEquals('Callout initiated for ' + acc1.Id, results.get(0));
        
    //     // Ensure System_Action__c records are created
    //     List<System_Action__c> systemActions = [SELECT Id FROM System_Action__c];
    //     System.assertEquals(1, systemActions.size());
    // }

    // Test method for empty input
    @IsTest
    public static void testUpdateCustomerInSiron_EmptyInput() {
        // Arrange
        List<SironTCRIntegration.FlowInputs> inputs = new List<SironTCRIntegration.FlowInputs>();
        
        // Act
        Test.startTest();
        List<String> results = SironTCRIntegration.updateCustomerInSiron(inputs);
        Test.stopTest();
        
        // Assert
        System.assertEquals(0, results.size());
        
        // Ensure no System_Action__c records are created
        List<System_Action__c> systemActions = [SELECT Id FROM System_Action__c];
        System.assertEquals(0, systemActions.size());
    }

    // Test method for non-existent Account IDs
    @IsTest
    public static void testUpdateCustomerInSiron_NonExistentAccount() {
        // Arrange
        List<SironTCRIntegration.FlowInputs> inputs = new List<SironTCRIntegration.FlowInputs>();
        SironTCRIntegration.FlowInputs flowInp = new SironTCRIntegration.FlowInputs();
        flowInp.customerId = '001000000000000';
        inputs.add(flowInp);
        
        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new SironTCRMockHttpResponseGenerator(200, '{"status":"success"}'));
        
        // Act
        Test.startTest();
        List<String> results = SironTCRIntegration.updateCustomerInSiron(inputs);
        Test.stopTest();
        
        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals('Callout initiated for 001000000000000', results.get(0));
        
        // Ensure no System_Action__c records are created
        List<System_Action__c> systemActions = [SELECT Id FROM System_Action__c];
        System.assertEquals(0, systemActions.size());
    }
}