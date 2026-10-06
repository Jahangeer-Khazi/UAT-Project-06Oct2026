/**
 * @description       : Service class to call Different Apis for Raffle Draw requirement.
 * @author            : Aniss Mbarki
 * @group             : 
 * @last modified on  : 28/02/2022
 * @last modified by  : 
 * @History : 
 * #CH01 : 29/12/2022 by Aniss Mbarki changes on body request of the api
 * #CH02 : 26/01/2024 by Aniss Mbarki changes to Jordan process
**/
public with sharing class SM003_DrawHandler {

    private static String CLASS_NAME = SM003_DrawHandler.class.getName();
    private static ApiConnection con = new ApiConnection();

    /**
     * @description  method used to call "Get Draw List Api" to return the draw details saved in RedShift based on Draw Type.
     * @author Aniss Mbarki | 28/02/2022 
     **/
    public static ApiConnection.Response callGetDrawListApi(String drawType ,String regionFlag){
        PAD.debugLogBegin(CLASS_NAME, 'callGetDrawListApi', '');
        final HttpRequest req = con.createRequest('GET', '/api/v1/raffle?drawType='+drawType,regionFlag);
        System.debug(req.getEndpoint());
        System.debug(req.getMethod());
        
        ApiConnection.Response response = EM03_RaffleServiceApiCalls.callGetDrawListApi(con,req,null);
        
        return response;
    }

    /**
     * @description  method used to call "Get Draw Data Api" based on the file type and drawId
     * @author Aniss Mbarki | 07/03/2022 
    **/
    public static ApiConnection.Response callGetDrawDataApi(Draw__c drawRecord ,String drawType){
        PAD.debugLogBegin(CLASS_NAME, 'callGetDrawDataApi', '');
        String drawIdApi;
        if(drawType == 'original_eligible' || drawType == 'original_ineligible'){
            drawIdApi = drawRecord.Draw_IdFromRedShift__c;
        }else{
            drawIdApi = drawRecord.Draw_IdFromRaffleService__c;
        }
        //#CH02 : Add RegionFlag__c 
        final HttpRequest req = con.createRequest('GET', '/api/v1/raffle/'+drawIdApi+'/data?type='+drawType,drawRecord.RegionFlag__c);
        ApiConnection.Response response = EM03_RaffleServiceApiCalls.callGetDrawDataApi(con,req,null);
        Map<String, Object> dataMap = (Map<String, Object>)response.responseData;
        if( !response.isSuccess){
            insert setSystemAction(drawRecord.Id,'Get Draw Data API ('+drawType+')',req.getEndpoint(), req.getMethod(), req.getBody(), null , String.valueOf(response.errorData), null, 'Failed');
        }else if(response.isSuccess && dataMap != null && dataMap.keySet().size() == 0){
            System.debug('Draw data file is being generated, please try after few seconds.');
            System.debug('API response is 200 and data is empty');
            //insert setSystemAction(drawRecord.Id,'Get Draw Data API ('+drawType+')',req.getEndpoint(), req.getMethod(), req.getBody(), 200 , String.valueOf(response.responseData), null, 'Failed');
        }
        return response;
    }

    /**
     * @description  method used to call "Create Draw API" to save the details in bank db (Raffle Service Side) of the selected draw.
     * @author Aniss Mbarki | 07/03/2022 
    **/
    public static HttpResponse callCreateDrawApi(HttpRequest req , Draw__c drawRecord){
        PAD.debugLogBegin(CLASS_NAME, 'callCreateDrawApi', '');
        
        WR01_CreateDrawRequest wrapper = new WR01_CreateDrawRequest(); 
        wrapper.drawDataId = drawRecord.Draw_IdFromRedShift__c;
        wrapper.drawDate = drawRecord.Draw_Date__c.format('yyyy-MM-dd\'T\'HH:mm:ss');
        wrapper.crmDrawId = '"'+drawRecord.Name+'"';
        
        Integer decimalPlaces;

        //#CH01 : Start
        if(drawRecord.Prize_Type__c == 'CASH' || drawRecord.Prize_Type__c == 'CASHBACK'){
            if(drawRecord.Currency__c == 'BHD'){decimalPlaces=3;}else{decimalPlaces=2;}
        }
        //#CH01 :End
        
        List<WR01_CreateDrawRequest.WR_Prize> prizeLst = new List<WR01_CreateDrawRequest.WR_Prize>();
        for(Prize__c prizeRec : drawRecord.Prizes__r){
            //#CH01: Start 
            WR01_CreateDrawRequest.WR_Prize przRec = new WR01_CreateDrawRequest.WR_Prize(Integer.valueOf(prizeRec.Number_of_Winners__c),prizeRec.Winning_Amount__c,prizeRec.Prize_Type__c,prizeRec.Tier__c);
            if(drawRecord.Prize_Type__c == 'CASH' || drawRecord.Prize_Type__c == 'CASHBACK'){
                przRec.prizeCurrency = new WR01_CreateDrawRequest.WR_PrizeCurrency(drawRecord.Currency__c,decimalPlaces);
            }
            prizeLst.add(przRec);
            //#CH01: End 

        }
        wrapper.prizes = prizeLst;

        List<WR01_CreateDrawRequest.WR_Customer> customerLst = new List<WR01_CreateDrawRequest.WR_Customer>();
        for(Draw_Entry_Review__c reviewRec : drawRecord.Draw_Entries_Review__r){
            customerLst.add(new WR01_CreateDrawRequest.WR_Customer(reviewRec.CIF__c,reviewRec.Category__c,reviewRec.No_of_Chances__c,reviewRec.EligibleBalance__c,reviewRec.TotalBalance__c));
        }
        wrapper.customers = customerLst;

        req.setBody(JSON.serialize(wrapper));
        System.debug(req.getBody());

        HttpResponse response = EM03_RaffleServiceApiCalls.callCreateDrawApi(req,null);
        //HttpResponse response = new MCK03_RaffleServiceApiCalls().callCreateDrawApi(req,200);

        return response;
    }
            
    /**
     * @description  method used to call "Get Winners List Api" to return the draw winners
     * @author Aniss Mbarki | 14/03/2022 
    **/
    public static Boolean getDrawWinnersViaApi(Id crmDrawId,HttpRequest req){
        PAD.debugLogBegin(CLASS_NAME, 'getDrawWinnersViaApi', '');

        Draw__c drawRecord = DM004_Draw.getDrawWithPrizesAndWinnersByIds(new Set<Id>{crmDrawId}).get(0);
        Map<Id,Winner__c> mapWinnerByCustomer = new Map<Id,Winner__c>(); 
        Integer countNbrOfWinners = 0;
        Boolean isError = false;

        req.setTimeout(20000);
        HttpResponse response = EM03_RaffleServiceApiCalls.callGetDrawWinnersApi(req,null);
        //HttpResponse response = new MCK03_RaffleServiceApiCalls().callGetDrawWinnersApi(null,200);

        Draw_System_Action__c drawSysAction = setSystemAction(crmDrawId,'Get Draw Winners API',req.getEndpoint(), req.getMethod(), req.getBody(), response.getStatusCode() , response.getBody(), null , null);

        if (response.getStatusCode() == 200) {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            Map<String, Object> responseData = (Map<String, Object>)m1.get('draws');

            Map<Id,Set<String>> mapCifsByPrizeId = new Map<Id,Set<String>>(); 
            Map<String,Integer> mapNumbrChancesByCif = new Map<String,Integer>(); 
            Map<String,Decimal> mapEligibleBalanceByCif = new Map<String,Decimal>(); 
            Set<String> allWinnerCifs= new Set<String>();

            for(Object prize : (Object[])responseData.get('prizes')){ 
                Map<String,Object> mapPrize = (Map<String, Object>)prize;
                Integer nbrWinners = Integer.valueOf(mapPrize.get('numberOfWinners'));
                countNbrOfWinners += nbrWinners;
                Decimal amount = (Decimal)mapPrize.get('amount'); 
                String namePrize = (String)mapPrize.get('title'); 
    
                Set<String> tempWinnerCifs= new Set<String>(); 
                for(Object winnerCif : (Object[])mapPrize.get('winners')){
                    Map<String, Object> winnerCifMap = (Map<String, Object>)winnerCif;
                    String cifN = String.valueOf(winnerCifMap.get('customerId'));
                    Integer nbrChances = Integer.valueOf(winnerCifMap.get('noOfChances'));
                    tempWinnerCifs.add(cifN);
                    allWinnerCifs.add(cifN);
                    mapNumbrChancesByCif.put(cifN,nbrChances);

                    Decimal eligibleBalance = Decimal.valueOf(String.valueOf(winnerCifMap.get('eligibleBalance')));
                    mapEligibleBalanceByCif.put(cifN,eligibleBalance);
                }

                //check existing prizes on crm  
                for(Prize__c prizeRecord : drawRecord.Prizes__r ){
                    //#CH01 : Start
                    if( drawRecord.Prize_Type__c == 'CASH' && mapCifsByPrizeId.get(prizeRecord.Id) == null && nbrWinners == prizeRecord.Number_of_Winners__c && amount == prizeRecord.Winning_Amount__c ){
                        mapCifsByPrizeId.put(prizeRecord.Id,tempWinnerCifs);
                        System.debug(prizeRecord.Id+'*********> : '+mapCifsByPrizeId.get(prizeRecord.Id));
                        break;
                    }
                    else if(mapCifsByPrizeId.get(prizeRecord.Id) == null && nbrWinners == prizeRecord.Number_of_Winners__c && namePrize == prizeRecord.Tier__c){
                        mapCifsByPrizeId.put(prizeRecord.Id,tempWinnerCifs);
                        System.debug(prizeRecord.Id+'********* OTHER Type>> : '+mapCifsByPrizeId.get(prizeRecord.Id));
                        break;
                    }
                    //#CH01 : End
                }
            }

            System.debug('****************');
            
            if(allWinnerCifs.size()>0){
                Map<String,Account> mapAccByCif = new Map<String,Account>();
                for( Account customer : [SELECT Id,CIF__pc FROM Account WHERE CIF__pc IN :allWinnerCifs] ){
                    mapAccByCif.put(customer.CIF__pc,customer);
                }
                System.debug(mapAccByCif);

                for(Id prizeId : mapCifsByPrizeId.keySet()){
                    System.debug(prizeId);
                    for(String cif : mapCifsByPrizeId.get(prizeId) ){
                        System.debug(cif);

                        Winner__c newWinner = new Winner__c();
                        if(mapAccByCif.get(cif) != null){
                            newWinner.Customer__c = mapAccByCif.get(cif).Id;
                        }else{
                            thowException('this cif number ('+cif+') don\'t exist on CRM or the current UserId ('+UserInfo.getUserId()+ ') don\'t have access to it.');
                        }
                        newWinner.Draw__c = crmDrawId;
                        newWinner.Prize__c = prizeId;
                        newWinner.nbrOfChancesOnDraw__c = mapNumbrChancesByCif.get(cif);
                        newWinner.eligibleBalance__c = mapEligibleBalanceByCif.get(cif);

                        if(mapWinnerByCustomer.get(newWinner.Customer__c) == null){
                            mapWinnerByCustomer.put(newWinner.Customer__c,newWinner);
                        }else{
                            thowException('this cif number ('+cif+') is duplicated on Winners List please check the response Body o System Action');
                        }
                    }
                }
            }
            
            if( mapWinnerByCustomer.size()>0 ) {

                //final check : the nbr of winners from the api should be the same on crm!
                if(countNbrOfWinners != mapWinnerByCustomer.size() ){
                    thowException('Number of Winners from the Api not Equal to Number of Winners On Crm');
                }

                insert mapWinnerByCustomer.values();
                drawRecord.Status__c = 'Raffle Completed';
                drawRecord.Button_Clicked__c = 'Execute Raffle Button';
                update drawRecord;
            }

            drawSysAction.Action_Type__c = 'Success';
            
        }else{
            drawSysAction.Action_Type__c = 'Failed';
            isError = true;
        }
        
        insert drawSysAction;
       
        return isError;
    }

    /**
     * @description  method used to initialize and return the Draw_System_Action which is used to store draw logs 
     * @author Aniss Mbarki | 14/03/2022 
    **/
    public static Draw_System_Action__c setSystemAction(Final Id drawId, Final String title, final String endPoint, Final String method, final String reqBody, Final Integer statCode, final String resBody,Final String crmStackTrace ,Final String actionType) {
        Draw_System_Action__c action = new Draw_System_Action__c();
        action.Draw__c = drawId;
        action.Title__c = title;
        action.Endpoint__c = endPoint;
        action.Method__c = method;
        action.Request_Body__c = reqBody;
        action.HTTP_Response_Code__c = statCode;
        action.Response_Body__c = resBody;
        action.CRM_Stack_Trace__c = crmStackTrace;
        action.Action_Type__c = actionType;//Success;Failed
        
        return action; 
    }

    /**
     * @description  method used to throw AuraHandledException with custom message
     * @author Aniss Mbarki | 14/03/2022 
    **/
    public static void thowException(String message){
        AuraHandledException ahe = new AuraHandledException(message);
        ahe.setMessage(message);
        throw ahe;
    }

    /**
     * @description  method used to check if the current user has edit access to the draw record
     * @author Aniss Mbarki | 22/03/2022 
    **/
    public static void checkEditAccessOfCurrentUserOnDraw(Id drawId){
        boolean hasEditAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId =: drawId ].HasEditAccess;
        if(hasEditAccess==false){
            thowException('You are not the owner of this draw ,you cannot do any changes!');
        }
    }

}