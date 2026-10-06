public class PayrollController {
    
    public static String PAYROLL_EP = '/api/v1/wps/payroll/list';
    public static String PAYROLL_DETAIL_EP = '/api/v1/wps/payroll/details';
    
    @TestVisible
    private static ApiConnection con = new ApiConnection();
    
    @AuraEnabled(cacheable=true)
    public static List<PayrollWrapper> getPayrolls(String customerId, String regionName, Boolean isAlburaqProd) {
        System.debug('=== Entering getPayrolls ===');
        System.debug('Input Parameters => customerId: ' + customerId + ', regionName: ' + regionName + ', isAlburaqProd: ' + isAlburaqProd);
        try {
            ApiConnection.Response apiResponse = loadPayrollSalaryList(customerId, regionName, isAlburaqProd);
            System.debug('API Response (getPayrolls) => ' + JSON.serialize(apiResponse));
            
            if (apiResponse.isSuccess && apiResponse.responseData != null) {
                System.debug('API call successful and responseData not null');
                Map<String, Object> responseData = (Map<String, Object>)apiResponse.responseData;
                System.debug('Parsed responseData => ' + responseData);
                
                List<Object> payrollsList = (List<Object>)responseData.get('payrolls');
                System.debug('Extracted payrollsList => ' + payrollsList);
                
                if (payrollsList != null && !payrollsList.isEmpty()) {
                    System.debug('Payroll list contains records => Size: ' + payrollsList.size());
                    List<PayrollWrapper> wrappers = new List<PayrollWrapper>();
                    
                    for (Object payrollObj : payrollsList) {
                        Map<String, Object> payroll = (Map<String, Object>)payrollObj;
                        System.debug('Processing payroll record => ' + payroll);
                        
                        PayrollWrapper wrapper = new PayrollWrapper();
                        
                        wrapper.reference = String.valueOf(payroll.get('payrollId'));
                        wrapper.status = String.valueOf(payroll.get('status'));
                        wrapper.debitAccount = String.valueOf(payroll.get('accountNumber'));
                        wrapper.salaryMonthBeforeFormatting = String.valueOf(payroll.get('salaryMonth'));
                        
                        String salMonth = String.valueOf(payroll.get('salaryMonth'));
                        String monthStr = salMonth.substring(0, 2);
                        String yearStr  = salMonth.substring(2);
                        Integer monthNum = Integer.valueOf(monthStr);
                        DateTime dt = DateTime.newInstance(Integer.valueOf(yearStr), monthNum, 1, 0, 0, 0);
                        
                        String monthName = dt.format('MMM');
                        String finalValue = monthName + ' ' + yearStr;
                        
                        wrapper.salaryMonth = finalValue;
                        wrapper.paymentDate = String.valueOf(payroll.get('transactionDate'));
                        wrapper.employerName = String.valueOf(payroll.get('employerName'));
                        wrapper.numberOfSalaries = String.valueOf(payroll.get('totalNoOfRec'));
                        wrapper.payrollAmount = String.valueOf(payroll.get('totalAmount'));
                        wrapper.currencyValue = 'BHD';
                        wrapper.payrollRef = String.valueOf(payroll.get('payrollRef'));
                        wrapper.totalDebitAmount = String.valueOf(payroll.get('totalAmount'));
                        wrapper.resultDescription = String.valueOf(payroll.get('resultDescription'));
                        wrapper.resultCode = String.valueOf(payroll.get('additionalInformation'));
                        wrapper.reason = '';
                        wrapper.creationDate = String.valueOf(payroll.get('creationDate'));
                        
                        List<Object> allowedActionObjList = (List<Object>) payroll.get('allowedAction');
                        List<String> allowedActionStringList = new List<String>();
                        
                        for (Object allAct : allowedActionObjList) {
                            allowedActionStringList.add((String) allAct);
                        }
                        
                        wrapper.allowedAction = allowedActionStringList;
                        
                        List<Object> customFields = (List<Object>) payroll.get('customFields');
                        
                        for (Object obj : customFields) {
                            Map<String, Object> item = (Map<String, Object>) obj;
                            
                            String key = (String) item.get('key');
                            String value = (String) item.get('value');
                            
                            if (key == 'VAT') {
                                wrapper.vat = value;
                            }
                            else if (key == 'TAX') {
                                wrapper.transactionFees = value;
                            }
                        }
                        
                        System.debug('Mapped PayrollWrapper => ' + JSON.serialize(wrapper));
                        wrappers.add(wrapper);
                    }
                    
                    System.debug('Final PayrollWrapper list size => ' + wrappers.size());
                    System.debug('=== Exiting getPayrolls ===> ' + JSON.serialize(wrappers));
                    return wrappers;
                } else {
                    System.debug('No payrolls found in response.');
                }
            } else {
                System.debug('API response not successful or responseData is null.');
            }
            
            System.debug('Returning empty payroll list.');
            return new List<PayrollWrapper>();
            
        } catch (Exception e) {
            System.debug('Exception in getPayrolls: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving payroll data: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static PayrollDetailWrapper getPayrollDetailandSalaries(String customerId, String regionName, String payrollReference, String recordId) {
        System.debug('=== Entering getPayrollDetailandSalaries ===');
        System.debug('Input Parameters => customerId: ' + customerId + ', regionName: ' + regionName + ', payrollReference: ' + payrollReference + ', recordId: ' + recordId);
        try { 
            // First check if we have stored payroll data in the current record
            if (recordId != null) {
                try {
                    WPSPayroll__c payrollRecord = [SELECT Id, Is_Actioned__c, Payroll_Reference__c, Payroll_Status__c, 
                                                   Payroll_Debit_Account_IBAN__c, Payroll_Salary_Month__c, Payroll_Creation_Date__c,
                                                   Payroll_Payment_Date__c, Payroll_Employer_Name__c, Payroll_No_of_Salaries__c,
                                                   Payroll_Currency__c, Payroll_Amount__c, Payroll_Transaction_Fees__c,
                                                   Payroll_VAT__c, Payroll_Total_Debit_Amount__c, Payroll_Action__c, Payroll_Reason__c
                                                   FROM WPSPayroll__c 
                                                   WHERE Id = :recordId LIMIT 1];
                    
                    // If record is actioned and has stored data, return the stored data
                    if (payrollRecord.Is_Actioned__c && payrollRecord.Payroll_Reference__c != null) {
                        System.debug('Returning stored payroll data from database');
                        PayrollDetailWrapper detailWrapper = new PayrollDetailWrapper();
                        
                        detailWrapper.debitAccount = payrollRecord.Payroll_Debit_Account_IBAN__c;
                        detailWrapper.reference = payrollRecord.Payroll_Reference__c;
                        detailWrapper.salaryMonth = payrollRecord.Payroll_Salary_Month__c;
                        detailWrapper.paymentDate = String.valueOf(payrollRecord.Payroll_Payment_Date__c);
                        detailWrapper.employerName = payrollRecord.Payroll_Employer_Name__c;
                        detailWrapper.employeeCount = String.valueOf(payrollRecord.Payroll_No_of_Salaries__c);
                        detailWrapper.currencyValue = payrollRecord.Payroll_Currency__c;
                        detailWrapper.payrollAmount = payrollRecord.Payroll_Amount__c != null ? String.valueOf(payrollRecord.Payroll_Amount__c) : '0';
                        detailWrapper.transactionFees = payrollRecord.Payroll_Transaction_Fees__c != null ? String.valueOf(payrollRecord.Payroll_Transaction_Fees__c) : '0';
                        detailWrapper.vat = payrollRecord.Payroll_VAT__c != null ? String.valueOf(payrollRecord.Payroll_VAT__c) : '0';
                        detailWrapper.totalDebt = payrollRecord.Payroll_Total_Debit_Amount__c != null ? String.valueOf(payrollRecord.Payroll_Total_Debit_Amount__c) : '0';
                        detailWrapper.status = payrollRecord.Payroll_Status__c;
                        detailWrapper.action = payrollRecord.Payroll_Action__c;
                        detailWrapper.reason = payrollRecord.Payroll_Reason__c;
                        
                        return detailWrapper;
                    }
                } catch (QueryException e) {
                    System.debug('No stored payroll data found for recordId: ' + recordId + ', proceeding with API call');
                    // Continue with API call if no stored data found
                }
            }
            
            // Otherwise, call the API as usual
            ApiConnection.Response apiResponse = loadPayrollDetailsAndSalaryList(customerId, regionName, payrollReference);
            System.debug('API Response (getPayrollDetailandSalaries) => ' + JSON.serialize(apiResponse));
            
            if (apiResponse.isSuccess && apiResponse.responseData != null) {
                System.debug('API call successful and responseData not null');
                Map<String, Object> responseData = (Map<String, Object>)apiResponse.responseData;
                System.debug('Parsed responseData => ' + responseData);
                
                PayrollDetailWrapper detailWrapper = new PayrollDetailWrapper();
                
                Map<String, Object> debtor = (Map<String, Object>)responseData.get('debtor');
                if (debtor != null) {
                    System.debug('Mapping debtor info => ' + debtor);
                    detailWrapper.debitAccount = String.valueOf(debtor.get('accountNumber'));
                    detailWrapper.employerName = String.valueOf(debtor.get('employerName'));
                    //detailWrapper.ref = String.valueOf(responseData.get('employerId'));
                } else {
                    System.debug('No debtor info found.');
                }
                
                detailWrapper.reference = String.valueOf(responseData.get('payrollRef'));
                detailWrapper.salaryMonth = String.valueOf(responseData.get('salaryMonth'));
                detailWrapper.paymentDate = String.valueOf(responseData.get('transactionDate'));
                detailWrapper.employeeCount = String.valueOf(responseData.get('totalNoOfRec'));
                detailWrapper.payrollAmount = String.valueOf(responseData.get('totalAmount'));
                detailWrapper.totalDebt = String.valueOf(responseData.get('totalAmount'));
                detailWrapper.ref = payrollReference;
                System.debug('Mapped PayrollDetailWrapper basic info => ' + JSON.serialize(detailWrapper));
                
                List<Object> salariesList = (List<Object>)responseData.get('salaries');
                List<SalaryWrapper> salaryWrappers = new List<SalaryWrapper>();
                
                if (salariesList != null && !salariesList.isEmpty()) {
                    System.debug('Salaries list found => Size: ' + salariesList.size());
                    for (Object salaryObj : salariesList) {
                        Map<String, Object> salary = (Map<String, Object>)salaryObj;
                        System.debug('Processing salary record => ' + salary);
                        
                        SalaryWrapper salaryWrapper = new SalaryWrapper();
                        salaryWrapper.recordNo = String.valueOf(salary.get('recordNo'));
                        salaryWrapper.employeeName = String.valueOf(salary.get('employeeName'));
                        salaryWrapper.creditAccount = String.valueOf(salary.get('accountNumber'));
                        salaryWrapper.bankSec = String.valueOf(salary.get('creditorIdentificationCode'));
                        salaryWrapper.currencyValue = String.valueOf(salary.get('currency'));
                        salaryWrapper.amount = String.valueOf(salary.get('transactionAmount'));
                        salaryWrapper.idType = String.valueOf(salary.get('idType'));
                        salaryWrapper.idNumber = String.valueOf(salary.get('id'));
                        
                        System.debug('Mapped SalaryWrapper => ' + JSON.serialize(salaryWrapper));
                        salaryWrappers.add(salaryWrapper);
                    }
                } else {
                    System.debug('No salary records found in response.');
                }
                
                detailWrapper.salaries = salaryWrappers;
                System.debug('Final detailWrapper => ' + JSON.serialize(detailWrapper));
                System.debug('=== Exiting getPayrollDetailandSalaries ===');
                return detailWrapper;
            } else {
                System.debug('API response not successful or responseData is null.');
            }
            
            System.debug('Returning null for PayrollDetailWrapper.');
            return null;
        } catch (Exception e) {
            System.debug('Exception in getPayrollDetailandSalaries: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving payroll details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadPayrollSalaryList(String customerId, String regionName, Boolean isAlburaqProd) {
        // ... existing implementation remains the same ...
        System.debug('=== Entering loadPayrollSalaryList ===');
        System.debug('Input Parameters => customerId: ' + customerId + ', regionName: ' + regionName);
        
        //Account accDetail = [SELECT ]
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        if (isAlburaqProd) {
            regionName += '_alburaq';
        }

        request = con.createRequest('POST', PAYROLL_EP, regionName);
        System.debug('Created HTTP Request => ' + request);
        
        //if (caseObj.Case_Model__c == 'alburaq') {
            //regionName += '_alburaq';
        //}
        
        if (regionName != null && regionName.toLowerCase().contains('alburaq')) {
            request.setTimeout(60000);
            System.debug('Alburaq region detected, timeout set to 60000ms');
        }
         
        String payrollRef;
        List<String> status = new List<String>();
        status.add('Approved');
        status.add('Pending');
        status.add('Rejected');
        status.add('Expired');
        status.add('Completed');
        status.add('Cancelled');
        status.add('Failed');
        String startDate;
        String endDate;
        String fromAmount;
        String toAmount;
        Integer pageNo = 1;
        Integer pageSize = 500;
        
        Map<String, Object> payload = new Map<String, Object>();
        System.debug('Building request payload...');
        
        if (payrollRef != null) payload.put('payrollRef', payrollRef);
        //if (status != null && !status.isEmpty()) payload.put('status', status);
        if (startDate != null) payload.put('startDate', startDate);
        if (endDate != null) payload.put('endDate', endDate);
        if (fromAmount != null) payload.put('fromAmount', fromAmount);
        if (toAmount != null) payload.put('toAmount', toAmount);
        if (pageNo != null) payload.put('pageNo', pageNo);
        if (pageSize != null) payload.put('pageSize', pageSize);
        payload.put('status', status);
        
        System.debug('Final payload => ' + payload);
        
        String body = payload.isEmpty() ? '{}' : JSON.serialize(payload);
        request.setBody(body);
        System.debug('Request body => ' + body);
        
        request.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
        request.setHeader('customerId', customerId);
        System.debug('Request headers set => userId and customerId');
        
        ApiConnection.Response response = con.makeCallout(request);
        System.debug('API Response from loadPayrollSalaryList => ' + JSON.serialize(response));
        
        System.debug('=== Exiting loadPayrollSalaryList ===');
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadPayrollDetailsAndSalaryList(String customerId, String regionName, String payrollReference) {
        // ... existing implementation remains the same ...
        System.debug('=== Entering loadPayrollDetailsAndSalaryList ===');
        System.debug('Input Parameters => customerId: ' + customerId + ', regionName: ' + regionName + ', payrollReference: ' + payrollReference);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = PAYROLL_DETAIL_EP + '?payrollId=' + payrollReference;
        request = con.createRequest('POST', endpoint, regionName);
        System.debug('Created HTTP Request => ' + request + ' | Endpoint: ' + endpoint);
        
        if (regionName != null && regionName.toLowerCase().contains('alburaq')) {
            request.setTimeout(60000);
            System.debug('Alburaq region detected, timeout set to 60000ms');
        }
        
        request.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
        request.setHeader('customerId', customerId);
        request.setBody('{}');
        System.debug('Request headers set => userId and customerId');
        
        ApiConnection.Response response = con.makeCallout(request);
        System.debug('API Response from loadPayrollDetailsAndSalaryList => ' + JSON.serialize(response));
        
        System.debug('=== Exiting loadPayrollDetailsAndSalaryList ===');
        return response;
    }
    
    @AuraEnabled
    public static void savePayrollTotal(Id recordId, Decimal totalAmount, String actionStatus, Object payrollData, String selectedPayrollReference, String CIF) {
        if (recordId == null) {
            throw new AuraHandledException('Record Id is required');
        }
        
        WPSPayroll__c rec = [
            SELECT Id, Is_Actioned__c, Customer_CIF__c
            FROM WPSPayroll__c
            WHERE Id = :recordId
            LIMIT 1
        ];
        
        // Convert the payrollData object to a string and then parse it as Map<String, Object>
        String payrollDataJson = JSON.serialize(payrollData);
        Map<String, Object> payrollMap = (Map<String, Object>)JSON.deserializeUntyped(payrollDataJson);
        
        rec.Payroll_Total_Debit_Amount__c = totalAmount;
        rec.Action_Status__c = actionStatus;
        rec.Customer_CIF__c = CIF;
        //rec.Is_Actioned__c = true;
        
        // Populate all the new payroll fields
        rec.Payroll_Action__c = actionStatus;
        rec.Payroll_Amount__c = safeConvertToDecimal(payrollMap.get('payrollAmount'));
        rec.Payroll_Creation_Date__c = safeConvertToDate(payrollMap.get('creationDate'));
        rec.Payroll_Currency__c = safeConvertToString(payrollMap.get('currencyValue'));
        rec.Payroll_Debit_Account_IBAN__c = safeConvertToString(payrollMap.get('debitAccount'));
        rec.Payroll_Employer_Name__c = safeConvertToString(payrollMap.get('employerName'));
        rec.Payroll_No_of_Salaries__c = safeConvertToDecimal(payrollMap.get('numberOfSalaries'));
        rec.Payroll_Payment_Date__c = safeConvertToDate(payrollMap.get('paymentDate'));
        rec.Payroll_Reason__c = safeConvertToString(payrollMap.get('reason'));
        rec.Payroll_Reference__c = selectedPayrollReference;
        rec.Payroll_Salary_Month__c = safeConvertToString(payrollMap.get('salaryMonth'));
        rec.Payroll_Status__c = safeConvertToString(payrollMap.get('status'));
        rec.Payroll_Total_Debit_Amount__c = totalAmount;
        rec.Payroll_Transaction_Fees__c = safeConvertToDecimal(payrollMap.get('transactionFees'));
        rec.Payroll_VAT__c = safeConvertToDecimal(payrollMap.get('vat'));
        
        update rec;
    }
    
    @AuraEnabled(cacheable=true)
    public static PayrollDetailWrapper getStoredPayrollData(Id recordId) {
        System.debug('=== Entering getStoredPayrollData ===');
        System.debug('Input Parameters => recordId: ' + recordId);
        
        try {
            // Query the current record to check if it's actioned and has stored data
            WPSPayroll__c payrollRecord = [SELECT Id, Is_Actioned__c, Payroll_Reference__c, Payroll_Status__c, 
                                           Payroll_Debit_Account_IBAN__c, Payroll_Salary_Month__c, Payroll_Creation_Date__c,
                                           Payroll_Payment_Date__c, Payroll_Employer_Name__c, Payroll_No_of_Salaries__c,
                                           Payroll_Currency__c, Payroll_Amount__c, Payroll_Transaction_Fees__c,
                                           Payroll_VAT__c, Payroll_Total_Debit_Amount__c, Payroll_Action__c, Payroll_Reason__c
                                           FROM WPSPayroll__c 
                                           WHERE Id = :recordId LIMIT 1];
            
            System.debug('Payroll Record Found: ' + JSON.serialize(payrollRecord));
            
            // If record is actioned and has stored data, return the stored data
            if (payrollRecord.Is_Actioned__c && payrollRecord.Payroll_Reference__c != null) {
                System.debug('Returning stored payroll data from database');
                PayrollDetailWrapper detailWrapper = new PayrollDetailWrapper();
                
                detailWrapper.debitAccount = payrollRecord.Payroll_Debit_Account_IBAN__c;
                detailWrapper.reference = payrollRecord.Payroll_Reference__c;
                detailWrapper.salaryMonth = payrollRecord.Payroll_Salary_Month__c;
                detailWrapper.paymentDate = String.valueOf(payrollRecord.Payroll_Payment_Date__c);
                detailWrapper.employerName = payrollRecord.Payroll_Employer_Name__c;
                detailWrapper.employeeCount = String.valueOf(payrollRecord.Payroll_No_of_Salaries__c);
                detailWrapper.currencyValue = payrollRecord.Payroll_Currency__c;
                detailWrapper.payrollAmount = payrollRecord.Payroll_Amount__c != null ? String.valueOf(payrollRecord.Payroll_Amount__c) : '0';
                detailWrapper.transactionFees = payrollRecord.Payroll_Transaction_Fees__c != null ? String.valueOf(payrollRecord.Payroll_Transaction_Fees__c) : '0';
                detailWrapper.vat = payrollRecord.Payroll_VAT__c != null ? String.valueOf(payrollRecord.Payroll_VAT__c) : '0';
                detailWrapper.totalDebt = payrollRecord.Payroll_Total_Debit_Amount__c != null ? String.valueOf(payrollRecord.Payroll_Total_Debit_Amount__c) : '0';
                detailWrapper.status = payrollRecord.Payroll_Status__c;
                detailWrapper.action = payrollRecord.Payroll_Action__c;
                detailWrapper.reason = payrollRecord.Payroll_Reason__c;
                detailWrapper.creationDate = String.valueOf(payrollRecord.Payroll_Creation_Date__c);
                
                System.debug('Stored PayrollDetailWrapper: ' + JSON.serialize(detailWrapper));
                return detailWrapper;
            } else {
                System.debug('Record is not actioned or has no stored data');
                return null;
            }
            
        } catch (QueryException e) {
            System.debug('Query Exception in getStoredPayrollData: ' + e.getMessage());
            throw new AuraHandledException('Record not found: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Exception in getStoredPayrollData: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving stored payroll data: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> downloadPayrollDocument(String customerId, String regionName, String payrollRef, String payrollId, String status, String fileOutputType, String fees, String vat, String salaryMonth) {
        System.debug('=== Entering downloadPayrollDocument ===');
        System.debug('Input Parameters => customerId: ' + customerId + ', regionName: ' + regionName + ', payrollRef: ' + payrollRef + ', payrollId: ' + payrollId + ', status: ' + status + ', fileOutputType: ' + fileOutputType);
        
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            
            String endpoint = '/api/v1/wps/payroll/download';
            request = con.createRequest('POST', endpoint, regionName);
            request.setTimeout(120000);
            System.debug('Created HTTP Request => ' + request + ' | Endpoint: ' + endpoint);
            
            if (regionName != null && regionName.toLowerCase().contains('alburaq')) {
                request.setTimeout(120000);
                System.debug('Alburaq region detected, timeout set to 60000ms');
            }
            
            // Build request payload
            Map<String, Object> payload = new Map<String, Object>();
            payload.put('payrollRef', payrollRef);
            payload.put('payrollId', payrollId);
            payload.put('status', status);
            payload.put('fileOutputType', fileOutputType);
            payload.put('currency', 'BHD');
            payload.put('fees', fees);
            payload.put('vat', vat);
            payload.put('salaryMonth', salaryMonth);
            
            String requestBody = JSON.serialize(payload);
            request.setBody(requestBody);
            System.debug('Request body => ' + requestBody);
            
            request.setHeader('userId', 'ranjith.mathiyalagan@bank-abc.com');
            request.setHeader('customerId', customerId);
            request.setHeader('Content-Type', 'application/json');
            System.debug('Request headers set => userId and customerId');
            
            ApiConnection.Response apiResponse = con.makeCallout(request);
            System.debug('API Response from downloadPayrollDocument => ' + JSON.serialize(apiResponse));
            
            Map<String, Object> result = new Map<String, Object>();
            if (apiResponse.isSuccess == true) {
                System.debug('API call successful');
                
                if (apiResponse.responseData != null) {
                    Map<String, Object> responseData = (Map<String, Object>)apiResponse.responseData;
                    System.debug('Parsed responseData => ' + responseData);
                    
                    // Extract file data directly from responseData
                    result.put('success', true);
                    result.put('fileName', responseData.get('fileName'));
                    result.put('fileUrl', responseData.get('fileUrl'));
                    result.put('fileContent', responseData.get('fileContent'));
                    result.put('fileMimeType', responseData.get('fileMimeType'));
                } else {
                    result.put('success', false);
                    result.put('error', 'Response data is null');
                    System.debug('API response successful but responseData is null.');
                }
            } else {
                result.put('success', false);
                result.put('error', apiResponse.errorData != null ? apiResponse.errorData : 'API call failed');
                System.debug('API response not successful. Error: ' + apiResponse.errorData);
            }
            
            System.debug('Final result => ' + JSON.serialize(result));
            System.debug('=== Exiting downloadPayrollDocument ===');
            return result;
            
        } catch (Exception e) {
            System.debug('Exception in downloadPayrollDocument: ' + e.getMessage() + ' | Stack Trace: ' + e.getStackTraceString());
            Map<String, Object> errorResult = new Map<String, Object>();
            errorResult.put('success', false);
            errorResult.put('error', 'Error downloading document: ' + e.getMessage());
            return errorResult;
        }
    }
    
    // Helper methods for safe data conversion
    public static Decimal safeConvertToDecimal(Object value) {
        if (value == null) return null;
        try {
            return Decimal.valueOf(String.valueOf(value));
        } catch (Exception e) {
            System.debug('Error converting to Decimal: ' + value + ' - ' + e.getMessage());
            return null;
        }
    }
    
    public static Date safeConvertToDate(Object value) {
        if (value == null) return null;
        try {
            String dateStr = String.valueOf(value);
            if (String.isNotBlank(dateStr)) {
                return Date.valueOf(dateStr);
            }
            return null;
        } catch (Exception e) {
            System.debug('Error converting to Date: ' + value + ' - ' + e.getMessage());
            return null;
        }
    }
    
    public static String safeConvertToString(Object value) {
        if (value == null) return null;
        return String.valueOf(value);
    }

    public static String convertMonthToNumeric(String monthYear) {
        if (String.isBlank(monthYear)) {
        return null;
    }
    
    // Split the month and year
    List<String> parts = monthYear.split(' ');
    if (parts.size() != 2) {
        return null;
    }
    
    String month = parts[0];
    String year = parts[1];
    
    // Map month names to numbers
    Map<String, String> monthMap = new Map<String, String>{
        'Jan' => '01',
        'Feb' => '02',
        'Mar' => '03',
        'Apr' => '04',
        'May' => '05',
        'Jun' => '06',
        'Jul' => '07',
        'Aug' => '08',
        'Sep' => '09',
        'Oct' => '10',
        'Nov' => '11',
        'Dec' => '12'
    };
    
    // Handle full month names as well
    Map<String, String> fullMonthMap = new Map<String, String>{
        'January' => '01',
        'February' => '02',
        'March' => '03',
        'April' => '04',
        'May' => '05',
        'June' => '06',
        'July' => '07',
        'August' => '08',
        'September' => '09',
        'October' => '10',
        'November' => '11',
        'December' => '12'
    };
    
    String monthNum;
    
    // Check if it's abbreviated month
    if (monthMap.containsKey(month)) {
        monthNum = monthMap.get(month);
    } 
    // Check if it's full month name
    else if (fullMonthMap.containsKey(month)) {
        monthNum = fullMonthMap.get(month);
    } 
    else {
        return null; // Invalid month format
    }
    
    // Take last 2 digits of year
    String yearShort = year.length() >= 2 ? year.substring(year.length() - 2) : year;
    
    // Format as MMYYYY (without any separators)
    return monthNum + year;
    // If you want just last 2 digits of year (MMYY), use:
    // return monthNum + yearShort;
    }
    
    // Wrapper classes remain the same
    public class PayrollWrapper {
        @AuraEnabled public String reference { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String debitAccount { get; set; }
        @AuraEnabled public String salaryMonth { get; set; }
        @AuraEnabled public String salaryMonthBeforeFormatting { get; set; }
        @AuraEnabled public String creationDate { get; set; }
        @AuraEnabled public String paymentDate { get; set; }
        @AuraEnabled public String employerName { get; set; }
        @AuraEnabled public String numberOfSalaries { get; set; }
        @AuraEnabled public String currencyValue { get; set; }
        @AuraEnabled public String payrollAmount { get; set; }
        @AuraEnabled public String transactionFees { get; set; }
        @AuraEnabled public String vat { get; set; }
        @AuraEnabled public String totalDebitAmount { get; set; }
        @AuraEnabled public String action { get; set; }
        @AuraEnabled public String reason { get; set; }
        @AuraEnabled public String payrollRef { get; set; }
        @AuraEnabled public String resultDescription { get; set; }
        @AuraEnabled public String resultCode { get; set; }
        @AuraEnabled public List<String> allowedAction { get; set; }
    }
    
    public class PayrollDetailWrapper {
        @AuraEnabled public String debitAccount { get; set; }
        @AuraEnabled public String reference { get; set; }
        @AuraEnabled public String salaryMonth { get; set; }
        @AuraEnabled public String paymentDate { get; set; }
        @AuraEnabled public String employerName { get; set; }
        @AuraEnabled public String employeeCount { get; set; }
        @AuraEnabled public String currencyValue { get; set; }
        @AuraEnabled public String payrollAmount { get; set; }
        @AuraEnabled public String transactionFees { get; set; }
        @AuraEnabled public String vat { get; set; }
        @AuraEnabled public String totalDebt { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String reason { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String action { get; set; }
        @AuraEnabled public String creationDate { get; set; }
        @AuraEnabled public String ref { get; set; }
        @AuraEnabled public List<SalaryWrapper> salaries { get; set; }
    }
    
    public class SalaryWrapper {
        @AuraEnabled public String recordNo { get; set; }
        @AuraEnabled public String employeeName { get; set; }
        @AuraEnabled public String creditAccount { get; set; }
        @AuraEnabled public String bankSec { get; set; }
        @AuraEnabled public String currencyValue { get; set; }
        @AuraEnabled public String amount { get; set; }
        @AuraEnabled public String idType { get; set; }
        @AuraEnabled public String idNumber { get; set; }
    }
    
}