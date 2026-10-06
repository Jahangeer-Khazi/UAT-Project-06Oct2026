/**
 * @author Aniss Mbarki
 * @date Création 02/03/2022
 * @date Modification
 * @description :Contains functions called in 'LTNG10_GetDrawList' aura cmp
 * @history : #CH01 : 26/01/2024 by Aniss Mbarki changes to Jordan process
 * @history : #CH02 : 09/04/2025 by Aniss Mbarki changes to Bahrain process "Al Kanz Staff & Relatives"
 */
public with sharing class LTNG10_GetDrawListController {
    private static String CLASS_NAME = LTNG10_GetDrawListController.class.getName();

    /**
     * @description  method used to call "Get Draw List Api" using service class "SM003_DrawHandler"
     * @author Aniss Mbarki | 28/02/2022 
     **/
    @AuraEnabled
	public static ApiConnection.Response getDrawListViaApi(String drawType ,String regionFlag) {//#CH01

        PAD.debugLogBegin(CLASS_NAME, 'getDrawListViaApi', 'Parameters : [drawType] : '+drawType );

        //#CH02 : type "kanzStaff" and "kanz" having same drawType value
        ApiConnection.Response response;
        if(regionFlag == 'Bahrain' && drawType == 'kanzStaff'){
            drawType = 'kanz';
            //response = new MCK03_RaffleServiceApiCalls().callGetDrawListApi(new ApiConnection(),null,200);
        }
        response = SM003_DrawHandler.callGetDrawListApi(drawType,regionFlag);


        PAD.debugLogEnd(CLASS_NAME, 'getDrawListViaApi', '[ApiConnection.Response] : ' + response );

        return response;
    }


    @AuraEnabled
	public static Id getDrawRecordType(String regionFlag, String drawType) {
        //#CH02 : adding new param {drawType} 
        if(regionFlag == 'Bahrain' && drawType == 'kanzStaff'){
            return Schema.SObjectType.Draw__c.getRecordTypeInfosByDeveloperName().get('Bahrain_Draw_AlKanz_Staff_Relatives').getRecordTypeId();
        }
        else{
            return Schema.SObjectType.Draw__c.getRecordTypeInfosByDeveloperName().get(regionFlag+'_Draw').getRecordTypeId();
        }
    }

}