/**
 * @description       : Data Manager class to handle all soql queries for Raffle Draw requirement.
 * @author            : Aniss Mbarki
 * @group             : 
 * @last modified on  : 15/03/2022
 * @last modified by  : 
 * @History : 
 *  #CH01 : 29/12/2022 BY Aniss add new fields
 *  #CH02 : 26/01/2024 BY Aniss add new regionFlag
 *  #CH03 : 18/04/2025 BY Aniss NBA-13163(Al Kanz - Changes to Raffle Application for Staff & Relatives Draws)
**/
public with sharing class DM004_Draw {

    public static List<Draw__c> getDrawWithWinnersOrderByPrizeOrder(Set<Id> drawIds){
        //#CH01
        return [SELECT  Id, Name,Draw_Name__c,RegionFlag__c,
                        (SELECT Id, Name, Customer__r.Name, Customer_CIF__c, Prize__r.Winning_Amount__c, Prize__r.Tier__c, Prize__r.Prize_Currency__c,nbrOfChancesOnDraw__c,Customer__r.iGA_English_First_Name__pc,Customer__r.iGA_English_Last_Name__pc FROM Winners__r ORDER BY Prize__r.Order__c DESC) 
                FROM Draw__c WHERE Id IN :drawIds];
    }

    public static List<Draw__c> getDrawWithWinnersOrderByPrizeWinningAmount(Set<Id> drawIds){
        //#CH01
        return [SELECT  Id, Name,Draw_Name__c,
                        (SELECT Id, Name, Customer__r.Name, Customer_CIF__c, Prize__r.Winning_Amount__c, Prize__r.Tier__c, Prize__r.Prize_Currency__c,nbrOfChancesOnDraw__c,Customer__r.iGA_English_First_Name__pc,Customer__r.iGA_English_Last_Name__pc FROM Winners__r ORDER BY Prize__r.Winning_Amount__c DESC) 
                FROM Draw__c WHERE Id IN :drawIds];
    }

    public static List<Draw__c> getDrawWithPrizesAndWinnersByIds(Set<Id> drawIds){
        //#CH01 #CH02
        return [SELECT  Id, Name,Status__c,Draw_Name__c, toLabel(Draw_Type__c) drawTypeLabel,Draw_Type__c, Grand_Prize__c, Currency__c,Draw_IdFromRaffleService__c,Prize_Type__c,RegionFlag__c,
                        (SELECT Id,Number_of_Winners__c,Winning_Amount__c,Name, Tier__c, Order__c,Prize_Currency__c,Prize_Type__c FROM Prizes__r ORDER BY Order__c ASC),
                        (SELECT Id FROM Winners__r) 
                FROM Draw__c WHERE Id IN :drawIds];
    }

    public static List<Draw__c> getDrawWithPrizesAndReviewsByIds(Set<Id> drawIds){
        //#CH01 #CH02
        return [SELECT Id,Name,Currency__c,Draw_IdFromRedShift__c,Draw_Date__c,Prize_Type__c,RegionFlag__c,
                                        (SELECT Id,Winning_Amount__c,Number_of_Winners__c,Prize_Type__c,Tier__c FROM Prizes__r),
                                        (SELECT Id,CIF__c,Category__c,No_of_Chances__c,EligibleBalance__c,TotalBalance__c,Prize_Type__c FROM Draw_Entries_Review__r)
                                    FROM Draw__c WHERE Id IN :drawIds];
    }

    public static List<Draw__c> getDrawWithHistoriesAndProcessStepsByIds(Set<Id> drawIds){
        return  [SELECT Id, 
                    (SELECT Id,CreatedDate,tolabel(Field),CreatedBy.Name,toLabel(OldValue),toLabel(NewValue) FROM Histories WHERE Field IN ('Status__c','Button_Clicked__c') ORDER BY CreatedDate Desc),
                    (SELECT Id,CreatedDate,ProcessInstance.ProcessDefinition.Name,ProcessNode.Name,StepStatus,OriginalActor.Name,Actor.Name,Comments FROM ProcessSteps ORDER BY CreatedDate Desc)
                    FROM Draw__c WHERE Id IN :drawIds
                ];
    }

    public static List<Draw__c> getDrawByIds(Set<Id> drawIds){
        //#CH01 #CH02 #CH03
        return [SELECT Id,Draw_IdFromRaffleService__c,Status__c,Draw_IdFromRedShift__c,Button_Clicked__c,Template_Id__c ,Draw_Name__c,Draw_Type__c,Grand_Prize__c,ComplianceDepartment__c,LegalDepartment__c,HumanResourcesDepartment__c,
                       External_Auditor_Name__c,Internal_Auditor_Name__c,MOIC_Representative_Name__c,ila_Marketing__c,ila_Business__c,ila_Risk__c,ila_Finance__c,Prize_Type__c,RegionFlag__c,ila_Operations__c,ila_HR__c
                FROM Draw__c WHERE Id IN :drawIds];
    }

}