/********************************************************************************************
* @name                 CashCollateralCertificateController
* @description          This controller is responsible to render Cash Collateral Certificate
* @date                 13/03/2025
* @cretaedby            Maksud
*********************************************************************************************
* version               Author              Date            Comments
* 1.0                   Maksud           13/03/2025     Initial Version
*********************************************************************************************
*/

public class CashCollateralCertificateController {

    public String customerFullName { get; set; }
    public String customerName { get; set; }
    public String customerFullAddress { get; set; }
    public String caseNumber { get; set; }
    public String nationalityId { get; set; }
    public String nationality { get; set; }
    public String typeOfAccount { get; set; }
    public String accountNumber { get; set; }
    public String creditLimit { get; set; }
    public String issueDate { get; set; }
    public String cardType { get; set; }
    public String pledgedAmount { get; set; }
    public String holdAccount { get; set; }
    
    public CashCollateralCertificateController(ApexPages.StandardController controller) {
        
        Id caseId = controller.getId();
        
        typeOfAccount = ApexPages.currentPage().getParameters().get('typeOfAccount');
        accountNumber = ApexPages.currentPage().getParameters().get('accountNo');
        creditLimit = ApexPages.currentPage().getParameters().get('creditLimit');
        issueDate = ApexPages.currentPage().getParameters().get('issueDate');
        cardType = ApexPages.currentPage().getParameters().get('cardType');
        pledgedAmount = ApexPages.currentPage().getParameters().get('pledgedAmount');
        holdAccount = ApexPages.currentPage().getParameters().get('holdAccount');
        
        if(typeOfAccount == 'FIXED_DEPOSIT'){
            typeOfAccount = 'Fixed Deposit';
        }
        
        pledgedAmount = convertAmountToCurrency(pledgedAmount);
        creditLimit = convertAmountToCurrency(creditLimit);
        
        if(!String.isEmpty(cardType)){
            cardType = cardType.toLowerCase();
            cardType = cardType.replace('credit card','').trim();
            
            if(cardType == 'ila gulf air'){
                cardType = 'ila Gulf Air';
            }
        }
        
        if(!String.isEmpty(caseId)){
            List<Case> listOfCases = [Select Id,Contact.AccountId,CaseNumber FROM Case 
                                     WHERE Id =:caseId LIMIT 1];
            if(!listOfCases.isEmpty()){
                caseNumber = listOfCases[0].CaseNumber;
                Contact contactObj = listOfCases[0].Contact;
                
                if(!String.isEmpty(contactObj.AccountId)){
                    Account acct = [SELECT Name,FirstName,LastName,MiddleName,
                                    ID_Number__pc,Nationality__pc,PersonMailingAddress 
                                    FROM Account 
                                    WHERE Id =: contactObj.AccountId];
                    System.debug('acct details ' + acct);
                    customerFullName = acct.Name;//+ ' ' + acct.MiddleName + ' ' + acct.LastName;
                    customerName = acct.FirstName + ' ' + acct.LastName;
                    nationalityId = acct.ID_Number__pc;
                    nationality = acct.Nationality__pc;
                    Address mailingAddr = acct.PersonMailingAddress;
                    customerFullAddress = getCustomerFullAddress(mailingAddr);
                }
            }
        }
    }
    
    /**
     * name : getFormattedTodayDate
     * @description : this method would return today's formatted date.
     */
    public String getCustomerFullAddress(Address mailingAddr) {
        String addr = '';
        
        if(!String.isEmpty(mailingAddr.Street)){
            addr = mailingAddr.street;
        }
        
        if(!String.isEmpty(mailingAddr.City)){
            addr = String.isEmpty(addr) ? mailingAddr.City : addr + ', ' + mailingAddr.City;
        }
        
        if(!String.isEmpty(mailingAddr.State)){
            addr = String.isEmpty(addr) ? mailingAddr.State : addr + ', ' + mailingAddr.State;
        }
        
        if(!String.isEmpty(mailingAddr.PostalCode)){
            addr = String.isEmpty(addr) ? mailingAddr.PostalCode : addr + ', ' + mailingAddr.PostalCode;
        }
        
        if(!String.isEmpty(mailingAddr.Country)){
            addr = String.isEmpty(addr) ? mailingAddr.Country : addr + ', ' + mailingAddr.Country;
        }
        
        return addr;
    }
    
    /**
     * name : getFormattedTodayDate
     * @description : this method would return today's formatted date.
     * @return String (string date)
     */
    public String getFormattedTodayDate() {
        Date todayDate = Date.today();
        // Format the date using the user's locale (default format)
        String formattedDate = todayDate.format();
        
        // Apply manual formatting (if needed, using split for 'MM/dd/yyyy' format)
        String[] dateParts = formattedDate.split('/');
        if (dateParts.size() == 3) {
            formattedDate = dateParts[0] + '/' + dateParts[1] + '/' + dateParts[2];
        }
        return formattedDate;
    }
    
    
    /**
     * name : convertAmountToCurrency
     * @description : this method would convert the given amount to currency format with 3 decimal point.
     * @param : amount
     * @return String (convered currency)
     */
    public String convertAmountToCurrency(String amount){
        
        try {
            Decimal convertedAmount = 0;
            convertedAmount = Decimal.valueof(amount);  
            convertedAmount = convertedAmount.setScale(3);
            String convertedCurrency = String.valueOf(convertedAmount.format());
            String[] arrAmount = convertedCurrency.split('\\.');
            
            
            if(arrAmount.size() == 1){
                convertedCurrency = convertedCurrency + '.000';
            }
            else {
                Integer decimalLength = arrAmount[1].length();
                if(decimalLength == 1){
                    convertedCurrency = convertedCurrency + '00';
                }
                else if(decimalLength == 2){
                    convertedCurrency = convertedCurrency + '0';
                }
            }
            return convertedCurrency;
        }
        catch(exception ex){
            System.debug('error ' + ex.getMessage());
            return '0';
        }
    }
}