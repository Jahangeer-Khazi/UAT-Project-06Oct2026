public class RaffleBulkExclusionController {
    
    @AuraEnabled
    public static String getDrawRegion(String drawId) {
        Draw__c draw = [SELECT RegionFlag__c FROM Draw__c WHERE Id = :drawId LIMIT 1];
        return draw.RegionFlag__c;
    }

    @AuraEnabled
    public static List<Map<String, String>> getParticipantDetails(Id contentDocumentId, String drawId, String prizeType) {
        try {
            ContentVersion contentVersion = [
                SELECT VersionData 
                FROM ContentVersion 
                WHERE ContentDocumentId = :contentDocumentId AND IsLatest = true
                LIMIT 1
            ];
            
            return processCSVContent(contentVersion.VersionData.toString());
        } catch (Exception e) {
            throw new AuraHandledException('Error processing CSV file: ' + e.getMessage());
        }
    }
    
    @TestVisible
    // Helper method to process CSV content
    private static List<Map<String, String>> processCSVContent(String fileContent) {
        List<Map<String, String>> cifList = new List<Map<String, String>>();
        try {
            
            List<String> lines = fileContent.split('\n');
            
            // Check if we have at least a header row and one data row
            if (lines.size() < 2) {
                throw new AuraHandledException('Invalid CSV format. File must contain a header row and at least one data row.');
            }
            
            // Process header row
            String headerRow = lines[0].trim();
            List<String> headers = headerRow.split(',');
            
            // Validate header
            if (headers.size() != 1) {
                throw new AuraHandledException('Invalid CSV format. Only one column named "CIF" is allowed.');
            }
            
            String header = headers[0];

            // Remove BOM, zero-width spaces, and normal spaces
            header = header.replaceAll('[\\u200B-\\u200D\\uFEFF]', '').trim();

            if (header != 'CIF') {
                throw new AuraHandledException('Invalid CSV header. Column must be named "CIF".');
            }
            
            // Process data rows
            for (Integer i = 1; i < lines.size(); i++) {
                String line = lines[i].trim();
                if (String.isBlank(line)) continue;
                
                List<String> values = line.split(',');
                if (values.size() != 1) {
                    throw new AuraHandledException('Invalid row at line ' + (i+1) + '. Only one value per row is allowed.');
                }
                
                String cif = values[0].trim();
                if (String.isNotBlank(cif)) {
                    if (!cif.isNumeric()) {
                        throw new AuraHandledException('Invalid CIF format at line ' + (i+1) + ': ' + cif + '. CIF must contain only numbers.');
                    }
                    
                    Map<String, String> cifMap = new Map<String, String>();
                    cifMap.put('CIF', cif);
                    cifList.add(cifMap);
                }
            }
            
            if (cifList.isEmpty()) {
                throw new AuraHandledException('No valid CIF numbers found in the uploaded file.');
            }
            
            return cifList;
        } Catch (Exception e) {
            System.debug('Error LineNumber -->'+e.getLineNumber());
            System.debug('Error Message -->'+e.getMessage());
            return cifList;
        }
        
    }
    
    @AuraEnabled
    public static void saveBulkExclusions(List<Map<String, Object>> records, List<Id> contentDocumentIds) {
        try {
            List<Draw_Entry_Review__c> exclusionsToCreate = new List<Draw_Entry_Review__c>();
            
            for (Map<String, Object> record : records) {
                // Create exclusion record
                Draw_Entry_Review__c exclusion = new Draw_Entry_Review__c();
                exclusion.CIF__c = (String)record.get('CIF');
                exclusion.Justification__c = (String)record.get('justification');
                exclusion.Draw__c = (String)record.get('drawId');
                exclusion.Prize_Type__c = (String)record.get('prizeType');
                exclusion.Category__c = 'EXC';
                exclusionsToCreate.add(exclusion);
            }
            
            if (!exclusionsToCreate.isEmpty()) {
                insert exclusionsToCreate;
                
                // Delete all uploaded files after processing
                if (contentDocumentIds != null && !contentDocumentIds.isEmpty()) {
                    delete [SELECT Id FROM ContentDocument WHERE Id IN :contentDocumentIds];
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error saving bulk exclusions: ' + e.getMessage());
        }
    }
}