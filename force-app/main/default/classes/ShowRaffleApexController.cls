/**
 * @description       : This controller is used to get the right template Id
 * @author            : ismael.ocana
 * @group             :
 * @last modified on  : 25/02/2022
 * @last modified by  : Aniss Mbarki
 * @History : 
 *  #CH01 : 26/01/2024 BY Aniss Jordan changes
 *  #CH02 : 18/04/2025 BY Aniss NBA-13163(Al Kanz - Changes to Raffle Application for Staff & Relatives Draws)
 **/
public with sharing class ShowRaffleApexController {

    /**
     * @description This method is going to be invoked when the Excute Raffle button is clicked
     * @author ismael.ocana | 26/10/2021
     * @param String drawId
     * @return String It will return the templateId to use in the visualforce pages
     * @last modified by  : Aniss.Mbarki 09/03/2022
     **/
    @AuraEnabled
    public static String getURL(String drawId){
        Draw__c d;
        try {
            d = DM004_Draw.getDrawByIds(new Set<Id>{drawId}).get(0);
        } catch (Exception e) {
            SM003_DrawHandler.thowException(System.label.DRAW_ID_NOT_FOUND);
        }
        if(d.Status__c != System.label.BUTTON_STATUS_RAFFLE){
            SM003_DrawHandler.thowException(System.label.RAFFLE_NOT_RIGHT_STATUS);
        }

        SM003_DrawHandler.checkEditAccessOfCurrentUserOnDraw(drawId);
        
        // Added condition based on custom auditor fields JT 010222 NBA-4682
        //#CH01 /#CH02 : START
        if( d.RegionFlag__c != 'Jordan' && d.Draw_Type__c != 'kanzStaff' && (String.isBlank(d.External_Auditor_Name__c) || String.isBlank(d.Internal_Auditor_Name__c) || String.isBlank(d.MOIC_Representative_Name__c) || String.isBlank(d.ila_Marketing__c) || String.isBlank(d.ila_Business__c) || String.isBlank(d.ila_Finance__c))){
			SM003_DrawHandler.thowException(System.label.AUDITOR_FIELDS_REQUIRED);            
        }
        if( d.RegionFlag__c != 'Jordan' && d.Draw_Type__c == 'kanzStaff' && (String.isBlank(d.External_Auditor_Name__c) || String.isBlank(d.Internal_Auditor_Name__c) || String.isBlank(d.MOIC_Representative_Name__c) || String.isBlank(d.ila_Marketing__c) || String.isBlank(d.ila_Business__c) || String.isBlank(d.ila_Operations__c) || String.isBlank(d.ila_HR__c))){
			SM003_DrawHandler.thowException(System.label.KANZ_STAFF_RELATIVES_AUDITOR_FIELDS_REQUIRED);            
        }

        if( d.RegionFlag__c == 'Jordan' && (String.isBlank(d.External_Auditor_Name__c) || String.isBlank(d.Internal_Auditor_Name__c) || String.isBlank(d.ila_Marketing__c) || String.isBlank(d.ila_Business__c) || String.isBlank(d.ila_Risk__c) || String.isBlank(d.ComplianceDepartment__c) || String.isBlank(d.LegalDepartment__c) || String.isBlank(d.HumanResourcesDepartment__c))){
			SM003_DrawHandler.thowException(System.label.JORDAN_AUDITOR_FIELDS_REQUIRED);            
        }
        //#CH01 /#CH02: end

        
        if(String.isBlank(d.Template_Id__c)){
            SM003_DrawHandler.thowException(System.label.TEMPLATE_MISSING);
        }

        return 'apex/' + d.Template_Id__c;
    }

    /** 
     * @author Aniss Mbarki
     * @date Création 14/03/2022
     * @description method used to call the api to create the winners on crm
     */
    @AuraEnabled
    public static Boolean createWinnerListApi(String drawId){
        Boolean isError = false;
        Draw__c d = DM004_Draw.getDrawByIds(new Set<Id>{drawId}).get(0);
        ApiConnection con = new ApiConnection();
        //#CH01
        final HttpRequest req = con.createRequest('GET', '/api/v1/raffle/winners/'+d.Draw_IdFromRaffleService__c,d.RegionFlag__c);
        try {
            //call api to get the list of winners !!
            isError = SM003_DrawHandler.getDrawWinnersViaApi(d.Id,req);
            
        }  catch (Exception e) {
            isError = true;
            System.debug(e.getCause()+';ErrorMessage : '+e.getMessage());
            insert SM003_DrawHandler.setSystemAction(drawId,'Get Winner Api (unhandled error)',req.getEndpoint(), req.getMethod(), null, null, null, 'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),'Failed');
        }
        return isError;
    }
}