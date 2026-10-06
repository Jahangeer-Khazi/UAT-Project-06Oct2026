/**
 * @author Wissal benqezza
 * @date Création 22/03/2022
 * @date Modification
 * @description :ALL the functions used in LTNG019_ReleaseHoldAmountCaseRequest , LTNG019_ReleaseHoldAmount
 *               and LTNG020_ReleaseHoldAmount components 
 * @history Modifications :   
 *       #CH01 : #D&A Team #24-06-2022# Added alburaq logic.
 *       #CH02 : #Imane Tsioucha# #15-01-2024# add x-canary header
 */
public class LTNG019_ReleaseHoldAmountController {
    private static String CLASS_NAME = LTNG019_ReleaseHoldAmountController.class.getName();
// To get the id of the record type : Account Hold
    @AuraEnabled
	public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('db_AccountHold').getRecordTypeId();
    }
      //To get the list of accounts to Hold the amount from via Api
    @AuraEnabled
	public static List<AccountToHoldAmountDetails> getAccountToHoldAmountViaApi(String accountId,String caseModel) {

        PAD.debugLogBegin(CLASS_NAME, 'getAccountToHoldAmountViaApi', 'Parameters : [accountId] : '+accountId );

        List<AccountToHoldAmountDetails> accToHoldAmount = new List<AccountToHoldAmountDetails>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,x_canary__pc,Region_Flag__c FROM Account WHERE Id=: accountId];
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 Start
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/accounts/all',regionName);

             //#CH02 : start
             if(accObj!= null ){
                 System.debug('x-canary added :'+accObj.x_canary__pc);
                 if(accObj.x_canary__pc != null){
                     request.setHeader('x-canary', accObj.x_canary__pc);
                 }
             }
             //#CH02 : end
             
 
            System.debug('request==>'+Request.getEndpoint());
            //toDo : use api 
            HttpResponse response = SM001_ApiCalls.getAccountsListAllApi(request,accObj);

             //fake responsE
            //https://bank-abc.atlassian.net/wiki/spaces/NA/pages/2215772314/Accounts+List+All+API+private
            //HttpResponse response = new HttpResponse();
            // Create Manually json response For Test Class
            //String body = '{"meta": {"code": "ACCO-1000","message": "Accounts list for customer [8610001] has been retrieved successfully."},"data": {"allowAccountCreation": true,"accounts": [{"id": "BH97ABCO86100019101101","customerId": "8610001","alias": "Neo BANK Saving Account 1","productType": "account","productName": "Neo BANK Saving Account 1","category1": "","category2": "","detailsExist": true,"defaultAccount": true,"account": {"number": "861000191011","currency": {"code": "USD","decimalPlaces": "2"},"iban": "BH97ABCO86100019101101","availableBalance": 586828,"ledgerBalance": 10090344,"startDate": "2019-02-08","endDate": "2019-02-10","overdraftLimit": 0,"overdraftExpiryDate": "2019-05-03","overdraftAvailableLimit": 0,"paymentsAllowed": true,"creditInterestFrequencyCode": "200001","creditInterestFrequency": "MONTHLY","debitInterestFrequencyCode": "200001","debitInterestFrequency": "MONTHLY","creditGlAccount": "2011204","creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","debitGlAccount": "2011204","debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","minimumBalance": 0,"maximumBalance": 0,"valueBalance": 10090344,"holdAmount": 9503516,"overdraftReviewDate": "1957-01-01"}},{"id": "BH32ABCO86100019101301","customerId": "8610001","alias": "Neo BANK Current Account 1","productType": "account","productName": "Neo BANK Current Account 1","category1": "","category2": "","detailsExist": true,"defaultAccount": false,"account": {"number": "861000191013","currency": {"code": "USD","decimalPlaces": "2"},"iban": "BH32ABCO86100019101301","availableBalance": 179911,"ledgerBalance": 179911,"startDate": "2019-02-08","endDate": "2019-02-10","overdraftLimit": 0,"overdraftExpiryDate": "2019-05-03","overdraftAvailableLimit": 0,"paymentsAllowed": true,"creditInterestFrequencyCode": "200001","creditInterestFrequency": "MONTHLY","debitInterestFrequencyCode": "200001","debitInterestFrequency": "MONTHLY","creditGlAccount": "2011204","creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","debitGlAccount": "2011204","debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR","minimumBalance": 0,"maximumBalance": 0,"valueBalance": 179911,"holdAmount": 0,"overdraftReviewDate": "1957-01-01", "accountType":"KANZ"}}]}}';
            //response.setStatus('OK');
            //response.setStatusCode(200);
            //response.setBody(body);
            //response.setHeader('Content-Type', 'application/json');

            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountList = (List<Object>)m1.get('accounts'); 
                
                System.debug('accountList --->'+accountList);
                
                for(Object accountDetails : accountList){
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    
                    System.debug('mapaccountConfig --->'+mapaccountConfig);
                    System.debug('mapaccountDetails --->'+mapaccountDetails);
                    
                    String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');
                    String type = String.valueOf(mapaccountDetails.get('templateId'));
                    
                    System.debug('type --->'+type);

                    accToHoldAmount.add( new AccountToHoldAmountDetails(
                        String.valueOf(mapaccountDetails.get('iban')) , 
                        accCurrency,
                       String.valueOf(mapaccountDetails.get('accountType')),
                        type
                    ));
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToHoldAmountViaApi', '[accToHoldAmount] : ' + accToHoldAmount );
        System.debug('accToHoldAmount --->'+accToHoldAmount);
        return accToHoldAmount;
    }
   //To get the transaction number and other additional iformations for the iban selected 
    @AuraEnabled
	public static List<AccountHoldTransaction> getAccDetailsViaApi(String iban,String accountId,String caseModel) {

        PAD.debugLogBegin(CLASS_NAME, 'getAccDetailsViaApi', 'Parameters : [iban] : '+iban );
        System.debug('------------accountId-----'+accountId);
        List<AccountHoldTransaction> accToHoldTrans = new List<AccountHoldTransaction>();
        
        if(iban != null && iban != '' && accountId != null && accountId != ''){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__pc,x_canary__pc FROM Account WHERE Id=: accountId];
            //#CH01 Start
            String regionName = accObj.Region_Flag__pc;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
             //#CH01 END
             //fake response
             //todo : ... !!
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('POST','/api/v1/transactions-enrichment/hold',regionName);
              //HttpRequest request = con.createRequest('POST','/api/v1/transactions',accObj.CIF__pc,regionName);
            request.setBody('{"id": "'+iban+'"}');  
            request.setHeader('customerId',accObj.CIF__pc);
            //request.setBody('{"id": "'+iban+'","status": "pending","pageSize": 20,"offSet": 0}');
             //#CH02 : start
             if(accObj!= null ){
                 System.debug('x-canary added :'+accObj.x_canary__pc);
                 if(accObj.x_canary__pc != null){
                     request.setHeader('x-canary', accObj.x_canary__pc);
                 }
             }
             //#CH02 : end
             System.debug('Request MAX ' + request);
            HttpResponse response = SM001_ApiCalls.getAccountHoldTransactionsApi(request,accObj,iban);

            //https://bank-abc.atlassian.net/wiki/spaces/NA/pages/2998665262/Get+Account+Hold+Transactions+API
            //HttpResponse response = new HttpResponse();
            // Create Manually json response For Test Class
            //String body = '{"meta": {"code": "TRAN-1009","message": "Transaction Details for Account Id has been retrieved successfully."},"data": {"transactions": [{"id": "BH09ABCO00929029882","holdDate": "2019-01-01","holdExpiryDate": "2019-08-01","holdType": "Release Debit Card Transaction","holdCurrency": "","holdAmount": "100","holdReferenceNumber": "1254555","previousBalance": "2019-01-31","currentBalance": "","generateAdvice": "completed","holdDescription1":"","holdDescription2":"","holdDescription3":"","holdDescription4":"","holdDescription5":"","holdDescription6":""}]}}';
            //response.setStatus('OK');
            //response.setStatusCode(200);
            //response.setBody(body);
            //response.setHeader('Content-Type', 'application/json');

            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Acc Transaction API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                System.debug('Body '+response.getBody());
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> transc = (List<Object>)m1.get('transactions'); 
                System.debug('transc ' + transc);
                for(Object transcDetails : transc){
                    System.debug('transcDetails ' + JSON.serializePretty(transcDetails));
                    Map<String,Object> maptranscDetails = (Map<String, Object>)transcDetails;

                    //accToHoldTrans.holdReferenceNumber = String.valueOf(maptranscDetails.get('holdReferenceNumber')) ;
                    //accToHoldTrans.holdAmount =  String.valueOf(maptranscDetails.get('holdAmount')) ;
                    //accToHoldTrans.holdDate =  String.valueOf(maptranscDetails.get('holdDate')) ;
                    //accToHoldTrans.holdExpiryDate =  String.valueOf(maptranscDetails.get('holdExpiryDate')) ;

                   accToHoldTrans.add( new AccountHoldTransaction(
                         String.valueOf(maptranscDetails.get('id')), 
                         String.valueOf(maptranscDetails.get('holdReferenceNumber')), 
                         String.valueOf(maptranscDetails.get('holdAmount')),
                         String.valueOf(maptranscDetails.get('holdDate')) ,
                         String.valueOf(maptranscDetails.get('holdExpiryDate')),
                       String.valueOf(maptranscDetails.get('holdType'))
                       
                    ));
                    //break;
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToHoldAmountViaApi', '[accToHoldTrans] : ' + accToHoldTrans );
        
        return accToHoldTrans;
    }
   
     public class AccountToHoldAmountDetails {
        @AuraEnabled 
        public String iban {get; set;}

        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}

        @AuraEnabled 
        public String ac_type {get; set;}
         
        @AuraEnabled 
        public String ac_template {get; set;}
        
        public AccountToHoldAmountDetails(String iban,String ac_currency,String ac_type, String ac_template){
            this.iban = iban;
            this.ac_currency = ac_currency;
            
            if(ac_template == 'HY') {
                this.ac_label = iban +' - '+ ac_currency +' - '+' HYSA';
            } else {
                this.ac_label = iban +' - '+ ac_currency;
            }
            
            this.ac_type = ac_type;
        }
    }

     public class AccountHoldTransaction {
        
        @AuraEnabled 
        public String refId {get; set;}

        @AuraEnabled 
        public String holdReferenceNumber {get; set;}
         
        @AuraEnabled 
        public String HoldId {get; set;}

        @AuraEnabled 
        public String holdAmount {get; set;}
        
        @AuraEnabled 
        public String holdDate {get; set;}

        @AuraEnabled 
        public String holdExpiryDate {get; set;}
         
          @AuraEnabled 
        public String HoldType {get; set;}
        
        public AccountHoldTransaction(String refId,String holdReferenceNumber,String holdAmount, String holdDate , String holdExpiryDate,String HoldType){ 
            this.HoldId = refId;
            this.refId = holdReferenceNumber;
            this.holdReferenceNumber = holdReferenceNumber;
            this.holdAmount = holdAmount;
            this.holdDate = holdDate;
            this.holdExpiryDate = holdExpiryDate; 
            this.HoldType = HoldType;
        }
    }
    
     @AuraEnabled
    public static List<AllAccountList> getAllAccountViaApi(String accountId,String caseModel) {
        
        PAD.debugLogBegin(CLASS_NAME, 'getAccountToBlockUnblockViaApi', 'Parameters : [accountId] : '+accountId+' , '+caseModel );//CH01
        
        List<AllAccountList> retriveAccountList = new List<AllAccountList>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c FROM Account WHERE Id=: accountId];
            
            //#CH01 Start
            String regionName = accObj.Region_Flag__c;//CH03
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 End
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/accounts/all',regionName);//CH03
            
            //#CH02 : start
            List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE Id=: accountId];
            if(accs!= null && accs.size()>0){
                System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                if(accs.get(0).x_canary__pc != null){
                    request.setHeader('x-canary', accs.get(0).x_canary__pc);
                }
            }
            //#CH02 : end
            
            System.debug('request==>'+Request.getEndpoint());
            //toDo : use api 
            HttpResponse response = SM001_ApiCalls.getAccountsListAllApi(request,accObj);         
            
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountList = (List<Object>)m1.get('accounts'); 
                for(Object accountDetails : accountList){
                    System.debug('accountDetails'+JSON.serializePretty(accountDetails));
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');
                    
                    retriveAccountList.add( new AllAccountList(
                        String.valueOf(mapaccountDetails.get('iban')) , 
                        accCurrency,
                        String.valueOf(mapaccountDetails.get('accountType'))
                    ));
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToBlockUnblockViaApi', '[accToBlockUnblock] : ' + retriveAccountList );
        
        return retriveAccountList;
    }
      
    public class AllAccountList {
        @AuraEnabled 
        public String iban {get; set;}
        
        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_type {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}
        
        public AllAccountList(String iban,String ac_currency,String ac_type){
            this.iban = iban;
            this.ac_currency = ac_currency;
            this.ac_type = ac_type;
            this.ac_label = iban +' - '+ ac_currency+' - '+ ac_type;
        }
    }
    
     // Get available balance from the account
    @InvocableMethod(label='Place Release Hold Request' description='The purpose of this service is to place or release hold request' )
    public static List<String> processPlaceReleaseHold(List<String> caseId){
        /*List<String>ReleaseHold= New List<String>();
        List<String>PlaceHold= New List<String>();
        For( Case caseObj :[SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,type,Operation_Result__c,Cc_Checker_result__c,OwnerId, Origin,bs_Investment_ID__c FROM Case WHERE Id IN:caseId]){
            if(caseObj.Type=='Place Hold'){
                PlaceHold.add(caseObj.Id);
            }
            if(caseObj.Type=='Release Hold'){
                ReleaseHold.add(caseObj.Id);
            }
        }
        System.debug('Result PlaceHold ' + PlaceHold);
        System.debug('Result ReleaseHold ' + ReleaseHold);
        if(!PlaceHold.isEmpty()){
            processPlaceHold(PlaceHold);
        }
        if(!ReleaseHold.isEmpty()){
            processReleaseHold(ReleaseHold);
        }*/
        
        /*Set<String> caseIds = new Set<String>(caseId);
        System.enqueueJob(
            new PlaceHoldQueueable(caseIds)
        );*/
        return null;
    }
    
    @future(callout=true)
    public static void  processPlaceHold(List<String> caseId) {
    
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<String>accntID = New List<String>();
        List<Case> caseRec= New List<Case>();
        if(!caseId.isEmpty()){
            
            Case caseObj = [SELECT Id,Place_hold_on_all_Accounts__c,Customer_CIF__c,AccountId,Case_Model__c,Region_Flag__c,account.CIF__pc,BUA_AccountsInformation__c,RHA_HoldExpiryDate__c,RHA_HoldAmount__c,Hold_Description__c, Account.x_canary__pc FROM Case WHERE Id IN:caseId LIMIT 1];
            
            String accountBody = '';
            if(!String.isBlank(caseObj.BUA_AccountsInformation__c)){
                //Sample account information, it contains IBAN,Currency and Account with comma separate fields
                //BH06ABCO91002011980492 - BHD - CUSTOMER_ACCOUNT,BH60ABCO91002011994458 - GBP - CUSTOMER_ACCOUNT
                
                String[] accountList = caseObj.BUA_AccountsInformation__c.split(',');
                
                for(String accountStr : accountList){
                    String[] acccountDetails = accountStr.split('-');
                    String ibanNumber = acccountDetails[0].trim();
                    String accCurrency = acccountDetails[1].trim();
                    Date todayDate = Date.today();
                    String fromDate = DateTime.newInstance(todayDate,Time.newInstance(0,0,0,0)).formatGmt('yyyy-MM-dd');
                    if(!caseObj.Place_hold_on_all_Accounts__c){
                        if(accountBody == ''){
                            accountBody = '{"iban":"'+ ibanNumber +'","amount":"'+ caseObj.RHA_HoldAmount__c +'","currency":"'+ accCurrency +'","fromdate":"'+ fromDate +'","toDate":"'+ caseObj.RHA_HoldExpiryDate__c +'","description":"'+ caseObj.Hold_Description__c +'"}';    
                        }
                        else {
                            accountBody = accountBody + ',' + '{"iban":"'+ ibanNumber +'","amount":"'+ caseObj.RHA_HoldAmount__c +'","currency":"'+ accCurrency +'","fromdate":"'+ fromDate +'","toDate":"'+ caseObj.RHA_HoldExpiryDate__c +'","description":"'+ caseObj.Hold_Description__c +'"}';    
                        }    
                    }
                    else {
                        accountBody = '{"amount":"'+ caseObj.RHA_HoldAmount__c +'","fromdate":"'+ fromDate +'","toDate":"'+ caseObj.RHA_HoldExpiryDate__c +'","description":"'+ caseObj.Hold_Description__c +'"}';
                    }
                }
            }
            accountBody = '{"allAccounts" : '+ caseObj.Place_hold_on_all_Accounts__c +',"accounts":[' + accountBody + ']}';
            
            String regionName = caseObj.Region_Flag__c;
            if(caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ApiConnection con = new ApiConnection();
            request = con.createRequest('POST','/api/v1/transactions/account/hold',caseObj.account.CIF__pc,regionName);
            request.setBody(accountBody);
            if(caseObj.Account.x_canary__pc != null){
                request.setHeader('x-canary', caseObj.Account.x_canary__pc);
            }
            System.debug('body ' + request.getBody());
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            System.debug('response body ' + response.getBody());
            if (response.getStatusCode() != 200) {
                System.debug('Api Error.');
                createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'POST',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Account Hold Request', 'Account Hold Request');
            	caseObj.Last_Api_Call_Status__c = 'Failed';
                update caseObj;
            }
            else {
                System.debug('API call successfully done.');
                Map<String,Object> apiResponseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> responseDataMap = (Map<String,Object>)apiResponseMap.get('data');
                String referenceHold = String.valueOf(responseDataMap.get('holdReference'));
                System.debug('referenceHold ' + referenceHold);
                //Updating Hold reference number.
                caseObj.ccol_Hold_Reference_Number__c = referenceHold;
                caseObj.Status = 'Closed';
                caseObj.Last_Api_Call_Status__c = 'Success';
                update caseObj;
            }
        }
    }
    
    
    @future(callout=true)
    public static void  processPlaceHold_old(List<String> caseId) {
        String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<String>accntID = New List<String>();
        List<Case> caseRec= New List<Case>();
        if(!caseId.isEmpty()){
            for(Case caseObj: [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Instrument__c,Customer_CIF__c,bs_Investment_ID__c, Account.x_canary__pc FROM Case WHERE Id IN:caseId]){
                CaseModel = caseObj.Case_Model__c;
                String regionName = caseObj.Region_Flag__c;
                if(caseModel == 'alburaq'){
                    regionName += '_alburaq';
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                ApiConnection con = new ApiConnection();
                // request = con.createRequest('GET','/api/v1/bond/investments?customerId='+caseObj.Customer_CIF__c,regionName);
                request = con.createRequest('GET','/api/v1/bond/investments/'+caseObj.bs_Investment_ID__c,regionName);
                request.setHeader('customerId',caseObj.Customer_CIF__c);
                
            if(caseObj!= null){
                System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                if(caseObj.Account.x_canary__pc != null){
                request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                }
            }
                request.setTimeout(120000);
                HttpResponse response = http.send(request);            
                if (response.getStatusCode() != 200) 
                {   
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                    
                    
                } else {
                    
                }
            }
        }
    }
    @future(callout=true)
    public static void  processReleaseHold(List<String> caseId) {
          String CaseModel;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> casesToUpdateList=new List<Case>();
        List<String>accntID = New List<String>();
        List<Case> caseRec= New List<Case>();
        if(!caseId.isEmpty()){
            for(Case caseObj: [SELECT Id,account.CIF__pc,Case_Model__c,Region_Flag__c,accountId,bs_Total_Bid_Amount__c,bs_Instrument__c,Customer_CIF__c,bs_Investment_ID__c, Account.x_canary__pc FROM Case WHERE Id IN:caseId]){
                CaseModel = caseObj.Case_Model__c;
                String regionName = caseObj.Region_Flag__c;
                if(caseModel == 'alburaq'){
                    regionName += '_alburaq';
                }
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                ApiConnection con = new ApiConnection();
                // request = con.createRequest('GET','/api/v1/bond/investments?customerId='+caseObj.Customer_CIF__c,regionName);
                request = con.createRequest('GET','/api/v1/bond/investments/'+caseObj.bs_Investment_ID__c,regionName);
                request.setHeader('customerId',caseObj.Customer_CIF__c);
                
            if(caseObj!= null){
                System.debug('x-canary added :'+caseObj.Account.x_canary__pc);
                if(caseObj.Account.x_canary__pc != null){
                request.setHeader('x-canary', caseObj.Account.x_canary__pc);
                }
            }
                request.setTimeout(120000);
                HttpResponse response = http.send(request);            
                if (response.getStatusCode() != 200) 
                {   
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                    lstSA = createSystemAction(request.getBody(),response.getBody(),request.getEndpoint(),'GET',caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 'Bond Sukuk Buy Request', 'Bond Sukuk Buy Request');
                    
                    
                } else {
                    
                }
            }
        }
    }
      public static List<System_Action__c> createSystemAction(final String reqBody, final String resBody, final String path, Final String method, Final Id CaseId, Final String custId, Final Id AccId, Integer statCode, Final String strAction, Final String strType) {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        System_Action__c action = new System_Action__c();
        action.Account_Number__c = custId;
        action.Action__c = strAction;
        //  action.Card_Number__c = objCase.cc_Requested_Card_Type__c;
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
}