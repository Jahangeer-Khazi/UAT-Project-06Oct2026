/**
 * @description       : This class is the controller for RaffleDrawComponent, it will query the data and show the CIFs
 * @author            : ismael.ocana
 * @group             : 
 * @last modified by  : ** 22/10/2021 ismael.ocana
 *                      ** 07/03/2022 Aniss Mbarki 
**/
public with sharing class RaffleDrawComponentController {

    public String drawId;
    public Draw__c draw {get;set;}
    public String [] cifsList{get;set;}
    public Winner__c smallestPrizeWinner{get;set;}

    public RaffleDrawComponentController() {

        this.drawId = System.currentPagereference().getParameters().get('drawId');
        this.cifsList = new List<String>();
        System.debug(this.drawId);
        if(String.isBlank(this.drawId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is not draws.'));
        } else {
            this.retrieveData();  
        }
    }

    /**
     * @description It will navigate to the next page
     * @author ismael.ocana | 22/10/2021 
     * @return Pagereference 
     **/
    public Pagereference navigateToNextPage(){

        Pagereference pr = Page.RaffleWinnerComponent;
        pr.getParameters().put('drawId', this.drawId);
        pr.getParameters().put('winnerNum', '0');
        return pr;
    }

    /**
     * @description This method will retrieve the draw with the related entries and the smallest prize
     * @author ismael.ocana | 22/10/2021 
     * @last modified by  : 07/03/2022 Aniss Mbarki 
     **/
    public void retrieveData() {

        
        List<Draw__c> drawList = DM004_Draw.getDrawByIds(new Set<Id>{this.drawId});
        if(!drawList.isEmpty()){
            this.draw = drawList.get(0);
        }
        
        //get first 100 cifs on crm :
        for(Account acc : [SELECT Id,CIF__pc FROM Account WHERE Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Region_Flag__pc = :this.draw.RegionFlag__c LIMIT 100] ){
            this.cifsList.add(String.valueOf(acc.CIF__pc));
        }

        this.smallestPrizeWinner = [SELECT Prize__r.Tier__c, Prize__r.Winning_Amount__c, Prize__r.Prize_Currency__c FROM Winner__c WHERE Prize__r.Draw__c =: this.drawId AND Prize__c != null ORDER BY Prize__r.Order__c DESC LIMIT 1];
    }
}