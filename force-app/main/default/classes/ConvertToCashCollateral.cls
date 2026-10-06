/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date:  27/09/2022
*       Change History: 
*        			#CH01# #Jahangeer Mohammed# #14-05-2023# Added a Region Flag in SOQL Query
*/
public class ConvertToCashCollateral {
@AuraEnabled(cacheable=false)
    public static string fetchAccountId(String strcaseId){
        String accId;
        try
        {
            System.debug('Case Id in Apex:'+strcaseId);
            case cs=[Select id,AccountId,Status from case where id =:strcaseId LIMIT 1];
            accId = cs.AccountId;
            System.debug('Account Id in Apex:'+accId);
        }
        catch(system.Exception e){
            accId='Error:' +e.getMessage();
        }
        return accId;
    }
    
    @AuraEnabled(cacheable=false)
    public static Case fetchCurrentCase(String strcaseId){
        System.debug('Case Id in Apex:'+strcaseId);
        //CH01: Start Added Region Flag in SOQL
        case caseObj=[Select id,AccountId,Status,Sub_Status__c,cc_Requested_Card_Type__c,cc_Requested_Credit_Limit__c,cc_Balance_Transfer_Card_Provider__c,
                     cc_Balance_Transfer_Card_Number__c,cc_Balance_Transfer_Amount__c,cc_Name_on_the_Card__c,Region_Flag__c from case where id =:strcaseId LIMIT 1];
        return caseObj;
        //CH01: END
    }
}