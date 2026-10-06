/*      Organization : ABC Bank
*       Created By: Jahangeer Mohammed
*       Created Date: 07-05-2026
*       Change History: 
*        
*/
public class DeviceDetailsController {
    private static ApiConnection con = new ApiConnection();
    
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> loadDeviceList(String accID){
        Map<String,Object> retriveDeviceOptions = new Map<String,Object>();
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c FROM Account WHERE Id=: accID];
         
        String regionName = accObj.Region_Flag__c;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
       
        request = con.createRequest('GET','/api/v1/ping/user/devices', regionName);

        request.setHeader('customerId', accObj.CIF__pc);

        System.debug('request==>'+Request.getEndpoint());
        system.debug('---> Request --> '+request.getBody());
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200)
        {
            System.debug(response.getBody());
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('---> MAP m --> '+m);  
            System.debug('---> MAP m VALUES --> '+m.Values());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
            System.debug('---> MAP m1 --> '+m1); 
            List<Object> devicesList = (List<Object>)m1.get('devices'); 
            System.debug('---> LIST devicesList --> '+devicesList);
            List<Map<String, Object>> lstDeviceMap = new List<Map<String, Object>> ();
            for(Object deviceObj : devicesList){
                lstDeviceMap.add((Map<String, Object>)deviceObj);
                system.debug('---->> deviceObj Iterations --> '+deviceObj);
                 
            }
            for(Map<String,Object> mapRelatedDevice : lstDeviceMap){
                if(mapRelatedDevice.containsKey('id')  ){
                    retriveDeviceOptions.put((String)mapRelatedDevice.get('id'),mapRelatedDevice);
                }
            }
            system.debug('retriveDeviceOptions||'+retriveDeviceOptions);
        }
        return retriveDeviceOptions;
    }
    
    @AuraEnabled
    public static List<CardWrapper> getCurrentCards(String accID) {
        
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];

        List<CardWrapper> cards = new List<CardWrapper>();

        try {

            HttpRequest request = new HttpRequest();
            request = con.createRequest('GET','/api/v1/credit-cards', accObj.Region_Flag__c);
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            if(accObj.x_canary__pc != null ){
            	request.setHeader('x-canary', accObj.x_canary__pc);
        	}

            Http http = new Http();
            HttpResponse response = http.send(request);

            if(response.getStatusCode() == 200) {

                ApiResponse responseObj = (ApiResponse)JSON.deserialize(response.getBody(),ApiResponse.class);
				System.debug('Response Object:'+responseObj);
                if(responseObj != null && responseObj.data != null && responseObj.data.currentCards != null){

                    for(CurrentCard card : responseObj.data.currentCards) {

                        CardWrapper row = new CardWrapper();
						row.id = card.id;
                        row.cardClassification = card.cardDisplayName;
                        row.cardStatus = card.status;
                        row.cardNumber = card.maskedCardNumber;
                        row.isDelinquent = card.isDelinquent;
                        
                        row.delinquentIcon = card.isDelinquent ? 'utility:check' : 'utility:close';
                        
                        if(card.cardNature != null && card.cardNature.equalsIgnoreCase('secured')) {
							row.cardType = 'Cash Collateral';
						}else{
							row.cardType = 'Credit Card';
                        }
						cards.add(row);
                    } //for loop Ends
                } //If Ends
                System.debug('Cards Info:'+cards);
            }

        }catch(Exception ex) {
			System.debug('Exception: ' + ex.getMessage());
			throw new AuraHandledException(ex.getMessage());
        }

        return cards;
    }
    
    public class ApiResponse {
        public Meta meta;
        public DataWrapper data;
    }

    public class Meta {
    }

    public class DataWrapper {
        public List<CurrentCard> currentCards;
    }
    
    public class CurrentCard {
        public String id;
        public String cardSequenceNumber;
        public String expiryDate;
        public String productMappingCode;
        public String cardDisplayName;
        public String maskedCardNumber;
        public String provider;
        public String status;
        public Boolean isDelinquent;
        public String cardNature;
        public Boolean isPrimary;
    }
    
    public class CardWrapper {
        @AuraEnabled
        public String id;

        @AuraEnabled
        public String cardClassification;

        @AuraEnabled
        public String cardStatus;

        @AuraEnabled
        public String cardType;

        @AuraEnabled
        public String cardNumber;

        @AuraEnabled
        public Boolean isDelinquent;
        
        @AuraEnabled public String delinquentIcon;
    	@AuraEnabled public String delinquentVariant;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> loadCardDetailsToFetchLimit(String accID,String requestedPCINumber){
        Map<String,Object> creditCardDetail = new Map<String,Object>();
        Map<String,Object> creditCardDetailData = new Map<String,Object>();
        Decimal creditLimit;
        System.debug('accID'+accID);
       
        List<System_Action__c> lstSA = new List<System_Action__c>();
        Account accObj = [SELECT Id, CIF__pc,PersonEmail, Region_Flag__c,x_canary__pc FROM Account WHERE Id=: accID];
        
        String regionName = accObj.Region_Flag__c;
        
         
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
        if (response.getStatusCode() == 200)
        {
           System.debug('Credit Card Detail Response:'+response.getBody());
            creditCardDetail = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); //meta, data
            creditCardDetailData = (Map<String, Object>)creditCardDetail.get('data');
            System.debug('Credit Card Detail Data:'+creditCardDetailData);
            
        }
       return creditCardDetailData;
    }
    
    @AuraEnabled
    public static List<FixedDepositWrapper> getFixedDeposits(String accID) {
        
        List<FixedDepositWrapper> deposits = new List<FixedDepositWrapper>();
        
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id = :accID];
        
        try {
            
            HttpRequest request = new HttpRequest();
            
            request = con.createRequest('GET','/api/v1/term-deposit',accObj.Region_Flag__c);
            
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('data');
                
                List<Object> termDeposits = (List<Object>)dataMap.get('termDeposits');
                
                for(Object obj : termDeposits){
                    
                    Map<String,Object> deposit = (Map<String,Object>)obj;
                    
                    FixedDepositWrapper row = new FixedDepositWrapper();
                    
                    row.id = String.valueOf(deposit.get('urbisContractId'));
                    
                    row.name = String.valueOf(deposit.get('name'));
                    
                    // Currency Node
                    Map<String,Object> currencyMap = (Map<String,Object>)deposit.get('currency');
                    
                    if(currencyMap != null){
                        row.currencyCode = String.valueOf(currencyMap.get('code'));
                    }
                    
                    row.depositAmount = Decimal.valueOf(String.valueOf(deposit.get('depositAmount')));
                    
                    row.maturityAmount = Decimal.valueOf(String.valueOf(deposit.get('matruityAmount')));
                    
                    row.status = String.valueOf(deposit.get('progressCode'));
                    
                    deposits.add(row);
                } //for loop Ends
                System.debug('Fixed Deposits List:'+deposits);
            }
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        return deposits;
    }
    
    public class FixedDepositWrapper {
        
        @AuraEnabled
        public String id;
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public String currencyCode;
        
        @AuraEnabled
        public Decimal depositAmount;
        
        @AuraEnabled
        public Decimal maturityAmount;
        
        @AuraEnabled
        public String status;
    }
    
     @AuraEnabled
    public static List<SavingPotWrapper> getSavingPots(String accID) {
        
        List<SavingPotWrapper> pots = new List<SavingPotWrapper>();
        
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id = :accID];
        
        try {
            
            HttpRequest request = new HttpRequest();
            
            request = con.createRequest('GET','/api/v1/pots',accObj.Region_Flag__c);
            
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('data');
                
                List<Object> savingPots = (List<Object>)dataMap.get('pots');
                
                for(Object obj : savingPots){
                    
                    Map<String,Object> pot = (Map<String,Object>)obj;
                    
                    SavingPotWrapper row = new SavingPotWrapper();
                    
                    row.id = String.valueOf(pot.get('potId'));
                    
                    row.name = String.valueOf(pot.get('name'));
                    
                    // Available Balance Node
                    Map<String,Object> availableBalanceMap = (Map<String,Object>)pot.get('account');
                    if(availableBalanceMap != null){
                        row.availableBalance = Decimal.valueOf(String.valueOf(availableBalanceMap.get('availableBalance')));
                    }
                    
                    //Available Currency Node
                     Map<String,Object> currencyMap = (Map<String,Object>)availableBalanceMap.get('currency');
                    if(currencyMap != null){
                        row.currencyCode = String.valueOf(currencyMap.get('code'));
                    }
                    
                    pots.add(row);
                } //for loop Ends
                System.debug('Saving Pots List:'+pots);
            }
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        return pots;
    }
    
    public class SavingPotWrapper {
        
        @AuraEnabled
        public String id;
        
        @AuraEnabled
        public String name;
        
        @AuraEnabled
        public String currencyCode;
        
        @AuraEnabled
        public Decimal availableBalance;
        
       
    }
    
    @AuraEnabled
    public static List<DebitWrapper> getCurrentDebitCards(String accID) {
        
        List<DebitWrapper> debitCardList = new List<DebitWrapper>();
        
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id = :accID];
        
        try {
            
            HttpRequest request = new HttpRequest();
            
            request = con.createRequest('GET','/api/v1/cards',accObj.Region_Flag__c);
            
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('data');
                
                List<Object> debitCard = (List<Object>)dataMap.get('cards');
                
                for(Object obj : debitCard){
                    
                    Map<String,Object> cards = (Map<String,Object>)obj;
                    
                    DebitWrapper row = new DebitWrapper();
                    
                    row.productName = String.valueOf(cards.get('productType'));
                    
                    row.cardNumber = String.valueOf(cards.get('maskedCardNumber'));
                    
                   
                    
                    row.status = String.valueOf(cards.get('status'));
                    row.cardType = String.valueOf(cards.get('cardType'));
                    
                    debitCardList.add(row);
                } //for loop Ends
                System.debug('Debit Card List:'+debitCardList);
            }
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        return debitCardList;
    }
    
    public class DebitWrapper {
        
        @AuraEnabled
        public String productName;
        
        @AuraEnabled
        public String status;
        
        @AuraEnabled
        public String cardNumber;
        
        @AuraEnabled
        public String cardType;
        
       
    }
    
     @AuraEnabled
    public static List<BankAccountWrapper> getForeignAccounts(String accID) {
        
        List<BankAccountWrapper> foreignAcctsList = new List<BankAccountWrapper>();
        
        Account accObj = [SELECT Id,CIF__pc,PersonEmail,Region_Flag__c,x_canary__pc FROM Account WHERE Id = :accID];
        
        try {
            
            HttpRequest request = new HttpRequest();
            
            request = con.createRequest('GET','/api/v1/accounts',accObj.Region_Flag__c);
            
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
            
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
            
            Http http = new Http();
            HttpResponse response = http.send(request);
            
            if(response.getStatusCode() == 200){
                
                Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> dataMap = (Map<String,Object>)responseMap.get('data');
                
                List<Object> foreignAccts = (List<Object>)dataMap.get('accounts');
                
                for(Object obj : foreignAccts){
                    
                    Map<String,Object> foreignAcct = (Map<String,Object>)obj;
                    BankAccountWrapper row = new BankAccountWrapper();
                    
                    //Available Account Node
                    Map<String,Object> availableBalanceAccts = (Map<String,Object>)foreignAcct.get('account');
                    String checkStatus =  String.valueOf(availableBalanceAccts.get('status'));
                  
                    //Available Currency Node
                    Map<String,Object> currencyMap = (Map<String,Object>)availableBalanceAccts.get('currency');
                    String checkCurrencyCode = String.valueOf(currencyMap.get('code'));
                    
                    if(checkCurrencyCode != null && checkCurrencyCode != 'BHD' && checkStatus == 'Active'){
                        row.aliasName = String.valueOf(foreignAcct.get('alias'));
                        row.accNumber = String.valueOf(availableBalanceAccts.get('number'));
                        row.availableBalance = Decimal.valueOf(String.valueOf(availableBalanceAccts.get('availableBalance')));
                        row.currencyCode = checkCurrencyCode;
                        foreignAcctsList.add(row);
                    }
                    
                } //for loop Ends
                System.debug('Foreign Accounts List:'+foreignAcctsList);
            }
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        
        return foreignAcctsList;
    }
    
     public class BankAccountWrapper {
        
        @AuraEnabled
        public String accNumber;
        
        @AuraEnabled
        public String aliasName;
        
        @AuraEnabled
        public String currencyCode;
        
        @AuraEnabled
        public Decimal availableBalance;
        
     }
    

}