trigger WPSPayrollTrigger on WPSPayroll__c (before insert, before update, after update) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        WPSPayrollHandler.handleBeforeInsertChanges(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        List<WPSPayrollHandler.PayrollData> payrollDataList = new List<WPSPayrollHandler.PayrollData>();
        
        for (WPSPayroll__c currentRecord : Trigger.new) {
            WPSPayroll__c oldRecord = Trigger.oldMap.get(currentRecord.Id);
            
            if (currentRecord.Maker_Result__c != oldRecord.Maker_Result__c ||
                (currentRecord.Checker_Result__c != oldRecord.Checker_Result__c && 
                 currentRecord.Checker_Result__c != 'Accept')) {
                
                WPSPayrollHandler.PayrollData payrollData = new WPSPayrollHandler.PayrollData(currentRecord.Id);
                
                if (currentRecord.Maker_Result__c != oldRecord.Maker_Result__c) {
                    payrollData.makerResult = currentRecord.Maker_Result__c;
                }
                
                // Only include non-Accept Checker Result changes in before update
                if (currentRecord.Checker_Result__c != oldRecord.Checker_Result__c && 
                    currentRecord.Checker_Result__c != 'Accept') {
                    payrollData.checkerResult = currentRecord.Checker_Result__c;
                }
                
                payrollDataList.add(payrollData);
            }
        }
        
        // Process simple changes in before update
        if (!payrollDataList.isEmpty()) {
            WPSPayrollHandler.handleSimpleChanges(payrollDataList, Trigger.newMap);
        }
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        List<WPSPayrollHandler.PayrollData> payrollDataList = new List<WPSPayrollHandler.PayrollData>();
        
        for (WPSPayroll__c currentRecord : Trigger.new) {
            WPSPayroll__c oldRecord = Trigger.oldMap.get(currentRecord.Id);
            
            if (currentRecord.Checker_Result__c != oldRecord.Checker_Result__c && 
                currentRecord.Checker_Result__c == 'Accept') {
                
                WPSPayrollHandler.PayrollData payrollData = new WPSPayrollHandler.PayrollData(currentRecord.Id);
                payrollData.checkerResult = currentRecord.Checker_Result__c;
                
                WPSPayroll__c newRecord = Trigger.newMap.get(currentRecord.Id);
                payrollData.payrollAction = newRecord.Payroll_Action__c;
                payrollData.payrollReference = newRecord.Payroll_Reference__c;
                payrollData.payrollReason = newRecord.Payroll_Reason__c;
                payrollData.payrollTotalDebitAmount = newRecord.Payroll_Total_Debit_Amount__c;
                payrollData.cif = newRecord.Customer_CIF__c;
                payrollData.customerId = newRecord.Customer__c;
                payrollData.payrollDebitAccountIBAN = newRecord.Payroll_Debit_Account_IBAN__c;
                payrollData.payrollAmount = newRecord.Payroll_Amount__c;
                payrollData.payrollCurrency = newRecord.Payroll_Currency__c;
                payrollData.regionName = newRecord.Region_Flag__c;
                payrollData.payrollNoOfSalaries = String.valueOf(newRecord.Payroll_No_of_Salaries__c);
                payrollData.payrollSalaryMonth = PayrollController.convertMonthToNumeric(newRecord.Payroll_Salary_Month__c);
                
                payrollDataList.add(payrollData);
            }
        }
        
        if (!payrollDataList.isEmpty()) {
            WPSPayrollHandler.handleAcceptCheckerResult(payrollDataList);
        }
    }

    
}