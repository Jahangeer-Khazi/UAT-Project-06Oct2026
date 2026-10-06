@isTest
public class ReturnedCardBulkControllerTest {
    
    @testSetup
    static void setupTestData() {
        
            Account bahrainAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='1293779', Region_Flag__c='Bahrain', Region_Flag__pc='Bahrain'), 'TestFactoryDefaults.AccountDefaults',true);
            Account jordanAccount = (Account)TestDataFactory.createSObject(new Account(CIF__pc='12349678', Region_Flag__c='Jordan', Region_Flag__pc='Jordan'), 'TestFactoryDefaults.AccountDefaults',true);
            
            Returned_Card_Bulk_Operation__c returnedCard = new Returned_Card_Bulk_Operation__c(
                Type__c = 'Returned Cards'
            );
            insert returnedCard;
            System.debug(bahrainAccount.Region_Flag__pc);
            // Create existing returned card for duplicate check
            Returned_Cards__c existingCard = new Returned_Cards__c(
                Customer__c = bahrainAccount.Id,
                RegionFlag__c=bahrainAccount.Region_Flag__pc,
                AWB__c = 'AWB123456',
                CIF__c = '1293779',
                Status__c = 'Open',
                Sub_Status__c = 'Pending For Pick-up',
                
                Returned_Card_Bulk_Operation__c = returnedCard.Id
            );
            insert existingCard;
        
    }
    
    @isTest
    static void testValidateFileBahrainValid() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference,ShipperName,ConsigneeName,ConsigneeAddress,ConsigneeTel,LastStatusComments1,LastStatusComments2\n' +
            'AWB001,15-06-2026,1,Credit Card,SHIP001,1293779,Shipper Name,Consignee Name,Address,1234567890,Card damaged,Comments';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test_bahrain.csv';
        cv.PathOnClient = 'test_bahrain.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileBahrainWithWarnings() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference,ShipperName,ConsigneeName,ConsigneeAddress,ConsigneeTel,LastStatusComments1,LastStatusComments2\n' +
            'AWB002,15-06-2026,1,Credit Card,SHIP002,12349678,Shipper Name,Consignee Name,Address,1234567890,Card damaged,Comments';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test_bahrain_warning.csv';
        cv.PathOnClient = 'test_bahrain_warning.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileJordanValid() {
        String csvContent = 'AWB,PickupDate,CommodityDescription,ShipperName,ConsigneeName,ConsigneeTel,LastStatusComments2,ShipperReference\n' +
            'AWB003,15-06-2026,Debit Card,Shipper Name,Consignee Name,1234567890,Card lost,12349678';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test_jordan.csv';
        cv.PathOnClient = 'test_jordan.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Jordan'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileEmptyContent() {
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile('', 'Bahrain');
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileInvalidRegion() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\nAWB004,15-06-2026,1,Credit Card,SHIP004,1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test.csv';
        cv.PathOnClient = 'test.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'InvalidRegion'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileEmptyData() {
        String csvContent = ' Test ';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'empty.csv';
        cv.PathOnClient = 'empty.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileMissingCIF() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            'AWB005,15-06-2026,1,Credit Card,SHIP005,';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'missing_cif.csv';
        cv.PathOnClient = 'missing_cif.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileInvalidCIF() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            'AWB006,15-06-2026,1,Credit Card,SHIP006,INVALIDCIF123';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'invalid_cif.csv';
        cv.PathOnClient = 'invalid_cif.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileDuplicateCase() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            'AWB123456,15-06-2026,1,Credit Card,SHIP001,1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'duplicate.csv';
        cv.PathOnClient = 'duplicate.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileMultipleRows() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            'AWB007,15-06-2026,1,Credit Card,SHIP007,1293779\n' +
            'AWB008,20-06-2026,1,Debit Card,SHIP008,12349678';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'multiple_rows.csv';
        cv.PathOnClient = 'multiple_rows.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithMixedCardTypes() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            'AWB009,15-06-2026,1,cc,SHIP009,1293779\n' +
            'AWB010,20-06-2026,1,dc,SHIP010,12349678\n' +
            'AWB011,25-06-2026,1,Invalid Type,SHIP011,1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'mixed_card_types.csv';
        cv.PathOnClient = 'mixed_card_types.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testCreateBatchSuccess() {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        Map<String, Object> record1 = new Map<String, Object>();
        record1.put('AWB', 'AWB012');
        record1.put('CIF', '1293779');
        record1.put('CardType', 'CC');
        record1.put('PickupDate', Date.today());
        record1.put('ReturnedReason', 'Card damaged');
        records.add(record1);
        
        Map<String, Object> record2 = new Map<String, Object>();
        record2.put('AWB', 'AWB013');
        record2.put('CIF', '12349678');
        record2.put('CardType', 'DC');
        record2.put('PickupDate', Date.today());
        record2.put('ReturnedReason', 'Card lost');
        records.add(record2);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'test_batch.csv';
        cv.PathOnClient = 'test_batch.csv';
        cv.VersionData = Blob.valueOf('test data');
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        try{
        ReturnedCardBulkController.BatchResult result = ReturnedCardBulkController.createBatch(
            records, 'test_batch.csv', insertedCV.ContentDocumentId, 'Bahrain'
        );}catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateBatchWithError() {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        Map<String, Object> record1 = new Map<String, Object>();
        record1.put('AWB', '');
        record1.put('CIF', '1293779');
        record1.put('CardType', 'CC');
        record1.put('PickupDate', Date.today());
        record1.put('ReturnedReason', 'Test');
        records.add(record1);
        
        Test.startTest();
        try{
        ReturnedCardBulkController.BatchResult result = ReturnedCardBulkController.createBatch(
            records, 'test_error.csv', null, 'Jordan'
        );
         }catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateBatchWithNoContentDocument() {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        Map<String, Object> record1 = new Map<String, Object>();
        record1.put('AWB', 'AWB014');
        record1.put('CIF', '1293779');
        record1.put('CardType', 'CC');
        record1.put('PickupDate', Date.today());
        record1.put('ReturnedReason', 'Test reason');
        records.add(record1);
        
        Test.startTest();
        try{
        ReturnedCardBulkController.BatchResult result = ReturnedCardBulkController.createBatch(
            records, 'test_no_doc.csv', null, 'Bahrain'
        );
         }catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateBatchWithException() {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        Map<String, Object> record1 = new Map<String, Object>();
        record1.put('AWB', 'AWB015');
        record1.put('CIF', 'NonExistentCIF');
        record1.put('CardType', 'CC');
        record1.put('PickupDate', Date.today());
        record1.put('ReturnedReason', 'Test');
        records.add(record1);
        
        Test.startTest();
        try {
            ReturnedCardBulkController.BatchResult result = ReturnedCardBulkController.createBatch(
                records, 'test_exception.csv', null, 'Bahrain'
            );
        } catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateBatchForDebitCard() {
        List<Map<String, Object>> records = new List<Map<String, Object>>();
        
        Map<String, Object> record1 = new Map<String, Object>();
        record1.put('AWB', 'AWB016');
        record1.put('CIF', '1293779');
        record1.put('CardType', 'DC');
        record1.put('PickupDate', Date.today());
        record1.put('ReturnedReason', 'Card expired');
        records.add(record1);
        
        Test.startTest();
         try {
        ReturnedCardBulkController.BatchResult result = ReturnedCardBulkController.createBatch(
            records, 'test_debit.csv', null, 'Jordan'
        );
         }catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUploadFile() {
        String fileName = 'test_upload.csv';
        String base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));
        
        Test.startTest();
        String contentDocumentId = ReturnedCardBulkController.uploadFile(fileName, base64Data, 'Bahrain');
        Test.stopTest();
    }
    
    @isTest
    static void testUploadFileException() {
        String fileName = 'test_upload.csv';
        String base64Data = null;
        
        Test.startTest();
        try {
            String contentDocumentId = ReturnedCardBulkController.uploadFile(fileName, base64Data, 'Bahrain');
        } catch (Exception e) {
            // Expected exception
        }
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithTabDelimited() {
        String csvContent = 'AWB\tPickupDate\tPCS\tCommodityDescription\tShipperNumber\tShipperReference\n' +
            'AWB017\t15-06-2026\t1\tCredit Card\tSHIP017\t1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'tab_delimited.csv';
        cv.PathOnClient = 'tab_delimited.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithDateFormats() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            'AWB018,15/06/2026,1,Credit Card,SHIP018,1293779\n' +
            'AWB019,2026-06-15,1,Debit Card,SHIP019,12349678\n' +
            'AWB020,invalid-date,1,Credit Card,SHIP020,1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'date_formats.csv';
        cv.PathOnClient = 'date_formats.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileJordanWithMinimalColumns() {
        String csvContent = 'AWB,PickupDate,CommodityDescription,ShipperReference\n' +
            'AWB021,15-06-2026,Credit Card,12349678';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'jordan_minimal.csv';
        cv.PathOnClient = 'jordan_minimal.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Jordan'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithEmptyRows() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            '\n' +
            'AWB022,15-06-2026,1,Credit Card,SHIP022,1293779\n' +
            '\n' +
            'AWB023,20-06-2026,1,Debit Card,SHIP023,12349678';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'empty_rows.csv';
        cv.PathOnClient = 'empty_rows.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithInsufficientColumns() {
        String csvContent = 'AWB,PickupDate\n' +
            'AWB024,15-06-2026';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'insufficient_columns.csv';
        cv.PathOnClient = 'insufficient_columns.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithNullValues() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            ',,,Credit Card,,1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'null_values.csv';
        cv.PathOnClient = 'null_values.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
    
    @isTest
    static void testValidateFileWithMissingAWB() {
        String csvContent = 'AWB,PickupDate,PCS,CommodityDescription,ShipperNumber,ShipperReference\n' +
            ',15-06-2026,1,Credit Card,SHIP025,1293779';
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'missing_awb.csv';
        cv.PathOnClient = 'missing_awb.csv';
        cv.VersionData = Blob.valueOf(csvContent);
        cv.IsMajorVersion = true;
        insert cv;
        
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        
        Test.startTest();
        ReturnedCardBulkController.ValidationResult result = ReturnedCardBulkController.validateFile(
            insertedCV.ContentDocumentId, 'Bahrain'
        );
        Test.stopTest();
    }
}