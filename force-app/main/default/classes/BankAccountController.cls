/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-08 11:03:42
 *  @description:
 *      controller for aura components related to Bank Account
 *
 *  Version History :
 *  2019-02-08 - CRM-37 - AG
 *  display bank account list and account details
 *  Change History:
 *                #CH01# #Jahangeer Mohammed# #02-06-2022# Added holdAmount Parameter for Staff Visibility(NBA-5191)
 *                #CH02# #Mbarki Aniss# #21-06-2022# add visibility function for Debit+Card+Enhancement requirement
 *                #CH03# #Hamza Chaoui# #22-07-2022# add alburaq logic for email notification
 *                #CH04# #Mbarki Aniss# #10-05-2023# add caseId parameter for email notification
 *                #CH05# #Mbarki Aniss# #02-01-2024# add x-canary header
 *                #CH06# #Tsioucha Imane# #12-09-2023# add Account Details Minimum Balance
 *                #CH07# #Tsioucha Imane #11-03-2024# Added logic for Download IBAN Letter
 *                #CH08# #Tsioucha Imane# #15-04-2024# add x-canary header
 *                #CH09# #Jahangeer Mohammed #28-04-2024# Added logic for Audit History Enhancements(NBA-9027)
 *                #CH10# #Ranjith Raja# #12-10-2024# add Created a new method to send an email with IBAN PDF Certificate
 *                #CH11# #Maksud Ali# #08-12-2025# add new methods for HYSA.
 *                #CH12 #Omar Aitogram #01-04-2026# Added logic for Dormancy Visibility Restrictions (NBA-11705)
 */
public with sharing virtual class BankAccountController {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    public static String regionName;
    @TestVisible // overwrite instance to provide custom DAO in test class
    private static BankAccountController DAO = new BankAccountController();

    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_LIST = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance'
    };
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_DETAILS = new List<String>{
        'account.availableBalance',
        'account.ledgerBalance',
         //CH01: Start
        'account.holdAmount'
        //CH01: END
    };

    //#CH11 Start.
    /**
     * @descriptioin : This method would return the HYSA list.
     */ 
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadHysaList(final String customerId, String regionName) {
        
        String path = '/api/v1/accounts?returnedAccounts=';
        
        if(regionName != null && regionName.endsWithIgnoreCase('_alburaq')){
            path = path + 'HB';
        }
        else {
            path = path + 'HY';
        }
        
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        
        if(accs!= null && accs.size() > 0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('HYSA Application Response ' + response);
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] accounts = (Object[])responseData.get('accounts');
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(accounts, SENSITIVE_FIELDS_ACCOUNT_LIST);
            }
        }
        return response;
    }
    //#CH11 end

    // #CH12 start
    @AuraEnabled(cacheable=false)
    public static Boolean getJordanVisibility(String customerId) {
        return SensitiveDataCleaner.loadIsDataCleaningRequired(customerId);
    }
    // #CH12 end

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountList(final String customerId, String regionName) {
        //final String path = '/api/v1/accounts?';
        final String path = '/api/v1/accounts?returnedAccounts=default,HY';
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        //req.setTimeout(120000);
        //#CH06 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH06 : end
        system.debug('request '+req.getBody());
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('loadAccountList ||'+JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] accounts = (Object[])responseData.get('accounts');
            System.debug('Accounts to filter:'+accounts);
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(accounts, SENSITIVE_FIELDS_ACCOUNT_LIST);
            }
        }
        System.debug('loadAccountList##'+response);
        return response;
    }
    @AuraEnabled(cacheable=false)
    public static Account loadAccountByCif(final String cif) {
        return DAO.loadAccount(cif);
    }

    //#CH11 Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadHysaAccountDetails(final String customerId, final String accountId, String regionName) {
        
        final String path = '/api/v1/accounts/details?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        req.setBody('{"id": "' + accountId + '"}');
        
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }

        final ApiConnection.Response response = con.makeCallout(req);
        
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
        }
        return response;
    }
    //#CH11 Start
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountDetails(final String customerId, final String accountId, String regionName) {
        System.debug('customerId --->'+customerId);
        System.debug('accountId --->'+accountId);
        System.debug('regionName --->'+regionName);
        
        final String path = '/api/v1/accounts/details?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        req.setBody('{"id": "'+accountId+'"}');
        //req.setHeader('Content-Length', );

        //#CH06 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH06 : end

        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('******************** loadAccountDetails : Start ********************* ');

        System.debug(req.getEndpoint());    
        System.debug(req.getMethod());
        System.debug(req.getBody());
        System.debug(JSON.serializePretty(response));
        System.debug('******************** loadAccountDetails : End ********************* ');

        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
        }
        return response;
    }
     /* Code Commented by Imane Tsioucha(Minimum Balance Project on Hold)
    //CH05: Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountDetailsMinimumBalance(final String customerId,final String accountNumber,final String curency, final String accountId, String regionName) {
        final String path = '/api/v1/accounts/minimum-balance?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        req.setBody('{"id": "'+accountId+'",'+'"accountNumber": "'+accountNumber+'",'+'"currency": "'+curency+'"}');
        final ApiConnection.Response response ;

       final ApiConnection.Response response = con.makeCallout(req);
        System.debug('******************** loadAccountDetailsMinimumBalance : Start ********************* ');
        System.debug('request body==> '+req.getBody());
        System.debug(req.getEndpoint());    
        System.debug(req.getMethod());
        System.debug(req.getBody());
        System.debug(response);
        System.debug(JSON.serializePretty(response));
        System.debug('******************** loadAccountDetailsMinimumBalance : End ********************* ');

        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
        }
        return response;
    }
    //CH05: End
    */


    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountTransactions(final String customerId,final String searchParametersJson, String regionName) {
        System.debug(' Customer ID ' +customerId+ 'search parameter ' +searchParametersJson+ ' regionName ' +regionName);

        // setup default response with no data
        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = new List<Object>();
        final String path = '/api/v1/transactions?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        //req.setTimeout(30000);
        req.setTimeout(120000);
        req.setBody(searchParametersJson);
        //#CH08 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
        System.debug('x-canary added :'+accs.get(0).x_canary__pc);
         if(accs.get(0).x_canary__pc != null){
             req.setHeader('x-canary', accs.get(0).x_canary__pc);
         }
        }
        //#CH08 : end
        System.debug('Request Body:'+req.getBody());
        response = con.makeCallout(req);
        System.debug('loadAccountTransactions>>>>>' + JSON.serializePretty(response));

        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        System.debug('Response data keys:'+responseData.keySet());
        Object[] transactions = (Object[])responseData.get('transactions');
        System.debug('Transaction Length after getting response:'+transactions.size());
        //if there are requried clean data, it means segment is staff and view staff = false
        //we will filter staff transaction from it
        if (response.isSuccess && null != response.responseData){

            response.recordLength = transactions.size();
            //if view staff = true, we will display all transactions
            if(SensitiveDataCleaner.isAllowedViewStaffData(customerId)){
                response.responseData = transactions;
            }
            //if view staff = false, we will display only transaction during Segment != staff
            else{
                List<Map<String, Datetime>> lstBanedDate = SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                response.responseData = SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, transactions);
            }
        }
       System.debug('Response object:'+response);
       return response;



    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response requestCashCollectionOrDelivery(final String customerId, final Id caseId,
                                                                            final String requestData, final String requestType, final String regionName) {

        //TODO - implement API call when API endpoint is available
        final HttpRequest req = con.createRequest('PUT', '/api/v1/TODO', customerId, regionName);
        req.setBody(requestData);//TODO - change when API is available

        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, requestType);

        final ApiConnection.Response response = con.makeCallout(req, action);
        response.isSuccess = true;//TODO - remove when API is available
        //response.responseData = new List<Object>();


        return response;
    }
    /**
     * @param extraParameters:
     *  ex: "{ systemActionType: '...', caseType: '...' , caseSubType: '...', isCaseClosureRequired: true}"
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response requestNewCard(final String customerId, final String requestTextJson,
                                                        final Id caseId,
                                                        final String extraParameters, final String personEmail, String regionName) {

        return BankCardListController.requestNewCard(customerId, requestTextJson, /*maskedCardNumber=*/null, caseId, extraParameters, personEmail, regionName);
    }

    @AuraEnabled(cacheable=true)
    public static String loadCountryPicklistValues() {
        return getPicklistValuesJson('Contact', 'Nationality__c');
    }
    @AuraEnabled(cacheable=true)
    public static String loadCurrencyPicklistValues() {
        return JSON.serialize([select DeveloperName, MasterLabel from Currency__mdt order by MasterLabel]);
    }

    public static List<Schema.PicklistEntry> getPicklistValues(final SObject obj, final String fld){
        final List<SelectOption> options = new list<SelectOption>();
        // Get the object type of the SObject.
        final Schema.sObjectType objType = obj.getSObjectType();
        // Describe the SObject using its object type.
        final Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        final Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        final List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();

        return values;
    }
    public static String getPicklistValuesJson(final String objApiName, final String fieldApiName){
        final Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objApiName);
        final SObject objInstance = targetType.newSObject();
        final List<Schema.PicklistEntry> entries = getPicklistValues(objInstance, fieldApiName);
        System.debug('agX entries=' + entries);
        return JSON.serialize(entries);
    }

    protected virtual Account loadAccount(final String customerId) {
        return [select Id, CIF__pc, Name,
                    PersonMailingCity, PersonMailingCountry,
                    PersonMailingPostalCode, PersonMailingState, PersonMailingStreet
                from Account where CIF__pc = :customerId limit 1];
    }
    
    //#CH04 : add caseId param
    @auraEnabled
    Public static String sendEmailWithPdf(String IBAN, String startDate, String accountCurrency,String accountId,String conEmail,String conName,String caseId ){
        String responseMessage;
        PageReference pdf=Page.Bankaccount;
        pdf.getParameters().put('iBAN', IBAN);
        pdf.getParameters().put('startDate', startDate);
        pdf.getParameters().put('accountCurrency', accountCurrency);
        pdf.getParameters().put('accId', accountId);
        //#CH04
        pdf.getParameters().put('caseId', caseId);

        Blob b;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
        }
        else{
                b = pdf.getContentAsPDF();
            }

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setContentType('application/pdf');
        efa.setFileName('BankAcccount.pdf');
        efa.setBody(b);

        //#CH03 start: query the current subscriptionModel on the current account
        EmailTemplate et;
        Account accRecord = [SELECT Id,Subscription_Model__pc,region_flag__pc FROM Account WHERE Id = :accountId ];
        Case csRecord = [SELECT Id,case_Model__c FROM Case WHERE Id = :caseId];
        if(csRecord != null && accRecord.region_flag__pc=='Bahrain' && csRecord.case_Model__c == 'alburaq'){
            et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='IBanAccountdetailsAlburaq'];
        }else if(accRecord!= null && accRecord.region_flag__pc=='Bahrain'){
            et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='IBanAccountdetails'];
        }else{
             et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='IBanAccountdetailsJO'];
        }
        //#CH03 End

        OrgWideEmailAddress owe;
         if(accRecord != null && accRecord.region_flag__pc=='Bahrain' && csRecord.case_Model__c == 'alburaq'){
             owe= [select Id from OrgWideEmailAddress where Address = 'support.alburaq@ilabank.com'];   
         }else if(accRecord!= null && accRecord.region_flag__pc=='Bahrain'){
             owe= [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
         }else{
             owe= [select Id from OrgWideEmailAddress where Address = 'support@ilajordan.com'];
         }
        contact cd = [SELECT Id,Name,Email FROM contact WHERE Email =:conEmail];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{conEmail} );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('resultEmail'+result);
            if(result[0].isSuccess()){
                 responseMessage='Success';
            }else{
                 responseMessage='Email Not sent successfully';
            }

        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
        }
        return responseMessage;
    }
   
    @auraEnabled
    Public static string updateCaseStatus(String recId){
        String response;
        try
        {
            case cs=[Select id,Status from case where Id=:recId];
            cs.Status='Closed';
            update cs;
            response='Success';
        }
        catch(system.Exception e){
            response='Error:' +e.getMessage();
        }
        return response;
    }
     //CH07: Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response downloadIBAN(final String customerId, final String accountId,String regionName){
        //String regionName = 'Bahrain';
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements/iban/letter', customerId,regionName);
        req.setBody('{"accountId": "'+accountId+'"}');
        req.setTimeout(120000); 
        system.debug('---> REQUEST IN IBAN DOWNLOAD  --> '+req.getBody());
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('---> RESPONSE IN IBAN DOWNLOAD --> '+response);
        return response;
    }
     //CH07: END

    /**
     *  @author: Aniss Mbarki 
     *  @date: 2022-06-21 
     *  @description:
     *      to handle the visibilty of some options in aura components related to bank Accounts Actions
     *  Version History :
     *
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, String> visibilityOptionsCheck(Id caseId){//#CH02
        Map<String, String> responseData = new Map<String, String>();
        
        Case caseRecord = [SELECT Status FROM Case WHERE Id = :caseId];
        responseData.put('Status',caseRecord.Status);
        
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        responseData.put('Profile',profileNameUserInfo);

        return responseData;
    }
    
       /**
     *  @author: Jayanth Manickam 
     *  @date: 2023-10-17 
     *  @description:
     *      retirve the last transaction of the account
     *  Version History :
     *
     */
    
     @AuraEnabled(cacheable=false)
     public static ApiConnection.Response loadAccountLastTransaction(final String customerId, /*final String accountId*/final String searchParametersJson, String regionName) {
      //System.debug('customerId==> '+ customerId +'  '+'accountId==> '+ accountId+'  '+'regionName==> '+ regionName);
     
      //Commented by Imane Tsioucha
      // final String path = '/api/v1/transactions-enrichment/last?';
      // final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
      // req.setBody('{"id": "'+accountId+'"}');
     // req.setHeader('Accept','*/*');

     final String path = '/api/v1/transactions?';
     final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
     //req.setTimeout(30000);
     req.setTimeout(120000);
     req.setBody(searchParametersJson);
     //#CH08 : start  - adding x-canary //PI-4798
     List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
     if(accs!= null && accs.size()>0){
     System.debug('x-canary added :'+accs.get(0).x_canary__pc);
      if(accs.get(0).x_canary__pc != null){
          req.setHeader('x-canary', accs.get(0).x_canary__pc);
      }
     }
     //#CH08 : end
     
     System.debug('Request Body:'+req.getBody());
     System.debug('Request endpoint:'+req.getEndpoint());

      final ApiConnection.Response response = con.makeCallout(req);
      System.debug(JSON.serializePretty(response));
      if (response.isSuccess && null != response.responseData) {
          final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
          if (SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
              SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
          }
      }
      return response;
  }
   //CH09: Start
    @AuraEnabled
    public static String createAuditRecordForBankAcctDetails(String accCIF, String accIBAN){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('IBAN Number:'+accIBAN);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Bank Account Detail';
        cusAudit.Account_IBAN_Number__c = accIBAN;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH09: END

    // CH10: Start
    @AuraEnabled(cacheable=false)
    public static String sendEmailWithIBANCertificatePdf(String conEmail, String file, String accountId, String caseId){
        System.debug('Apex Class');
        String responseMessage;
        Blob b;
        b = Blob.valueOf(file);
        Blob myBlob = EncodingUtil.base64Decode(file);

        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setContentType('application/pdf');
        efa.setFileName('Bank Acccount.pdf');
        efa.setBody(myBlob);

        //#CH03 start: query the current subscriptionModel on the current account
        EmailTemplate et;
        Account accRecord = [SELECT Id,Subscription_Model__pc,region_flag__pc FROM Account WHERE Id = :accountId ];
        Case csRecord = [SELECT Id,case_Model__c FROM Case WHERE Id = :caseId];
        if(csRecord != null && accRecord.region_flag__pc=='Bahrain' && csRecord.case_Model__c == 'alburaq'){
            et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='IBanAccountdetailsAlburaq'];
        }else if(accRecord!= null && accRecord.region_flag__pc=='Bahrain'){
            et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='IBanAccountdetails'];
        }else{
             et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='IBanAccountdetailsJO'];
        }
        //#CH03 End

        OrgWideEmailAddress owe;
         if(accRecord != null && accRecord.region_flag__pc=='Bahrain' && csRecord.case_Model__c == 'alburaq'){
             owe= [select Id from OrgWideEmailAddress where Address = 'support.alburaq@ilabank.com'];   
         }else if(accRecord!= null && accRecord.region_flag__pc=='Bahrain'){
             owe= [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
         }else{
             owe= [select Id from OrgWideEmailAddress where Address = 'support@ilajordan.com'];
         }
        contact cd = [SELECT Id,Name,Email FROM contact WHERE Email =:conEmail LIMIT 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{conEmail} );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('resultEmail'+result);
            if(result[0].isSuccess()){
                 responseMessage='Success';
            }else{
                 responseMessage='Email Not sent successfully';
            }

        }
        catch(System.Exception e){
            responseMessage='Error:'+e.getMessage();
        }
        return responseMessage;
    }
    // CH10: End
    @AuraEnabled(cacheable=false)
    public static String downloadAccountTransactionExcel(final String customerId,final String searchParametersJson, String regionName) {
    
        try {
            String response = '';
            PageReference accountTransactionExcelPage = Page.AccountTransactionExcel;
            accountTransactionExcelPage.getParameters().put('cifno', customerId);
            accountTransactionExcelPage.getParameters().put('filter', searchParametersJson);
            accountTransactionExcelPage.getParameters().put('region', regionName);
            
            Blob blobData = accountTransactionExcelPage.getContent();
            response = EncodingUtil.base64Encode(blobData);
            return response;
        }
        catch(Exception ex){
            return 'Error : ' + ex.getMessage();
        }
    }
}