/**
 * @author Wissal benqezza
 * @date Création 31/12/2021
 * @date Modification
 * @description :Contains functions called in 'LTNG004_AccountClosureCaseRequest'and 'LTNG004_AccountToClose'
 *  *  #CH01# Added by Imane tsioucha  20-06-2022 *** region name changes according to case model value 
 *     #CH02 : #D&A Team #24-06-2022# Added alburaq logic.
 *     #CH03# #Imane Tsioucha# #17-01-2024# add x-canary header
 * 	   #CH04# Maksud Ali 04 May 2026, update api response, included Product Type and Product Name.	
 */
public with sharing class LTNG004_AccountClosureController {
    private static String CLASS_NAME = LTNG004_AccountClosureController.class.getName();

    @AuraEnabled
    //To get the record type id for the record type account closure 
	public static Id getAccRequestCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ac_AccountClosure').getRecordTypeId();
    }

    @AuraEnabled
    //To get the list of accounts to close for the custumer via the api 
	public static List<AccountToCloseDetails> getAccountToCloseViaApi(String accountId,String caseModel) {

        PAD.debugLogBegin(CLASS_NAME, 'getAccountToCloseViaApi', 'Parameters : [accountId] : '+accountId );

        List<AccountToCloseDetails> accToClose = new List<AccountToCloseDetails>();
        if(accountId != null && accountId != '' ){
            //CH02
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accountId];
              //#CH03 : start
        /*   if(accObj!= null ){
              System.debug('x-canary added :'+accObj.x_canary__pc);
                 if(accObj.x_canary__pc != null){
                    request.setHeader('x-canary', accObj.x_canary__pc);
                 }
              }*/
            HttpResponse response = SM001_ApiCalls.callAccountListApi(accObj,caseModel);

            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Account List API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountList = (List<Object>)m1.get('accounts'); 
                for(Object accountDetails : accountList){
                    Map<String,Object> mapaccountConfig = (Map<String, Object>)accountDetails;
                    Map<String,Object> mapaccountDetails = (Map<String, Object>)mapaccountConfig.get('account');
                    String accCurrency = (String) ((Map<String, Object>)mapaccountDetails.get('currency')).get('code');
                    String type = String.valueOf(mapaccountDetails.get('templateId'));
                    System.debug('template type ' + type);
                    String productName = String.valueOf(mapaccountConfig.get('productName')); //CH04
					
                    accToClose.add( new AccountToCloseDetails(
                        String.valueOf(mapaccountDetails.get('iban')) , 
                        accCurrency,
                        type,
                        productName //CH04
                    ));
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountToCloseViaApi', '[accToClose] : ' + accToClose );
        
        return accToClose;
    }

    //To close the account selected ,first it calls the Api to see if it's eligible to close then it closes it and sends an approved email
    /* @InvocableMethod(label='Close Account Api' description='The purpose of this service is to close accounts except the default one' callout=true )
    public static List<String> closeAccountViaApiFromFlow(List<Id> caseIds){

        //call future method
        closeAccountViaApi(new Set<Id>(caseIds));

        return null;
    } */

    /* @future(callout=true)
    public static void closeAccountViaApi(Set<Id> caseIds){

        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<System_Action__c> lstSA = new List<System_Action__c>();
        
        ApiConnection con = new ApiConnection();

        for(Case caseObj : cases){
            HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/account',null);
            HttpResponse response = SM001_ApiCalls.callCloseAccountApi(caseObj,request);
    
            if (response.getStatusCode() != 200 && response.getStatusCode() != 403 ) {
                //show CRM red message with error description 
                System.debug(' != 200 & != 403');

                caseObj.err_IsError__c = true;
             
                caseObj.err_LastErrorDescription__c	 = 'Please check the last error in System Log ';
                lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                          request.getEndpoint() ,request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    'Account Closure Api When Checker Result is Approved', 'Account Closure'
                                                ));
                //&& do not change anything in the case
            }else if (response.getStatusCode() == 403 ) {
                System.debug(' == 403');

                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> meta = (Map<String, Object>)m.get('meta');
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                caseObj.ac_EligibleToClose__c = (Boolean)m1.get('eligible');
                caseObj.ac_IneligibilityReasons__c = (String)m1.get('notEligibleReasons');
            }else if(response.getStatusCode() == 200){
                System.debug(' == 200');
                
                //Create parameter
                Map<String, Object> Params = new Map<String, Object>();
                Params.put('sendApprovedEmail',true);
                Params.put('caseRecord',caseObj);
                //create instance of Interview
                Flow.Interview.Account_closure_update stage = new Flow.Interview.Account_closure_update(Params);
                //Invoke start method
                stage.start();


                caseObj.Sub_Status__c = 'Approved';
                caseObj.Status = 'Closed';
            }
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(cases != null && cases.size()>0){
            update cases;
        }
    } */

    @AuraEnabled
    public static String updateCheckerSection(Id caseId , String checkerResults, String checkerComments){
        System.debug('updateCheckerSection*****************************');
        System.debug(caseId);
        System.debug(checkerResults);
        System.debug(checkerComments);
        Case caseObj = DM002_Case.getListByIds(new Set<Id>{caseId}).get(0);
        //CH02
        Account accObjt=[SELECT Id,Subscription_Model__pc,Alburaq_Segment__pc,Segment__pc FROM Account where id=:caseObj.accountId ].get(0);
        String regionName=caseObj.Region_Flag__c;
        System.debug('hiiiiiii==> '+caseObj.cc_Checker_Result__c );
        if(caseObj.cc_Checker_Result__c != 'Accept' && checkerResults == 'Accept'){
          
            // CH01 region name changes according to case model value -->
             if(caseObj.Case_Model__c != null){
                if(caseObj.Case_Model__c == 'alburaq'){
                    regionName+='_alburaq';
                }
                
            }
            System.debug( 'Region name ===> '+ regionName);
            ApiConnection con = new ApiConnection();
            HttpRequest request = con.createRequest('DELETE','/api/v1/customer-products/account',regionName);
               //#CH03 : start
              List<Account> accs = [SELECT Id,x_canary__pc FROM Account WHERE Id=:caseObj.accountId];
              if(accs!= null && accs.size()>0){
              System.debug('x-canary added :'+accs.get(0).x_canary__pc);
                 if(accs.get(0).x_canary__pc != null){
                    request.setHeader('x-canary', accs.get(0).x_canary__pc);
                 }
              }
             //#CH03 : End
            
            // CH01 END-->
            HttpResponse response = SM001_ApiCalls.callCloseAccountApi(caseObj,request);
    
            if (response.getStatusCode() != 200 && response.getStatusCode() != 403 ) {
                //show CRM red message with error description 
                //&& do not change anything in the case
                System.debug(' != 200 & != 403');

                System_Action__c lst = SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                          request.getEndpoint() ,request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    'Account Closure Api When Checker Result is Accepted', 'Account Closure'
                                                );
                insert lst;
                return 'We are unable to close this account. Find out more infos in system log ';
            }else if (response.getStatusCode() == 403 ) {
                System.debug(' == 403');
                
                /* 
                update the following fields in the case :
                Eligible to Close = response.eligible
                Ineligibility Reasons = response.notEligibleReasons
                keep case sub-status as In-Progress
                 */
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> meta = (Map<String, Object>)m.get('meta');
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                caseObj.ac_EligibleToClose__c = (Boolean)m1.get('eligible');
                caseObj.ac_IneligibilityReasons__c = (String)m1.get('notEligibleReasons');
            }else if(response.getStatusCode() == 200){
                System.debug(' == 200');
                
                /* 
                CRM to send email to the customer 16. Account Closure | ACCT_CLOSURE_CONFIRMED //gerer dans le flow
                CRM to update case sub-status
                CRM to close case
                 */
                
                //Create parameter
               
                Map<String, Object> Params = new Map<String, Object>();
                Params.put('sendApprovedEmail',true);
                Params.put('caseRecord',caseObj);
                //create instance of Interview
                Flow.Interview.Account_closure_update stage = new Flow.Interview.Account_closure_update(Params);
                //Invoke start method
                stage.start();


                caseObj.Sub_Status__c = 'Approved';
                caseObj.Status = 'Closed';
                  //CH02
                  //check issue
               /* if(accObjt.Subscription_Model__pc=='both'){
                    if(caseObj.Case_Model__c=='alburaq'){
                        accObjt.Subscription_Model__pc='ila';
                        accObjt.Alburaq_Segment__pc=null;
                    }
                   else if(caseObj.Case_Model__c=='ila'){
                        accObjt.Subscription_Model__pc='alburaq';
                        accObjt.Segment__pc=null;
                    }
                    update accObjt;
                }*/
            }  
        }

        caseObj.cc_Checker_Result__c = checkerResults;
        caseObj.cc_Checker_Comments__c = checkerComments;
        update caseObj;
        return null;
    }

    public class AccountToCloseDetails {
        @AuraEnabled 
        public String iban {get; set;}

        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}
        
        @AuraEnabled 
        public String ac_template {get; set;}
        
        //CH04 START
        @AuraEnabled 
        public String productName {get; set;}
        
        @AuraEnabled 
        public String productType {get; set;}
        //CH04 END
        
        public AccountToCloseDetails(String iban,String ac_currency,String ac_template,String productName){ //CH04 Added productName param
            this.iban = iban;
            this.ac_currency = ac_currency;
            
            //CH04 START
			this.productName = productName;
            this.productType = 'Account';
            //CH04 END
            
            //HB is HYSA account type for alburaq.
            //HY is HYSA account type for ila
            if(ac_template == 'HY' || ac_template == 'HB') {
                this.ac_label = iban +' - '+ ac_currency +' - '+' HYSA';
                this.productType = 'HYSA'; //CH04 one line added.
            } else {
                this.ac_label = iban +' - '+ ac_currency;
            }
        }
    }
}