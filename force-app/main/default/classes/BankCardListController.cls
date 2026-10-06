/**
 *  @author: Andrey Gavrikov (westbrook)
 *  @date: 2019-02-08 10:04:53
 *  @description:
 *      controller for aura components related to bank cards
 *
 *  Version History :
 *  2019-02-08 - CRM-38 - AG
 *  - Display Card Information
 *                #CH01# #Mbarki Aniss# #21-06-2022# add visibility function for Debit+Card+Enhancement requirement & collect fee logic
 *                #CH02# #Jahangeer Mohammed# #20/02/2024#  add filterBlocked Parameter to loadCardList(PI-3089)
 * 		  		  #CH03# #Jahangeer Mohammed #06-05-2024# Added logic for Audit History Enhancements(NBA-9027)
                  #CH04 : #Aniss Mbarki# #04-06-2024# add x-canary header
 * 				  
 *
 */
public without sharing virtual class BankCardListController {
    @TestVisible // overwrite instance to provide custom connection in test class
    private static ApiConnection con = new ApiConnection();

    @TestVisible // overwrite instance to provide custom DAO in test class
    private static BankCardListController DAO = new BankCardListController();


    /**
     * to load Segment Option /segment/options/crm?language=en&unit=neo
     * @author SP
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadSegmentOptionsCRM(String customerId, String caseId, String regionName){
        return SegmentAPIHandler.loadSegmentOptionsCRM(customerId, caseId, regionName);
    }

    /**
     * to request Segment Transaction /segment/options/crm?language=en&unit=neo
     * @author SP
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response upDowngradeSegment(String customerId, String availableCard,
                                                            String discount, String embossName, String caseId,  String regionName)
    {

        System.debug('43 upDowngradeSegment ');
        System.debug('43 upDowngradeSegment customerId ' + customerId);
        System.debug('43 upDowngradeSegment availableCard ' + availableCard);
        System.debug('43 upDowngradeSegment discount ' + discount);
        System.debug('43 upDowngradeSegment embossName ' + embossName);
        System.debug('43 upDowngradeSegment caseId ' + caseId);
        System.debug('43 upDowngradeSegment regionName ' + regionName);
        
        //#CH01 Start: added to close the Case after sucessfull response
        ApiConnection.Response response = SegmentAPIHandler.upDowngradeSegment(customerId, availableCard, discount, embossName, caseId, regionName);
        if (response.isSuccess){
            Case cs=New Case(Id=caseId);
            cs.Status='Closed';
            update cs;
        }
        //#CH01 :  END

        return response;
    }


    @AuraEnabled(cacheable=false)
    //changed by SP
    //Add param personEmail to the method
    //public static ApiConnection.Response loadCardList(final String customerId) {
    public static ApiConnection.Response loadCardList(final String customerId, final String personEmail, String regionName, Id recordId) {
        HttpRequest req = con.createRequest('GET', '/api/v1/cards', customerId, personEmail, regionName);
        //CH02: Start
        String endp = req.getEndpoint() + '&filterBlocked=false';
        req.setEndpoint(endp);
        //CH02: END
		req.setTimeout(120000);
        final ApiConnection.Response response = con.makeCallout(req);
        System.debug(JSON.serializePretty(response));
        if (response.isSuccess && null != response.responseData) {
            final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            final Object[] cards = (Object[])responseData.get('cards');
            final Object[] cleanedCards = cards; //removeSensitiveData(cards);
            responseData.put('cards', cleanedCards);
        }

        return response;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadCardDetails(final String customerId, final String cardId, final String personEmail, String regionName) {
        final HttpRequest req = con.createRequest('POST', '/api/v1/cards/details', customerId, personEmail, regionName);
        //ISDI-6861 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size() > 0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
        		System.debug('Request x-canary header : '+accs.get(0).x_canary__pc);
            }
        }
        //ISDI-6861 : End
        req.setTimeout(120000);
        req.setBody('{ "id":"'+cardId+'" }');
		System.debug('Request Body for Debit Card Details:'+req.getBody());
        final ApiConnection.Response response = con.makeCallout(req);

        return response;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response blockCard(final String customerId, final String blockCardData,
                                                   final Id caseId, final String personEmail, String regionName) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> caseObj=[Select Id,AccountId,Account.x_canary__pc from Case where Id=:caseId];

        final Map<String, Object> blockCardDataMap = (Map<String, Object>)JSON.deserializeUntyped(blockCardData);
        final String cardId = (String)blockCardDataMap.get('cardId');
        final String actionType = (String)blockCardDataMap.get('actionType');
        
        //#CH01 : START 
        String collectFee;
        if(blockCardDataMap.get('collectFee') != null ){
            collectFee = String.valueOf(blockCardDataMap.get('collectFee'));
        }
        //#CH01 : END
        
        final Map<String, String> requestObject = new Map<String, String>{
            'customerId' => customerId,
            'id' => cardId,
            'reason' => (String)blockCardDataMap.get('reason'),
            'collectFee' => collectFee //#CH01
        };
        final String requestText = JSON.serialize(requestObject);

        // JT Changed the End point from cards/' + cardId + '/block' to cards/block since change to API definition
        final HttpRequest req = con.createRequest('PUT', '/api/v1/cards/block/crm', customerId, personEmail, regionName);
        if(caseObj.get(0).Account.x_canary__pc != null){
            req.setHeader('x-canary', caseObj.get(0).Account.x_canary__pc);//CH01
        }
        req.setBody(requestText);

        req.setTimeout(60000); //CH01 : add after error msg Read timed out "UATNB-48590"

        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = (String)blockCardDataMap.get('maskedCardNumber');

        final ApiConnection.Response response = con.makeCallout(req, action);

        System.debug('blockCard **************** /////////////////////');
        System.debug( 'request Method : ' + req.getMethod() );
        System.debug( 'request EndPoint : ' + req.getEndpoint() );
        System.debug( 'request Body : ' +req.getBody() );
        System.debug( response );

        //CH01 - start Swapna
        /*if (!response.isSuccess && null != response.errorData) {
        // check if this is 20020: Card is already blocked.
        // in this case we report this as a successful response
        final Map<String, Object> errData = (Map<String, Object>)response.errorData;
        response.isSuccess = 20020 == errData.get('code');
        }*/
        system.debug('response==>'+response);                                           
        //if (response.isSuccess && null != response.responseData) {
        if (response.isSuccess){
            Case cs=New Case(Id=caseId);
            cs.Status='Closed';
            update cs;
        }
        else{
            //final Map<String, Object> errData = (Map<String, Object>)response.errorData;
            //response.isSuccess = 20020 == errData.get('code');
           lstSA = createSystemAction(req.getBody(),String.valueOf(response.responseData),'callout:NeoBank_Endpoint/api/v1/cards/block/crm?language=en&unit=neo','PUT',caseId,customerId,caseObj[0].AccountId,400, 'blockCard', 'blockCard');
        
        }
        //CH01 - End 

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
                                                        final String personEmail, final String regionName) {

        System.assert(String.isNotBlank(extraParameters), 'requestNewCard: parameter "extraParameters" must be provided');
                                                            
        List<Case> caseObj=[Select Id,AccountId,Account.x_canary__pc from Case where Id=:caseId];
        final HttpRequest req = con.createRequest('POST', '/api/v1/cards/issuance', customerId, personEmail, regionName);
        if(caseObj.get(0).Account.x_canary__pc != null){
            req.setHeader('x-canary', caseObj.get(0).Account.x_canary__pc);
        }                                                    
        req.setBody(requestTextJson);
        req.setTimeout(120000);
        final Map<String, Object> extraParametersMap = (Map<String, Object>)JSON.deserializeUntyped(extraParameters);
        final String systemActionType = (String)extraParametersMap.get('systemActionType');
        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, systemActionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = maskedCardNumber;

        ApiConnection.Response response = con.makeCallout(req, action);
        System.debug('requestNewCard **************** /////////////////////');
        System.debug( 'request Method : ' + req.getMethod() );
        System.debug( 'request EndPoint : ' + req.getEndpoint() );
        System.debug( 'request Body : ' +req.getBody() );
        System.debug( response );
        final Boolean isCaseClosureRequired = true == extraParametersMap.get('isCaseClosureRequired');
        if (isCaseClosureRequired && response.isSuccess) {
            final String caseType = (String)extraParametersMap.get('caseType');
            final String caseSubType = (String)extraParametersMap.get('caseSubType');


            response = closeCase(caseId, caseType, caseSubType);
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

        ApiConnection.Response response = con.makeCallout(req, action);
        final Boolean isCaseClosureRequired = true == parameterDataMap.get('isCaseClosureRequired');
        if (isCaseClosureRequired && response.isSuccess) {
            final String caseType = (String)parameterDataMap.get('caseType');
            final String caseSubType = (String)parameterDataMap.get('caseSubType');

            response = closeCase(caseId, caseType, caseSubType);
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
        List<Case> caseObj=[Select Id,AccountId,Account.x_canary__pc from Case where Id=:caseId];

        final Map<String, String> requestObject = new Map<String, String>{
            'id' => cardId,
            'accountId' => accountId,
            'action' => (String)parameterDataMap.get('action'),
            'customerId' => customerId
        };
        final String requestText = JSON.serialize(requestObject);

        final HttpRequest req = con.createRequest('PUT', '/api/v1/cards/accounts/association', customerId, personEmail, regionName);
       if(caseObj.get(0).Account.x_canary__pc != null){
            req.setHeader('x-canary', caseObj.get(0).Account.x_canary__pc);
        } 
        req.setBody(requestText);

        final System_Action__c action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, actionType);
        // topup System_Action__c log record with extra information
        action.Card_Number__c = (String)parameterDataMap.get('maskedCardNumber');

        ApiConnection.Response response = con.makeCallout(req, action);
        final Boolean isCaseClosureRequired = true == parameterDataMap.get('isCaseClosureRequired');
        if (isCaseClosureRequired && response.isSuccess) {
            final String caseType = (String)parameterDataMap.get('caseType');
            final String caseSubType = (String)parameterDataMap.get('caseSubType');

            response = closeCase(caseId, caseType, caseSubType);
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
     public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        system.debug('new==>');
         List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
         system.debug('custId==>'+custId);
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //  action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
        system.debug('AccId==>'+AccId);
        action.Case__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        lstSA.add(action);

        return lstSA;

    }

    /**
     *  @author: Aniss Mbarki 
     *  @date: 2022-06-21 
     *  @description:
     *      to handle the visibilty of some options in aura components related to bank cards Actions
     *  Version History :
     *
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, String> visibilityOptionsCheck(Id caseId){//#CH01
        Map<String, String> responseData = new Map<String, String>();
        
        Case caseRecord = [SELECT Status, Account.PersonEmail, Region_Flag__c FROM Case WHERE Id = :caseId];
        responseData.put('Status',caseRecord.Status);
        responseData.put('PersonEmail',caseRecord.Account.PersonEmail);
        responseData.put('Region',caseRecord.Region_Flag__c);
        
        String profileNameUserInfo = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        responseData.put('Profile',profileNameUserInfo);

        return responseData;
    }
     //CH03: Start
    @AuraEnabled
    public static String createAuditRecordForDebitCardDetails(String accCIF, String maskNumber, String cardClassification, String cardStatus){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('Mask Number:'+maskNumber);
        System.debug('Card Classification:'+cardClassification);
        System.debug('Card Status:'+cardStatus);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Debit Card Detail';
        cusAudit.Masked_Card_Number__c = maskNumber;
        cusAudit.Card_Classification__c = cardClassification;
        cusAudit.Card_Status__c = cardStatus;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH03: END
    
}