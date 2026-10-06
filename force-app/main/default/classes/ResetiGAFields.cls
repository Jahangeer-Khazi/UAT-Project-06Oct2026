/* 		Organization : ABC Bank
* 		Created By: 
*		Created Date:23-11-2022
* 		Change History: 
* 	 				
*
*			  
*/
public class ResetiGAFields {
    public static void cleariGAFields(String accId){
    List<Account> accList = new List<Account>();
        for(Account acc : [Select Id,iGA_Mobile_Number__pc,iGA_Email__pc,iGA_ID_Number__pc,iGA_Document_Country__pc,iGA_English_First_Name__pc,
                           iGA_English_Middle_Name_1__pc,iGA_English_Middle_Name_2__pc, iGA_English_Middle_Name_3__pc, iGA_English_Middle_Name_4__pc,
                           iGA_English_Last_Name__pc, iGA_Arabic_First_Name__pc, iGA_Arabic_Middle_Name_1__pc,iGA_Arabic_Middle_Name_2__pc,
                           iGA_Arabic_Middle_Name_3__pc,iGA_Arabic_Middle_Name_4__pc,iGA_Arabic_Last_Name__pc,iGA_Gender__pc,iGA_Date_of_Birth__pc,
                           iGA_Nationality__pc,iGA_Passport_Number__pc,iGA_Passport_Expiry_Date__pc,iGA_Residency_Permit_Number__pc,iGA_Residency_Permit_Expiry__pc,
                           iGA_Occupation__pc,iGA_Employment_Status__pc, iGA_Employer_Name__pc, iGA_Employer_Building_Number__pc, iGA_Employer_Building_Alpha__pc,
                           iGA_Mailing_Block_Number__pc,iGA_Mailing_Flat_Number__pc,iGA_Mailing_Road_Number__pc,iGA_Employer_Flat_Number__pc,
                           iGA_Employer_Road_Number__pc,iGA_Employer_Block_Number__pc,iGA_Mailing_Building_Number__pc,iGA_Mailing_Building_Alpha__pc,
                           pr_ReviewStatus__c,pr_NextReviewReason__c,pr_NextReviewDate__c,iGA_Place_of_Birth__pc,iGA_Mailing_Country__pc,iGA_Marital_Status__pc from Account where Id =: accId]){
                               
                               acc.iGA_Mobile_Number__pc = '';
                               acc.iGA_Email__pc = '';
                               acc.iGA_ID_Number__pc = '';
                               acc.iGA_Document_Country__pc = '';
                               acc.iGA_English_First_Name__pc = '';
                               acc.iGA_English_Middle_Name_1__pc = '';
                               acc.iGA_English_Middle_Name_2__pc = '';
                               acc.iGA_English_Middle_Name_3__pc = '';
                               acc.iGA_English_Middle_Name_4__pc = '';
                               acc.iGA_English_Last_Name__pc = '';
                               acc.iGA_Arabic_First_Name__pc = '';
                               acc.iGA_Arabic_Middle_Name_1__pc = '';
                               acc.iGA_Arabic_Middle_Name_2__pc = '';
                               acc.iGA_Arabic_Middle_Name_3__pc = '';
                               acc.iGA_Arabic_Middle_Name_4__pc = '';
                               acc.iGA_Arabic_Middle_Name_4__pc = '';
                               acc.iGA_Arabic_Last_Name__pc = '';
                               acc.iGA_Gender__pc = '';
                               acc.iGA_Date_of_Birth__pc = '';
                               acc.iGA_Nationality__pc = '';
                               acc.iGA_Passport_Number__pc = '';
                               acc.iGA_Passport_Expiry_Date__pc = '';
                               acc.iGA_Residency_Permit_Number__pc = '';
                               acc.iGA_Residency_Permit_Expiry__pc = '';
                               acc.iGA_Occupation__pc = '';
                               acc.iGA_Employment_Status__pc = '';
                               acc.iGA_Occupation__pc = '';
                               acc.iGA_Employer_Name__pc = '';
                               acc.iGA_Occupation__pc = '';
                               acc.iGA_Employer_Building_Number__pc = '';
                               acc.iGA_Employer_Building_Alpha__pc = '';
                               acc.iGA_Mailing_Block_Number__pc = '';
                               acc.iGA_Mailing_Flat_Number__pc = '';
                               acc.iGA_Employer_Flat_Number__pc = '';
                               acc.iGA_Employer_Road_Number__pc = '';
                               acc.iGA_Mailing_Road_Number__pc = '';
                               acc.iGA_Employer_Block_Number__pc = '';
                               acc.iGA_Mailing_Building_Number__pc = '';
                               acc.iGA_Mailing_Building_Alpha__pc = '';
                               acc.pr_ReviewStatus__c = '';
                               acc.pr_NextReviewReason__c = '';
                               acc.pr_NextReviewDate__c = null;
                               acc.iGA_Place_of_Birth__pc = '';
                               acc.iGA_Mailing_Country__pc = '';
                               acc.iGA_Marital_Status__pc = '';
                               accList.add(acc);
                              
                               
                           }//for loop Ends
        if(accList.size()>0){
            update accList;
        }
        
    }
    
    public static String toProperCase(String value) {
        // Normalize - Convert to lowercase
        value = value.toLowerCase();

        // Hold each word
        List<String> pieces = new List<String>();

        // Split
        for(String s : value.split(' ')) {
            // Capitalize each piece
            s = s.capitalize();

            // Add to pieces
            pieces.add(s);
        }
		System.debug('Pieces of String:'+pieces);
        // Join
        return String.join(pieces, ' ');
    }
}