/**
 * @author Imane Tsioucha
 * @date Création 29/03/2024
 * @date Modification
 * @description : The function used in LTNG043_CreditCardServiceRequest.
 */
public with sharing class LTNG043_CreditCardServiceReqController {

    private static ApiConnection con = new ApiConnection();
    private static String CLASS_NAME =LTNG043_CreditCardServiceReqController.class.getName();
    private final static List<String> SENSITIVE_FIELDS_EPP_List = new List<String>{
        'tenor',
        'transactionAmount',
        'numberOfInstallementsPaid',
        'numberOfInstallementsRemaining',
        'installementAmount',
        'remainingBalance'
  };
  @AuraEnabled
  public static Id getAccRequestCaseRecordType() {
      return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Credit_Card_Services').getRecordTypeId();
  }
  

  @AuraEnabled(cacheable=false)
  public static List<String> loadEPPList(final String accountId){
    system.debug('testtt==>'+accountId);
     List<String> retrivePCIOption = new List<String>();
    Account accObj = [SELECT Id, CIF__pc,Region_Flag__c,PersonEmail FROM Account WHERE Id=: accountId];
    String regionName = accObj.Region_Flag__c; 
    String personalEMail=accObj.PersonEmail;
    String customerId=accObj.CIF__pc;
    final HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards', customerId, personalEMail, regionName);
    system.debug('---> REQUEST --> '+req);

       HttpResponse response = new HttpResponse();
        String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030004434274","cardSequenceNumber":"0001","expiryDate":"2027-07-01","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Test","maskedCardNumber":"511724******4274","issueDate":"2024-07-01","provider":"Mastercard","isRequestedCard":false,"status":"ACTIVE","parentStatus":"ACTIVE","order":6,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","FREEZE","TRANSACTIONS_CONTROL","CHANGE_CREDIT_LIMIT","UPDATE_CHOSEN_REWARDS","CHANGE_PIN","REPLACE_CARDS"],"cardConfigurations":[{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"10"},{"configCode":"SUPPLEMENTARY_ID_SUPPORTED_COUNTRIES","configValue":"BHR"},{"configCode":"DEFAULT_CREDIT_LIMIT_SAL_500","configValue":"1"},{"configCode":"DEFAULT_CREDIT_LIMIT_SAL_1000","configValue":"2"},{"configCode":"DEFAULT_CREDIT_LIMIT_SAL_999999","configValue":"3"},{"configCode":"DEFAULT_CREDIT_LIMIT_SELF_2000","configValue":"1"},{"configCode":"DEFAULT_CREDIT_LIMIT_SELF_999999","configValue":"1.5"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"5"},{"configCode":"MINIMUM_LIMIT","configValue":"300"},{"configCode":"MAXIMUM_LIMIT","configValue":"15000"},{"configCode":"MINIMUM_CREDIT_LIMIT_SECURED","configValue":"100"},{"configCode":"MINIMUM_CREDIT_LIMIT_UNSECURED","configValue":"100"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"10"},{"configCode":"CASHBACK_ENABLED","configValue":"TRUE"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"5"},{"configCode":"SHOW_ANNUAL_FEES_AMOUNT","configValue":"FALSE"},{"configCode":"SHOW_ANNUAL_RATE","configValue":"TRUE"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BAHRAIN","configValue":"Employed, Self Employed, Retired"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_البحرين","configValue":"Employed, Self Employed, Retired"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BH","configValue":"Employed, Self Employed, Retired"},{"configCode":"SUPPLEMENTARY_CARD_TYPE","configValue":"01"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CODE","configValue":"PLATINUM_CASHBACK_AND_REWARD_01"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CONFIG_ID","configValue":"2"},{"configCode":"SUPPLEMENTARY_MIN_AGE","configValue":"12"},{"configCode":"SUPPLEMENTARY_MAX_AGE","configValue":"150"},{"configCode":"SUPPLEMENTARY_EXPIRY_DATE","configValue":"TRUE"},{"configCode":"SUPPLEMENTARY_VALIDATE_PRIMARY_NATIONAL_ID","configValue":"TRUE"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"5"},{"configCode":"MINIMUM_LIMIT","configValue":"300"},{"configCode":"MAXIMUM_LIMIT","configValue":"15000"},{"configCode":"HAS_DOCUMENTS","configValue":"TRUE"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"GULF_AIR"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"BHD"},{"configCode":"ANNUAL_RATE","configValue":"1.833"},{"configCode":"MINIMUM_CREDIT_LIMIT","configValue":"300"},{"configCode":"CREDIT_LIMIT_MULTIPLAYER","configValue":"4"},{"configCode":"CARD_REPLACEMENT_FEES","configValue":"0"},{"configCode":"CARD_REPLACEMENT_VAT","configValue":"0"},{"configCode":"DEFAULT_REQUESTED_CREDIT_LIMIT","configValue":"5000"},{"configCode":"SUPPLEMENTARY_CARD_FEES","configValue":"5"},{"configCode":"SUPPLEMENTARY_CARD_VAT","configValue":"0.250"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"5"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"GULF_AIR"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"BHD"},{"configCode":"ANNUAL_RATE","configValue":"1.833"}],"enabledMainActions":[{"mainAction":"TRANSACTIONS","status":"SHOW_ENABLED","sortOrder":1},{"mainAction":"PAYMENT","status":"SHOW_ENABLED","sortOrder":2},{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":4},{"mainAction":"SUPPLEMENTARY_CARDS","status":"SHOW_ENABLED","sortOrder":6},{"mainAction":"CC_REWARDS","status":"SHOW_ENABLED","sortOrder":7},{"mainAction":"CASH_ADVANCE","status":"SHOW_ENABLED","sortOrder":8},{"mainAction":"CARD_SETTINGS","status":"SHOW_ENABLED","sortOrder":8}],"primaryCardPciNumber":"2660030004434274","applicationStatus":"APPROVED","blockCode":" ","pendingRequests":[],"canReactivateDormant":false}],"pendingCards":[],"cardOptions":[{"cardProductConfigurationId":1,"productMappingCode":"PLATINUM_BALANCE_TRANSFER_01","cardDisplayName":"ila Switch","cmsCardProductId":"002","cmsCardProductType":"01","order":0,"productStatus":"ORDER","campaign":[{"id":"1","name":"name1","expiryDate":"2022-09-28"},{"id":"2","name":"name2","expiryDate":"2022-09-28"}],"cardConfigurations":[{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"10"},{"configCode":"SHOW_ANNUAL_FEES_AMOUNT","configValue":"FALSE"},{"configCode":"SUPPLEMENTARY_ID_SUPPORTED_COUNTRIES","configValue":"BHR"},{"configCode":"DEFAULT_CREDIT_LIMIT_SAL_500","configValue":"1"},{"configCode":"DEFAULT_CREDIT_LIMIT_SAL_1000","configValue":"2"},{"configCode":"DEFAULT_CREDIT_LIMIT_SAL_999999","configValue":"3"},{"configCode":"DEFAULT_CREDIT_LIMIT_SELF_2000","configValue":"1"},{"configCode":"DEFAULT_CREDIT_LIMIT_SELF_999999","configValue":"1.5"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"5"},{"configCode":"MINIMUM_LIMIT","configValue":"300"},{"configCode":"MAXIMUM_LIMIT","configValue":"15000"},{"configCode":"MINIMUM_CREDIT_LIMIT_SECURED","configValue":"300"},{"configCode":"MINIMUM_CREDIT_LIMIT_UNSECURED","configValue":"300"},{"configCode":"CASH_ADVANCE_VAT_PERCENTAGE","configValue":"10"},{"configCode":"CASHBACK_ENABLED","configValue":"TRUE"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"5"},{"configCode":"SHOW_ANNUAL_RATE","configValue":"TRUE"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BAHRAIN","configValue":"Employed, Self Employed, Retired"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_البحرين","configValue":"Employed, Self Employed, Retired"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES_BH","configValue":"Employed, Self Employed, Retired"},{"configCode":"SUPPLEMENTARY_CARD_TYPE","configValue":"01"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CODE","configValue":"PLATINUM_BALANCE_TRANSFER_01"},{"configCode":"SUPPLEMENTARY_CARD_PRODUCT_CONFIG_ID","configValue":"1"},{"configCode":"SUPPLEMENTARY_MIN_AGE","configValue":"12"},{"configCode":"SUPPLEMENTARY_MAX_AGE","configValue":"150"},{"configCode":"SUPPLEMENTARY_EXPIRY_DATE","configValue":"TRUE"},{"configCode":"SUPPLEMENTARY_VALIDATE_PRIMARY_NATIONAL_ID","configValue":"TRUE"},{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"5"},{"configCode":"MINIMUM_LIMIT","configValue":"300"},{"configCode":"MAXIMUM_LIMIT","configValue":"15000"},{"configCode":"HAS_DOCUMENTS","configValue":"TRUE"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"GULF_AIR"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"BHD"},{"configCode":"ANNUAL_RATE","configValue":"1.833"},{"configCode":"MINIMUM_CREDIT_LIMIT","configValue":"300"},{"configCode":"CREDIT_LIMIT_MULTIPLAYER","configValue":"4"},{"configCode":"CARD_REPLACEMENT_FEES","configValue":"0"},{"configCode":"CARD_REPLACEMENT_VAT","configValue":"0"},{"configCode":"DEFAULT_REQUESTED_CREDIT_LIMIT","configValue":"5000"},{"configCode":"SUPPLEMENTARY_CARD_FEES","configValue":"5"},{"configCode":"SUPPLEMENTARY_CARD_VAT","configValue":"0.250"},{"configCode":"CASH_ADVANCE_FEE_PERCENTAGE","configValue":"5"},{"configCode":"MEMBERSHIP_REFERENCE","configValue":"GULF_AIR"},{"configCode":"ALLOWED_EMPLOYMENT_STATUSES","configValue":"Employed,Self Employed"},{"configCode":"ANNUAL_FEES_AMOUNT","configValue":"0"},{"configCode":"CARD_CURRENCY","configValue":"BHD"},{"configCode":"ANNUAL_RATE","configValue":"1.833"}],"cardNature":["unsecured","secured"],"cardTypeConfigurations":[]},{"cardProductConfigurationId":20,"productMappingCode":"PREPAID","cardDisplayName":"ila prepaid","cmsCardProductId":"006","order":1,"productStatus":"ORDER","campaign":[],"cardConfigurations":[{"configCode":"PREPAID_CARD_COLORS","configValue":"GREEN,BLUE,PINK,COBRANDED"},{"configCode":"PREPAID_DAILY_SPENDING_LIMIT","configValue":"2500"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"},{"configCode":"MAXIMUM_PREPAID_CARDS","configValue":"5"},{"configCode":"MAXIMUM_AGE","configValue":"100"},{"configCode":"HAS_DOCUMENTS","configValue":"TRUE"},{"configCode":"MINOR_MAX_AGE","configValue":"17"},{"configCode":"CARD_CURRENCY","configValue":"BHD"},{"configCode":"MINIMUM_AGE","configValue":"18"},{"configCode":"SHOW_ANNUAL_FEES_AMOUNT","configValue":"TRUE"},{"configCode":"SHOW_ANNUAL_RATE","configValue":"TRUE"},{"configCode":"SUPPLEMENTARY_EXPIRY_DATE","configValue":"TRUE"}],"cardNature":["prepaid"],"prepaidFees":{"adultIssuanceFee":3.000,"adultIssuanceVat":0.300,"minorIssuanceFee":3.000,"minorIssuanceVat":0.300,"replacementFee":5.000,"replacementVat":0.500},"cardTypeConfigurations":[{"cardColor":"GREEN","cardType":"01","cardTypeMappingCode":"PREPAID_01","prepaidFees":{"adultIssuanceFee":3.000,"adultIssuanceVat":0.300,"minorIssuanceFee":3.000,"minorIssuanceVat":0.300,"replacementFee":5.000,"replacementVat":0.500}},{"cardColor":"BLUE","cardType":"02","cardTypeMappingCode":"PREPAID_02","prepaidFees":{"adultIssuanceFee":3.000,"adultIssuanceVat":0.300,"minorIssuanceFee":3.000,"minorIssuanceVat":0.300,"replacementFee":5.000,"replacementVat":0.500}},{"cardColor":"PINK","cardType":"03","cardTypeMappingCode":"PREPAID_03","prepaidFees":{"adultIssuanceFee":3.000,"adultIssuanceVat":0.300,"minorIssuanceFee":3.000,"minorIssuanceVat":0.300,"replacementFee":5.000,"replacementVat":0.500}},{"cardColor":"COBRANDED","cardType":"04","cardTypeMappingCode":"PREPAID_04","prepaidFees":{"adultIssuanceFee":3.000,"adultIssuanceVat":0.300,"minorIssuanceFee":3.000,"minorIssuanceVat":0.300,"replacementFee":5.000,"replacementVat":0.500}}]}]}}';
        response.setStatusCode(200);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json'); 
        system.debug('---> Responce New --> '+response.getBody());
        
     // ApiConnection.Response response = new ApiConnection.Response();
    //   response = con.makeCallout(req);
    //    if(response.isSuccess && null != response.responseData){
        //    final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        if (response.getStatusCode() == 200)
        
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1); 
            
            List<Object> currCardsList = (List<Object>)m1.get('currentCards'); 
            System.debug('---> LIST Current Cards --> '+currCardsList);
            List<Map<String, Object>> lstcardMap = new List<Map<String, Object>> ();
            for(Object curCards : currCardsList){
                 lstcardMap.add((Map<String, Object>)curCards);
                 system.debug('---->> Card Iterations --> '+curCards);
                 
            }
            for(Map<String,Object> mapRelatedCurrentCards : lstcardMap){
                if(mapRelatedCurrentCards.containsKey('id')  ){
                  //  String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                        retrivePCIOption.add((String)mapRelatedCurrentCards.get('id'));
                    
                }
            }
            system.debug('retrivePCIOption||'+retrivePCIOption);
        }
    //   }
      return retrivePCIOption ; 
  }



  @AuraEnabled(cacheable=false)
  public static List<String> loadEPPList_Plan(String accountId,final String pciNumber){
    Account accObj = [SELECT Id, CIF__pc,Region_Flag__c,PersonEmail FROM Account WHERE Id=: accountId];
    List<String> eppList=new List<String>();
    String regionName = accObj.Region_Flag__c; 
      final HttpRequest req = con.createRequest('GET', '/api/v1/credit-cards/'+pciNumber+'/epp', accObj.CIF__pc,regionName);
      system.debug('---> REQUEST --> '+req);
      HttpResponse response = new HttpResponse();
        String body = '{"meta":{"code":"CCRD-1000","message":"Credit card payment is complete successfully."},"data":{"eppList":[{"planNumber":"46001","sequenceNumber":"1","transactionAmount":1200,"currency":{"code":"BHD","description":"Bahrain Dinar","decimalPlaces":3},"merchant":"Sharaf DG","installementBookingDate":"2020-01-01","tenor":"12","numberOfInstallementsPaid":"3","numberOfInstallementsRemaining":"9","installementAmount":"100","remainingBalance":"900","intrestPayment":"","transactionPayment":""},{"planNumber":"46001","sequenceNumber":"1","transactionAmount":1200,"currency":{"code":"BHD","description":"Bahrain Dinar","decimalPlaces":3},"merchant":"Sharaf DG","installementBookingDate":"2020-01-01","tenor":"12","numberOfInstallementsPaid":"3","numberOfInstallementsRemaining":"9","installementAmount":"100","remainingBalance":"900","intrestPayment":"","transactionPayment":""}]}}';
        response.setStatusCode(200);
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json'); 
        system.debug('---> Responce New --> '+response.getBody());
    //   response = con.makeCallout(req);
    //    if(response.isSuccess && null != response.responseData){
        //    final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
        // final Map<String, Object> responseData = (Map<String, Object>)response.responseData;
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1); 
           final Object[] eppLst = (Object[])m1.get('eppList');
          if(CreditCard_SensitiveDataCleaner.loadIsDataCleaningRequired( accObj.CIF__pc)){
              system.debug('SENSITIVE_FIELDS_EPP||'+SENSITIVE_FIELDS_EPP_List);
              CreditCard_SensitiveDataCleaner.removeSensitiveData(eppLst, SENSITIVE_FIELDS_EPP_List); 
          }
          List<Map<String, Object>> lsteppMap = new List<Map<String, Object>> ();
          for(Object curEpp : eppLst){
               lsteppMap.add((Map<String, Object>)curEpp);
               system.debug('---->> lsteppMap Iterations --> '+curEpp);
               
          }
          for(Map<String,Object> mapRelatedCurrentCards : lsteppMap){
              if(mapRelatedCurrentCards.containsKey('planNumber')  ){
                //  String cardNature = (String) mapRelatedCurrentCards.get('cardNature');
                eppList.add((String)mapRelatedCurrentCards.get('planNumber'));
                  
              }
          }
    //   }
      system.debug('test=>'+eppList);
      return eppList; 
  }
}