/**
 * @description       : This is the controller for RaffleComponentWinner
 * @author            : ismael.ocana
 * @group             : 
 * @last modified by  : ** 20/01/2022 juan.trujillo
 *                      ** 07/03/2022 Aniss Mbarki 
 * 
**/
public with sharing class RaffleWinnerComponentController {
    
    public String drawId;
    public Draw__c draw {get;set;}
    public List<Winner__c> winnerList {get;set;}
    public Boolean finish{get;set;}
    public Winner__c winnerSelected{get;set;}
    public Integer winnerNum{get;set;}

    public RaffleWinnerComponentController() {
        
        this.drawId = System.currentPagereference().getParameters().get('drawId');
        this.winnerNum = System.currentPagereference().getParameters().containsKey('winnerNum') ? Integer.valueOf(System.currentPagereference().getParameters().get('winnerNum')) : 0;
        this.finish = false;
        if(String.isBlank(this.drawId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is not draws.'));
        } else {
            this.retrieveData();
        }
    }

    /**
     * @description It will retrieve the whole data
     * @author ismael.ocana | 22/10/2021 
     * @last modified by : 07/03/2022 Aniss Mbarki
    **/
    public void retrieveData(){
        List<Draw__c> drawList = DM004_Draw.getDrawWithWinnersOrderByPrizeOrder(new Set<Id>{this.drawId});
        if(!drawList.isEmpty()){
            this.draw = drawList.get(0);
            this.winnerList = this.draw.Winners__r;
            if(!this.winnerList.isEmpty()){
                if((this.winnerNum + 1) >= this.winnerList.size()){
                    this.finish = true;
                    if(this.winnerList.size() == 1){
                        this.winnerSelected = this.winnerList.get(winnerNum); 
                    }
                }
                else {
                    this.winnerSelected = this.winnerList.get(winnerNum);
                }
            }
        }
    }

    /**
     * @description It will be references when the user clicks the button, it will iterate though the winners list
     * until it finish and when it navigates to the next page.
     * @author ismael.ocana | 22/10/2021 
     * @return Pagereference 
    **/
    public Pagereference buttonAction(){

        if(!finish){
            this.winnerNum = this.winnerNum + 1;
            if(this.winnerNum < this.winnerList.size()){
                this.winnerSelected = this.winnerList.get(this.winnerNum);
            }
            this.finish = (this.winnerNum + 1) == this.winnerList.size();
        }
        else {
            Pagereference pr = Page.RaffleSummaryComponent;
            pr.getParameters().put('drawId', this.drawId);
            return pr;
        }
        return null;
    }

    /**
     * @description It returns the ordinal related the position
     * @author ismael.ocana | 22/10/2021 
     * @return String 
    **/
    public String getWinnerString(){

        return this.getOrdinal(this.winnerNum + 1);
    }

    /**
     * @description It gets the string related the position of i
     * @author ismael.ocana | 22/10/2021 
     * @param Integer i 
     * @return String 
    **/
    public String getOrdinal(Integer i){

        String num = string.valueof(i);
        String suffix = 'th';
        String ordinal = '';
        i = integer.valueof(num.right(2));
        if(10 < i && i < 14) {
            ordinal =  num + suffix;
        }else{
            String onesDigit = num.right(1);
            if(onesDigit == '1'){
                suffix = 'st';
            }else if(onesDigit == '2'){
                suffix = 'nd';
            }else if(onesDigit == '3'){
                suffix = 'rd';
            }
            ordinal = num+suffix;
        }
        return ordinal;
    }

    /**
     * @description It will return the selected winner name
     * @author ismael.ocana | 22/10/2021 
     * @return String 
    **/
    public String getNameCif(){

        String ncif = '';
        if(this.winnerSelected != null){
            if( this.draw.RegionFlag__c != 'Jordan' && this.winnerSelected.Customer__r.iGA_English_Last_Name__pc != null && this.winnerSelected.Customer__r.iGA_English_First_Name__pc != null ){
                ncif = this.winnerSelected.Customer__r.iGA_English_First_Name__pc + ' ' + this.winnerSelected.Customer__r.iGA_English_Last_Name__pc + ' - ' + this.winnerSelected.Customer_CIF__c;
            }else{
                ncif = this.winnerSelected.Customer__r.Name + ' - ' + this.winnerSelected.Customer_CIF__c;
            }
        }
        return ncif;
    }
}