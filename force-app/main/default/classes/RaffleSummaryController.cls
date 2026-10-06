/**
 * @description       : This is the controller for RaffleSummaryComponent
 * @author            : ismael.ocana
 * @group             : 
 * @last modified by  : ** 22/10/2021 Jose Caballero
 *                      ** 07/03/2022 Aniss Mbarki 
**/
public with sharing class RaffleSummaryController {

    public String drawId;
    public Draw__c draw {get;set;}
    public List<Winner__c> winnerList {get;set;}
    public List<Summary> summaryList {get;set;}

    public RaffleSummaryController() {

        this.summaryList = new List<Summary>();
        this.drawId = System.currentPagereference().getParameters().get('drawId');
        if(String.isBlank(this.drawId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is not draws.'));
        } else {
            this.retrieveData();
        }
    }

    /**
     * @description It will return the draw Name
     * @author ismael.ocana | 22/10/2021 
     * @return String 
    **/
    public String getDrawName(){
        String name = draw != null ? draw.Draw_Name__c + ' Winners List' : 'Winners List';
        return name;
    }

    /**
     * @description It will query the Draw, the winners and create the wrapper
     * @author ismael.ocana | 22/10/2021 
     * @last modified by : 07/03/2022 Aniss Mbarki
    **/
    public void retrieveData(){
        
        List<Draw__c> drawList = DM004_Draw.getDrawWithWinnersOrderByPrizeWinningAmount(new Set<Id>{this.drawId});
        if(!drawList.isEmpty()){
            this.draw = drawList.get(0);
            this.winnerList = this.draw.Winners__r;
            if(!this.winnerList.isEmpty()){
                Map<String, Summary> summaryByPriceTier = new Map<String, Summary>();
                Summary selectedSummary;
                for(Winner__c w : this.winnerList){
                    if(!summaryByPriceTier.containsKey(w.Prize__r.Tier__c)){
                        summaryByPriceTier.put(w.Prize__r.Tier__c, new Summary(w.Prize__r.Tier__c, w.Prize__r.Winning_Amount__c, w.Prize__r.Prize_Currency__c));
                    }
                    selectedSummary = summaryByPriceTier.get(w.Prize__r.Tier__c);
                    selectedSummary.winnerList.add(w);
                    summaryByPriceTier.put(w.Prize__r.Tier__c, selectedSummary);
                }
                this.summaryList = summaryByPriceTier.values();
            }
        }
    }

    public class Summary{

        public List<Winner__c> winnerList {get;set;}
        public String prizeName {get;set;}
        public Decimal winningAmmount {get;set;}
        public String currencyValue {get;set;}

        public Summary(String prizeName, Decimal winningAmmount, String currencyValue){
            this.prizeName = prizeName;
            this.winnerList = new List<Winner__c>();
            this.winningAmmount = winningAmmount;
            this.currencyValue = currencyValue;
        }
    }
}