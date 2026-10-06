/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 08-01-2023
* 		Change History: 
*             #CH02 : #Imane Tsioucha# #22-02-2024# add x-canary header
*/
public class SupplementaryCardController {
    @AuraEnabled
    public static SupplementaryCardApprovedDetails approveSupplementaryCardApi(Id caseId){
       SupplementaryCardApprovedDetails cardApprovedDetail= new SupplementaryCardApprovedDetails();
       ApiConnection con = new ApiConnection();
       Case caseObj = DM002_Case.getListByIds(new Set<Id>{caseId}).get(0);
        
       String regionName = caseObj.Region_Flag__c;
       if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
       }
	   HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);

        if(caseObj.Account.x_canary__pc != null){
           request2.setHeader('x-canary', caseObj.Account.x_canary__pc); //CH02
        }

       request2.setTimeout(120000);
       HttpResponse suppCardResp = SM001_ApiCalls.callApiToCreateSupplementaryCardInVPlus(request2,caseObj);
       if(suppCardResp.getStatusCode() != 200){
            System.debug('The status code returned was not expected: ' + suppCardResp.getStatusCode() + ' ' + suppCardResp.getStatus());
            insert SM001_ApiCalls.setSystemAction(request2.getBody(),suppCardResp.getBody(),
                                       'callout:NeoBank_Endpoint/api/v1/credit-cards/request?language=en&unit=neo','PUT',
                                        caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,suppCardResp.getStatusCode(),
                                        'Credit Card Supplemntary Application -- call api to create supplementary card in V+ ', 'Credit Card');
	   }
       else{
            Supplementary_Card__c suppCardObj = [SELECT Id FROM Supplementary_Card__c WHERE Related_Case__c =: caseObj.Id LIMIT 1 ]; 
 			suppCardObj.Status__c = 'Active';
            suppCardObj.sc_ScreeningResult__c = 'PASS';
           
            caseObj.Status = 'Closed';
            caseObj.Sub_Status__c = 'Approved';
            caseObj.cc_Application_Stages__c = 'Completed';
            caseObj.cc_CRM_Stage__c = 'APPROVED';
           	if(caseObj.Approve_Card_Using_API__c == true){
            	caseObj.Approve_Card_Using_API__c = false;
            }
            update caseObj;
            update suppCardObj;
           
           cardApprovedDetail.successMessageFromApi = 'Supplementary Card approved successfully!';
            
       }
       return cardApprovedDetail;  
    }
    
    public class SupplementaryCardApprovedDetails {
    	@AuraEnabled 
        public String successMessageFromApi  {get; set;}
    }

}