/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-11-2022
*       Change History: 
						#CH01# #Jahangeer Mohammed# #23-03-2025# Added Logic for Pop Up Notification
*/
public class walkInCustomerHandler {
    
    public static void handlerBeforeCaseInsert(List<Case> lstCase){
        Map<Id,Case> mapIdRelatedCase = new Map<Id,Case>();
        //CH01: Start
        Map<Id,Case> mapIdRelatedPopUpCase = new Map<Id,Case>();
        //CH01: END
        List<Case> caseCount = [SELECT Id, Type,CreatedDate FROM Case where Type = 'Walkin Customer' AND Status = 'New' AND CreatedDate = TODAY ];
        //CH01: Start
        List<Case> caseCountPopUp = [SELECT Id, Type,CreatedDate FROM Case where Type = 'Walkin Customer Pop Up' AND Status = 'New' AND CreatedDate = TODAY ];
		//CH01: END
        for(Case caseObj : lstCase){
            if(caseObj.Type == 'Walkin Customer' && caseObj.Status == 'New'){
                mapIdRelatedCase.put(caseObj.Id,caseObj);
            }
            //CH01: Start
            else if(caseObj.Type == 'Walkin Customer Pop Up' && caseObj.Status == 'New'){
                mapIdRelatedPopUpCase.put(caseObj.Id,caseObj);
            }
            //CH01: END
        }
        if(!mapIdRelatedCase.isEmpty()){
            for(Id caseIds : mapIdRelatedCase.keySet()){
                Case c = mapIdRelatedCase.get(caseIds);
                c.Total_Walkin_Cases__c = caseCount.size();
            }
        }
        //CH01: Start
        if(!mapIdRelatedPopUpCase.isEmpty()){
            for(Id caseIds : mapIdRelatedPopUpCase.keySet()){
                Case c = mapIdRelatedPopUpCase.get(caseIds);
                c.Total_Walkin_Cases__c = caseCountPopUp.size();
            }
        }
        //CH01: END
    }
    public static void handlerBeforeCaseUpdate(List<Case> lstCase){
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            //CH01: Start Added Type = Walkin Customer Pop Up
            if((caseObj.Type == 'Walkin Customer' || caseObj.Type == 'Walkin Customer Pop Up') && caseObj.Assign_to_yourself__c != caseOldObj.Assign_to_yourself__c && caseObj.Assign_to_yourself__c == true){
                caseObj.OwnerId = UserInfo.getUserId();
            }
            //CH01: END
        }
    }
    
    public static void handlerAfterCaseUpdate(List<Case> lstCase){
        set<Id> setCasesWalkinCustomerInNewStatus = new Set<Id>();
		set<Id> setCasesTakingOwnershipForWalkinCustomer = new Set<Id>();
        for(Case caseObj : lstCase){
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            //CH01: Start Added Type = Walkin Customer Pop Up
             if((caseObj.Type == 'Walkin Customer' || caseObj.Type == 'Walkin Customer Pop Up') && caseObj.Status == 'New' && caseObj.Token_Counter__c != caseOldObj.Token_Counter__c && caseObj.Token_Counter__c != 0 && caseObj.Token_Counter__c != null){
                 setCasesWalkinCustomerInNewStatus.add(caseObj.Id);
                 System.debug('Walkin Customer Case Creation:'+setCasesWalkinCustomerInNewStatus);
                 System.debug('Token Counter:'+caseObj.Token_Counter__c);
                 System.debug('Supplied Phone:'+caseObj.SuppliedPhone);
             }
            //CH01: END
             //CH01: Start Added Type = Walkin Customer Pop Up
            if((caseObj.Type == 'Walkin Customer' || caseObj.Type == 'Walkin Customer Pop Up') && caseObj.Counter_Number__c != caseOldObj.Counter_Number__c && caseObj.Counter_Number__c != '' && caseObj.Assign_to_yourself__c == true){
                setCasesTakingOwnershipForWalkinCustomer.add(caseObj.Id);
               
            }
            //CH01: END
        }
        if(!setCasesWalkinCustomerInNewStatus.isEmpty()){
             walkInCustomerSendingSMSReminders.sendSMSRemindersOnCaseCreation(setCasesWalkinCustomerInNewStatus);
        }
        if(!setCasesTakingOwnershipForWalkinCustomer.isEmpty()){
            walkInCustomerSendingSMSReminders.sendSMSRemindersOnChangingOwnership(setCasesTakingOwnershipForWalkinCustomer);
        }
    }

}