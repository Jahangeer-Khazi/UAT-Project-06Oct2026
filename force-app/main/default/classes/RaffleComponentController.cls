/**
 * @description       : Controller for RaffeComponentPage, it will query all the data and create the winners
 * @author            : ismael.ocana
 * @group             : 
 * @last modified by  : ** 27/10/2021 Jose Caballero
 *                      ** 06/03/2022 Aniss Mbarki 
 **/
public with sharing class RaffleComponentController {

    public String drawId;
    public Draw__c draw {get;set;}
    public String drawTypeLabel {get;set;}
    public Boolean disableBtn {get;set;}
    public String errorMsg {get;set;}
    public Prize__c [] prizeList {get;set;} 

    /**
     * @description Constructor
     * @author ismael.ocana | 22/10/2021 
     **/
    public RaffleComponentController() {
        this.disableBtn = false;
        this.drawId = System.currentPagereference().getParameters().get('drawId');
        if(String.isBlank(this.drawId)){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There are no draws available'));
            return;
        } else {
            this.retrieveData();            
        }
    }

    /**
     * @description used in error handling to display alert popup
     * @author Aniss Mbarki | 06/03/2022 
     **/
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('isError','isError'));
        return options;
    }

    /**
     * @description When the user clicks on start raffle it will create the winners and navigate to the next page
     * @author ismael.ocana | 22/10/2021 
     * @last modified by  : 06/03/2022 Aniss Mbarki
     * @return Pagereference 
     **/
    public Pagereference navigateToNextPage(){
        this.disableBtn=true;
        try {
            if(this.processRaffle()) {
                Pagereference pr = Page.RaffleDrawComponent;
                pr.getParameters().put('drawId', this.drawId);
                return pr;
            }
        } catch (Exception e) {
            this.errorMsg = e.getMessage();
            System.debug(e.getCause()+';ErrorMessage : '+e.getMessage());
            insert SM003_DrawHandler.setSystemAction(drawId,'Error in GUI Winner list (unhandled error)',null, null, null, null, null, 'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),'Failed');
        }

        return null;
    }


    public Boolean processRaffle() {

        if( this.draw.Winners__r == null || (this.draw.Winners__r != null && this.draw.Winners__r.size() == 0) ){
            SM003_DrawHandler.thowException('This Draw has no winners !');
        }

        return true;
    }

    /**
     * @description This method will query for the draw and the related Prizes
     * @author ismael.ocana | 22/10/2021 
     * @last modified by  : 06/03/2022 Aniss Mbarki
     **/
    public void retrieveData() {

        Draw__c [] drawList = DM004_Draw.getDrawWithPrizesAndWinnersByIds(new Set<Id>{this.drawId});
            if(!drawList.isEmpty()){
                this.draw = drawList.get(0);
                this.drawTypeLabel = String.valueOf(this.draw.get('drawTypeLabel'));
                this.prizeList = this.draw.Prizes__r;
            }
    }
}