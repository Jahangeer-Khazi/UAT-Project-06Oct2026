/**
 * @description       : This is a Controller class for aura cmp LTNG25_NewPrepaidCard
 * @author            : ANISS MBARKI
 * @creation date     : 04-07-2022
 * History Changes :     
 *                     #CH01 : #Imane Tsioucha# #22-02-2024# add x-canary header
**/
public without sharing class LTNG25_NewPrepaidCardController {

    @AuraEnabled
	public static Id getPrepaidCardCaseRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ppc_Prepaid_Card').getRecordTypeId();
    }

    @AuraEnabled
	public static Object getPrepaidCardConfigViaApi(String accountId,String caseModel) {
        ApiConnection con = new ApiConnection();

        System.debug('===========++>  '+accountId);
        if(accountId != null && accountId != '' ){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,x_canary__pc,Region_Flag__pc,FirstName,LastName FROM Account WHERE Id=: accountId];
            String regionName = accObj.Region_Flag__pc;
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }

            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('GET','/api/v1/credit-cards?',regionName);
    
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc); //CH01
            }

    
            system.debug('---> Request EndPoint --> '+ request.getEndPoint() );
            system.debug('---> Request Header userId --> '+ accObj.PersonEmail );
            system.debug('---> Request Header customerId --> '+accObj.CIF__pc );
            system.debug('---> Request --> '+request.getBody());

            HttpResponse response;
            if( !test.isRunningTest() ){
                response = new Http().send(request);
            }else{
                //fake response
                response = new HttpResponse();
                String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030003081773","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blu12e","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","maskedCardNumber":"511724XXXXXX1773","issueDate":"2024-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","CHANGE_CREDIT_LIMIT","TRANSACTIONS_CONTROL"],"cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}],"enabledMainActions":[{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":7}],"primaryCardPciNumber":"2660030003081773","applicationStatus":"","blockCode":"O","pendingRequests":[]}],"pendingCards":[{"id":"16511","cardProductConfigurationId":2,"cardType":"01","productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","status":"PENDING","order":1000,"caseId":"5007Y00000IlpWNQAZ","embossName":"MOHAMED ALBASRI","createdDate":"2021-09-26T14:45:36","modifiedDate":"2021-09-26T14:45:36","closureDate":"2021-09-26T14:45:36","creditLimit":4000.00000,"requestType":"CREDIT_CARD_ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}]}],"cardOptions":[{"cardProductConfigurationId":4,"productMappingCode":"TITANIUM_CO_BRAND_01","cardDisplayName":"Prepaid Card Product","cmsCardProductId":"005","cmsCardProductType":"01","order":2,"productStatus":"ORDER","cardConfigurations":[{"configCode":"PREPAID_CARD_ISSUANCE_FEE_MINOR","configValue":"2"},{"configCode":"PREPAID_CARD_ISSUANCE_VAT_MINOR","configValue":"0"},{"configCode":"PREPAID_CARD_ISSUANCE_FEE_ADULT","configValue":"3.00"},{"configCode":"PREPAID_CARD_ISSUANCE_VAT_ADULT","configValue":"0.30"}],"cardNature":["unsecured","prepaid"] ,"prepaidFees":{"adultIssuanceFee":1,"adultIssuanceVat":2,"minorIssuanceFee":0,"minorIssuanceVat":0} }]}}';
                response.setStatus('OK');    
                response.setStatusCode(200);
                response.setBody(body);
                response.setHeader('Content-Type', 'application/json');
            }
            system.debug('---> Responce New --> '+response.getBody());
    
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Credit Cards API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');//currentCards,pendingCards,cardOptions
                List<Object> cardOptionsList = (List<Object>)m1.get('cardOptions'); //cardOptions
                for(Object cardOption : cardOptionsList){
                    Map<String,Object> mapCardOption = (Map<String, Object>)cardOption;
                    for(Object cardNature : (List<Object>)mapCardOption.get('cardNature') ){
                        if(( (String)cardNature) == 'prepaid'){ //toDo : check this condition
                            System.debug('prepaid card config founded !');
                            Map<String,Object> mapPrepaidCardConfig = new Map<String,Object>();
                            
                            mapPrepaidCardConfig.put( 'defaultCardName',accObj.FirstName + ' ' + accObj.LastName );

                            mapPrepaidCardConfig.put('cardProductConfigurationId',String.valueOf(mapCardOption.get('cardProductConfigurationId')));
                            mapPrepaidCardConfig.put('productMappingCode',mapCardOption.get('productMappingCode'));
                            mapPrepaidCardConfig.put('cardDisplayName',mapCardOption.get('cardDisplayName'));
                            mapPrepaidCardConfig.put('primaryCardPciNumber',mapCardOption.get('primaryCardPciNumber'));

                            /* for(Object cardConf : (List<Object>)mapCardOption.get('cardConfigurations') ){
                                Map<String,Object> mapCardConf = (Map<String, Object>)cardConf;
                                if( ((String)mapCardConf.get('configCode')) == 'PREPAID_CARD_ISSUANCE_FEE_ADULT' ){
                                    mapPrepaidCardConfig.put('ppc_Adult_Issuance_Fee',mapCardConf.get('configValue'));
                                }else if( ((String)mapCardConf.get('configCode')) == 'PREPAID_CARD_ISSUANCE_VAT_ADULT' ){
                                    mapPrepaidCardConfig.put('ppc_Adult_Issuance_VAT',mapCardConf.get('configValue'));
                                }else if( ((String)mapCardConf.get('configCode')) == 'PREPAID_CARD_ISSUANCE_FEE_MINOR' ){
                                    mapPrepaidCardConfig.put('ppc_Minor_Issuance_Fee',mapCardConf.get('configValue'));
                                }else if( ((String)mapCardConf.get('configCode')) == 'PREPAID_CARD_ISSUANCE_VAT_MINOR' ){
                                    mapPrepaidCardConfig.put('ppc_Minor_Issuance_VAT',mapCardConf.get('configValue'));
                                }
                            } */

                            Map<String,Object> mapCardConf = (Map<String, Object>)mapCardOption.get('prepaidFees');

                            mapPrepaidCardConfig.put('cardTypeConfigurations',mapCardOption.get('cardTypeConfigurations'));

                            mapPrepaidCardConfig.put('ppc_Adult_Issuance_Fee',mapCardConf.get('adultIssuanceFee'));
                            mapPrepaidCardConfig.put('ppc_Adult_Issuance_VAT',mapCardConf.get('adultIssuanceVat'));
                            mapPrepaidCardConfig.put('ppc_Minor_Issuance_Fee',mapCardConf.get('minorIssuanceFee'));
                            mapPrepaidCardConfig.put('ppc_Minor_Issuance_VAT',mapCardConf.get('minorIssuanceVat'));


                            System.debug('---> '+ mapPrepaidCardConfig);
                            return mapPrepaidCardConfig;
                        }
                    }
                }
            }
        }
        
        return null;
    }

    @AuraEnabled
    public static CardApprovedDetails approvePrepaidCardApi(Id caseId){

        CardApprovedDetails cardApprovedDetail= new CardApprovedDetails() ;

        ApiConnection con = new ApiConnection();
        Case caseObj = DM002_Case.getListByIds(new Set<Id>{caseId}).get(0);
        String regionName = caseObj.Region_Flag__c;
        if (caseObj.Case_Model__c == 'alburaq') {
            regionName += '_alburaq';
        }

        HttpRequest request2 = con.createRequest('PUT','/api/v1/credit-cards/request',regionName);
        //START CH01
        if( caseObj.Account.x_canary__pc != null ){
            request2.setHeader('x-canary', caseObj.Account.x_canary__pc);
        }
        //END CH01
        request2.setTimeout(60000);
        HttpResponse response2 = SM001_ApiCalls.updatePrepaidCardRequestStatusApi(request2,caseObj,'APPROVED');
        
        if(response2.getStatusCode() != 200){                
            System.debug('The status code returned when calling Update Credit Card Status api was not expected: ' + response2.getStatusCode() + ' ' + response2.getStatus());
            caseObj.Last_Api_Call_Status__c = 'Failed';
            
            insert SM001_ApiCalls.setSystemAction( request2.getBody(),response2.getBody(),
                                request2.getEndpoint(),request2.getMethod(),
                                caseObj.id,caseObj.Customer_CIF__c,caseObj.accountId,response2.getStatusCode(), 
                                'Calling Credit Card Update Status Api', 'Prepaid Credit Card'
                            );

        }else{
            Prepaid_CreditCard__c objPrepCard = [SELECT Id FROM Prepaid_CreditCard__c WHERE Related_Case__c =: caseObj.Id LIMIT 1 ]; 
            objPrepCard.Status__c = 'Active';
            caseObj.Sub_Status__c = 'Approved';
            caseObj.Status = 'Closed';
            update caseObj;
            update objPrepCard;
            cardApprovedDetail.successMessageFromApi = 'Prepaid Card approved successfully!';
        }

        return cardApprovedDetail;
    }

    @AuraEnabled
public static Account getAccountDetails(String accountId) {
    try {
        return [SELECT Id, PersonEmail, PersonMobilePhone 
                FROM Account 
                WHERE Id = :accountId 
                LIMIT 1];
    } catch (Exception e) {
        throw new AuraHandledException('Error fetching account details: ' + e.getMessage());
    }
}

    public class CardApprovedDetails {
    
        @AuraEnabled 
        public String successMessageFromApi  {get; set;}
    }
}