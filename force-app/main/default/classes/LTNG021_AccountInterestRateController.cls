/**
 * @author Wissal benqezza
 * @date Création 22/04/2022
 * @date Modification
 * @description :
 * @history Modifications : 
 *          #CH01 : #D&A Team #24-06-2022# Added alburaq logic.
 */
public with sharing class LTNG021_AccountInterestRateController {
    private static String CLASS_NAME = LTNG021_AccountInterestRateController.class.getName();

    @AuraEnabled
    
	public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('AIR_AccountInterestRate').getRecordTypeId();
    }

    @AuraEnabled
   
	public static List<AccountForInterestDetails> getAccountForInterestRateViaApi(String accountId,String caseModel) {//CH01

        PAD.debugLogBegin(CLASS_NAME, 'getAccountForInterestRateViaApi', 'Parameters : [accountId] : '+accountId );

        List<AccountForInterestDetails> accForInterest = new List<AccountForInterestDetails>();
        if(accountId != null && accountId != '' ){
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c FROM Account WHERE Id=: accountId];
             //#CH01 Start
            String regionName = accObj.Region_Flag__c;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 END
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('GET','/api/v1/accounts/compatibility',regionName);
            //toDo : use api 
            //HttpResponse response = SM001_ApiCalls.UpdateAccountForInterestRate(request,accObj);

             //fake responsE
            //https://bank-abc.atlassian.net/wiki/spaces/RTS/pages/3013312617/Interest+Rate+Management+CRM+-+Account+Interest+Rate+Update
            HttpResponse response = new HttpResponse();
            // Create Manually json response For Test Class
            String body = '{  "meta": {    "code": "ACCO-1000",    "message": "Accounts list for customer [8610001] has been retrieved successfully."  },  "data": {    "allowAccountCreation": true,    "totalBalance": 100,    "totalBalanceCurrency": {      "code": "USD",      "decimalPlaces": 3    },  "accounts": [      {        "id": "BH97ABCO86100019101101",        "customerId": "8610001",        "alias": "Neo BANK Saving Account 1",        "productType": "account",        "productName": "Neo BANK Saving Account 1",        "category1": "",        "category2": "",        "detailsExist": true,        "defaultAccount": true,        "account": {          "number": "861000191011",          "currency": {            "code": "USD",            "decimalPlaces": "2"          },          "iban": "BH97ABCO86100019101101",          "availableBalance": 586828,          "ledgerBalance": 10090344,          "startDate": "2019-02-08",          "endDate": "2019-02-10",          "overdraftLimit": 0,          "overdraftExpiryDate": "2019-05-03",          "overdraftAvailableLimit": 0,          "paymentsAllowed": true,          "creditInterestFrequencyCode": "200001",          "creditInterestFrequency": "MONTHLY",          "debitInterestFrequencyCode": "200001",          "debitInterestFrequency": "MONTHLY",          "creditGlAccount": "2011204",          "creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR",          "debitGlAccount": "2011204",          "debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR",          "minimumBalance": 0,          "maximumBalance": 0,          "valueBalance": 10090344,          "holdAmount": 9503516,          "overdraftReviewDate": "1957-01-01",          "currentInterestRate": 1.5,          "defaultInterestRate": 0.5,          "accountType": "CUSTOMER_ACCOUNT"      }      },      {        "id": "BH32ABCO86100019101301",        "customerId": "8610001",        "alias": "Neo BANK Current Account 1",        "productType": "account",        "productName": "Neo BANK Current Account 1",        "category1": "",        "category2": "",        "detailsExist": true,        "defaultAccount": false,        "account": {          "number": "861000191013",          "currency": {            "code": "USD",            "decimalPlaces": "2"          },          "iban": "BH32ABCO86100019101301",          "availableBalance": 179911,          "ledgerBalance": 179911,          "startDate": "2019-02-08",          "endDate": "2019-02-10",          "overdraftLimit": 0,          "overdraftExpiryDate": "2019-05-03",          "overdraftAvailableLimit": 0,          "paymentsAllowed": true,          "creditInterestFrequencyCode": "200001",          "creditInterestFrequency": "MONTHLY",          "debitInterestFrequencyCode": "200001",          "debitInterestFrequency": "MONTHLY",          "creditGlAccount": "2011204",          "creditGlAccountDescription": "LIAB CURRENT ACCT - REGULAR",          "debitGlAccount": "2011204",          "debitGlAccountDescription": "LIAB CURRENT ACCT - REGULAR",          "minimumBalance": 0,          "maximumBalance": 0,          "valueBalance": 179911,          "holdAmount": 0,          "overdraftReviewDate": "1957-01-01",          "currentInterestRate": 1.5,          "defaultInterestRate": 0.5,          "accountType": "KENZ"        }      }      ]}}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');

            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountList = (List<Object>)m1.get('accounts');
                Double totalBalance =(Double) m1.get('totalBalance'); 
                for(Object accountDetails : accountList){
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');

                    accForInterest.add( new AccountForInterestDetails(
                        String.valueOf(mapaccountDetails.get('iban')) , 
                        accCurrency,
                       String.valueOf(mapaccountDetails.get('accountType')),
                        totalBalance,
                        String.valueOf(mapaccountDetails.get('currentInterestRate')),
                        String.valueOf(mapaccountDetails.get('defaultInterestRate'))
                    ));
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountForInterestRateViaApi', '[accForInterest] : ' + accForInterest );
        
        return accForInterest;
    }
    
   @InvocableMethod(label='Update Account Details API' description='The purpose of this service is to Update Account Details API' callout=true )
    public static  List<String> UpdateAccountDetailsAPIFromFlow(List<Id> caseIds)
        
    {   //call future method  
        UpdateAccountDetailsAPI(new Set<Id>(caseIds));
        return null;
        }
     @future(callout=true)
    public static void UpdateAccountDetailsAPI(Set<Id> caseIds){
        System.debug('Update Account Details API*****************************');
        System.debug(caseIds);
        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<System_Action__c> lst = new List<System_Action__c>();
        
        for(Case caseObj : cases){
            
            //toDo : use api uncomment this part
            ApiConnection con = new ApiConnection();
            //#CH01 Start
            String regionName = 'Bahrain';
            if(caseObj.Case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            //#CH01 END
            HttpRequest request = con.createRequest('PUT','/api/v1/accounts/details/private',regionName);
            //HttpResponse response = SM001_ApiCalls.blockUnblockAccountApi(request,caseObj,updatedStatus);

            HttpResponse response = new HttpResponse();
            // Create Manually json response For Test Class
            String body = '{    "meta": {        "code": "ACCO-1001",        "message": "Account Details for given account has been retrieved successfully."    },    "data": {        "customerId": "989248099",        "id": "BH09ABCO00929029882",        "alias": "Wife Account",        "productType": "Account",        "productName": "Saving Account",        "category1": "",        "category2": "",        "account": {            "number": "100001009280",            "branch": "",            "currency": {                "code": "BHD",                "description": "Bahraini Dinar",                "decimalPlaces": 3            },            "iban": "BH09ABCO00929029882",            "availableBalance": 100.000,            "ledgerBalance": 100.000,            "startDate": "2018-01-09",            "endDate": "2018-02-09",            "status": "Active",            "overdraftLimit": 100000.000,            "overdraftExpiryDate": "2020-12-31",            "overdraftAvailableLimit": 1000000.000,            "paymentsAllowed": true        }    }}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');

            if (response.getStatusCode() != 200 ) {
                System.debug(' != 200');

               System_Action__c actionRecord = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint() ,request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    'Update Account Details API',''
                                                );
                lst.add(actionRecord);
            }
            
            else{
                System.debug(' == 200');
                //Create parameter
                Map<String, Object> Params = new Map<String, Object>();
                Params.put('air_SendApprovedEmail',true);
                Params.put('CaseRecord',caseObj);
                Params.put('recordId',caseObj.Id);
                //#CH01 : Start
                Params.put('recordId',caseObj.Id);
                Params.put('caseModel',caseObj.Case_Model__c);
                //#CH01 End

                //create instance of Interview
                Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
                //Invoke start method
                stage.start();

                caseObj.Status = 'Closed';
                caseObj.Sub_Status__c = 'Approved';
                caseObj.Waiting_for_customer_feedback__c = false;
                caseObj.cc_Checker_Result_Date_Time__c =DateTime.now();
               
                }
            }  
        
       
        if(cases != null && cases.size()>0){
            update cases;
        }
        if(lst != null && lst.size()>0){
            insert lst;
        }    
    }
        
    
    public class AccountForInterestDetails {
        @AuraEnabled 
        public String iban {get; set;}

        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}
        
        @AuraEnabled 
        public String RHA_AccountType {get; set;}

        @AuraEnabled 
        public Double AIR_CIFBalance {get; set;}
        
        @AuraEnabled 
        public String AIR_CurrentInterestRate {get; set;}
        
        @AuraEnabled 
        public String AIR_SegmentInterestRate {get; set;}
        
        public AccountForInterestDetails(String iban,String ac_currency,String RHA_AccountType,Double AIR_CIFBalance,String AIR_CurrentInterestRate,String AIR_SegmentInterestRate){
            this.iban = iban;
            this.ac_currency = ac_currency;
            this.RHA_AccountType = RHA_AccountType;
            this.AIR_CIFBalance = AIR_CIFBalance;
            this.AIR_CurrentInterestRate = AIR_CurrentInterestRate;
            this.AIR_SegmentInterestRate = AIR_SegmentInterestRate;
            this.ac_label = iban +' - '+ ac_currency;
        }
    }
}