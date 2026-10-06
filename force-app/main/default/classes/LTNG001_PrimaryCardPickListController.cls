/**
Change History :
*          #CH01: #Jahangeer Mohammed# #06-01-2022# Added a condition to Check for Primary Cards
*          #CH02 : #D&A Team #24-06-2022# Added alburaq logic.
*          #CH03 : #ANISS MBARKI #01-08-2022# Prepaid Card Requirement.
*          #CH04 : #ANISS MBARKI #11-09-2023# Supplementary card Requirement for Jordan.
*          #CH05 : #Imane Tsioucha# #22-02-2024# add x-canary header
*/
public with sharing class LTNG001_PrimaryCardPickListController {

    @AuraEnabled
    public static List<CurrentCardWrapper> getCurrentCardsViaApi(String accountId ,String caseModel) {//#CH02 add caseModel param
        ApiConnection con = new ApiConnection();
        System.debug('===========++>  '+accountId);
        List<CurrentCardWrapper> currentCards = new List<CurrentCardWrapper>();
        if(accountId != null && accountId != '' ){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            Account accObj = [SELECT Id, CIF__pc,PersonEmail/*,x_canary__pc*/,Region_Flag__c FROM Account WHERE Id=: accountId];
    
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            //#CH02 Start
            String regionName = accObj.Region_Flag__c;
            
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
            
            request = con.createRequest('GET','/api/v1/credit-cards?',regionName);
            System.debug('request==>'+Request.getEndpoint());
            //#CH02 End
    
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            request.setTimeOut(120000);
            /*if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc); //CH05
            }*/

    
            system.debug('---> Request --> '+request.getBody());
            //HttpResponse response = http.send(request);
            
            HttpResponse response = http.send(request);
            
            system.debug('---> Responce New --> '+response.getBody());
    
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Credit Cards API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');//currentCards,pendingCards,cardOptions
                List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
                for(Object curCard : currCardsList){
                    Map<String,Object> mapCurrentCard = (Map<String, Object>)curCard;
                    system.debug('---> mapCurrentCard --> '+mapCurrentCard);
                    //CH01: #Jahangeer Mohammed# #06-01-2022# Added a condition to Check for Primary Cards
                    if(mapCurrentCard.get('isPrimary') == true){
                        //#CH03 -- Start
                        String cardNature = (String) mapCurrentCard.get('cardNature');
                        system.debug('---> cardNature --> '+cardNature);
                        if( cardNature != 'prepaid' ){
                            currentCards.add(new CurrentCardWrapper(String.valueOf(mapCurrentCard.get('cardProductionConfigurationId')) , (String)mapCurrentCard.get('maskedCardNumber') , (String)mapCurrentCard.get('id'),(String)mapCurrentCard.get('cardDisplayName') ,(String)mapCurrentCard.get('productMappingCode')));//#CH04 : add productMappingCode
                        }
                        system.debug('---> currentCards --> '+currentCards);
                        //#CH03 -- End
                    }
                }
            }
        }
        
        return currentCards;
    }


    public with sharing class CurrentCardWrapper {
        
        @AuraEnabled
        public String cardDisplayName {get; set;}
        
        @AuraEnabled
        public String cardProductConfigurationId {get; set;}
        
        @AuraEnabled
        public String maskedCardNumber {get; set;}
        
        @AuraEnabled
        public String productMappingCode {get; set;}//#CH04 : add productMappingCode
        
        @AuraEnabled
        public String id {get; set;}  
        
        public CurrentCardWrapper(String cardProductConfigurationId,String maskedCardNumber,String id,String cardDisplayName,String productMappingCode){
            this.cardProductConfigurationId = cardProductConfigurationId;
            this.maskedCardNumber = maskedCardNumber;
            this.id = id;
            this.cardDisplayName = cardDisplayName;
            this.productMappingCode = productMappingCode; //#CH04
        }
    }

}