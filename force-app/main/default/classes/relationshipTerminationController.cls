/*    Organization : ABC Bank
 *      Created By: Prashant Kulshrestha
 *      Created Date: 11-01-2022
 *      Change History: 
 *          #CH01 : Aniss Mbarki add x-canary on header http request
 *            
*/

public class relationshipTerminationController {
    private static ApiConnection con = new ApiConnection();
    
    @AuraEnabled
    public static void republishedData(string objectName, string recordId){
        List<Case> lstUpdateCase = new List<Case>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        //#CH01 : add Account.x_canary__pc
        List<Case> lstCase = [Select id,Unit_Termination__c,Account.x_canary__pc,Region_Flag__c,accountId, Account.CIF__pc, Account.PersonEmail, status, Sub_Status__c, Type, Sub_Type__c, Has_Active_Term_Deposit__c, Has_Hold_s_on_Kanz__c, Has_Processed_International_Transfer_s__c, Has_Open_Dispute_Case_s__c, Relationship_Termination_Button_Checks__c,Eligible_for_Termination__c,Has_Hold_s_on_Any_Hassala__c,cc_Has_existing_credit_card__c,Has_Hold_s_on_Any_Account_s__c,A_Member_or_Admin_of_Active_Jamiyah_s__c,Case_Model__c from Case where id =: recordId];
        
        //check if customer has any open dispute cases under the model which will be terminated and update the flag “Has open dispute case(s)“
        List<Case> disputeCases = [SELECT Id FROM Case WHERE accountId =: lstCase.get(0).accountId AND RecordType.DeveloperName = 'Issue' AND 
                                    Type = 'Case Management' AND Status != 'Closed' ];

        System.debug('disputeCases LIST@@:'+disputeCases);
        System.debug('CASE LIST:'+lstCase);
        
        
        for(Case objCase : lstCase){
            
            if(objCase.Unit_Termination__c == 'both'){
                CaseProductWrapper ilaResponse = customerProductsValidation('ila',objCase,!disputeCases.isEmpty());
                CaseProductWrapper alburaqResponse = customerProductsValidation('alburaq',objCase,!disputeCases.isEmpty());
                
                objCase.Eligible_for_Termination__c = ilaResponse.eligibleTermination || alburaqResponse.eligibleTermination;
                objCase.Has_Open_Dispute_Case_s__c = ilaResponse.hasOpenDisputeCases || alburaqResponse.hasOpenDisputeCases;
                objCase.Has_Hold_s_on_Any_Hassala__c = ilaResponse.hasHassala || alburaqResponse.hasHassala;
                objCase.Has_Hold_s_on_Kanz__c = ilaResponse.hasKanz || alburaqResponse.hasKanz;
                objCase.Has_Hold_s_on_Any_Account_s__c = ilaResponse.hasHoldAccount || alburaqResponse.hasHoldAccount;
                objCase.Has_Active_and_Funded_Account_s_Not_Ma__c = ilaResponse.hasFundedAccount || alburaqResponse.hasFundedAccount;
                objCase.A_Member_or_Admin_of_Active_Jamiyah_s__c = ilaResponse.hasJamiyah || alburaqResponse.hasJamiyah;
                objCase.Has_Active_Term_Deposit__c = ilaResponse.hasTermDeposit || alburaqResponse.hasTermDeposit;
                objCase.cc_Has_existing_credit_card__c = ilaResponse.hasCreditCard || alburaqResponse.hasCreditCard;
                lstUpdateCase.add(objCase);
            }
            else {
                
                String strUnit = objCase.Unit_Termination__c == 'ila' ? 'ila' : 'alburaq';
                CaseProductWrapper response = customerProductsValidation(strUnit,objCase,!disputeCases.isEmpty());
                
                objCase.Eligible_for_Termination__c = response.eligibleTermination;
                objCase.Has_Open_Dispute_Case_s__c = response.hasOpenDisputeCases;
                objCase.Has_Hold_s_on_Any_Hassala__c = response.hasHassala;
                objCase.Has_Hold_s_on_Kanz__c = response.hasKanz;
                objCase.Has_Hold_s_on_Any_Account_s__c = response.hasHoldAccount;
                objCase.Has_Active_and_Funded_Account_s_Not_Ma__c = response.hasFundedAccount;
                objCase.A_Member_or_Admin_of_Active_Jamiyah_s__c = response.hasJamiyah;
                objCase.Has_Active_Term_Deposit__c = response.hasTermDeposit;
                objCase.cc_Has_existing_credit_card__c = response.hasCreditCard;
                lstUpdateCase.add(objCase);
            }
        }
        
        
        if(lstUpdateCase.size()>0){
            System.debug('List Upsert:'+lstUpdateCase);
            update lstUpdateCase;
        }
        if(lstSA.size()>0)
            insert lstSA;
    }
    
    
    public static CaseProductWrapper customerProductsValidation(String unit,Case objCase,Boolean isDisputeCases){
        HttpRequest request = new HttpRequest();
        String regionName;
        
        if(unit == 'alburaq'){
            regionName = objCase.Region_Flag__c + '_alburaq';
        }else{
             regionName = objCase.Region_Flag__c;
        }
        
        request = con.createRequest('GET', '/api/v1/customer-products/closure/validation',regionName );
        
        if(objCase.Account.x_canary__pc != null){
            request.setHeader('x-canary', objCase.Account.x_canary__pc);
        }
        
        request.setHeader('customerId', objCase.Account.CIF__pc);
        request.setHeader('userId', objCase.Account.PersonEmail);
        request.setTimeout(120000);
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        CaseProductWrapper caseWrapper = new CaseProductWrapper();
        if(response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
        }
        else{
            List<Map<String, Object>> ProdCheck = new List<Map<String, Object>> ();
            Map<String, Object> deserializeResponse = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> dataMap = (Map<String, Object>)deserializeResponse.get('data');
            
            List<Object> dataMapeligibilityChecksStatus = (List<Object>)dataMap.get('eligibilityChecksStatus');
            
            if(dataMap.containsKey('relationshipTerminationEligible')){
                if((Boolean)dataMap.get('relationshipTerminationEligible') != false){
                    caseWrapper.eligibleTermination = TRUE;
                }
            }
            
            objCase.Relationship_Termination_Button_Checks__c = TRUE;
            for(Object obj : dataMapeligibilityChecksStatus)
            { 
                ProdCheck.add((Map<String, Object>)obj);
            }
            
            if(isDisputeCases){
            	caseWrapper.hasOpenDisputeCases = TRUE;
            }
            
            for(Map<String, Object> eachProdCheck : ProdCheck){
                if(eachProdCheck.get('productCheck') != null){
                    if(eachProdCheck.get('productCheck') == 'HASSALA'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasHassala = TRUE;
                    }
                    
                    if(eachProdCheck.get('productCheck') == 'KANZ'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasKanz = TRUE;
                    }
                    
                    if(eachProdCheck.get('productCheck') == 'ACCOUNTS_HOLD'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasHoldAccount = TRUE;
                    }
                    
                    if(eachProdCheck.get('productCheck') == 'ACCOUNTS_FUNDING'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasFundedAccount = TRUE;
                    }
                    
                    if(eachProdCheck.get('productCheck') == 'JAMEYA'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasJamiyah = TRUE;
                    }
                    
                    if(eachProdCheck.get('productCheck') == 'TERM_DEPOSIT'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasTermDeposit = TRUE;
                    }
                    
                    if(eachProdCheck.get('productCheck') == 'CREDIT_CARD'){
                        if(eachProdCheck.get('eligibilityStatus') != true)
                            caseWrapper.hasCreditCard = TRUE;
                    }
                }
            }
        }
        return caseWrapper;
    }
    
    public class CaseProductWrapper {
        public Boolean eligibleTermination { get; set; }
        public Boolean hasOpenDisputeCases { get; set; }
        public Boolean hasHassala { get; set; }
        public Boolean hasKanz { get; set; }
        public Boolean hasHoldAccount { get; set; }
        public Boolean hasFundedAccount { get; set; }
        public Boolean hasJamiyah { get; set; }
        public Boolean hasTermDeposit { get; set; }
        public Boolean hasCreditCard { get; set; }
        
        public CaseProductWrapper(){
            eligibleTermination = FALSE;
            hasOpenDisputeCases = FALSE;
            hasHassala = FALSE;
            hasKanz = FALSE;
			hasHoldAccount = FALSE;
			hasFundedAccount = FALSE;
            hasJamiyah = FALSE;
            hasTermDeposit = FALSE;
            hasCreditCard = FALSE;
        }
    }
}