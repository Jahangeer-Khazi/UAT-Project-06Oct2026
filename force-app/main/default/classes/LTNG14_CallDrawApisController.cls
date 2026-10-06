/**
 * @author Aniss Mbarki
 * @date Création 02/03/2022
 * @date Modification
 * @description :Contains functions called in 'LTNG14_CallDrawApis' 
 * @history : #CH02 : 26/01/2024 by Aniss Mbarki changes to Jordan process
 * @history : #CH03 : 18/04/2025 BY Aniss NBA-13163(Al Kanz - Changes to Raffle Application for Staff & Relatives Draws)
 */
public with sharing class LTNG14_CallDrawApisController {


    /**
     * @author Aniss Mbarki
     * @date Création 02/03/2022
     * @date Modification
     * @description : call 2 apis the first one "Create Draw Api" to create the Draw on Raffle Service Side , then the second one "Get Summary Api" to get summary infos related to original data 
     */
    @AuraEnabled
    public static Boolean createDrawApi(Id drawId){
        System.debug('createDrawApi **************** ' +drawId);
        SM003_DrawHandler.checkEditAccessOfCurrentUserOnDraw(drawId);
        Boolean isErrorDetected = false;
        try{
            List<Draw_System_Action__c> drawSysActions = new List<Draw_System_Action__c>();
            Draw__c drawRecord = DM004_Draw.getDrawWithPrizesAndReviewsByIds(new Set<Id>{drawId}).get(0); 

            ApiConnection con = new ApiConnection();
            //#CH02
            HttpRequest req = con.createRequest('POST', '/api/v1/raffle',drawRecord.RegionFlag__c);
            HttpResponse response = SM003_DrawHandler.callCreateDrawApi(req,drawRecord);
            System.debug(response.getBody());
            drawSysActions.add(SM003_DrawHandler.setSystemAction(drawRecord.Id,'Create draw Api',req.getEndpoint(), req.getMethod(), req.getBody(), response.getStatusCode(), response.getBody(), null, null));
            if(response.getStatusCode() != 200){
                drawSysActions.get(0).Action_Type__c = 'Failed';
                drawRecord.TECH_FirstApiCall__c = 'Failed';
                isErrorDetected = true;
            }else{
                drawSysActions.get(0).Action_Type__c = 'Success';
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                drawRecord.Draw_IdFromRaffleService__c = String.valueOf(m1.get('drawId'));

                //call summary api ...
                //#CH02
                HttpRequest reqSum = con.createRequest('GET', '/api/v1/raffle/summary/'+drawRecord.Draw_IdFromRedShift__c,drawRecord.RegionFlag__c);
                
                HttpResponse responseSumm = EM03_RaffleServiceApiCalls.callGetDrawSummaryApi(reqSum,null);
                //mock response
                //HttpResponse responseSumm = new MCK03_RaffleServiceApiCalls().callGetDrawSummaryApi(reqSum,200);
                
                drawSysActions.add(SM003_DrawHandler.setSystemAction(drawRecord.Id,'Get Draw Summary API',reqSum.getEndpoint(), reqSum.getMethod(), reqSum.getBody(), responseSumm.getStatusCode(), responseSumm.getBody(), null, null));
                if(responseSumm.getStatusCode() != 200){
                    drawSysActions.get(1).Action_Type__c = 'Failed';
                    drawRecord.TECH_FirstApiCall__c = 'Failed';
                    isErrorDetected = true;
                }else{
                    drawSysActions.get(1).Action_Type__c = 'Success';
                    Map<String, Object> me = (Map<String, Object>)JSON.deserializeUntyped(responseSumm.getBody());// meta, data
                    Map<String, Object> me1 = (Map<String, Object>)me.get('data');
                    try {
                        drawRecord.Draw_From__c = Datetime.valueof(String.valueof(me1.get('drawFrom')).replace('T',' '));
                        drawRecord.Draw_To__c = Datetime.valueOf(String.valueOf(me1.get('drawTo')).replace('T',' '));
                    } catch (Exception e) {
                        System.debug(e.getMessage());
                    }
                    drawRecord.TotalNumberOfCustomers__c = (Decimal)(me1.get('totalNumberOfCustomers'));
                    drawRecord.TotalNumberOfChances__c = (Decimal)(me1.get('totalNumberOfChances'));
                    drawRecord.TotalBalances__c = (Decimal)(me1.get('totalBalances'));
                    drawRecord.TotalEligibleBalances__c = (Decimal)(me1.get('totalEligibleBalances'));

                    //after the two api calls are running successfully
                    drawRecord.TECH_FirstApiCall__c = 'Success';
                    drawRecord.Scattering_Complete__c = true;
                    drawRecord.Button_Clicked__c = 'Create Draw Button';
                }
            }

            update drawRecord;
            insert drawSysActions;
        }catch(Exception e){
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM003_DrawHandler.setSystemAction(drawId,'Create draw Api(unhandled error)',null, null, null, null, null, 'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),'Failed');
            isErrorDetected = true;
        }

        return isErrorDetected;
    }


    /**
     * @author Aniss Mbarki
     * @date Création 02/03/2022
     * @date Modification
     * @description : method called from aura cmp LTNG14_CallDrawApis to call the Update Status Api 
     */
    @AuraEnabled
    public static Boolean updateDrawStatusApi(Id drawId,String status){
        SM003_DrawHandler.checkEditAccessOfCurrentUserOnDraw(drawId);
        return updateDrawStatus(drawId,status);
    }

    /**
     * @author Aniss Mbarki
     * @date Création 02/03/2022
     * @date Modification
     * @description : method called from the flow "Draw - Trigger Approval Processes" to call the Update Status Api using future method 
     */
    @InvocableMethod(label='Update Draw Status API' callout=true )
    public static void updateDrawStatusApiFromFlow(List<RequestStatusUpdate> reqStatus){
        updateDrawStatusFutureCallout(reqStatus.get(0).drawId,reqStatus.get(0).status);
    }
    @future(callout=true)
    public static void updateDrawStatusFutureCallout(Id drawId,String status){
        updateDrawStatus(drawId,status);
    }

    /**
     * @author Aniss Mbarki
     * @date Création 02/03/2022
     * @date Modification
     * @description : method used to call the Update Status Api with error handling in case there is any issue related to the api call
     * @history : #CH01 : 10/05/2023 add setTimeOut of 13seconds in case of APPROVED
     */
    public static Boolean updateDrawStatus(Id drawId,String status){
        Boolean isErrorDetected = false;
        try {
    
            Draw__c drawRecord = DM004_Draw.getDrawByIds(new Set<Id>{drawId}).get(0);
            ApiConnection con = new ApiConnection();
            //#CH02
            HttpRequest req = con.createRequest('PUT', '/api/v1/raffle/status/'+drawRecord.Draw_IdFromRaffleService__c,drawRecord.RegionFlag__c);
            req.setBody('{"status": "'+status+'"}');
            
            //#CH01 : Start
            if(status == 'APPROVED'){
                req.setTimeout(13000);
            }
            //#CH01 : End
            
            HttpResponse response = EM03_RaffleServiceApiCalls.updateDrawStatusApi(req,null);
            //HttpResponse response = new MCK03_RaffleServiceApiCalls().updateDrawStatusApi(req,200);

            Draw_System_Action__c drawSysAction = SM003_DrawHandler.setSystemAction(drawId,'Update Draw Status API ('+status+')',req.getEndpoint(), req.getMethod(), req.getBody(), response.getStatusCode(), response.getBody(), null,null);

            if(response.getStatusCode() != 200){
                if(status == 'APPROVED'){//if current status is "Approved" , we will move it again to "Pending Risk Dept Validation"
                    //#CH03 : Start
                    if(drawRecord.RegionFlag__c == 'Jordan'){
                        drawRecord.Status__c = 'Pending Checker Validation';
                    }
                    else if(drawRecord.RegionFlag__c != 'Jordan' && drawRecord.Draw_Type__c == 'kanzStaff' ){
                        drawRecord.Status__c = 'Pending Operations Dept Validation';
                    }else{
                        drawRecord.Status__c = 'Pending Risk Dept Validation';
                    }
                    //#CH03 : End
                }
                drawRecord.TECH_LastApiCall__c = 'Failed';
                drawSysAction.Action_Type__c = 'Failed';
                isErrorDetected = true;
            }else{
                drawSysAction.Action_Type__c = 'Success';
                drawRecord.TECH_LastApiCall__c = 'Success';
                if(status == 'APPROVED' && drawRecord.Status__c != 'Approved'){
                    drawRecord.Status__c = 'Approved';
                }
            }
            
            update drawRecord;
            insert drawSysAction;
            
        } catch (Exception e) {
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            insert SM003_DrawHandler.setSystemAction(drawId,'Update Draw Status API(unhandled error)',null, null, null, null, null, 'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),'Failed');
            isErrorDetected = true;
        }
        return isErrorDetected;
    }

    //inner Wrapper class used to pass parameters inside the "Draw - Trigger Approval Processes" Flow
    public class RequestStatusUpdate {
        @InvocableVariable(label='Draw Id' description='the Id of the Draw' required=true)
        public Id drawId;

        @InvocableVariable(label='Status' description='Status { APPROVED OR REJECTED }' required=true)
        public String status;
    }
}