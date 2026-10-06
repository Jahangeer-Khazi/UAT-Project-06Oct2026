/**
 * Created by Himanshu on 15/12/2021.
 */
public class Util {
    public static void setOwnerQueue(List<Queue_IDs__mdt> queueIds, Map<Id, String> caseToRegion, Case objCase, String queueName) {
        System.debug('1');
        for (Queue_IDs__mdt queueId : queueIds) {
            String caseRegion = caseToRegion.get(objCase.Id);
            System.debug('2 -->'+caseRegion);
            if (caseRegion == queueId.Region__c && queueId.Queue_Name__c == queueName) {
                objCase.OwnerId = queueId.Queue_ID__c;
                System.debug('3 -->'+objCase);
                break;
            }
        }
    }

     public static void setOwnerQueueFromAccount(List<Queue_IDs__mdt> queueIds, Map<Id, String> accountToRegion, Case objCase, Account acc,  String queueName) {
        for (Queue_IDs__mdt queueId : queueIds) {
            String accRegion = accountToRegion.get(acc.Id);
            if (accRegion == queueId.Region__c && queueId.Queue_Name__c == queueName) {
                objCase.OwnerId = queueId.Queue_ID__c;
                break;
            }
        }
    }
     public static void setOwnerQueueFromCase(List<Queue_IDs__mdt> queueIds, Map<Id, String> caseToRegion, Case objCase, Case originalCase,  String queueName) {
        for (Queue_IDs__mdt queueId : queueIds) {
            String caseRegion = caseToRegion.get(originalCase.Id);
            if (caseRegion == queueId.Region__c && queueId.Queue_Name__c == queueName) {
                objCase.OwnerId = queueId.Queue_ID__c;
                break;
            }
        }
    }
    public static Map<Id, String> getQueuesCustomMetadata(List<Case> lstCase){
        Map<Id, String> caseToRegion = new Map<Id, String>();
        for(Case cItem :lstCase) {
              //get the case region
              caseToRegion.put(cItem.Id, cItem.Region_Flag__c);
         }
        return caseToRegion;
    }
     public static Map<Id, String> getAccountQueuesCustomMetadata(List<Account> lstAccount){
        Map<Id, String> accountToRegion = new Map<Id, String>();
        for(Account cItem :lstAccount) {
              //get the case region
              accountToRegion.put(cItem.Id, cItem.Region_Flag__c);
         }
        return accountToRegion;
    }
}