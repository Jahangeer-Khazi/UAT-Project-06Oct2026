/*     
 *     Change History: 
 *          #CH01 : hamza chaoui 22/07/2022 -- add alburaq notification logic
 *          #CH02 : #ANISS MBARKI #01-08-2022# Prepaid Card Requirement.
 *       #CH03 : Meryem Bakir 26/05/2023 Add Region Flag 
 *       #CH04 : Aniss Mbarki 17/07/2025 CRM Enhancements - Generating Letters from CRM - CRM Changes
 *      #CH05 : Maksud Ali 10/09/2025 CRM Enhancements - Validating Generate case request, for outstanding, cancelling and no due
*/
public class CreditCollectionLettersController {
    private static ApiConnection con = new ApiConnection();
    @AuraEnabled
    public static Id getCollectionLetterCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Collection_Letter').getRecordTypeId();
    }
    
    @AuraEnabled
    public static Id getCollectionLetterCaseQueue() {
        Id queueId= [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Credit_Collection_Maker'].Id;
        return queueId;
        }
    
    public static Map<String,String> getCardOptions(String accID,string filerOption){
        Map<String,String> retriveCardOption =  new Map<String,String>();
        Map<String,String> retrivePCIOption = new Map<String,String>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        system.debug('accID==>'+accID);
        // CH03 - Add Region Flag - Meryem Bakir
        Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c FROM Account WHERE Id=:accID];
        final ApiConnection.Response response = SM001_ApiCalls.getCreditCardStatusApi(con, accObj.PersonEmail,accObj.CIF__pc,filerOption,accObj.Region_Flag__c);
        
       // System.debug('swapna==>'+JSON.serializePretty(response));
        if (response!=null && response.isSuccess && null != response.responseData) {
            Map<String, Object> m = (Map<String, Object>)response.responseData;
            System.debug('m==>'+m);
            List<Object> currCardsList = (List<Object>)m.get('currentCards');
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+lstcardMap);
                 
            }
         
         
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                system.debug('mapRelatedCurrentCards.get==>'+mapRelatedCurrentCards.get('status'));
                if(filerOption=='C' && (mapRelatedCurrentCards.get('status')=='AccountCancelledByBank'|| mapRelatedCurrentCards.get('status')=='AccountCancelledByCustomer')
                   ||filerOption=='D')
                {
                    if(mapRelatedCurrentCards.containsKey('id')&& mapRelatedCurrentCards.get('isPrimary')==true) 
                   {
                       //#CH02 -- Start
                       String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                       if(!cardNature.contains('prepaid')){
                           retriveCardOption.put((String)mapRelatedCurrentCards.get('maskedCardNumber')+'&'+(String)mapRelatedCurrentCards.get('issueDate')+'&'+(String)mapRelatedCurrentCards.get('id')+'&'+(String)mapRelatedCurrentCards.get('blockDate'),(String)mapRelatedCurrentCards.get('cardDisplayName'));
                       }
                       //#CH02 -- End
                    }
                }
                
            }
            system.debug('retrivePCIOption||'+retriveCardOption);
         
        }
        else
        {
            System.debug('The status code returned was not expected: ' + response );
 
        }
        return retriveCardOption;
    }

    public static Map<String,String> loadCardDetails(final String accId, final String cardId) {
          Map<String,String> retriveCardOption =  new Map<String,String>();
        List<Account> accounts=[select id,CIF__pc,personEmail,Region_Flag__c from Account where Id=:accId];

        final ApiConnection.Response response = SM001_ApiCalls.getCreditCardDetailsApi(con,cardId,accounts[0].CIF__pc,accounts[0].personEmail,accounts[0].Region_Flag__c);

        system.debug('---> RESPONSE --> '+response);
        Map<String, Object> m = (Map<String, Object>)response.responseData;
        retriveCardOption.put(string.valueOf(m.get('creditLimit')),string.valueOf(m.get('usedCreditLimit')));
        system.debug('---->> retriveCardOption --> '+retriveCardOption);

       return retriveCardOption;
    }
    @AuraEnabled(cacheable=false)
    public static String sendEmailWithPdf(ID caseId){
        //#CH01 : add Case_Model__c
        Case cs = [SELECT Id,Status,Region_Flag__c,AccountId,ContactEmail,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,cc_Business_Approval_Result__c,cc_Business_Approval_Result_Date_Time__c,Case_Model__c,Sub_Type__c,Case_Nature__c  FROM Case Where ID =:caseId];
        contact cd = [SELECT Id,Name,Email FROM contact WHERE AccountId =:cs.AccountId];
        String responseMessage;
        string fileName;
        PageReference pdf;

        //CH04 : start
        if(cs.Sub_Type__c=='Outstanding balance Letter'){
            pdf = Page.Outstanding_Balance_Letter;
        }
        else if(cs.Sub_Type__c=='Cancellation Letter')
        {
            pdf=Page.Cancellation_Letter_PDF;
        }
        else if(cs.Sub_Type__c=='No Due Letter')
        {
            pdf=Page.No_Due_Letter_PDF;
        }
        else if(cs.Sub_Type__c=='Balance Confirmation Letter')
        {
            pdf=Page.Balance_Confirmation_PDF;
        }
        else if(cs.Sub_Type__c=='Reference Letter')
        {
            pdf=Page.Reference_Letter_PDF;
        }

        fileName = cs.Sub_Type__c+'.pdf';
        //CH04 : end

        pdf.getParameters().put('accId', cs.AccountId);
        pdf.getParameters().put('csId', cs.Id);
        
        Blob b;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
        }
        else{
            system.debug('CaseId||'+CaseId);
            b = pdf.getContent();
        }

        //#CH01 -Start
        EmailTemplate et;
        if(cs.Case_Model__c == 'alburaq'){
            et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='Letter_Generation_Request_Alburaq'];
        }else{
            et = [SELECT Id,Name FROM EmailTemplate WHERE DeveloperName ='Letter_Generation_Request'];
        }
        //#CH01 -End
        OrgWideEmailAddress owe;
        if(cs.Region_Flag__c == 'Bahrain'){
            owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
        }else{
            owe = [select Id from OrgWideEmailAddress where Address = 'support@ilajordan.com'];
        }
        
        system.debug('et--->'+et);
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(fileName);
        efa.setBody(b);
                        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(cs.Id);
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{cd.Email} );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                responseMessage='Success';
                //#CH04 :Start
                if(cs.Case_Nature__c == 'FCR'){
                    cs.Status= 'Closed';
                    update cs;
                }
                //#CH04 :End
            }else{
                responseMessage='Email Not sent successfully';
            }
            
        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
            System.debug('result'+responseMessage);
        }
        return responseMessage; 
    }
    
    @AuraEnabled(cacheable=false)
    public static string downloadcasePdf(ID caseId){
        system.debug('reached');
        Case cs = [SELECT Id,Status,AccountId,Account.CIF__pc/*,Letter_Type__c*/,ContactEmail,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,cc_Business_Approval_Result__c,cc_Business_Approval_Result_Date_Time__c,Sub_Type__c,Case_Nature__c FROM Case Where ID =:caseId];
        System.debug('cs cs acc ' + cs.AccountId);
        System.debug('cs cs case id ' + cs.Id);
        //contact cd = [SELECT Id,Name,Email,Account.CIF__pc FROM contact WHERE AccountId =:cs.AccountId];
        //getCardOptions(cs.AccountId);
        PageReference pdf;
        //CH04 : start
        if(cs.Sub_Type__c=='Outstanding balance Letter'){
            pdf = Page.Outstanding_Balance_Letter;
        }
        else if(cs.Sub_Type__c=='Cancellation Letter')
        {
            pdf=Page.Cancellation_Letter_PDF;
        }
        else if(cs.Sub_Type__c=='No Due Letter')
        {
            pdf=Page.No_Due_Letter_PDF;
        }
        else if(cs.Sub_Type__c=='Balance Confirmation Letter')
        {
            pdf=Page.Balance_Confirmation_PDF;
        }
        else if(cs.Sub_Type__c=='Reference Letter')
        {
            pdf=Page.Reference_Letter_PDF;
        }
        //CH04 : end

        pdf.getParameters().put('accId', cs.AccountId);
        pdf.getParameters().put('csId', cs.Id);
        
        Blob b;
        string newblobMessage;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
        }
        else{
            system.debug('CaseId||'+CaseId);
            b = pdf.getContent();
            newblobMessage = EncodingUtil.base64Encode(b);
        }

        //#CH04 :Start
        if(cs.Case_Nature__c == 'FCR'&& !Test.IsRunningTest()){
            cs.Status= 'Closed';
            cs.Sub_Status__c='Processed';
            update cs;
        }
        //#CH04 :End
     
        return newblobMessage; 
    }

    //#CH04
    @AuraEnabled
  public static String getDefaultAccountIdViaApi(String accountId,String caseModel) {
        List<Object> accountsList = LTNG035_NewBankStatementReqController.getAccountConfigViaApi(accountId, caseModel);
        for (Object item : accountsList) {
            Map<String, Object> firstElement = (Map<String, Object>) item;
            Map<String, Object> accountDetails = (Map<String, Object>) firstElement.get('account');
            system.debug('accountsList accountDetails--> '+accountDetails);

            if((Boolean)accountDetails.get('defaultAccount') == true){
                return String.valueOf(firstElement.get('id'));
            }
        }
        return null;
    }
    
    //#CH05 - Start
    @AuraEnabled
    public static String validateCreditCard(String accountId,String filerOption,String letterType){
        String response = '';
        try {
            Account accountObj = [Select Id,Name,CIF__pc,Subscription_Model__pc,PersonEmail,Region_Flag__c,ID_Number__pc,x_canary__pc 
                                  FROM Account WHERE id=:accountId];
            Boolean isCard = false;
            List<Object> currentCardMap = getCurrentCards(accountObj,filerOption);
            if(filerOption == 'D'){ //D filter option is for Outstanding Balance/No Due Letter
                isCard = fetchNoDueOrOutstandingCardDetails(currentCardMap);
                Boolean isLoan = checkCustomerHasActiveLoan(accountObj);
                if(letterType == 'no due letter'){
                    if(!isCard && !isLoan){
                        return 'success';
                    }
                    else {
                        return 'Customer has active credit card / loans or finances.';
                    }
                }
                else {
                    if(isCard || isLoan){
                        return 'success';
                    }
                    else {
                         return 'This request cannot be processed at this time, as There is no Credit Card / Loan for the Customer.';
                    }
                }
            }
            else if(filerOption == 'A'){ //C filter option is for Cancellation Letter
                isCard = fetchCancelledCardDetails(currentCardMap);
                return isCard ? 'success' : 'This request cannot be processed at this time, as There is no Cancelled Credit Card for the Customer.';
            }
            response = isCard ? 'success' : 'There is no valid card found. This process cannot be done.';
        }
        catch(Exception ex){
            response = ex.getMessage();
        }
        
        return response;
    }
    
    public static List<Object> getCurrentCards(Account accountObj,String filerOption){
        
        HttpRequest request = con.createRequest('GET', '/api/v1/credit-cards', accountObj.CIF__pc, accountObj.Region_Flag__c);
        if(accountObj.x_canary__pc != null){
            request.setHeader('x-canary', accountObj.x_canary__pc); //CH09
        }
        String endPoint = request.getEndpoint();
        request.setEndpoint(endPoint + '&filterOption=' + filerOption);
        ApiConnection.Response response = con.makeCallout(request);
        
        //ApiConnection.Response response = SM001_ApiCalls.getCreditCardStatusApi(con, accountObj.PersonEmail,accountObj.CIF__pc,filerOption,accountObj.Region_Flag__c);
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        System.debug('card option ' + JSON.serializePretty(response));
        if(responseData == null || !responseData.containsKey('currentCards')){
            return new List<Object>();
        }
        
        return (List<Object>)responseData.get('currentCards');
    }
    
    public static Boolean checkCustomerHasActiveLoan(Account accountObj){
        Boolean isActiveLoan = false;
        if(accountObj.Subscription_Model__pc == 'both'){
          List<Object> ilaLoans = getCurrentLoans(accountObj.CIF__pc,'ila');
            Boolean ilaActiveLoan = hasCustomerActiveLoan(ilaLoans);
            
            List<Object> alBuraqLoans = getCurrentLoans(accountObj.CIF__pc,'alburaq');
            Boolean alburaqActiveLoan = hasCustomerActiveLoan(alBuraqLoans);
            
            if(ilaActiveLoan || alburaqActiveLoan){
                isActiveLoan = true;
            }
        }
        else {
            List<Object> ilaLoans = getCurrentLoans(accountObj.CIF__pc,accountObj.Subscription_Model__pc);
            isActiveLoan = hasCustomerActiveLoan(ilaLoans);
        }
        
        return isActiveLoan;
    }
    
    public static List<Object> getCurrentLoans(String cif,String caseModel){
        ApiConnection.Response response = Loans_ServiceManagerHandler.callLoansOptionsAPI(cif,caseModel);
        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        if(responseData != null && responseData.containsKey('currentLoans')){
            return (List<Object>)responseData.get('currentLoans');
        }
        return new List<Object>();
    }
    
    public static Boolean hasCustomerActiveLoan(List<Object> currentLoans){
        String statusToAvoid = 'close,pending,closure'; //loan status must not be one of them.
        Boolean isActiveLoan = false;
        for(Object loan : currentLoans){
            Map<String, Object> loanObject = (Map<String, Object>)loan;
          String status = (String)loanObject.get('status');
            if(!statusToAvoid.contains(status.toLowerCase()) || status.toLowerCase() != 'unauth'){
              isActiveLoan = true;
                break;
            }
        }
        return isActiveLoan;
    }
    
    public static Boolean fetchCancelledCardDetails(List<Object> currCardsList){
        Boolean isCancelledCard = false;
        for(Object curCards : currCardsList){
          Map<String, Object> currentCardMap = (Map<String, Object>)curCards;
            System.debug('currentCardMap ' + currentCardMap);
            String cancelledCardStatus = 'account_cancelled_by_bank,account_cancelled_by_customer';
            Boolean isPrimaryCard = (Boolean)currentCardMap.get('isPrimary');
            String cardNature = (String)currentCardMap.get('cardNature');
            String cardStatus = (String)currentCardMap.get('status');
            System.debug('cardStatus ' + cardStatus);
            if(isPrimaryCard && !cardNature.equalsIgnoreCase('prepaid') && cancelledCardStatus.contains(cardStatus.toLowerCase())){
                isCancelledCard = true;
                break;
            }
        }
        return isCancelledCard;
    }
    
    public static Boolean fetchNoDueOrOutstandingCardDetails(List<Object> currCardsList){
        Boolean isCreditCard = false;
        for(Object curCards : currCardsList){
          Map<String, Object> currentCardMap = (Map<String, Object>)curCards;
            Boolean isPrimaryCard = (Boolean)currentCardMap.get('isPrimary');
            String cardNature = (String)currentCardMap.get('cardNature');
            
            if(isPrimaryCard && !cardNature.equalsIgnoreCase('prepaid')){
                isCreditCard = true;
                break;
            }
        }
        return isCreditCard;
    }
    //#CH05 - End
}