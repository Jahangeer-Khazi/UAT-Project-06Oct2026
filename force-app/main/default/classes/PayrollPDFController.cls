public class PayrollPDFController {
    
    // Public properties that will be accessed from Visualforce
    public String payrollReference { get; set; }
    public String customerId { get; set; }
    public String regionName { get; set; }
    public String recordId { get; set; }
    
    // Main payroll properties
    public String debitAccount { get; set; }
    public String employerName { get; set; }
    public String salaryMonth { get; set; }
    public String paymentDate { get; set; }
    public String creationDate { get; set; }
    public String currencyValue { get; set; }
    public String status { get; set; }
    public String statusClass { get; set; }
    public String payrollAmount { get; set; }
    public String transactionAmount { get; set; }
    public String vat { get; set; }
    public String totalDebt { get; set; }
    public String employeeCount { get; set; }
    public String reason { get; set; }
    public String description { get; set; }
    
    // Employee list
    public List<EmployeeWrapper> employees { get; set; }
    
    // Utility properties
    public String generationDate { 
        get {
            return DateTime.now().format('yyyy-MM-dd HH:mm:ss');
        }
    }
    
    public Integer currentYear {
        get {
            return Date.today().year();
        }
    }
    
    public PayrollPDFController() {
        // Get parameters from URL
        payrollReference = ApexPages.currentPage().getParameters().get('reference');
        customerId = ApexPages.currentPage().getParameters().get('customerId');
        regionName = ApexPages.currentPage().getParameters().get('regionName');
        recordId = ApexPages.currentPage().getParameters().get('recordId');
        System.debug('payrollReference -->'+payrollReference);
        System.debug('customerId -->'+customerId);
        System.debug('regionName -->'+regionName);
        initializeData();
    }
    
    private void initializeData() {
        if (payrollReference != null && customerId != null) {
            try {
                // Call the existing Apex method to get payroll details
                PayrollController.PayrollDetailWrapper detailData = PayrollController.getPayrollDetailandSalaries(customerId, regionName, payrollReference, recordId);
                System.debug('detailData -->'+detailData);
                if (detailData != null) {
                    // Map main properties from the API response
                    debitAccount = getStringValue(detailData.debitAccount);
                    employerName = getStringValue(detailData.employerName);
                    salaryMonth = getStringValue(detailData.salaryMonth);
                    paymentDate = getStringValue(detailData.paymentDate);
                    creationDate = getStringValue(detailData.paymentDate);
                    currencyValue = getStringValue(detailData.currencyValue, 'BHD');
                    status = getStringValue(detailData.status, 'Unknown');
                    payrollAmount = formatAmount(getStringValue(detailData.payrollAmount, '0.000'));
                    transactionAmount = getStringValue(detailData.transactionFees, '0.000');
                    vat = getStringValue(detailData.vat, '0.000');
                    totalDebt = formatAmount(getStringValue(detailData.totalDebt, '0.000'));
                    employeeCount = getStringValue(detailData.totalDebt, '0');
                    reason = getStringValue(detailData.reason, '-');
                    description = getStringValue(detailData.description, '-');
                    
                    // Set status class
                    statusClass = getStatusClass(status);
                    
                    // Map employees
                    employees = new List<EmployeeWrapper>();
                    List<PayrollController.SalaryWrapper> salaryList = (List<PayrollController.SalaryWrapper>)detailData.salaries;
                    if (salaryList != null) {
                        Integer recordCounter = 1;
                        for (PayrollController.SalaryWrapper salaryObj : salaryList) {
                            EmployeeWrapper emp = new EmployeeWrapper();
                            emp.recordNo = getStringValue(salaryObj.recordNo, String.valueOf(recordCounter));
                            emp.name = getStringValue(salaryObj.employeeName);
                            emp.creditAccount = getStringValue(salaryObj.creditAccount);
                            emp.bankSec = getStringValue(salaryObj.bankSec);
                            emp.currencyValue = getStringValue(salaryObj.currencyValue, 'BHD');
                            emp.amount = formatAmount(getStringValue(salaryObj.amount, '0.000'));
                            emp.idType = getStringValue(salaryObj.idType);
                            emp.idNumber = getStringValue(salaryObj.idNumber);
                            employees.add(emp);
                            recordCounter++;
                        }
                    }
                    
                } else {
                    //setDefaultValues();
                }
                
            } catch (Exception e) {
                System.debug('Error loading payroll data: ' + e.getMessage() + ' - ' + e.getStackTraceString());
                //setDefaultValues();
            }
        } else {
            //setDefaultValues();
        }
    }
    
    private String getStatusClass(String status) {
        if (status == null) return 'status-unknown';
        
        String statusLower = status.toLowerCase();
        if (statusLower.contains('approved') || statusLower.contains('authorized') || statusLower.contains('completed')) {
            return 'status-authorized';
        } else if (statusLower.contains('pending') || statusLower.contains('processing')) {
            return 'status-pending';
        } else if (statusLower.contains('rejected') || statusLower.contains('failed') || statusLower.contains('canceled') || statusLower.contains('declined')) {
            return 'status-rejected';
        } else {
            return 'status-unknown';
        }
    }
    
    private String getStringValue(Object value) {
        return getStringValue(value, 'N/A');
    }
    
    private String getStringValue(Object value, String defaultValue) {
        if (value == null) return defaultValue;
        String stringValue = String.valueOf(value);
        return String.isBlank(stringValue) ? defaultValue : stringValue;
    }
    
    private String formatAmount(String amount) {
        return formatAmount(amount, '0.000');
    }
    
    private String formatAmount(String amount, String defaultValue) {
        if (String.isBlank(amount)) return defaultValue;
        
        try {
            // Handle decimal formatting
            Decimal decimalValue = Decimal.valueOf(amount);
            return decimalValue.setScale(3).toPlainString();
        } catch (Exception e) {
            return defaultValue;
        }
    }
    
    // Wrapper class for employee data
    public class EmployeeWrapper {
        public String recordNo { get; set; }
        public String name { get; set; }
        public String creditAccount { get; set; }
        public String bankSec { get; set; }
        public String currencyValue { get; set; }
        public String amount { get; set; }
        public String idType { get; set; }
        public String idNumber { get; set; }
    }
    
}