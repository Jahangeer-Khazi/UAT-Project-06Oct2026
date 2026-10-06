/**
*  @author: Andrey Gavrikov (westbrook)
*  @date: 2019-02-xx
*  @description:
*      controller for Aura actions in following components:
*      - bankInformation
*      - personalDetails
*
*  Version History :
*              CH02 : Added Alburaq logic by Hamza Chaoui 24-06-2022
*              CH03 : Added by Mbarki Aniss add FirstName & LastName on soql query 21-06-2022
*              CH04 : Added by Mbarki Aniss add Type Field on soql query 16-08-2022
*              CH05 : Added #Jahangeer Mohammed# #15-01-2023# Sub Type field in the SOQL Query
*              CH06 : Added #Jahangeer Mohammed# #29-05-2023# loadDebitCardList Method
*              CH07 : Added #Jahangeer Mohammed# #26-12-2023# loadCreditCardPurgeList Method
*              CH08 : Added #Jahangeer Mohammed# #20-02-2024# Added a filter option value(PI-3089)
*              CH09 : #Imane Tsioucha# #22-02-2024# add x-canary header
*/
public with sharing virtual class BankInformationController {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    
    @TestVisible
    private static BankInformationController DAO = new BankInformationController();
    
    @AuraEnabled(cacheable=true)
    public static ApiConnection.Response loadRecord(final Id recordId) {
        
        ApiConnection.Response response = new ApiConnection.Response();
        if ( Account.sObjectType == recordId.getSobjectType()) {
            response.isSuccess = true;
            response.responseData = DAO.loadAccount(recordId);
        } else if ( Case.sObjectType == recordId.getSobjectType()) {
            response.isSuccess = true;
            response.responseData = DAO.loadCase(recordId);
        }
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static ApiConnection.Response loadTabsConfig() {
        
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = Bank_Information_Tabs__c.getInstance();
        return response;
    }
    
    @AuraEnabled(cacheable=true)
    public static ApiConnection.Response sendVerificationRequest(final Id caseId, final String customerId, final String requestBody,
                                                                 final String systemActionName,  final String email, String regionName) 
    {
        final String path = '/api/v1/verifications/code';
        //SP: 28-Jan-2020: updated request to add header and body
        Set<Id> caseIds= new Set<Id>();
        System.debug('>>>>>>>email: ' + email);
        System.debug('>>>>>>>customerId: ' + customerId);
        
        
        final HttpRequest req = con.createRequest('POST', path, customerId, email, regionName);
        
        req.setBody(requestBody);
        
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, systemActionName);
        
        final ApiConnection.Response response = con.makeCallout(req, action);
        System.debug(JSON.serializePretty(response));
        // return response;
        if (response.isSuccess ) 
        {
         caseIds.add(caseId);
         closeCase(caseIds);
        }

        return response;
    }
    //Swapna -05062022- added the logic to close the case upon success response from API
    @future(callout=true)
    public static void closeCase(Set<Id> setCaseId)
    {
        List<Case> lstCaseUpdate = new List<Case>();
        List<Case> lstCase = [Select id, status, Type, Account.PersonEmail, Account.CIF__pc,Customer_CIF__c, Jamiyah_Id__c, Region_Flag__c from Case where id in: setCaseId];
        for(Case caseObj : lstCase)
        {
            caseObj.Status = 'Closed';
            lstCaseUpdate.add(caseObj);
        }
        if(lstCaseUpdate.size()>0)
            update lstCaseUpdate;
    }
    protected virtual Account loadAccount(final Id recordId) {
        //Added Segment Field in SOQL by Jahangeer Mohammed
        //#CH02 : Added Subscription_Model__pc & Alburaq_Segment__pc Fields in SOQL by Hamza Chaoui
        //CH03 : Added by Mbarki Aniss add FirstName & LastName on soql query
        //22/05/2023 add : PLA_Eligibility__pc,PLA_Ineligibility_Reason__pc
        return [select Id, CIF__pc, Name, PersonEmail, PersonMobilePhone, RecordTypeId, RecordType.Name, FATCA_Customer__pc , Mobile_Country_Code__pc,
                Segment__pc, Region_Flag__c,FirstName,LastName ,Subscription_Model__pc,Alburaq_Segment__pc,PLA_Eligibility__pc,PLA_Ineligibility_Reason__pc,x_canary__pc, Region_Flag__pc from Account where Id = :recordId limit 1];
    }
    protected virtual Case loadCase(final Id recordId) {
        //#CH02 : Added Subscription_Model__pc & Alburaq_Segment__pc Field in SOQL by Hamza Chaoui
        //CH03 : Added by Mbarki Aniss add FirstName & LastName on soql query
        //CH04 : Add Type field on soql query
        //CH05 : Added Sub type & Status field on the soql query
        return [select Id, RecordType.DeveloperName,Case_Model__c,
                Account.Id, Account.Name,  Account.Region_Flag__c, Account.CIF__pc, Account.PersonEmail,Account.x_canary__pc, Account.Mobile_Country_Code__pc,
                Account.PersonMobilePhone, Account.RecordTypeId, Account.RecordType.Name, Account.FATCA_Customer__pc,
                Account.Segment__pc,Account.FirstName,Account.LastName, Account.Subscription_Model__pc,Account.Alburaq_Segment__pc,Type,Sub_Type__c,Status,Account.Region_Flag__pc from Case where Id = :recordId limit 1];
    }
    @AuraEnabled
    public static ApiConnection.Response cardStatusFilter(Id recordId, String option){
        system.debug(recordId.getSobjectType()+' ||recordId||'+recordId+'||option||'+option);
        Case caseItem;
        Account accountItem;
        String customerId;
        if ( Account.sObjectType == recordId.getSobjectType()) {
            accountItem = DAO.loadAccount(recordId);
            
        } else if ( Case.sObjectType == recordId.getSobjectType()) {
            
            caseItem = DAO.loadCase(recordId);
        }
        if(accountItem != NULL){
            customerId = accountItem.CIF__pc;
        }else if (caseItem != NULL){
            customerId = caseItem.Account.CIF__pc;
        }
        
        final HttpRequest req;
        if ( Account.sObjectType == recordId.getSobjectType()) {
            req = con.createRequest('GET', '/api/v1/credit-cards', customerId, accountItem.Region_Flag__c);
            if(accountItem.x_canary__pc != null){
            req.setHeader('x-canary', accountItem.x_canary__pc); //CH09
            }
        }else{

            req = con.createRequest('GET', '/api/v1/credit-cards',customerId, caseItem.account.Region_Flag__pc);
            if(caseItem.Account.x_canary__pc != null){
            req.setHeader('x-canary', caseItem.Account.x_canary__pc); //CH09
            }
        }
        
        // Commented by Jahangeer Mohammed on 29-08-2021
        //req.setHeader('filterOption',option);
        
        //CH01 Added by Jahangeer Mohammed 29-08-2021 for Append Filter Option in the URL
        String endPoint = req.getEndpoint();
        System.debug('End Point URL:'+endPoint);
        req.setEndpoint(endPoint + '&filterOption='+option);
        System.debug('Final End Point URL:'+ req.getEndpoint());
        //CH01 END
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('JSON Pretty Response:'+JSON.serializePretty(response));
        system.debug('---> JSON Formatted RESPONSE --> '+response);
        return response;
    }
    //CH07: Start
     @AuraEnabled
    public static ApiConnection.Response loadCreditCardPurgeList(Id recordId, String option){
        system.debug(recordId.getSobjectType()+' ||recordId||'+recordId+'||option||'+option);
        Case caseItem;
        Account accountItem;
        String customerId;
        
        if(Account.sObjectType == recordId.getSobjectType()) {
            accountItem = DAO.loadAccount(recordId);
        }
        else if(Case.sObjectType == recordId.getSobjectType()) {
            caseItem = DAO.loadCase(recordId);
        }
        if(accountItem != NULL){
            customerId = accountItem.CIF__pc;
        }else if (caseItem != NULL){
            customerId = caseItem.Account.CIF__pc;
        }
        
        final HttpRequest req;
        if (Account.sObjectType == recordId.getSobjectType()) {
            req = con.createRequest('GET', '/api/v1/cards-archival/credit-cards/archived', customerId, accountItem.Region_Flag__c);
        }else{
            req = con.createRequest('GET', '/api/v1/cards-archival/credit-cards/archived', customerId, caseItem.account.Region_Flag__c);
        }
        req.setTimeOut(60000);
        String endPoint = req.getEndpoint();
        System.debug('End Point URL:'+endPoint);
        
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('JSON Pretty Purge Response:'+JSON.serializePretty(response));
        system.debug('---> JSON Formatted Purge RESPONSE --> '+response);
        return response;
    }
    //CH07: END
     //CH06: Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadDebitCardList(Id recordId, String option) {
        system.debug('Selected Option in Debit Card:'+option);
        Case caseItem;
        Account accountItem;
        String customerId;
        String regionFlag;
        if ( Account.sObjectType == recordId.getSobjectType()) {
            accountItem = DAO.loadAccount(recordId);
        } else if ( Case.sObjectType == recordId.getSobjectType()) {
            caseItem = DAO.loadCase(recordId);
        }

        if(accountItem != NULL){
            customerId = accountItem.CIF__pc;
            regionFlag = accountItem.Region_Flag__c;
        }else if (caseItem != NULL){
            customerId = caseItem.Account.CIF__pc;
            regionFlag = caseItem.account.Region_Flag__c;
        }
        
        final HttpRequest req = con.createRequest('GET', '/api/v1/cards', customerId, regionFlag);
        //CH08: Start
        String endp;
        if(option == 'B'){ //Active / Inactive Cards
            endp = req.getEndpoint() + '&filterBlocked=true';
            req.setEndpoint(endp);
        }else if(option == 'A'){ //Blocked / Cancelled
            endp = req.getEndpoint() + '&filterBlocked=false';
            req.setEndpoint(endp);
        }
        //CH08: END
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('Debit Card API Response:'+JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] cards = (Object[])responseData.get('cards');
            final Object[] cleanedCards = cards; //removeSensitiveData(cards);
            responseData.put('cards', cleanedCards);
        }
        
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadDebitCardPurgeList(Id recordId, String option) {
        system.debug('Selected Option in Debit Card:'+option);
        Case caseItem;
        Account accountItem;
        String customerId;
        String regionFlag;
        if ( Account.sObjectType == recordId.getSobjectType()) {
            accountItem = DAO.loadAccount(recordId);
        } else if ( Case.sObjectType == recordId.getSobjectType()) {
            caseItem = DAO.loadCase(recordId);
        }

        if(accountItem != NULL){
            customerId = accountItem.CIF__pc;
            regionFlag = accountItem.Region_Flag__c;
        }else if (caseItem != NULL){
            customerId = caseItem.Account.CIF__pc;
            regionFlag = caseItem.account.Region_Flag__c;
        }
        
        final HttpRequest req = con.createRequest('GET', '/api/v1/cards/archived', customerId, regionFlag);
        
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('Debit Card API Purge Response:'+JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] cards = (Object[])responseData.get('cards');
            final Object[] cleanedCards = cards; //removeSensitiveData(cards);
            responseData.put('cards', cleanedCards);
        }
        
        return response;
    }
    //CH06: END
    
}