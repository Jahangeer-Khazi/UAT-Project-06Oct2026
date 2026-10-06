/**
 * @author Wissal benqezza
 * @date Création 17/07/2022
 * @date Modification
 * @description : The function used in LTNG026_ReactivatingDormantRelationshipCaseRequest.
 */
/**
 * @author Aitogram Omar
 * @date Création 20/20/2026
 * @date Modification
 * @description :  add region parameter for jordan logic
 */

public class LTNG026_DormancyStatusController {
 private static String CLASS_NAME =LTNG026_DormancyStatusController.class.getName();
      // To get the id of the record type : Reactivate_Dormant_Relationship_And_Post_Transaction_On_Dormant_Account	
    @AuraEnabled
	public static Id getAccRequestCaseRecordType(String region) {
        String developerName = (region == 'Jordan') ? 'Dormancy_Status_Jordan' : 'Dormancy_Status';
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(developerName).getRecordTypeId();
    }
}