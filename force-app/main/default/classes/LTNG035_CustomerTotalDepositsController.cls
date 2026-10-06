/**
 *  @author: Imane Tsioucha
 *  @date: 2024-02-13  
 *  @description:
 *      controller for aura component "LTNG035_DisplayCustomerTotalDepositsController"
 *     		#CH01# #Ranjith Raja# #29/07/2024# add x-canary header
 *      
 */
public with sharing class LTNG035_CustomerTotalDepositsController {

    @AuraEnabled 
    public static CustomerDepositResponse CustomerDepositDetailsViaApi(Id AccountId){
        CustomerDepositResponse depositResponse = new CustomerDepositResponse();
        Account acc = [Select id, CIF__pc, Subscription_Model__pc, Region_Flag__c, x_canary__pc from Account where Id =: AccountId limit 1]; //CH01

        String regionName = acc.Region_Flag__c;
        String caseModel = acc.Subscription_Model__pc;
        String regionType; 
        if(caseModel == 'alburaq'){
            regionName += '_alburaq';
           
        }
        System.debug('caseModel!! '+caseModel);
      
        ApiConnection con = new ApiConnection();
        HttpRequest request = con.createRequest('GET', '/api/v1/customer-products/total-balance', regionName); 
        
        //CH01 Start
        if(acc.x_canary__pc != null) {
            request.setHeader('x-canary',acc.x_canary__pc);
        }
        //CH01 End
        
        HttpResponse response = SM001_ApiCalls.CustomerTotalBalanceAPI(request, acc);
        System.debug('response  >>> '+response);
         
        if (response.getStatusCode() != 200) {
            depositResponse.status = false;
        } else {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            Map<String, Object> m1 = (Map<String, Object>)m.get('data');
             System.debug('depositResponse m1 >>> '+m1);
            depositResponse.status = true;
            depositResponse.total_balance = (Decimal)m1.get('total_balance');
            depositResponse.currancy = (String)m1.get('currency');
              if(caseModel == 'alburaq'){
                  depositResponse.titleValue =  'alburaq ';
           
              }
            else{
                  depositResponse.titleValue =  'ila ';
              }
            
          
                      
        }

        System.debug('depositResponse >>> '+depositResponse);     
        if(caseModel == 'both'){
           
            String regionNameSecond = acc.Region_Flag__c;
            regionNameSecond += '_alburaq';
            HttpRequest requestSecond = con.createRequest('GET', '/api/v1/customer-products/total-balance', regionNameSecond);
            
            //CH01 Start
            if(acc.x_canary__pc != null) {
                requestSecond.setHeader('x-canary',acc.x_canary__pc);
            }
            //CH01 End
            
            HttpResponse responseSecond = SM001_ApiCalls.CustomerTotalBalanceAPI(requestSecond, acc);

            System.debug('responseSecond  >>> '+responseSecond);
            if (responseSecond.getStatusCode() == 200) {
                Map<String, Object> mSecond = (Map<String, Object>)JSON.deserializeUntyped(responseSecond.getBody());
                Map<String, Object> m1Second = (Map<String, Object>)mSecond.get('data');
                depositResponse.secondTitleValue =  'alburaq ';
                depositResponse.statusBoth = true;
                depositResponse.total_balanceBoth = (Decimal)m1Second.get('total_balance');
                depositResponse.currancyBoth = (String)m1Second.get('currency');
                
                System.debug('depositResponse m1Second >>> '+m1Second +' >> '+depositResponse.total_balanceBoth  );
            }
            else{
                  depositResponse.statusBoth=false;
				}
     
        }
          depositResponse.model = caseModel;
        return depositResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static Boolean getButtonAccess() {
        Button_Access_Setting__c setting = Button_Access_Setting__c.getInstance();
        return setting != null && setting.Show_Eligible_Products_Button__c;
    }

    public class CustomerDepositResponse {     
        @AuraEnabled 
        public Boolean status {get; set;}
       @AuraEnabled 
        public Boolean statusBoth {get; set;}
        @AuraEnabled 
        public Decimal total_balance {get; set;}

        @AuraEnabled 
        public String currancy {get; set;}
 
       @AuraEnabled 
        public String model {get; set;}
        @AuraEnabled 
        public Decimal total_balanceBoth  {get; set;}

        @AuraEnabled 
        public String currancyBoth  {get; set;}
        
       @AuraEnabled 
        public String titleValue  {get; set;}
        
        
       @AuraEnabled 
        public String secondTitleValue  {get; set;}
        
    }
}