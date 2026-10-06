/**
 * @author Wissal benqezza
 * @date Création 05/01/2022
 * @date Modification
 * @description : To call the api to check the eligibility of the account to close once clicking on the button validate account closure on the case object 
 * #CH01 : #Hamza Chaoui# #04-07-2022# -- implement alburaq unit changes.
 */
public without sharing class LTNG005_ValidateAccountClosureController {

    private static String CLASS_NAME = LTNG005_ValidateAccountClosureController.class.getName();
    
    //call the api and update the fields 'Eligible to Close' and 'Ineligibility Reasons' with the response
    @InvocableMethod(label='Validate Account Closure Api Based On Notification Type' description='Get api validation checks for the customer account closure' callout=true )
    public static List<String> validateAccClosureViaApiFromFlow(List<RequestAccClosure> reqAccClosure){
        Set<Id> caseIds= new Set<Id>();
        List<String> strcaseIds= new List<String>();
        String notifType = reqAccClosure.get(0).notifType;
        for(RequestAccClosure req : reqAccClosure){
            caseIds.add(req.caseId);
            strcaseIds.add(req.caseId);
        }
        //call future method
        validateAccClosureViaApiFutureMeth(caseIds,notifType);
        return strcaseIds;
    } 
    
    @future(callout=true)
    public static void validateAccClosureViaApiFutureMeth(Set<Id> caseIds,String notifType){
        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<Case> casesToUpdate = new List<Case>();
        for (Case caseObj : cases) {
            AccountClosureValidationDetails accClosureValid = processValidateAccClosureViaApi(caseObj,true);
            if(accClosureValid != null){
                caseObj.ac_EligibleToClose__c = accClosureValid.eligible;
                if(caseObj.ac_EligibleToClose__c == true){
                    caseObj.cc_Maker__c = 'Send to Checker';   
                    caseObj.OwnerId = system.Label.ac_CheckerQueue;    
                }
                caseObj.ac_IneligibilityReasons__c = accClosureValid.notEligibleReasons;
                if(accClosureValid.eligible == false && notifType == 'EXPIRED'){
                    System.debug('Eligible to be expired and an email should be sent');
                    caseObj.Sub_Status__c = 'Expired';
                    caseObj.Status = 'Closed';
                    
                    Map<String, Object> Params = new Map<String, Object>();
                    Params.put('SendExpiredEmail',true);
                    Params.put('caseRecord',caseObj);
                    //create instance of Interview
                    Flow.Interview.Account_closure_update stage = new Flow.Interview.Account_closure_update(Params);

                    //Invoke start method
                    stage.start();
                    System.debug('Email expired sent all good!');
                }
                else if(accClosureValid.eligible == false && notifType == 'REMINDER'){
                    /* 
                        CRM to send email to the customer 16. Account Closure |ac_EmailReminder //gerer dans le flow
                    */
                   
                    //Create parameter
                    Map<String, Object> Params = new Map<String, Object>();
                    Params.put('SendReminderEmail',true);
                    Params.put('caseRecord',caseObj);
                    //create instance of Interview
                    Flow.Interview.Account_closure_update stage = new Flow.Interview.Account_closure_update(Params);
                    //Invoke start method
                    stage.start();
                }
                casesToUpdate.add(caseObj);  
            }
        }
        if(casesToUpdate.size()>0){
            update casesToUpdate;
        }
    }

    @AuraEnabled
    public static AccountClosureValidationDetails validateAccClosureViaApi(Id caseId) {
        PAD.debugLogBegin(CLASS_NAME, 'validateAccClosureViaApi', 'Parameters : [caseId] : '+caseId );
       //CH01 : ADD Region_Flag__c,Case_Model__c
        Case caseObj = [SELECT Id,ac_Iban__c,Account.PersonEmail,Customer_CIF__c,Region_Flag__c,Case_Model__c,accountId  FROM Case WHERE Id = :caseId LIMIT 1];
        AccountClosureValidationDetails accClosureValid = processValidateAccClosureViaApi(caseObj,false);

        if(accClosureValid != null){
            caseObj.ac_EligibleToClose__c = accClosureValid.eligible;
            if(caseObj.ac_EligibleToClose__c == true){
                caseObj.cc_Maker__c = 'Send to Checker';    
                caseObj.OwnerId = system.Label.ac_CheckerQueue;    
            }
            caseObj.ac_IneligibilityReasons__c = accClosureValid.notEligibleReasons;
            update caseObj;
        }

        PAD.debugLogEnd(CLASS_NAME, 'validateAccClosureViaApi', '[accClosureValid] : ' + accClosureValid );
        return accClosureValid;
    }


    private static AccountClosureValidationDetails processValidateAccClosureViaApi(Case caseObj,Boolean isFromFlow){
        AccountClosureValidationDetails accClosureValid;

        
        HttpResponse response = SM001_ApiCalls.callValidateAccountClosureApi(caseObj);
        if (response.getStatusCode() != 200 ) {

            String errorMsg = 'The status code returned was not expected when we are calling Validate Account Closure API : ' + response.getStatusCode();
            System.debug(errorMsg);
            if(!isFromFlow){
                throw new AuraHandledException(errorMsg);
            }else{
                String regionName=caseObj.Region_Flag__c;
                if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
                    regionName += '_alburaq';
                }
                ApiConnection con = new ApiConnection();
                HttpRequest request = con.createRequest('GET','/api/v1/customer-products/account/closure/validation',regionName); 
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
                                '"iban": '+SM001_ApiCalls.stringApiFormat(caseObj.ac_Iban__c)+
                            '}';
                request.setBody(body);
                insert SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                        'Calling processValidateAccClosureViaApi function from apex class LTNG005_ValidateAccountClosureController.cls ', 'Account Closure'
                                                    );
            }
        }else {
            System.debug('response.getStatusCode()'+ response.getStatusCode() );
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> meta = (Map<String, Object>)m.get('meta');
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');

            List<String> notElegibleReasonsList = new List<String>(); 
            for(Object reason : (List<Object>)m1.get('notEligibleReasons')){
                Map<String,Object> reasonDetails = (Map<String, Object>)reason;
                notElegibleReasonsList.add('"'+String.valueOf(reasonDetails.get('code'))+'"');
            }


            accClosureValid = new AccountClosureValidationDetails();
            accClosureValid.eligible = (Boolean)m1.get('eligible');
            accClosureValid.notEligibleReasons = String.join(notElegibleReasonsList, ',');
            accClosureValid.messageApi = String.valueOf(meta.get('message'));
        }

        return accClosureValid;
    }
   
    public class AccountClosureValidationDetails {
        @AuraEnabled 
        public Boolean eligible {get; set;}

        @AuraEnabled 
        public String notEligibleReasons {get; set;}
        
        @AuraEnabled 
        public String messageApi {get; set;}
        
    }
    public class RequestAccClosure {
        @InvocableVariable(label='Case Id' description='the Id of the Case' required=true)
        public Id caseId;

        @InvocableVariable(label='Notification Type' description='Notification Type' required=true)
        public String notifType;
    }
}