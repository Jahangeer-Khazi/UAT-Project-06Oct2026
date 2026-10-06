/* 		Organization : ABC Bank
* 		Created By: Jahangeer Mohammed
*		Created Date: 28-03-2022
* 		Change History: 
*			  
*/
public class DebitCardHandler {
    public static void handlerAfterCaseUpdate(List<Case> lstCase){
        Set<Id> setDebitCardCaseForReleaseHoldByMaker = new Set<Id>();
        Set<Id> setDebitCardCaseForReleaseHoldByChecker = new Set<Id>();
        
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            if(caseObj.Type == 'Release Hold Amount' && (caseObj.Sub_Type__c == 'Release International Transfer' || caseObj.Sub_Type__c == 'Release Fawri Transfer') &&
               caseObj.cc_Maker__c == 'Release Hold' && caseObj.cc_Maker__c != caseOldObj.cc_Maker__c){
                   setDebitCardCaseForReleaseHoldByMaker.add(caseObj.id);
               }
            
            if(caseObj.Type == 'Release Hold Amount' && caseObj.Sub_Type__c == 'Release Debit Card Transaction' && caseObj.cc_Checker_Result__c == 'Release Hold' &&
               caseObj.cc_Checker_Result__c != caseOldObj.cc_Checker_Result__c){
                   setDebitCardCaseForReleaseHoldByChecker.add(caseObj.id);
               }
        }
        if(setDebitCardCaseForReleaseHoldByMaker.size() > 0){
            DebitCardHandlerAPI.debitCardCaseUpdate(setDebitCardCaseForReleaseHoldByMaker);
        }
        if(setDebitCardCaseForReleaseHoldByChecker.size() > 0){
            DebitCardHandlerAPI.debitCardCaseUpdate(setDebitCardCaseForReleaseHoldByChecker);
        }
    }
    public static void handlerBeforeCaseUpdate(List<Case> lstCase){
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseObj.id);
            if(caseObj.Email_Status__c != caseOldObj.Email_Status__c && caseObj.Email_Status__c == 'Email Sent' && caseObj.Type == 'Release Hold Amount' && caseObj.Sub_Type__c == 'Release Debit Card Transaction'){
                caseObj.Awaiting_Customer_Feedback__c = true;
               
            }
            if(caseObj.Email_Status__c != caseOldObj.Email_Status__c && caseObj.Email_Status__c == 'Email Received' && caseObj.Type == 'Release Hold Amount' && caseObj.Sub_Type__c == 'Release Debit Card Transaction'){
                caseObj.Awaiting_Customer_Feedback__c = false;
                caseObj.OwnerId = System.Label.MakerQueue;
                caseObj.cc_Is_Doc_Uploaded__c = true;
                caseObj.cc_Maker__c = '';
            }
             if(caseObj.Type == 'Release Hold Amount' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
                caseObj.Sub_Status__c == 'Pending'){
                System.debug('Checking Sub Status values from Other State ------> Pending');
                caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Not Changed';
                caseObj.LastCaseSubStatusChanged__c = System.now();
            }
             if(caseObj.Type == 'Release Hold Amount' && caseOldObj.Sub_Status__c != caseObj.Sub_Status__c &&
               caseObj.Sub_Status__c != 'Pending'){
                System.debug('Checking Sub Status values from Pending ------> Other State');
                caseObj.cc_Last_Sub_Status_Changed_Pending__c = 'Changed';
                caseObj.LastCaseSubStatusChanged__c = System.now();
            }
            if(caseObj.Type == 'Release Hold Amount' && caseOldObj.cc_Maker__c != caseObj.cc_Maker__c && caseObj.cc_Maker__c != ''){
                caseObj.Address_Updated_By__c = UserInfo.getUserId();
            }
            if(checkRecursive.runOnce() && caseObj.Type == 'Release Hold Amount' && caseObj.Sub_Type__c == 'Release Debit Card Transaction' && caseObj.Is_Doc_Dicrepancy__c == true && caseObj.Status == 'All Documents Uploaded' 
              && caseObj.Awaiting_Customer_Feedback__c == true && caseObj.cc_Is_Doc_Uploaded__c == false){
                caseObj.Awaiting_Customer_Feedback__c = false;
                caseObj.cc_Is_Doc_Uploaded__c = true;
                caseObj.OwnerId = System.Label.MakerQueue;
                caseObj.cc_Maker__c = '';
            }
              
        }
    }
    
}