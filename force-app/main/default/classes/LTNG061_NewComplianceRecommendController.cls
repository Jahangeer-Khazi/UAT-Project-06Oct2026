/**
 * @author Aniss Mbarki
 * @date Création 07/05/2026
 */
public without sharing class LTNG061_NewComplianceRecommendController {
    private static String CLASS_NAME = LTNG061_NewComplianceRecommendController.class.getName();
    private static ApiConnection con = new ApiConnection();

    @AuraEnabled
    //To get the record type id for the record type Compliance Query 
	public static Id getComplianceRecommendationCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Compliance_Query').getRecordTypeId();
    }

    @AuraEnabled
    public static String checkValidtyOfCreationCompliance(String accountId ,String caseModel) {
        System.debug('checkValidtyOfCreationCompliance  -- accountId -->' +accountId );
        String raisonError = null;
        Account accObj = [SELECT Id,x_canary__pc,PersonEmail,Region_Flag__c,CIF__pc,Subscription_Model__pc FROM Account WHERE Id=: accountId];
        List <Case> lstComplianceRecommdOpenCases = [SELECT Id FROM Case WHERE AccountId=: accountId AND Status != 'Closed' AND RecordType_DeveloperName__c = 'Compliance_Query' AND Type = 'Compliance' ];
        String regionName = accObj.Region_Flag__c;
        if(caseModel == null || caseModel == ''){
            caseModel = accObj.Subscription_Model__pc;
        }
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }

        //***************************** Existing Compliance Recommendation ****************
        if(lstComplianceRecommdOpenCases != null && lstComplianceRecommdOpenCases.size()>0){
            raisonError = 'Existing Compliance Recommendation application';
        }

        //***************************** Credit Cards ****************
        if(raisonError == null ){
            HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards', accObj.CIF__pc, accObj.PersonEmail, regionName);
            if(accObj.x_canary__pc != null ){
                req.setHeader('x-canary', accObj.x_canary__pc);
            }
            req.setTimeout(120000);
            System.debug('----->> REQUEST -->> '+req.getBody());
            Http http = new Http();
            HttpResponse response = http.send(req);
    
            if (response.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
                //toDo : what to do in case of errors ??
            }
            else
            {
                System.debug(response.getBody());
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
                
                List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
                System.debug('---> LIST Current Cards --> '+currCardsList);
                for(Object curCards : currCardsList){
                    Map<String,Object> mapRelatedCurrentCards = (Map<String, Object>)curCards;
                    String cardStatus = (String) mapRelatedCurrentCards.get('status');
                    if( cardStatus == 'ACTIVE' ){
                        raisonError = 'Active credit card';
                        break;
                    }
                }
            }
        }

        //***************************** Loans ****************
        if(raisonError == null ){
            HttpRequest req2 = con.createRequest('GET', System.Label.LoansOptionsAPIPath, accObj.CIF__pc, regionName);
            req2.setTimeout(60000);
            System.debug('Request Endpoint: ' +req2.getEndpoint());
            System.debug('Request Method: ' +req2.getMethod());
            System.debug('Request Body:'+req2.getBody());
            //Call Mock Response
            HttpResponse response2 = Loans_ServiceApiCallsEM.callLoansOptionsAPI(req2,200);//real api call
            //HttpResponse response = new Loans_ServiceApiCallsMock().callLoansOptionsAPI(req,200);
            if (response2.getStatusCode() != 200)
            {
                System.debug('The status code returned was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
                //toDo : what to do in case of errors ??
            }
            else
            {
                System.debug(response2.getBody());
                Map<String, Object> mm = (Map<String, Object>)JSON.deserializeUntyped(response2.getBody());
                Map<String, Object> mm1 = (Map<String, Object>)mm.get('data');
                System.debug('---> MAP mm1 --> '+ mm1);  // currentLoans,..
                
                List<Object> currLoansList = (List<Object>)mm1.get('currentLoans'); //Current Cards
                System.debug('---> LIST currLoansList --> '+currLoansList);
                for(Object curLoan : currLoansList){
                    Map<String,Object> mapRelatedcurLoan = (Map<String, Object>)curLoan;
                    String loanStatus = (String) mapRelatedcurLoan.get('status');
                    if( loanStatus == 'ACTIVE' ){
                        raisonError = 'Active loan';
                        break;
                    }
                }
            }
        }


        return raisonError;
    }
}