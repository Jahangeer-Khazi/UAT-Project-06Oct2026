/**
*  @author: Ashish Pandey
*  @date: 23/01/2010
*  @description: controller for aura components related to Credit cards
*  Change History :
*         #CH01 : Added #Jahangeer Mohammed# #07-11-2021# Logic to get PCI Number from API.
*         #CH02 : Added #Jahangeer Mohammed #25-11-2021# Logic to get EPP List from API.
*         #CH03 : #Jahangeer Mohammed #06-01-2021# Added a condition for Primary Cards.
*         #CH04 : #Jahangeer Mohammed #28-03-2022# Added field to restrict Sensitive Data(NBA-4106)
*         #CH05 : #MBARKI ANISS# #09-08-2022# Prepaid Card related Changes (Add targetType param  & "Reactivate Dormant Card" Logic)
          #CH06 : #D&A Team #24-06-2022# Added alburaq logic.
*         #CH07 : #MBARKI ANISS# #16-08-2022# CRM22-136 :  Differentiate Credit Limit Increase Cases Based on Card Type
*         #CH08 : Added #Jahangeer Mohammed# #07-09-2022# Logic to get PCI Number from API for Cash Collateral Limit Increase Application.
*         #CH09 : Added #Jahangeer Mohammed# #08-11-2022# Logic to Check Card Nature = unsecured and Card Status = Active as per UATNB-51495
*         #CH10 : Added #Jayanth Manickam# #03-12-2022# Logic to get credit card reward details.
*         #CH11 : Added #Jahangeer Mohammed#25-10-2023# Fetching Maker Result for Credit Card Upgrade Enhancements
*         #CH12 : #Imane Tsioucha# #22-02-2024# add x-canary header
*         #CH13# #Jahangeer Mohammed #28-04-2024# Added logic for Audit History Enhancements(NBA-9027)
*         #CH14# #Aniss Mbarki #04-06-2024# Added logic for FIxed deposit
*         #CH15# #Jahangeer Mohammed# #23-10-2024# Added Region Name Logic for Fixed Deposits
          #CH16# #Jahangeer Mohammed# #08-12-2024# Added Logic for Co-Brand Credit Cards
*         #CH17# #Jahangeer Mohammed# #02-02-2025# Added Logic for API Failures(NBA-13083)
*         #CH18# #Maksud Ali# #27-03-2025# Added Logic for Downloading/Send Email Cash Collateral Letter.
*         #CH19# #Jahangeer Mohammed# #03-07-2025# Added Logic for Convert Credit Card Application(NBA-13871)
          #CH20# #Jahangeer Mohammed# #19-08-2025# Added Masked Card Number(NBA-15639)
          #CH21# #Jahangeer Mohammed# #09-10-2025# Added Logic for Credit Card Spouse(NBA-15728)
          #CH22# #Jahangeer Mohammed #11-11-2025# Added Logic for World Elite Entitlement Process (NBA-15929)
          #CH23# #Jahangeer Mohammed #17-02-2026# Added Logic for hiding Sensitive fields (PI-4660)
          #CH24# #Jahangeer Mohammed #05-04-2026# Added Logic for Jordan Balance Transfer Process(NBA-15608)

*/

public without sharing virtual class JoCreditCardApplicationController  {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();
    private static final String  CREDIT_BUSINESS_TEAM_QUEUE = 'Credit Business Team';

    @TestVisible // overwrite instance to provide custom DAO in test class
    private static JoCreditCardApplicationController  DAO = new JoCreditCardApplicationController ();

    // added by Shashank to filter the Sensitive Data
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_LIST = new List<String>{
            'currency',
            'creditLimit',
            'availableCreditLimit',
            'holdAmount',
            'lastPaymentAmount',
            'availableCashLimit',
            'lastStatementBalance',
            'unbilledAmount',
            'cashLimit',
            'minimumDues',
            'totalDues',
            'pastDues',
            'pointsBalance'
    };
    private final static List<String> SENSITIVE_FIELDS_ACCOUNT_DETAILS = new List<String>{
            'currency',
            'creditLimit',
            'availableCreditLimit',
            'holdAmount',
            'lastPaymentAmount',
            'availableCashLimit',
            'lastStatementBalance',
            'unbilledAmount',
            'cashLimit',
            'minimumDues',
            'totalDues',
            'pastDues',
            'pointsBalance',
            //CH04: Start
            'accountBlockCode1',
            'accountBlockDate1',
            'accountBlockCode2',
            'accountBlockDate2',
            'usedCreditLimit',
            //CH04: END
            //CH23: Start
            'retailPlanBalance','cashPlanBalance','balanceTransferPlanBalance','lastStatementWithDueEpp','totalFutureEPP','currentBalance','memoCredit','lastStatmentBalance','unpaidTransactionsBalance',
            'feePlanBalance','eppPlanBalance','paymentSinceLastStatements','outstandingBalance','totalDueEPP','memoDebit','outstandingBalance','recentCreditsAmount' ,'futureEPP',
            'minimumDues','totalDueEPP','minimumDuesExcludingEPP','paymentLastStatementBalanceNew','paymentOutstandingBalance','usedCreditLimit','recentCreditsAmount','lastStatementRecentPayments'
            //CH23: END
            };
                
     //CH02: Start
     private final static List<String> SENSITIVE_FIELDS_EPP_List = new List<String>{
           'tenor',
           'transactionAmount',
           'numberOfInstallmentsPaid',
           'numberOfInstallmentsRemaining',
           'installmentAmount',
           'remainingBalance'
     };
     //CH02: END   

    @AuraEnabled(cacheable=false)
    //changed by SP
    //Add param personEmail to the method
    //public static ApiConnection.Response loadCardList(final String customerId) {
    public static ApiConnection.Response loadCardList(final String customerId, final String personEmail, String regionName) {
        Account accObj = [SELECT Id,x_canary__pc, Region_Flag__c FROM Account WHERE CIF__pc=: customerId];//CH12

        final HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards', customerId, personEmail, regionName);
     
       // req.('20000');
        if(accObj.x_canary__pc != null ){
            req.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        //req.setHeader('setTimeOut','120000');
        req.setTimeout(120000);
        System.debug('----->> REQUEST -->> '+req.getBody());
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug('----->> RESPONSE loadCardList -->> '+JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            System.debug('----->> RESPONSE DATA -->> '+responseData);
            final Object[] cards = (Object[])responseData.get('cards');
            final Object[] cleanedCards = cards; //removeSensitiveData(cards);
            responseData.put('cards', cleanedCards);
        }else{
            System_Action__c logObject = new System_Action__c();
            logObject.Account__c = [SELECT Id FROM ACCOUNT WHERE CIF__pc =:customerId].Id;
            logObject.Action__c = 'Credit Card Application';
            logObject.Endpoint__c ='/api/v1/credit-cards';
            logObject.Method__c='GET';
            logObject.Response_Body__c=JSON.serializePretty(response.errorData);

            insert logObject;


        }
        return response;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadCardDetails(final String customerId, final String cardId, final String personEmail, String regionName) {
        Account accObj = [SELECT Id,x_canary__pc, Region_Flag__c FROM Account WHERE CIF__pc=: customerId];//CH12

        final HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards/'+cardId+'/details', customerId, personEmail, regionName);
        if(accObj.x_canary__pc != null){
            req.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        req.setTimeout(120000);
        //req.setBody('{ "pciNumber":"'+cardId+'" }');

        system.debug('---> REQUEST --> '+req);
        final ApiConnection.Response response = con.makeCallout(req);
        system.debug('---> RESPONSE --> '+JSON.serializePretty(response));
        //system.debug('---> JSON Formatted RESPONSE --> '+JSON.stringify(response));
        //added by shashank
        if (response.isSuccess && null != response.responseData ||(test.isRunningTest())) {

            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            if (CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                system.debug('SENSITIVE_FIELDS_ACCOUNT_DETAILS||'+SENSITIVE_FIELDS_ACCOUNT_DETAILS);
                CreditCard_SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
            }
            
            for(String k : responseData.keyset()){
                system.debug('---> RESPONSEMX --> ' + k + ' = ' + responseData.get(k));    
            }
        }
        
        
        
        return response;
    }
    
    //CH02 : Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadEPPList(final String customerId,final String pciNumber,final String regionName){
        //String regionName = 'Bahrain';
        system.debug('CreditCArdEPPDetailsController ||EPP List ||LINE:666 ||'+pciNumber);
        final HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards/'+pciNumber+'/epp', customerId,regionName);
        system.debug('---> REQUEST --> '+req);
        //system.debug('---> REQUEST Body --> '+req.getBody());
        ApiConnection.Response response = new ApiConnection.Response();
        response = con.makeCallout(req);
        System.debug('Response in Apex class:' +JSON.serializePretty(response));
         if(response.isSuccess && null != response.responseData){
             final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
             final Object[] eppLst = (Object[])responseData.get('eppList');
            if(CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)){
                system.debug('SENSITIVE_FIELDS_EPP||'+SENSITIVE_FIELDS_EPP_List);
                CreditCard_SensitiveDataCleaner.removeSensitiveData(eppLst, SENSITIVE_FIELDS_EPP_List); 
            }
             else{
                 System.debug('Sensitive Data Class returning false value');
             }
        }
        return response; 
    }
    //CH02 : END

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response blockCard(final String customerId, final String blockCardData,
                                                   final Id caseId, final String personEmail, String regionName) {

        final Map<String, Object> blockCardDataMap = (Map<String, Object>)JSON.deserializeUntyped(blockCardData);
        final String cardId = (String)blockCardDataMap.get('cardId');
        final String actionType = (String)blockCardDataMap.get('actionType');
        final Map<String, String> requestObject = new Map<String, String>{
           'customerId' => customerId,
               'id' => cardId,
               'reason' => (String)blockCardDataMap.get('reason')
               };
                   final String requestText = JSON.serialize(requestObject);

        // JT Changed the End point from cards/' + cardId + '/block' to cards/block since change to API definition
        final HttpRequest req = con.createRequest('PUT', '/api/v1/cards/block', customerId, personEmail, regionName);
        req.setBody(requestText);

        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = (String)blockCardDataMap.get('maskedCardNumber');

        final ApiConnection.Response response = con.makeCallout(req, action);
        if (!response.isSuccess && null != response.errorData) {
           // check if this is 20020: Card is already blocked.
           // in this case we report this as a successful response
           if(!test.isRunningTest()){
               final Map<String, Object> errData = (Map<String, Object>)response.errorData;
               response.isSuccess = 20020 == errData.get('code');
           }
        }

        return response;
                                                   }

    /**
* @param extraParameters:
*  ex: "{ systemActionType: '...', caseType: '...' , caseSubType: '...', isCaseClosureRequired: true}"
*/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response requestNewCard(final String customerId, final String requestTextJson,
                                                        final String maskedCardNumber,
                                                        final Id caseId,
                                                        final String extraParameters,
                                                        final String personEmail, String regionName) {

        System.assert(String.isNotBlank(extraParameters), 'requestNewCard: parameter "extraParameters" must be provided');

        final HttpRequest req = con.createRequest('POST', '/api/v1/cards/issuance', customerId, personEmail, regionName);
        req.setBody(requestTextJson);

        final Map<String, Object> extraParametersMap = (Map<String, Object>)JSON.deserializeUntyped(extraParameters);
        final String systemActionType = (String)extraParametersMap.get('systemActionType');
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, systemActionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = maskedCardNumber;
        ApiConnection.Response response ;
        if(!test.isRunningTest()){


            response = con.makeCallout(req, action);
            final Boolean isCaseClosureRequired = true == extraParametersMap.get('isCaseClosureRequired');
            if (isCaseClosureRequired && response.isSuccess) {
                final String caseType = (String)extraParametersMap.get('caseType');
                final String caseSubType = (String)extraParametersMap.get('caseSubType');


                response = closeCase(caseId, caseType, caseSubType);
            }
        }
        return response;
        }
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response changeCardStatus(final String customerId, final String parameterData, final Id caseId, final String personEmail, String regionName) {

        final Map<String, Object> parameterDataMap = (Map<String, Object>)JSON.deserializeUntyped(parameterData);
        final String cardId = (String)parameterDataMap.get('cardId');
        final String actionType = (String)parameterDataMap.get('actionType');
        final String status = (String)parameterDataMap.get('cardStatus');

        final Map<String, String> requestObject = new Map<String, String>{
            'id' => cardId,
                'status' => status
                };
                    final String requestText = JSON.serialize(requestObject);

        final HttpRequest req = con.createRequest('PUT', '/api/v1/cards/status', customerId, personEmail, regionName);
        req.setBody(requestText);

        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = (String)parameterDataMap.get('maskedCardNumber');
        ApiConnection.Response response;
        if(!test.isRunningTest()){


            response = con.makeCallout(req, action);
            final Boolean isCaseClosureRequired = true == parameterDataMap.get('isCaseClosureRequired');
            if (isCaseClosureRequired && response.isSuccess) {
                final String caseType = (String)parameterDataMap.get('caseType');
                final String caseSubType = (String)parameterDataMap.get('caseSubType');

                response = closeCase(caseId, caseType, caseSubType);
            }
        }
        return response;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response changeCardAccountAssociation(final String customerId, final String parameterData,
                                                                      final Id caseId, final String personEmail, String regionName) {

        final Map<String, Object> parameterDataMap = (Map<String, Object>)JSON.deserializeUntyped(parameterData);
        final String cardId = (String)parameterDataMap.get('cardId');
        final String actionType = (String)parameterDataMap.get('actionType');
        final String accountId = (String)parameterDataMap.get('accountId');

        final Map<String, String> requestObject = new Map<String, String>{
          'id' => cardId,
              'accountId' => accountId,
              'action' => (String)parameterDataMap.get('action'),
              'customerId' => customerId
              };
                  final String requestText = JSON.serialize(requestObject);

        final HttpRequest req = con.createRequest('PUT', '/api/v1/cards/accounts/association', customerId, personEmail, regionName);
        req.setBody(requestText);

        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = (String)parameterDataMap.get('maskedCardNumber');
        ApiConnection.Response response;
        if(!test.isRunningTest()){
          response = con.makeCallout(req, action);
          final Boolean isCaseClosureRequired = true == parameterDataMap.get('isCaseClosureRequired');
          if (isCaseClosureRequired && response.isSuccess) {
              final String caseType = (String)parameterDataMap.get('caseType');
              final String caseSubType = (String)parameterDataMap.get('caseSubType');

              response = closeCase(caseId, caseType, caseSubType);
          }
        }
        return response;
                                                                      }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountList(final String customerId, String regionName) {
        return BankAccountController.loadAccountList(customerId, regionName);
    }

    private static ApiConnection.Response closeCase(final Id caseId, final String caseType, final String caseSubType ) {
        final Case caseRec = new Case(Id = caseId, Status = 'Closed');
        if (null != caseType) {
            caseRec.Type = caseType;
        }
        if (null != caseSubType) {
            caseRec.Sub_Type__c = caseSubType;
        }
        final List<String> errors = DAO.updateRecords(new List<SObject>{caseRec});
        final ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = errors.isEmpty();
        response.errorData = errors;
        return response;
    }

    protected virtual List<String> updateRecords(final List<SObject> recs) {
        final List<String> errors = new List<String>();
        system.debug('>>>>>>>>>>>>>recs:' + recs);
        for(Database.SaveResult res : Database.update(recs, /*all_or_none=*/false)) {
            if (!res.isSuccess()) {
                errors.add(res.getErrors()[0].getMessage());
            }
        }
        return errors;
    }

    @AuraEnabled(cacheable=false)
    public static Case getCaseSubType(final ID caseIdapex) {
        Case caseObj = [select id, Sub_Type__c,Status,Type from case where id =: caseIdapex limit 1];
        return caseObj;
    }
    // added by shashank @ 03/March/2021
    /**
* Method to get the transaction data from response API
* @param customerId   Customer CIF
* @param searchParametersJson paramanets from components
* @return list object with transaction data
*/
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountTransactions(final String customerId,final String searchParametersJson, String regionName){
        
        system.debug('CreditCArdListController ||loadAccountTransactions ||LINE:246 ||'+searchParametersJson);
        Account accObj = [SELECT Id,x_canary__pc, Region_Flag__c FROM Account WHERE CIF__pc=: customerId];//CH12

        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = new List<Object>();

        final String path = '/api/v1/credit-cards/transactions?';
        
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        if(accObj.x_canary__pc != null){
            req.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        req.setBody(searchParametersJson);
        system.debug('LINE 308'+searchParametersJson);
        if(!test.isRunningTest()){
            response = con.makeCallout(req);
            System.debug('creditCardListController ||loadAccountTransactions ||LINE:310 ||' + JSON.serializePretty(response));

            Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            //system.debug('responseData|| LINE 313'+responseData.size());
            System.debug('Response data keys:'+responseData.keySet());
            if(responseData != null){
                Object[] transactions = (Object[])responseData.get('transactions');
                System.debug('transactions:'+transactions);

                //if there are requried clean data, it means segment is staff and view staff = false
                //we will filter staff transaction from it
                System.debug('isSuccess:'+response.isSuccess);
                System.debug('responseData:'+response.responseData);
                
                System.debug('check logic:'+(response.isSuccess && null != response.responseData));
                if (response.isSuccess && null != response.responseData){

                    System.debug('transactions.size:'+transactions.size());
                    response.recordLength = transactions.size();
                    //if view staff = true, we will display all transactions
                    if(CreditCard_SensitiveDataCleaner.isAllowedViewStaffData(customerId)){
                        System.debug('Entered one:');
                        response.responseData = transactions;
                    }
                    //if view staff = false, we will display only transaction during Segment != staff
                    else{
                        System.debug('Entered two:');
                        List<Map<String, Datetime>> lstBanedDate = CreditCard_SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                        response.responseData = CreditCard_SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, transactions);
                    }
                }
            }
        }
        system.debug('response after filter||'+response);
        return response;
    }
    @AuraEnabled(cacheable=false)
    public static String caseType(String caseId){
        String result;
        if(caseId.startsWith('500')){
            Case newObj = [SELECT Id,RecordType.Name FROM Case WHERE Id=:caseId LIMIT 1];
            result = newObj.RecordType.Name;
        }else {
            result = 'Not_Case';
        }
        return result;
    }
    //CH11: Start
    @AuraEnabled(cacheable=false)
    public static String fetchMakerResult(String caseId){
        String result;
        if(caseId.startsWith('500')){
            Case caseObj = [SELECT Id,cc_Maker__c FROM Case WHERE Id=:caseId LIMIT 1];
            System.debug('Maker Result:'+caseObj.cc_Maker__c);
            result = caseObj.cc_Maker__c;
        }else {
            result = 'Not_Case';
        }
        return result;
    }
    //CH11: END
    @AuraEnabled(cacheable=false)
    public static Map<String,String> getCardOptions(String accID, String caseModel){
        Map<String,String> retriveCardOption =  new Map<String,String>();
        Map<String,String> retrivePCIOption = new Map<String,String>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID]; //CH12
        Http http = new Http();
        HttpRequest request = new HttpRequest();

         //#CH06 Start
         String regionName = accObj.Region_Flag__c;
         if(caseModel == 'alburaq'){
             regionName += '_alburaq';
         }
         request =  con.createRequest('GET','/api/v1/credit-cards?', regionName); 
         //#CH06 End
        

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        request.setTimeout(120000);
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        system.debug('---> Responce New --> '+response.getBody());
           system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response.getBody()));
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //CH17: Added isAPIFailed parameter in the method
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);

        }
        else
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards');
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                if(mapRelatedCurrentCards.containsKey('id')){
                    retrivePCIOption.put((String)mapRelatedCurrentCards.get('maskedCardNumber'),(String)mapRelatedCurrentCards.get('id'));
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
            
            List<Object> m2 = (List<Object>)m1.get('cardOptions');
            System.debug('---> LIST m2 --> '+m2);

            List<Map<String, Object>> a = new List<Map<String, Object>> ();

            for(Object obj : m2)
            {
                a.add((Map<String, Object>)obj);
                {
                    system.debug('---->> OBJ Iterations --> '+obj);
                }
            }
            system.debug('---->> FINALL aaaa --> '+a);

            for(Map<String, Object> map1 : a)
            {
                if(map1.containsKey('productMappingCode'))
                {
                    retriveCardOption.put((String)map1.get('cardDisplayName'),(String)map1.get('productMappingCode'));

                }
            }
            system.debug('retriveCardOption||'+retriveCardOption);
        }
        return retriveCardOption;
    }
    //CH24: Start
     @AuraEnabled(cacheable=false)
    public static Map<String,Object> getCardConfigurations(String accID, String caseModel){
        Map<String,Object> retriveCardOption =  new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID]; //CH12
        Http http = new Http();
        HttpRequest request = new HttpRequest();

         //#CH06 Start
         String regionName = accObj.Region_Flag__c;
         if(caseModel == 'alburaq'){
             regionName += '_alburaq';
         }
         request =  con.createRequest('GET','/api/v1/credit-cards?includeOtherProducts=true', regionName); 
         //#CH06 End
        

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        request.setTimeout(120000);
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        system.debug('---> Responce New --> '+response.getBody());
           system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response.getBody()));
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //CH17: Added isAPIFailed parameter in the method
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);

        }
        else
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> m2 = (List<Object>)m1.get('cardOptions');
            System.debug('---> LIST m2 --> '+m2);

            List<Map<String, Object>> a = new List<Map<String, Object>> ();

            for(Object obj : m2)
            {
                a.add((Map<String, Object>)obj);
                {
                    system.debug('---->> OBJ Iterations --> '+obj);
                }
            }
            system.debug('---->> FINALL aaaa --> '+a);

            for(Map<String, Object> map1 : a)
            {
                if(map1.containsKey('productMappingCode'))
                {
                    retriveCardOption.put((String)map1.get('productMappingCode'),map1);

                }
            }
            system.debug('retriveCardOption||'+retriveCardOption);
            system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(retriveCardOption));
        }
        return retriveCardOption;
    }
    @AuraEnabled(cacheable=false)
    public static String getAccId(String cseId){
        Case cse = [SELECT Id,AccountId, Region_Flag__c From Case WHERE Id =:cseId];
        return cse.AccountId;
    }
    //CH24: END
    //CH01 : Start Added #Jahangeer Mohammed# #07-11-2021# to get PCI Number of Credit Cards from API
     @AuraEnabled(cacheable=false)
    public static Map<String,String> getPCIOptions(String accID,String caseModel){
        Map<String,String> retrivePCIOption = new Map<String,String>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];

        //#CH06 Start
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         //#CH06 END

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);//CH06

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }

        request.setTimeout(120000);
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        system.debug('---> Responce New --> '+response.getBody());
             //system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response));
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //CH17: Added isAPIFailed parameter in the method
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);

        }
        else
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
            //CH03 : #Jahangeer Mohammed# #06-01-2022# Added a condition for Primary Cards
                if(mapRelatedCurrentCards.containsKey('id') && mapRelatedCurrentCards.get('isPrimary') == true){
                    retrivePCIOption.put((String)mapRelatedCurrentCards.get('maskedCardNumber'),(String)mapRelatedCurrentCards.get('id'));
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
        }
        return retrivePCIOption;
    }
    //CH01 : END
    //CH08 : Start
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getPCIOptionsCashCollateralLimitIncrease(String accID,String caseModel){
        Map<String,Object> retrivePCIOption = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];//CH12
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        request.setTimeout(120000);

        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        system.debug('---> Responce New --> '+response.getBody());
       system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response.getBody()));
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //CH17: Added isAPIFailed parameter in the method
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);

        }
        else
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                System.debug('Current Cards in Cash Collateral:'+mapRelatedCurrentCards);
                System.debug('Current Cards in Cash Collateral is having Id:'+mapRelatedCurrentCards.containsKey('id'));
                System.debug('Current Cards in Cash Collateral is a Primary Card:'+mapRelatedCurrentCards.get('isPrimary'));
                System.debug('Current Cards in Cash Collateral is having a card Nature:'+mapRelatedCurrentCards.containsKey('cardNature'));

                if(mapRelatedCurrentCards.containsKey('id') && mapRelatedCurrentCards.get('isPrimary') == true  && mapRelatedCurrentCards.containsKey('cardNature')){
                    String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                    //CH19: Start
                    //String status = (String) mapRelatedCurrentCards.get('status');
                    //CH19: END
                    //System.debug('Card Nature Value:'+cardNature);
                    //System.debug('Status Value:'+status);
                    //CH19: Start
                    if(cardNature == 'secured' /*&& status == 'ACTIVE'*/){
                        retrivePCIOption.put((String)mapRelatedCurrentCards.get('id'),mapRelatedCurrentCards);
                    }
                    //CH19: END
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
            system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(retrivePCIOption));
        }
        return retrivePCIOption;
    }
    //CH08 : END
 
    @AuraEnabled(cacheable=false)
    public static String getDefaultName(String accID){
        String name;
        Account acc = [SELECT Id, PersonContact.FirstName, PersonContact.MiddleName, PersonContact.LastName From Account WHERE Id =:accID];
        String middlename =' ';
        if(acc.PersonContact.MiddleName != NULL){middlename = ' '+acc.PersonContact.MiddleName+' ';}
        return name = acc.PersonContact.FirstName+middlename+acc.PersonContact.LastName;

    }
    
    //CH15: Start
    @AuraEnabled(cacheable=false)
    public static String getRegionName(String accID){
        Account acc = [SELECT Id, Region_Flag__c From Account WHERE Id =:accID];
        return acc.Region_Flag__c;
    }
   //CH15: END

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> creditCardFCRAPI(final String customerId, final String parameterData, final Id caseId, final String personEmail, final String regionName){
        Map<String, Object> ActionFCRResponseMap = new Map<String, Object>();

        String body ='';
        final Map<String, Object> parameterDataMap = (Map<String, Object>)JSON.deserializeUntyped(parameterData);
        final String cardId = (String)parameterDataMap.get('cardId');
        final String actionType = (String)parameterDataMap.get('actionType');
        final String status = (String)parameterDataMap.get('cardStatus');
        final String reason = (String)parameterDataMap.get('reason');
        final Boolean isCaseClose = (Boolean)parameterDataMap.get('isCaseClosureRequired');
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE CIF__pc=: customerId];


        //#CH05 : Start 
        final String targetType = (String)parameterDataMap.get('targetType');
        System.debug('Target Type >>>>>>> '+targetType);
        //#CH05 : End

        HttpRequest request = new HttpRequest();
        //request.setHeader('customerId', customerId);

        if(actionType=='Freeze Card'){
            system.debug('actionType||'+actionType);
            body = '{"pciNumber": "'+cardId + '","status": "FREEZE"}';
            request= con.createRequest('POST', '/api/v1/credit-cards/status?', regionName);
            request.setBody(body);
            ActionFCRResponseMap = initiateManualOnboarding.getFCRresponse(request,isCaseClose,caseId,customerId,actionType);
        }
        else if(actionType=='Unfreeze Card'){
            body = '{"pciNumber": "'+cardId + '","status": "UNFREEZE"}';
            request= con.createRequest('POST', '/api/v1/credit-cards/status?', regionName);
            request.setBody(body);
            ActionFCRResponseMap = initiateManualOnboarding.getFCRresponse(request,isCaseClose,caseId,customerId,actionType);
        }
        else if(actionType=='temporaryBlock'){
            //#CH05 : add targetType Param
            body = '{"pciNumber": "'+cardId + '","reason":"'+reason +'","targetType":"'+targetType+'"}';
            request= con.createRequest('POST', '/api/v1/credit-cards/block/internal?', regionName);
            request.setBody(body);

            ActionFCRResponseMap = initiateManualOnboarding.getFCRresponse(request,isCaseClose,caseId,customerId,actionType);
        }
        else if(actionType=='Unblock'){
            //#CH05 : add targetType Param
            body = '{"pciNumber": "'+cardId + '","reason":"UNBLOCK","targetType":"'+targetType+'"}';
            request= con.createRequest('POST', '/api/v1/credit-cards/block/internal?', regionName);
            request.setBody(body);
            ActionFCRResponseMap = initiateManualOnboarding.getFCRresponse(request,isCaseClose,caseId,customerId,actionType);
        }
        else if(actionType=='Replace Card'){
            //#CH05 : add targetType Param
            body = '{"pciNumber": "'+cardId + '","reason":"'+reason +'","targetType":"'+targetType+'"}';
            request= con.createRequest('POST', '/api/v1/credit-cards/block/internal?', regionName);
            request.setBody(body);
            ActionFCRResponseMap = initiateManualOnboarding.getFCRresponse(request,isCaseClose,caseId,customerId,actionType);
        }
        //#CH05 : Start
        else if(actionType=='ReactivateDormantCard'){
            body = '{"pciNumber": "'+cardId + '","status": "ACTIVATE_DORMANT"}';
            request= con.createRequest('POST', '/api/v1/credit-cards/status?', regionName);
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc); //CH12
            }

            System.debug('ReactivateDormantCard Request Body ===>> '+body);
            request.setBody(body);
            ActionFCRResponseMap = initiateManualOnboarding.getFCRresponse(request,isCaseClose,caseId,customerId,actionType);
        }
        //#CH05 : End
        return ActionFCRResponseMap;
    }

    @auraEnabled
    Public static String sendEmailWithPdf(Id caseId, String IBAN, String startDate, String accountCurrency){
        //#CH06 : add Case_Model__c
        Case cs = [SELECT Id,Status,AccountId,ContactEmail,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,Case_Model__c FROM Case Where ID =:CaseId];
        contact cd = [SELECT Id,Name,Email FROM contact WHERE AccountId =:cs.AccountId];
        String responseMessage;

        PageReference pdf=Page.NoDueCertificate;
        pdf.getParameters().put('iBAN', IBAN);
        pdf.getParameters().put('startDate', startDate);
        pdf.getParameters().put('accountCurrency', accountCurrency);
        pdf.getParameters().put('accId', cs.AccountId);

        Blob b;
        if (Test.IsRunningTest()){
            b=Blob.valueOf('UNIT.TEST');
        }
        else{
            system.debug('CaseId||'+CaseId);
            b = pdf.getContent();
        }
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        system.debug('b'+b);
        efa.setFileName('No_Due_Certificate.pdf');
        efa.setBody(b);

        //#CH06 Start: add alburaq notificatio logic
        EmailTemplate et;
        if( cs.Case_Model__c == 'alburaq' ){
            et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='CC_NoDueCertificateNotification_Alburaq'];
        }else{
            et =  [SELECT Id,Name FROM EmailTemplate WHERE Name ='CC_NoDueCertificateNotification'];
        }
        //#CH06 End

        OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{cd.Email} );
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        system.debug('<------------>');
        try{
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            System.debug('result'+result);
            if(result[0].isSuccess()){
                responseMessage='Success';

                cs.Status = 'Closed';
                //cs.cc_Contact_Centre_Result__c = 'Generated';
                cs.cc_Contact_Centre_Date_Time__c = System.now();
                cs.Sub_Status__c = 'Completed';
                update cs;
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
    Public static String sendToBusinessApproval(Id caseId){
        String responseMessage;
        system.debug('caseId||'+caseId);
        Case cs = [SELECT Id,cc_Contact_Centre_Date_Time__c,OwnerId, Region_Flag__c FROM Case WHERE Id =:caseId];
        //Get the queue label for the assignment depending on the region flag
        List<Queue_IDs__mdt> queueIds = [SELECT Id, DeveloperName, Label, Queue_ID__c, MasterLabel, Queue_Name__c, Region__c FROM Queue_IDs__mdt WHERE Region__c =: cs.Region_Flag__c];
        Map<Id, String> caseToRegion = Util.getQueuesCustomMetadata(new List<Case>{cs});
        Util.setOwnerQueue(queueIds, caseToRegion, cs, CREDIT_BUSINESS_TEAM_QUEUE); //cs.OwnerId = System.Label.Credit_Business_Team;
        
        cs.cc_Contact_Centre_Date_Time__c = System.now();
        try{
            update cs;
            responseMessage ='Success';
        }
        catch(exception e){
            responseMessage ='Fail: '+e.getMessage();
        }

        return responseMessage;

    }
    @auraEnabled
    Public static String sendForRejection(Id caseId){
        String responseMessage;
        system.debug('caseId||'+caseId);
        Case cs = [SELECT Id,Status,Sub_Status__c,cc_Contact_Centre_Result__c,cc_Contact_Centre_Date_Time__c,AccountId,ContactEmail FROM Case Where ID =:CaseId];
        contact cd = [SELECT Id,Name,Email FROM contact WHERE AccountId =:cs.AccountId];
        cs.Status = 'Closed';
        cs.Sub_Status__c = 'Completed';
        cs.cc_Contact_Centre_Result__c = 'Declined';
        cs.cc_Contact_Centre_Date_Time__c = System.now();
        try{
            update cs;
            responseMessage ='Success';
        }
        catch(Exception e){
            responseMessage ='Fail: '+e.getMessage();
        }
        //Commented By Jahangeer Mohammed on 29-08-2021
        //code to send the rejection Email
        //upon email success we can update case as closed
        /*EmailTemplate et = [SELECT Id,Name FROM EmailTemplate WHERE Name ='CC_NoDueCertificateRejection'];
        OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address = 'support@ilabank.com'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(et.Id);
        email.setTargetObjectId(cd.Id);
        email.setOrgWideEmailAddressId(owe.Id);
        email.setToAddresses( new List<String>{cd.Email} );
        Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        System.debug('result||'+result);
        if(result[0].isSuccess()){
            responseMessage='Success';
        }else{
            responseMessage='Email Not sent successfully';
        }*/
        return responseMessage;
    }
    //CH02 - Swapna -Start
    @AuraEnabled(cacheable=false) 
    public static Boolean checkVisibilityStatement(String accountId){
        system.debug('hitting==>'+accountId);
      Boolean isVisible=false;
      List<User> users = [select id,Member_Of_Credit_Card_Collection__c FROM User Where id =: userInfo.getUserId()];
      if(users[0].Member_Of_Credit_Card_Collection__c==true)
      {
        system.debug('accountId==>'+accountId);
        isVisible = SensitiveDataCleaner.checkStaffVisibilityForStatements(accountId);  
      }
       return isVisible; 
    }
    //CH02 - Swapna -End

    //CH07 : Start
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getPCIOptionsV2(String accID,String caseModel){
        Map<String,Object> retrivePCIOption = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
         //#CH06 Start
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         //#CH06 END
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);//CH06

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); //CH12
        }
        request.setTimeout(120000);
        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        /* HttpResponse response = new HttpResponse();
        String body = '{    "meta": {        "code": "COPT-001",        "message": "Card Options Response."    },    "data": {        "currentCards": [            {                "id": "16549978",                "cardProductConfigurationId": 1,                "cardNature": "secured",                "productMappingCode": "PLATINUM_BALANCE_TRANSFER_01",                "cardDisplayName": "Titanium Co-brand",                "cmsCardProductId": "002",                "cmsCardProductType": "01",                "isPrimary": true,                "embossName": "Mohammed Salah",                "maskedCardNumber": "123456 **** **** 1234",                "issueDate": "2020-12-01",                "activationDate": "2020-12-15",                "blockDate": "",                "provider": "Mastercard",                "status": "Active",                "parentStatus": "Active",                "order": "1",                "isRequestedCard": true,                "mustBeActivated": false,                "isDelinquent": false,                "isBankBlocked": false,                "hasSupplementaryCardFees": false,                "canRequestSupplementaryCard": true,                "pendingRelease": false,                "supportedDigitalWallets": [                    "APPLE_PAY"                ]            }        ]    }}';
        response.setStatus('OK');    
        response.setStatusCode(200);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json'); */
        system.debug('---> Responce New --> '+response.getBody());


        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            //CH17: Added isAPIFailed parameter in the method
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',true);

        }
        else
        {
            System.debug(response.getBody());
            //system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response));
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                if(mapRelatedCurrentCards.containsKey('id') && mapRelatedCurrentCards.get('isPrimary') == true 
                    && mapRelatedCurrentCards.containsKey('cardNature') ){
                    String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                    //CH09: Start Checking cardNature == unsecured and cardStatus == ACTIVE
                    String cardStatus = (String) mapRelatedCurrentCards.get('status');
                    if(!cardNature.contains('prepaid') && cardNature == 'unsecured' && cardStatus == 'ACTIVE'){
                        retrivePCIOption.put((String)mapRelatedCurrentCards.get('id'),mapRelatedCurrentCards);
                        //retrivePCIOption.put((String)mapRelatedCurrentCards.get('maskedCardNumber'),(String)mapRelatedCurrentCards.get('id'));
                    }
                    //CH09: END
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
        }
        return retrivePCIOption;
    }
    //CH07 : End
    
    //#CH10:START
      @AuraEnabled(cacheable=false)
        public static ApiConnection.Response loadRewardDetails(final String customerId, final String cardId, String regionName, String Option) {
        final HttpRequest req;
        if(Option=='ILA_TOKENS'){
            req = con.createRequest('GET','/api/v1/rewards/ila-tokens?pciNumber='+cardId, customerId, regionName);
            req.setTimeout(120000);   
        }else if(Option=='CASHBACK'){
            req = con.createRequest('GET','/api/v1/rewards/cashback?pciNumber='+cardId, customerId, regionName);
            req.setTimeout(120000);     
        }else if(Option=='AIRLINE_MILES'){
            req = con.createRequest('GET','/api/v1/rewards/miles?pciNumber='+cardId, customerId, regionName);
            req.setTimeout(120000);
        }
        
        system.debug('---> REQUEST --> '+req);
        
        ApiConnection.Response response = new ApiConnection.Response();
        //final ApiConnection.Response response;
        if(req!=null){
            response = con.makeCallout(req);
            
            system.debug('---> RESPONSE Reward --> '+response);
            system.debug('---> JSON Formatted RESPONSE --> '+JSON.serializePretty(response));
            if (response.isSuccess && null != response.responseData ||(test.isRunningTest())) {
                
                final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
                if (CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired(customerId)) {
                    system.debug('SENSITIVE_FIELDS_ACCOUNT_DETAILS||'+SENSITIVE_FIELDS_ACCOUNT_DETAILS);
                    CreditCard_SensitiveDataCleaner.removeSensitiveData(responseData, SENSITIVE_FIELDS_ACCOUNT_DETAILS);
                }
            }else{
                System.debug('The status code returned was not expected: ' + JSON.serializePretty(response.errorData));
                System_Action__c logObject = new System_Action__c();
                logObject.Account__c = [SELECT Id FROM ACCOUNT WHERE CIF__pc =:customerId].Id;
                logObject.Action__c = 'Reward Details';
                logObject.Endpoint__c =String.valueOf(req);
                logObject.Method__c='GET';
                logObject.Response_Body__c=JSON.serializePretty(response.errorData);
                
                insert logObject;
            }
        }
        return response;
    }  
    //#CH10:END
    /*@AuraEnabled(cacheable=false)
    public static String generatePdf(String customerId,String selCardId,String accName,Object[] selectedData){
        System.debug('Generate Pdf Methods:'+selectedData);
        creditCardPdfController2 pdfController = new creditCardPdfController2();
        pdfController.processCreditCardTransactions(customerId,selCardId,accName,selectedData);
        return 'Message';
    }*/
     //CH13: Start
    @AuraEnabled
    public static String createAuditRecordForCreditCardDetails(String accCIF, String maskNumber, String cardClassification, String cardStatus){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('Mask Number:'+maskNumber);
        System.debug('Card Classification:'+cardClassification);
        System.debug('Card Status:'+cardStatus);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Credit Card Detail';
        cusAudit.Masked_Card_Number__c = maskNumber;
        cusAudit.Card_Classification__c = cardClassification;
        cusAudit.Card_Status__c = cardStatus;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH13: END

    //CH14: START
    @AuraEnabled(cacheable=false)
    public static List<Object> termDepositListApiCall(String accID, String caseModel,String typeCase){
        List<Object> depositList = new List<Object>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID]; 
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        request =  con.createRequest('GET', '/api/v1/term-deposit', accObj.CIF__pc,regionName);
        

        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc);        
        }

        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
        if (response.getStatusCode() != 200 ) {
            String errorMsg = 'The status code returned was not expected when we are calling Get term deposits API : ' + response.getStatusCode();
            System.debug(errorMsg);
            throw new AuraHandledException(errorMsg);
        }else {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> termDepositsList = (List<Object>)m1.get('termDeposits');
                for(Object termDeposit : termDepositsList){
                    Map<String,Object> mapTermDeposit = (Map<String, Object>)termDeposit;
                    if(typeCase == 'CASH_LIMIT_INCREASE'){
                        //CH15: Start
                        if(mapTermDeposit.get('statusCode') == 'OPEN' /*&& mapTermDeposit.get('linkedAsCollateral') == false*/ ){
                            depositList.add(mapTermDeposit);
                        }
                    }else{
                        if(mapTermDeposit.get('statusCode') == 'OPEN' && mapTermDeposit.get('linkedAsCollateral') == false ){
                            depositList.add(mapTermDeposit);
                        }
                        //CH15: END
                    }
                }
        }
        
        return depositList; 
    }
    @AuraEnabled(cacheable=false)
    public static List<Object> termDepositList(String accID, String caseModel){
        return termDepositListApiCall(accID,caseModel,'NORMAL_CASH_CORATERAL'); 
    }
    @AuraEnabled(cacheable=false)
    public static List<Object> termDepositListForLimitIncrease(String accID, String caseModel){
        return termDepositListApiCall(accID,caseModel,'CASH_LIMIT_INCREASE'); 
    }
    //CH14: END
    //CH16: Start
        @AuraEnabled(cacheable=false)
    public static Map<String,Object> fetchGulfAirId(String customerId, String membershipId) {
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,x_canary__pc, Region_Flag__c FROM Account WHERE Id=: customerId];//CH12

        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = accObj.Region_Flag__c;
        request = con.createRequest('GET','/api/v1/gulf-air/details',regionName);
        String endPoint = request.getEndpoint();
        request.setEndpoint(endPoint + '&membershipNumber='+membershipId);
        System.debug('Get End-Point:'+request.getEndPoint());
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null ){
            request.setHeader('x-canary', accObj.x_canary__pc);
        }
        HttpResponse response = http.send(request);
        Map<String, Object> responseMap;
        if(response.getStatusCode() != 200){
           System.debug('The status code returned was not expected: ' +response.getStatusCode());
           System.debug('Un-Successful response from the API:'+response.getBody());
           responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

        }
        else{
            System.debug('Successful Response from the API:'+response.getBody());
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        }
        return responseMap;
    }
    //CH16: END
    
    //CH18:START
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response downloadCashCollateral(final String caseId,final Map<String, Object> mapOfCardDetails){
        ApiConnection.Response response = new ApiConnection.Response();

        String pageURL = getVFPageURLWithParams(caseId,mapOfCardDetails);
        
        try{
            PageReference pdfPage = new PageReference(pageURL);
            Blob pdfData;
            if(Test.isRunningTest()) {
                pdfData = blob.valueOf('Content for Unit Test');
            }
            else {
                pdfData = pdfPage.getContent();
            }
            response.isSuccess = true;
            response.responseData = EncodingUtil.base64Encode(pdfData);
            response.errorData = '';
        }
        catch(Exception ex){
            response.isSuccess = false;
            response.responseData = '';
            response.errorData = ex.getMessage();
        }
        return response;
    }
    
    @AuraEnabled(cacheable=false)
    public static String sendEmailWithCashCollateralCert(final String caseId,final Map<String, Object> mapOfCardDetails){
    
        String pageURL = getVFPageURLWithParams(caseId,mapOfCardDetails);
        String response = '';
        try{
            PageReference pdfPage = new PageReference(pageURL);
            Blob pdfData;
            if(Test.isRunningTest()) {
                pdfData = blob.valueOf('Content for Unit Test');
            }
            else {
                pdfData = pdfPage.getContent();
            }
            
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setContentType('application/pdf');
            efa.setFileName('Cash Collateral.pdf');
            efa.setBody(pdfData);
            
            String emailTemplate = 'CashCollateralCertificate';
            String supportEmail = 'support@ilabank.com';
            
            Case caseRecord = [SELECT Id,Case_Model__c,ContactId,Contact.Email FROM Case WHERE Id = :caseId LIMIT 1];
            Contact cntRecord = caseRecord.Contact;
            
            if(caseRecord != null && caseRecord.Case_Model__c == 'alburaq'){
                emailTemplate = 'CashCollateralCertificate_alburaq';
                supportEmail = 'support.alburaq@ilabank.com';
            }
            
            EmailTemplate template = [SELECT Id,Name FROM EmailTemplate 
                                      WHERE DeveloperName =:emailTemplate LIMIT 1];
            
            OrgWideEmailAddress owe = [select Id from OrgWideEmailAddress where Address =:supportEmail];
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(template.Id);
            email.setTargetObjectId(cntRecord.Id);
            email.setOrgWideEmailAddressId(owe.Id);
            email.setToAddresses( new List<String>{cntRecord.Email} );
            email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
            Messaging.SendEmailResult [] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
            
            if(result[0].isSuccess()){
                 response = 'success';
            }else{
                 response = 'Email Not sent successfully';
            }
            
        }
        catch(Exception ex){
            response = ex.getMessage();
        }
        
        return response;
    }
    
    @AuraEnabled
    public static String getVFPageURLWithParams(String caseId,Map<String, Object> mapOfCardDetails){
        
        String pageURL = '/apex/CashCollateralCertificatePDF?id=' + caseId;
        String otherVFPageParams = '';
        for(String key : mapOfCardDetails.keyset()){
            Object val = mapOfCardDetails.get(key);
            if(String.isEmpty(otherVFPageParams)){
                otherVFPageParams = key + '=' + val;
            }
            else {
                otherVFPageParams = otherVFPageParams + '&' + key + '=' + val;
            }
        }
        
        if(!String.isEmpty(otherVFPageParams)){
            pageURL = pageURL + '&' + otherVFPageParams;
        }
        
        return pageURL;
    }
    
    @AuraEnabled
    public static string updateCaseStatus(String caseId){
        String response;
        try
        {
            Case caseObj = new Case(Id = caseId);
            caseObj.Status='Closed';
            update caseObj;
            response='Success';
        }
        catch(system.Exception e){
            response = 'Error:' +e.getMessage();
        }
        return response;
    }
    
    @AuraEnabled
    public static String checkCreditCardUser(){
        String response = 'no';
        try
        {
            User u = [Select Id,Cannot_Close_Non_Credit_Card_Application__c FROM 
                      User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            if(u.Cannot_Close_Non_Credit_Card_Application__c){
                response = 'yes';
            }
        }
        catch(system.Exception e){
            response = 'Error:' +e.getMessage();
        }
        return response;
    }
    //CH18:END
    //CH19: Start
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> loadCardDetailsToFetchLimit(String accID,String caseModel,String requestedPCINumber){
        Map<String,Object> creditCardDetail = new Map<String,Object>();
        Map<String,Object> creditCardDetailData = new Map<String,Object>();
        Decimal creditLimit;
        System.debug('accID'+accID);
        //accID='001Pw00000XzpdUIAR';
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
        
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/credit-cards/'+requestedPCINumber+'/details', regionName);
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); 
        }
        request.setTimeout(60000);
        System.debug('End Point Credit Card Detail ==>'+Request.getEndpoint());
        system.debug('---> Request Body --> '+request.getBody());
        HttpResponse response = http.send(request);
       
        system.debug('---> Response Getting from API in Credit Card detail --> '+response.getBody());
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',false);

        }
        else{
            System.debug('Credit Card Detail Response:'+response.getBody());
            creditCardDetail = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); //meta, data
            creditCardDetailData = (Map<String, Object>)creditCardDetail.get('data');
            System.debug('Credit Card Detail Data:'+creditCardDetailData);
            //creditLimit = (Decimal)creditCardDetailData.get('creditLimit');
        }
        
        return creditCardDetailData;
    }
    //CH19: END
    //CH24: Start
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> getloadCreditCardBankList(String accId){
        List<Map<String, String>> bankListOptions = new List<Map<String, String>>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accId];
        String regionName = accObj.Region_Flag__c;
        System.debug('Region Name:'+regionName);
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('GET','/api/v1/content/CreditCardBanks/list', regionName);
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            
            request.setTimeout(60000);
            System.debug('End Point Credit Card Detail ==>'+request.getEndpoint());
            HttpResponse response = http.send(request);
            system.debug('---> Response Getting from API--> '+response.getBody());
            if(response.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
            else{
                System.debug('Bank List Detail Response:'+response.getBody());
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                
                Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
                List<Object> resources = (List<Object>) dataMap.get('resources');

                for (Object obj : resources){
                    Map<String, Object> item = (Map<String, Object>) obj;
                    Map<String, String> option = new Map<String, String>();
                    option.put('key', String.valueOf(item.get('key')));
                    option.put('value', String.valueOf(item.get('value')));
                    
                    bankListOptions.add(option);
                }
            }
        }catch(Exception ex){
            System.debug('Error Message:'+ex.getMessage());
        }
        return bankListOptions;
        
    }
    //CH24: END
    //CH20: Start
      @auraEnabled
    public static String updatePCIMaskNumberOnCase(string caseId, string pciNumber, string mskCardNumber){
        String responseMessage;
        system.debug('Case Id:'+caseId);
        system.debug('PCI Number:'+pciNumber);
        system.debug('Masked Card Number:'+mskCardNumber);
        
        Case cs = [SELECT Id,Type,Status,cc_Credit_Card_PCI_Number__c,cc_PCI_Id__c FROM Case Where ID =:caseId];
        Boolean isUpdateRequired = false;
        if(cs.Type == 'Credit Card FCR' && cs.Status != 'Closed'){
            if(cs.cc_Credit_Card_PCI_Number__c != pciNumber){
                cs.cc_Credit_Card_PCI_Number__c = pciNumber;
                isUpdateRequired = true;
            }
            if(cs.cc_PCI_Id__c != mskCardNumber){
                cs.cc_PCI_Id__c = mskCardNumber;
                isUpdateRequired = true;
            }
        }
        else if(cs.Type == 'Credit Card Services' && cs.Status != 'Closed'){
            system.debug('Masked Card Number Already Exist:'+cs.cc_Credit_Card_PCI_Number__c);
            if(cs.cc_Credit_Card_PCI_Number__c != mskCardNumber){
                cs.cc_Credit_Card_PCI_Number__c = mskCardNumber;
                isUpdateRequired = true;
            }
            if(cs.cc_PCI_Id__c != pciNumber){
                cs.cc_PCI_Id__c = pciNumber;
                isUpdateRequired = true;
            }
        }
        if(isUpdateRequired){
            try{
                update cs;
                responseMessage ='Successfully updated case';
            }catch(Exception e){
                responseMessage ='Fail: '+e.getMessage();
            } 
        }
        else{
            responseMessage = 'No changes detected - case not updated';
        }
        
        return responseMessage;
    }
    //CH20: END
    //CH21: Start
    @AuraEnabled(cacheable=false) 
    public static Boolean checkCIFNumber(String accountId, String cifNumber){
        Boolean cifFound = false;
        List<Account> accList = [Select Id, CIF__pc from Account Where CIF__pc =: cifNumber AND Segment__pc != 'Staff' AND Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Blacklisted__c != true LIMIT 1];
        if(accList.size()>0){
            cifFound = true;
        }
        else{
            cifFound = false;
        }
        return cifFound;
    }
    @AuraEnabled(cacheable=false)
    public static String getFirstAndLastName(String cifNumber){
        String name;
        Account acc = [SELECT Id,CIF__pc, PersonContact.FirstName, PersonContact.MiddleName, PersonContact.LastName From Account WHERE CIF__pc =:cifNumber];
        String middlename =' ';
        if(acc.PersonContact.MiddleName != NULL){middlename = ' '+acc.PersonContact.MiddleName+' ';}
        return name = acc.PersonContact.FirstName+middlename+acc.PersonContact.LastName;

    }
    //CH21: END
    //CH22: Start
    /*@AuraEnabled(cacheable=false)
    public static String fetchWorldEliteMembershipNumber(String caseId){
        Case cse = [Select id, AccountId, Account.World_Elite_Benefit_Membership_No__pc from Case where id =: caseId];
        return cse.Account.World_Elite_Benefit_Membership_No__pc;
       
    }*/
    //CH22: END
}