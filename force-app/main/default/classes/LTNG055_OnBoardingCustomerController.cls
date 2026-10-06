/**
* @author Aniss Mbarki
* @date Création 28/10/2024
* @date Modification
* @description : 
*/
public without sharing class LTNG055_OnBoardingCustomerController {

    private static String CLASS_NAME = LTNG055_OnBoardingCustomerController.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    

    @AuraEnabled
	public static Id getCrsRecordId(Id caseId) {
        return [Select Id FROM CrsOnboarding__c WHERE Case__c = :caseId LIMIT 1].Id ;
    }

    @InvocableMethod(label='call CRS Continue On boarding Process API' description='call CRS Continue On boarding Process API' callout=true )
    public static List<String> crsContinueOnboardingApiFromFlow(List<Id> caseIds)
    {
        crsContinueOnboardingApiFuture(new Set<Id>(caseIds));

        return caseIds;
    }

    @future(callout=true)
    public static void crsContinueOnboardingApiFuture (Set<Id> caseIds)
    {
        List<Case> cases = new List<Case>();
        List<CrsOnboarding__c> crsUpdating = new List<CrsOnboarding__c>();
        List<Case> updateCases = new List<Case>();
        List<Account> updateAccs = new List<Account>();

        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String fieldsCrs = DM000_sObjectDescriber.constructFieldListForQueryFrom('CrsOnboarding__c');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.x_canary__pc,'+
                                    '(SELECT '+ fieldsCrs +' FROM CrsOnboarding__r) '+
                                'FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for(Case objCase : cases){
            try {
                CrsOnboarding__c objCRs = objCase.CrsOnboarding__r.get(0); 
                if(objCRs.CRS_Checker_Result__c == 'Approved'){

                    objCRs.CRS_Checker_Result_Date_Time__c = system.now();
    
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    String regionName = objCase.Region_Flag__c;    
                    if(objCase.Case_Model__c == 'alburaq'){    
                        regionName += '_alburaq';  
                    }
    
                    if(objCase.Account.x_canary__pc != null){
                        request.setHeader('x-canary', objCase.Account.x_canary__pc);
                    }
    
                    request = con.createRequest('POST', '/api/v1/onboarding/continue?', regionName);
    
                    String body = '{"caseId": "'+objCase.Id +
                        '","email": "'+objCase.Account.PersonEmail +
                        '","caseType": "'+objCase.Type +
                        '","caseStatus": "Approved"}';
                    
                    request.setBody(body);
                    request.setTimeout(60000);
                    request.setHeader('userId', objCase.Account.PersonEmail);
                    request.setHeader('customerId', objCase.Account.CIF__pc);
                    
                    system.debug('---> Request --> '+request.getBody());
                    HttpResponse response = http.send(request);
                    //store response as system action !
                    lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                        request.getEndpoint(),request.getMethod(),
                        objCase.id,objCase.Customer_CIF__c,objCase.accountId,response.getStatusCode(), 
                        'calling CRS Continue On boarding Process API', objCase.Type
                        ));
                    
                    if (response.getStatusCode() != 200)
                    {
                        System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                        objCRs.CRS_Checker_Result__c = null;
                    }
                    else
                    {
                        System.debug(response.getBody());
                        objCase.Status = 'Closed';
                        objCase.Sub_Status__c = 'Approved';
                        updateCases.add(objCase);
    
                        Account acc = new Account(Id = objCase.accountId);
                        acc.Applicable_Residency_Tax__pc = objCRs.ApplicableResidencyTax__c ;
                        acc.Tax_Country_1__pc = objCRs.Tax_Country_1__c ;
                        acc.Tax_Country_1_ID__pc = objCRs.Tax_Country_1_ID__c ;
                        acc.Tax_Country_2__pc = objCRs.Tax_Country_2__c ;
                        acc.Tax_Country_2_ID__pc = objCRs.Tax_Country_2_ID__c ;
                        acc.Tax_Country_3__pc = objCRs.Tax_Country_3__c ;
                        acc.Tax_Country_3_ID__pc = objCRs.Tax_Country_3_ID__c ;
                        acc.Tax_Country_4__pc = objCRs.Tax_Country_4__c ;
                        acc.Tax_Country_4_ID__pc = objCRs.Tax_Country_4_ID__c ;
                        updateAccs.add(acc);
                    }
    
                    crsUpdating.add(objCRs);
                }

            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                            null,null,
                            objCase.id,objCase.Customer_CIF__c,objCase.accountId,null, 
                            objCase.Type+' crsContinueOnboardingApiFromFlow (unhandled error)', objCase.Type
                        ));
            }
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
        if(crsUpdating != null && crsUpdating.size()>0){
            update crsUpdating;
        }
        if(updateCases != null && updateCases.size()>0){
            update updateCases;
        }
        if(updateAccs != null && updateAccs.size()>0){
            update updateAccs;
        }
    }
    
}