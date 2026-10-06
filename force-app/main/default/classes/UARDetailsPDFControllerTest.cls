@isTest
public class UARDetailsPDFControllerTest {

    @isTest
    static void testUARDetailsPDFController() {
        // Create test data
        Account testAccount = new Account();
        testAccount.FirstName = 'TestIla';
        testAccount.LastName = 'TestIla';
        testAccount.PersonEmail = 'testclass@ilatest123.com';
        testAccount.Region_Flag__c = 'Bahrain';
        testAccount.Region_Flag__pc = 'Bahrain';
        insert testAccount;

        UAR__c testUAR = new UAR__c(
            Account__c = testAccount.Id,
            Case_Model__c = 'ila',
            Type__c = 'ATM',
            Sub_Type__c = 'ATM Withdrawal',
            Transaction_Amount__c = 100.000,
            Subject__c = 'Testing',
            Description__c = 'Testing',
            Typology__c = 'Funneling;Charity front;Identity Theft;Cash Smurfing;3rd party use;Fraud;Fraud Peer-to-Peer / pooling funds;	Fraud Investment middleman;Business Use;Gambling;Others',
            MLRO_decision__c = 'Submit an STR',
            Withdrawal_Channels__c = 'ATM',
            Deposit_Channels__c = 'ATM',
            Declared_source_of_funds_del__c = 'Source;Source2',
            Transaction_Date__c = Date.today()
        );
        insert testUAR;
        
        testUAR.Compliance_Result__c = 'Approved';
        update testUAR;

        // Create test content versions
        ContentVersion cv1 = new ContentVersion(
            Title = 'Test Document 1',
            PathOnClient = 'test1.pdf',
            VersionData = Blob.valueOf('Test Content 1'),
            IsMajorVersion = true
        );
        insert cv1;

        ContentVersion cv2 = new ContentVersion(
            Title = 'Test Document 2',
            PathOnClient = 'test2.pdf',
            VersionData = Blob.valueOf('Test Content 2'),
            IsMajorVersion = true
        );
        insert cv2;

        ContentDocumentLink cdl1 = new ContentDocumentLink(
            LinkedEntityId = testAccount.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv1.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl1;

        ContentDocumentLink cdl2 = new ContentDocumentLink(
            LinkedEntityId = testAccount.Id,
            ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv2.Id].ContentDocumentId,
            ShareType = 'V'
        );
        insert cdl2;

        // Create a standard controller instance
        ApexPages.StandardController sc = new ApexPages.StandardController(testUAR);

        // Instantiate the controller
        UARDetailsPDFController controller = new UARDetailsPDFController(sc);

        // Call the init method
        ApexPages.currentPage().getParameters().put('download', 'true');
        controller.init();

        // Call the getFormattedDate method
        String formattedDate = controller.getFormattedDate();

        // Call the getFormattedTodayDate method
        String formattedTodayDate = controller.getFormattedTodayDate();
    }
}