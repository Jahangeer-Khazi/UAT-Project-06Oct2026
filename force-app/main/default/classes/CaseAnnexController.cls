/**
 * @description       : Controller class for Case Annex management
 * @author            : AITOGRAM Omar
 * @last modified on  : 07-17-2024
 * @last modified by  : AITOGRAM Omar
 * 
 * changes :   #CH01# AITOGRAM Omar 07-14-2026 – Synchronous Fawri cancellation gate added to updateRecordsWithRollback  [NBA-15906].
**/
public without sharing class CaseAnnexController {

    @AuraEnabled(cacheable=true)
    public static List<Case_Annex__mdt> getConfigJson(String subtype, String type, String recTypeDveloperName) {
        System.debug('subtype >> ' + subtype);
        System.debug('type >> ' + type);
        System.debug('recordType >> ' + recTypeDveloperName);
        if (String.isBlank(subtype) || String.isBlank(type) || String.isBlank(recTypeDveloperName)) {
            throw new AuraHandledException('Subtype or Type or recordType parameters cannot be empty.');
        }

        try {
          
            List<Case_Annex__mdt> metadataList = [SELECT JSON_Value__c
                                                  FROM Case_Annex__mdt
                                                  WHERE SubTypeValue__c = :subtype AND TypeValue__c = :type AND RecordType_DeveloperName__c  = :recTypeDveloperName];
            // System.debug('metadataList >> ' + metadataList);
            return metadataList;
        } catch (Exception e) {
            System.debug('Exception in getConfigJson: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching configuration JSON.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getCaseAnnexFields(Id recordId) {
        if (recordId == null) {
            throw new AuraHandledException('Record Id cannot be null.');
        }

        try {
            List<String> results = new List<String>();
            String query = 'SELECT ';
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.CaseAnnex__c.fields.getMap();
            // System.debug('fieldMap :: ' + fieldMap);

            for (String fieldName : fieldMap.keySet()) {
                query += fieldName + ', ';
            }

            query = query.substring(0, query.length() - 2);
            query += ' FROM CaseAnnex__c WHERE Case__c = :recordId LIMIT 1';

            List<CaseAnnex__c> caseAnnexRecords = Database.query(query);

            for (CaseAnnex__c record : caseAnnexRecords) {
                Map<String, Object> recordMap = new Map<String, Object>();
                
                for (String fieldName : fieldMap.keySet()) {
                    recordMap.put(fieldName, record.get(fieldName));
                }
                results.add(JSON.serialize(recordMap, true));
            }
            // System.debug('results :: ' + results);
            return results;
        } catch (Exception e) {
            System.debug('Exception in getCaseAnnexFields: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching Case Annex fields.');
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getCaseFields(Id recordId) {
        // System.debug('recordId >> ' + recordId);
        
        if (recordId == null) {
            throw new AuraHandledException('Record Id cannot be null.');
        }

        try {
            Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Case.fields.getMap();
            List<String> fieldNames = new List<String>();
            for (String fieldName : fieldMap.keySet()) {
                fieldNames.add(fieldName);
            }
            String soqlQuery = 'SELECT ' + String.join(fieldNames, ', ') + ' FROM Case WHERE Id = :recordId LIMIT 1';
            System.debug('SOQL Query: ' + soqlQuery);

            Case caseRecord = Database.query(soqlQuery);

            Map<String, Object> result = new Map<String, Object>();
            for (String fieldName : fieldMap.keySet()) {
                Object fieldValue = caseRecord.get(fieldName);
                if(fieldValue != null){
                    result.put(fieldName, fieldValue);
                } else {
                    result.put(fieldName, null);
                }
            }
            // System.debug(caseRecord);
            return JSON.serialize(result, true);
        } catch (Exception e) {
            System.debug('Exception in getCaseFields: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching Case fields.');
        }
    }


    @AuraEnabled
    public static void updateRecordsWithRollback(Case cas, CaseAnnex__c caseAnnexe) {

        // #CH01# – Start: Fawri cancellation
        Case storedCase = [
            SELECT Id,
                RecordType_DeveloperName__c,
                Type,
                Sub_Type__c,
                cc_Checker_Result__c
            FROM Case
            WHERE Id = :cas.Id
            LIMIT 1
        ];

        Boolean isFawriCancellationApproval =
            storedCase.Type == 'Funds Transfer' &&
            storedCase.Sub_Type__c == 'Fawri Cancellation Request' &&
            storedCase.RecordType_DeveloperName__c == 'Request' && 
            cas.cc_Checker_Result__c != null;
            
            system.debug('New Case cancellation  :'+ cas);
            system.debug('New Case cancellation  :'+ cas.cc_Checker_Result__c);
            system.debug('New Case cancellation  :'+ cas.Id);
        if (isFawriCancellationApproval ) {
              // Check if the current user is in the checker queue
              if( cas.cc_Checker_Result__c == 'Approve' ||  cas.cc_Checker_Result__c == 'Reject'){
                    if (!CaseFawriTransferController.isUserInCheckerQueue()) 
                     {
                          throw new AuraHandledException('PERMISSION_ERROR:You are not authorized to ' + cas.cc_Checker_Result__c +  ' Fawri cancellation requests.');
                     }
                }
           
                if( cas.cc_Checker_Result__c == 'Approve'){
                    System.debug('>>> Fawri cancellation approval detected.');

                    try {

                        CancelFawriService.CancelResult cancelResult =
                            CancelFawriService.callCancelSync(cas.Id);

                        if (!cancelResult.isSuccess) {

                            String errorDetail = String.isNotBlank(cancelResult.metaCode)
                                ? cancelResult.metaCode + ' - ' + cancelResult.message
                                : cancelResult.message;

                            System.debug('>>> Fawri cancellation FAILED: ' + errorDetail);
                            if ((errorDetail != null && errorDetail.startsWith('MISSING_BATCH_ID')) || (errorDetail != null && errorDetail.startsWith('MISSING_REF_NUMBER'))) {
                                System.debug('>>> Error starts with MISSING_BATCH_ID Or MISSING_REF_NUMBER');
                                    throw new AuraHandledException(
                                'There is no transaction found for this Case'
                            );
                            }
                            else{
                                throw new AuraHandledException(
                                'Fawri cancellation could not be approved because the payment is already settled.'
                            );
                            }
                          
                        }
                       cas.put('Last_Api_Call_Status__c', cancelResult.isSuccess ? 'Success' : 'Failed');
                       cas.put('Status','Closed');
                       cas.put('Sub_Status__c','Closed');
                       System.debug('>>> Fawri cancellation SUCCEEDED.');
                        // return;
                        

                    } catch (AuraHandledException e) {
                       
                        throw e;

                    } catch (Exception e) {

                        System.debug('>>> Unexpected exception during Fawri cancellation:');
                        System.debug(e.getStackTraceString());

                        throw new AuraHandledException(
                            'Unable to verify the Fawri cancellation status. Please try again or contact support.'
                        );
                    }
                }
        }
          

        // #CH01# – End: Fawri cancellation




         Savepoint sp = Database.setSavepoint(); // Create a savepoint for rollback

        try {
            // Update Case record
            system.debug('New Case :'+ cas);
            update cas;

            // Update CaseAnnex__c record
            system.debug('New caseAnnex :'+ caseAnnexe);
            //update caseAnnexe;
            if (caseAnnexe != null && caseAnnexe.Id != null) {
        update caseAnnexe;
    }
        } catch (Exception e) {
            Database.rollback(sp); // Rollback to the savepoint if any error occurs
            // throw new AuraHandledException(e.getMessage());
            throw e;
        }
    }

    @AuraEnabled
    public static String getOwnerDeveloperName(String ownerid) {
        // Only queues are stored in Group with Type = 'Queue'
        system.debug('Fetch owner developerName '+ownerId);
        Group g = [
            SELECT DeveloperName 
            FROM Group 
            WHERE Id = :ownerId AND Type = 'Queue'
            LIMIT 1
        ];
        return g != null ? g.DeveloperName : null;
    }
}