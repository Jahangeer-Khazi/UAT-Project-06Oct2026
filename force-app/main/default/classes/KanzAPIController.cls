/**
 * @description       :
 * @author            : Jose Caballero
 * @group             :
 * @last modified on  : 18/10/2021
 * @last modified by  : Jose Caballero -> jose.caballero@s4g.es
 * @History           : #CH01 x-canary on header http request
 *   		  		    #CH02# #Jahangeer Mohammed #07-05-2024# Added logic for Audit History Enhancements(NBA-9027)
 *   		  		    #CH04# #Aniss Mbarki# #08-01-2025# Added Logic for PLA - Double Chances - CRM Requirements (NBA-12870)
 *                      #CH05#: #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705)

**/
public with sharing class KanzAPIController {
    @TestVisible // overwrite instance to provide custom connection in test class
    //private static ApiConnection2 con = new ApiConnection2();
    private static ApiConnection con= new ApiConnection();
    @TestVisible // overwrite instance to provide custom DAO in test class
    private static KanzAPIController dao = new KanzAPIController();
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadPrizeLinkedAccount(final String customerId, String caseId, String regionName) {
        System.debug('###regionName'+regionName);
        final String path = '/api/v1/prize-linked-account?';
        final HttpRequest req = con.createRequest('GET', path, customerId, regionName);
        
        //#CH01 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH01 : end

        System_Action__c action;
        ApiConnection.Response response;
        Id idToCheck = (Id) caseId;
        if (idToCheck.getSObjectType().getDescribe().getName() == 'Case') {
            action = SystemActionLoggerWithCase.initiateLogRequest(caseId, req, 'Kanz API Request');
            response = con.makeCallout(req, action);
        } else {
            response = con.makeCallout(req);
        }
        System.debug('loadAccountTransactions>>>>>' + JSON.serializePretty(response));
        return response;
    }

    /*
        Get Kanz Account transaction details with account type only PAFD.
     */
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadKanzAccountTransactions(final String customerId,final String searchParametersJson,final String regionName) {
         System.debug(' Customer ID ' +customerId+ 'search parameter ' +searchParametersJson);

        // setup default response with no data
        ApiConnection.Response response = new ApiConnection.Response();
        response.isSuccess = true;
        response.responseData = new List<Object>();
        final String path = '/api/v1/transactions?';
        final HttpRequest req = con.createRequest('POST', path, customerId, regionName);
        
        //#CH01 : start
        List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE CIF__pc =:customerId];
        if(accs!= null && accs.size()>0){
            System.debug('x-canary added :'+accs.get(0).x_canary__pc);
            if(accs.get(0).x_canary__pc != null){
                req.setHeader('x-canary', accs.get(0).x_canary__pc);
            }
        }
        //#CH01 : end

        //req.setTimeout(30000);
        req.setTimeout(120000);
        req.setBody(searchParametersJson);
        System.debug('Request Body:'+req.getBody());
        response = con.makeCallout(req);
        System.debug('loadAccountTransactions>>>>>' + JSON.serializePretty(response));

        Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        if(responseData != null) {
            Object[] transactions = (Object[]) responseData.get('transactions');
            System.debug('Transaction Length after getting response:' + transactions.size());
            //if there are requried clean data, it means segment is staff and view staff = false
            //we will filter staff transaction from it
            if (response.isSuccess && null != response.responseData) {
                response.recordLength = transactions.size();
                //if view staff = true, we will display all transactions
              //  if (SensitiveDataCleaner.isAllowedViewStaffData(customerId)) {
                    response.responseData = transactions;
              //  }
                //if view staff = false, we will display only transaction during Segment != staff
            //    else {
                  // List<Map<String, Datetime>> lstBanedDate = SensitiveDataCleaner.getStaffHideTransactionDate(customerId);
                   //response.responseData = SensitiveDataCleaner.filterBannedDate('transactionDate', lstBanedDate, transactions);
              //  }
            }
        }
        //ApiConnection2.Response response = BankAccountController.loadAccountTransactions(customerId, searchParametersJson, regionName);
        return response;
    }
    //CH02: Start
     @AuraEnabled
    public static String createAuditRecordForKanzDetails(String accCIF, String accIBAN){
        
        System.debug('Account CIF:'+accCIF);
        System.debug('IBAN Number:'+accIBAN);
        
        Customer_Pages_Audit_Trail__c cusAudit = new Customer_Pages_Audit_Trail__c();
        cusAudit.Customer_CIF__c = accCIF;
        cusAudit.User_Action__c = 'Viewed';
        cusAudit.User__c = userInfo.getUserId();
        cusAudit.Page_Name__c = 'Kanz Detail';
        cusAudit.Kanz_IBAN__c = accIBAN;
        insert cusAudit;
        
        return cusAudit.id;
    }
    //CH02: END
    @AuraEnabled(cacheable=false)
    public static Boolean loadDataSensitiveData(final String customerId) {
        return SensitiveDataCleaner.isAllowedViewStaffData(customerId);
    }

    //CH04 : Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadAccountDetails(final String customerId, final String accountId, String regionName) {
        return BankAccountController.loadAccountDetails(customerId,accountId,regionName);
    }
    //CH04 END

    // CH05 start 
    @AuraEnabled
    public static Boolean getJordanVisibility(String customerId) {
        return SensitiveDataCleaner.loadIsDataCleaningRequired(customerId);
    }
    // CH05 end
}