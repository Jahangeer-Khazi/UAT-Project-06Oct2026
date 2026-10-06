/**
* @author ANISS MBARKI
* @date Création 15/12/2021
* @date Modification
* @description SM001_ApiCalls - Apex class (part of the Mocking Framework) that prepare and initiate the http requests and call the EM001 to get appropriate response
* @history Modifications :
*       #CH01 : Swapna add creditCardStatementApi method
*       #CH02 : Aniss Mbarki add AccountStatementsApi method
*       #CH03 : Wissal benqezza add Account Closure Api calls
*       #CH04 : Swapna added getCreditCardStatusApi and getCreditCardDetailsApi method
*       #CH05 : Wissal benqezza add Update Credit Card Request Status API
*       #CH06 : Wissal benqezza add blockUnblockAccountApi & getAccountsListAllApi & getAccountHoldTransactionsApi
*       #CH07 : Wissal benqezza add   UpdateAccountForInterestRate
*       #CH08 : Aniss Mbarki add scheduled PLA payments API
*       #CH10 : Added by Amina BENABDELKRIM  20-06-2022 *** region name changes according to case model value -->callValidateAccountClosureApi
*       #CH11 : Aniss Mbarki add updatePrepaidCardRequestStatusApi -- Prepaid Card Requirement
*       #CH12 : Amina BENABDELKRIM add callValidateAccountTerminationApi method.
*       #CH13- : Meryem Bakir Add Region Name Process. Date 25/05/2023
*       #CH14 : Wissal benqezza add PeriodicReviewBlockProductsApi,PeriodicReviewUnblockProductsApi . Date 21/11/2022
*       #CH17 : Elmustapha ELGARNI add updateCustomerDetailsAPI . Date 04/03/2024
*       #CH20 : Imane Tsioucha add CustomerTotalBalanceAPI . Date 13/02/2024
* 		 #CH21 : Imane Tsioucha add MoEngageDeleteAPI . Date 17/05/2024
*       #CH22# #Jahangeer Mohammed# #04-02-2025# Added Logic for API Failures(NBA-13083)
*       #CH23 : Jayanth Manickam Bond Statement . Date 24/09/2024
*/
public without sharing class SM001_ApiCalls {
    private static String CLASS_NAME = SM001_ApiCalls.class.getName();
    public static HttpResponse getComplianceCaseStatusApi(HttpRequest request, Case caseObj){
        request.setHeader('customerId', caseObj.sc_Card_Holder_ID_Number__c);//Account.CIF__pc
        system.debug('getComplianceCaseStatusApi ---> Request getEndpoint() --> '+request.getEndpoint() );
        HttpResponse response = EM001_ApiCalls.getComplianceCaseStatusApi(request,null);
        System.debug(response.getBody());
        return response;
    }
    public static HttpResponse callNameScreeningApi(HttpRequest request, Case caseObj){
        String fullName;
        if(caseObj.sc_Card_Holder_First_Name__c != null && caseObj.sc_Card_Holder_Last_Name__c != null){
            fullName = caseObj.sc_Card_Holder_First_Name__c + ' ' + caseObj.sc_Card_Holder_Last_Name__c ;
        }
        String body = '{"idNumber":'+ stringApiFormat(caseObj.sc_Card_Holder_ID_Number__c) +
            ',"idExpiryDate":' + stringApiFormat(dateToApiDateFormat(caseObj.sc_Card_Holder_ID_Expiry_Date__c)) +
            ',"fullName":' + stringApiFormat(fullName) +
            ',"dateOfBirth":' + stringApiFormat(dateToApiDateFormat(caseObj.sc_Card_Holder_Date_of_Birth__c)) +
            ',"nationality":' + stringApiFormat(caseObj.sc_Card_Holder_Nationality__c) +
            ',"gender":'+ stringApiFormat(caseObj.sc_Card_Holder_Gender__c)+
            '}';
        request.setBody(body);
        request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', caseObj.sc_Card_Holder_ID_Number__c);
        system.debug('---> Request body --> '+request.getBody());
        system.debug('---> Request getEndpoint() --> '+request.getEndpoint() );
        HttpResponse response = EM001_ApiCalls.callNameScreeningApi(request,null);
        System.debug(response.getBody());
        return response;
    }
    public static HttpResponse callApiToCreateSupplementaryCardInVPlus(HttpRequest request, Case objCase){
        String body = '{"crmCaseId":'+stringApiFormat(objCase.Id)+
            ',"cardProductConfigurationId":'+stringApiFormat(objCase.PrimaryCardProductConfigurationId__c)+
            ',"pciNumber":'+stringApiFormat(objCase.PrimaryCard__c)+
            ',"embossName":'+stringApiFormat(objCase.cc_Name_on_the_Card__c)+
            ',"supplementaryCard":'+
            '{"mobile":'+stringApiFormat(objCase.sc_Card_Holder_Mobile_No__c)+
            ',"email":'+stringApiFormat(objCase.sc_Card_Holder_Email_Address__c)+
            ',"relationship":'+stringApiFormat(objCase.sc_Relationship__c)+
            ',"enableSpendingLimit":false},'+
            '"creditLimit": 0' +
            ',"targetType": "SUPPLEMENTARY_CARD","status":"APPROVED"}';
        request.setBody(body);
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        system.debug('---> Request body --> '+request.getBody());
        system.debug('---> Request getEndpoint() --> '+request.getEndpoint() );
        HttpResponse response = EM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus(request,null);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        return response;
    }
    public static HttpResponse callBlockAmountApi(HttpRequest request, Case objCase){
        String body =
            '{"caseNumber":'+stringApiFormat(objCase.CaseExecutionNumberB__c)+
            ',"letterReferenceNumber":'+stringApiFormat(objCase.LetterReferenceNumberB__c)+
            ',"amount":'+objCase.BlockAmountBHDB__c+
            ',"currency":"BHD"'+
            ',"type":"CUSTOM"' +
            '}';
        request.setBody(body);
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        system.debug('---> Request body --> '+request.getBody());
        system.debug('---> Request getEndpoint() --> '+request.getEndpoint() );
        HttpResponse response = EM001_ApiCalls.callBlockAmountApi(request,200);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        return response;
    }
    public static HttpResponse callUnblockAmountApi(HttpRequest request, Case objCase){
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setHeader('customerId', objCase.Account.CIF__pc);
        system.debug('---> Request getEndpoint() --> '+request.getEndpoint() );
        HttpResponse response = EM001_ApiCalls.callUnblockAmountApi(request,200);
        System.debug(response.getStatusCode());
        System.debug(response.getBody());
        return response;
    }
    public static String dateToApiDateFormat(Date input){
        if(input != null){
            Datetime output = input;
            return output.format('yyyy-MM-dd');
        }else{
            return null;
        }
    }
    public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
    public static String decimalApiFormat(Decimal input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
    public static System_Action__c setSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
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
        //CH22: Start
        if(strType == 'Prepaid Credit Card'){
            action.Is_API_Failed__c = true;
        }
        //CH22: END
        return action;
    }
    public static System_Action__c setSystemActionWithBOD(final String reqBody, final String resBody, final String path, Final String method, Final Id bulkOperationDetailId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
        action.Bulk_Operation_Detail__c = bulkOperationDetailId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        //CH22: Start
        if(strType == 'Prepaid Credit Card'){
            action.Is_API_Failed__c = true;
        }
        //CH22: END
        return action;
    }
    public static System_Action__c setSystemActionForReturnedCard(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Final Integer statCode, Final String strAction, Final String strType) {
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
        action.Returned_Cards__c = CaseId;
        action.Account__c = AccId;
        action.Endpoint__c = path;
        action.Method__c = method;
        action.HTTP_Response_Code__c = statCode;
        action.Origin__c = 'CRM';
        action.Request_Body__c = reqBody;
        action.Response_Body__c = resBody;
        action.Target__c = 'Orchestration Layer';
        action.Type__c = strType;
        action.Is_API_Failed__c = false;
        return action;
    }
    //CH01 -Begin
    public static ApiConnection.Response callCreditCardStatementApi(ApiConnection con, String customerId,string regionName, string requestTextJson){
        PAD.debugLogBegin('SM001_ApiCalls', 'callCreditCardStatementApi', '');
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements/credit-card', customerId ,regionName);
        req.setBody(requestTextJson);
        ApiConnection.Response response = EM001_ApiCalls.callCreditCardStatementApi(con,req,null);
        return response;
    }
    public static ApiConnection.Response callCreditCardStatementDetailsApi(ApiConnection con, String customerId,string regionName,string requestTextJson){
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements/credit-card/details', customerId,regionName);
        req.setBody(requestTextJson);
        ApiConnection.Response response = EM001_ApiCalls.callCreditCardStatementDetailsApi(con,req,null);
        return response;
    }
    //CH01 -End
    //CH02 -Begin
    public static ApiConnection.Response callAccountStatementsApi(ApiConnection con, String customerId, string requestTextJson){
        PAD.debugLogBegin('SM001_ApiCalls', 'callAccountStatementsApi', '');
        //aniss Start : 20/12/2022
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        String caseModel ;
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            caseModel = lstAcc.get(0).Subscription_Model__pc;
        }
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements', customerId ,regionName);
        //End : 20/12/2022
        //#CH02 : start
        if(lstAcc != null && lstAcc.size()>0){
            System.debug('x-canary added :'+lstAcc[0].x_canary__pc);
            if(lstAcc[0].x_canary__pc != null){
                req.setHeader('x-canary', lstAcc[0].x_canary__pc);
            }
        }
        //#CH02 : end
        req.setBody(requestTextJson);
        ApiConnection.Response response = EM001_ApiCalls.callAccountStatementsApi(con,req,null);
        return response;
    }
    public static ApiConnection.Response callAccountStatementsDetailsApi(ApiConnection con, String customerId, string requestTextJson){
        //aniss Start : 20/12/2022
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        String regionName ;
        String caseModel ;
        if(lstAcc != null && lstAcc.size()>0){
            regionName = lstAcc.get(0).Region_Flag__c;
            caseModel = lstAcc.get(0).Subscription_Model__pc;
        }
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements/details', customerId,regionName);
        //End : 20/12/2022
        //#CH02 : start
        if(lstAcc != null && lstAcc.size()>0){
            System.debug('x-canary added :'+lstAcc[0].x_canary__pc);
            if(lstAcc[0].x_canary__pc != null){
                req.setHeader('x-canary', lstAcc[0].x_canary__pc);
            }
        }
        //#CH02 : end
        req.setBody(requestTextJson);
        PAD.debugLogInfo(CLASS_NAME, 'callAccountStatementsDetailsApi', 'request Body : '+req.getBody());
        ApiConnection.Response response = EM001_ApiCalls.callAccountStatementsDetailsApi(con,req,null);
        return response;
    }
    //CH02 -End
    //CH03 -Begin
    //To call the list of accounts to close via the api
    public static HttpResponse callAccountListApi(Account customerObj ,String caseModel){
        PAD.debugLogBegin(CLASS_NAME, 'callAccountListApi', 'Parameters : [customerObj] : '+ customerObj);
        ApiConnection con = new ApiConnection();
        //#CH10 Start
        String regionName = customerObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
        HttpRequest request = con.createRequest('GET','/api/v1/accounts',regionName);
        //#CH10 END
        //request.setHeader('userId', customerObj.PersonEmail);
        request.setHeader('customerId', customerObj.CIF__pc);
        HttpResponse response = EM001_ApiCalls.callAccountListApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'callAccountListApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    public static HttpResponse callValidateAccountClosureApi(Case caseObj){
        PAD.debugLogBegin(CLASS_NAME, 'callValidateAccountClosureApi', 'Parameters : [caseObj] : '+ caseObj);
        //#CH10 region name changes according to case model value -->
        String regionName=caseObj.Region_Flag__c;
        if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
            regionName += '_alburaq';
        }
        System.debug( 'Region name ===> '+ regionName);
        ApiConnection con = new ApiConnection();
            
        HttpRequest request = con.createRequest('GET','/api/v1/customer-products/account/closure/validation',regionName);
        //#CH10 END-->
        //request.setHeader('userId', caseObj.Account.PersonEmail);
        //#CH03 : start
              List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE Id=:caseObj.accountId];
              if(accs!= null && accs.size()>0){
              System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                 if(accs.get(0).x_canary__pc != null){
                    request.setHeader('x-canary', accs.get(0).x_canary__pc);
                 }
              }
             //#CH03 : End
        request.setHeader('customerId', caseObj.Customer_CIF__c);
        String body = '{'+
            '"iban": '+stringApiFormat(caseObj.ac_Iban__c)+
            '}';
        request.setBody(body);
        System.debug('body$##'+body);
        HttpResponse response = EM001_ApiCalls.callValidateAccountClosureApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'callValidateAccountClosureApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    public static HttpResponse callCloseAccountApi(Case caseObj,HttpRequest request){
        PAD.debugLogBegin(CLASS_NAME, 'callCloseAccountApi', 'Parameters : [caseObj] : '+ caseObj);
        //toCheck
        //request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', caseObj.Customer_CIF__c);
        System.debug('---> Request getEndpoint() --> '+request.getEndpoint() );
        String body = '{'+
            '"iban": '+stringApiFormat(caseObj.ac_Iban__c)+
            '}';
        request.setBody(body);
        System.debug(request.getBody());
        HttpResponse response = EM001_ApiCalls.callCloseAccountApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'callCloseAccountApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH03 -End
    //CH04 -Start - Swapna
    ////CH13- Add Region Name Process - Meryem Bakir
    public static ApiConnection.Response getCreditCardStatusApi(ApiConnection con, String userId,String customerId,string filerOption,string regionName){
        final HttpRequest request = con.createRequest('GET','/api/v1/credit-cards?',regionName);
        request.setHeader('userId', userId);
        request.setHeader('customerId', customerId);
        request.setHeader('filerOption', filerOption);
        request.setHeader('regionName', regionName);
        ApiConnection.Response response = EM001_ApiCalls.getCreditCardStatusApi(con,request,null);
        return response;
    }
    public static ApiConnection.Response getCreditCardDetailsApi(ApiConnection con,String cardId,String customerId,String personEmail,string regionName){
        //#CH10 replace null param to regionName
        final HttpRequest request = con.createRequest('GET','/api/v1/credit-cards/'+cardId+'/details',regionName);
        request.setHeader('customerId', customerId);
        request.setHeader('personEmail', personEmail);
        request.setHeader('regionName', regionName);
        ApiConnection.Response response = EM001_ApiCalls.getCreditCardDetailsApi(con,request,null);
        return response;
    }
    //CH04 -End - Swapna
    //CH05 -Begin
    public static HttpResponse updateCreditCardRequestStatusApi(ApiConnection con ,Case objCase,String updatedStatus){
        PAD.debugLogBegin(CLASS_NAME, 'updateCreditCardRequestStatusApi','Parameters : [objCase] : '+ objCase);
        //#CH10 Start
        String regionName = objCase.Region_Flag__c;
        if(objCase.Case_Model__c == 'alburaq'){
            regionName += '_alburaq';
        }
        HttpRequest request = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
        //#CH10 End
        //request.setHeader('userId', customerObj.PersonEmail);
        request.setHeader('customerId', objCase.Customer_CIF__c);
        String body =  '{  "crmCaseId":'+stringApiFormat(objCase.Id)+
            ',"status": '+stringApiFormat(updatedStatus)+
            '}';
        request.setBody(body);
        HttpResponse response = EM001_ApiCalls.updateCreditCardRequestStatusApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'updateCreditCardRequestStatusApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH05 -End
    //CH06 -Begin
    public static HttpResponse blockUnblockAccountApi(HttpRequest request,Case objCase,String updatedStatus){
        PAD.debugLogBegin(CLASS_NAME, 'blockUnblockAccountApi','Parameters : [objCase] : '+ objCase);
        //request.setHeader('userId', customerObj.PersonEmail);
        request.setHeader('customerId', objCase.Customer_CIF__c);
        String type;
        if(objCase.Sub_Type__c == 'Block for debit' || objCase.Sub_Type__c == 'Unblock for debit'){
            type = 'DEBIT';
        }else if(objCase.Sub_Type__c == 'Block for credit' || objCase.Sub_Type__c == 'Unblock for credit'){
            type = 'CREDIT';
        }else if(objCase.Sub_Type__c == 'Block for both' || objCase.Sub_Type__c == 'Unblock for both'){
            type = 'BOTH';
        }
        List<String> listIbanObj = new List<String>();
        if(objCase.ac_Iban__c != null){
            for (String ibanNum : objCase.ac_Iban__c.split(',')) {
                listIbanObj.add('{ "iban" : '+stringApiFormat(ibanNum)+' }');
            }
        }
        String body =  '{  "action":'+stringApiFormat(updatedStatus)+
            ',"type": '+stringApiFormat(type)+
            ',"allAccounts": false'+
            ',"accounts": [ '+String.join(listIbanObj,',')+' ]'+
            '}';
        request.setBody(body);
        System.debug(request.getBody());
        HttpResponse response = EM001_ApiCalls.blockUnblockAccountApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'blockUnblockAccountApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    public static HttpResponse getAccountsListAllApi(HttpRequest request,Account accObj){
        PAD.debugLogBegin(CLASS_NAME, 'getAccountsListAllApi','Parameters : [accObj] : '+ accObj);
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        HttpResponse response = EM001_ApiCalls.getAccountsListAllApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'getAccountsListAllApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    public static HttpResponse getAccountHoldTransactionsApi(HttpRequest request,Account accObj,String iban){
        PAD.debugLogBegin(CLASS_NAME, 'getAccountHoldTransactionsApi','Parameters : [accObj] : '+ accObj);
        //String dateAmount = Datetime.now().format('yyyy-MM-dd');
        //request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        String body =  '{  "id":'+stringApiFormat(iban)+
            ',"offset": 0'+
            ',"pageSize": 20'+
            ',"filter": null'+
            ',"fromAmount": null'+
            ',"toAmount": null'+
            ',"fromDate": null'+
            ',"toDate": null'+
            ',"maskedCardNumber": null'+
            ',"excludeCardTransactions": null'+
            ',"targetType ": "DEBIT_CARD"'+
            '}';
        request.setBody(body);
        HttpResponse response = EM001_ApiCalls.getAccountHoldTransactionsApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'getAccountHoldTransactionsApi', '[request] body : '+request.getBody());
        PAD.debugLogEnd(CLASS_NAME, 'getAccountHoldTransactionsApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH06 -End
    //CH07 -Begin
    /* public static HttpResponse UpdateAccountForInterestRate(HttpRequest request,Account accObj){
PAD.debugLogBegin(CLASS_NAME, 'UpdateAccountForInterestRate','Parameters : [accObj] : '+ accObj);
HttpResponse response = EM001_ApiCalls.UpdateAccountForInterestRate(request,200);
PAD.debugLogEnd(CLASS_NAME, 'UpdateAccountForInterestRate', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
return response;
} */
    //CH07 -End
    //CH08 -Begin
    public static ApiConnection.Response callScheduledPlaPaymentsApi(ApiConnection con, String customerId, string requestTextJson, String regionName){
        PAD.debugLogBegin('SM001_ApiCalls', 'callScheduledPlaPaymentsApi', '');
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        HttpRequest req = con.createRequest('GET', '/api/v1/prize-linked-account/schedule', customerId ,regionName);
        //#CH02 : start
        if(lstAcc != null && lstAcc.size()>0){
            System.debug('x-canary added :'+lstAcc[0].x_canary__pc);
            if(lstAcc[0].x_canary__pc != null){
                req.setHeader('x-canary', lstAcc[0].x_canary__pc);
            }
        }
        //#CH02 : end
        req.setHeader('status', 'new,active,cancelled');
        ApiConnection.Response response = EM001_ApiCalls.callScheduledPlaPaymentsApi(con,req,null);
        return response;
    }
    public static ApiConnection.Response callScheduledPlaPaymentDetailsApi(ApiConnection con, String customerId, string scheduleId, String regionName){
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        HttpRequest req = con.createRequest('GET', '/api/v1/prize-linked-account/schedule/'+scheduleId+'/transactions', customerId,regionName);
        //#CH02 : start
        if(lstAcc != null && lstAcc.size()>0){
            System.debug('x-canary added :'+lstAcc[0].x_canary__pc);
            if(lstAcc[0].x_canary__pc != null){
                req.setHeader('x-canary', lstAcc[0].x_canary__pc);
            }
        }
        //#CH02 : end
        PAD.debugLogInfo(CLASS_NAME, 'callScheduledPlaPaymentDetailsApi', 'request Body : '+req.getBody());
        ApiConnection.Response response = EM001_ApiCalls.callScheduledPlaPaymentDetailsApi(con,req,null);
        return response;
    }
    //CH08 -End
    //CH11 -Begin
    public static HttpResponse updatePrepaidCardRequestStatusApi(HttpRequest request,Case objCase,String updatedStatus){
        PAD.debugLogBegin(CLASS_NAME, 'updatePrepaidCardRequestStatusApi','Parameters : [objCase] : '+ objCase);
        if(objCase.Customer_CIF__c != null){
            request.setHeader('customerId', objCase.Customer_CIF__c);
        }
        String embossName = objCase.cc_Name_on_the_Card__c;
        if(objCase.ppc_Approved_Name_On_The_Card__c != null){
            embossName = objCase.ppc_Approved_Name_On_The_Card__c;
        }
        Decimal fees;
        Decimal vat;
        if(objCase.ppc_Card_Holder_Age__c != null && objCase.ppc_Card_Holder_Age__c >= 21){
            fees = objCase.ppc_Adult_Issuance_Fee__c;
            vat = objCase.ppc_Adult_Issuance_VAT__c;
        }else if(objCase.ppc_Card_Holder_Age__c != null && objCase.ppc_Card_Holder_Age__c >= 7 && objCase.ppc_Card_Holder_Age__c < 21){
            fees = objCase.ppc_Minor_Issuance_Fee__c;
            vat = objCase.ppc_Minor_Issuance_VAT__c;
        }
        String feeParams = '';
        if( fees != null && vat != null ){
            feeParams = ',"fees":'+decimalApiFormat(fees) + ',"vat": '+decimalApiFormat(vat);
        }
        String cardProductConfIdParam = '';
        if( objCase.Card_Product_Configuration_Id__c != null ){
            cardProductConfIdParam = ',"cardProductConfigurationId":'+ stringApiFormat(objCase.Card_Product_Configuration_Id__c);
        }
        String body =  '{  "crmCaseId":'+stringApiFormat(objCase.Id)+
            cardProductConfIdParam+
            ',"status": '+stringApiFormat(updatedStatus)+
            ',"embossName":'+stringApiFormat(embossName)+ //toCheck :
            ',"creditLimit":0'+
            ',"targetType": "PREPAID_CARD"'+
            ',"prepaidCard":{'+
            '"mobile":'+stringApiFormat(objCase.ppc_OTP_MobileNo__c)+//toCheck
            ',"email":'+stringApiFormat(objCase.ppc_OTP_EmailAddress__c)+//toCheck
            ',"relationship":'+stringApiFormat(objCase.sc_Relationship__c)+
            ',"scanReference":'+stringApiFormat(objCase.sc_Jumio_Scan_Reference_Number__c)+
            ',"cardType":'+stringApiFormat(objCase.Card_Type__c)+
            ',"participantName":'+stringApiFormat(objCase.ppc_ParticipantName__c)+
            ',"cpr":'+stringApiFormat(objCase.sc_Card_Holder_ID_Number__c)+
            ',"cprExpiryDate":'+stringApiFormat(dateToApiDateFormat(objCase.sc_Card_Holder_ID_Expiry_Date__c))+
            ',"dob":' + stringApiFormat(dateToApiDateFormat(objCase.sc_Card_Holder_Date_of_Birth__c)) +
            feeParams+
            ',"color":'+stringApiFormat(objCase.ppc_CardDesign__c);

            // Add the same Bahrain logic as in Supplementary
if (objCase.Region_Flag__c == 'Bahrain') {
    body +=
        ',"sendOTPNotificationsTo":' + stringApiFormat(objCase.Send_OTP_Notifications_To__c) +
        ',"sendTransactionsNotificationsTo":' + stringApiFormat(objCase.Send_Transaction_Notifications_To__c) +
        ',"cardHolderMobileNumber":' + stringApiFormat(objCase.sc_Card_Holder_Mobile_No__c) +
        ',"cardHolderEmail":' + stringApiFormat(objCase.sc_Card_Holder_Email_Address__c);
}

            body += '}}';
        request.setBody(body);
        System.debug('********************* request.getBody() **********************');
        System.debug(request.getBody());
        HttpResponse response = EM001_ApiCalls.updateCreditCardRequestStatusApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'updatePrepaidCardRequestStatusApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH11 -End
    //CH12 Begin
    public static HttpResponse callValidateAccountTerminationApi(Case caseObj){
        PAD.debugLogBegin(CLASS_NAME, 'callValidateAccountTerminationApi', 'Parameters : [caseObj] : '+ caseObj);
        String regionName=caseObj.Region_Flag__c;
        System.debug( 'Region name ===> '+ regionName);
        if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
            regionName+='_alburaq';
        }
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('GET','/api/v1/customer-products/closure/validation',regionName);
        //#CH02 : start
        if(caseObj.accountId != null){
            System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
            if(caseObj.Account.x_canary__pc != null){
                request.setHeader('x-canary', caseObj.Account.x_canary__pc);
            }
        }
        //#CH02 : end
        //request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', caseObj.Customer_CIF__c);
        HttpResponse response = EM001_ApiCalls.callValidateAccountTerminationApi(request,200);
        System.debug('request==> '+request.getEndpoint());
        PAD.debugLogEnd(CLASS_NAME, 'callValidateAccountTerminationApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    public static HttpResponse smt_callCloseAccountApi(HttpRequest request,String Iban,String customerId){
        PAD.debugLogBegin(CLASS_NAME, 'callCloseAccountApi', 'Parameters : [request] : '+request+'  '+'Parameters : [Iban] :'+Iban+'Parameters : [customerId] :'+customerId);
        //toCheck
        //request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', customerId);
        System.debug('---> Request getEndpoint() --> '+request.getEndpoint() );
        String body = '{'+
            '"iban": '+stringApiFormat(Iban)+
            '}';
        request.setBody(body);
        System.debug('request body==> '+request.getBody());
        HttpResponse response = EM001_ApiCalls.callCloseAccountApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'callCloseAccountApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH12 END
    //CH14 -Start
    public static HttpResponse PeriodicReviewBlockProductsApi(HttpRequest request,Account accObj,Case caseObj){
        Boolean BlockAtmWithdrawls;
        Boolean BlockDebitCards;
        Boolean BlockCreditCards;
        Boolean BlockAccounts;
        PAD.debugLogBegin(CLASS_NAME, 'PeriodicReviewBlockProductsApi', 'Parameters : [caseObj] : '+ caseObj);
        //request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', caseObj.Customer_CIF__c);
        if(caseObj.Sub_Status__c == 'Overdue Stage 2')
        {
            BlockAtmWithdrawls =true;
        }
        if(caseObj.Sub_Status__c == 'Overdue Stage 3')
        {
            BlockDebitCards =true;
        }
        if(caseObj.Sub_Status__c == 'Overdue Stage 4')
        {
            BlockCreditCards=true;
            BlockAccounts =true;
        }
        String body = '{  "atmWithdrawls":'+BlockAtmWithdrawls+
            ',"debitCards": '+BlockDebitCards+
            ',"creditCards": '+BlockCreditCards+
            ',"accounts": '+BlockAccounts+
            '}';
        request.setBody(body);
        request.setTimeout(70000);
        System.debug('Request Body for Blocking:'+request.getBody());
        HttpResponse response = EM001_ApiCalls.PeriodicReviewBlockProductsApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'PeriodicReviewBlockProductsApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    public static HttpResponse PeriodicReviewUnblockProductsApi(HttpRequest request,Account acc){
        PAD.debugLogBegin(CLASS_NAME, 'PeriodicReviewUnblockProductsApi', 'Parameters : [acc] : '+ acc);
        //ApiConnection con = new ApiConnection();
        //HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/periodic-review/productBlocks',acc.Region_Flag__pc);
        request.setHeader('userId',acc.PersonEmail);
        request.setHeader('customerId',acc.CIF__pc);
        String body = '{  "atmWithdrawls":true'+
            ',"debitCards": true'+
            ',"creditCards": true'+
            ',"accounts":true'+
            '}';
        request.setBody(body);
        request.setTimeout(70000);
        System.debug('Request Body for Un-Blocking:'+request.getBody());
        HttpResponse response = EM001_ApiCalls.PeriodicReviewUnblockProductsApi(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'PeriodicReviewBlockProductsApi', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH14 -End
    //CH17 -Start
    public static HttpResponse updateCustomerDetailsAPI(HttpRequest request,String Body){
        PAD.debugLogBegin(CLASS_NAME, 'updateCustomerDetailsAPI', 'Parameters : Body : '+ Body);
        request.setBody(body);
        HttpResponse response = EM001_ApiCalls.updateCustomerDetailsAPI(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'updateCustomerDetailsAPI', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
    }
    //CH17 -End
    //CH20 -Start
    public static HttpResponse CustomerTotalBalanceAPI(HttpRequest request, Account accObj){
        PAD.debugLogBegin(CLASS_NAME, 'CustomerTotalBalanceAPI', 'Parameters : [accObj] : '+ accObj);
        //request.setHeader('userId', customerObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        System.debug('request==>'+Request.getEndpoint());
        HttpResponse response = EM001_ApiCalls.CustomerTotalBalanceAPI(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'CustomerTotalBalanceAPI', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
        //CH20 -End
    }
    //CH21 -Start
    public static HttpResponse MoEngageDeleteAPI(HttpRequest request, Account accObj){
        PAD.debugLogBegin(CLASS_NAME, 'MoEngageDeleteAPI', 'Parameters : [accObj] : '+ accObj);
        request.setHeader('customerId', accObj.CIF__pc);
        String body = '{"cif": "'+accObj.CIF__pc +'"}';
        request.setBody(body);
        System.debug('request==>'+Request.getEndpoint());
        HttpResponse response = EM001_ApiCalls.MoEngageDeleteAPI(request,200);
        PAD.debugLogEnd(CLASS_NAME, 'MoEngageDeleteAPI', '[response] code : ' + response.getStatusCode() +' ,body : '+response.getBody());
        return response;
        //CH21 -End
    }
    //CH23 -Start
    public static ApiConnection.Response callBondSukukStatementsApi(ApiConnection con, String customerId, String regionName){
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        PAD.debugLogBegin('SM001_ApiCalls', 'callBondStatementsApi', '');
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements/bonds', customerId ,regionName);
        //#CH02 : start
        if(lstAcc != null){
            System.debug('x-canary added :'+lstAcc[0].x_canary__pc);
            if(lstAcc[0].x_canary__pc != null){
                req.setHeader('x-canary', lstAcc[0].x_canary__pc);
            }
        }
        //#CH02 : end
        ApiConnection.Response response = EM001_ApiCalls.callBondSukukStatementsApi(con,req,null);
        return response;
    }
    public static ApiConnection.Response callBondSukukStatementsDetailsApi(ApiConnection con, String customerId, String regionName,string requestTextJson){
        List<Account> lstAcc = [SELECT Id,Region_Flag__c,Subscription_Model__pc,x_canary__pc FROM Account WHERE CIF__pc = :customerId ];
        final HttpRequest req = con.createRequest('POST', '/api/v1/statements/bonds/details', customerId,regionName);
        //#CH02 : start
        if(lstAcc != null && lstAcc.size()>0){
            System.debug('x-canary added :'+lstAcc[0].x_canary__pc);
            if(lstAcc[0].x_canary__pc != null){
                req.setHeader('x-canary', lstAcc[0].x_canary__pc);
            }
        }
        //#CH02 : end
        req.setBody(requestTextJson);
        PAD.debugLogInfo(CLASS_NAME, 'callAccountStatementsDetailsApi', 'request Body : '+req.getBody());
        ApiConnection.Response response = EM001_ApiCalls.callAccountStatementsDetailsApi(con,req,null);
        return response;
    }
    //CH23 -End
}