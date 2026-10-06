/**
 * @author Wissal benqezza
 * @date Création 18/10/2021
 * @date Modification
 * @description :
 * 
 */
public with sharing class LTNG027_MinimumBalanceFeeController{
    private static String CLASS_NAME = LTNG027_MinimumBalanceFeeController.class.getName();

    @AuraEnabled
    //To get the record type id for the record type Minimum Balance Management
	public static Id getMinimumBalanceManagementCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Minimum_Balance_Management').getRecordTypeId();
    }

    @AuraEnabled
    //To get the list of accounts For Minimum Balance Fee Reversal via the api 
 
	public static List<AccountForFeeDetails> getAccountForFeeViaApi(String accountId,String caseModel) {

        PAD.debugLogBegin(CLASS_NAME, 'getAccountForFeeViaApi', 'Parameters : [accountId] : '+accountId );

        List<AccountForFeeDetails> accForFee = new List<AccountForFeeDetails>();
        if(accountId != null && accountId != '' ){
            //CH02
            Account accObj = [SELECT Id,Region_Flag__c, CIF__pc,PersonEmail FROM Account WHERE Id=: accountId];

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

                    accForFee.add( new AccountForFeeDetails(
                        String.valueOf(mapaccountDetails.get('iban')) , 
                        accCurrency
                    ));
                }
            }
        }
        PAD.debugLogEnd(CLASS_NAME, 'getAccountForFeeViaApi', '[accForFee] : ' + accForFee );
        
        return accForFee;
    }

     @InvocableMethod(label='Update Fee Waiver Flag & Reason' description='The purpose of this service is to close the case and Update Fee Waiver Flag & Reason' callout=true )
    public static List<String> UpdateFeeWaiverFlagReasonViaApiFromFlow(List<Id> caseIds){

        //call future method
        UpdateFeeWaiverFlagReasonViaApi(new Set<Id>(caseIds));

        return null;
    } 

     @future(callout=true)
    public static void UpdateFeeWaiverFlagReasonViaApi(Set<Id> caseIds){

        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<System_Action__c> lst = new List<System_Action__c>();
        ApiConnection con = new ApiConnection();

        for(Case caseObj : cases){
           
            HttpResponse response = SM001_ApiCalls.callUpdateFeeWaiverFlagReasonApi(con,caseObj);
            System.debug(' response code status '+response.getStatusCode());
            if (response.getStatusCode() != 200 ) {
                System.debug(' != 200');

               //System_Action__c actionRecord = SM001_ApiCalls.setSystemAction(response.getBody(),
                                                   // caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                   // 'Update Fee Waiver Flag & Reason API'
                                               // );
                //lst.add(actionRecord);
            }
            
    
            else{
                System.debug(' == 200');
                if(caseObj.Sub_Type__c=='Requested By Customer'){
                 sendEmailAlert(caseObj,'MIN_FEE_WAIVER_COMPLETED');
                }

                caseObj.cc_Checker_Result_Date_Time__c =DateTime.now();
                caseObj.Sub_Status__c = 'Completed';
                caseObj.Status = 'Closed';
               
            }
        }
         if(cases != null && cases.size()>0){
            update cases;
        }
         if(lst != null && lst.size()>0){
            insert lst;
        }  
       
    } 
    
   public static void sendEmailAlert(Case objCase,String emailAlertName){
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('recordId',objCase.Id);
        System.debug('TESSSTTT recordId'+objCase.Id);
        Params.put('emailAlertName',emailAlertName);
        System.debug('TESSSTTTT emailAlertName'+emailAlertName);
        Params.put('caseModel',objCase.Case_Model__c);

        Params.put('caseRecordTyeName',objCase.RecordType_DeveloperName__c);
        System.debug('TESSTTTTcaseRecordTyeName'+objCase.RecordType_DeveloperName__c);

        //create instance of Interview
        Flow.Interview.Send_Emails_Alert_Flow stage = new Flow.Interview.Send_Emails_Alert_Flow(Params);
        //Invoke start method
        stage.start(); 
    } 

 
    public class AccountForFeeDetails {
        @AuraEnabled 
        public String iban {get; set;}

        @AuraEnabled 
        public String ac_currency {get; set;}
        
        @AuraEnabled 
        public String ac_label {get; set;}
        
        public AccountForFeeDetails(String iban,String ac_currency){
            this.iban = iban;
            this.ac_currency = ac_currency;
            this.ac_label =  ac_currency +'  '+ iban;
        }
    }
}