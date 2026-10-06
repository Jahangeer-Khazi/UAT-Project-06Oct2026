public with sharing class UARDetailsPDFController {
    public UAR__c uarRecord { get; set; }
    public List<String> typologyList { get; set; }
    public List<String> typologyListFirstHalf { get; set; }
    public List<String> typologyListSecondHalf { get; set; }
    public List<String> mlroDecisionList { get; set; }
    public List<String> mlroDecisionListFirstHalf { get; set; }
    public List<String> mlroDecisionListSecondHalf { get; set; }
    public String formattedWithdrawChannels { get; set; }
    public String formattedDepositChannels { get; set; }
    public String formattedSourceOfFunds { get; set; }
    public Date todayDate { get; set; }
    public List<String> imageUrls { get; set; }
    public List<Id> contentVersionIds { get; set; }
    
    public UARDetailsPDFController(ApexPages.StandardController controller) {
        // Get the record Id from the standard controller
        Id recordId = controller.getId();
        System.debug('recordId -->'+recordId);
        todayDate = Date.today();
        
        // Fetching the UAR__c record using the record Id
        if (recordId != null) {
            uarRecord = [SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, Case_Model__c, Subject__c, 
                         Description__c, Type__c, Sub_Type__c, Other__c, Transaction_Amount__c, Transaction_Date__c, Account__c, 
                         Contact__c, Customer_CIF__c, Occupation__c, Declared_expected_monthly_deposits_BHD__c, 
                         Declared_source_of_funds_del__c, System_Generated_Suspicion__c, Date_of_transaction_s__c, 
                         Value_of_transaction_s__c, Other_Details__c, Typology__c, Reason_for_Suspicion__c, 
                         Summary_of_look_back_exercise__c, Total_Deposits_BHD__c, Total_Withdrawals_BHD__c, 
                         Deposit_Channels__c, Withdrawal_Channels__c, IBAN__c, Number_of_transfers__c, Amount_BHD__c, 
                         Key_findings_risks_identified__c, AML_Analyst_Case_Closure_Recommendation__c, Maker_Result__c, 
                         Maker_Comments__c, Maker_Result_Date_Time__c, Checker_Result__c, Checker_Comments__c, 
                         Checker_Result_Date_Time__c, MLRO_commentary__c, MLRO_decision__c, Compliance_Comments__c, 
                         Compliance_Result_Date_Time__c, Declared_gross_monthly_income_BHD__c, AML_Analyst_Summary__c, 
                         Compliance_Result__c, Status__c, Sub_Status__c, Customer_since__c, Owner.Name, Account__r.Employer_Name__pc,
                         (SELECT Id, Transaction_Amount__c, Transaction_Date__c FROM Suspicious_Transactions__r)
                        FROM UAR__c WHERE Id = :recordId LIMIT 1];
            
            System.debug('uarRecord -->'+uarRecord);
            
            if (uarRecord.Typology__c != null) {
                typologyList = uarRecord.Typology__c.split(';');
            }
            
            if (uarRecord.MLRO_decision__c != null) {
                mlroDecisionList = uarRecord.MLRO_decision__c.split(';');
            }
            
            if (uarRecord.Withdrawal_Channels__c != null) {
                List<String> picklistValues = uarRecord.Withdrawal_Channels__c.split(';');
                formattedWithdrawChannels = String.join(picklistValues, ', ');
            }
            
            if (uarRecord.Deposit_Channels__c != null) {
                List<String> picklistValues = uarRecord.Deposit_Channels__c.split(';');
                formattedDepositChannels = String.join(picklistValues, ', ');
            }
            
            if (uarRecord.Declared_source_of_funds_del__c != null) {
                List<String> picklistValues = uarRecord.Declared_source_of_funds_del__c.split(';');
                formattedSourceOfFunds = String.join(picklistValues, ', ');
            }
            
            // Splitting the list into two halves
            if (typologyList != null && !typologyList.isEmpty()) {
                Integer midpoint = Math.min(9, typologyList.size());  // Get the smaller value between 10 and the list size
                typologyListFirstHalf = new List<String>();
                typologyListSecondHalf = new List<String>();
                
                // Add items to the first half
                for (Integer i = 0; i < midpoint; i++) {
                    typologyListFirstHalf.add(typologyList[i]);
                }
                
                // Add items to the second half (if there are more than 10)
                if (typologyList.size() > 9) {
                    for (Integer i = midpoint; i < typologyList.size(); i++) {
                        typologyListSecondHalf.add(typologyList[i]);
                    }
                }
            }
            
            // Splitting the list into two halves
            if (mlroDecisionList != null && !mlroDecisionList.isEmpty()) {
                Integer midpoint = Math.min(8, mlroDecisionList.size());  // Get the smaller value between 10 and the list size
                mlroDecisionListFirstHalf = new List<String>();
                mlroDecisionListSecondHalf = new List<String>();
                
                // Add items to the first half
                for (Integer i = 0; i < midpoint; i++) {
                    mlroDecisionListFirstHalf.add(mlroDecisionList[i]);
                }
                
                // Add items to the second half (if there are more than 10)
                if (mlroDecisionList.size() > 8) {
                    for (Integer i = midpoint; i < mlroDecisionList.size(); i++) {
                        mlroDecisionListSecondHalf.add(mlroDecisionList[i]);
                    }
                }
            }
        }
        
        fetchImages();
    }
    
    public PageReference init() {
        // Check if the download parameter is present
        if (ApexPages.currentPage().getParameters().containsKey('download')) {
            // Set the Content-Disposition header to force download
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachment; filename="STR-' + uarRecord.Name + '.pdf"');
        }
        return null;
    }
    
    // Public method to return formatted date
    public String getFormattedDate() {
        if (uarRecord.Transaction_Date__c != null) {
            // Format the date using the user's locale (default format)
            String formattedDate = uarRecord.Transaction_Date__c.format();
            
            // Apply manual formatting (if needed, using split for 'MM/dd/yyyy' format)
            String[] dateParts = formattedDate.split('/');
            if (dateParts.size() == 3) {
                return dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
            }
            return formattedDate;
        }
        return 'No Date Available';
    }
    
    // Public method to return formatted date
    public String getFormattedTodayDate() {
        if (todayDate != null) {
            // Format the date using the user's locale (default format)
            String formattedDate = todayDate.format();
            
            // Apply manual formatting (if needed, using split for 'MM/dd/yyyy' format)
            String[] dateParts = formattedDate.split('/');
            if (dateParts.size() == 3) {
                return dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
            }
            return formattedDate;
        }
        return 'No Date Available';
    }
    
    private void fetchImages() {
        contentVersionIds = new List<Id>(); // List to store ContentVersion IDs
        Id customerId = uarRecord.Account__c;
        
        if (customerId != null) {
            List<Account> accList = [
                SELECT Id, (SELECT Id FROM Content__r 
                            WHERE Document_Type__c = 'Bahraini ID' 
                            AND Image_Type__c IN ('Front', 'Back') ORDER BY Image_Type__c DESC)
                FROM Account 
                WHERE Id = :customerId
                LIMIT 1
            ];
            
            Set<Id> contentIds = new Set<Id>();
            for (Account acc : accList) {
                if (acc.Content__r != null && !acc.Content__r.isEmpty()) {
                    for (Content__c cont : acc.Content__r) {
                        contentIds.add(cont.Id);
                    }
                }
            }
            
            if (!contentIds.isEmpty()) {
                List<ContentDocumentLink> cdlList = [
                    SELECT ContentDocumentId 
                    FROM ContentDocumentLink 
                    WHERE LinkedEntityId IN :contentIds
                ];
                
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink cdl : cdlList) {
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                
                if (!contentDocumentIds.isEmpty()) {
                    List<ContentVersion> cvList = [
                        SELECT Id 
                        FROM ContentVersion 
                        WHERE ContentDocumentId IN :contentDocumentIds
                        ORDER BY CreatedDate DESC
                    ];
                    
                    for (ContentVersion cv : cvList) {
                        contentVersionIds.add(cv.Id);
                    }
                }
            }
        }
        
        // If no ContentVersion IDs are found, add a placeholder message
        if (contentVersionIds.isEmpty()) {
            System.debug('No ContentVersion IDs found.');
        }
    }
    
    
}