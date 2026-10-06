/**
 * @author Amina BENABDELKRIM
 * @date Création 05/07/2022
 * @date Modification
 * @description  : To call the api to check the eligibility of the subscription model to terminate once clicking on the button Execute subscription model termination  on the case object 
 *   #CH01 : ADD Region_Flag__c,Case_Model__c
 *   #CH02# #Imane Tsioucha# #15-01-2024# add x-canary header
 * 
 */
public with sharing class LTNG024_SubsModelTerminationController {
    private static String CLASS_NAME = LTNG024_SubsModelTerminationController.class.getName();
      
    @AuraEnabled
    public static AccountTerminationValidationDetails validateAccTerminationViaApi(Id caseId) {
        PAD.debugLogBegin(CLASS_NAME, 'validateAccTerminationViaApi', 'Parameters : [caseId] : '+caseId );
       
        //CH01 : ADD Region_Flag__c,Case_Model__c
        //CH02 : add Account.x_canary__pc
        Case caseObj = [SELECT Id,ac_Iban__c,ac_EligibleToClose__c,Account.PersonEmail,Customer_CIF__c,Region_Flag__c,Case_Model__c,accountId,Account.x_canary__pc FROM Case WHERE Id = :caseId LIMIT 1];
        AccountTerminationValidationDetails accTerminationValid = processValidateAccTerminationViaApi(caseObj,false);

        if(accTerminationValid != null){
            caseObj.ac_EligibleToClose__c = accTerminationValid.eligible;

            caseObj.ac_IneligibilityReasons__c = accTerminationValid.notEligibleReasons;
            System.debug('case==>'+caseObj);
            
            //check if customer has any open dispute cases under the model which will be terminated and update the flag “Has open dispute case(s)“
            List<Case> disputeCases = [SELECT Id FROM Case WHERE accountId =: caseObj.accountId AND RecordType.DeveloperName = 'Issue' AND Type = 'Case Management'
                                                                AND Status != 'Closed' AND Case_Model__c =: caseObj.Case_Model__c ];

            if(disputeCases != null && disputeCases.size()>0 ){
                caseObj.Has_Open_Dispute_Case_s__c = true;
            }

            update caseObj;
            System.debug(' end case==>'+caseObj);
        }

        PAD.debugLogEnd(CLASS_NAME, 'validateAccTerminationViaApi', '[accTerminationValid] : ' + accTerminationValid );
        return accTerminationValid;
    }


    private static AccountTerminationValidationDetails processValidateAccTerminationViaApi(Case caseObj,Boolean isFromFlow){
        AccountTerminationValidationDetails accTerminationValid;
      
        HttpResponse response = SM001_ApiCalls.callValidateAccountTerminationApi(caseObj);
        /* HttpResponse response = new HttpResponse();
        
        String body = '{      "meta":{         "code":10003,       "displayMessage":"The validation for {CIF} has been processed successfully."    },    "data":{         "relationshipTermintionEligible":false,       "eligiblityChecksStatus": [       {              "productCheck": "JAMEYA",             "eligibilityStatus" : false,             "reasone": "Associated with 3 Jameyas"       },       {              "product": "HASSALA",             "eligibilityStatus" : false,             "reasone" : "Has hold on x Hassala"       },       {              "product": "CREDIT_CARD",             "eligibilityStatus" : true,             "reasone" : "No balance found"       },       {              "product": "ACCOUNTS_HOLD",             "eligibilityStatus" : false,             "reasone" : "Hold Exists on xxxxxxxxxxxxx , yyyyyyyyyyyyy, zzzzzzzzzz"       },       {              "product": "ACCOUNTS_FUNDING",             "eligibilityStatus" : false,             "reasone" : "Non-Zero balance on accounts: aaaaaaaaaa , bbbbbbbbb"       },       {              "product": "INTERNATIONAL_TRANSFERS",             "eligibilityStatus" : false,             "reasone" : "customer is having transfer within last 7 days"       },       {              "product": "TERM_DEPOSIT",             "eligibilityStatus" : false,             "reasone" : "customer is having 2 active term deposit"       },       {              "product": "KANZ",             "eligibilityStatus" : false,             "reasone" : "Has hold on KANZ"       }    ]    }}    ';
        response.setStatus('OK');    
        response.setStatusCode(200);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json'); */
      
        if (response.getStatusCode() != 200 ) {

            String errorMsg = 'The status code returned was not expected when we are calling r Validate Customer Relationship Termination API : ' + response.getStatusCode();
            System.debug(errorMsg);
            if(!isFromFlow){
                throw new AuraHandledException(errorMsg);
            }
        }
        else {
            System.debug('response.getStatusCode()'+ response.getStatusCode() );
            System.debug('response.getBody()'+ response.getBody() );
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> meta = (Map<String, Object>)m.get('meta');
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');

            List<String> notElegibleReasonsList = new List<String>(); 
            for(Object reason : (List<Object>)m1.get('eligibilityChecksStatus')){
                Map<String,Object> reasonDetails = (Map<String, Object>)reason;
               
                if(reasonDetails.get('eligibilityStatus')==false){ //toCheck
                    System.debug('eligibilityStatus ==> '+reasonDetails.get('eligibilityStatus')+',productCheck ==> '+reasonDetails.get('productCheck'));
                    notElegibleReasonsList.add('"'+String.valueOf(reasonDetails.get('productCheck'))+'"');
                    
                }
            }

            accTerminationValid = new AccountTerminationValidationDetails();
            accTerminationValid.eligible = (Boolean)m1.get('relationshipTerminationEligible');
            accTerminationValid.notEligibleReasons = String.join(notElegibleReasonsList, ',');
          
            accTerminationValid.messageApi = String.valueOf(meta.get('displayMessage'));
        }
   
        return accTerminationValid;
    }
   
 
   @InvocableMethod(label='Terminate Subscription Model ' description='The purpose of this service is to Terminate Subscribtion Model' callout=true )
    public static  List<String>  TerminateSubscriptionModelApiFromFlow(List<Id> caseIds)
    {   //call future method from flow to terminate subscription model 
        
        TerminateSubscriptionModelApiFromFlow(caseIds.get(0));
        return null;
    }
    
      
    @future(callout=true)
    public static void TerminateSubscriptionModelApiFromFlow(Id caseId){
        TerminateSubscriptionModelApi(caseId);
    }
   
    @AuraEnabled
    public static AccountTerminationDetails TerminateSubscriptionModelApi(Id caseId){
        
        AccountTerminationDetails accTermination= new AccountTerminationDetails() ;
    
        System.debug('TerminateSubscriptionModelApi*****************************');
        System.debug('CaseId==> '+caseId);

        ApiConnection con = new ApiConnection();
        List<System_Action__c> lst = new List<System_Action__c>();

        Boolean allApiCallAreSuccess = true;
        Integer activeAccNumber = 0;
        String successMsg;
        String regionName;
        String Iban;
        String customerId;

        Case caseObj = [SELECT Id,ac_Iban__c,ac_EligibleToClose__c,accountId,ac_IneligibilityReasons__c,Customer_CIF__c,Region_Flag__c,Case_Model__c,Sub_Status__c,Status,OwnerId FROM Case WHERE Id = :caseId LIMIT 1];
        Account accObjt=[SELECT Id,Subscription_Model__pc,Alburaq_Segment__pc,Segment__pc,PersonEmail,CIF__pc,x_canary__pc FROM Account where  id=:caseObj.accountId LIMIT 1];
        
        customerId=caseObj.Customer_CIF__c;
        regionName=caseObj.Region_Flag__c;
        
        //region name changes according to case model value -->
        if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
            regionName+='_alburaq';      
        }
        
        //CALL ACCOUNT LIST API
        HttpRequest request1 = con.createRequest('GET','/api/v1/accounts?',regionName);
         //#CH02 : start
         if(accObjt != null){
             System.debug('x-canary added :'+accObjt.x_canary__pc);
             if(accObjt.x_canary__pc != null){
                request1.setHeader('x-canary', accObjt.x_canary__pc);
             }
         }
         //#CH02 : end


       
       HttpResponse response1 = SM001_ApiCalls.getAccountsListAllApi(request1,accObjt);
        Map<String, Object> responseData1  = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());// meta, data
        Map<String, Object> meta1 = (Map<String, Object>)responseData1.get('meta');
        Map<String, Object> data1 = (Map<String, Object>)responseData1.get('data');
        
        lst.add(SM001_ApiCalls.setSystemAction( request1.getBody(),response1.getBody(),
                        request1.getEndpoint() ,request1.getMethod(),
                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response1.getStatusCode(), 
                        'get Accounts List All Api', 'Subscription model termination'
                ));

        for(Object accounts : (List<Object>)data1.get('accounts')){
            Map<String,Object> accountDetails = (Map<String, Object>)accounts;
            System.debug('Account status ==> '+((Map<String, Object>)accountDetails.get('account')).get('status'));
            System.debug('Iban ==> '+accountDetails.get('id'));
            Iban=(String)accountDetails.get('id');

            if(((Map<String, Object>)accountDetails.get('account')).get('status')=='Active' || Test.IsRunningTest() ){
                activeAccNumber++;
                //CALL CLOSE ACCOUNT API
                HttpRequest request2 = con.createRequest('DELETE','/api/v1/customer-products/account',regionName);
                // CH01 END-->

                //#CH02 : start
                if(accObjt != null){
                    System.debug('x-canary added :'+accObjt.x_canary__pc);
                    if(accObjt.x_canary__pc != null){
                        request2.setHeader('x-canary', accObjt.x_canary__pc);
                    }
                }
                //#CH02 : End

                HttpResponse response2;

                if(Test.IsRunningTest()){
                    response2 = new HttpResponse();
                    // Create Manually json response For Test Class
                    String body = '{  	   "meta":{  		  "code":"PROD-1015",		  "displayMessage":"The validation has been performed successfully."	   }	}';
                    response2.setStatus('OK');
                    response2.setStatusCode(200);
                    response2.setBody(body);
                    response2.setHeader('Content-Type', 'application/json');
                }else{
                    response2 = SM001_ApiCalls.smt_callCloseAccountApi(request2,Iban,customerId);
                    lst.add(SM001_ApiCalls.setSystemAction( request2.getBody(),response2.getBody(),
                        request2.getEndpoint() ,request2.getMethod(),
                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response2.getStatusCode(), 
                        'delete account Api', 'Subscription model termination'
                    ));
                }
            
                Map<String, Object> responseData2 = (Map<String, Object>)JSON.deserializeUntyped(response2.getBody());// meta, data
                Map<String, Object> meta2 = (Map<String, Object>)responseData2.get('meta');
                Map<String, Object> data2 = (Map<String, Object>)responseData2.get('data');
    
                if (response2.getStatusCode() != 200 && response2.getStatusCode() != 403 ) {
                    //show CRM red message with error description 
                    //&& do not change anything in the case
                    System.debug(' != 200 & != 403');
    
                    allApiCallAreSuccess = false;
                    break;
                
                }else if (response2.getStatusCode() == 403 ) {
                    System.debug(' == 403');
                    
                    allApiCallAreSuccess = false;
                    accTermination.successMessageFromApi = 'For iban ('+iban+') the Status Code From Api is 403 !';
    
                    caseObj.ac_EligibleToClose__c = (Boolean)data2.get('eligible');
                    caseObj.ac_IneligibilityReasons__c = (String)data2.get('notEligibleReasons');
                    caseObj.Sub_Status__c = 'In-Progress';
                    update caseObj;
                    return accTermination;
                }else if(response2.getStatusCode() == 200){
                    System.debug('For the iban = '+Iban + ' the Api call Status is 200 !');
                    successMsg = String.valueOf(meta2.get('displayMessage'));
                }
            }
        }

        if(lst != null && lst.size()>0){
            insert lst;
        }
        
        if(allApiCallAreSuccess == true && activeAccNumber>=1){

            accTermination.successMessageFromApi = successMsg;
            caseObj.Status = 'Closed';
            caseObj.Sub_Status__c = 'Approved';
            caseObj.OwnerId = System.Label.smt_checkerQueue;

            update caseObj;

            system.debug('subscription model==> '+accObjt.Subscription_Model__pc);

            if(accObjt.Subscription_Model__pc=='both'){
                if(caseObj.Case_Model__c=='alburaq'){
                    accObjt.Subscription_Model__pc='ila';
                    accObjt.Alburaq_Segment__pc=null;
                }
                else if(caseObj.Case_Model__c=='ila'){
                    accObjt.Subscription_Model__pc='alburaq';
                  //  accObjt.Segment__pc=null;
                }
                update accObjt;
            }  
        }

        System.debug('caseObj after modification ==> '+caseObj);
        PAD.debugLogEnd(CLASS_NAME, 'TerminateSubscriptionModelApi', '[accTermination] : ' + accTermination );

       return accTermination;
        
    }  
    
   

    public class AccountTerminationValidationDetails {
        @AuraEnabled 
        public Boolean eligible {get; set;}

        @AuraEnabled 
        public String notEligibleReasons {get; set;}
        
        @AuraEnabled 
        public String messageApi {get; set;}
    }

    public class AccountTerminationDetails {
    
        @AuraEnabled 
        public String successMessageFromApi  {get; set;}
    }      
    
}