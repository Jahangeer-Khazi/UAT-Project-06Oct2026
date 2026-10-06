/**
 * @author Aniss Mbarki
 * @date Création 14/03/2022
 * @date Modification
 * @description : Contains functions called in 'VF01_DrawDetailsPdf.page' VisualForce Page 
 */
public class VF01_DrawDetailsController {
    private Draw__c drawRecord;
    private Draw__c drawWithRelatedHistories;

    public VF01_DrawDetailsController(Apexpages.StandardController stdController){
        this.drawRecord = (Draw__c)stdController.getRecord();
        this.drawWithRelatedHistories = DM004_Draw.getDrawWithHistoriesAndProcessStepsByIds(new Set<Id>{this.drawRecord.Id}).get(0);
    }
    
    public List<Draw__History> getDrawHistories(){
        return this.drawWithRelatedHistories.Histories;
    }

    public List<ProcessInstanceHistory> getDrawProcessSteps(){
        return this.drawWithRelatedHistories.ProcessSteps;
    }

    public Integer getWinnersSize(){
        if(this.drawRecord.Winners__r != null){
            return this.drawRecord.Winners__r.size();
        }
        return 0;
    }
    public Integer getReviewsSize(){
        if(this.drawRecord.Draw_Entries_Review__r != null){
            return this.drawRecord.Draw_Entries_Review__r.size();
        }
        return 0;
    }
}