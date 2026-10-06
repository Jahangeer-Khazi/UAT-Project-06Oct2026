/**
 * @author Jayanth
 * @date Création 07/03/2024
 * @date Modification 
 * @description MCK04_Bonds_SukukServiceApiCalls - Apex class (part of the Mocking Framework) that contains the mock call for raffle requirment
 * @history Modifications :
 *               
 */
@isTest
public class MCK04_Bonds_SukukServiceApiCalls implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest request) {

            // Create a fake response
 System.debug('===========respond========');
        
        String endPoint = request.getEndpoint();
        System.debug('endPoint##'+endPoint);
        String method = request.getMethod();
        if( endPoint != null && endPoint.contains('api/v1/bond/instrument/investments?instrumentId=20') && method != null && method.contains('GET')){
            return GetMinInstrumentInvestmentAPI(request);
        }else if( endPoint != null && endPoint.contains('api/v1/bond/instrument/investments?instrumentId=26') && method != null && method.contains('GET')){
            return GetCancelledInstrumentInvestmentAPI(request);
        }else if( endPoint != null && endPoint.contains('api/v1/bond/instrument/investments?instrumentId=25') && method != null && method.contains('GET')){
            return GetValidInstrumentInvestmentAPI(request);
        }else if ( endPoint != null && endPoint.contains('/api/v1/bond/instrument/investments') && method != null && method.contains('GET') ){
            return GetInstrumentInvestmentAPI(request);
        }else if ( endPoint != null && endPoint.contains('/api/v1/bond/instruments') && method != null && method.contains('GET') ){
            return GetInstrumentAPI(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/bond/configurations') && method != null && method.contains('GET') ){
            return GetBondConfigurationAPI(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/bond/investments/allocation') && method != null && method.contains('POST') ){
            return PostInvestmentAllocationAPI(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/bond/investments/distribute') && method != null && method.contains('POST') ){
            return PostInvestmentDistributionAPI(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/bond/investments/distribute') && method != null && method.contains('GET') ){
            return GetInvestmentDistributionAPI(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/bond/investments/d') && method != null && method.contains('GET') ){
            return GetInvestmentDetailsBuyAPI(request);
        }else if( endPoint != null && endPoint.contains('/api/v1/bond/investments') && method != null && method.contains('GET') ){
            return GetInvestmentDetailsSellAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/accounts') && method != null && method.contains('GET')){
            return GetAccountListAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/accounts/details') && method != null && method.contains('POST')){
            return GetAccountDetailsAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/bond/simulate') && method != null && method.contains('POST')){
            return GetCalculateBondSimulateAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/bond') && method != null && method.contains('POST')){
            return HoldBidAmountAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/bond/investments/') && method != null && method.contains('DELETE')){
            return ReleaseBidHoldAmountAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/bond/sell') && method != null && method.contains('PUT')){
            return ProcessSellRequestAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/bond/distribute/') && method != null && method.contains('GET')){
            return GetInvestmentDistributionDetailsAPI(request);
        }else if(endPoint != null && endPoint.contains('/api/v1/bond/instrument/historical-rates?subType=123456') && method != null && method.contains('GET')){
            return GetHistoryRateDetailsAPI(request);
        }else{
            System.debug('##endPoint'+endPoint);
            return GetCalculateBondSimulateAPI(request);
           // return GetInstrumentAPI(request);
        }
    }
  
       public HTTPResponse GetInstrumentAPI(HTTPRequest request) {
            String body = '{"meta":{"code":"bond-1000","message":"Resultsfetchedsuccessfully."},"data":{"instruments":[{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"12-01-2024","tenderDateCBB":"12-01-2024","issueDateCBB":"12-01-2024","maturityDateCBB":"12-01-2024","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"12-01-2024","minimumOrderAmount":5,"maximumOrderAmount":1000000000,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}]}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
        public HTTPResponse GetInvestmentDetailsBuyAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investment":{"id":"d","CrmRefrence":"","status":"","funding_account_iban":"","bid_creation_date":"12-01-2024","bidAmount":33.421,"bidAmountVat":33.421,"bidAmountFee":33.421,"bid_allocation_date":"12-01-2024","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"12-01-2024","selling_price":33,"selling_date":"12-01-2024","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"12-01-2024","tenderDateCBB":"12-01-2024","issueDateCBB":"12-01-2024","maturityDateCBB":"12-01-2024","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"12-01-2024","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","status":"Active","allowActions":["cancel"]}}}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetInvestmentDetailsSellAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"d","CrmRefrence":"","status":"Active","funding_account_iban":"","bid_creation_date":"12-01-2024","bidAmount":33.421,"bidAmountVat":33.421,"bidAmountFee":33.421,"bid_allocation_date":"12-01-2024","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"12-01-2024","selling_price":33,"selling_date":"12-01-2024","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"12-01-2024","tenderDateCBB":"12-01-2024","issueDateCBB":"12-01-2024","maturityDateCBB":"12-01-2024","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"12-01-2024","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","status":"Active","allowActions":["cancel"]}}]}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetAccountListAPI(HTTPRequest request) {
            String body = '{"meta":{"code":"ACCO-1000","message":"Accountslistforcustomerhasbeenretrievedsuccessfully."},"data":{"allowAccountCreation":true,"accounts":[{"id":"BH97ABCO86100019101101","customerId":"8610001","alias":"NeoBANKSavingAccount1","productType":"account","productName":"NeoBANKSavingAccount1","category1":"","category2":"","detailsExist":true,"account":{"number":"861000191011","currency":{"code":"BHD","decimalPlaces":"2"},"iban":"BH97ABCO86100019101101","availableBalance":586828,"ledgerBalance":10090344,"startDate":"2019-02-08","endDate":"2019-02-10","overdraftLimit":0,"overdraftExpiryDate":"2019-05-03","overdraftAvailableLimit":0,"paymentsAllowed":true,"creditInterestFrequencyCode":"200001","creditInterestFrequency":"MONTHLY","debitInterestFrequencyCode":"200001","debitInterestFrequency":"MONTHLY","creditGlAccount":"2011204","creditGlAccountDescription":"LIABCURRENTACCT-REGULAR","debitGlAccount":"2011204","debitGlAccountDescription":"LIABCURRENTACCT-REGULAR","minimumBalance":0,"maximumBalance":0,"valueBalance":10090344,"holdAmount":9503516,"overdraftReviewDate":"1957-01-01","defaultAccount":true},"minimumBalance":{"threshold":20.0,"fee":1.0,"averageBalance":17.0,"feeWaiver":false,"feeWaiverReason":"Salarybelow250"}},{"id":"BH32ABCO86100019101301","customerId":"8610001","alias":"NeoBANKCurrentAccount1","productType":"account","productName":"NeoBANKCurrentAccount1","category1":"","category2":"","detailsExist":true,"account":{"number":"861000191013","currency":{"code":"BHD","decimalPlaces":"2"},"iban":"BH32ABCO86100019101301","availableBalance":179911,"ledgerBalance":179911,"startDate":"2019-02-08","endDate":"2019-02-10","overdraftLimit":0,"overdraftExpiryDate":"2019-05-03","overdraftAvailableLimit":0,"paymentsAllowed":true,"creditInterestFrequencyCode":"200001","creditInterestFrequency":"MONTHLY","debitInterestFrequencyCode":"200001","debitInterestFrequency":"MONTHLY","creditGlAccount":"2011204","creditGlAccountDescription":"LIABCURRENTACCT-REGULAR","debitGlAccount":"2011204","debitGlAccountDescription":"LIABCURRENTACCT-REGULAR","minimumBalance":0,"maximumBalance":0,"valueBalance":179911,"holdAmount":0,"overdraftReviewDate":"1957-01-01","defaultAccount":false,"minimumBalanceThreshold":20.0,"minimumBalanceFee":1.0,"averageBalance":17.0,"minimumBalanceFeeWaiver":false,"minimumBalanceFeeWaiverReason":"Salarybelow250"}}]}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetAccountDetailsAPI(HTTPRequest request) {
            String body = '{"meta":{"code":"ACCO-1001","message":"AccountDetailsforgivenaccounthasbeenretrievedsuccessfully."},"data":{"customerId":"989248099","id":"BH09ABCO00929029882","alias":"WifeAccount","productType":"Account","productName":"SavingAccount","category1":"","category2":"","transferByMobile":true,"account":{"number":"100001009280","branch":"","currency":{"code":"BHD","description":"BahrainiDinar","decimalPlaces":3},"iban":"BH09ABCO00929029882","availableBalance":100.000,"ledgerBalance":150.000,"startDate":"2018-01-09","endDate":"2018-02-09","status":"Active","overdraftLimit":100000.000,"overdraftExpiryDate":"2020-12-31","overdraftAvailableLimit":1000000.000,"paymentsAllowed":true,"swiftCode":"ABCOBHBMXXX","earnInterest":true,"creditTotalInterest":0.0,"debitTotalInterest":0.0,"allowInterestConditionUpdate":true,"interestRateInformation":{"currentEarnInterest":true,"requestedEarnInterest":false,"processingStatus":"PENDING","effectiveDate":"2021-07-30","modifiedDate":"2021-06-28"},"interestConditions":[{"rateType":"TIERED_INTEREST_RATE","rankOrder":1,"currency":{"code":"BHD","description":"BahrainiDinar","decimalPlaces":3},"tier":"BHD0-1,000","tier_start":0.000,"tier_end":1000.0,"rate":0.014,"applicable_balance":1000.0,"active":true,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":2,"currency":{"code":"BHD","description":"BahrainiDinar","decimalPlaces":3},"tier":"BHD1,000-5,000","tier_start":1000.000,"tier_end":5000.000,"rate":0.0155,"applicable_balance":1000.0,"active":true,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":3,"currency":{"code":"BHD","description":"BahrainiDinar","decimalPlaces":3},"tier":"BHD5,000-10,000","tier_start":5000.000,"tier_end":10000.000,"rate":0.0175,"applicable_balance":1000.0,"active":true,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":4,"currency":{"code":"BHD","description":"BahrainiDinar","decimalPlaces":3},"tier":"BHD10,000-250,000","tier_start":10000.000,"tier_end":250000.000,"rate":0.021,"applicable_balance":1000.0,"active":false,"show_rate":true},{"rateType":"TIERED_INTEREST_RATE","rankOrder":5,"currency":{"code":"BHD","description":"BahrainiDinar","decimalPlaces":3},"tier":"BHD250,000+","tier_start":0.000,"tier_end":1000.0,"rate":0.0145,"applicable_balance":1000.0,"active":false,"show_rate":false}]},"minimumBalance":{"threshold":20.0,"fee":1.0,"averageBalance":17.0,"feeWaiver":false,"feeWaiverReason":"Salarybelow250"}}}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
    Public HTTPResponse HoldBidAmountAPI(HTTPRequest request) {
           String body = '{"meta":{"code":"BOND-1003","message":"Therequestsubmittedsuccessfully."},"data":{"investment":{"id":"d","CrmRefrence":"","status":"","funding_account_iban":"","bid_creation_date":"","bid_amount":33.421,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creation_date":""}}}}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }
    Public HTTPResponse GetCalculateBondSimulateAPI(HTTPRequest request) {
           String body = '{"meta":{"code":"BOND-1000","message":"BidsimulatedSuccessfully."},"data":{"calculatedAmount":{"totalAmount":20011.000,"feeAmount":10.000,"vatamount":1.000,"bidAmount":20000.000}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }
    Public HTTPResponse ReleaseBidHoldAmountAPI(HTTPRequest request) {
           String body = '{"meta":{"code":"BOND-1003","message":"Therequestcanceledsuccessfully."},"data":{"investment":{"id":"3845","customerId":"5564516","status":"Pending_sold","fundingAccountIban":"BH12ABCO55645169101001","bidCreationDate":"23-04-202409:44:57","bidAmount":50000.00000,"bidAmountVat":5.00000,"bidAmountFee":50.00000,"bidAllocationDate":"23-04-202410:02:16","bidAllocationPercentage":"95.00000","bidAllocationAmount":47025.00000,"bidAllocationAmountFee":47.02500,"bidAllocationAmountVat":4.70250,"cbbPercentageOfTotal":27.77800,"yieldRate":9.50000,"maturityAmount":47500.00000,"proceedsCreditedToAccount":"null","creationDate":"23-04-202409:44:57","processingFeesPercentage":0.10000,"processingFeesMinimumAmount":10.00000,"processingFeesVAT":10.00000,"allowActions":[],"instrument":{"id":"269","isInTypeCBB":"12MonthsTreasuryBills","isInCodeCBB":"BH0005637721","issueNoCBB":"2003","issueAmountCBB":100000000.00000,"invitationDateCBB":"28-03-202400:00:00","tenderDateCBB":"01-05-202400:00:00","issueDateCBB":"03-05-202400:00:00","maturityDateCBB":"04-07-202400:00:00","rateCBB":0.00,"issuePrice":99.00000,"period":{"tenure":"1.00","tenure_type":"Year"},"couponDistributionFlag":false,"isInName":"12MonthsTreasuryBills","group":"TREASURY_BILL","securityType":"Conventional","currency":"BHD","bidDueDate":"30-04-202400:00:00","minimumOrderAmount":10000,"minimumNoOfUnits":1,"creation_date":"18-04-202412:12:52","status":"Active","categoryName":"Bills","subType":"12_MONTHS_TREASURY_BILLS"}}}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }
    Public HTTPResponse ProcessSellRequestAPI(HTTPRequest request) {
           String body = '{"meta":{"code":"BOND-1003","message":"Therequestsubmittedsuccessfully."},"data":{"investments":[{"id":"d","CrmRefrence":"","status":"","funding_account_iban":"","bid_creation_date":"","bid_amount":33.421,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creation_date":""}}}]}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }
   Public HTTPResponse PostInvestmentAllocationAPI(HTTPRequest request) {
          // String body = '{"meta":{"code":"BOND-1001","message":"Updatedsuccessfully."},"data":{"investments":{"id":"d","status":"","funding_account_iban":"","bid_creation_date":"","bid_amount":33.421,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creation_date":""}}}}}';
            
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"d","CrmRefrence":"","status":"","funding_account_iban":"","bid_creation_date":"12-01-2024","bidAmount":33.421,"bidAmountVat":33.421,"bidAmountFee":33.421,"bid_allocation_date":"12-01-2024","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"12-01-2024","selling_price":33,"selling_date":"12-01-2024","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"12-01-2024","tenderDateCBB":"12-01-2024","issueDateCBB":"12-01-2024","maturityDateCBB":"12-01-2024","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"12-01-2024","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","status":"Active","allowActions":["cancel"]}}]}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    }    
    Public HTTPResponse PostInvestmentDistributionAPI(HTTPRequest request) {
          // String body = '{"meta":{"code":"BOND-1001","message":"Updatedsuccessfully."},"data":{"investments":{"id":"d","status":"","funding_account_iban":"","bid_creation_date":"","bid_amount":33.421,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isinCodeCBB":"","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creation_date":""}}}}}';
            
            String body = '{"meta":{"code":"BOND-1000","message":"Updatedsuccessfully."},"data":{"distributeDetails":[{"id":"123","investmentId":"54445","ISIN":"CSW/ED4","amount":445.954,"type":"maturity","status":"closed"},{"id":"12433","investmentId":"12345","ISIN":"CSW/ED4","amount":447.954,"type":"maturity","status":"closed"}]}}';
            HTTPResponse res = new HTTPResponse();
         //  if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
    } 
            public HTTPResponse GetInvestmentDistributionAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"distributeDetails":[{"id":"123","instrumentId":"123","investmentId":"54445","ISIN":"CSW/ED4","amount":445.954,"type":"maturity","status":"Closed","proceedsCreditedTo":"ABC001","proceedsCreditedOn":"17-03-202407:33:55","creationDate":"17-03-202407:33:55"},{"id":"12433","instrumentId":"123","investmentId":"12345","ISIN":"CSW/ED4","amount":447.954,"type":"maturity","status":"Closed","proceedsCreditedTo":"ABC002","proceedsCreditedOn":"17-03-202407:33:55","creationDate":"17-03-202407:33:55"}]}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetBondConfigurationAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Configurationhavebeenfetchedsuccessfully."},"data":{"configurations":[{"param":"BANK_MINIMUM_BID_AMOUNT_BONDS","type":"Integer","value":"10000","description":"Maximumnumberofbondallowedpercustomer"},{"param":"QUESTIONNAIRE_ENABLED","type":"String","value":"disabled","description":"Maximumnumberofbondallowedpercustomer"},{"param":"DefaultName","type":"Integer","value":"15","description":"ThedefaultNameofbond"}]}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetInstrumentInvestmentAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"d","CrmRefrence":"","status":"In-Progress","funding_account_iban":"","bid_creation_date":"","bidAmount":500,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isInCodeCBB":"34324","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}}]}}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetMinInstrumentInvestmentAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"2","CrmRefrence":"","status":"In-Progress","funding_account_iban":"","bid_creation_date":"","bidAmount":1000,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isInCodeCBB":"3434","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}}]}}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
     public HTTPResponse GetCancelledInstrumentInvestmentAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"5","CrmRefrence":"","status":"Cancelled","funding_account_iban":"","bid_creation_date":"","bidAmount":11000,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"isinTypeCBB":"","isInCodeCBB":"434","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}}]}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
        public HTTPResponse GetValidInstrumentInvestmentAPI(HTTPRequest request ) {
            String body = '{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"investments":[{"id":"d","CrmRefrence":"","status":"In-Progress","funding_account_iban":"","bid_creation_date":"","bidAmount":22500,"bid_amount_vat":33.421,"bid_amount_fee":33.421,"bid_allocation_date":"","bid_allocation_percentage":"","bid_allocation_amount":333,"bid_allocation_amount_fee":44,"bid_allocation_amount_vat":22,"CBB_percentage_of_total":144,"yield_rate":0.390,"maturity_amount":778,"cancellation_date":"","selling_price":33,"selling_date":"","proceeds_credited_on":"","proceeds_credited_to_account":"","creation_date":"","instrument":{"id":25,"isinTypeCBB":"","isInCodeCBB":"34324","issueNoCBB":"","issueAmountCBB":"","invitationDateCBB":"","tenderDateCBB":"","issueDateCBB":"","maturityDateCBB":"","rateCBB":5.5,"issuePrice":4.99,"period":{"tenure":"","tenure_type":""},"nextCouponDate":"","couponDistributionFlag":true,"couponDistributionFrequency":9,"isinName":"","group":"","securityType":"","currency":"","bidDueDate":"","minimumOrderAmount":5.000,"minimumNoOfUnits":99.987,"processingFeesPercentage":90.987,"processingFeesMinimumAmount":99,"processingFeesVAT":9.009,"creationDate":"","allowActions":["cancel"]}}]}}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        } 
      public HTTPResponse GetInvestmentDistributionDetailsAPI(HTTPRequest request){
             String body ='{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"distributeDetails":[{"creationDate":"2024-08-15T06:58:22.040179","proceedsCreditedOn":"null","amount":23.80952,"investmentId":"20583","id":"2891"},{"creationDate":"2024-08-15T06:58:22.040209","proceedsCreditedOn":"null","amount":23.80952,"investmentId":"20584","id":"2892"},{"creationDate":"2024-08-15T06:58:22.040243","proceedsCreditedOn":"null","amount":23.80952,"investmentId":"20585","id":"2893"}]}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
       public HTTPResponse GetHistoryRateDetailsAPI(HTTPRequest request){
             String body ='{"meta":{"code":"BOND-1000","message":"Resultsfetchedsuccessfully."},"data":{"distributeDetails":[{"creationDate":"2024-08-15T06:58:22.040179","proceedsCreditedOn":"null","amount":23.80952,"investmentId":"20583","id":"2891"},{"creationDate":"2024-08-15T06:58:22.040209","proceedsCreditedOn":"null","amount":23.80952,"investmentId":"20584","id":"2892"},{"creationDate":"2024-08-15T06:58:22.040243","proceedsCreditedOn":"null","amount":23.80952,"investmentId":"20585","id":"2893"}]}}';
            HTTPResponse res = new HTTPResponse();
          // if(statusCodeGlobal != null){ statusCode = statusCodeGlobal; }
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
}