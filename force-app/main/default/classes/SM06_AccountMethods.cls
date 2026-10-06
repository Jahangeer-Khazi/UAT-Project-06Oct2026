/**
 * @description       : 
 * @author            : Elmustapha ELGARNI
 * @group             : 
 * @last modified on  : 08-01-2023
 * @last modified by  : Elmustapha ELGARNI
**/
public without sharing class SM06_AccountMethods {

    // Define a wrapper class to hold the input parameters and output data
    public class AccountSearchParams {
        @InvocableVariable(label='Email' description='The Email of the customer' required=true)
        public String email;
        
        @InvocableVariable(label='Region Flag' description='The Region Flag of the customer' required=true)
        public String regionFlag;
    }
    
    @InvocableMethod(label='Get Customer by Email and Region Flag')
    public static List<String> getAccountByEmailAndRegionFlag(List<AccountSearchParams> searchParamsList) {
        
        List<Account> accounts = new List<Account>();
        List<String> strLst = new List<String>();

        if (searchParamsList != null && !searchParamsList.isEmpty()) {
            AccountSearchParams searchParams = searchParamsList[0];

            // Query for the Account based on the provided parameters
            accounts = [SELECT Id 
                        FROM Account 
                        WHERE RecordType.Name != 'Prospect' AND Archived__pc = false AND Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED'
                        AND PersonEmail = :searchParams.email AND Region_Flag__pc  = :searchParams.regionFlag ];
            
            if(accounts != null && accounts.size() > 0){
                strLst.add(String.valueOf(accounts[0].id));
            }
        }
        
        if(strLst != null && strLst.size() > 0){
            return strLst;
        }
        
        for(AccountSearchParams accParams : searchParamsList){
            strLst.add('');
        }
        return strLst;
    }
    
}