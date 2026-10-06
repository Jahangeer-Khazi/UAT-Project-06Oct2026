/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 04-23-2024
 * @last modified by  : Elmustapha ELGARNI
**/
public without sharing class Loans_LoansListController {
    // @TestVisible // overwrite instance to provide custom connection in test class
    // private static ApiConnection con = new ApiConnection();
    // public static String regionName;


    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadLoansList(final String customerId, Final String caseModel) {
        System.debug('loadLoansList##'+customerId + ' ## '+caseModel);
        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.callLoansOptionsAPI(customerId, caseModel);
        // if(response.isSuccess == true && loanStatus != null && loanStatus != '' && loanStatus != 'All'){
        //     response = filterLoansList(response, loanStatus);
        // } 
        System.debug('loadLoansList##'+response);
        
        return response;
        
        
    }
    // omar Start

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadLoansEarlySettlmentApiList(final String customerId, Final String loanId, String caseModel) {
        System.debug('loadLoansEarlySettlementList##'+customerId + ' ## '+LoanId);
        ApiConnection.Response response = new ApiConnection.Response();
        response = Loans_ServiceManagerHandler.callLoansEarlySettlementAPI(customerId, loanId, caseModel);
        System.debug('loadLoansEarlySettlementList##'+response);
        return response;
        
    }
    // omar end 

    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response callLoanOptionsAPI(final String caseId) {

        List<Case> caseList = [SELECT id, Account.CIF__pc, Case_Model__c  FROM Case WHERE id =:caseId];

        ApiConnection.Response response = new ApiConnection.Response();

        response = Loans_ServiceManagerHandler.callLoansOptionsAPI(caseList[0].Account.CIF__pc, caseList[0].Case_Model__c);
        System.debug('callLoanOptionsAPI##'+response);
        
        return response;
        
        
    }

    //Aniss - Start
    @AuraEnabled(cacheable=false)
    public static ApiConnection.Response loadLoanTransactions(final String customerId,final String searchParametersJson, String regionName) {
        System.debug(' Customer ID ' +customerId+ 'search parameter ' +searchParametersJson+ ' regionName ' +regionName);
        
        ApiConnection.Response response = Loans_ServiceManagerHandler.loadLoanTransactions(customerId,searchParametersJson,regionName);
        
        System.debug('Response object:'+response);

        return response;
    }
    //Aniss - End
    
    
    @AuraEnabled(cacheable=false)
    public static Loans_ServiceManagerHandler.APIResponse getSimulationPaymentList(Id caseId,String regionName, Boolean saveLog) {
        
        System.debug('caseId getSimulationPaymentList ' +caseId );
        
        List<Case> cases = [SELECT Id,Customer_CIF__c,CaseAnnex__c, CaseAnnex__r.cx_ln_SimulationReference__c,case_Model__c,Region_Flag__c, RecordType_DeveloperName__c,Sub_Type__c,cc_PCI_Id__c FROM Case WHERE Id = :caseId];
        Loans_ServiceManagerHandler.APIResponse response = new Loans_ServiceManagerHandler.APIResponse();

        //this will show the SimulationPaymentList -> for LoanFinanceServiceRequest recordType and some subType ["'Partial Settlement'" ,"Top-up", "Restructuring"]
        if (cases.get(0).RecordType_DeveloperName__c == 'LoanFinanceServiceRequest' && (cases.get(0).Sub_Type__c == 'Partial Settlement' || cases.get(0).Sub_Type__c == 'Top-up' || cases.get(0).Sub_Type__c == 'Restructuring') ) {
            response = LoanServiceRequest_FinDetailsController.getSimulationPaymentList(caseId, cases.get(0).CaseAnnex__c);

        } // this will show active Loan payment list -> for LoanFinanceServiceRequest recordType and remaining subTypes 
        else if(cases.get(0).RecordType_DeveloperName__c == 'LoanFinanceServiceRequest'){
            String searchParametersJson = '{"arrangementId":"'+ cases.get(0).cc_PCI_Id__c +'", "type":"Schedule"}';

            regionName = cases.get(0).Region_Flag__c;
            if(cases.get(0).case_Model__c == 'alburaq'){
                regionName += '_alburaq';
            }
            System.debug('Expected Case -->'+cases.get(0));
            response = getPaymentList(cases.get(0).Customer_CIF__c,searchParametersJson,regionName);

        }
        //for other cases (loan application recordType)
        else {
            String customerId = cases.get(0).Customer_CIF__c;
            String simulationReference = cases.get(0).CaseAnnex__r.cx_ln_SimulationReference__c;
            String searchParametersJson = '{"crmCaseId": "'+caseId+'","simulationReference":"'+simulationReference+'","type": "Simulation"}';
            
            response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(caseId,customerId, searchParametersJson ,regionName , saveLog);
        
        }
        
        System.debug('Response getSimulationPaymentList object:'+ response);

        return response;
    }

    //Omar - start 
    @AuraEnabled(cacheable=false)
    public static Loans_ServiceManagerHandler.APIResponse getPaymentList(final String customerId , String searchParametersJson, String regionName) {
        System.debug('Customer ID getPaymentList ' +customerId + ' ... searchParametersJson  '+ searchParametersJson);
        
        Loans_ServiceManagerHandler.APIResponse response = Loans_ServiceManagerHandler.callGetLoanPaymentsSchedule(null,customerId, searchParametersJson, regionName,false);
        
        System.debug('Response object:'+response);

        return response;
    }
    //Omar - End

    @AuraEnabled
    public static String caseRecordType(String caseId) {
        try {
      
            Case caseRecord = [SELECT RecordType.Name FROM Case WHERE Id = :caseId LIMIT 1];
            
            if (caseRecord != null && caseRecord.RecordType != null) {
                System.debug('caseRecord >>> ' + caseRecord.RecordType.Name );
                return caseRecord.RecordType.Name;
            } else {
                return null;  
            }
        } catch (Exception e) {
          
            System.debug('Error: ' + e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static Case getCaseRecord(Id caseId) {
        System.debug('caseId ... '+ caseId);
        List<Case> caseList = [SELECT Id, case_Model__c,Type,Sub_Type__c, isSubmitted__c, cc_PCI_Id__c,CaseAnnex__r.cx_ln_Approved_Loan_Amount__c FROM Case WHERE Id = :caseId LIMIT 1];
        System.debug('caseList found!!! '+ caseList);
        
        if(caseList != null && caseList.size() > 0){
            System.debug('caseList Loan_Application_ID__c !!! '+ caseList[0].cc_PCI_Id__c);
            return caseList[0];
        }
        return null;
    }
    //omar start
    

    @AuraEnabled(cacheable=false)
    public static Map<String, Case> getApprovedCases(List<String> arrangementIds) {
        if (arrangementIds == null || arrangementIds.isEmpty()) {
            return new Map<String, Case>();
        }
        
        Set<String> approvedSubStatuses = new Set<String>{'Processed', 'Approved'};
        
        List<Case> cases = [
            SELECT Id, CaseNumber, Status, Sub_Status__c, cc_CRM_Stage__c, cc_PCI_Id__c
            FROM Case
            WHERE cc_PCI_Id__c IN :arrangementIds
                AND cc_CRM_Stage__c = 'APPROVED'
                AND Sub_Status__c IN :approvedSubStatuses
            ORDER BY CreatedDate DESC
        ];
        
        Map<String, Case> caseMap = new Map<String, Case>();
        for (Case c : cases) {
        
            if (c.cc_PCI_Id__c != null && !caseMap.containsKey(c.cc_PCI_Id__c)) {
                caseMap.put(c.cc_PCI_Id__c, c);
            }
        }
        
        return caseMap;
    }
    //omar end
}