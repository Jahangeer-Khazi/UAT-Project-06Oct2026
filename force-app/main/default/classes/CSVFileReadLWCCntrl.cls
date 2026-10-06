/**
* @File Name : CSVFileReadLWCCntrl.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : February 19, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | February 19, 2025 |   | Initial Version
**/

public class CSVFileReadLWCCntrl {
    @AuraEnabled
    public static List<Map<String, String>> readExcelFile(Id contentDocumentId) {

    System.debug(LoggingLevel.INFO, 'readExcelFile START | ContentDocumentId = ' + contentDocumentId);

    List<Map<String, String>> recordsList = new List<Map<String, String>>();

    if (contentDocumentId == null) {
        System.debug(LoggingLevel.WARN, 'ContentDocumentId is NULL. Exiting method.');
        return recordsList;
    }

    ContentVersion contentVersion;
    try {
        contentVersion = [
            SELECT Id, VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            LIMIT 1
        ];
        System.debug(LoggingLevel.INFO, 'ContentVersion fetched | Id = ' + contentVersion.Id);
    } catch (Exception e) {
        System.debug(LoggingLevel.ERROR, 'Error fetching ContentVersion: ' + e.getMessage());
        return recordsList;
    }

    Blob excelBlob = contentVersion.VersionData;
    String excelString = excelBlob.toString();

    System.debug(LoggingLevel.INFO, 'Excel file size (chars) = ' + excelString.length());

    List<String> rows = excelString.split('\n');
    System.debug(LoggingLevel.INFO, 'Total rows found = ' + rows.size());

    if (rows.size() <= 1) {
        System.debug(LoggingLevel.WARN, 'No data rows found in Excel file.');
        return recordsList;
    }

    List<String> headers = rows[0].split('\t');
    System.debug(LoggingLevel.INFO, 'Headers count = ' + headers.size());
    System.debug(LoggingLevel.INFO, 'Headers = ' + headers);

    for (Integer i = 0; i < rows.size(); i++) {

        if (String.isBlank(rows[i])) {
            System.debug(LoggingLevel.WARN, 'Skipping empty row at index ' + i);
            continue;
        }

        List<String> values = rows[i].split('\t');
        Map<String, String> rowData = new Map<String, String>();

        for (Integer j = 0; j < headers.size(); j++) {
            if (j < values.size()) {
                rowData.put(headers[j], values[j]);
            } else {
                rowData.put(headers[j], null);
            }
        }

        recordsList.add(rowData);

        System.debug(
            LoggingLevel.DEBUG,
            'Processed row ' + i + ' | Column count = ' + rowData.size()
        );
    }

    System.debug(LoggingLevel.INFO, 'readExcelFile END | Total records parsed = ' + recordsList.size());

    return recordsList;
    }
    @AuraEnabled
    public static Bulk_Operation__c saveBulkOperation(List<Map<String, Object>> records, String operationType, String contentDocumentId) {
        try {
            // Create parent record
            Bulk_Operation__c bulkOperation = new Bulk_Operation__c(
                Type__c = operationType,
                Status__c = 'Maker Review',
                ownerId = System.Label.Bulk_Block_Unblock_Maker
            );
            insert bulkOperation;
            
            // Create child records if records list is not empty
            if (!records.isEmpty()) {
                List<Bulk_Operation_Detail__c> detailRecords = new List<Bulk_Operation_Detail__c>();
                for (Map<String, Object> record : records) {
                    detailRecords.add(new Bulk_Operation_Detail__c(
                        Bulk_Operation__c = bulkOperation.Id,
                        CIF__c = (String) record.get('CIF'),
                        Subject__c = (String) record.get('Subject'),
                        Model__c = (String) record.get('Model'),
                        Type__c = (String) record.get('Type'),
                        Sub_Type__c = (String) record.get('SubType'),
                        Case_Nature__c = (String) record.get('CaseNature'),
                        Reason__c = (String) record.get('Reason'),
                        Origin__c = (String) record.get('Origin'),
                        IBAN__c = (String) record.get('IBAN'),
                        All_Accounts__c = (Boolean) record.get('AllAccounts'),
                        Block_App_Access__c = (Boolean) record.get('BlockAppAccess'),
                        Blacklist__c = (Boolean) record.get('Blacklist'),
                        Is_Fraud__c = (Boolean) record.get('isFraud'),
                        Status__c = 'Pending'
                    ));
                }
                insert detailRecords;
            }

            // Associate the ContentDocument to the Bulk_Operation__c record
            if (String.isNotBlank(contentDocumentId)) {
                ContentDocumentLink contentLink = new ContentDocumentLink(
                    ContentDocumentId = contentDocumentId,
                    LinkedEntityId = bulkOperation.Id,
                    ShareType = 'I' // 'I' for Inferred permission
                );
                insert contentLink;
            }
            
            return bulkOperation;
        } catch (Exception e) {
            System.debug('Error Line number -->'+e.getLineNumber() + e.getMessage());
            throw new AuraHandledException('Error occurred while saving bulk operation: ' + e.getMessage());
        }
    }
}