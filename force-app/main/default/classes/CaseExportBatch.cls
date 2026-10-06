/**
* @File Name : CaseExportBatch.cls
* @Description : Batch class to generate CSV for case aging report and send email
* @Author : 
* @Last Modified On : May 20, 2025
* @Modification Log :
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 20, 2025 |   | Initial Version
* 1.1 | May 20, 2025 |   | Added detailed logging and email send result validation
* 1.2 | May 20, 2025 |   | Added fallback to save CSV as Salesforce File
*/
public with sharing class CaseExportBatch implements Database.Batchable<sObject>, Database.Stateful {
    public Map<String, List<String>> teamSubcategories;
    public static final Map<String, List<String>> TEAM_SUBCATEGORIES = DynamicCaseReportController.TEAM_SUBCATEGORIES;
    public String csvContent = '';
    public Integer totalRecordsProcessed = 0;
    public Integer totalRecords;
    public String jobId { get; set; }
    public Integer daysBack { get; set; }
    
    public CaseExportBatch(String dateRange) {
        this.jobId = String.valueOf(System.currentTimeMillis());
        this.teamSubcategories = buildTeamSubcategories(); // Initialize dynamic map
        this.daysBack = (dateRange != null) ? Integer.valueOf(dateRange) : 90;
        Date startDate = System.today().addDays(-this.daysBack);
        this.totalRecords = [SELECT COUNT() FROM Case WHERE CreatedDate >= :startDate AND RecordType.DeveloperName IN ('Case_Disputes_and_Frauds','Complaint','Case_Faults_and_Incidents','Request','Sukuk_Bond_Request') AND SLA__c != null];
        System.debug('CaseExportBatch initialized. Total records to process: ' + totalRecords);
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Starting batch job with JobId: ' + jobId);
        Date startDate = System.today().addDays(-this.daysBack);
        publishProgressEvent('Starting batch job...', 0);
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, Subject, Type, Sub_Type__c, CreatedDate, Status, Owner.Name, cc_Request_Type__c
            FROM Case
            WHERE CreatedDate >= :startDate
            AND RecordType.DeveloperName IN ('Case_Disputes_and_Frauds','Complaint','Case_Faults_and_Incidents','Request','Sukuk_Bond_Request')
            AND SLA__c != null
            ORDER BY CreatedDate DESC
            LIMIT 400000
        ]);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        try {
            System.debug('Processing batch with ' + scope.size() + ' cases');
            Set<Id> caseIds = new Map<Id, Case>(scope).keySet();
            List<Case_Aging_Line_Item__c> lineItems = [
                SELECT Id, Case_Aging__r.Case__c, Group_Queue__c, Previous_Owner__c, New_Owner__c, Case_Aging__r.Case__r.SLA__c,
                Time__c, Changed_By__c, Total_Time__c, Case_Aging__r.Total_Time_Age__c, Case_Aging__r.SLA__c
                FROM Case_Aging_Line_Item__c
                WHERE Case_Aging__r.Case__c IN :caseIds
                ORDER BY Case_Aging__r.Case__c
            ];
            System.debug('Retrieved ' + lineItems.size() + ' Case Aging Line Items');
            
            if (totalRecordsProcessed == 0) {
                csvContent += generateHeaders();
                System.debug('Generated CSV headers: ' + csvContent.substring(0, Math.min(csvContent.length(), 255)));
            }
            
            for (Case c : scope) {
                Map<String, Object> caseRow = new Map<String, Object>{
                    'Id' => c.Id,
                        'Case Number' => c.CaseNumber != null ? c.CaseNumber : '',
                            'Case Subject' => c.Subject != null ? c.Subject : '',
                                'Case Type' => c.Type != null ? c.Type : '',
                                    'Case Sub Type' => c.Sub_Type__c != null ? c.Sub_Type__c : '',
                                        'Case Request Type' => c.cc_Request_Type__c != null ? c.cc_Request_Type__c : '',
                                            'Case Created Date' => c.CreatedDate?.format('yyyy-MM-dd') != null ? c.CreatedDate?.format('yyyy-MM-dd') : '',
                                                'Status' => c.Status != null ? c.Status : '',
                                                    'Case Current Owner' => c.Owner.Name != null ? c.Owner.Name : '',
                                                        'SLA Status' => ''
                                                        };
                                                            
                                                            List<Case_Aging_Line_Item__c> caseLineItems = new List<Case_Aging_Line_Item__c>();
                for (Case_Aging_Line_Item__c li : lineItems) {
                    if (li.Case_Aging__r.Case__c == c.Id) {
                        caseLineItems.add(li);
                        caseRow.put('Case SLA', li.Case_Aging__r.Case__r.SLA__c != null ? li.Case_Aging__r.Case__r.SLA__c : 60);
                        caseRow.put('Total Time', li.Case_Aging__r.Total_Time_Age__c != null ? li.Case_Aging__r.Total_Time_Age__c : 0);
                        // Calculate SLA Status based on the logic from DynamicCaseReportController
                        Decimal caseSLA = li.Case_Aging__r.Case__r.SLA__c != null ? li.Case_Aging__r.Case__r.SLA__c : 60;
                        Decimal totalTime = li.Case_Aging__r.Total_Time_Age__c != null ? li.Case_Aging__r.Total_Time_Age__c : 0;
                        
                        if (caseSLA >= totalTime && c.Status == 'Closed') {
                            caseRow.put('SLA Status', 'Met');
                        } else if(caseSLA >= totalTime && c.Status != 'Closed') {
                            caseRow.put('SLA Status', 'In Progress');
                        } else {
                            caseRow.put('SLA Status', 'Breached');
                        }
                    }
                }
                
                for (Case_Aging_Line_Item__c li : caseLineItems) {
                    String team = li.Group_Queue__c;
                    List<String> subcategories = this.teamSubcategories.get(team);
                    if (subcategories != null) {
                        for (String subcat : subcategories) {
                            caseRow.put(team + '|' + li.Previous_Owner__c, li.Total_Time__c != null ? li.Total_Time__c : 0);
                        }
                    }
                }
                
                csvContent += generateCsvRow(caseRow);
                totalRecordsProcessed += 1;
                System.debug('Processed case ' + c.Id + '. Total records processed: ' + totalRecordsProcessed);
            }
            
            Decimal progress = ((Decimal)totalRecordsProcessed / totalRecords) * 80;
            System.debug('Batch progress: ' + progress.intValue() + '% (' + totalRecordsProcessed + '/' + totalRecords + ')');
            publishProgressEvent('Processing cases... (' + totalRecordsProcessed + '/' + totalRecords + ')', progress.intValue());
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Batch processing error: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            publishProgressEvent('Error in batch processing: ' + e.getMessage(), 0);
            throw e;
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        try {
            System.debug('CSV generation complete. CSV size: ' + csvContent.length() + ' characters');
            if (String.isBlank(csvContent)) {
                System.debug(LoggingLevel.ERROR, 'CSV content is empty. Cannot send email.');
                publishProgressEvent('Error: No data to export', 0);
                // *** New: Save empty CSV error as a file ***
                saveCsvAsFile('Error: No data to export');
                return;
            }
            
            saveCsvAsFile(csvContent);
            
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{'ranjith.mathiyalagan@bank-abc.com'});
            email.setSubject('Case Aging Report CSV');
            email.setPlainTextBody('Please find the attached Case Aging Report CSV file.');
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            attachment.setFileName('Case_Aging_Report_' + Date.today().format() + '.csv');
            Blob csvBlob = Blob.valueOf(csvContent);
            attachment.setBody(csvBlob);
            attachment.setContentType('text/csv');
            email.setFileAttachments(new List<Messaging.EmailFileAttachment>{attachment});
            
            if ( owea.size() > 0 ) {
                email.setOrgWideEmailAddressId(owea.get(0).Id);
            }
            
            System.debug('Preparing to send email to: ranjith.mathiyalagan@bank-abc.com');
            System.debug('Attachment file name: Case_Aging_Report_' + Date.today().format() + '.csv');
            System.debug('Attachment size: ' + csvBlob.size() + ' bytes');
            
            // *** Modified: Detailed logging of email send result ***
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
            if (results != null && !results.isEmpty()) {
                Messaging.SendEmailResult result = results[0];
                if (result.isSuccess()) {
                    System.debug('Email sent successfully to ranjith.mathiyalagan@bank-abc.com');
                    publishProgressEvent('Export completed and email sent!', 100);
                } else {
                    String errorMessage = 'Email send failed: ';
                    for (Messaging.SendEmailError err : result.getErrors()) {
                        errorMessage += err.getMessage() + '; ';
                    }
                    System.debug(LoggingLevel.ERROR, errorMessage);
                    publishProgressEvent('Error sending email: ' + errorMessage, 0);
                    // *** New: Save CSV as a file if email fails ***
                    saveCsvAsFile(csvContent);
                }
            } else {
                System.debug(LoggingLevel.ERROR, 'No email send results returned');
                publishProgressEvent('Error: No email send results returned', 0);
                // *** New: Save CSV as a file if no results ***
                saveCsvAsFile(csvContent);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in finish method: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            publishProgressEvent('Error sending email: ' + e.getMessage(), 0);
            // *** New: Save CSV as a file on exception ***
            saveCsvAsFile(csvContent);
        }
    }
    
    // *** New: Method to save CSV as a Salesforce File ***
    public void saveCsvAsFile(String content) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Case_Aging_Report_' + Date.today().format();
            cv.PathOnClient = 'Case_Aging_Report_' + Date.today().format() + '.csv';
            cv.VersionData = Blob.valueOf(content);
            cv.ContentLocation = 'S'; // S for Salesforce
            insert cv;
            System.debug('Saved CSV as Salesforce File with ContentVersion Id: ' + cv.Id);
            publishProgressEvent('Email failed, but CSV saved as Salesforce File (ContentVersion Id: ' + cv.Id + ')', 0);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error saving CSV as file: ' + e.getMessage() + '\nStack Trace: ' + e.getStackTraceString());
            publishProgressEvent('Error saving CSV as file: ' + e.getMessage(), 0);
        }
    }
    
    public String generateHeaders() {
        List<Column> fixedColumns = getFixedColumns();
        List<String> teamHeaders = new List<String>(TEAM_SUBCATEGORIES.keySet());
        List<DynamicColumn> dynamicColumns = buildDynamicColumns(teamHeaders);
        
        String headerRow1 = '';
        String headerRow2 = '';
        
        for (Column col : fixedColumns) {
            headerRow1 += '"' + col.label + '",';
            headerRow2 += '"",';
        }
        
        for (DynamicColumn team : dynamicColumns) {
            headerRow1 += '"' + team.label + '",';
            for (Integer i = 1; i < team.colspan; i++) {
                headerRow1 += '"",';
            }
            for (String subcat : team.subcategories) {
                headerRow2 += '"' + subcat + '",';
            }
        }
        
        String headers = headerRow1.removeEnd(',') + '\n' + headerRow2.removeEnd(',') + '\n';
        System.debug('Generated headers: ' + headers.substring(0, Math.min(headers.length(), 255)));
        return headers;
    }
    
    public String generateCsvRow(Map<String, Object> caseRow) {
        String row = '';
        List<Column> fixedColumns = getFixedColumns();
        List<String> teamHeaders = new List<String>(TEAM_SUBCATEGORIES.keySet());
        List<DynamicColumn> dynamicColumns = buildDynamicColumns(teamHeaders);
        
        for (Column col : fixedColumns) {
            Object value = caseRow.get(col.label);
            row += '"' + (value != null ? String.valueOf(value).escapeCsv() : '') + '",';
        }
        
        for (DynamicColumn team : dynamicColumns) {
            for (String subcat : team.subcategories) {
                String key = team.label + '|' + subcat;
                Object value = caseRow.get(key);
                row += '"' + (value != null ? String.valueOf(value).escapeCsv() : '0') + '",';
            }
        }
        
        String csvRow = row.removeEnd(',') + '\n';
        System.debug('Generated CSV row: ' + csvRow.substring(0, Math.min(csvRow.length(), 255)));
        return csvRow;
    }
    
    public void publishProgressEvent(String status, Integer progress) {
        Case_Export_Progress__e event = new Case_Export_Progress__e(
            JobId__c = this.jobId,
            Status__c = status,
            Progress__c = progress,
            ErrorMessage__c = progress == 0 && status.contains('Error') ? status : ''
        );
        try {
            Database.SaveResult result = EventBus.publish(event);
            System.debug('Published progress event: ' + status + ' (' + progress + '%) | Success: ' + result.isSuccess());
            if (!result.isSuccess()) {
                for (Database.Error err : result.getErrors()) {
                    System.debug('Event publish error: ' + err.getMessage());
                }
            }
            System.debug('Published progress event: ' + status + ' (' + progress + '%)');
        } catch (Exception e) {
            System.debug('Error publishing progress event: ' + e.getMessage());
        }
    }
    
    public class Column {
        @AuraEnabled public String label;
        @AuraEnabled public Integer colspan;
        @AuraEnabled public Integer rowspan;
        
        public Column(String label, Integer colspan, Integer rowspan) {
            this.label = label;
            this.colspan = colspan;
            this.rowspan = rowspan;
        }
    }
    
    public class DynamicColumn {
        @AuraEnabled public String label;
        @AuraEnabled public Integer colspan;
        @AuraEnabled public Integer rowspan;
        @AuraEnabled public List<String> subcategories;
        
        public DynamicColumn(String label, Integer colspan, Integer rowspan, List<String> subcategories) {
            this.label = label;
            this.colspan = colspan;
            this.rowspan = rowspan;
            this.subcategories = subcategories;
        }
    }
    
    public static List<Column> getFixedColumns() {
        return new List<Column>{
            new Column('Case Number', 1, 2),
                new Column('Case Subject', 1, 2),
                new Column('Case Type', 1, 2),
                new Column('Case Sub Type', 1, 2),
                new Column('Case Request Type', 1, 2),
                new Column('Case Created Date', 1, 2),
                new Column('Case SLA', 1, 2),
                new Column('Status', 1, 2),
                new Column('Case Current Owner', 1, 2),
                new Column('Total Time', 1, 2),
                new Column('SLA Status', 1, 2) // Added this line
                };
                    }
    
    public List<DynamicColumn> buildDynamicColumns(List<String> teamHeaders) {
        List<DynamicColumn> columns = new List<DynamicColumn>();
        
        for(String team : teamHeaders) {
            List<String> subcategories = this.teamSubcategories.get(team);
            if(subcategories != null && !subcategories.isEmpty()) {
                columns.add(new DynamicColumn(
                    team, 
                    subcategories.size(),
                    1,
                    subcategories
                ));
            }
        }
        
        return columns;
    } 
    
    public static Map<String, List<String>> buildTeamSubcategories() {
        Map<String, List<String>> teamSubcategories = DynamicCaseReportController.TEAM_SUBCATEGORIES.clone();
        Set<String> existingSubcategories = getAllExistSubcategories(teamSubcategories);
        
        Set<String> individualOwners = new Set<String>();
        
        // Query for all distinct Previous_Owner__c values not in existing subcategories
        for(AggregateResult ar : [
            SELECT Previous_Owner__c 
            FROM Case_Aging_Line_Item__c 
            WHERE Previous_Owner__c != null 
            GROUP BY Previous_Owner__c
        ]) {
            String owner = (String)ar.get('Previous_Owner__c');
            if(!existingSubcategories.contains(owner)) {
                individualOwners.add(owner);
            }
        }
        
        // Update the TEAM_SUBCATEGORIES map (only for Individuals key)
        if(!individualOwners.isEmpty()) {
            teamSubcategories.put('Individuals', new List<String>(individualOwners));
        }
        
        return teamSubcategories;
    }
    
    public static Set<String> getAllExistSubcategories(Map<String, List<String>> teamSubcategories) {
        Set<String> allSubcategories = new Set<String>();
        for(List<String> subcats : teamSubcategories.values()) {
            allSubcategories.addAll(subcats);
        }
        return allSubcategories;
    }
    
    public static Set<String> getAllExistingSubcategories() {
        Set<String> allSubcategories = new Set<String>();
        for(List<String> subcats : TEAM_SUBCATEGORIES.values()) {
            allSubcategories.addAll(subcats);
        }
        return allSubcategories;
    }
}