/**
 * @author ANISS MBARKI
 * @date Création 15/12/2021
 * @date Modification 
 * @description DM001_ApiCalls - Apex class (part of the Mocking Framework) that contains the real call to apis
 * @history Modifications : 
 *       #CH01 : Swapna add creditCardStatementApi method
 *       #CH02 : Aniss Mbarki add AccountStatementsApi method
 *       #CH03 : Wissal benqezza add Account Closure Api calls
 *       #CH04 : Swapna added getCreditCardStatusApi and getCreditCardDetailsApi method.
 *       #CH05 : Wissal benqezza added updateCreditCardRequestStatusApi call
 *       #CH06 : Wissal benqezza add blockUnblockAccountApi & getAccountsListAllApi & getAccountHoldTransactionsApi
 *       #CH07 : Wissal benqezza add  UpdateAccountForInterestRate
 *       #CH08 : Aniss Mbarki add scheduled PLA payments API
 *       #CH12 : Amina BENABDELKRIM add callValidateAccountTerminationApi method.
 *       #CH13 : Wissal benqezza add callUpdateFeeWaiverFlagReasonApi and callUncollectedFeesApi. Date 24/10/2022
 *      #CH14 : Wissal benqezza add PeriodicReviewBlockProductsApi and PeriodicReviewUnblockProductsApi. Date 21/11/2022
 *      #CH15 : Wissal benqezza add BenefitPayAPIUpdateApi . Date 07/02/2023
 *      #CH16 : Elmustapha ELGARNI add updateCustomerDetailsAPI . Date 18/10/2023
 *      #CH17 : Imane Tsioucha add ManualOnboardingAPI . Date 15/11/2023
 *      #CH18 : Imane Tsioucha add CustomerTotalBalanceAPI . Date 13/02/2024
*       #CH20 : Imane Tsioucha add MoEngageDeleteAPI . Date 17/05/2024
 *      #CH21 : Ranjith Raja add Prepaid/Supplementary Credit Card API . Date 24/12/2025
 */
public with sharing class DM001_ApiCalls implements ITF001_ApiCalls {

    public static HttpResponse getComplianceCaseStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;  
    }


    public static HttpResponse callNameScreeningApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }


    public static HttpResponse callApiToCreateSupplementaryCardInVPlus(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }
    
    public static HttpResponse callBlockAmountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    public static HttpResponse callUnblockAmountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request); 
        return response ;
    }

    //CH01 -Begin
    public static ApiConnection.Response callCreditCardStatementApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        PAD.debugLogBegin('DM001_ApiCalls', 'callCreditCardStatementApi', '');
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    public static ApiConnection.Response callCreditCardStatementDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    //CH01 -End

    //CH02 -Begin
    public static ApiConnection.Response callAccountStatementsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        PAD.debugLogBegin('DM001_ApiCalls', 'callAccountStatementsApi', '');
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    public static ApiConnection.Response callAccountStatementsDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    //CH02 -End

    //CH03 -Begin
    public static HttpResponse callAccountListApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    public static HttpResponse callValidateAccountClosureApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    public static HttpResponse callCloseAccountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    //CH03 -End
    //CH04 -Swapna -Start
     public static ApiConnection.Response getCreditCardStatusApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
     public static ApiConnection.Response getCreditCardDetailsApi(ApiConnection con,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request); 
        return response ;  
    }
    //CH04 - Swapna -End

    //CH05 -Begin
    public static HttpResponse updateCreditCardRequestStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    //CH05 -End
    
    //CH21 -Begin
    public static HttpResponse updatePrepaidSupplementaryCreditCardApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    //CH21 -End

    //CH06 -Begin
    public static HttpResponse blockUnblockAccountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    public static HttpResponse getAccountsListAllApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    public static HttpResponse getAccountHoldTransactionsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    //CH06 -End

    //CH07 -Begin
    public static HttpResponse UpdateAccountForInterestRate(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    //CH07 -End

    //CH08 -Begin
    public static ApiConnection.Response callScheduledPlaPaymentsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        PAD.debugLogBegin('DM001_ApiCalls', 'callScheduledPlaPaymentsApi', '');
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    public static ApiConnection.Response callScheduledPlaPaymentDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    //CH08 -End

    //CH12 -Begin
    public static HttpResponse callValidateAccountTerminationApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
    //CH12 -End
    //CH13 -Begin
    public static HttpResponse callUpdateFeeWaiverFlagReasonApi(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
        return response;     
    }
        public static ApiConnection.Response callUncollectedFeesApi(ApiConnection con,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response;     
    }
    //CH13 -End
     //CH14 -Start
       public static HttpResponse PeriodicReviewBlockProductsApi(HttpRequest request, Integer statusCode){
         HttpResponse response = new Http().send(request);
        return response;   
    }
     public static HttpResponse PeriodicReviewUnblockProductsApi(HttpRequest request, Integer statusCode){
         HttpResponse response = new Http().send(request);
        return response;   
    }
    //CH14 -End
    //CH15 -Start
       public static HttpResponse BenefitPayAPIUpdateApi(HttpRequest request, Integer statusCode){
         HttpResponse response = new Http().send(request);
        return response;   
    }
    //CH15 -End

    //CH16 -Start
    public static HttpResponse updateCustomerDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
       return response;   
   }
   //CH16 -End
   //CH17 -Start
    public static HttpResponse ManualOnboardingAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
       return response;   
   }
   //CH17 -End

    //CH18 -Start
      public static HttpResponse CustomerTotalBalanceAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = new Http().send(request);
       return response;   
    }
    //CH18 -End

    //CH20 -Start
   public static HttpResponse MoEngageDeleteAPI(HttpRequest request, Integer statusCode){
    HttpResponse response = new Http().send(request);
   return response;   
}
   //CH20 -End
//CH02 -Begin
    public static ApiConnection.Response callBondSukukStatementsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        PAD.debugLogBegin('DM001_ApiCalls', 'callAccountStatementsApi', '');
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    public static ApiConnection.Response callBondSukukStatementsDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = con.makeCallout(request);
        return response ;
    }
    //CH02 -End
}