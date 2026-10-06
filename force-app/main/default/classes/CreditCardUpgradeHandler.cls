/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 23-10-2023
*       Change History:
						#CH01# #Jahangeer Mohammed# #13-08-2025# Added Logic for Credit Card Upgrade Cases(NBA-15639)
*/
public class CreditCardUpgradeHandler {
    
    public static void handlerBeforeCaseCreation(List<Case> lstCase){
        //CH01: Start
        List<Case> lstNewCase = new List<Case>();
        Set<Id> setNewAccIds = new Set<Id>();
        Map<Id,List<Case>> mapAccountContainingUpgradeCases = new Map<Id,List<Case>>();
        //CH01: END

        for(Case cs : lstCase){
            if(cs.Type == 'Credit Card Upgrade' && (cs.Sub_Type__c == 'Upgrade to ila World' || cs.Sub_Type__c == 'Upgrade to ila World Elite')){
                System.debug('Inside Credit Upgrade Maker Queue in Before Insert');
                cs.OwnerId = System.Label.Credit_Upgrade_Maker_Queue;
            }
            //CH01: Start
            else if(cs.Type == 'Credit Card Upgrade' && cs.Sub_Type__c == 'Credit Card Upgrade - No Limit Increase'){
                lstNewCase.add(cs);
                setNewAccIds.add(cs.AccountId);
               
            }
            //CH01: END
        }//for loop Ends
        //CH01: Start
        if(setNewAccIds.size()>0){
            System.debug('Account Ids:'+setNewAccIds);
            for(Case c : [Select id,Type,Sub_Type__c,AccountId,Status from Case where Status NOT IN('Closed') AND Type IN('Credit Card Upgrade') AND AccountId IN :setNewAccIds]){
                System.debug('Credit Card Upgrade:'+c);
                if(c.Type == 'Credit Card Upgrade' && c.Sub_Type__c == 'Credit Card Upgrade - No Limit Increase'){
                    if(mapAccountContainingUpgradeCases.containsKey(c.AccountId)){
                        mapAccountContainingUpgradeCases.get(c.AccountId).add(c);
                    }
                    else{
                        mapAccountContainingUpgradeCases.put(c.AccountId,new List<Case>{c});
                    } 
                }
            }
        }
        if(lstNewCase.size()>0){
            for(Case c : lstNewCase){
                if(mapAccountContainingUpgradeCases.containsKey(c.AccountId)){
                        c.addError('Customer has an open credit card upgrade case');
                 }
            }
        }
        //CH01: END
    }
    public static void handlerBeforeCaseUpdate(List<Case> lstCase){
        for(Case caseObj : lstCase){
           Case caseOldObj = (Case)trigger.oldMap.get(caseObj.id);
            if(caseObj.Type == 'Credit Card Upgrade' && (caseObj.Sub_Type__c == 'Upgrade to ila World' || caseObj.Sub_Type__c == 'Upgrade to ila World Elite') &&
              caseOldObj.cc_Maker__c != caseObj.cc_Maker__c && caseObj.cc_Maker__c == 'Cancel Request'){
                System.debug('Inside Credit Upgrade Maker Queue Cancelled Request Before Update');
                caseObj.Sub_Status__c = 'Cancelled';
                caseObj.Status = 'Closed';
                caseObj.cc_Maker_Result_Date_Time__c = System.now();
            }
        }
    } 
    public static void handlerAfterCaseUpdate(List<Case> lstCase){
        List<Case> lstCasesRouteToOperationsTeam = new List<Case>();
        List<Case> lstCasesBlockingCurrentCardANDCreatedNewCard = new List<Case>();
        List<case> lstCasesCancellingCurrentCardByOperations = new List<Case>();
        List<Case> lstUpdateCase = new List<Case>();
        
        for(Case caseObj : lstCase) {
            Case caseOldObj = (Case)trigger.oldMap.get(caseobj.id);
            if(caseObj.Type == 'Credit Card Upgrade' && (caseObj.Sub_Type__c == 'Upgrade to ila World' || caseObj.Sub_Type__c == 'Upgrade to ila World Elite') &&
              caseOldObj.cc_Maker__c != caseObj.cc_Maker__c && caseObj.cc_Maker__c == 'Send to Ops'){
                System.debug('Inside Credit Upgrade Maker Queue Send to Ops Request After Update');
                lstCasesRouteToOperationsTeam.add(caseObj);
                
            }//If Ends
            if(caseObj.Type == 'Credit Card Upgrade' && (caseObj.Sub_Type__c == 'Upgrade to ila World' || caseObj.Sub_Type__c == 'Upgrade to ila World Elite') &&
                caseObj.cc_Maker__c == 'Send to Ops' && caseObj.Operation_Result__c != caseOldObj.Operation_Result__c && caseObj.Operation_Result__c == 'Upgrade Completed'){
                System.debug('Inside Credit Card Operations Queue ------> Upgrade Completed ');
                lstCasesBlockingCurrentCardANDCreatedNewCard.add(caseObj);
                
            }//If Ends
            if(caseObj.Type == 'Credit Card Upgrade' && (caseObj.Sub_Type__c == 'Upgrade to ila World' || caseObj.Sub_Type__c == 'Upgrade to ila World Elite') &&
                caseObj.cc_Maker__c == 'Send to Ops' && caseObj.Operation_Result__c != caseOldObj.Operation_Result__c && caseObj.Operation_Result__c == 'Cancel Request'){
                System.debug('Inside Credit Card Operations Queue ------> Cancelling Current Card');
                lstCasesCancellingCurrentCardByOperations.add(caseObj);
                
            }//If Ends
            
        }//for loop Ends
        
        if(lstCasesRouteToOperationsTeam.size()>0){
            for(Case c : lstCasesRouteToOperationsTeam){
                Case cs = new Case(Id = c.Id);
                cs.OwnerId = System.Label.Credit_Card_Regular_Buyout;
                cs.cc_Maker_Result_Date_Time__c = System.now();
                cs.Sub_Status__c = 'In-Progress';
                cs.Status = 'In Progress';
                lstUpdateCase.add(cs);
            }
        }
        if(lstCasesBlockingCurrentCardANDCreatedNewCard.size()>0){
            for(Case c: lstCasesBlockingCurrentCardANDCreatedNewCard){
                Case cs = new Case(Id = c.id);
                cs.cc_Operations_Date_Time__c = System.now();
                cs.Sub_Status__c = 'Approved';
                cs.Status = 'Closed';
                lstUpdateCase.add(cs);
            }
        }
        if(lstCasesCancellingCurrentCardByOperations.size()>0){
            for(Case c: lstCasesCancellingCurrentCardByOperations){
                Case cs = new Case(Id = c.id);
                cs.cc_Operations_Date_Time__c = System.now();
                cs.Sub_Status__c = 'Cancelled';
                cs.Status = 'Closed';
                lstUpdateCase.add(cs);
            } 
        }
        if(lstUpdateCase.size()>0){
            update lstUpdateCase;
        }
        
    }
    public static void handlerAfterCaseCreation(List<Case> lstCase){
        List<Case> lstNewCase = new List<Case>();
        Set<Id> setNewAccIds = new Set<Id>();
        Map<Id,List<Case>> mapAccountContainingUpgradeCases = new Map<Id,List<Case>>();
        //Credit Card Application,Credit Limit Increase Application,Credit Card Cash Collateral Application,Cash Collateral Credit Limit Increase Application,Credit Card FCR,Credit Card Services,Credit Card Supplementary Application
        String creditCardTypes = System.Label.CREDIT_CARD_TYPES;
        Set<String> creditCardType = new Set<String>();
        
        if(!String.isBlank(creditCardTypes)){
            for (String typeValue : creditCardTypes.split(',')) {
                creditCardType.add(typeValue.trim());
            }
        }
        for(Case cs : lstCase){
            if(creditCardType.contains(cs.Type) && cs.Region_Flag__c == 'Bahrain'){
                lstNewCase.add(cs);
                setNewAccIds.add(cs.AccountId);
            }
        }//for loop Ends
        //CH01: Start
        if(setNewAccIds.size()>0){
            System.debug('Account Id is:'+setNewAccIds);
            for(Case c : [Select id,Type,Sub_Type__c,Region_Flag__c,AccountId,Status from Case where Status NOT IN('Closed') AND Type IN('Credit Card Upgrade') AND AccountId IN :setNewAccIds]){
                System.debug('Credit Card Upgrade:'+c);
                if(c.Type == 'Credit Card Upgrade' && c.Sub_Type__c == 'Credit Card Upgrade - No Limit Increase' && c.Region_Flag__c == 'Bahrain'){
                    if(mapAccountContainingUpgradeCases.containsKey(c.AccountId)){
                        mapAccountContainingUpgradeCases.get(c.AccountId).add(c);
                    }
                    else{
                        mapAccountContainingUpgradeCases.put(c.AccountId,new List<Case>{c});
                    } 
                }
             }//for loop Ends
        }
        if(lstNewCase.size()>0){
            for(Case c : lstNewCase){
                if(mapAccountContainingUpgradeCases.containsKey(c.AccountId)){
                    List<Case> upgList = mapAccountContainingUpgradeCases.get(c.AccountId);
                    if(upgList.size()>0){
                        c.addError('Customer has an open credit card upgrade case');
                    }
                }
            }
        }
        
    }
}