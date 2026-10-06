/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 04-17-2024
 * @last modified by  : Elmustapha ELGARNI
**/
public without sharing class Loans_NewLoanApplicationController {

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response callLoanOptionsAPI(final String customerId, Final String caseModel) {

        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.callLoansOptionsAPI(customerId, caseModel);
        System.debug('callLoanOptionsAPI##'+response);
        
        return response;
        
        
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getUserApplicationInfoAPI(final String customerId, final String loanProductConfigurationId, Final String caseModel) {

        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.getUserApplicationInfoAPI(customerId, loanProductConfigurationId, caseModel);
        System.debug('getUserApplicationInfoAPI##'+response);
        
        return response;
    }


    
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getExistingLiabilitiesAPI(final String customerId, Final String caseModel, Final Decimal loanAmount, Final Decimal loanDuration, Final Decimal loanMonthlyInstalment) {
        //UATNB-211338 : change function signature adding Decimal loanAmount, Decimal loanDuration, Decimal loanMonthlyInstalment
        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.getExistingLiabilitiesAPI(customerId, caseModel,loanAmount, loanDuration, loanMonthlyInstalment);
        System.debug('getExistingLiabilitiesAPI##'+response);
        return response;
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getCustomerProductsAPI(final String customerId, Final String caseModel) {

        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.getCustomerProductsAPI(customerId, caseModel);
        System.debug('getCustomerProductsAPI##'+response);
        
        return response;
        
    }

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response getLoanCalculatorMatrixAPI(final String customerId, Final String caseModel) {

        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.getLoanCalculatorMatrixAPI(customerId, caseModel);
        System.debug('getLoanCalculatorMatrixAPI##'+response);
        
        return response;
        
    }

    @AuraEnabled
    public static Account getAccountRecord(String accountId) {
        System.debug('getAccountRecord called with ID: ' + accountId);
        
        if(String.isBlank(accountId)) {
            throw new AuraHandledException('Account ID is required');
        }
        
        try {
            Account acc = [SELECT Id, Name, CIF__pc, Subscription_Model__pc,Nationality__pc,Segment__pc,Region_Flag__pc
                          FROM Account 
                          WHERE Id = :accountId 
                          LIMIT 1];
            
            System.debug('Found account: ' + acc);
            return acc;
        } 
        catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            throw new AuraHandledException('Error fetching account: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String, Object> calculatorApiCall (Map<String,Object> param)
    {
        return LTNG056_LoansCalculatorController.calculatorApiCall(param);
    }

    @AuraEnabled
    public static String checkExistanceOfComplianceCase(String accountId) {
        System.debug('checkExistanceOfComplianceCase  -- accountId -->' +accountId );
        String raisonError = null;
        List <Case> lstComplianceRecommdOpenCases = [SELECT Id FROM Case WHERE AccountId=: accountId AND Status != 'Closed' AND RecordType_DeveloperName__c = 'Compliance_Query' AND Type = 'Compliance' ];
        
        if(lstComplianceRecommdOpenCases != null && lstComplianceRecommdOpenCases.size()>0){
            raisonError = 'Existing Compliance Recommendation application';
        }

        return raisonError;
    }
}