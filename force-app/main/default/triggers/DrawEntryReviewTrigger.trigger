/**
 * @author Aniss Mbarki
 * @date Création 07/03/2022
 * @date Modification
 * @description : apex trigger used to prevent deleting Draw Entry Reviews records realted to a draw with status different of "new" and "rework"
 */
trigger DrawEntryReviewTrigger on Draw_Entry_Review__c (before delete) {
    for(Draw_Entry_Review__c review : trigger.old){
        if(review.Draw_Status__c != 'New' && review.Draw_Status__c != 'Rework'){
            review.adderror(System.Label.DrawReview_PreventDeleteMsg);
        }
    }
}