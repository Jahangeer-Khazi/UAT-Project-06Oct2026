/**
 * @author Wissal benqezza
 * @date Création 07/02/2023
 * @date Modification
 * @description :
 * 
 */
public class BenefitPayAPIUpdateController {
    
     @InvocableMethod(label='Update BenefitPay API' description='The purpose of this service is to update the BenefitPay fields in the account object' callout=false )
    public static List<String> UpdateBenefitPayViaAPIFromFlow(List<Id> caseIds){

        //call future method
        UpdateBenefitPayViaAPI(new Set<Id>(caseIds));

        return null;
    }

    @future(callout=true)
    public static void UpdateBenefitPayViaAPI(Set<Id> caseIds){

        List<Case> cases = DM002_Case.getListByIds(caseIds);
        List<Account> accList = new List<Account>();
        List<System_Action__c> lst = new List<System_Action__c>();
       
        for(Case caseObj : cases){
        Account accObj = new Account(Id=caseObj.AccountId);
        String regionName=caseObj.Region_Flag__c;
        if(caseObj.Case_Model__c != null && caseObj.Case_Model__c == 'alburaq'){
            regionName += '_alburaq';
        }
        System.debug( 'Region name ===> '+ regionName);
        
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('PUT','/api/v1/customers',regionName); 
        HttpResponse response = SM001_ApiCalls.BenefitPayAPIUpdateApi(request,accObj,caseObj);
        
       
        if (response.getStatusCode() != 200  ) {
                 
         System.debug(' != 200');
         System_Action__c actionRecord = SM001_ApiCalls.setSystemAction((String)request.getBody(),response.getBody(),
                                                   request.getEndpoint(),request.getMethod(),
                                                   caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                   'BenefitPay - Customer Details API Update', 'BenefitPay - Customer Details API UpdateI'
                                               );
          lst.add(actionRecord);
            
        }else {
                
              accObj.Minor__pc= true;
              accObj.Guardian_CIF__pc= caseObj.Guardian_CIF__c;
              caseObj.status = 'closed';
              accList.add(accObj);
            }
        }

        if(lst != null && lst.size()>0){
            insert lst;
        }
        if(cases != null && cases.size()>0){
            update cases;
        }
        if(accList != null && accList.size()>0){
           update accList;
       }
    } 

}