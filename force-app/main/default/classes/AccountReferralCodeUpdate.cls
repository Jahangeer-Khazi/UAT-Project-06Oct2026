/**
 *  @author: Jayanth Manickam
 *  @date: 2022-10-03
 *  @description:
 *      generate unique, Update the referral code
 *
 *  Version History :
 *  2022-10-03
 *  initial version
 *
 */

public class AccountReferralCodeUpdate {
    
    @future
    public static void processAccountReferralCode(String jsonString){
        List<Account> accountList = (List<Account>)Json.deserialize(jsonString,List<Account>.class);
        getReferalCode(accountList);
    }
    
    private static void getReferalCode( List<Account> accountList) {
        try{
            String genRefCode = CifGenerator.generateRandomString();	
            List<Account> genAcc = [Select id from Account where Referral_Code__pc =: genRefCode LIMIT 1];	
            if(genAcc.size() == 0){
                accountList[0].Referral_Code__pc=genRefCode;
                update accountList;
            }else {
                getReferalCode(accountList);         
            }
        }catch(exception ex){
            System.debug('AccountReferralCodeUpdate--->'+ex.getLineNumber()+'---'+ex.getMessage());
        }
    }
}