/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 20/06/2024
*       Change History: 
*/
@RestResource(urlMapping='/bulkDeleteAuditRecords')
global class DeleteAuditRecordsRestAPI {
    @HttpPost
    global static void deleteAccounts() {
        Integer batchsize = Integer.valueOf(System.Label.BATCH_SIZE_TO_DELETE_AUDIT_RECORDS);
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Extract the JSON array of Audit Record Ids from the request body
            String requestBody = req.requestBody.toString();
            // Parse the JSON array into a list of IDs
            List<String> audIds = (List<String>) JSON.deserialize(requestBody, List<String>.class);
            System.debug('Audit Ids After De-serialize Size:'+audIds.size());
            List<Customer_Pages_Audit_Trail__c> auditRecordsToDelete = new List<Customer_Pages_Audit_Trail__c>();
            
            if(System.Label.ENABLE_AUDIT_BATCH_TO_DELETE_RECORDS.equalsIgnoreCase('true')){
                DeleteAuditRecordsBatch delAuditBtach = new DeleteAuditRecordsBatch(audIds);
                ID auditBatchId = Database.executeBatch(delAuditBtach,batchsize);
                // Set a successful response
                res.statusCode = 200;
                res.responseBody = Blob.valueOf('{"success": true, "message": "Audit Job started to delete audit records"}');
            }
            else if(System.Label.ENABLE_AUDIT_BATCH_TO_DELETE_RECORDS.equalsIgnoreCase('false')){
                for(String audId : audIds) {
                    Customer_Pages_Audit_Trail__c auditId = new Customer_Pages_Audit_Trail__c();
                    auditId.Id = audId;
                    auditRecordsToDelete.add(auditId);
                }
                // Delete the Audit records
                delete auditRecordsToDelete;//1 DML Operation
                database.emptyRecycleBin(auditRecordsToDelete); //2 DML Operation
                // Set a successful response
            	res.statusCode = 200;
            	res.responseBody = Blob.valueOf('{"success": true, "message": "Audit Records deleted"}');
            }
		}catch (DmlException e) {
            // Handle DML exceptions and set an error response
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"success": false, "message": "Failed to delete Audit Records: ' + e.getDmlMessage(0) + '"}');
        }catch (Exception e) {
            // Handle general exceptions and set an error response
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('{"success": false, "message": "An unexpected error occurred: ' + e.getMessage() + '"}');
        }
    }

}