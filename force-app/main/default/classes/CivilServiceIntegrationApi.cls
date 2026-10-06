/**
* @author Aniss Mbarki
* @date Création 06/10/2023
* @date Modification
* @description : to hundel Civil Service Integration Api //will be called If (the case is opened by the app + id type = "Civil ID")
*/
public without sharing class CivilServiceIntegrationApi {
    
    private static String CLASS_NAME = CivilServiceIntegrationApi.class.getName();
    private static ApiConnection con = new ApiConnection();
    private static List<System_Action__c> lstSA = new List<System_Action__c>();
    

    @InvocableMethod(label='call Civil Service Integration Api' description='to hundel Civil Service Integration Api' callout=true )
    public static List<String> civilServiceIntegApiFromFlow(List<Id> caseIds)
    {
        civilServiceIntegApiFuture(new Set<Id>(caseIds));

        return caseIds;
    }

    @future(callout=true)
    public static void civilServiceIntegApiFuture (Set<Id> caseIds)
    {
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for(Case caseObj : cases){
            try {

                if( (caseObj.cc_CC_Application_Source__c == 'API' && caseObj.sc_Jumio_Verification_Status__c == 'APPROVED_VERIFIED') || 
                     (caseObj.cc_CC_Application_Source__c == 'Manual') ){
                    
                    caseObj = civilDepartProcess(caseObj);

                }else if(caseObj.cc_CC_Application_Source__c == 'API' && caseObj.sc_Jumio_Verification_Status__c != null && caseObj.sc_Jumio_Verification_Status__c != 'APPROVED_VERIFIED'){
                    caseObj.OwnerId = System.Label.Jordan_Credit_Card_Temp_Queue;
                    caseObj.cc_Send_notification_dateTime__c = System.now();
                    caseObj.cc_Customer_Response__c = 'Customer Not Responded';
                    caseObj.Awaiting_Customer_Feedback__c = true;
                    caseObj.Sub_Status__c = 'Pending';
                }

                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,null, 
                                                         caseObj.Type+' civilServiceIntegApiFromFlow (unhandled error)', caseObj.Type
                                                        ));
                caseObj.Last_Api_Call_Status__c = 'Failed';
            }

        }

        if(cases != null && cases.size()>0){
            update cases;
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
    }


    public static Boolean validateSuppCardFields(Case caseObj){

        //mandatory fields
        if( caseObj.sc_Card_Holder_ID_Number__c == null || caseObj.sc_Card_Holder_Jordan_ID_Number__c == null || caseObj.sc_Card_Holder_ID_Expiry_Date__c == null || caseObj.sc_Card_Holder_ID_Issuing_Country__c  == null || caseObj.sc_Card_Holder_Date_of_Birth__c == null || caseObj.sc_Card_Holder_Gender__c == null || caseObj.sc_Card_Holder_First_Name__c == null || caseObj.sc_Card_Holder_Second_Name__c == null || caseObj.sc_Card_Holder_Third_Name__c == null || caseObj.sc_Card_Holder_Last_Name__c == null || caseObj.sc_Card_Holder_Arabic_First_Name__c == null || caseObj.sc_Card_Holder_Arabic_Second_Name__c == null || caseObj.sc_Card_Holder_Arabic_Third_Name__c == null || caseObj.sc_Card_Holder_Arabic_Last_Name__c == null || caseObj.sc_Card_Holder_Nationality__c == null || caseObj.sc_Card_Holder_Death_Status__c == null) 
        {
            return false;
        }
        return true;
    }
	
	public static String stringApiFormat(String input){
        if(input != null){
            return '"'+ input +'"';
        }else{
            return 'null';
        }
    }
	
	public static String dateToApiDateFormat(Date input){
        if(input != null){
            Datetime output = input;
            return output.format('yyyy-MM-dd');
        }else{
            return null;
        }
    }

    public static Case civilDepartProcess(Case caseObj){
        System.debug('civilDepartProcess: **************');


        Boolean civilDepartWentWrong = false;
        if( caseObj.CivilDepart_Api_Retry_Counter__c == null ){
            caseObj.CivilDepart_Api_Retry_Counter__c = 0;
        }

        String regionName = caseObj.Region_Flag__c;
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }
        
        Http http = new Http();
        HttpRequest request = con.createRequest('PUT', '/api/v1/government-data/jo-civil-service/person/crm',regionName);
        request.setHeader('userId', caseObj.Account.PersonEmail);
        request.setHeader('customerId', caseObj.Account.CIF__pc);
        //CH01 : enhacement supplementary card for Joradn 
        String body = '{"uidValue": "'+ caseObj.sc_Card_Holder_Jordan_ID_Number__c +
					  '","cardNo": "'+ caseObj.sc_Card_Holder_ID_Number__c +
					  '","dateOfBirth": '+ stringApiFormat(dateToApiDateFormat(caseObj.sc_Card_Holder_Date_of_Birth__c)) +
					  ',"crmSync": true, "promoteGovernmentDataToCustomerProfile": false}';
        request.setBody(body);

        request.setTimeout(60000);
        HttpResponse response;
        if ( test.isRunningTest() ) {
            //fake response 
            response = new HttpResponse();
            String body1 = '{"meta":{"code":"CCRD-1500","message":"Credit card request status has been updated successfully."},"data":{"customerCivilDetailResponse":{"cardNo": "123456","birthDate":"1986-09-11","Gender":"M","enFName":"FirstNameTest","EnSName":"SecondNameTest","EnTName":"ThirdNameTest","EnLName":"EnLastNameTest","ArFName":"ArFNameTest","ArSName":"ArSNameTest","ArTName":"ArTNameTest","ArLName":"ArLNameTest","cexpDt":"2023-10-05","nationality":"JO","death":"alive"}}}';
            response.setStatus('OK');    
            response.setStatusCode(200);
            response.setBody(body1);
            response.setHeader('Content-Type', 'application/json');
        }else{
            response = http.send(request);
        }

        //store response as system action !
        lstSA.add(SM001_ApiCalls.setSystemAction( request.getBody(),response.getBody(),
                                                    request.getEndpoint(),request.getMethod(),
                                                    caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response.getStatusCode(), 
                                                    'Calling Civil Service Integration Api', caseObj.Type
                                                    ));

        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            caseObj.Last_Api_Call_Status__c = 'Failed';
            civilDepartWentWrong = true;
        }
        else
        {
            //logic : .... api response need correct one...
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> m0 = (Map<String, Object>)m.get('data');
            Map<String, Object> m1 = (Map<String, Object>)m0.get('customerCivilDetailResponse');
            caseObj.sc_Card_Holder_ID_Number__c = (String)m1.get('cardNo');
            caseObj.sc_Card_Holder_Date_of_Birth__c = Date.valueOf((String)m1.get('birthDate'));
            String genderStr = String.valueOf(m1.get('gender'));
            if(genderStr == 'Female'){
                caseObj.sc_Card_Holder_Gender__c = 'F';
            }else if(genderStr == 'Male'){
                caseObj.sc_Card_Holder_Gender__c = 'M';
            }
            caseObj.sc_Card_Holder_First_Name__c = String.valueOf(m1.get('enFName'));
            caseObj.sc_Card_Holder_Second_Name__c  = String.valueOf(m1.get('enSName'));
            caseObj.sc_Card_Holder_Third_Name__c  = String.valueOf(m1.get('enTName'));
            caseObj.sc_Card_Holder_Last_Name__c  = String.valueOf(m1.get('enLName'));
            caseObj.sc_Card_Holder_Arabic_First_Name__c  = String.valueOf(m1.get('arFName'));
            caseObj.sc_Card_Holder_Arabic_Second_Name__c  = String.valueOf(m1.get('arSName'));
            caseObj.sc_Card_Holder_Arabic_Third_Name__c  = String.valueOf(m1.get('arTName'));
            caseObj.sc_Card_Holder_Arabic_Last_Name__c  = String.valueOf(m1.get('arLName'));
            caseObj.sc_Card_Holder_ID_Expiry_Date__c  = Date.valueOf((String)m1.get('cexpDt'));
            caseObj.sc_Card_Holder_Nationality__c  = String.valueOf(m1.get('nationality')); 
            caseObj.sc_Card_Holder_Death_Status__c  = String.valueOf(m1.get('death'));
            //Name Screening First Name
            //Name Screening Second Name
            //Name Screening Last Name

            if( validateSuppCardFields(caseObj) == true ){
                caseObj.OwnerId = System.Label.Jordan_Supplementary_Maker_Queue;
            }else{
                civilDepartWentWrong = true;
            }
        }

        if( civilDepartWentWrong == true ){
            if ( caseObj.CivilDepart_Api_Retry_Counter__c == 0 ) {
                caseObj.CivilDepart_Api_Date_Retry_init__c = System.now();
            }
        }else{
            caseObj.CivilDepart_Api_Date_Retry_init__c = null;
        }
        caseObj.CivilDepart_Api_Retry_Counter__c ++;
        
        return caseObj;
    }


    @AuraEnabled
    public static String enterIdNumberButton(Id caseId , String cardHolderIdNumber, String cardHolderIdType){
        List<Case> cases = new List<Case>();
        if (caseId != null) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id = :caseId';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }
        if (cases.size()>0) {
            Case caseObj = cases.get(0);
            caseObj.sc_Card_Holder_Jordan_ID_Number__c = String.valueof(cardHolderIdNumber);
            caseObj = civilDepartProcess(caseObj);
            
            update cases;
            if(lstSA != null && lstSA.size()>0){
                insert lstSA;
            }
        }
        
        return null;
    }
    
}