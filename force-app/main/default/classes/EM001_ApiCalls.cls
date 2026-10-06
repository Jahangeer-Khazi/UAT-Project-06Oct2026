/**
 * @author ANISS MBARKI
 * @date Création 15/12/2021
 * @date Modification 
 * @description EM001_ApiCalls - Apex class (part of the Mocking Framework) Purpose : Reroute to the correct class Using Stub Concept  
 * @history Modifications : 
 *       #CH01 : Swapna add creditCardStatementApi method
 *       #CH02 : Aniss Mbarki add AccountStatementsApi method
 *       #CH03 : Wissal benqezza add Account Closure Api calls
 *       #CH04 : Swapna added getCreditCardStatusApi and getCreditCardDetailsApi method
 *       #CH05 : Wissal benqezza added updateCreditCardRequestStatusApi call
 *       #CH06 : Wissal benqezza add blockUnblockAccountApi & getAccountsListAllApi
 *       #CH07 : Wissal benqezza  UpdateAccountForInterestRate
 *       #CH08 : Aniss Mbarki add scheduled PLA payments API
 *       #CH12 : Amina BENABDELKRIM add callValidateAccountTerminationApi method.
 *       #CH13 : Wissal benqezza add callUpdateFeeWaiverFlagReasonApi and callUncollectedFeesApi. Date 24/10/2022
 *       #CH14 : Wissal benqezza add PeriodicReviewBlockProductsApi,PeriodicReviewUnblockProductsApi . Date 21/11/2022
 *       #CH15 : Wissal benqezza add BenefitPayAPIUpdate . Date 07/02/2023
 *       #CH16 : Elmustapha ELGARNI add updateCustomerDetailsAPI . Date 18/10/2023
 *       #CH18 : Imane Tsioucha add ManualOnboardingAPI // Date 15/11/2023
 *       #CH19 : Imane Tsioucha add CustomerTotalBalanceAPI . Date 13/02/2024
 *       #CH20 : Imane Tsioucha add MoEngageDeleteAPI . Date 17/05/2024
 *       #CH21 : Jayanth Manickam add BondSukukStatementAPI . Date 24/09/2024
 */
public with sharing class EM001_ApiCalls implements  ITF001_ApiCalls {

    // WS STUB
   private static ITF001_ApiCalls stub {
       get {
           return callApi_STUB();
       }
   }

   // Private variable_Getter method
   private static ITF001_ApiCalls callApi_STUB(){
       ITF001_ApiCalls STUB;
       
       if (Test.isRunningTest()) {
           STUB = new MCK001_ApiCalls(); 
       } else {
           STUB = new DM001_ApiCalls();
       }

       return STUB;
   }

   // ****************  Api calls **********************************
   public static HttpResponse getComplianceCaseStatusApi(HttpRequest request, Integer statusCode){ 
       HttpResponse response = stub.getComplianceCaseStatusApi(request, statusCode);
       return response;
   }


   public static HttpResponse callNameScreeningApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callNameScreeningApi(request, statusCode);
       return response;  
   }


   public static HttpResponse callApiToCreateSupplementaryCardInVPlus(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callApiToCreateSupplementaryCardInVPlus(request, statusCode);
       return response;     
   }

   public static HttpResponse callBlockAmountApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callBlockAmountApi(request, statusCode);
       return response;     
   }

   public static HttpResponse callUnblockAmountApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callUnblockAmountApi(request, statusCode);
       return response;     
   }

   //CH01 -Begin
   public static ApiConnection.Response callCreditCardStatementApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callCreditCardStatementApi(con, request, statusCode);
       return response;     
   }
   public static ApiConnection.Response callCreditCardStatementDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callCreditCardStatementDetailsApi(con, request, statusCode);
       return response;     
   }
   //CH01 -End

   //CH02 -Begin
   public static ApiConnection.Response callAccountStatementsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callAccountStatementsApi(con, request, statusCode);
       return response;     
   }
   public static ApiConnection.Response callAccountStatementsDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callAccountStatementsDetailsApi(con, request, statusCode);
       return response;     
   }
   //CH02 -End

   //CH03 -Begin
   public static HttpResponse callAccountListApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callAccountListApi(request, statusCode);
       return response;     
   }
   public static HttpResponse callValidateAccountClosureApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callValidateAccountClosureApi(request, statusCode);
       return response;     
   }
   public static HttpResponse callCloseAccountApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.callCloseAccountApi(request, statusCode);
       return response;     
   }
   //CH03 -End

   //CH04 -Swapna -Begin
   public static ApiConnection.Response getCreditCardStatusApi(ApiConnection con,HttpRequest request, Integer statusCode){ 
       ApiConnection.Response response = stub.getCreditCardStatusApi(con,request, statusCode);
       return response;
   }
   
    public static ApiConnection.Response getCreditCardDetailsApi(ApiConnection con,HttpRequest request, Integer statusCode){ 
       ApiConnection.Response response = stub.getCreditCardDetailsApi(con,request, statusCode);
       return response;
   }
   //CH04 -Swapna -End

    //CH05 -Begin
    public static HttpResponse updateCreditCardRequestStatusApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.updateCreditCardRequestStatusApi(request, statusCode);
        return response;
    }
    //CH05 -End
    
    public static HttpResponse updatePrepaidSupplementaryCreditCardApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.updatePrepaidSupplementaryCreditCardApi(request, statusCode);
        return response;
    }

    //CH06 -Begin
    public static HttpResponse blockUnblockAccountApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.blockUnblockAccountApi(request, statusCode);
        return response;
    }
    public static HttpResponse getAccountsListAllApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getAccountsListAllApi(request, statusCode);
        return response;
    }
    public static HttpResponse getAccountHoldTransactionsApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.getAccountHoldTransactionsApi(request, statusCode);
        return response;
    }
    //CH06 -End

    //CH07 -Begin
    public static HttpResponse UpdateAccountForInterestRate(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.UpdateAccountForInterestRate(request, statusCode);
        return response;
    }
    //CH07 -End

    //CH08 -Begin
    public static ApiConnection.Response callScheduledPlaPaymentsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = stub.callScheduledPlaPaymentsApi(con, request, statusCode);
        return response;     
    }
    public static ApiConnection.Response callScheduledPlaPaymentDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
        ApiConnection.Response response = stub.callScheduledPlaPaymentDetailsApi(con, request, statusCode);
        return response;     
    }
    //CH08 -End
   
   //CH12 -Begin
   public static HttpResponse callValidateAccountTerminationApi(HttpRequest request, Integer statusCode){
      HttpResponse response = stub.callValidateAccountTerminationApi(request, statusCode);
      return response;     
   }
   //CH12 -End
   
    //CH13 -Begin
    public static HttpResponse callUpdateFeeWaiverFlagReasonApi(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.callUpdateFeeWaiverFlagReasonApi(request, statusCode);
        return response;
    }
    public static ApiConnection.Response callUncollectedFeesApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callUncollectedFeesApi(con,request,statusCode);
        return response;
    }
    //CH13 -End
     //CH14 -Start
    public static HttpResponse PeriodicReviewBlockProductsApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.PeriodicReviewBlockProductsApi(request, statusCode);
        return response;
    }
    public static HttpResponse PeriodicReviewUnblockProductsApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.PeriodicReviewUnblockProductsApi(request, statusCode);
        return response;
    }
    //CH14 -End
    //CH15 -Start
    public static HttpResponse BenefitPayAPIUpdateApi(HttpRequest request, Integer statusCode){
       HttpResponse response = stub.BenefitPayAPIUpdateApi(request, statusCode);
        return response;
    }
    //CH15 -End
    
   //CH16 -Start
   public static HttpResponse updateCustomerDetailsAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.updateCustomerDetailsAPI(request, statusCode);
        return response;
        }
    //CH16 -End
    
    //CH17 -Start
    public static HttpResponse ManualOnboardingAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.ManualOnboardingAPI(request, statusCode);
         return response;
     }
     //CH17 -End
   
     //CH19 -Start
    public static HttpResponse CustomerTotalBalanceAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.CustomerTotalBalanceAPI(request, statusCode);
         return response;
     }
     //CH19 -End

      //CH20 -Start
    public static HttpResponse MoEngageDeleteAPI(HttpRequest request, Integer statusCode){
        HttpResponse response = stub.MoEngageDeleteAPI(request, statusCode);
         return response;
     }
     //CH20 -End
     //
     
       //CH21 -Begin
   public static ApiConnection.Response callBondSukukStatementsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callBondSukukStatementsApi(con, request, statusCode);
       return response;     
   }
   public static ApiConnection.Response callBondSukukStatementsDetailsApi(ApiConnection con ,HttpRequest request, Integer statusCode){
       ApiConnection.Response response = stub.callBondSukukStatementsDetailsApi(con, request, statusCode);
       return response;     
   }
    //CH21 -End
}