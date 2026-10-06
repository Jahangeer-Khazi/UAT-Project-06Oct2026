/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:15-08-2024
 * 		Change History: 
 * 					#CH01# #11-08-2026# #Jahangeer Mohammed# Added Campaign Upgrade Logic(NBA-17681)

 *  
 *			  
 */
public class CreditCardUpgradeRequestController {
private static ApiConnection con = new ApiConnection();
    @AuraEnabled(cacheable=false)
    public static String getDefaultName(String accID){
        String name;
        Account acc = [SELECT Id, PersonContact.FirstName, PersonContact.MiddleName, PersonContact.LastName From Account WHERE Id =:accID];
        String middlename =' ';
        if(acc.PersonContact.MiddleName != NULL){middlename = ' '+acc.PersonContact.MiddleName+' ';}
        return name = acc.PersonContact.FirstName+middlename+acc.PersonContact.LastName;

    }
    //CH01: Start
    @AuraEnabled
	public static Boolean isCampaignUpgradeUser() {
    	User currentUser = [SELECT Id, Is_Campaign_Upgrade__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    	return currentUser.Is_Campaign_Upgrade__c;
	}
    //CH01: END
	@AuraEnabled(cacheable=false)
    public static Map<String,Object> getCreditCardPCIOptions(String accID,String caseModel){
        Map<String,Object> retrivePCIOption = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
        
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); 
        }
		request.setTimeout(60000);
        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
       
        system.debug('---> Responce New --> '+response.getBody());


        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',false);

        }
        else
        {
            System.debug('Response Body:'+response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                if(mapRelatedCurrentCards.containsKey('id') && mapRelatedCurrentCards.get('isPrimary') == true 
                    && mapRelatedCurrentCards.containsKey('cardNature') ){
                    String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                    // Checking cardNature == unsecured and cardStatus == ACTIVE
                    String cardStatus = (String) mapRelatedCurrentCards.get('status');
                    
                    if(!cardNature.contains('prepaid') && (cardNature == 'unsecured' || cardNature == 'secured') && cardStatus == 'ACTIVE'){ //Excluding Cash Collateral Cards
                        retrivePCIOption.put((String)mapRelatedCurrentCards.get('id'),mapRelatedCurrentCards);
                    }
                    
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
        }
        return retrivePCIOption;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getCreditCardUpgradeOptions(String accID,String caseModel, String subType){
        System.debug('Sub Type Value:'+subType);
        Map<String,Object> retriveUpgradePCIOption = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
        
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); 
        }
		request.setTimeout(60000);
        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
       
        system.debug('---> Responce New --> '+response.getBody());


        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',false);

        }
        else
        {
            System.debug('Response Body:'+response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> cardOptionList = (List<Object>)m1.get('cardOptions'); //Card Options Array
            System.debug('---> LIST Card Options --> '+cardOptionList);
            
            List<Map<String, Object>> lstcardOptionMap = new List<Map<String, Object>> ();
            for(Object cardOption : cardOptionList){
                 lstcardOptionMap.add((Map<String, Object>)cardOption);
                 system.debug('---->> Card Option Iterations --> '+JSON.serializePretty(cardOption));
            } //for loop End
            system.debug('---->> List Card Option Map --> '+lstcardOptionMap);
            
            for(Map<String, Object> optionMap : lstcardOptionMap)
            {
               
                if(optionMap.containsKey('productStatus') && (String)optionMap.get('productStatus') == 'UPGRADE' && subType == 'Credit Card Upgrade - No Limit Increase')
                {
                     system.debug('---->> productStatus --> '+(String)optionMap.get('productStatus') == 'UPGRADE');
                    retriveUpgradePCIOption.put((String)optionMap.get('cardDisplayName'),(String)optionMap.get('productMappingCode'));
                }
                else if(subType == 'Credit Card Limit Split' && (String)optionMap.get('productMappingCode') != 'PREPAID'){
                    //retriveUpgradePCIOption.put((String)optionMap.get('cardDisplayName'),(String)optionMap.get('productMappingCode'));
                    retriveUpgradePCIOption.put((String)optionMap.get('cardDisplayName'),optionMap);
				}
            } //for loop End
            System.debug('Retreive Upgrade PCI Option:'+retriveUpgradePCIOption);
        } //Else End
        return retriveUpgradePCIOption;
    }
    @AuraEnabled(cacheable=false)
    public static boolean checkOtherCardsExist(String accID){
        String cardType = System.Label.TYPE_OF_CREDIT_CARDS;  
        Set<String> cardTypes = new Set<String>();
        if (!String.isBlank(cardType)) {
            for (String typeValue : cardType.split(',')) {
                cardTypes.add(typeValue.trim());
            }
        }
        List<case> lstCase = [Select id,Type,Sub_Type__c,AccountId,Status from Case where Status NOT IN('Closed') AND Type IN : cardTypes AND Region_Flag__c = 'Bahrain' AND AccountId =: accID];
        return lstCase.size()>0;
    }
   
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getPCIOptionsSuppCards(String accID,String caseModel,String requestedPCINumber){
        System.debug('Requested PCI Number:'+requestedPCINumber);
        Map<String,Object> retriveSuppPCIOption = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
        
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/credit-cards?', regionName);

        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); 
        }
		request.setTimeout(60000);
        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        HttpResponse response = http.send(request);
       
        system.debug('---> Responce New --> '+response.getBody());


        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',false);

        }
        else
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  // meta, data
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1);  // currentCards,pendingCards,cardOptions
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                if(mapRelatedCurrentCards.containsKey('id') && mapRelatedCurrentCards.get('isPrimary') == false && mapRelatedCurrentCards.containsKey('cardNature') && 
                   mapRelatedCurrentCards.get('primaryCardPciNumber') == requestedPCINumber ){
                    String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                    String cardStatus = (String) mapRelatedCurrentCards.get('status');
                    if(!cardNature.contains('prepaid') && (cardNature == 'unsecured' || cardNature == 'secured') && cardStatus == 'ACTIVE'){
                        retriveSuppPCIOption.put((String)mapRelatedCurrentCards.get('id'),mapRelatedCurrentCards);
                        System.debug('Supp PCI Options'+retriveSuppPCIOption);
                    }
                    else{
                        System.debug('No Supp Cards for Selected PCI Number');  
                    }
                    
                }
            }
        }
        return retriveSuppPCIOption;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> loadCardDetails(String accID,String caseModel,String requestedPCINumber){
        Map<String,Object> creditCardDetail = new Map<String,Object>();
        Map<String,Object> creditCardDetailData = new Map<String,Object>();
        Decimal creditLimit;
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
        
        String regionName = accObj.Region_Flag__c;
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
        }
         
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request = con.createRequest('GET','/api/v1/credit-cards/'+requestedPCINumber+'/details', regionName);
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null){
            request.setHeader('x-canary', accObj.x_canary__pc); 
        }
		request.setTimeout(60000);
        System.debug('End Point Credit Card Detail ==>'+Request.getEndpoint());
        system.debug('---> Request Body --> '+request.getBody());
        HttpResponse response = http.send(request);
       
        system.debug('---> Response Getting from API in Credit Card detail --> '+response.getBody());
        if (response.getStatusCode() != 200)
        {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            lstSA = initiateManualOnboarding.createSystemAction(request.getBody(),response.getBody(),'callout:NeoBank_Endpoint/api/v1/credit-cards?language=en&unit=neo','GET',Null,accObj.CIF__pc,accObj.Id,response.getStatusCode(), 'Credit Card Application', 'Credit Card',false);

        }
        else{
            System.debug('Credit Card Detail Response:'+response.getBody());
            creditCardDetail = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); //meta, data
            creditCardDetailData = (Map<String, Object>)creditCardDetail.get('data');
            System.debug('Credit Card Detail Data:'+creditCardDetailData);
            //creditLimit = (Decimal)creditCardDetailData.get('creditLimit');
        }
        
        return creditCardDetailData;
    }
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> fetchGulfAirId(String customerId, String membershipId) {
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,x_canary__pc, Region_Flag__c FROM Account WHERE Id=: customerId];//CH12

        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = accObj.Region_Flag__c;
		request = con.createRequest('GET','/api/v1/gulf-air/details',regionName);
		String endPoint = request.getEndpoint();
        request.setEndpoint(endPoint + '&membershipNumber='+membershipId);
        System.debug('Get End-Point:'+request.getEndPoint());
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null ){
            request.setHeader('x-canary', accObj.x_canary__pc);
        }
		HttpResponse response = http.send(request);
        Map<String, Object> responseMap;
        if(response.getStatusCode() != 200){
           System.debug('The status code returned was not expected: ' +response.getStatusCode());
           System.debug('Un-Successful response from the API:'+response.getBody());
           responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

		}
        else{
            System.debug('Successful Response from the API:'+response.getBody());
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		}
        return responseMap;
    }
     @AuraEnabled(cacheable=false)
    public static Map<String,Object> enrollGulfAirMembershipId(String customerId) {
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,x_canary__pc, Region_Flag__c FROM Account WHERE Id=: customerId];//CH12

        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = accObj.Region_Flag__c;
		request = con.createRequest('POST','/api/v1/gulf-air/enroll',regionName);
		
        System.debug('Get End-Point:'+request.getEndPoint());
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null ){
            request.setHeader('x-canary', accObj.x_canary__pc);
        }
		HttpResponse response = http.send(request);
        Map<String, Object> responseMap;
        if(response.getStatusCode() != 200){
           System.debug('The status code returned was not expected: ' +response.getStatusCode());
           System.debug('Un-Successful response from the API:'+response.getBody());
           responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

		}
        else{
            System.debug('Successful Response from the API:'+response.getBody());
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		}
        return responseMap;
    }
     @AuraEnabled(cacheable=false)
    public static Map<String,Object> manageGulfAirMembershipId(String customerId, String membershipId) {
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,x_canary__pc, Region_Flag__c FROM Account WHERE Id=: customerId];//CH12

        ApiConnection con = new ApiConnection();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String regionName = accObj.Region_Flag__c;
		request = con.createRequest('POST','/api/v1/gulf-air/manage',regionName);
		
        System.debug('Get End-Point:'+request.getEndPoint());
        request.setHeader('userId', accObj.PersonEmail);
        request.setHeader('customerId', accObj.CIF__pc);
        if(accObj.x_canary__pc != null ){
            request.setHeader('x-canary', accObj.x_canary__pc);
        }
        String body = '';
        body = '{"membershipNumber": "'+membershipId + 
                 '","action": "UPDATE"}';
		request.setBody(body);
        HttpResponse response = http.send(request);
        Map<String, Object> responseMap;
        if(response.getStatusCode() != 200){
           System.debug('The status code returned was not expected: ' +response.getStatusCode());
           System.debug('Un-Successful response from the API:'+response.getBody());
           responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
        }
        else{
            System.debug('Successful Response from the API:'+response.getBody());
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		}
        return responseMap;
    }
    @AuraEnabled
    public static String checkCaseSubType(string caseId){
        String caseSubType;
        try{
           Case cs = [Select Id, Type, Sub_Type__c from Case where id =: caseId];
           caseSubType = cs.Sub_Type__c;
           return caseSubType;
        } 
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
        
    }
}