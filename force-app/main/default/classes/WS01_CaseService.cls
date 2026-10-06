@RestResource(urlMapping='/CaseService/*')
global without sharing class WS01_CaseService {
    // Relationship field name between Case and CaseAnnex__c
    private static final String CASE_RELATIONSHIP_FIELD = 'Case__c';
    private static final List<String> REQUIRED_FIELDS = new List<String>{
                                                                            'RecordType', 
                                                                            'Contact', 
                                                                            'Subject', 
                                                                            'description', 
                                                                            'Origin', 
                                                                            'Type', 
                                                                            'Sub_Type__c', 
                                                                            'Case_Nature__c', 
                                                                            'case_Model__c'
                                                                        };
    @HttpPost
    global static ResponseWrapper createCaseWithAnnex() {
        Savepoint sp = Database.setSavepoint();
        RestResponse res = RestContext.response;
        Map<String, Object> requestData = new Map<String, Object>();
        try {
            requestData = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        } catch (Exception e) {
            res.statusCode = 400;
            System.debug('Error e.getMessage(): '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Unexpected error: ' + e.getStackTraceString());
            return new ErrorResponseWrapper(false, 'BAD_REQUEST', e.getMessage());
        }
        try {
            // Initialize response object
            res = RestContext.response != null ? RestContext.response : new RestResponse();
            
            
            if (RestContext.request.requestBody == null) {
                res.statusCode = 400;
                return new ErrorResponseWrapper(false, 'BAD_REQUEST', 'Empty request body');
            }
            // Parse request directly into field map
            // Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
            Map<String, Object> requestDataTemp = new Map<String, Object> ();
            // Create a map to store SobjectType as the key and RecordType Id as the value
            Map<String, Id> recordTypeMap = new Map<String, Id>();

            for (String key : requestData.keySet()) {
                requestDataTemp.put(key.toLowerCase(), requestData.get(key));
            }


            for(String fieldName: REQUIRED_FIELDS){
                if (!requestDataTemp.containsKey(fieldName.toLowerCase()) ) {
                    res.statusCode = 400;
                    return new ErrorResponseWrapper(false, 'MISSING_FIELD', fieldName + ' is required');
                }
            }
            

            // Split fields between Case and CaseAnnex__c
            Case newCase = new Case();
            CaseAnnex__c newCaseAnnex = new CaseAnnex__c();
            
            // Store field access metadata before looping
            Map<String, Schema.SObjectField> caseFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();
            Map<String, Schema.SObjectField> annexFields = Schema.getGlobalDescribe().get('CaseAnnex__c').getDescribe().fields.getMap();

            for (String fieldName : requestData.keySet()) {
                System.debug('Processing field: ' + fieldName);
                
                if (fieldName.toLowerCase().startsWith('cx_')) {
                    if (!annexFields.containsKey(fieldName)) {
                        res.statusCode = 400;
                        return new ErrorResponseWrapper(false, 'INVALID_FIELD', 'Invalid annex field: ' + fieldName);
                    }
                    ////////////////////////
                    Object value = requestData.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = annexFields.get(fieldName).getDescribe();
                    Schema.DisplayType fieldType = fieldDescribe.getType();

                    if (fieldType == Schema.DisplayType.DATE) {
                        try {
                            value = Date.valueOf((String)value); // Proper date string like "2032-04-28"
                        } catch (Exception e) {
                            return new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName);
                        }
                    }
                    else if (fieldType == Schema.DisplayType.DATETIME) {
                        try {
                            value = parseUtcString((String)value);// Proper date string like "2032-04-28 12:27:36"
                        } catch (Exception e) {
                            return new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName);
                        }
                    }
                     
                    // newCaseAnnex.put(fieldName, requestData.get(fieldName));
                    newCaseAnnex.put(fieldName, value);

                    ////////////////////////////7

            
                }
                else if (fieldName.toLowerCase().equals('contact')) { 
                    Map<String, Object> contactInfo = (Map<String, Object>) requestData.get(fieldName);
                    String cif = String.valueOf(contactInfo.get('CIF__c'));

                    if (String.isBlank(cif)) {
                        res.statusCode = 400;
                        return new ErrorResponseWrapper(false, 'MISSING_FIELD', 'Contact.CIF__c is required');
                    }
                    if (!Schema.sObjectType.Contact.isAccessible()) {
                        res.statusCode = 403;
                        return new ErrorResponseWrapper(false, 'ACCESS_DENIED', 'Contact access denied');
                    }
            
                    if (!String.isBlank(cif)) {
                        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE CIF__c = :cif LIMIT 1];
            
                        if (contacts.isEmpty()) {
                            res.statusCode = 404;
                            return new ErrorResponseWrapper(false,'INVALID_FIELD', 'Foreign key external ID: ' + cif + ' not found for field CIF__c in entity Contact');
                        }
            
                        // Set both ContactId and AccountId for PersonAccount
                        newCase.put('ContactId', contacts[0].Id);
                        newCase.put('AccountId', contacts[0].AccountId);
                    }
                    
                    continue; 

                } else if (fieldName.toLowerCase().equals('recordtype')) { 
                    Map<String, Object> recordtype = (Map<String, Object>) requestData.get(fieldName);
                    String recordTypeName = String.valueOf(recordtype.get('Name'));

                    if (String.isBlank(recordTypeName)) {
                        continue;
                    }
            
                    // Query RecordType records with the specified DeveloperName
                    List<RecordType> recordTypes = [
                        SELECT Id, SobjectType, DeveloperName 
                        FROM RecordType 
                        WHERE Name =: recordTypeName 
                    ];
                    // Populate the map
                    for (RecordType rt : recordTypes) {
                        recordTypeMap.put(rt.SobjectType, rt.Id);
                    }
            
                    if (!recordTypeMap.containsKey('Case')) {
                        res.statusCode = 404;
                        return new ErrorResponseWrapper(false,'INVALID_FIELD', 'No recordType was found with the DeveloperName: ' + fieldName );
                    }
        
                    newCase.put('RecordTypeId', recordTypeMap.get('Case'));

                    if (recordTypeMap.containsKey('CaseAnnex__c')) {
                        newCaseAnnex.put('RecordTypeId', recordTypeMap.get('CaseAnnex__c'));
                    }
                    continue; 
                }
                else {
                    if (!caseFields.containsKey(fieldName)) {
                        res.statusCode = 400;
                        return new ErrorResponseWrapper(false, 'INVALID_FIELD', 'Invalid case field: ' + fieldName);
                    }
                    ////////////////////////
                    Object value = requestData.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = caseFields.get(fieldName).getDescribe();
                    Schema.DisplayType fieldType = fieldDescribe.getType();

                    if (fieldType == Schema.DisplayType.DATE) {
                        try {
                            value = Date.valueOf((String)value); // Proper date string like "2032-04-28"
                        } catch (Exception e) {
                            return new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName);
                        }
                    }
                    else if (fieldType == Schema.DisplayType.DATETIME) {
                        try {
                            value = parseUtcString((String)value);// Proper date string like "2032-04-28 12:27:36"
                        } catch (Exception e) {
                            return new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName);
                        }
                    }
                    
                    newCase.put(fieldName, value);
                }
            }
            
            // Check create permissions
            if (!Schema.sObjectType.Case.isCreateable()) {
                res.statusCode = 403;
                return new ErrorResponseWrapper(false, 'ACCESS_DENIED', 'Case create access denied');
            }
            insert newCase;
            
            newCaseAnnex.put(CASE_RELATIONSHIP_FIELD, newCase.Id);            
            if (!Schema.sObjectType.CaseAnnex__c.isCreateable()) {
                res.statusCode = 403;
                return new ErrorResponseWrapper(false, 'ACCESS_DENIED', 'CaseAnnex__c create access denied');
            }

            //insert newCaseAnnex; //to reduce the time of creation from app move this line to queueable Method
            
            Case cs = [SELECT Id, caseNumber,accountId FROM Case WHERE Id = :newCase.Id];
            res.statusCode = 201;

            if(RestContext.request.requestBody != null){
                insert  SM001_ApiCalls.setSystemAction( 
                            null,RestContext.request.requestBody.toString(),
                            '/CaseService/createCaseWithAnnex','POST',
                            cs.id,null,cs.accountId,null, 
                            'WS01-> createCaseWithAnnex (called via BE)', null
                        );
            }
            System.enqueueJob(new CreateCaseAnnexProcessJob(newCaseAnnex));
            return new SuccessResponseWrapper(true, newCase.id, cs.caseNumber);

        } catch (DmlException e) {
            Database.rollback(sp);
            res.statusCode = 400;
            return new ErrorResponseWrapper(false, 'VALIDATION_ERROR', e.getMessage());
        } catch (QueryException e) {
            Database.rollback(sp);
            res.statusCode = 400;
            return new ErrorResponseWrapper(false, 'QUERY_ERROR', e.getMessage());
        } catch (Exception e) {
            Database.rollback(sp);
            res.statusCode = 500;
            System.debug('Error e.getMessage(): '+e.getMessage());
            System.debug(LoggingLevel.ERROR, 'Unexpected error: ' + e.getStackTraceString());
            return new ErrorResponseWrapper(false, 'INTERNAL_ERROR', 'An unexpected error occurred');
        }
        
    }


    @HttpPatch
    global static void updateCaseWithAnnex() {
        System.debug('updateCaseWithAnnex() --> ');
        Savepoint sp = Database.setSavepoint();
        RestResponse res = RestContext.response;
        try {
            // Initialize response
            res = RestContext.response != null ? RestContext.response : new RestResponse();
            res.addHeader('Content-Type', 'application/json');
            // Extract Case ID from URL
            String[] uriParts = RestContext.request.requestURI.split('/');
            String caseId = uriParts[uriParts.size()-1];
            System.debug(LoggingLevel.ERROR, 'caseId ==: ' + caseId);
            // Validate request body
            if (RestContext.request.requestBody == null) {
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'BAD_REQUEST', 'Empty request body')));
                return;
            }
            
            Map<String, Object> requestData = (Map<String, Object>)JSON.deserializeUntyped(
                RestContext.request.requestBody.toString()
            );

            // Retrieve the existing Case and CaseAnnex__c
            Case existingCase;
            CaseAnnex__c existingAnnex;
            List<Case> caseRecords = [SELECT Id, ContactId, AccountId FROM Case  WHERE Id = :caseId LIMIT 1 FOR UPDATE];
            List<CaseAnnex__c> caseAnnexRecords = [SELECT Id FROM CaseAnnex__c  WHERE Case__c = :caseId LIMIT 1 FOR UPDATE];

            if (caseRecords.isEmpty() ) {
                res.statusCode = 404;
                res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'NOT_FOUND', 'Case not found')));
                return;
            }
            System.debug(LoggingLevel.ERROR, 'caseRecords: ' + caseRecords);
            existingCase = caseRecords[0];
            if (!caseAnnexRecords.isEmpty()) {
                existingAnnex = caseAnnexRecords[0];
            }
    
            // Split fields between Case and Annex
            Map<String, Schema.SObjectField> caseFieldMap = Schema.SObjectType.Case.fields.getMap();
            Map<String, Schema.SObjectField> annexFieldMap = Schema.SObjectType.CaseAnnex__c.fields.getMap();
            
            for (String fieldName : requestData.keySet()) {
                System.debug('fieldName --> '+fieldName);
                if (fieldName.toLowerCase().startsWith('cx_')) {
                    if (!annexFieldMap.containsKey(fieldName)) {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_FIELD', 'Invalid annex field: ' + fieldName)));
                        return;
                    }
                    ////////////////////////
                    Object value = requestData.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = annexFieldMap.get(fieldName).getDescribe();
                    Schema.DisplayType fieldType = fieldDescribe.getType();

                    if (fieldType == Schema.DisplayType.DATE) {
                        try {
                            value = Date.valueOf((String)value); // Proper date string like "2032-04-28"
                        } catch (Exception e) {
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName)));
                        }
                    }
                    else if (fieldType == Schema.DisplayType.DATETIME) {
                        try {
                            value = parseUtcString((String)value);// Proper date string like "2032-04-28 12:27:36"
                        } catch (Exception e) {
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName)));
                        }
                    }

                    ////////////////////////////7
                    System.debug('existingAnnex.fieldName --> '+fieldName + '; value --> ' + value);
                    existingAnnex.put(fieldName, value);
                } 
                else if (fieldName == 'Contact') {
                    Map<String, Object> contactInfo = (Map<String, Object>) requestData.get('Contact');
                    String cif = String.valueOf(contactInfo.get('CIF__c'));
                    
                    if (String.isBlank(cif)) {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_FIELD', 'Foreign key external ID: not found for field CIF__c in entity Contact')));
                        return;
                    }
                    
                    List<Contact> contacts = [SELECT Id, AccountId FROM Contact 
                                            WHERE CIF__c = :cif LIMIT 1];
                    if (contacts.isEmpty()) {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_FIELD', 'Foreign key external ID: ' + cif + ' not found for field CIF__c in entity Contact')));
                        return;
                    }
                    
                    existingCase.put('ContactId', contacts[0].Id);
                    existingCase.put('AccountId', contacts[0].AccountId);
                } 
                else {
                    if (!caseFieldMap.containsKey(fieldName)) {
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_FIELD', 'Invalid case field: ' + fieldName)));
                        return;
                    }
                    ////////////////////////
                    Object value = requestData.get(fieldName);
                    Schema.DescribeFieldResult fieldDescribe = caseFieldMap.get(fieldName).getDescribe();
                    Schema.DisplayType fieldType = fieldDescribe.getType();

                    
                    if (fieldType == Schema.DisplayType.DATE) {
                        try {
                            value = Date.valueOf((String)value); // Proper date string like "2032-04-28"
                        } catch (Exception e) {
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName)));
                        }
                    }
                    else if (fieldType == Schema.DisplayType.DATETIME) {
                        try {
                            value = parseUtcString((String)value);// Proper date string like "2032-04-28 12:27:36"
                        } catch (Exception e) {
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INVALID_DATE', 'Invalid date format for field: ' + fieldName)));
                        }
                    }

                    ////////////////////////////7
                    existingCase.put(fieldName, value);
                    // existingCase.put(fieldName, requestData.get(fieldName));
                    System.debug('existingCase.fieldName --> '+fieldName + '; value --> ' + value);

                }
            }
    
            // Update Case
            if (!Schema.sObjectType.Case.isUpdateable()) {
                System.debug('error case not updateble --> ');
                res.statusCode = 403;
                res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'ACCESS_DENIED', 'Case update access denied')));
                return;
            }
            update existingCase;
            System.debug('update existingCase; --> ');
            

            // Update Case Annex
            if (!Schema.sObjectType.CaseAnnex__c.isUpdateable()) {
                System.debug('error caseAnnex not updateble --> ');
                res.statusCode = 403;
                res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'ACCESS_DENIED', 'Case Annex update access denied')));
                return;
            }
            update existingAnnex;
            System.debug('update existingAnnex; --> ');


            if(RestContext.request.requestBody != null){
                insert  SM001_ApiCalls.setSystemAction( 
                            null,RestContext.request.requestBody.toString(),
                            '/CaseService/updateCaseWithAnnex','PATCH',
                            existingCase.id,null,existingCase.accountId,null, 
                            'WS01-> updateCaseWithAnnex (called via BE)', null
                        );
            }
            
            res.statusCode = 204; // No Content
            res.responseBody = null;
    
        } catch (System.QueryException e) {
            System.debug('System.QueryException e --> ');
            Database.rollback(sp);
            res.statusCode = 404;
            res.responseBody = Blob.valueOf(JSON.serialize(new ErrorResponseWrapper(false, 'NOT_FOUND', 'Case not found')));
            return;

        } catch (DmlException e) {
            System.debug('DmlException e --> ');
            Database.rollback(sp);
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'VALIDATION_ERROR', e.getMessage())));
            return;

        } catch (Exception e) {
            System.debug('Exception e --> ');
            Database.rollback(sp);
            res.statusCode = 500;
            System.debug(LoggingLevel.ERROR, 'Update error: ' + e.getStackTraceString());
            res.responseBody = Blob.valueOf(JSON.serialize( new ErrorResponseWrapper(false, 'INTERNAL_ERROR', e.getMessage() + e.getStackTraceString() )));
            return;
        }
    }

    public static DateTime parseUtcString(String utcString) {
        // Expected format: "yyyy-MM-dd HH:mm:ss"
        List<String> parts = utcString.split(' ');
        List<String> dateParts = parts[0].split('-');
        List<String> timeParts = parts[1].split(':');
    
        Integer year = Integer.valueOf(dateParts[0]);
        Integer month = Integer.valueOf(dateParts[1]);
        Integer day = Integer.valueOf(dateParts[2]);
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        Integer second = Integer.valueOf(timeParts[2]);
    
        return DateTime.newInstanceGMT(year, month, day, hour, minute, second);
    }
    
    

    // Wrapper Classes
    global virtual  class ResponseWrapper {
        global Boolean success;
    }

    // Error Wrapper Class
    global class ErrorResponseWrapper extends ResponseWrapper {
        global String errorCode;
        global String message;
    
        global ErrorResponseWrapper(Boolean success, String errorCode, String message) {
            this.success = success;
            this.errorCode = errorCode;
            this.message = message;
        }
    }

    // Success Wrapper Class
    global class SuccessResponseWrapper extends ResponseWrapper{
        global String id;
        global String caseNumber;
        
        global SuccessResponseWrapper(Boolean success, String id, String caseNumber) {
            this.success = success;
            this.id = id;
            this.caseNumber = caseNumber;
        }

        global SuccessResponseWrapper() {}
    }

    // Inner class to create caseAnnex
    public class CreateCaseAnnexProcessJob implements Queueable {
        private CaseAnnex__c newCaseAnnex;

        public CreateCaseAnnexProcessJob(CaseAnnex__c newCaseAnnex) {
            this.newCaseAnnex = newCaseAnnex;
        }

        public void execute(QueueableContext qc) {
            System.debug('execute Queueable method CreateCaseAnnexProcessJob -- to create case annex record');
            insert newCaseAnnex;
        }
    }
}