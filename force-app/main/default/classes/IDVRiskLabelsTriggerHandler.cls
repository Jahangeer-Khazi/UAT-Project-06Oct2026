/**
 * @author Imane Tsioucha
 * @date 18/05/2023
 */
public with sharing class IDVRiskLabelsTriggerHandler {
    public static  void fetchAccountWhenIDVinserted(List<IDV_RiskLabels__c> idvList) {
        list <Account> accList=new list <Account>();
        List<Id> idIdvList=new List<Id>();
        List<String> CIFIdvList=new List<String>();
        List<IDV_RiskLabels__c> myIdvList=new List<IDV_RiskLabels__c>();


      for(IDV_RiskLabels__c idv: idvList){
          if(idv.CIF__c!=null)
          {
              idv.Customer__c = [Select id from Account where CIF__pc =: idv.CIF__c limit 1].id;
          }
      }
    }
}