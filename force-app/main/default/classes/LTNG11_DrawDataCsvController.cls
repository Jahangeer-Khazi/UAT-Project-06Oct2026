/**
 * @author Aniss Mbarki
 * @date Création 07/03/2022
 * @date Modification
 * @description :Contains functions called in 'LTNG11_DrawDataCsv' aura cmp
 * @history :
 *          #CH01 : 17/04/2025 by Aniss Mbarki : NBA-13163(Al Kanz - Changes to Raffle Application for Staff & Relatives Draws)
 */
public with sharing class LTNG11_DrawDataCsvController {
    private static String CLASS_NAME = LTNG11_DrawDataCsvController.class.getName();

    /**
     * @author Aniss Mbarki
     * @date Création 02/03/2022
     * @date Modification
     * @description :  method used to call "Get Draw Data Api" and track who download the csv file by changing the value of "Button_Clicked__c" field
     */
    @AuraEnabled
	public static ApiConnection.Response getDrawDataViaApi(Id recordId, String dataType) {

        PAD.debugLogBegin(CLASS_NAME, 'getDrawDataViaApi', 'Parameters : [recordId] : '+recordId+' , [dataType] : '+dataType );

        Draw__c drawRecord = DM004_Draw.getDrawByIds(new Set<Id>{recordId}).get(0);
        
        ApiConnection.Response response = SM003_DrawHandler.callGetDrawDataApi(drawRecord,dataType);
        //ApiConnection.Response response = new MCK03_RaffleServiceApiCalls().callGetDrawDataApi(new ApiConnection(),null,200);


        if(response.isSuccess){
            //track who download the csv file
            String msg = 'Export Data '+dataType;
            if(drawRecord.Button_Clicked__c == msg){
                //to create new tracking history entry for this field  
                drawRecord.Button_Clicked__c = null;
                update drawRecord;
            }

            drawRecord.Button_Clicked__c = msg;
            update drawRecord;
        }
        PAD.debugLogEnd(CLASS_NAME, 'getDrawDataViaApi', '[ApiConnection.Response] : ' + response );

        return response;
    }

    /**
     * @author Aniss Mbarki
     * @date Création 02/03/2022
     * @date Modification
     * @description :  method used to track who click on Raffle buttons by changing the value of "Button_Clicked__c" field
     */
    @AuraEnabled
	public static void trackClickedButton(Id recordId, String buttonDesc) {
        //to track Clicked button field
        Draw__c drawRecord = new Draw__c();
        drawRecord.Id = recordId;
        drawRecord.Button_Clicked__c = buttonDesc;
        update drawRecord;
    }

    /**
     * @author Aniss Mbarki
     * @date Création 17/04/2025
     * @date Modification
     * @description :  method used to show/hide “Get Draw Data” component based on the draw type
     */
    @AuraEnabled
	public static Boolean checkDrawDataVisibilityForKanzStaff(Id recordId) {//#CH01
        //toCheck : we should exclude admin and restricted admin??
        Draw__c drawRecord = [SELECT Id,OwnerId FROM Draw__c WHERE Id =:recordId LIMIT 1];
        String queueName = 'Bahrain_Draw_Maker';
        // Get the current user's ID
        Id currentUserId = UserInfo.getUserId();
            
        // Query the QueueSobject to get the Queue Id by its name
        Group queue = [SELECT Id FROM Group WHERE DeveloperName = :queueName AND Type = 'Queue' LIMIT 1];
        
        // Query the QueueSobject Members (QueueSobjectMembers) to check if the user is a member
        List<GroupMember> queueMembers = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queue.Id];
        
        // Check if the current user is a member of the queue
        for (GroupMember member : queueMembers) {
            if (member.UserOrGroupId == currentUserId) {
                return false;
            }
        }

        return true;
    }
}