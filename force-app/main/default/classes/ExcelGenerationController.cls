/********************************************************************************************
* @name                 ExcelGenerationController
* @description          This controller is responsible to generate Excel file for Account and Saving Pot Transaction.
* @date                 23/09/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           23/09/2025     Initial Version
*********************************************************************************************
*/

public class ExcelGenerationController {

    public String cifNumber { get; set; }
    public String searchFilter { get; set; }
    public String region { get; set; }
    public String customerName { get; set; }
    public String potId { get; set; }
    public String potName { get; set; }
    public String fileName { get; set; }
    public String fromDate { get; set; }
    public String toDate { get; set; }
    public String datePopulated { get; set; }
    public String unit { get; set; }
    public String accountName { get; set; }
    public String earnInterest { get; set; }
    public String goalAmount { get; set; }
    public String monthlyDepositAmount { get; set; }
    
    public Boolean isFromDateIncludedInFilter { get; set; }
    
    
    public List<TransactionWrapper> transactionList { get; set; }
    
    Public ExcelGenerationController(){
        cifNumber = ApexPages.currentPage().getParameters().get('cifno');
        searchFilter = ApexPages.currentPage().getParameters().get('filter');
        region = ApexPages.currentPage().getParameters().get('region');
        datePopulated = ApexPages.currentPage().getParameters().get('datePopulated');
        
        transactionList = new List<TransactionWrapper>();
        
        String urlPath = ApexPages.currentPage().getURL();
        
        cifNumber = EncodingUtil.base64Decode(cifNumber).toString();
        region = EncodingUtil.base64Decode(region).toString();
        datePopulated = EncodingUtil.base64Decode(datePopulated).toString();
        
        if(region.contains('alburaq')){
            unit = 'Alburaq';
        }
        else {
            unit = 'Ila';
        }
        
        if(datePopulated == 'Y'){
            isFromDateIncludedInFilter = true;
            Map<String,Object> filterMap = (Map<String,Object>)JSON.deserializeUntyped(searchFilter);
            fromDate = (String)filterMap.get('fromDate');
            toDate = (String)filterMap.get('toDate');
        }
        
        if(urlPath.containsIgnoreCase('AccountTransactionExcel')){
            System.debug('cifNumber ' + cifNumber);
            System.debug('searchFilter ' + searchFilter);
            
            String accountNumber = ApexPages.currentPage().getParameters().get('accountNumber');
            String bankProductName = ApexPages.currentPage().getParameters().get('productName');
            accountNumber = EncodingUtil.base64Decode(accountNumber).toString();
            bankProductName = EncodingUtil.base64Decode(bankProductName).toString();
			accountName = bankProductName + ' - ' + accountNumber;      
            System.debug('region ' + region);
            Account accObj = [Select Id,Name FROM Account WHERE CIF__pc =:cifNumber];
            customerName = accObj.Name;
            ApexPages.currentPage().getHeaders().put('Content-Disposition', 'attachment; filename="' + cifNumber + '_Accounts_'+ DateTime.now().format('ddMMyyyy') +'.xls"');
            getAccountTransactions();
        }
        else if(urlPath.containsIgnoreCase('SavingPotTransactionExcel')){
            potId = ApexPages.currentPage().getParameters().get('potId');
            potName = ApexPages.currentPage().getParameters().get('potName');
            earnInterest = ApexPages.currentPage().getParameters().get('earnInterest');
            monthlyDepositAmount = ApexPages.currentPage().getParameters().get('monthlyDepositAmount');
            goalAmount = ApexPages.currentPage().getParameters().get('goalAmount');
            
            earnInterest = EncodingUtil.base64Decode(earnInterest).toString();
            monthlyDepositAmount = EncodingUtil.base64Decode(monthlyDepositAmount).toString();
            goalAmount = EncodingUtil.base64Decode(goalAmount).toString();
            earnInterest = earnInterest.capitalize();
            System.debug('earnInterest ' + earnInterest);
            ApexPages.currentPage().getHeaders().put('Content-Disposition', 'attachment; filename="' + cifNumber + '_SavingPots_'+ DateTime.now().format('ddMMyyyy') +'.xls"');
            getSavingPotTransactions();
        }
    }
    
    
    public void getAccountTransactions(){
        ApiConnection.Response response = BankAccountController.loadAccountTransactions(cifNumber,searchFilter,region);
        System.debug('account transaction res ' + JSON.serializePretty(response.responseData));
        List<Object> transactions = (List<Object>)response.responseData;
        extractTransactionData(transactions);
    }
    
    public void getSavingPotTransactions(){
        System.debug('potName ' + potName);
        potId = EncodingUtil.base64Decode(potId).toString();
        potName = EncodingUtil.base64Decode(potName).toString();
        Account accObj = [Select Id,Name FROM Account WHERE CIF__pc =:cifNumber];
        customerName = accObj.Name;
        
        ApiConnection.Response response = SavingPotController.loadPotTransactions(cifNumber,potId,searchFilter,region);
        System.debug('pot transaction res ' + JSON.serializePretty(response.responseData));
        List<Object> transactions = (List<Object>)response.responseData;
        extractTransactionData(transactions);
    }
    
    public void extractTransactionData(List<Object> transactions){
        //transactionWrapperList
        for(Object transObj : transactions){
        	Map<String, Object> transactionMap = (Map<String, Object>)transObj;
            Map<String, Object> transCurrencyMap = (Map<String, Object>)transactionMap.get('transactionCurrency');
            
            String transDate = (String)transactionMap.get('transactionDate');
            List<String> dateComponent = transDate.split('T');
            List<String> ddmmyy = dateComponent[0].split('-');
            
            Integer yyyy = Integer.valueOf(ddmmyy[0]);
            Integer mm = Integer.valueOf(ddmmyy[1]);
            Integer dd = Integer.valueOf(ddmmyy[2]);
            DateTime transationDate = DateTime.newInstance(yyyy,mm,dd);
            
            System.debug('dateComponent ' + dateComponent);
            //transDate = transDate.replace('T', ' '); //removing T from datetime
            transDate = dateComponent[1].substring(0, dateComponent[1].length() - 3); //Removing last 3 digit from datetime e.g. '2025-08-06T10:43:31' in the sample date :31 would removed.
            transDate = transationDate.format('dd MMM yyyy') + ' ' + transDate; 
            String allDescriptions = '';
            String desc1 = (String)transactionMap.get('transactionDescription1');
            String desc2 = (String)transactionMap.get('transactionDescription2');
            String desc3 = (String)transactionMap.get('transactionDescription3');
            String desc4 = (String)transactionMap.get('transactionDescription4');
            String desc5 = (String)transactionMap.get('transactionDescription5');
            
            if(!String.isBlank(desc1)){
                allDescriptions = desc1;
            }
            
            if(!String.isBlank(desc2)){
                allDescriptions = allDescriptions + ', ' + desc2;
            }
            
            if(!String.isBlank(desc3)){
                allDescriptions = allDescriptions + ', ' + desc3;
            }
            
            if(!String.isBlank(desc4)){
                allDescriptions = allDescriptions + ', ' + desc4;
            }
            
            if(!String.isBlank(desc5)){
                allDescriptions = allDescriptions + ', ' + desc5;
            }
            
            TransactionWrapper wrapper = new TransactionWrapper();
            wrapper.status = (String)transactionMap.get('status');
            wrapper.reference = (String)transactionMap.get('reference');
            wrapper.amount = (Decimal)transactionMap.get('amount');
            wrapper.originalAmount = (Decimal)transactionMap.get('originalAmount');
            wrapper.description = allDescriptions;//(String)transactionMap.get('transactionDescription1');
            wrapper.transactionType = (String)transactionMap.get('transactionType');
            wrapper.currencyCode = (String)transCurrencyMap.get('code');
            wrapper.transactionDate = transDate;
            wrapper.formattedAmount = getFormattedCurrency(wrapper.amount);
            wrapper.formattedOriginalAmount = getFormattedCurrency(wrapper.originalAmount);
            transactionList.add(wrapper);
        }
    }
    
    /**
     * @description : This method would generate thousand separate currency formating e.g 100,100.000
     * @param : currencyValue
     * @return : String
     */
    public String getFormattedCurrency(Decimal currencyValue){
        if(currencyValue == null) return '';
        
        String formattedCurrency = currencyValue.format();
        
        if(formattedCurrency != '' && !formattedCurrency.contains('.')){
            formattedCurrency = formattedCurrency + '.000';
        }
        else {
            String currencyDecimal = formattedCurrency.split('\\.')[1];
            if(currencyDecimal.length() == 0){
                formattedCurrency = formattedCurrency + '000';
            }
            else if(currencyDecimal.length() == 1){
                formattedCurrency = formattedCurrency + '00';
            }
            else if(currencyDecimal.length() == 2){
                formattedCurrency = formattedCurrency + '0';
            }
        }
        return formattedCurrency;
    }
    
    public class TransactionWrapper {
        public String transactionDate { get; set; }
        public String transactionType { get; set; }
        public String status { get; set; }
        public String currencyCode { get; set; }
        public String description { get; set; }
        public String reference { get; set; }
        public String formattedAmount { get; set; } //currency with 3 decimal point
        public String formattedOriginalAmount { get; set; } //currency with 3 decimal point
        
        public Decimal amount { get; set; }
        public Decimal originalAmount { get; set; }
        
    }
}