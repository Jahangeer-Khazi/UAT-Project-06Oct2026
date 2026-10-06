/**
* @author Aniss Mbarki
* @date Création 25/05/2024
* @date Modification
* @description : 
*/
public without sharing class Loan_CrossSellingService {
    
    private static String CLASS_NAME = Loan_CrossSellingService.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    

    @InvocableMethod(label='call Loan Cross Selling Service' description='Loan Cross Selling Service' callout=true )
    public static List<String> crossSellingServiceFromFlow(List<Id> caseIds)
    {   
        List<Case> cases = new List<Case>();
        List<Case> newCases = new List<Case>();
        List<Case> lstUpdateCase = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for(Case caseObj : cases){
            if( caseObj.AIR_HaveCreditCard__c == true ){
                try {
                        newCases.add( getCrossCellingMappingCase(caseObj) );
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                        System.debug(e.getStackTraceString());
                        lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                    null,null,
                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                    caseObj.Type+' crossSellingServiceFromFlow (unhandled error)', caseObj.Type
                                ));
                    }
            }
        }

        if(newCases != null && newCases.size()>0){
            insert newCases;

            Set<Id> newcaseIds = new Set<Id>();
            for( Case cs : newCases ){
                newcaseIds.add(cs.Id);
            }
            crossSellingApisAfterInsertFuture(new Set<Id>(newcaseIds));
        }

        return caseIds;
    }

    @future(callout=true)
    public static void crossSellingApisAfterInsertFuture (Set<Id> caseIds)
    {
        
        List<Case> cases = new List<Case>();
        List<Case> lstUpdateCase = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        if(cases != null && cases.size()>0){
            Integer cardProductConfigurationIdString;
            
            for(Case objCase : cases){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                String regionName = objCase.Region_Flag__c;    
                if(objCase.Case_Model__c == 'alburaq'){    
                    regionName += '_alburaq';  
                }

                //request = con.createRequest('GET', '/api/v1/credit-cards?', regionName ); 
                request = con.createRequest('GET', System.Label.CC_EndPointGetCreditCards, regionName ); 

                System.debug('Person Email :'+objCase.Account.PersonEmail);
                System.debug('Customer ID :'+objCase.Account.CIF__pc);
                //System.debug('Case ID :'+setCaseId);
                
                request.setHeader('userId', objCase.Account.PersonEmail);
                request.setHeader('customerId', objCase.Account.CIF__pc);
                if(objCase.Account.x_canary__pc != null){
                    request.setHeader('x-canary', objCase.Account.x_canary__pc);//CH22
                }
                
                system.debug('---> Request --> '+request.getBody());
                request.setTimeout(60000);
                HttpResponse response = http.send(request);
                system.debug('---> Responce New --> '+response.getBody());
                lstSA.add(SM001_ApiCalls.setSystemAction(request.getBody(),response.getBody(),
                                                        request.getEndpoint(),request.getMethod(),
                                                        objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(),
                                                        objCase.Type+' -- call api to et api/v1/credit-cards list --', 'Credit Card'));
                if (response.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
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
                        if(map1.get('productMappingCode')== objCase.cc_Requested_Card_Type__c)
                        {
                            system.debug('---> FINALL 1111 --> '+(Integer)map1.get('cardProductConfigurationId'));
                            cardProductConfigurationIdString = (Integer)map1.get('cardProductConfigurationId');
                            system.debug('---> FINALL cardProductConfigurationId --> '+cardProductConfigurationIdString);
                            objCase.PrimaryCardProductConfigurationId__c = String.valueOf(cardProductConfigurationIdString);
                        }
                    }
                }
                
                //call second api : 
                String body ='';
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                request1 = con.createRequest('PUT', System.Label.CC_EndPointCreditCardRequest, regionName);
                request1.setTimeout(60000);
                if(objCase.Account.x_canary__pc != null){
                    request1.setHeader('x-canary', objCase.Account.x_canary__pc);//CH22
                }
                if(objCase.cc_Name_on_the_Card__c !=null){
                    body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                        '","crmCaseId": "'+objCase.Id +
                        '","embossName": "'+objCase.cc_Name_on_the_Card__c +
                        '","status":"IN_PROGRESS"}';
                }
                else{
                    body = '{"cardProductConfigurationId": "'+cardProductConfigurationIdString +
                        '","crmCaseId": "'+objCase.Id +
                        '","embossName": '+null +
                        ',"status":"IN_PROGRESS"}';
                }

                system.debug('---> BODY --> '+body);               
                request1.setBody(body);
                request1.setHeader('userId', objCase.Account.PersonEmail);
                request1.setHeader('customerId', objCase.Account.CIF__pc);
                
                system.debug('---> Request --> '+request1.getBody());
                HttpResponse response1 = http1.send(request1);
                system.debug('---> Responce New --> '+response1.getBody());
                lstSA.add(SM001_ApiCalls.setSystemAction(request1.getBody(),response1.getBody(),
                                                        request1.getEndpoint(),request1.getMethod(),
                                                        objCase.id,objCase.Customer_CIF__c,objCase.accountId,response1.getStatusCode(),
                                                        objCase.Type+' -- call api to update status credit card status api --', 'Credit Card'));
                if (response1.getStatusCode() != 200)
                {
                    System.debug('The status code returned was not expected: ' + response1.getStatusCode() + ' ' + response1.getStatus());
                    
                }
                else
                {
                    System.debug(response1.getBody());
                }
            }
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(cases != null && cases.size()>0){
            update cases;
        }
    }


    public static Case getCrossCellingMappingCase(Case caseObj){
        Case newCase = new Case();
        newCase.OwnerId = System.Label.Loan_Evaluation_Queue;//toCheck
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card').getRecordTypeId();
        newCase.Subject = 'Credit Card Application - Cross Selling';
        newCase.Description = 'New Request for a Credit card - Cross Selling';
        newCase.AIR_HaveCreditCard__c = true;
        newCase.cc_Requested_Card_Type__c = caseObj.cc_Requested_Card_Type__c;
        newCase.cc_Approved_Requested_Card_Type__c = caseObj.cc_Requested_Card_Type__c;
        newCase.cc_Requested_Credit_Limit__c = caseObj.cc_Requested_Credit_Limit__c;
        newCase.cc_Approved_Credit_Limit__c = caseObj.cc_Requested_Credit_Limit__c;
        newCase.cc_Name_on_the_Card__c = caseObj.cc_Name_on_the_Card__c;
        newCase.cc_Approved_Name_on_the_card__c = caseObj.cc_Name_on_the_Card__c;
        newCase.ContactId = caseObj.ContactId;
        newCase.Case_Model__c = caseObj.Case_Model__c;
        newCase.cc_Customer_Segment__c = caseObj.cc_Customer_Segment__c;
        newCase.Type = 'Credit Card Application';
        newCase.Sub_Type__c = 'New Credit Card - Cross Selling';
        newCase.cc_Employment_Status__c = caseObj.cc_Employment_Status__c;
        newCase.cc_Approved_employment_status__c = caseObj.cc_Employment_Status__c;
        newCase.Origin = caseObj.Origin;
        newCase.Priority = caseObj.Priority;
        newCase.cc_CRM_Stage__c = 'IN PROGRESS';
        newCase.cc_Application_Stages__c = 'Credit Pre-Screening';
        newCase.Status = 'In Progress';
        newCase.Sub_Status__c = 'In-Progress';
        newCase.ParentId = caseObj.Id;
        newCase.cc_Employer_Sector__c = caseObj.cc_Employer_Sector__c ;
        newCase.cc_Employer_Grade__c = caseObj.cc_Employer_Grade__c;
        newCase.cc_Whitelisted_Employer__c= caseObj.cc_Whitelisted_Employer__c;
        newCase.cc_Employer_Name__c= caseObj.cc_Employer_Name__c;
        newCase.cc_Marital_Status__c= caseObj.cc_Marital_Status__c;
        newCase.cc_Academic_Qualifications__c= caseObj.cc_Academic_Qualifications__c;
        newCase.cc_Number_of_Dependents__c= caseObj.cc_Number_of_Dependents__c;
        newCase.cc_Residence_Occupancy_Status__c= caseObj.cc_Residence_Occupancy_Status__c;
        newCase.cc_Number_of_Years_at_Current_Residence__c= caseObj.cc_Number_of_Years_at_Current_Residence__c;
        newCase.cc_Friend_s_Name__c= caseObj.cc_Friend_s_Name__c;
        newCase.cc_Friend_s_Contact_Number__c= caseObj.cc_Friend_s_Contact_Number__c;
        newCase.cc_Consent_to_Query_Benefit_Credit__c = caseObj.cc_Consent_to_Query_Benefit_Credit__c;
        newCase.cc_Terms_and_Conditions_Acceptance_Flag__c = caseObj.cc_Terms_and_Conditions_Acceptance_Flag__c;
        newCase.Region_Flag__c = caseObj.Region_Flag__c;
        newCase.AccountId = caseObj.AccountId;
        newCase.Campaign_Name__c = caseObj.Campaign_Name__c;
        newCase.Approved_Campaign_Name__c = caseObj.Campaign_Name__c;
        newCase.cc_Use_Current_Address__c = caseObj.cc_Use_Current_Address__c;
        
        //toDo : review mapping
       
        return newCase;
    }
    
}