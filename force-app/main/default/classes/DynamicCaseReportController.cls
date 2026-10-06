/**
* @File Name : CaseExportController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : May 11, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | May 11, 2025 |   | Initial Version
**/

public with sharing class DynamicCaseReportController {
    // Hardcoded subcategories mapping
    public static final Map<String, List<String>> TEAM_SUBCATEGORIES = new Map<String, List<String>>{
        'Backoffice' => new List<String>{'Back Office Queue', 'CRS Checker Queue', 'Manual Onboarding - Checker Queue', 'Manual Onboarding - Maker Queue', 'Onboarding Support Team', 'Supplementary Maker Queue'},
            'CRM Team' => new List<String>{'Segment Change Checker Queue', 'Segment Change Maker Queue', 'CRM Team'},
                'Compliance Team' => new List<String>{'Business Team', 'Compliance Team', 'Compliance/Business Queue', 'FLoD', 'MLRO'},
                    'Contact Center' => new List<String>{'Contact Center', 'Contact Centre', 'Contact Centre Internal Queue', 'Deceased Customer Contact Center'},
                        'Frauds/dispute' => new List<String>{'Checker (Fraud Checker)', 'CheckerQueue', 'Disputes', 'Fraud team', 'Frauds', 'Maker (Fraud Maker)', 'UAR Checker', 'UAR Compliance', 'UAR Maker', 'Unblock Account Checker Queue'},
                            'HR' => new List<String>{'HR Team'},
                                'Internal Control Unit' => new List<String>{'Dormancy Reactivation ICU Queue', 'ICU - Checker', 'ICU - Maker', 'ICU Queue', 'ICU Relationship Termination Checker', 'ICUTempQueue', 'Internal Control Unit'},
                                    'Operations team' => new List<String>{'ATM', 'Cards', 'Cards-AFS', 'Cheques', 'Debit Card', 'Debit Card Temp Queue', 'Ila Ops Maker', 'Investment Buy Request Checker', 'Investment Buy Request Maker', 'Investment Questionnaire Checker Queue', 'Investment Questionnaire Maker Queue', 'Investment Sell Request Checker', 'Investment Sell Request Maker', 'Investment Sell Request Queue', 'Investment Temp Queue', 'Invitation temp Queue', 'Operations Team', 'Payments & Transfers', 'Support Staff', 'Transfers', 'Vision Plus Queue', 'ila Ops Checker'},
                                        'QA team' => new List<String>{'Canceled Work Permit for VVIP', 'Complaint Team', 'Dormancy Reactivation Approval Queue', 'Dormancy Reactivation Queue', 'QA Team', 'tempQueue_eKYC'},
                                            'RMT' => new List<String>{'Account Closure_Checker Queue', 'Account Closure_Maker Queue', 'Account Closure_Temp Queue', 'Block Account Maker Queue', 'Deceased Customer Validation', 'Dormancy Reactivation RMT Queue', 'In-App Rating Queue', 'Makers Queue', 'Premium temp Queue', 'Prepaid Maker Queue', 'Prepaid QA Queue', 'Prepaid Temp Queue', 'Prospect Archive Checker', 'Prospect Archive Maker', 'RMT'},
                                                'Retail Credit Team' => new List<String>{'Credit Approval', 'Credit Business Team', 'Credit Card Anti Attrition', 'Credit Card CEO Queue', 'Credit Card Checker Queue', 'Credit Card Collection Queue', 'Credit Card Maker Queue', 'Credit Card Operations', 'Credit Card Pre-Screener Queue', 'Credit Card Retention Queue', 'Credit Card Service Center Queue', 'Credit Card Temp Queue', 'Credit Collection Checker', 'Credit Collection Maker', 'Credit Evaluation', 'Credit HR Signature Verification', 'Credit Invitation Temp Queue', 'Credit Risk - Prizeout Manual Review', 'Credit Signature Verification', 'Credit Upgrade Maker Queue', 'Credit Verification', 'Rejected Application Queue'},
                                                    'Sales Team' => new List<String>{'Sales Team'},
                                                        'Service Center' => new List<String>{'Bank Statement Checker Queue', 'Walk-in Service Centre Queue', 'Bank Statement Maker Queue', 'Service Case', 'Service Centre', 'Service Centre Exceptions', 'Service Centre On Boarding'},
                                                            'contact center' => new List<String>{'Dormancy Reactivation Validation Queue'},
                                                                //'exclude' => new List<String>{'Account Interest Rate_Checker Queue', 'Account Interest Rate_Maker Queue', 'Account Services', 'Bahrain Draw Checker', 'Bahrain Draw Maker', 'Bahrain Risk Checker Queue', 'Bahrain Risk Department', 'Fee Waiver Checker Queue', 'Fee Waiver Maker Queue', 'GPH', 'InfoSec', 'Minimum Balance Fee-Checker Queue', 'Minimum Balance Fee-Maker Queue', 'Perform exit interview', 'Proactive Approach', 'Product & Marketing', 'Q1', 'Restriction Checker', 'Restriction Maker', 'Risk', 'Roadshow_Queue', 'SMT_Checker Queue', 'SMT_Maker Queue', 'Senior Manager', 'Waiting Internal', 'WhatsApp Queue'},
                                                                'ila service desk/IT' => new List<String>{'IT', 'ila ServiceDesk'},
                                                                    'Individuals' => new List<String>{''}
    };
        
        @AuraEnabled(cacheable=true)
        public static ReportData getPaginatedReportData(Integer pageNumber, Integer pageSize, String dateRange, String statusFilter, String fromDateStr, String toDateStr) {
            // Input validation
            pageNumber = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
            pageSize = (pageSize != null && pageSize > 0) ? pageSize : 75;
            
            ReportData result = new ReportData();
            Integer offset = (pageNumber - 1) * pageSize;
            Set<String> existingSubcategories = getAllExistingSubcategories();
            
            // Handle date range filtering
            Datetime startDatetime;
            Datetime endDatetime = Datetime.now();
            String dateCondition;
            
            if (dateRange == 'custom') {
                // Custom date range handling
                if (String.isBlank(fromDateStr) || String.isBlank(toDateStr)) {
                    throw new AuraHandledException('Custom date range requires both from and to dates');
                }
                
                Date fromDate = Date.valueOf(fromDateStr);
                Date toDate = Date.valueOf(toDateStr);
                
                if (fromDate > toDate) {
                    throw new AuraHandledException('From date cannot be after To date');
                }
                
                startDatetime = Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
                endDatetime = Datetime.newInstance(toDate, Time.newInstance(23, 59, 59, 999));
                dateCondition = 'CreatedDate >= :startDatetime AND CreatedDate <= :endDatetime';
            } else {
                // Standard date range handling
                Integer days = (dateRange != null && dateRange != 'custom') ? Integer.valueOf(dateRange) : 90;
                startDatetime = Datetime.newInstance(System.today().addDays(-days), Time.newInstance(0, 0, 0, 0));
                dateCondition = 'CreatedDate >= :startDatetime';
            }
            
            // Build base query conditions
            String recordTypes = '(\'Case_Disputes_and_Frauds\',\'Sukuk_Bond_Request\',\'Complaint\',\'Case_Faults_and_Incidents\',\'Request\')';
            String statusCondition = '';
            
            // Add status filter condition
            if (statusFilter == 'open') {
                statusCondition = 'AND Status != \'Closed\'';
            } 
            else if (statusFilter == 'closed') {
                statusCondition = 'AND Status = \'Closed\'';
            }
            
            try {
                // Get total count with filters
                String countQuery = 'SELECT COUNT() FROM Case WHERE ' + dateCondition + 
                    ' AND RecordType.DeveloperName IN ' + recordTypes + ' ' + statusCondition + ' AND SLA__c != null';
                result.totalCount = Database.countQuery(countQuery);
                
                // Get Cases with dynamic query based on date range type
                String caseQuery = 'SELECT Id, CaseNumber, Subject, Type, Sub_Type__c, cc_Request_Type__c, CreatedDate, ' +
                    'Status, Owner.Name FROM Case WHERE ' + dateCondition + 
                    ' AND RecordType.DeveloperName IN ' + recordTypes + ' ' + statusCondition + 
                    ' AND SLA__c != null ORDER BY CreatedDate DESC LIMIT ' + pageSize + ' OFFSET ' + offset;
                
                List<Case> cases = Database.query(caseQuery);
                Set<Id> caseIds = new Map<Id, Case>(cases).keySet();
                
                // Get Line Items
                List<Case_Aging_Line_Item__c> lineItems = [
                    SELECT Id, Case_Aging__r.Case__c, Group_Queue__c, Previous_Owner__c, Case_Aging__r.Case__r.Status,
                    Total_Time__c, Case_Aging__r.SLA__c, Case_Aging__r.Total_Time_Age__c, Case_Aging__r.Case__r.SLA__c
                    FROM Case_Aging_Line_Item__c
                    WHERE Case_Aging__r.Case__c IN :caseIds
                ];
                
                // Process categories and individual owners
                Set<String> allCategories = new Set<String>();
                Set<String> individualOwners = new Set<String>();
                for(Case_Aging_Line_Item__c li : lineItems) {
                    if(li.Group_Queue__c != null) {
                        allCategories.add(li.Group_Queue__c);
                    }
                    if(!existingSubcategories.contains(li.Previous_Owner__c)) {
                        individualOwners.add(li.Previous_Owner__c);
                    }
                }
                
                // Process data
                result.caseData = new List<Map<String, Object>>();
                Set<String> dynamicHeaders = new Set<String>();
                
                for(Case c : cases) {
                    // Validate case status matches filter
                    if((statusFilter == 'closed' && c.Status != 'Closed') || 
                       (statusFilter == 'open' && c.Status == 'Closed')) {
                           continue;
                       }
                    
                    Map<String, Object> caseRow = new Map<String, Object>{
                        'Id' => c.Id,
                            'Case Number' => c.CaseNumber,
                            'Case Subject' => c.Subject,
                            'Case Type' => c.Type,
                            'Case Sub Type' => c.Sub_Type__c,
                            'Case Request Type' => c.cc_Request_Type__c,
                            'Case Created Date' => c.CreatedDate?.format('yyyy-MM-dd'),
                            'Status' => c.Status,
                            'Case Current Owner' => c.Owner.Name,
                            'Case SLA' => null,
                            'Total Time' => null,
                            'SLA Status' => null
                            };
                                
                                // Initialize category times
                                Map<String, Decimal> categoryTimes = new Map<String, Decimal>();
                    for(String cat : allCategories) {
                        categoryTimes.put(cat, 0);
                    }
                    Decimal individualsTime = 0;
                    
                    // Process line items
                    for(Case_Aging_Line_Item__c li : lineItems) {
                        if(li.Case_Aging__r.Case__c == c.Id) {
                            // Standard category
                            if(li.Group_Queue__c != null && !individualOwners.contains(li.Previous_Owner__c)) {
                                String category = li.Group_Queue__c;
                                Decimal timeValue = (li.Total_Time__c != null ? li.Total_Time__c : 0);
                                categoryTimes.put(category, categoryTimes.get(category) + timeValue.setScale(2));
                                dynamicHeaders.add(category);
                            }
                            // Individual
                            else if(individualOwners.contains(li.Previous_Owner__c)) {
                                individualsTime += (li.Total_Time__c != null ? li.Total_Time__c : 0);
                                dynamicHeaders.add('Individuals');
                            }
                            
                            // Set SLA and Total Time
                            Decimal caseSLA = (li.Case_Aging__r.Case__r.SLA__c != null ? li.Case_Aging__r.Case__r.SLA__c : 60);
                            Decimal totalTime = (li.Case_Aging__r.Total_Time_Age__c != null ? li.Case_Aging__r.Total_Time_Age__c : 0);
                            
                            caseRow.put('Case SLA', caseSLA);
                            caseRow.put('Total Time', totalTime.setScale(2));
                            
                            // Set SLA Status
                            if (caseSLA >= totalTime && li.Case_Aging__r.Case__r.Status == 'Closed') {
                                caseRow.put('SLA Status', 'Met');
                            } else if(caseSLA >= totalTime && li.Case_Aging__r.Case__r.Status != 'Closed') {
                                caseRow.put('SLA Status', 'In Progress');
                            } else {
                                caseRow.put('SLA Status', 'Breached');
                            }
                        }
                    }
                    
                    // Add category times
                    for(String category : categoryTimes.keySet()) {
                        if(categoryTimes.get(category) > 0) {
                            caseRow.put(category, categoryTimes.get(category));
                        }
                    }
                    
                    // Add Individuals time if exists
                    if(individualsTime > 0) {
                        caseRow.put('Individuals', individualsTime.setScale(2));
                    }
                    
                    result.caseData.add(caseRow);
                }
                
                if(pageNumber == 1) {
                    result.fixedColumns = getFixedColumns();
                    result.dynamicColumns = buildCategoryColumns(new List<String>(dynamicHeaders));
                }
                
                return result;
            } catch (Exception e) {
                throw new AuraHandledException('Error retrieving report data: ' + e.getMessage());
            }
        }
    
    public static String getCaseQuery(Integer limitSize, Integer offset, Integer daysBack, String statusFilter) {
        Datetime startDatetime = Datetime.newInstance(
            System.today().addDays(-daysBack),Time.newInstance(0, 0, 0, 0));
        
        // Define the record type developer names
        Set<String> recordTypeDevNames = new Set<String>{
            'Case_Disputes_and_Frauds',
                'Complaint',
                'Case_Faults_and_Incidents',
                'Request',
                'Sukuk_Bond_Request'
                };
                    
                    // Convert the Set to a formatted string for SOQL
                    String recordTypesString = '(\'' + String.join(new List<String>(recordTypeDevNames), '\',\'') + '\')';
        
        // Base query with required filters
        String query = 'SELECT Id, CaseNumber, Subject, Type, Sub_Type__c, cc_Request_Type__c, CreatedDate, SLA__c, ' +
            'Status, Owner.Name ' +
            'FROM Case ' +
            'WHERE CreatedDate >= ' + startDatetime.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' ' +
            'AND RecordType.DeveloperName IN ' + recordTypesString +
            'AND SLA__c != null';
        
        // Add status filter condition
        if (statusFilter == 'open') {
            query += ' AND Status != \'Closed\'';
        } 
        else if (statusFilter == 'closed') {
            query += ' AND Status = \'Closed\'';
        }
        
        // Add sorting and pagination
        query += ' ORDER BY CreatedDate DESC ' +
            'LIMIT ' + limitSize + ' ' +
            'OFFSET ' + offset;
        
        System.debug('Query --->'+query);
        
        return query;
    }
    
    // Add this helper method to collect all existing subcategories from the map
    public static Set<String> getAllExistingSubcategories() {
        Set<String> allSubcategories = new Set<String>();
        for(List<String> subcats : TEAM_SUBCATEGORIES.values()) {
            allSubcategories.addAll(subcats);
        }
        return allSubcategories;
    }
    
    @AuraEnabled
    public static String startBatchExport(String dateRange) {
        try {
            // Create a unique job ID to track this specific export
            String jobId = 'CASE_EXPORT_' + DateTime.now().getTime();
            
            CaseExportBatch batch = new CaseExportBatch(dateRange);
            batch.jobId = jobId;
            
            // Start the batch with higher priority
            Id batchId = Database.executeBatch(batch, 200);
            
            // Return both the batch ID and our custom job ID
            return JSON.serialize(new Map<String, String>{
                'batchId' => batchId,
                    'jobId' => jobId
                    });
        } catch (Exception e) {
            throw new AuraHandledException('Failed to start batch job: ' + e.getMessage());
        }
    }
    
    // Main method that can be called imperatively or from LWC
    @AuraEnabled
    public static void calculateTotalTime() {
        if (Limits.getLimitQueueableJobs() > Limits.getQueueableJobs()) {
            // If we have queueable capacity, use that for larger datasets
            Database.executeBatch(new CaseAgingCalculationBatch(), 200);
        }
    }
    
    public static List<Column> getFixedColumns() {
        return new List<Column>{
            new Column('Case Number', 1, 1),
                new Column('Case Subject', 1, 1),
                new Column('Case Type', 1, 1),
                new Column('Case Sub Type', 1, 1),
                new Column('Case Request Type', 1, 1),
                new Column('Case Created Date', 1, 1),
                new Column('Status', 1, 1),
                new Column('Case Current Owner', 1, 1),
                new Column('Case SLA', 1, 1),
                new Column('Total Time', 1, 1),
                new Column('SLA Status', 1, 1)
                };
                    }
    
    public static List<DynamicColumn> buildDynamicColumns(List<String> teamHeaders) {
        List<DynamicColumn> columns = new List<DynamicColumn>();
        
        for(String team : teamHeaders) {
            List<String> subcategories = TEAM_SUBCATEGORIES.get(team);
            if(subcategories != null) {
                columns.add(new DynamicColumn(team, subcategories.size(), 1, subcategories));
            }
        }
        
        return columns;
    }
    
    public static List<DynamicColumn> buildCategoryColumns(List<String> categories) {
        List<DynamicColumn> columns = new List<DynamicColumn>();
        
        for(String category : categories) {
            // Create simple columns with colspan=1 and no subcategories
            columns.add(new DynamicColumn(category, 1, 1, new List<String>()));
        }
        
        return columns;
    }
    
    public static String buildWhereClause(String filters) {
        // Implement your filter logic here
        return ''; // Return appropriate WHERE clause
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getCaseCounts(
        Integer pageNumber, 
        Integer pageSize, 
        String dateRange, 
        String statusFilter, 
        String fromDateStr, 
        String toDateStr
    ) {
        // Input validation (same as getPaginatedReportData)
        pageNumber = (pageNumber != null && pageNumber > 0) ? pageNumber : 1;
        pageSize = (pageSize != null && pageSize > 0) ? pageSize : 75;
        Integer offset = (pageNumber - 1) * pageSize;
        
        Map<String, Integer> result = new Map<String, Integer>();
        
        // Initialize all counters
        Integer vipTotal = 0;
        Integer vipMet = 0;
        Integer vipInProgress = 0;
        Integer vipBreached = 0;
        Integer totalCases = 0;
        Integer totalMet = 0;
        Integer totalInProgress = 0;
        Integer totalBreached = 0;
        
        // Date range handling (same as getPaginatedReportData)
        Datetime startDatetime;
        Datetime endDatetime = Datetime.now();
        String dateCondition;
        
        if (dateRange == 'custom') {
            // Custom date range handling
            if (String.isBlank(fromDateStr) || String.isBlank(toDateStr)) {
                throw new AuraHandledException('Custom date range requires both from and to dates');
            }
            
            Date fromDate = Date.valueOf(fromDateStr);
            Date toDate = Date.valueOf(toDateStr);
            
            if (fromDate > toDate) {
                throw new AuraHandledException('From date cannot be after To date');
            }
            
            startDatetime = Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
            endDatetime = Datetime.newInstance(toDate, Time.newInstance(23, 59, 59, 999));
            dateCondition = 'CreatedDate >= :startDatetime AND CreatedDate <= :endDatetime';
        } else {
            // Standard date range handling
            Integer days = (dateRange != null && dateRange != 'custom') ? Integer.valueOf(dateRange) : 90;
            startDatetime = Datetime.newInstance(System.today().addDays(-days), Time.newInstance(0, 0, 0, 0));
            dateCondition = 'CreatedDate >= :startDatetime';
        }
        
        // Status filter condition (same as getPaginatedReportData)
        String statusCondition = '';
        if (statusFilter == 'open') {
            statusCondition = 'AND Status != \'Closed\'';
        } 
        else if (statusFilter == 'closed') {
            statusCondition = 'AND Status = \'Closed\'';
        }
        
        // Build query with pagination (same as getPaginatedReportData)
        String query = 'SELECT Id, AccountId, Account.VVIP__pc, Status, SLA__c, ' +
            '(SELECT Id, Total_Time_Age__c FROM Case_Agings__r ORDER BY CreatedDate DESC LIMIT 1) ' +
            'FROM Case ' +
            'WHERE ' + dateCondition + ' ' +
            'AND RecordType.DeveloperName IN (\'Case_Disputes_and_Frauds\',\'Sukuk_Bond_Request\',\'Complaint\',\'Case_Faults_and_Incidents\',\'Request\') ' +
            statusCondition + ' ' +
            'AND SLA__c != null ' +
            'ORDER BY CreatedDate DESC ' +
            'LIMIT :pageSize ' +
            'OFFSET :offset';
        
        List<Case> cases = Database.query(query);
        totalCases = cases.size();
        
        for (Case c : cases) {
            Boolean isVip = c.AccountId != null && c.Account.VVIP__pc;
            String slaStatus = 'Not Calculated';
            
            // Determine SLA status (same logic as getPaginatedReportData)
            if (!c.Case_Agings__r.isEmpty()) {
                Case_Aging__c aging = c.Case_Agings__r[0];
                if (c.SLA__c != null && aging.Total_Time_Age__c != null) {
                    if (c.SLA__c >= aging.Total_Time_Age__c && c.Status == 'Closed') {
                        slaStatus = 'Met';
                    } else if (c.SLA__c >= aging.Total_Time_Age__c && c.Status != 'Closed') {
                        slaStatus = 'In Progress';
                    } else {
                        slaStatus = 'Breached';
                    }
                }
            }
            
            // Update VIP counters
            if (isVip) {
                vipTotal++;
                if (slaStatus == 'Met') vipMet++;
                else if (slaStatus == 'In Progress') vipInProgress++;
                else if (slaStatus == 'Breached') vipBreached++;
            }
            
            // Update total counters
            if (slaStatus == 'Met') totalMet++;
            else if (slaStatus == 'In Progress') totalInProgress++;
            else if (slaStatus == 'Breached') totalBreached++;
        }
        
        // Populate result map
        result.put('vipTotal', vipTotal);
        result.put('vipMet', vipMet);
        result.put('vipInProgress', vipInProgress);
        result.put('vipBreached', vipBreached);
        result.put('totalCases', totalCases);
        result.put('totalMet', totalMet);
        result.put('totalInProgress', totalInProgress);
        result.put('totalBreached', totalBreached);
        
        return result;
    }
    
    // 🟢 New future method to handle CaseMilestone and Case_Aging__c updates asynchronously
    @future
    public static void updateRelatedRecordsAsync(Set<Id> milestoneCaseIds, Map<Id, Decimal> caseIdToSLA) {
        if (!milestoneCaseIds.isEmpty()) {
            List<CaseMilestone> milestones = [
                SELECT Id, StartDate FROM CaseMilestone
                WHERE CaseId IN :milestoneCaseIds AND IsCompleted = false
            ];
            DateTime now = System.now();
            for (CaseMilestone m : milestones) {
                m.StartDate = now;
            }
            if (!milestones.isEmpty()) update milestones;
        }
    }
    
    
    public class ReportData {
        @AuraEnabled public List<Map<String, Object>> caseData;
        @AuraEnabled public List<Column> fixedColumns;
        @AuraEnabled public List<DynamicColumn> dynamicColumns;
        @AuraEnabled public Integer totalCount; // Added this field
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
}