public class ReturnedCardBulkController {
    
    public class ValidationResult {
        @AuraEnabled public Boolean success;
        @AuraEnabled public String message;
        @AuraEnabled public List<Map<String, Object>> parsedData;
        @AuraEnabled public List<ValidationError> errors;
        @AuraEnabled public List<ValidationError> warnings;
    }
    
    public class ValidationError {
        @AuraEnabled public String id;
        @AuraEnabled public Integer rowNumber;
        @AuraEnabled public String awb;
        @AuraEnabled public String cif;
        @AuraEnabled public String cardType;
        @AuraEnabled public Date pickupDate;
        @AuraEnabled public String returnedReason;
        @AuraEnabled public String status;
        @AuraEnabled public String message;
    }
    
    public class BatchResult {
        @AuraEnabled public String batchId;
        @AuraEnabled public Integer totalRecords;
        @AuraEnabled public Integer successfulRecords;
        @AuraEnabled public Integer failedRecords;
    }
    
    @AuraEnabled
public static ValidationResult validateFile(String contentDocumentId, String region) {
    ValidationResult result = new ValidationResult();
    result.success = false;
    result.errors = new List<ValidationError>();
    result.warnings = new List<ValidationError>();
    result.parsedData = new List<Map<String, Object>>();
    
    try {
        if (String.isBlank(contentDocumentId)) {
            result.message = 'File content is empty';
            return result;
        }
        
        if (String.isBlank(region) || (!region.equals('Bahrain') && !region.equals('Jordan'))) {
            result.message = 'Invalid region selected. Please select Bahrain or Jordan.';
            return result;
        }
        
        // Use existing working class
        List<Map<String, String>> fileData = CSVFileReadLWCCntrl.readExcelFile(contentDocumentId);
        
        if (fileData == null || fileData.isEmpty()) {
            result.message = 'Upload failed. The file is empty or contains no data.';
            return result;
        }
        
        System.debug('Raw file data size: ' + fileData.size());
        System.debug('First row: ' + JSON.serialize(fileData[0]));
        System.debug('Selected Region: ' + region);
        
        // Parse each row
        Integer rowNumber = 0;
        Boolean hasEmptyCIFError = false;
        Boolean isFirstRow = true;
        
        // Store header mapping
        Map<String, Integer> headerMap = new Map<String, Integer>();
        
        // Store parsed data for batch processing
        List<Map<String, Object>> parsedRows = new List<Map<String, Object>>();
        List<String> cifsToCheck = new List<String>();
        List<String> awbCifKeys = new List<String>();
        
        for (Map<String, String> rowData : fileData) {
            rowNumber++;
            
            if (rowData == null || rowData.isEmpty()) continue;
            
            // Get the actual CSV row data
            List<String> values = new List<String>();
            
            // Check if the map has a single key with comma-separated values
            if (rowData.size() == 1) {
                String singleValue = rowData.values()[0];
                if (String.isNotBlank(singleValue)) {
                    // Parse the single string as CSV
                    if (singleValue.contains('\t')) {
                        values = singleValue.split('\t');
                    } else {
                        values = singleValue.split(',');
                    }
                }
            } else {
                // Map has multiple keys (index-based)
                for (Integer i = 0; i < rowData.size(); i++) {
                    String key = String.valueOf(i);
                    if (rowData.containsKey(key)) {
                        String value = rowData.get(key);
                        if (value != null) {
                            values.add(value.trim());
                        } else {
                            values.add('');
                        }
                    }
                }
            }
            
            // Trim all values
            for (Integer i = 0; i < values.size(); i++) {
                if (values[i] != null) {
                    values[i] = values[i].trim();
                } else {
                    values[i] = '';
                }
            }
            
            System.debug('Row ' + rowNumber + ' values size: ' + values.size());
            System.debug('Row ' + rowNumber + ' values: ' + JSON.serialize(values));
            
            // Skip empty rows
            if (values.isEmpty() || (values.size() == 1 && String.isBlank(values[0]))) {
                System.debug('Skipping empty row: ' + rowNumber);
                continue;
            }
            
            // Handle header row - build column mapping
            if (isFirstRow) {
                isFirstRow = false;
                
                // Build header map (case insensitive)
                for (Integer i = 0; i < values.size(); i++) {
                    if (String.isNotBlank(values[i])) {
                        headerMap.put(values[i].toLowerCase(), i);
                    }
                }
                
                // Check if this looks like a header row
                Boolean isHeaderRow = false;
                for (String val : values) {
                    if (String.isNotBlank(val)) {
                        String lowerVal = val.toLowerCase();
                        if (lowerVal.contains('awb') || lowerVal.contains('pickupdate') || 
                            lowerVal.contains('cif') || lowerVal.contains('shipperreference') ||
                            lowerVal.contains('commoditydescription') || lowerVal.contains('awb number')) {
                            isHeaderRow = true;
                            break;
                        }
                    }
                }
                
                if (isHeaderRow) {
                    System.debug('Skipping header row: ' + rowNumber);
                    continue;
                }
            }
            
            // Parse based on region - USING HEADER NAMES INSTEAD OF INDICES
            String awb = '';
            String pickupDateStr = '';
            String commodityDesc = '';
            String shipperReference = '';
            String lastStatusComments1 = '';
            
            if (region == 'Bahrain') {
                // Bahrain columns mapping
                while (values.size() < 12) {
                    values.add('');
                }
                
                // Get values by header name (case insensitive)
                awb = headerMap.containsKey('awb') ? values[headerMap.get('awb')] : '';
                pickupDateStr = headerMap.containsKey('pickupdate') ? values[headerMap.get('pickupdate')] : '';
                commodityDesc = headerMap.containsKey('commoditydescription') ? values[headerMap.get('commoditydescription')] : '';
                shipperReference = headerMap.containsKey('shipperreference') ? values[headerMap.get('shipperreference')] : '';
                lastStatusComments1 = headerMap.containsKey('laststatuscomments1') ? values[headerMap.get('laststatuscomments1')] : '';
                
            } else if (region == 'Jordan') {
                // Jordan columns mapping
                while (values.size() < 8) {
                    values.add('');
                }
                
                // Get values by header name (case insensitive)
                awb = headerMap.containsKey('awb') ? values[headerMap.get('awb')] : '';
                pickupDateStr = headerMap.containsKey('pickupdate') ? values[headerMap.get('pickupdate')] : '';
                commodityDesc = headerMap.containsKey('commoditydescription') ? values[headerMap.get('commoditydescription')] : '';
                lastStatusComments1 = headerMap.containsKey('returned reason') ? values[headerMap.get('returned reason')] : '';
                shipperReference = headerMap.containsKey('shipperreference') ? values[headerMap.get('shipperreference')] : '';
            }
            
            System.debug('Parsed - Region: ' + region + ', AWB: ' + awb + ', CIF: ' + shipperReference + ', Commodity: ' + commodityDesc + ', Reason: ' + lastStatusComments1);
            
            // Check if CIF is empty - mandatory validation
            if (String.isBlank(shipperReference)) {
                hasEmptyCIFError = true;
                ValidationError error = new ValidationError();
                error.id = String.valueOf(rowNumber);
                error.rowNumber = rowNumber;
                error.awb = String.isBlank(awb) ? 'N/A' : awb;
                error.cif = 'EMPTY';
                error.cardType = String.isBlank(commodityDesc) ? 'N/A' : commodityDesc;
                error.pickupDate = null;
                error.returnedReason = String.isBlank(lastStatusComments1) ? 'N/A' : lastStatusComments1;
                error.status = 'Error';
                error.message = 'CIF is mandatory and cannot be empty. Please provide ShipperReference value.';
                result.errors.add(error);
                continue;
            }
            
            // Parse date
            Date pickupDate = parseDate(pickupDateStr);
            
            // Create a map for this row
            Map<String, Object> rowMap = new Map<String, Object>();
            rowMap.put('rowNumber', rowNumber);
            rowMap.put('awb', awb);
            rowMap.put('cif', shipperReference);
            rowMap.put('commodityDesc', commodityDesc);
            rowMap.put('pickupDate', pickupDate);
            rowMap.put('lastStatusComments1', lastStatusComments1);
            
            parsedRows.add(rowMap);
            
            // Collect CIFs for batch query
            if (String.isNotBlank(shipperReference)) {
                cifsToCheck.add(shipperReference);
            }
            
            // Collect AWB+CIF combinations for duplicate check
            if (String.isNotBlank(shipperReference) && String.isNotBlank(awb)) {
                awbCifKeys.add(shipperReference + '|' + awb);
            }
        }
        
        // Batch query 1: Get all valid accounts
        Map<String, Id> validCIFs = new Map<String, Id>();
        if (!cifsToCheck.isEmpty()) {
            for (Account acc : [SELECT Id, CIF__pc FROM Account WHERE CIF__pc IN :cifsToCheck]) {
                if (String.isNotBlank(acc.CIF__pc)) {
                    validCIFs.put(acc.CIF__pc, acc.Id);
                }
            }
        }
        
        // Batch query 2: Get all duplicate cases
        Set<String> duplicateKeys = new Set<String>();
        if (!awbCifKeys.isEmpty()) {
            // Build OR conditions for query
            List<Returned_Cards__c> existingCases = [
                SELECT Id, Name, Customer__r.CIF__pc, AWB__c 
                FROM Returned_Cards__c 
                WHERE Status__c != 'Closed'
                LIMIT 10000
            ];
            
            // Filter in memory
            for (Returned_Cards__c caseRec : existingCases) {
                String key = caseRec.Customer__r.CIF__pc + '|' + caseRec.AWB__c;
                if (awbCifKeys.contains(key)) {
                    duplicateKeys.add(key);
                }
            }
        }
        
        // Batch query 3: Get replacement cases (last 90 days)
        Map<String, Boolean> replacementWarnings = new Map<String, Boolean>();
        if (!cifsToCheck.isEmpty()) {
            Date startDate = Date.today().addDays(-90);
            List<Returned_Cards__c> recentCases = [
                SELECT Id, Customer__r.CIF__pc 
                FROM Returned_Cards__c 
                WHERE Customer__r.CIF__pc IN :cifsToCheck 
                AND CreatedDate >= :startDate
                AND Status__c != 'Closed'
                ORDER BY CreatedDate DESC
            ];
            
            for (Returned_Cards__c caseRec : recentCases) {
                if (!replacementWarnings.containsKey(caseRec.Customer__r.CIF__pc)) {
                    replacementWarnings.put(caseRec.Customer__r.CIF__pc, true);
                }
            }
        }
        
        // Now process each row with the batch results
        for (Map<String, Object> rowMap : parsedRows) {
            Integer currentRowNumber = (Integer)rowMap.get('rowNumber');
            String awb = (String)rowMap.get('awb');
            String shipperReference = (String)rowMap.get('cif');
            String commodityDesc = (String)rowMap.get('commodityDesc');
            Date pickupDate = (Date)rowMap.get('pickupDate');
            String lastStatusComments1 = (String)rowMap.get('lastStatusComments1');
            
            ValidationError error = new ValidationError();
            error.id = String.valueOf(currentRowNumber);
            error.rowNumber = currentRowNumber;
            error.awb = awb;
            error.cif = shipperReference;
            error.cardType = commodityDesc;
            error.pickupDate = pickupDate;
            error.returnedReason = lastStatusComments1;
            
            Boolean hasError = false;
            Boolean hasWarning = false;
            
            // 1. Validate AWB
            if (String.isBlank(awb)) {
                error.message = 'AWB is missing';
                hasError = true;
            }
            
            // 2. Validate CIF exists in Salesforce (using batch result)
            if (!hasError && String.isNotBlank(shipperReference)) {
                if (!validCIFs.containsKey(shipperReference)) {
                    error.message = 'Invalid CIF: ' + shipperReference + ' - No account found with this CIF number';
                    hasError = true;
                }
            }
            
            // 3. Validate CardType (CC/DC) based on CommodityDescription
            if (!hasError && String.isNotBlank(commodityDesc)) {
                String cardTypeLower = commodityDesc.toLowerCase();
                if (cardTypeLower.contains('credit')) {
                    commodityDesc = 'CC';
                } else if (cardTypeLower.contains('debit')) {
                    commodityDesc = 'DC';
                } else if (cardTypeLower == 'cc' || cardTypeLower == 'dc') {
                    commodityDesc = cardTypeLower.toUpperCase();
                } else {
                    error.message = 'Invalid CardType. Expected Credit Card or Debit Card. Found: ' + commodityDesc;
                    hasError = true;
                }
            }
            
            // 4. Check for duplicate cases (using batch result)
            if (!hasError && String.isNotBlank(shipperReference) && String.isNotBlank(awb)) {
                String key = shipperReference + '|' + awb;
                if (duplicateKeys.contains(key)) {
                    error.message = 'Duplicate case exists';
                    hasError = true;
                }
            }
            
            // 5. Check for replacement cases (using batch result)
            if (!hasError && String.isNotBlank(shipperReference)) {
                if (replacementWarnings.containsKey(shipperReference)) {
                    error.message = 'Warning: Replacement case exists within 90 days';
                    error.status = 'Warning';
                    hasWarning = true;
                    result.warnings.add(error);
                }
            }
            
            if (hasError) {
                error.status = 'Error';
                result.errors.add(error);
            } else if (!hasWarning) {
                // Create valid record
                Map<String, Object> record = new Map<String, Object>();
                record.put('AWB', awb);
                record.put('CIF', shipperReference);
                record.put('CardType', commodityDesc);
                record.put('PickupDate', pickupDate);
                record.put('ReturnedReason', lastStatusComments1);
                record.put('rowNumber', currentRowNumber);
                record.put('hasError', false);
                
                result.parsedData.add(record);
            }
        }
        
        // Set result message
        if (hasEmptyCIFError) {
            result.message = 'Validation failed: One or more records have empty CIF values. CIF (ShipperReference) is mandatory.';
            result.success = false;
        } else if (result.errors.isEmpty() && result.warnings.isEmpty() && !result.parsedData.isEmpty()) {
            result.success = true;
            result.message = 'Validation successful. ' + result.parsedData.size() + ' records ready for processing.';
        } else if (!result.errors.isEmpty()) {
            result.message = 'Found ' + result.errors.size() + ' errors. Please fix and re-upload.';
        } else if (!result.warnings.isEmpty()) {
            result.success = true;
            result.message = 'Validation completed with ' + result.warnings.size() + ' warnings. You can proceed or cancel.';
        } else {
            result.message = 'No valid data found in file.';
        }
        
    } catch (Exception e) {
        result.message = 'Error processing file: ' + e.getMessage();
        System.debug('Error in validateFile: ' + e.getMessage() + ' at line: ' + e.getLineNumber());
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    System.debug('Validation result: ' + JSON.serialize(result));
    return result;
}
    
    private static Date parseDate(String dateStr) {
        if (String.isBlank(dateStr)) return null;
        
        dateStr = dateStr.trim();
        
        try {
            // Try DD-MM-YYYY format
            if (dateStr.contains('-')) {
                List<String> parts = dateStr.split('-');
                if (parts.size() == 3) {
                    Integer day = Integer.valueOf(parts[0].trim());
                    Integer month = Integer.valueOf(parts[1].trim());
                    Integer year = Integer.valueOf(parts[2].trim());
                    return Date.newInstance(year, month, day);
                }
            }
            
            // Try DD/MM/YYYY format
            if (dateStr.contains('/')) {
                List<String> parts = dateStr.split('/');
                if (parts.size() == 3) {
                    Integer day = Integer.valueOf(parts[0].trim());
                    Integer month = Integer.valueOf(parts[1].trim());
                    Integer year = parts[2].length() == 2 ? 2000 + Integer.valueOf(parts[2].trim()) : Integer.valueOf(parts[2].trim());
                    return Date.newInstance(year, month, day);
                }
            }
            
            // Try standard format (YYYY-MM-DD)
            if (dateStr.contains('-') && dateStr.split('-')[0].length() == 4) {
                return Date.valueOf(dateStr);
            }
            
            return null;
        } catch (Exception e) {
            System.debug('Error parsing date: ' + dateStr + ' - ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static BatchResult createBatch(List<Map<String, Object>> records, String fileName, String contentDocumentId, String region) {
        BatchResult result = new BatchResult();
        result.successfulRecords = 0;
        result.failedRecords = 0;
        Map<String, Id> accountByCIF = new Map<String, Id>();
        Map<String, String> cifByContactId = new Map<String, String>();
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            String nameWithoutExtension = fileName.substring(0, fileName.lastIndexOf('.'));
            // Create Batch Operation
            Returned_Card_Bulk_Operation__c batchOp = new Returned_Card_Bulk_Operation__c(
                Returned_Card_Bulk_Operation_Name__c = 'Returned Cards - ' + nameWithoutExtension + System.now().format('yyyy-MM-dd HH:mm'),
                Type__c = 'Returned Cards',
                Status__c = 'Pending',
                Start_Time__c = System.now(),
                Region__c = region // Store region in batch operation
            );
            insert batchOp;
            result.batchId = batchOp.Id;
            
            // Create records
            List<Returned_Cards__c> cardsToInsert = new List<Returned_Cards__c>();
            
            // Get account mapping
            Set<String> cifNumbers = new Set<String>();
            for (Map<String, Object> record : records) {
                String cif = (String)record.get('CIF');
                if (String.isNotBlank(cif)) {
                    cifNumbers.add(cif);
                }
            }
            
            if (!cifNumbers.isEmpty()) {
                for (Account acc : [SELECT Id, CIF__pc, PersonContactId FROM Account WHERE CIF__pc IN :cifNumbers]) {
                    accountByCIF.put(acc.CIF__pc, acc.Id);
                    cifByContactId.put(acc.CIF__pc, acc.PersonContactId);
                }
            }
            
            Integer recordCount = 0;
            for (Map<String, Object> record : records) {
                recordCount++;
                
                try {
                    String cif = (String)record.get('CIF');
                    String awb = (String)record.get('AWB');
                    String cardType = (String)record.get('CardType');
                    String pickupDateStr = (String)record.get('PickupDate');
                    Date pickupDate = Date.valueOf(pickupDateStr);
                    String reason = (String)record.get('ReturnedReason');
                    
                    // Map card type
                    String cardTypeDisplay = 'CC'.equals(cardType) ? 'Credit Card' : 'Debit Card';
                    
                    // Create Returned Card record
                    Returned_Cards__c newCard = new Returned_Cards__c(
                        Customer__c = accountByCIF.get(cif),
                        AWB__c = awb,
                        CIF__c = cif,
                        CardType__c = cardTypeDisplay,
                        Pick_up_Date__c = pickupDate,
                        Returned_Reason__c = reason,
                        Returned_Card_Bulk_Operation__c = batchOp.Id,
                        Status__c = 'Open',
                        Sub_Status__c = 'Pending For Pick-up',
                        Description__c = 'Card returned to the bank by the courier and awaiting customer action.',
                        Awaiting_Customer_3rd_Party_Feedback__c = true,
                        Reason__c = 'Pending on customer response',
                        Contact__c = cifByContactId.get(cif)
                    );

                    if (region == 'Bahrain') {

                        Date todayDate = Date.today();
                        Date dateIn30Days = todayDate.addDays(30);
                        newCard.SLA_Remaining_Time__c = dateIn30Days;

                    } else if (region == 'Jordan') {

                        if(cardTypeDisplay == 'Credit Card') {
                            Date todayDate = Date.today();
                            Date dateIn90Days = todayDate.addDays(90);
                            newCard.SLA_Remaining_Time__c = dateIn90Days;
                        } else if (cardTypeDisplay == 'Debit Card') {
                            Date todayDate = Date.today();
                            Date dateIn30Days = todayDate.addDays(30);
                            newCard.SLA_Remaining_Time__c = dateIn30Days;
                        }

                    }
                    
                    cardsToInsert.add(newCard);
                    result.successfulRecords++;
                    
                } catch (Exception e) {
                    result.failedRecords++;
                    
                    String cif = (String)record.get('CIF');
                    
                    // Create failed detail
                    Returned_Cards__c detail = new Returned_Cards__c(
                        Returned_Card_Bulk_Operation__c = batchOp.Id,
                        Customer__c = accountByCIF.get(cif),
                        AWB__c = (String)record.get('AWB'),
                        Status__c = 'Closed',
                        CIF__c = cif,
                        Error_Message__c = e.getMessage().left(255),
                        Row_Number__c = recordCount
                    );
                    cardsToInsert.add(detail);
                }
            }
            
            // Insert all records
            if (!cardsToInsert.isEmpty()) insert cardsToInsert;
            
            // Link uploaded file
            if (String.isNotBlank(contentDocumentId)) {
                ContentDocumentLink cdl = new ContentDocumentLink(
                    ContentDocumentId = contentDocumentId,
                    LinkedEntityId = batchOp.Id,
                    ShareType = 'I'
                );
                insert cdl;
            }
            
            // Update batch status
            batchOp.Successful_Records__c = result.successfulRecords;
            batchOp.Failed_Records__c = result.failedRecords;
            batchOp.Status__c = 'Pending';
            batchOp.End_Time__c = System.now();
            if (System.Label.Returned_Card_Checker_Queue != null) {
                batchOp.OwnerId = System.Label.Returned_Card_Checker_Queue;
            }
            update batchOp;
            
            result.totalRecords = records.size();
            
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Error creating batch: ' + e.getMessage());
        }
        
        return result;
    }
    
    // Helper method to upload file
    @AuraEnabled
    public static String uploadFile(String fileName, String base64Data, String region) {
        try {
            // Create content version
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = EncodingUtil.base64Decode(base64Data);
            cv.IsMajorVersion = true;
            insert cv;
            
            // Get content document id
            ContentVersion contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            return contentVersion.ContentDocumentId;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading file: ' + e.getMessage());
        }
    }
}