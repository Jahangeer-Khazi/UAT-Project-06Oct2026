/*     Organization : ABC Bank
*      Created By:
*      Created Date:5/11/2022
*      Description:Code to assign sales agent to the credit card application
*/

public class creditCardCaseController {
    @AuraEnabled
    public static List<Case> getCases() {
        List<Case> cccases = [SELECT Id,Subject,Status,Contact_Name__c,Type,Sales_Agent__c,cc_Case_Create_Date_Time__c,cc_Application_Submission_Date_Time__c,CreatedDate,ClosedDate,Case_Nature__c,Customer_CIF__c,Sub_Status__c FROM Case Where Sales_Agent__c='' AND
                              Sub_Status__c IN('In Progress','New','Pending') AND recordtype.Name IN ('Credit Card','Credit Card Supplementary','Credit Card Cash Collateral - Regular','Prepaid Credit Card') AND
                              Type IN ('Credit Card Application','Credit Card Supplementary Application','Credit Card Cash Collateral Application','Credit Card Prepaid Application') AND cc_Application_Submission_Date_Time__c<Last_N_Days:14 Order by cc_Application_Submission_Date_Time__c Desc ];
        return cccases;
    }
    
    @AuraEnabled
    public static void assignCases(List<case>assignedSA){
        List<CaseShare> cslist = New List<CaseShare>();
        If(!assignedSA.isEmpty()){
            Update assignedSA; 
        }
        
    }
}