/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 04-01-2024
*       Change History: 
*                   
*/
public class InvestmentQuestionnaireTriggerHandler {
      public static void handlerAfterQuestionnaireCreation(List<Bonds_Sukuk_Questionnaire__c> lstQuest){
          List<Account> lstAccountToUpdate = new List<Account>();
          List<Bonds_Sukuk_Questionnaire__c> lstQuestionnaire = new List<Bonds_Sukuk_Questionnaire__c>();
          
          Set<Id> accIds = new Set<Id>();
          Set<Id> questionnaireIds = new Set<Id>();
          List<Bonds_Sukuk_Questionnaire__c> lstQuestionnaireToUpdate = new List<Bonds_Sukuk_Questionnaire__c>();
          Map<Id,List<Bonds_Sukuk_Questionnaire__c>> mapAccountRelatedQuestionnaire = new Map<Id,List<Bonds_Sukuk_Questionnaire__c>>();
          
          for(Bonds_Sukuk_Questionnaire__c Ques : lstQuest){
              lstQuestionnaire.add(Ques);
              accIds.add(Ques.Customer__c);
          }
          
          /////////////////////////////////////////////////////// Start: Logic to Fetch Latest Questionnaire Record ///////////////////////////////////////////////////////////////////////////
          if(!accIds.isEmpty()){
              System.debug('Account Ids After Questionnaire Creation:'+accIds);
              for(Bonds_Sukuk_Questionnaire__c Ques : [Select Id, Customer__c,Latest_Questionnaire__c,Submitted_On__c from Bonds_Sukuk_Questionnaire__c Where Customer__c =: accIds ORDER BY Submitted_On__c ASC]){
                  if(mapAccountRelatedQuestionnaire.containsKey(Ques.Customer__c)){
                      List<Bonds_Sukuk_Questionnaire__c> lstQuestn = mapAccountRelatedQuestionnaire.get(Ques.Customer__c);
                      lstQuestn.add(Ques);
                      mapAccountRelatedQuestionnaire.put(Ques.Customer__c, lstQuestn);
                  }
                  else{
                      mapAccountRelatedQuestionnaire.put(Ques.Customer__c, new List<Bonds_Sukuk_Questionnaire__c>{Ques});
                  }
              }
          }
          if(!mapAccountRelatedQuestionnaire.isEmpty()){
              System.debug('Map Account Related Questionnaire :'+mapAccountRelatedQuestionnaire);
              for(Id accId : mapAccountRelatedQuestionnaire.keySet()){
                  List<Bonds_Sukuk_Questionnaire__c> questList = mapAccountRelatedQuestionnaire.get(accId);
                  if(questList.size()>0){
                      Bonds_Sukuk_Questionnaire__c bondQuestionnaire = questList.get(questList.size()-1);
                      questionnaireIds.add(bondQuestionnaire.Id);
                  }
              }
          }
          if(!questionnaireIds.isEmpty()){
              System.debug('Questionnaire Ids:'+questionnaireIds);
              for(Bonds_Sukuk_Questionnaire__c q : [Select Id,Latest_Questionnaire__c from Bonds_Sukuk_Questionnaire__c Where Id =: questionnaireIds]){
                  q.Latest_Questionnaire__c = true;
                  lstQuestionnaireToUpdate.add(q);
              }
          }
          if(!lstQuestionnaireToUpdate.isEmpty()){
              System.debug('List of Questionnaire to update:'+lstQuestionnaireToUpdate);
              update lstQuestionnaireToUpdate;
          }
          /////////////////////////////////////////////////////// END: Logic to Fetch Latest Questionnaire Record ///////////////////////////////////////////////////////////////////////////

          if(!lstQuestionnaire.isEmpty())
          {
              for(Bonds_Sukuk_Questionnaire__c Questionnaire : lstQuestionnaire){
                  Account acc = new Account(Id = Questionnaire.Customer__c);
                  if(Questionnaire.Total_Risk_Score__c >= 6 && Questionnaire.Total_Risk_Score__c <= 13){
                      acc.Bonds_Sukuk_Risk_Category__pc = 'LOW';
                  }
                  else if(Questionnaire.Total_Risk_Score__c >= 14 && Questionnaire.Total_Risk_Score__c <= 22){
                      acc.Bonds_Sukuk_Risk_Category__pc = 'MODERATE';
                  }
                  else if(Questionnaire.Total_Risk_Score__c >= 23 && Questionnaire.Total_Risk_Score__c <= 30){
                      acc.Bonds_Sukuk_Risk_Category__pc = 'HIGH';
                  }
                  acc.Bonds_Sukuk_Risk_Category_Score__pc = Questionnaire.Total_Risk_Score__c;
                  acc.Bonds_Sukuk_Consent__pc = true;
                  acc.Bonds_Sukuk_Consent_Timestamp__pc = Questionnaire.Submitted_On__c;
                  acc.Bonds_Sukuk_Consent_Version__pc = '1.0';
                  acc.Bonds_Sukuk_Consent_Status__pc = 'VALID';
                  lstAccountToUpdate.add(acc);
              } //for Ends
          }
          if(!lstAccountToUpdate.isEmpty()){
              update lstAccountToUpdate;
          }
      }

    public static void handlerAfterQuestionnaireDeletion(List<Bonds_Sukuk_Questionnaire__c> lstOldQuest){
        System.debug('Old Questionnairre size:'+lstOldQuest.size());
        System.debug('Old Questionnairre :'+lstOldQuest);
        
        Set<Id> accIds = new Set<Id>();
        Set<Id> questionnaireIds = new Set<Id>();
        List<Bonds_Sukuk_Questionnaire__c> lstQuestionnaireToUpdate = new List<Bonds_Sukuk_Questionnaire__c>();
        Map<Id,List<Bonds_Sukuk_Questionnaire__c>> mapAccountRelatedQuestionnaire = new Map<Id,List<Bonds_Sukuk_Questionnaire__c>>();
        
        for(Bonds_Sukuk_Questionnaire__c Ques : lstOldQuest){
            accIds.add(Ques.Customer__c);
        }
        
         /////////////////////////////////////////////////////// Start: Logic to Fetch Latest Questionnaire Record ///////////////////////////////////////////////////////////////////////////
          if(!accIds.isEmpty()){
              System.debug('Account Ids After Questionnaire Deletion:'+accIds);
              for(Bonds_Sukuk_Questionnaire__c Ques : [Select Id, Customer__c,Latest_Questionnaire__c,Submitted_On__c from Bonds_Sukuk_Questionnaire__c Where Customer__c =: accIds ORDER BY Submitted_On__c ASC]){
                  if(mapAccountRelatedQuestionnaire.containsKey(Ques.Customer__c)){
                      List<Bonds_Sukuk_Questionnaire__c> lstQuestn = mapAccountRelatedQuestionnaire.get(Ques.Customer__c);
                      lstQuestn.add(Ques);
                      mapAccountRelatedQuestionnaire.put(Ques.Customer__c, lstQuestn);
                  }
                  else{
                      mapAccountRelatedQuestionnaire.put(Ques.Customer__c, new List<Bonds_Sukuk_Questionnaire__c>{Ques});
                  }
              }
          }
          if(!mapAccountRelatedQuestionnaire.isEmpty()){
              System.debug('Map Account Related Questionnaire in Deletion :'+mapAccountRelatedQuestionnaire);
              for(Id accId : mapAccountRelatedQuestionnaire.keySet()){
                  List<Bonds_Sukuk_Questionnaire__c> questList = mapAccountRelatedQuestionnaire.get(accId);
                  if(questList.size()>0){
                      Bonds_Sukuk_Questionnaire__c bondQuestionnaire = questList.get(questList.size()-1);
                      questionnaireIds.add(bondQuestionnaire.Id);
                  }
              }
          }
          if(!questionnaireIds.isEmpty()){
              System.debug('Questionnaire Ids in Delete Event:'+questionnaireIds);
              for(Bonds_Sukuk_Questionnaire__c q : [Select Id,Latest_Questionnaire__c from Bonds_Sukuk_Questionnaire__c Where Id =: questionnaireIds]){
                  q.Latest_Questionnaire__c = true;
                  lstQuestionnaireToUpdate.add(q);
              }
          }
          if(!lstQuestionnaireToUpdate.isEmpty()){
              System.debug('List of Questionnaire to update:'+lstQuestionnaireToUpdate);
              update lstQuestionnaireToUpdate;
          }
          /////////////////////////////////////////////////////// END: Logic to Fetch Latest Questionnaire Record ///////////////////////////////////////////////////////////////////////////

        
    }
}