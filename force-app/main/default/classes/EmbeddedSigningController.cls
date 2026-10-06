/*      
 *      Change History: 
 *             #CH05# #Aniss Mbarki# 03-02-2026# Added Logic for Loans - Introducing "Pledge Form" To Secured Loans DocuSign Documents  (NBA-16477)
*/
public without sharing class EmbeddedSigningController {

    private static List<System_Action__c> lstSA = new List<System_Action__c>();

    @AuraEnabled
    public static String sendEnvelope(Id recordId, String channel) {
        String EnvelopeId;
        Id mySourceId = recordId; // The ID of the initiating Salesforce object
        List<Case> caseList = new List<Case>();
        String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
        String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.Name, Account.Subscription_Model__pc FROM Case WHERE Id = :recordId';
        caseList = new List<Case>((List<Case>)Database.query(soqlQuery)); 
        Case cItem = caseList.get(0);
        
        System.debug(' New Case -->'+cItem);
        List<CaseAnnex__c> CaseAnnexs = new List<CaseAnnex__c>();
        String caseAnnexId = cItem.CaseAnnex__c;
        String caseAnnexfields = DM000_sObjectDescriber.constructFieldListForQueryFrom('CaseAnnex__c');   
        String caseAnnexsoqlQuery = 'SELECT ' + caseAnnexfields + ' FROM CaseAnnex__C WHERE Id =:caseAnnexId';
        CaseAnnexs = new List<CaseAnnex__c>((List<CaseAnnex__c>)Database.query(caseAnnexsoqlQuery));
          CaseAnnex__c caseAnnexRecord;
        if(!CaseAnnexs.isEmpty()){
            caseAnnexRecord = CaseAnnexs[0];
        }

        try{
            
    
            System.debug('***============ sendEnvelope Begin ============*********');
            if(cItem.case_Model__c == 'alburaq'){
                EnvelopeId = createEnvelopeForAlburaq(cItem, caseAnnexRecord, channel);
            } else{
                EnvelopeId = createEnvelopeForIla(cItem, caseAnnexRecord, channel);
            }
        }
        catch(Exception e){
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            lstSA.add(SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  cItem.id,cItem.Customer_CIF__c,cItem.accountId,null, 
                                                  'please check : '+'sendEnvelope()', cItem.Type
                                                 ));

            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            if(lstSA != null && lstSA.size()>0){
                insert lstSA;
            }
        }

        return EnvelopeId;

    }

    // ########################### Case model == Ila
    // ###########################
    public static String createEnvelopeForIla(Case cItem, CaseAnnex__c caseAnnexRecord, String channel) {
        System.debug('***============ createEnvelopeForIla Begin ============*********');
        Integer numberOfInstallments = 1;
        List<dfsle.Document> ListOfDocs = new List<dfsle.Document> {};   
        List<dfsle.Tab> tabList = new List<dfsle.Tab>();
        
        Integer NumberOfDocumentAdded = 0;

        String LoanApplicationFormId = System.Label.Loan_ApplicationForm_TemplateId;//Loan Application Form_Digital
        String taxInvoiceTemplateId = System.Label.Loan_TaxInvoice_TemplateId;//Loans_Tax Invoice
        //Repayment Schedule //inside the loop
        String loanTermsAndConditions_A_TemplateId = System.Label.Loan_A_PersonalTermsConditions_TemplateId;// Loans_16(a) Personal Loans Terms and Conditions
        String loanTermsAndConditions_B_TemplateId = System.Label.Loan_B_PersonalTermsConditions_TemplateId;// Loans_16(b) Personal Loan agreement
        String promisaryNoteTemplateId = System.Label.Loan_PromissoryNote_TemplateId;//Loans_Promissory Note
        String pledgeFormTemplateId = System.Label.Loan_PledgeForm_TemplateId;//#CH05
        String managerChequeTemplateId = System.Label.Loan_ManagerCheque_TemplateId;//Loan_ManagerCheque
        String CreditCardDoc_Expats_NONStaff_ilaBlue_TempId = System.Label.CreditCardDoc_Expats_NONStaff_ilaBlue;
        String CreditCardDoc_BH_NONStaff_ilaBlue_TempId = System.Label.CreditCardDoc_BH_NONStaff_ilaBlue;

        //#CH02 : Start Mapping
        /*ApiConnection.Response getLoanOptions= new  ApiConnection.Response();
        getLoanOptions=Loans_ServiceManagerHandler.callLoansOptionsAPI(cItem.Account.CIF__pc, cItem.Case_Model__c);
        system.debug('getLoanOptions .. '+getLoanOptions);
        system.debug('1 .. '+getLoanOptions.isSuccess);
        if (getLoanOptions.isSuccess == true) {
            system.debug('2 .. '+getLoanOptions.responseData);
            Map<String, Object> responseData = (Map<String, Object>) getLoanOptions.responseData;
            system.debug('3 .. '+responseData);
            system.debug('4 .. '+responseData.containsKey('pendingLoans'));
            if (responseData.containsKey('pendingLoans')) {
                List<Object> pendingLoans = (List<Object>) responseData.get('pendingLoans');                  
                for (Object loanObj : pendingLoans) {
                    Map<String, Object> loanMap = (Map<String, Object>) loanObj;
                    
                    System.debug('Case Id -->'+cItem.id);
                    System.debug('CRM Case Id -->'+(String) loanMap.get('crmCaseId'));
                }
            } else {
                System.debug('No loans found in the pendingLoans list');
            }
        } else {
            System.debug('No pendingLoans in the responseData');
        }*/
        
        //fake response
            // getLoanOptions.isSuccess = true;
            // getLoanOptions.responseData = new List<Object>();
            // HttpRequest reques = new HttpRequest();
            // HttpResponse responseHttp = new Loans_ServiceApiCallsMock().callLoansOptionsAPI(reques,200);
            // getLoanOptions = Loans_ServiceManagerHandler.formatResponse(responseHttp);
        // End Fake Response
        
        //if(cItem.id == (String) loanMap.get('crmCaseId')){
                // get repayment schedule API===================================

                Loans_ServiceManagerHandler.APIResponse paymentsScheduleResponse = Loans_LoansListController.getSimulationPaymentList(cItem.Id, '', false);
                HttpRequest request10 = paymentsScheduleResponse.requestHttp;  
                HttpResponse response10 = paymentsScheduleResponse.responseHttp;  
                //for both error and success
                lstSA.add(SM001_ApiCalls.setSystemAction(request10.getBody(),response10.getBody(),
                            request10.getEndpoint(),request10.getMethod(),
                            cItem.id,cItem.Customer_CIF__c,cItem.accountId,response10.getStatusCode(),
                            cItem.Type+' --call Get Schedule List API (while generating docusign envelopId) ', null));

                // ===========Call fake response
                    /* ApiConnection con = new ApiConnection();
                    // String regionName ;
                    // String caseModel = cItem.case_Model__c;
                    // regionName = cItem.Account.Region_Flag__pc;
                    // if(caseModel == null || caseModel == ''){
                    //     caseModel = cItem.Account.Subscription_Model__pc;
                    // }
                    // if(caseModel == 'alburaq'){
                    //     regionName += '_alburaq';
                    // }
                     HttpRequest req = con.createRequest('POST', '/api/v1/loans/schedule?', cItem.Account.CIF__pc, null);
                    // req.setTimeout(60000);
                    // req.setBody(searchParametersJson);
                    // //Call Mock Response
                     HttpResponse response = new Loans_ServiceApiCallsMock().callGetLoanPaymentsSchedule(req,200);
                     Loans_ServiceManagerHandler.APIResponse paymentsScheduleResponse = Loans_ServiceManagerHandler.formatAPIResponse(response);*/
                // End fake response=================
                
                Map<String, Object> headerData = (Map<String, Object>) paymentsScheduleResponse.headerData;
                List< Object> repaymentScheduleresponseData = (List< Object>) paymentsScheduleResponse.responseData;
                system.debug('headerData :'+headerData);
                system.debug('repaymentScheduleresponseData :'+repaymentScheduleresponseData);
                // ================================
                if(repaymentScheduleresponseData != null){
                    numberOfInstallments = repaymentScheduleresponseData.Size();
                }else{
                    numberOfInstallments = 0;
                }
                system.debug('numberOfInstallments :'+numberOfInstallments);


                //FINAL - DONE ################### Loan Application Form Mapping =============
                    dfsle.Document applicationFormDocument ;
                    applicationFormDocument = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(LoanApplicationFormId), // templateId in dfsle.UUID format
                                    'Loan_applicationForm'); // name of the template
                    if (applicationFormDocument != null) {
                        ListOfDocs.add(applicationFormDocument);
                        NumberOfDocumentAdded ++;
                    }
                    

                    // Loan Against
                    dfsle.Tab LoanAgainstTab = new dfsle.TextTab()
                                    .withValue(caseAnnexRecord.cx_ln_Product__c?.toLowerCase().contains('unsecured') ? 'Salary':'Secured Deposit')
                                    // .withValue('Salary')
                                    .withReadOnly(true) // locked
                                    .withDataLabel('LoanAgainst')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    164, // X position
                                    108, // Y position
                                    130, // Default width
                                    19)); // Default height;
                    tabList.add(LoanAgainstTab);

                    // loan_amount1
                    dfsle.Tab loan_amount1Tab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') )) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('loan_amount1')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    164, // X position
                                    137, // Y position
                                    106, // Default width
                                    16)); // Default height;
                    tabList.add(loan_amount1Tab);


                    // RepayableIn
                    dfsle.Tab RepayableInTab = new dfsle.TextTab()
                                    .withValue(String.valueof( String.valueof( headerData.get('loanPeriod') ) ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('RepayableIn')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    131, // X position
                                    165, // Y position
                                    35, // Default width
                                    15)); // Default height;
                    tabList.add(RepayableInTab);

                    // firstInstallmentDate
                    dfsle.Tab firstInstallmentDateTab = new dfsle.TextTab()
                                    .withValue( formatDate( String.valueof( headerData.get('firstInstallmentDate') ) ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    446, // X position
                                    165, // Y position
                                    35, // Default width
                                    15)); // Default height;
                    tabList.add(firstInstallmentDateTab);

                    // Handle requested Liabilities
                    if(caseAnnexRecord.cx_ln_Requested_Liabilities__c != null){
                        List< Object> liabilities = (List< Object>) JSON.deserializeUntyped(caseAnnexRecord.cx_ln_Requested_Liabilities__c);
                        // List<Map<String, Object>> liabilities = (List<Map<String, Object>>) JSON.deserializeUntyped(cItem.Extra_information__c);
                        Integer numberOfLiabilities = 0;
                        if(liabilities.size() > 0 ){
                            for (Integer i=0; i < liabilities.size() ; i++) {
                                Map<String, Object> liabity = (Map<String, Object>) liabilities[i];
                                Boolean selected = (Boolean) liabity.get('selected');

                                if (selected == null || !selected) {
                                    continue;
                                }
                                // TypeOfFacility
                                dfsle.Tab TypeOfFacilityTab = new dfsle.TextTab()
                                            .withValue(liabity.get('type') )
                                            .withReadOnly(true) // locked
                                            .withDataLabel('TypeOfFacility')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            2, // Page number on the document
                                            110, // X position
                                            324 + numberOfLiabilities*50, // Y position
                                            85, // Default width
                                            26)); // Default height;
                                tabList.add(TypeOfFacilityTab);

                                // RemainingAmount
                                dfsle.Tab RemainingAmountTab = new dfsle.TextTab()
                                            .withValue(formatAmountEnUS(String.valueof( liabity.get('outstanding') )) )
                                            .withReadOnly(true) // locked
                                            .withDataLabel('RemainingAmount')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            2, // Page number on the document
                                            303, // X position
                                            324 + numberOfLiabilities*50, // Y position
                                            71, // Default width
                                            26)); // Default height;
                                tabList.add(RemainingAmountTab);

                                // Installment
                                dfsle.Tab InstallmentTab = new dfsle.TextTab()
                                            .withValue(formatAmountEnUS(String.valueof( liabity.get('monthlyInstallment') )) )
                                            .withReadOnly(true) // locked
                                            .withDataLabel('Installment')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            2, // Page number on the document
                                            414, // X position
                                            324 + numberOfLiabilities*50, // Y position
                                            71, // Default width
                                            26)); // Default height;
                                tabList.add(InstallmentTab);

                                // BuyOut
                                dfsle.Tab BuyOutTab = new dfsle.TextTab()
                                            .withValue('Yes' ) 
                                            .withReadOnly(true) // locked
                                            .withDataLabel('BuyOut')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            2, // Page number on the document
                                            506, // X position
                                            324 + numberOfLiabilities*50, // Y position
                                            71, // Default width
                                            26)); // Default height;
                                tabList.add(BuyOutTab);
                                
                                numberOfLiabilities ++;
                            }
                        }
                    }
            

                //################### Tax Invoice Mapping =============
                    dfsle.Document taxInvoiceDocument;
                    taxInvoiceDocument = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(taxInvoiceTemplateId), // templateId in dfsle.UUID format
                                    'Loan_taxInvoice'); // name of the template
                    if (taxInvoiceDocument != null) {
                        ListOfDocs.add(taxInvoiceDocument);
                        NumberOfDocumentAdded ++;
                    }
                    

                    // FacilityAmount
                    dfsle.Tab FacilityAmountTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') ) ) + ' BHD' )//#CH04 : change mapping
                                    .withReadOnly(true) // locked
                                    .withDataLabel('FacilityAmount')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (193 --> 150)
                                    317, // Y position
                                    99, // Default width
                                    15)); // Default height;
                    tabList.add(FacilityAmountTab);

                    // cashInHand
                    dfsle.Tab cashInHandTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('cashInHand') ) )+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('cashInHand')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (193 --> 150)
                                    333, // Y position
                                    99, // Default width
                                    15)); // Default height;
                    tabList.add(cashInHandTab);

                    // FacilityInterestRate
                    dfsle.Tab FacilityInterestRateTab = new dfsle.TextTab()
                                    .withValue(String.valueof( String.valueof( headerData.get('interestRate') ) ) + ' %' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('FacilityInterestRate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (193 --> 150)
                                    361, // Y position
                                    99, // Default width
                                    15)); // Default height;
                    tabList.add(FacilityInterestRateTab);

                    //  apr1
                    dfsle.Tab apr1Tab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('apr') )+ ' %' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('apr1')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded , // The document to use
                                    1, // Page number on the document
                                    180, // X position
                                    389, // Y position
                                    120, // Default width
                                    23)); // Default height;
                    tabList.add(apr1Tab);

                    //  totalInterest
                    dfsle.Tab totalInterestTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('totalInterest') ))+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('totalInterest')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded , // The document to use
                                    1, // Page number on the document
                                    180, // X position (221 --> 180)
                                    421, // Y position
                                    120, // Default width
                                    23)); // Default height;
                    tabList.add(totalInterestTab);

                    //  administrationFees
                    dfsle.Tab administrationFeesTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('administrationFees') ))+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('administrationFees')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded , // The document to use
                                    1, // Page number on the document
                                    180, // X position (227 --> 180)
                                    439, // Y position
                                    120, // Default width
                                    23)); // Default height;
                    tabList.add(administrationFeesTab);

                    //  administrationFeesVat
                    dfsle.Tab administrationFeesVatTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('administrationFeesVat') ))+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('administrationFeesVat')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded , // The document to use
                                    1, // Page number on the document
                                    180, // X position (226 --> 180)
                                    456, // Y position
                                    120, // Default width
                                    23)); // Default height;
                    tabList.add(administrationFeesVatTab);

                    //  insuranceAmount
                    dfsle.Tab insuranceAmountTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('insuranceAmount') ))+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('insuranceAmount')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded , // The document to use
                                    1, // Page number on the document
                                    180, // X position (229 --> 180)
                                    485, // Y position
                                    120, // Default width
                                    23)); // Default height;
                    tabList.add(insuranceAmountTab);

                    // // tenor
                    dfsle.Tab tenorTab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('loanPeriod') ))
                                    .withReadOnly(true) // locked
                                    .withDataLabel('tenor')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (229 --> 180)
                                    503, // Y position
                                    113, // Default width
                                    13)); // Default height;
                    tabList.add(tenorTab);

                    // // monthlyInstallment
                    dfsle.Tab monthlyInstallmentTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('monthlyInstallment') )) + ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('monthlyInstallment')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (231 --> 180)
                                    521, // Y position
                                    113, // Default width
                                    13)); // Default height;
                    tabList.add(monthlyInstallmentTab);

                    // // firstInstallmentDate
                    dfsle.Tab firstInstallmentDateTaxInvoiceTab = new dfsle.TextTab()
                                    .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') )))
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (231 --> 180)
                                    539, // Y position
                                    113, // Default width
                                    13)); // Default height;
                    tabList.add(firstInstallmentDateTaxInvoiceTab);

                    // // lastInstallmentDate
                    dfsle.Tab lastInstallmentDateTab = new dfsle.TextTab()
                                    .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') )))
                                    .withReadOnly(true) // locked
                                    .withDataLabel('lastInstallmentDate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (234--> 180)
                                    555, // Y position
                                    113, // Default width
                                    13)); // Default height;
                    tabList.add(lastInstallmentDateTab);

                    // // totalRepayment
                    dfsle.Tab totalRepaymentTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('totalCostOfLoan') ))+ ' BHD')
                                    .withReadOnly(true) // locked
                                    .withDataLabel('totalRepayment')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (245--> 180)
                                    583, // Y position
                                    113, // Default width
                                    13)); // Default height;
                    tabList.add(totalRepaymentTab);

                    // // VATAccountNumber
                    dfsle.Tab VATAccountNumberTab = new dfsle.TextTab()
                                    .withValue(String.valueof( '210000425500002' )) //toDo : check this
                                    .withReadOnly(true) // locked
                                    .withDataLabel('VATAccountNumber')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    180, // X position (221 --> 180)
                                    677, // Y position
                                    125, // Default width
                                    16)); // Default height;
                    tabList.add(VATAccountNumberTab);


                // FINAL - DONE ################### Repayment schedule mapping ==========

                    dfsle.Document repaymentDocument ;
                    if(numberOfInstallments <= 20){
                        String Loan_DetailedRepaymentScheduleForm_20_TemplateId = System.Label.Loan_DetailedRepaymentScheduleForm_20_TemplateId; //Loan_DetailedRepaymentScheduleForm_20
                        repaymentDocument = dfsle.Document.fromTemplate(
                            dfsle.UUID.parse(Loan_DetailedRepaymentScheduleForm_20_TemplateId), 
                            'Loan_DetailedRepaymentScheduleForm_20'); // name of the template
                        system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_20');

                    } else if(numberOfInstallments <= 53){
                        String Loan_DetailedRepaymentScheduleForm_53_TemplateId = System.Label.Loan_DetailedRepaymentScheduleForm_53_TemplateId;  //Loan_DetailedRepaymentScheduleForm_53
                        repaymentDocument = dfsle.Document.fromTemplate(
                            dfsle.UUID.parse(Loan_DetailedRepaymentScheduleForm_53_TemplateId), // templateId in dfsle.UUID format
                            'Loan_DetailedRepaymentScheduleForm_53'); // name of the template
                            system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_53');

                    } else if(numberOfInstallments <= 86){
                        String Loan_DetailedRepaymentScheduleForm_86_TemplateId = System.Label.Loan_DetailedRepaymentScheduleForm_86_TemplateId;  //Loan_DetailedRepaymentScheduleForm_86
                        repaymentDocument = dfsle.Document.fromTemplate(
                            dfsle.UUID.parse(Loan_DetailedRepaymentScheduleForm_86_TemplateId), // templateId in dfsle.UUID format
                            'Loan_DetailedRepaymentScheduleForm_86'); // name of the template
                            system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_86');
                    } else if(numberOfInstallments <= 120){
                        String Loan_DetailedRepaymentScheduleForm_120_TemplateId = System.Label.Loan_DetailedRepaymentScheduleForm_120_TemplateId;  //Loan_DetailedRepaymentScheduleForm_120
                        repaymentDocument = dfsle.Document.fromTemplate(
                            dfsle.UUID.parse(Loan_DetailedRepaymentScheduleForm_120_TemplateId), // templateId in dfsle.UUID format
                            'Loan_DetailedRepaymentScheduleForm_120'); // name of the template
                            system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_120');
                    }
                    if(repaymentDocument != null){
                        ListOfDocs.add(repaymentDocument);
                        NumberOfDocumentAdded ++;
                    }
                    

                    List<dfsle.Tab> repTabs = handleRepaymentScheduleDocTabsForIla(headerData, repaymentScheduleresponseData, NumberOfDocumentAdded,caseAnnexRecord);
                    System.debug('repTabs ' + repTabs.size());
                    System.debug('repTabs 1 ' + repTabs[0]);
                    tabList.addAll(repTabs);
            

                // FINAL - DONE ################### terms and Conditions Mapping =============
                    dfsle.Document TandCDocument_A ;
                    TandCDocument_A = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(loanTermsAndConditions_A_TemplateId), // templateId in dfsle.UUID format
                                    'Loan_TermsAndConditions'); // name of the template
                    if(TandCDocument_A != null){
                        ListOfDocs.add(TandCDocument_A);
                        NumberOfDocumentAdded = NumberOfDocumentAdded + 1;
                    }
                    

                    dfsle.Document TandCDocument_B ;
                    TandCDocument_B = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(loanTermsAndConditions_B_TemplateId), // templateId in dfsle.UUID format
                                    'Loan_PersonalLoanAgreement'); // name of the template
                    if(TandCDocument_B !=null){
                        ListOfDocs.add(TandCDocument_B);
                        NumberOfDocumentAdded = NumberOfDocumentAdded + 1;
                    }
                    

                    // loan_amount
                    dfsle.Tab loan_amountTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') ))+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('loan_amount')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    255, // X position
                                    303, // Y position
                                    60, // Default width
                                    15)); // Default height;
                    tabList.add(loan_amountTab);

                    // loan_amount arab
                    /*dfsle.Tab loan_amountTabArab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') ))+ ' BHD' )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('loan_amount_arab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    326, // X position
                                    303, // Y position
                                    60, // Default width
                                    15)); // Default height;
                    tabList.add(loan_amountTabArab);*/


                    // interestRate
                    dfsle.Tab interestRateTab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('interestRate') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('interestRate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    255, // X position
                                    325, // Y position
                                    57, // Default width
                                    15)); // Default height;
                    tabList.add(interestRateTab);

                    // interestRateArab
                    /*dfsle.Tab interestRateTabArab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('interestRate') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('interestRate_Arab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    326, // X position
                                    326, // Y position
                                    57, // Default width
                                    15)); // Default height;
                    tabList.add(interestRateTabArab);*/

                    // apr_Agreement
                    dfsle.Tab apr_AgreementTab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('apr') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('apr_Agreement')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    260, // X position
                                    347, // Y position
                                    57, // Default width
                                    15)); // Default height;
                    tabList.add(apr_AgreementTab);

                    // apr_Agreement_arab
                    /*dfsle.Tab apr_AgreementTabArab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('apr') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('apr_Agreement_arab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    304, // X position
                                    351, // Y position
                                    57, // Default width
                                    15)); // Default height;
                    tabList.add(apr_AgreementTabArab);*/

                    // LoanTerm
                    dfsle.Tab LoanTermTab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('loanPeriod') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('LoanTerm')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    260, // X position
                                    368, // Y position
                                    57, // Default width
                                    15)); // Default height;
                    tabList.add(LoanTermTab);

                    // LoanTerm_Arab
                    /*dfsle.Tab LoanTermTabArab = new dfsle.TextTab()
                                    .withValue(String.valueof( headerData.get('loanPeriod') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('LoanTerm_arab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    332, // X position
                                    376, // Y position
                                    57, // Default width
                                    15)); // Default height;
                    tabList.add(LoanTermTabArab);*/

                    String dateStr = String.valueof( headerData.get('firstInstallmentDate'));
                    Date firstDate = Date.valueOf(dateStr);
                    Integer day = firstDate.day();
                    // firstInstallmentDate
                    dfsle.Tab firstInstallmentDateTab2 = new dfsle.TextTab()
                                    .withValue(String.valueof( day ) + (day == 1 ? 'st ':'th ') +'of every month' )    
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    260, // X position
                                    419, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(firstInstallmentDateTab2);

                    // firstInstallmentDateARAb
                    /*dfsle.Tab firstInstallmentDateTab2Arab = new dfsle.TextTab()
                                    .withValue( String.valueof(day) )    
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDate_Arab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    369, // X position
                                    409, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(firstInstallmentDateTab2Arab);*/

                    // firstInstallmentDateARAb2
                    /*dfsle.Tab firstInstallmentDateTab2Arab2 = new dfsle.TextTab()
                                    .withValue( 'من كل شهر' )    
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDate_Arab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    312, // X position
                                    408, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(firstInstallmentDateTab2Arab2);*/

                    // firstInterestAccrualDate
                    dfsle.Tab firstInterestAccrualDateTab = new dfsle.TextTab()
                                    .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') ) ))//firstInterestAccrualDate
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    260, // X position
                                    438, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(firstInterestAccrualDateTab);

                    // firstInterestAccrualDateARAB
                    /*dfsle.Tab firstInterestAccrualDateTabArab = new dfsle.TextTab()
                                    .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') ) ))//firstInterestAccrualDate
                                    .withReadOnly(true) // locked
                                    .withDataLabel('firstInstallmentDateARAB')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    343, // X position
                                    422, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(firstInterestAccrualDateTabArab);*/

                    // lastInstallmentDate
                    dfsle.Tab lastInstallmentDateTaxInvoiceTab = new dfsle.TextTab()
                                    .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') ) ))
                                    .withReadOnly(true) // locked
                                    .withDataLabel('lastInstallmentDate')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    260, // X position
                                    460, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(lastInstallmentDateTaxInvoiceTab);

                    // lastInstallmentDateArAB
                    /*dfsle.Tab lastInstallmentDateTaxInvoiceTabArab = new dfsle.TextTab()
                                    .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') ) ))
                                    .withReadOnly(true) // locked
                                    .withDataLabel('lastInstallmentDatearab')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    315, // X position
                                    446, // Y position
                                    65, // Default width
                                    15)); // Default height;
                    tabList.add(lastInstallmentDateTaxInvoiceTabArab);*/


                // FINAL ################### promisary note Mapping =============
                    dfsle.Document promisaryNoteDocument ;
                    promisaryNoteDocument = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(promisaryNoteTemplateId), // templateId in dfsle.UUID format
                                    'Loan_promisaryNote'); // name of the template

                    if(promisaryNoteDocument != null){
                        ListOfDocs.add(promisaryNoteDocument);
                        NumberOfDocumentAdded ++;
                    }
                    System.debug('promisary note -> NumberOfDocumentAdded --> '+ NumberOfDocumentAdded);

                    // TotalRepaymentAmount
                    dfsle.Tab TotalRepaymentAmountTab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS( String.valueof( headerData.get('totalCostOfLoan') ) ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('TotalRepaymentAmount')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    28, // X position
                                    347, // Y position
                                    85, // Default width
                                    15)); // Default height;
                    tabList.add(TotalRepaymentAmountTab);

                    // TotalRepaymentAmount1
                    dfsle.Tab TotalRepaymentAmount1Tab = new dfsle.TextTab()
                                    .withValue(formatAmountEnUS( String.valueof( headerData.get('totalCostOfLoan') ) ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('TotalRepaymentAmount1')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    1, // Page number on the document
                                    377, // X position
                                    337, // Y position
                                    85, // Default width
                                    15)); // Default height;
                    tabList.add(TotalRepaymentAmount1Tab);
            

                //#CH05 : start
                if(caseAnnexRecord.cx_ln_Product__c == 'Secured'){
                    // ################### pledgeForm Mapping =============
                    dfsle.Document pledgeFormDocument ;
                    pledgeFormDocument = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(pledgeFormTemplateId), // templateId in dfsle.UUID format
                                    'Loans_Pledge_Form'); // name of the template
    
                    if(pledgeFormDocument != null){
                        ListOfDocs.add(pledgeFormDocument);
                        NumberOfDocumentAdded ++;
                    }
                    
                    //call api calculate-hold-amount :
                    HttpResponse holdAmountCalculResp = callCalculateHoldAmountApi(cItem);
                    if (holdAmountCalculResp.getStatusCode() != 200){
                        System.debug('The status code returned was not expected: ' + holdAmountCalculResp.getStatusCode() + ' ' + holdAmountCalculResp.getStatus());
                    }
                    else
                    {
                        System.debug('api holdAmountCalculResp.getBody() : ' + holdAmountCalculResp.getBody());
                        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(holdAmountCalculResp.getBody());
                        Map<String, Object> holdAmountData = (Map<String, Object>)m1.get('data');
                        // HoldAmountTab
                        dfsle.Tab HoldAmountTab = new dfsle.TextTab()
                                        .withValue(formatAmountEnUS(String.valueof(holdAmountData.get('holdAmount')) ) + ' BHD' )//#CH04 : change mapping
                                        .withReadOnly(true) // locked
                                        .withDataLabel('HoldAmount')
                                        .withPosition(new dfsle.Tab.Position(
                                        NumberOfDocumentAdded, // The document to use
                                        1, // Page number on the document
                                        175, // X position (193 --> 150)
                                        247, // Y position
                                        99, // Default width
                                        15)); // Default height;
                        tabList.add(HoldAmountTab);
    
                        // HoldAmountInwordsTab
                        dfsle.Tab HoldAmountInwordsTab = new dfsle.TextTab()
                                        .withValue(CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords((Decimal) holdAmountData.get('holdAmount') ) )//#CH04 : change mapping
                                        .withReadOnly(true) // locked
                                        .withDataLabel('HoldAmountInwords')
                                        .withPosition(new dfsle.Tab.Position(
                                        NumberOfDocumentAdded, // The document to use
                                        1, // Page number on the document
                                        175, // X position (193 --> 150)
                                        270, // Y position
                                        99, // Default width
                                        15)); // Default height;
                        tabList.add(HoldAmountInwordsTab);
                        System.debug('pledgeForm -> NumberOfDocumentAdded --> '+ NumberOfDocumentAdded);
                    }
                }
                //#CH05 : End

                // FINAL - DONE ############# Manager Cheque  Mapping =============
                    dfsle.UUID Loans_ManagerCheque_templateID = dfsle.UUID.parse(managerChequeTemplateId);
                    Loans_ServiceManagerHandler.numberToWordsUtilsClass numberToWordsUtils = new Loans_ServiceManagerHandler.numberToWordsUtilsClass();
                    
                    // Start Get Account Number
                    String defaultAccountNumber = '';
                    String regionName = cItem.Region_Flag__c;
                    if(cItem.Case_Model__c == 'alburaq'){
                        regionName += '_alburaq';
                    }

            ApiConnection.Response resp;
            if(!Test.isRunningTest()) {
                resp = BankAccountController.loadAccountList(cItem.Customer_CIF__c, regionName);
            } else {
                resp = new ApiConnection.Response();
            }
                    

                    system.debug('AccountList resp .. '+resp);
                    if (resp.isSuccess == true) {
                        final Map<String, Object> respData = (Map<String, Object>)resp.responseData;
                        final Object[] accounts = (Object[])respData.get('accounts');
                        for (Object accItem : accounts) {
                            Map<String, Object> acct = (Map<String, Object>) accItem;
                            Map<String, Object> acc = (Map<String, Object>) acct.get('account');
                            system.debug('acc .. '+JSON.serialize(acc));
                            if ((Boolean)acc.get('defaultAccount')) {
                                defaultAccountNumber = (String)acc.get('number');
                                break;
                            }
                        }
                        
                    }
                    // End Get Account Number


                    Decimal currentChequeAmount = 0;
                    String chequeDate = null;
                    Integer chequeCounter = 0;


                    for(Integer i=0; i<numberOfInstallments; i++){
                            Map<String, Object> paySched = (Map<String, Object>) repaymentScheduleresponseData[i];
                            String paymentDate = String.valueOf(paySched.get('paymentDate'));
                            Decimal installmentAmount = (Decimal) paySched.get('monthlyInstallmentFull');

                            if(chequeDate == null) {
                                chequeDate = paymentDate;
                            }
                            
                            currentChequeAmount += installmentAmount;
                            chequeCounter++;

                            if(chequeCounter == 3 || i == numberOfInstallments - 1) {

                                dfsle.Document chequeDocument = dfsle.Document.fromTemplate(Loans_ManagerCheque_templateID, 'Loan_ManagerCheque');
                                if(chequeDocument != null){
                                    ListOfDocs.add(chequeDocument);
                                    NumberOfDocumentAdded ++;
                                    System.debug('chequeDocument -> NumberOfDocumentAdded --> '+ NumberOfDocumentAdded);

                                }
                                chequeDocument = null;
                            
                                // Manager Cheque Tabs Mapping =============
                                    // dateTab
                                    dfsle.Tab dateTab = new dfsle.TextTab()
                                                    .withValue(formatDate(String.valueof( chequeDate )) )
                                                    .withReadOnly(true) // locked
                                                    .withDataLabel('date')
                                                    .withPosition(new dfsle.Tab.Position(
                                                    NumberOfDocumentAdded, // The document to use
                                                    1, // Page number on the document
                                                    333, // X position
                                                    22, // Y position
                                                    120, // Default width
                                                    23)); // Default height;
                                    tabList.add(dateTab);
                                    // BDAmountTab
                                    dfsle.Tab BDAmountTab = new dfsle.TextTab()
                                                    .withValue(formatAmountEnUS(String.valueof( currentChequeAmount ) ))
                                                    .withReadOnly(true) // locked
                                                    .withDataLabel('BDAmount')
                                                    .withPosition(new dfsle.Tab.Position(
                                                    NumberOfDocumentAdded, // The document to use
                                                    1, // Page number on the document
                                                    349, // X position
                                                    98, // Y position
                                                    102, // Default width
                                                    21)); // Default height;
                                    tabList.add(BDAmountTab);

                                    // AmountInWordsTab
                                    List<String> totalAmountList = String.valueOf(currentChequeAmount).split('\\.');
                                    String totalAmountWords = numberToWordsUtils.numberToWords(Integer.valueof(totalAmountList[0])) + ' Bahraini Dinars';
                                    if(totalAmountList.size() == 2) {
                                        totalAmountWords = totalAmountWords +  ' and '+ numberToWordsUtils.numberToWords(Integer.valueof(totalAmountList[1])) + ' fils';
                                    }
                                    
                                    dfsle.Tab AmountInWordsTab = new dfsle.TextTab()
                                                    .withValue(totalAmountWords)
                                                    .withReadOnly(true) // locked
                                                    .withDataLabel('BDAmount')
                                                    .withPosition(new dfsle.Tab.Position(
                                                    NumberOfDocumentAdded, // The document to use
                                                    1, // Page number on the document
                                                    20, // X position
                                                    96, // Y position
                                                    255, // Default width
                                                    36)); // Default height;
                                    tabList.add(AmountInWordsTab);

                                    // accountNoTab
                                    dfsle.Tab accountNoTab = new dfsle.TextTab()
                                                    .withValue(defaultAccountNumber )
                                                    .withReadOnly(true) // locked
                                                    .withDataLabel('accountNo')
                                                    .withPosition(new dfsle.Tab.Position(
                                                    NumberOfDocumentAdded, // The document to use
                                                    1, // Page number on the document
                                                    67, // X position
                                                    154, // Y position
                                                    117, // Default width
                                                    13)); // Default height;
                                    tabList.add(accountNoTab);

                                // Reset counters
                                    currentChequeAmount = 0;
                                    chequeDate = null;
                                    chequeCounter = 0;
                            }
                    
                    }

                // FINAL ################### Credit card Cross selling  =============
                    
                if(cItem.AIR_HaveCreditCard__c && caseAnnexRecord.cx_ln_Cross_Selling_Approver_Result__c == 'Approve'){
                    dfsle.Document creditCardDoc ;
                    if(cItem.cc_Nationality__c == 'BH'){
                        creditCardDoc = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(CreditCardDoc_BH_NONStaff_ilaBlue_TempId), // templateId in dfsle.UUID format
                                    'CreditCardDoc_BH_NONStaff_ilaBlue'); // name of the template
                    }else {
                        creditCardDoc = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(CreditCardDoc_Expats_NONStaff_ilaBlue_TempId), // templateId in dfsle.UUID format
                                    'CreditCardDoc_Expats_NONStaff_ilaBlue'); // name of the template
                    }
                    if(creditCardDoc != null){
                        ListOfDocs.add(creditCardDoc);
                        NumberOfDocumentAdded ++;
                        System.debug('CreditCardDoc_BH_NONStaff_ilaBlue -> NumberOfDocumentAdded --> '+ NumberOfDocumentAdded);

                    }
                }
                    
            //break;
        //}

        
        //#CH02 : End Mapping
        system.debug('tabList size: ' + tabList.size());
        system.debug('ListOfDocs size: ' + ListOfDocs.size());

        Map<String, Map<String, Object>> envelopeEventUpdates= new Map<String, Map<String, Object>> {
            dfsle.Envelope.STATUS_SENT => new Map<String, Object> {
                'Last_Call_Outcome__c' => 'Sent'
            },
            dfsle.Envelope.STATUS_COMPLETED => new Map<String, Object> {
                'Last_Call_Outcome__c' => 'Completed',
                'Status' => 'Under Review',
                'Sub_Status__c' => 'Pending Signature Verification'
            }
          };
        // Define document write-back options
        dfsle.Document.WriteBack documentWriteBack = new dfsle.Document.WriteBack(
            // Where to link the completed document(s)
            cItem.Id,
            // The completed document(s) file name format
            dfsle.Document.WRITE_BACK_ENVELOPE_STATUS_PDF,
            // Whether to combine all the documents into a single PDF
            false,
            // Whether to include the Certificate of Completion (CoC)
            true);

        // Create an instance of Envelope.Options
        dfsle.Envelope.Options options = new dfsle.Envelope.Options(
            false, // includeDefaultAutoPlaceTags
            documentWriteBack, // documentWriteBack
            envelopeEventUpdates, // envelopeEventUpdates
            null // recipientEventUpdates
        );
        
        dfsle.Recipient myRecipient;
        if(channel == 'Email'){
            myRecipient = dfsle.Recipient.fromSource(
                cItem.cc_Full_Name__c, // Recipient name
                cItem.cc_Email_Address__c, // Recipient email
                null, //Optional phone number
                'Contact', //Role Name. Specify the exact role name from template
                new dfsle.Entity(cItem.Id)); //source object for the Recipient.
            myRecipient = myRecipient.withTabs(tabList);

        }else if(channel == 'In-App') {
            //this bloc is for "component lwc" in loan lightning page used only for testing purposes
            String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            String Loans_DocusigManualTriggerCRMAdmin = System.Label.Loans_DocusigManualTriggerCRMAdmin;
            if(profileName == 'Restricted System Admin' && Loans_DocusigManualTriggerCRMAdmin == 'true') {
            //if(UserInfo.getUserId() == '0053N000006tZMjQAM' || UserInfo.getUserId() == '0051t000003EWO5AAO' ){
                myRecipient = dfsle.Recipient.newEmbeddedSigner().withRole('Contact').withTabs(tabList);
            } else {
                myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.Account.Name, cItem.Account.PersonEmail, cItem.ContactId).withRole('Contact').withTabs(tabList);
            }
            //myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.Account.Name, cItem.Account.PersonEmail, cItem.ContactId).withRole('Contact').withTabs(tabList);
        }

       

        dfsle.Envelope dsEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                                        new dfsle.Entity(cItem.Id, 'Case', new dfsle.Entity(cItem.ContactId) )
                                    ); 
        dsEnvelope = dsEnvelope.withOptions(options);
        dsEnvelope = dsEnvelope.withDocuments(ListOfDocs);
        dsEnvelope = dsEnvelope.withRecipients(new List<dfsle.Recipient> {myRecipient});


        // boolean sendNow = UserInfo.getUserId() == '0053N000009K2VSQA0' ? false : true ;
        // Send the envelope.
            
        if(!Test.isRunningTest()) {
            dsEnvelope = dfsle.EnvelopeService.sendEnvelope(
                dsEnvelope, // The envelope to send
                true // Send now? 
            );
            
            System.debug('The envelope Id: '+ dsEnvelope.docuSignId);
            // Return string value of DocuSign envelope ID
            return String.valueOf(dsEnvelope.docuSignId);
        } else {
            return '';
        }
    }

    //############################ Handle Tabs for repayment schedule api for ila
    // ###########################
    public static List<dfsle.Tab> handleRepaymentScheduleDocTabsForIla(Map<String, Object> headerData, List<Object> repaymentScheduleresponseData, Integer NumberOfDocumentAdded,CaseAnnex__c caseAnnexRecord){
        // Map<String, Object> paySched = (Map<String, Object>) repaymentScheduleresponseData;
        Integer numberOfInstallments = repaymentScheduleresponseData.Size();
        List<dfsle.Tab> tabList = new List<dfsle.Tab> {};

        // Commun Tabs mapping ======
            
            // approvedLoanAmountTab
            dfsle.Tab approvedLoanAmountTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( caseAnnexRecord.cx_ln_Approved_Loan_Amount__c )) + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('approvedLoanAmountTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        136, // X position
                        143, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(approvedLoanAmountTab);

            // totalLoanAmountTab
            dfsle.Tab totalLoanAmountTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('totalCostOfLoan') )) + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('totalLoanAmountTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        136, // X position
                        163, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(totalLoanAmountTab);

            // cashInHandTab
            dfsle.Tab cashInHandTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('cashInHand') ))  + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('cashInHandTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        136, // X position
                        180, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(cashInHandTab);

            // monthlyInstallmentTab
            dfsle.Tab monthlyInstallmentTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('monthlyInstallment') ))  + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('monthlyInstallmentTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        136, // X position
                        200, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(monthlyInstallmentTab);

            // loanPeriodTab
            dfsle.Tab loanPeriodTab = new dfsle.TextTab()
                        .withValue(String.valueof( headerData.get('loanPeriod') )  + ' months' )
                        .withReadOnly(true) // locked
                        .withDataLabel('loanPeriodTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        136, // X position
                        217, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(loanPeriodTab);

            // interestRateTab
            dfsle.Tab interestRateTab = new dfsle.TextTab()
                        .withValue(String.valueof( headerData.get('interestRate') )  + ' %')
                        .withReadOnly(true) // locked
                        .withDataLabel('interestRateTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        88, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(interestRateTab);

            // aprTab
            dfsle.Tab aprTab = new dfsle.TextTab()
                        .withValue(String.valueof( headerData.get('apr') )  + ' %' )
                        .withReadOnly(true) // locked
                        .withDataLabel('aprTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        106, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(aprTab);

            // totalInterestTab
            dfsle.Tab totalInterestTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('totalInterest') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('totalInterestTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        125, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(totalInterestTab);

            // insuranceAmountTab
            dfsle.Tab insuranceAmountTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('insuranceAmount') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('insuranceAmountTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        144, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(insuranceAmountTab);

            // processingFeeTab
            dfsle.Tab processingFeeTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('administrationFees') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('processingFeeTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        162, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(processingFeeTab);

            // vatProcessingFeeTab
            dfsle.Tab vatProcessingFeeTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('administrationFeesVat') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('vatProcessingFeeTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        181, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(vatProcessingFeeTab);

            // firstInstallmentDateTab1
            dfsle.Tab firstInstallmentDateTab1 = new dfsle.TextTab()
                        .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') ) ))
                        .withReadOnly(true) // locked
                        .withDataLabel('firstInstallmentDateTab1')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        199, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(firstInstallmentDateTab1);

            // lastInstallmentDateTab
            dfsle.Tab lastInstallmentDateTab = new dfsle.TextTab()
                        .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') ) ))
                        .withReadOnly(true) // locked
                        .withDataLabel('lastInstallmentDateTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        217, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(lastInstallmentDateTab);


        Integer pageNumber = 1;
        Integer positionY = 300;
        Integer rowCounter = 0;
        Integer tabHeight = 22;
        for(Integer i=0; i<numberOfInstallments; i++){
            if (i == 21) {
                rowCounter = 0;
                pageNumber = 2;
                positionY = 45;
            }else if(i == 54){
                rowCounter = 0;
                pageNumber = 3;
                positionY = 45;
            }else if(i == 87){
                rowCounter = 0;
                pageNumber = 4;
                positionY = 43;
            }

            Map<String, Object> paySched = (Map<String, Object>) repaymentScheduleresponseData[i];
            // Start Mapping =============

                // instalmentNumTab
                dfsle.Tab instalmentNumTab = new dfsle.TextTab()
                                .withValue(String.valueof(i + 1) )
                                .withReadOnly(true) // locked
                                .withDataLabel('instalmentNumTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                64, // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(instalmentNumTab);

                // paymentDateTab
                dfsle.Tab paymentDateTab = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( paySched.get('paymentDate') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('paymentDateTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                110, // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(paymentDateTab);

                // monthlyInstallementTab
                dfsle.Tab monthlyInstallementTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('monthlyInstallmentFull') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('monthlyInstallementTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                205 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(monthlyInstallementTab);

                // principalTab
                dfsle.Tab principalTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('principalAmount') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('principalTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                290 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(principalTab);

                // interestTab
                dfsle.Tab interestTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('interestAmount') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('interestTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                350 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(interestTab);

                // adminFeeTab
                /*Decimal am1 = (Decimal)paySched.get('adminFeesFlat') != null ? (Decimal)paySched.get('adminFeesFlat') : 0 ;
                Decimal am2 =  (Decimal)paySched.get('adminFeesVat') != null ? (Decimal)paySched.get('adminFeesVat') : 0;
            
                Decimal am = am1 + am2;
                dfsle.Tab adminFeeTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof(am) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('adminFeeTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                337 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(adminFeeTab);*/

                // insuranceTab
                dfsle.Tab insuranceTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( (paySched.get('monthlyInsuranceFeesFlat') != null)?paySched.get('monthlyInsuranceFeesFlat') :'0.000' ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('insuranceTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                416 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(insuranceTab);

                // outstandingBalanceTab
                dfsle.Tab outstandingBalanceTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('outstandingAmount') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('outstandingBalanceTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                485  , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(outstandingBalanceTab);

            // Increment rowCounter
            rowCounter ++;

        }
        return (tabList);
    }

    // ########################### Case model == alburaq
    // ###########################
    public static String createEnvelopeForAlburaq(Case cItem,CaseAnnex__c caseAnnexRecord, String channel) {
        Integer numberOfInstallments = 1;
        List<dfsle.Document> ListOfDocs = new List<dfsle.Document> {};   
        List<dfsle.Tab> tabList = new List<dfsle.Tab>();
        
        Integer NumberOfDocumentAdded = 0;
        //String testTemplateId = '70d1b540-ed95-422a-be32-65b2f76d9512';
        String managerChequeTemplateId = System.Label.Loan_alburaq_ManagerCheque_TemplateId; //alburaq _ Manager's Cheque
        //String loanTemplateId = '9a9c42f9-409d-41b9-96e1-bea77f78a5c3';

        String LoanApplicationFormId = System.Label.Loan_Alburaq_ApplicationForm_TemplateId; //Alburaq_Application Form
        String promisaryNoteTemplateId = System.Label.Loan_alburaq_PromissoryNote_TemplateId; //alburaq _ Promissory note
        String pledgeFormTemplateId = System.Label.Loan_Alburaq_PledgeForm_TemplateId;//#CH05
        String taxInvoiceTemplateId = System.Label.Loan_Alburaq_TaxInvoice_TemplateId; //Alburaq_ Tax Invoice
        String loanTermsAndConditions_A_TemplateId = System.Label.Loan_Alburaq_TermsAndConditions_A_TemplateId; //alburaq _ 17(a) - Personal Finance (Islamic) Terms and Conditions
        String loanTermsAndConditions_B_TemplateId = System.Label.Loan_Alburaq_TermsAndConditions_B_TemplateId; //alburaq _ 17(b) - Master Murabaha Agreement
        String loanTermsAndConditions_C_TemplateId = System.Label.Loan_Alburaq_TermsAndConditions_C_TemplateId; //alburaq _ 17(c) - Murabaha Transaction Request

        //#CH02 : Start Mapping
        /*ApiConnection.Response getLoanOptions= new  ApiConnection.Response();
        getLoanOptions=Loans_ServiceManagerHandler.callLoansOptionsAPI(cItem.Account.CIF__pc, cItem.Case_Model__c);
        
        system.debug('getLoanOptions .. '+getLoanOptions);
        if (getLoanOptions.isSuccess == true) {
            Map<String, Object> responseData = (Map<String, Object>) getLoanOptions.responseData;
            if (responseData.containsKey('pendingLoans')) {
                List<Object> pendingLoans = (List<Object>) responseData.get('pendingLoans');                  
                for (Object loanObj : pendingLoans) {
                    Map<String, Object> loanMap = (Map<String, Object>) loanObj;

                }
            } else {
                System.debug('No loans found in the pendingLoans list');
            }
        } else {
            System.debug('No pendingLoans in the responseData');
        }*/
        //#CH02 : End Mapping

        //if(cItem.id == (String) loanMap.get('crmCaseId')){
            // get repayment schedule API===================================
            Loans_ServiceManagerHandler.APIResponse paymentsScheduleResponse = Loans_LoansListController.getSimulationPaymentList(cItem.Id,'', false);
            // ===========Call fake response
                // ApiConnection con = new ApiConnection();
                // String regionName ;
                // String caseModel = cItem.case_Model__c;
                // regionName = cItem.Account.Region_Flag__pc;
                // if(caseModel == null || caseModel == ''){
                //     caseModel = cItem.Account.Subscription_Model__pc;
                // }
                // if(caseModel == 'alburaq'){
                //     regionName += '_alburaq';
                // }
                // HttpRequest req = con.createRequest('POST', '/api/v1/loans/schedule?', cItem.Account.CIF__pc, regionName);
                // req.setTimeout(60000);
                // req.setBody(searchParametersJson);
                // //Call Mock Response
                // HttpResponse response = new Loans_ServiceApiCallsMock().callGetLoanPaymentsSchedule(req,200);
                // ApiConnection.Response paymentsScheduleResponse = Loans_ServiceManagerHandler.formatResponse(response);
                
            // End fake response=================
            Map<String, Object> headerData = (Map<String, Object>) paymentsScheduleResponse.headerData;
            List< Object> repaymentScheduleresponseData = (List< Object>) paymentsScheduleResponse.responseData;
            system.debug('headerData :'+headerData);
            system.debug('repaymentScheduleresponseData :'+repaymentScheduleresponseData);
            // ================================
            numberOfInstallments = repaymentScheduleresponseData.Size();
            system.debug('numberOfInstallments :'+numberOfInstallments);

            
            // End CH01

            //FINAL - DONE ###################  Application Form Mapping =============
                dfsle.Document applicationFormDocument ;
                applicationFormDocument = dfsle.Document.fromTemplate(
                                dfsle.UUID.parse(LoanApplicationFormId), // templateId in dfsle.UUID format
                                'Loan_applicationForm'); // name of the template
                ListOfDocs.add(applicationFormDocument);
                NumberOfDocumentAdded ++;

                // Loan Against
                dfsle.Tab LoanAgainstTab = new dfsle.TextTab()
                                .withValue(caseAnnexRecord.cx_ln_Product__c?.toLowerCase().contains('unsecured') ? 'Salary':'Secured Deposit')
                                // .withValue('Salary')
                                .withReadOnly(true) // locked
                                .withDataLabel('LoanAgainst')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                150, // X position
                                157, // Y position
                                130, // Default width
                                19)); // Default height;
                tabList.add(LoanAgainstTab);

                // loan_amount1
                dfsle.Tab loan_amount1Tab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') )) ) 
                                .withReadOnly(true) // locked
                                .withDataLabel('loan_amount1')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                151, // X position
                                183, // Y position
                                106, // Default width
                                16)); // Default height;
                tabList.add(loan_amount1Tab);

                // RepayableIn
                dfsle.Tab RepayableInTab = new dfsle.TextTab()
                                .withValue(String.valueof( String.valueof( headerData.get('loanPeriod') ) ) )
                                .withReadOnly(true) // locked
                                .withDataLabel('RepayableIn')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                138, // X position
                                211, // Y position
                                35, // Default width
                                15)); // Default height;
                tabList.add(RepayableInTab);

                // firstInstallmentDate
                dfsle.Tab firstInstallmentDateTab = new dfsle.TextTab()
                                .withValue(formatDate( String.valueof( headerData.get('firstInstallmentDate') ) ) )
                                .withReadOnly(true) // locked
                                .withDataLabel('firstInstallmentDate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                444, // X position
                                209, // Y position
                                35, // Default width
                                15)); // Default height;
                tabList.add(firstInstallmentDateTab);

                // Handle requested Liabilities
                if(caseAnnexRecord.cx_ln_Requested_Liabilities__c != null){
                    List< Object> liabilities = (List< Object>) JSON.deserializeUntyped(caseAnnexRecord.cx_ln_Requested_Liabilities__c);
                    // List<Map<String, Object>> liabilities = (List<Map<String, Object>>) JSON.deserializeUntyped(cItem.Extra_information__c);
                    Integer numberOfLiabilities = 0;
                    for (Integer i=0; i < liabilities.size() ; i++) {
                        Map<String, Object> liabity = (Map<String, Object>) liabilities[i];

                        Boolean selected = (Boolean) liabity.get('selected');

                        if (selected == null || !selected) {
                            continue;
                        }
                        
                        // TypeOfFacility
                        dfsle.Tab TypeOfFacilityTab = new dfsle.TextTab()
                                    .withValue(liabity.get('type') )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('TypeOfFacility')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    95, // X position
                                    324 + numberOfLiabilities*50, // Y position
                                    85, // Default width
                                    26)); // Default height;
                        tabList.add(TypeOfFacilityTab);

                        // RemainingAmount
                        dfsle.Tab RemainingAmountTab = new dfsle.TextTab()
                                    .withValue(String.valueof( liabity.get('outstanding') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('RemainingAmount')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    303, // X position
                                    324 + numberOfLiabilities*50, // Y position
                                    71, // Default width
                                    26)); // Default height;
                        tabList.add(RemainingAmountTab);

                        // Installment
                        dfsle.Tab InstallmentTab = new dfsle.TextTab()
                                    .withValue(String.valueof( liabity.get('monthlyInstallment') ) )
                                    .withReadOnly(true) // locked
                                    .withDataLabel('Installment')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    414, // X position
                                    324 + numberOfLiabilities*50, // Y position
                                    71, // Default width
                                    26)); // Default height;
                        tabList.add(InstallmentTab);

                        // BuyOut
                        dfsle.Tab BuyOutTab = new dfsle.TextTab()
                                    .withValue('Yes' ) 
                                    .withReadOnly(true) // locked
                                    .withDataLabel('BuyOut')
                                    .withPosition(new dfsle.Tab.Position(
                                    NumberOfDocumentAdded, // The document to use
                                    2, // Page number on the document
                                    506, // X position
                                    324 + numberOfLiabilities*50, // Y position
                                    71, // Default width
                                    26)); // Default height;
                        tabList.add(BuyOutTab);
                        
                        numberOfLiabilities ++;
                    }
                }
            
            //################### Tax Invoice Mapping =============
                dfsle.Document taxInvoiceDocument ;
                taxInvoiceDocument = dfsle.Document.fromTemplate(
                                dfsle.UUID.parse(taxInvoiceTemplateId), // templateId in dfsle.UUID format
                                'Loan_taxInvoice'); // name of the template
                ListOfDocs.add(taxInvoiceDocument);
                NumberOfDocumentAdded ++;

                // FacilityAmount
                dfsle.Tab FacilityAmountTab = new dfsle.TextTab()
                                .withValue(String.valueof( String.valueof( headerData.get('principleAmount') ) )+' BHD' )//#CH04 : change mapping 
                                .withReadOnly(true) // locked
                                .withDataLabel('FacilityAmount')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (193 --> 150)
                                317, // Y position
                                99, // Default width
                                15)); // Default height;
                tabList.add(FacilityAmountTab);

                // cashInHand
                dfsle.Tab cashInHandTab = new dfsle.TextTab()
                                .withValue(String.valueof( String.valueof( headerData.get('cashInHand') ) )+' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('cashInHand')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (193 --> 150)
                                333, // Y position
                                99, // Default width
                                15)); // Default height;
                tabList.add(cashInHandTab);

                // FacilityInterestRate
                dfsle.Tab FacilityInterestRateTab = new dfsle.TextTab()
                                .withValue(String.valueof( String.valueof( headerData.get('interestRate') ) )+ ' %' )
                                .withReadOnly(true) // locked
                                .withDataLabel('FacilityInterestRate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (193 --> 150)
                                361, // Y position
                                99, // Default width
                                15)); // Default height;
                tabList.add(FacilityInterestRateTab);

                //  apr1
                dfsle.Tab apr1Tab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('apr') )+ ' %' )
                                .withReadOnly(true) // locked
                                .withDataLabel('apr1')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded , // The document to use
                                1, // Page number on the document
                                180, // X position (193 --> 150)
                                389, // Y position
                                120, // Default width
                                23)); // Default height;
                tabList.add(apr1Tab);

                //  totalInterest
                dfsle.Tab totalInterestTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('totalInterest') )+' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('totalInterest')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded , // The document to use
                                1, // Page number on the document
                                180, // X position (221 --> 180)
                                421, // Y position
                                120, // Default width
                                23)); // Default height;
                tabList.add(totalInterestTab);

                //  administrationFees
                dfsle.Tab administrationFeesTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('administrationFees') )+' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('administrationFees')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded , // The document to use
                                1, // Page number on the document
                                180, // X position (221 --> 180)
                                439, // Y position
                                120, // Default width
                                23)); // Default height;
                tabList.add(administrationFeesTab);

                //  administrationFeesVat
                dfsle.Tab administrationFeesVatTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('administrationFeesVat') )+' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('administrationFeesVat')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded , // The document to use
                                1, // Page number on the document
                                180, // X position (221 --> 180)
                                456, // Y position
                                120, // Default width
                                23)); // Default height;
                tabList.add(administrationFeesVatTab);

                //  insuranceAmount
                dfsle.Tab insuranceAmountTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('insuranceAmount') )+' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('insuranceAmount')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded , // The document to use
                                1, // Page number on the document
                                180, // X position (221 --> 180)
                                486, // Y position
                                120, // Default width
                                23)); // Default height;
                tabList.add(insuranceAmountTab);

                // // tenor
                dfsle.Tab tenorTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('loanPeriod') ))
                                .withReadOnly(true) // locked
                                .withDataLabel('tenor')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (221 --> 180)
                                504, // Y position
                                113, // Default width
                                13)); // Default height;
                tabList.add(tenorTab);

                // // monthlyInstallment
                dfsle.Tab monthlyInstallmentTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('monthlyInstallment') )+' BHD')
                                .withReadOnly(true) // locked
                                .withDataLabel('monthlyInstallment')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (221 --> 180)
                                522, // Y position
                                113, // Default width
                                13)); // Default height;
                tabList.add(monthlyInstallmentTab);

                // // firstInstallmentDate
                dfsle.Tab firstInstallmentDateTaxInvoiceTab = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') )))
                                .withReadOnly(true) // locked
                                .withDataLabel('firstInstallmentDate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (234 --> 180)
                                538, // Y position
                                113, // Default width
                                13)); // Default height;
                tabList.add(firstInstallmentDateTaxInvoiceTab);

                // // lastInstallmentDate
                dfsle.Tab lastInstallmentDateTab = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') )))
                                .withReadOnly(true) // locked
                                .withDataLabel('lastInstallmentDate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (238--> 180)
                                555, // Y position
                                113, // Default width
                                13)); // Default height;
                tabList.add(lastInstallmentDateTab);

                // // totalRepayment
                dfsle.Tab totalRepaymentTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('totalCostOfLoan') )+' BHD')
                                .withReadOnly(true) // locked
                                .withDataLabel('totalRepayment')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (245 --> 180)
                                584, // Y position
                                113, // Default width
                                13)); // Default height;
                tabList.add(totalRepaymentTab);

                // // VATAccountNumber
                dfsle.Tab VATAccountNumberTab = new dfsle.TextTab()
                                .withValue(String.valueof( '210000425500002' )) //toDo : ..
                                .withReadOnly(true) // locked
                                .withDataLabel('VATAccountNumber')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                180, // X position (215 --> 180)
                                677, // Y position
                                125, // Default width
                                16)); // Default height;
                tabList.add(VATAccountNumberTab);

            //FINAL - DONE ################### Repayment schedule mapping ==========
                dfsle.Document repaymentDocument ;
                if(numberOfInstallments <= 21){
                    String Loan_alburaq_DetailedRepaymentScheduleForm_21_TemplateId = System.Label.Loan_alburaq_DetailedRepaymentScheduleForm_21_TemplateId;  //alburaq_DetailedRepaymentScheduleForm_21
                    repaymentDocument = dfsle.Document.fromTemplate(
                        dfsle.UUID.parse(Loan_alburaq_DetailedRepaymentScheduleForm_21_TemplateId), // templateId in dfsle.UUID format
                        'Loan_DetailedRepaymentScheduleForm_19'); // name of the template
                    system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_19');

                } else if(numberOfInstallments <= 53){ 
                    String Loan_alburaq_DetailedRepaymentScheduleForm_53_TemplateId = System.Label.Loan_alburaq_DetailedRepaymentScheduleForm_53_TemplateId;  //alburaq_DetailedRepaymentScheduleForm_53
                    repaymentDocument = dfsle.Document.fromTemplate(
                        dfsle.UUID.parse(Loan_alburaq_DetailedRepaymentScheduleForm_53_TemplateId),
                        'Loan_DetailedRepaymentScheduleForm_53'); // name of the template
                        system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_53');

                } else if(numberOfInstallments <= 85){
                    String Loan_alburaq_DetailedRepaymentScheduleForm_85_TemplateId = System.Label.Loan_alburaq_DetailedRepaymentScheduleForm_85_TemplateId;  //alburaq_DetailedRepaymentScheduleForm_85
                    repaymentDocument = dfsle.Document.fromTemplate(
                        dfsle.UUID.parse(Loan_alburaq_DetailedRepaymentScheduleForm_85_TemplateId),
                        'Loan_DetailedRepaymentScheduleForm_85'); // name of the template
                        system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_85');
                } else if(numberOfInstallments <= 117){
                    String Loan_alburaq_DetailedRepaymentScheduleForm_117_TemplateId = System.Label.Loan_alburaq_DetailedRepaymentScheduleForm_117_TemplateId;  //alburaq_DetailedRepaymentScheduleForm_117
                    repaymentDocument = dfsle.Document.fromTemplate(
                        dfsle.UUID.parse(Loan_alburaq_DetailedRepaymentScheduleForm_117_TemplateId), 
                        'Loan_DetailedRepaymentScheduleForm_117'); // name of the template
                        system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_117');
                } else {
                    String Loan_alburaq_DetailedRepaymentScheduleForm_149_TemplateId = System.Label.Loan_alburaq_DetailedRepaymentScheduleForm_149_TemplateId;  //alburaq_DetailedRepaymentScheduleForm_149
                    repaymentDocument = dfsle.Document.fromTemplate(
                        dfsle.UUID.parse(Loan_alburaq_DetailedRepaymentScheduleForm_149_TemplateId), 
                        'Loan_DetailedRepaymentScheduleForm_149'); // name of the template
                        system.debug('repayment Template Id: Loan_DetailedRepaymentScheduleForm_149');
                }
                ListOfDocs.add(repaymentDocument);
                NumberOfDocumentAdded ++;

                List<dfsle.Tab> repTabs = handleRepaymentScheduleDocTabsForAlburaq(headerData, repaymentScheduleresponseData, NumberOfDocumentAdded,caseAnnexRecord);
                System.debug('repTabs ' + repTabs.size());
                System.debug('repTabs 1 ' + repTabs[0]);
                tabList.addAll(repTabs);
            
            //FINAL - DONE ################### terms and Conditions Mapping =============
                dfsle.Document TandCDocument_A ;
                TandCDocument_A = dfsle.Document.fromTemplate(
                                dfsle.UUID.parse(loanTermsAndConditions_A_TemplateId), // templateId in dfsle.UUID format
                                'Loan_TermsAndConditions'); // name of the template
                ListOfDocs.add(TandCDocument_A);
                NumberOfDocumentAdded = NumberOfDocumentAdded + 1;

                dfsle.Document TandCDocument_B ;
                TandCDocument_B = dfsle.Document.fromTemplate(
                                dfsle.UUID.parse(loanTermsAndConditions_B_TemplateId), // templateId in dfsle.UUID format
                                'Loan_PersonalLoanAgreement'); // name of the template
                ListOfDocs.add(TandCDocument_B);
                NumberOfDocumentAdded = NumberOfDocumentAdded + 1;

                dfsle.Document TandCDocument_C ;
                TandCDocument_C = dfsle.Document.fromTemplate(
                                dfsle.UUID.parse(loanTermsAndConditions_C_TemplateId), // templateId in dfsle.UUID format
                                'Loan_PersonalLoanAgreement'); // name of the template
                ListOfDocs.add(TandCDocument_C);
                NumberOfDocumentAdded = NumberOfDocumentAdded + 1;

                // loan_amount
                dfsle.Tab loan_amountTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') ))+' BHD')
                                .withReadOnly(true) // locked
                                .withDataLabel('loan_amount')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                263, // X position
                                684, // Y position
                                60, // Default width
                                15)); // Default height;
                tabList.add(loan_amountTab);

                // loan_amountARAB
                /*
                dfsle.Tab loan_amountARABTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('principleAmount') ))+' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('loan_amountARAB')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                310, // X position
                                676, // Y position
                                60, // Default width
                                15)); // Default height;
                tabList.add(loan_amountARABTab);
                */

                // MurabahaProfit
                dfsle.Tab MurabahaProfitTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('totalInterest') )) +' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('MurabahaProfit')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                266, // X position
                                706, // Y position
                                60, // Default width
                                15)); // Default height;
                tabList.add(MurabahaProfitTab);

                // MurabahaProfitARAB
                /*
                dfsle.Tab MurabahaProfitARABTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('totalInterest') )) +' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('MurabahaProfitARAB')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                312, // X position
                                702, // Y position
                                60, // Default width
                                15)); // Default height;
                tabList.add(MurabahaProfitARABTab);
                */

                // interestRate
                dfsle.Tab interestRateTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('interestRate') ) +' %')
                                .withReadOnly(true) // locked
                                .withDataLabel('interestRate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                263, // X position
                                728, // Y position
                                57, // Default width
                                15)); // Default height;
                tabList.add(interestRateTab);

                // interestRateARAB
                /*
                dfsle.Tab interestRateARABTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('interestRate') ) +' %')
                                .withReadOnly(true) // locked
                                .withDataLabel('interestRateARAB')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                316, // X position
                                727, // Y position
                                57, // Default width
                                15)); // Default height;
                tabList.add(interestRateARABTab);
                */

                // apr_Agreement
                dfsle.Tab apr_AgreementTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('apr') )+' %' )
                                .withReadOnly(true) // locked
                                .withDataLabel('apr_Agreement')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                267, // X position
                                143, // Y position
                                57, // Default width
                                15)); // Default height;
                tabList.add(apr_AgreementTab);

                // apr_AgreementARAB
                /*
                dfsle.Tab apr_AgreementARABTab = new dfsle.TextTab()
                                .withValue(String.valueof( headerData.get('apr') )  )
                                .withReadOnly(true) // locked
                                .withDataLabel('apr_AgreementARAB')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                306, // X position
                                145, // Y position
                                57, // Default width
                                15)); // Default height;
                tabList.add(apr_AgreementARABTab);
                */

                // deferredPayementPrice
                dfsle.Tab deferredPayementPriceTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('totalCostOfLoan') )) + ' BHD')
                                .withReadOnly(true) // locked
                                .withDataLabel('deferredPayementPrice')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                268, // X position
                                165, // Y position
                                57, // Default width
                                15)); // Default height;
                tabList.add(deferredPayementPriceTab);

                // deferredPayementPriceARAB
                /*
                dfsle.Tab deferredPayementPriceARABTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( headerData.get('totalCostOfLoan') )) + ' BHD' )
                                .withReadOnly(true) // locked
                                .withDataLabel('deferredPayementPriceARAB')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                334, // X position
                                182, // Y position
                                57, // Default width
                                15)); // Default height;
                tabList.add(deferredPayementPriceARABTab);
                */

                // firstInstallmentDate
                dfsle.Tab firstInstallmentDateTab2 = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('firstInstallmentDate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                268, // X position
                                192, // Y position
                                65, // Default width
                                15)); // Default height;
                tabList.add(firstInstallmentDateTab2);

                // firstInstallmentDateARAB
                /*
                dfsle.Tab firstInstallmentDateARABTab2 = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('firstInstallmentDateARAB')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                340, // X position
                                234, // Y position
                                65, // Default width
                                15)); // Default height;
                tabList.add(firstInstallmentDateARABTab2);
                */

                // lastInstallmentDate
                dfsle.Tab lastInstallmentDateTaxInvoiceTab = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('lastInstallmentDate')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                262, // X position
                                217, // Y position
                                65, // Default width
                                15)); // Default height;
                tabList.add(lastInstallmentDateTaxInvoiceTab);

                // lastInstallmentDateARAV
                /*
                dfsle.Tab lastInstallmentDateARAVTaxInvoiceTab = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('lastInstallmentDateARAV')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                2, // Page number on the document
                                312, // X position
                                258, // Y position
                                65, // Default width
                                15)); // Default height;
                tabList.add(lastInstallmentDateARAVTaxInvoiceTab);
                */
                

            //FINAL - DONE ################### promisary note Mapping =============
                dfsle.Document promisaryNoteDocument ;
                promisaryNoteDocument = dfsle.Document.fromTemplate(
                                dfsle.UUID.parse(promisaryNoteTemplateId), // templateId in dfsle.UUID format
                                'Loan_promisaryNote'); // name of the template
                ListOfDocs.add(promisaryNoteDocument);
                NumberOfDocumentAdded ++;

                // TotalRepaymentAmount
                dfsle.Tab TotalRepaymentAmountTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS( String.valueof( headerData.get('totalCostOfLoan') ) ) )
                                .withReadOnly(true) // locked
                                .withDataLabel('TotalRepaymentAmount')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                32, // X position
                                347, // Y position
                                85, // Default width
                                15)); // Default height;
                tabList.add(TotalRepaymentAmountTab);

                // TotalRepaymentAmount1
                dfsle.Tab TotalRepaymentAmount1Tab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS( String.valueof( headerData.get('totalCostOfLoan') ) ) )
                                .withReadOnly(true) // locked
                                .withDataLabel('TotalRepaymentAmount1')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                1, // Page number on the document
                                378, // X position
                                337, // Y position
                                85, // Default width
                                15)); // Default height;
                tabList.add(TotalRepaymentAmount1Tab);
            
            //#CH05 : start
            // ################### pledgeForm Mapping =============
                if(caseAnnexRecord.cx_ln_Product__c == 'Secured'){
                    dfsle.Document pledgeFormDocument ;
                    pledgeFormDocument = dfsle.Document.fromTemplate(
                                    dfsle.UUID.parse(pledgeFormTemplateId), // templateId in dfsle.UUID format
                                    'Alburaq_Pledge_Form'); // name of the template
    
                    if(pledgeFormDocument != null){
                        ListOfDocs.add(pledgeFormDocument);
                        NumberOfDocumentAdded ++;
                    }
                    //call api calculate-hold-amount :
                    HttpResponse holdAmountCalculResp = callCalculateHoldAmountApi(cItem);
                    if (holdAmountCalculResp.getStatusCode() != 200){
                        System.debug('The status code returned was not expected: ' + holdAmountCalculResp.getStatusCode() + ' ' + holdAmountCalculResp.getStatus());
                    }
                    else
                    {
                        System.debug('api holdAmountCalculResp.getBody() : ' + holdAmountCalculResp.getBody());
                        Map<String, Object> m1 = (Map<String, Object>)JSON.deserializeUntyped(holdAmountCalculResp.getBody());
                        Map<String, Object> holdAmountData = (Map<String, Object>)m1.get('data');
                        // HoldAmountTab
                        dfsle.Tab HoldAmountTab = new dfsle.TextTab()
                                        .withValue(formatAmountEnUS(String.valueof(holdAmountData.get('holdAmount')) ) + ' BHD' )//#CH04 : change mapping
                                        .withReadOnly(true) // locked
                                        .withDataLabel('HoldAmount')
                                        .withPosition(new dfsle.Tab.Position(
                                        NumberOfDocumentAdded, // The document to use
                                        1, // Page number on the document
                                        175, // X position (193 --> 150)
                                        247, // Y position
                                        99, // Default width
                                        15)); // Default height;
                        tabList.add(HoldAmountTab);
    
                        // HoldAmountInwordsTab
                        dfsle.Tab HoldAmountInwordsTab = new dfsle.TextTab()
                                        .withValue(CC_ApprovedHoldAmountHandler.convertDecimalToBahrainWords((Decimal) holdAmountData.get('holdAmount') ) )//#CH04 : change mapping
                                        .withReadOnly(true) // locked
                                        .withDataLabel('HoldAmountInwords')
                                        .withPosition(new dfsle.Tab.Position(
                                        NumberOfDocumentAdded, // The document to use
                                        1, // Page number on the document
                                        175, // X position (193 --> 150)
                                        270, // Y position
                                        99, // Default width
                                        15)); // Default height;
                        tabList.add(HoldAmountInwordsTab);
                        System.debug('pledgeForm -> NumberOfDocumentAdded --> '+ NumberOfDocumentAdded);
                    }
                }
            //#CH05 : End

            //FINAL ############# Murabaha Contract Confirmation =============
                // dfsle.Document murabahaDocument ;
                // murabahaDocument = dfsle.Document.fromTemplate(
                //                 dfsle.UUID.parse(murabahaContractTemplateId), // templateId in dfsle.UUID format
                //                 'alburaq_murabahaContractConfirmation'); // name of the template
                // ListOfDocs.add(murabahaDocument);
                // NumberOfDocumentAdded ++;

            //FINAL - DONE ############# Manager Cheque  Mapping =============
                dfsle.UUID Loans_ManagerCheque_templateID = dfsle.UUID.parse(managerChequeTemplateId);
                Loans_ServiceManagerHandler.numberToWordsUtilsClass numberToWordsUtils = new Loans_ServiceManagerHandler.numberToWordsUtilsClass();
                
                // Start Get Account Number
                String defaultAccountNumber = '';
                String regionName = cItem.Region_Flag__c;
                if(cItem.Case_Model__c == 'alburaq'){
                    regionName += '_alburaq';
                }
                
                ApiConnection.Response resp;
                if(!Test.isRunningTest()) {
                    resp = BankAccountController.loadAccountList(cItem.Customer_CIF__c, regionName);
                } else {
                    resp = new ApiConnection.Response();
                }
                system.debug('AccountList resp .. '+resp);
                if (resp.isSuccess == true) {
                    final Map<String, Object> respData = (Map<String, Object>)resp.responseData;
                    final Object[] accounts = (Object[])respData.get('accounts');
                    for (Object accItem : accounts) {
                        Map<String, Object> acct = (Map<String, Object>) accItem;
                        Map<String, Object> acc = (Map<String, Object>) acct.get('account');
                        system.debug('acc .. '+JSON.serialize(acc));
                        if ((Boolean)acc.get('defaultAccount')) {
                            defaultAccountNumber = (String)acc.get('number');
                            break;
                        }
                    }
                    
                }
                // End Get Account Number

                
                Decimal currentChequeAmount = 0;
                String chequeDate = null;
                Integer chequeCounter = 0;


                for(Integer i=0; i<numberOfInstallments; i++){
                    Map<String, Object> paySched = (Map<String, Object>) repaymentScheduleresponseData[i];
                    String paymentDate = String.valueOf(paySched.get('paymentDate'));
                    Decimal installmentAmount = (Decimal) paySched.get('monthlyInstallmentFull');
    
                    if(chequeDate == null) {
                        chequeDate = paymentDate;
                    }
                    
                    currentChequeAmount += installmentAmount;
                    chequeCounter++;
    
                    if(chequeCounter == 3 || i == numberOfInstallments - 1) {
    
                        dfsle.Document chequeDocument = dfsle.Document.fromTemplate(Loans_ManagerCheque_templateID, 'Loan_ManagerCheque');
                        if(chequeDocument != null){
                            ListOfDocs.add(chequeDocument);
                            NumberOfDocumentAdded ++;
                        }
                        chequeDocument = null;
                    
                        // Manager Cheque Tabs Mapping =============
                            // dateTab
                            dfsle.Tab dateTab = new dfsle.TextTab()
                                            .withValue(formatDate(String.valueof( chequeDate )) )
                                            .withReadOnly(true) // locked
                                            .withDataLabel('date')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            1, // Page number on the document
                                            333, // X position
                                            22, // Y position
                                            120, // Default width
                                            23)); // Default height;
                            tabList.add(dateTab);
                            // BDAmountTab
                            dfsle.Tab BDAmountTab = new dfsle.TextTab()
                                            .withValue(formatAmountEnUS(String.valueof( currentChequeAmount ) ))
                                            .withReadOnly(true) // locked
                                            .withDataLabel('BDAmount')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            1, // Page number on the document
                                            349, // X position
                                            98, // Y position
                                            102, // Default width
                                            21)); // Default height;
                            tabList.add(BDAmountTab);
    
                            // AmountInWordsTab
                            List<String> totalAmountList = String.valueOf(currentChequeAmount).split('\\.');
                            String totalAmountWords = numberToWordsUtils.numberToWords(Integer.valueof(totalAmountList[0])) + ' Bahraini Dinars';
                            if(totalAmountList.size() == 2) {
                                totalAmountWords = totalAmountWords +  ' and '+ numberToWordsUtils.numberToWords(Integer.valueof(totalAmountList[1])) + ' fils';
                            }
                            
                            dfsle.Tab AmountInWordsTab = new dfsle.TextTab()
                                            .withValue(totalAmountWords)
                                            .withReadOnly(true) // locked
                                            .withDataLabel('BDAmount')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            1, // Page number on the document
                                            20, // X position
                                            96, // Y position
                                            255, // Default width
                                            36)); // Default height;
                            tabList.add(AmountInWordsTab);
    
                            // accountNoTab
                            dfsle.Tab accountNoTab = new dfsle.TextTab()
                                            .withValue(defaultAccountNumber )
                                            .withReadOnly(true) // locked
                                            .withDataLabel('accountNo')
                                            .withPosition(new dfsle.Tab.Position(
                                            NumberOfDocumentAdded, // The document to use
                                            1, // Page number on the document
                                            100, // X position
                                            154, // Y position
                                            117, // Default width
                                            13)); // Default height;
                            tabList.add(accountNoTab);
    
                        // Reset counters
                            currentChequeAmount = 0;
                            chequeDate = null;
                            chequeCounter = 0;
                    }
                }
            
            //break;
        //}

        system.debug('tabList size: ' + tabList.size());

        Map<String, Map<String, Object>> envelopeEventUpdates= new Map<String, Map<String, Object>> {
            dfsle.Envelope.STATUS_SENT => new Map<String, Object> {
                'Last_Call_Outcome__c' => 'Sent'
            },
            dfsle.Envelope.STATUS_COMPLETED => new Map<String, Object> {
                'Last_Call_Outcome__c' => 'Completed',
                'Status' => 'Under Review',
                'Sub_Status__c' => 'Pending Signature Verification'
            }
        };
        // Define document write-back options
        dfsle.Document.WriteBack documentWriteBack = new dfsle.Document.WriteBack(
            // Where to link the completed document(s)
            cItem.Id,
            // The completed document(s) file name format
            dfsle.Document.WRITE_BACK_ENVELOPE_STATUS_PDF,
            // Whether to combine all the documents into a single PDF
            false,
            // Whether to include the Certificate of Completion (CoC)
            true);

        // Create an instance of Envelope.Options
        dfsle.Envelope.Options options = new dfsle.Envelope.Options(
            false, // includeDefaultAutoPlaceTags
            documentWriteBack, // documentWriteBack
            envelopeEventUpdates, // envelopeEventUpdates
            null // recipientEventUpdates
        );

        dfsle.Recipient myRecipient;
        if(channel == 'Email'){
            //myEnvelope = myEnvelope.withEmail('My custom Email Subject', 'My custom Email Message');
            //use the Recipient.fromSource method to create the Recipient to send an email
            myRecipient = dfsle.Recipient.fromSource(
                cItem.cc_Full_Name__c, // Recipient name
                cItem.cc_Email_Address__c, // Recipient email
                null, //Optional phone number
                'Contact', //Role Name. Specify the exact role name from template
                new dfsle.Entity(cItem.Id)); //source object for the Recipient.
            myRecipient.withTabs(tabList);

        }else if(channel == 'In-App') {

            //this bloc is for "component lwc" in loan lightning page used only for testing purposes
            String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            String Loans_DocusigManualTriggerCRMAdmin = System.Label.Loans_DocusigManualTriggerCRMAdmin;
            if (profileName == 'Restricted System Admin' && Loans_DocusigManualTriggerCRMAdmin == 'true') {
            //if(UserInfo.getUserId() == '0053N000006tZMjQAM' || UserInfo.getUserId() == '0051t000003EWO5AAO'){
                myRecipient = dfsle.Recipient.newEmbeddedSigner().withRole('Contact').withTabs(tabList);
            } else {
                myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.Account.Name, cItem.Account.PersonEmail, cItem.ContactId).withRole('Contact').withTabs(tabList);
            }
            //myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.Account.Name, cItem.Account.PersonEmail, cItem.ContactId).withRole('Contact').withTabs(tabList);
        }

        // for (dfsle.Document doc : ListOfDocs) {
        //     system.debug('Document ==> '+ doc);
        // }

        dfsle.Envelope dsEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
            new dfsle.Entity(cItem.Id, 'Case', new dfsle.Entity(cItem.ContactId) )) // The initiating Salesforce entity--current SF user (salesperson)
            .withDocuments(ListOfDocs)
            .withOptions(options)
            .withRecipients(new List<dfsle.Recipient> {myRecipient});
        
        
        // boolean sendNow = UserInfo.getUserId() == '0053N000009K2VSQA0' ? false : true ;
        // Send the envelope.
        if(!Test.isRunningTest()) {
            dsEnvelope = dfsle.EnvelopeService.sendEnvelope(
                dsEnvelope, // The envelope to send
                true // Send now? 
            );
            
            System.debug('The envelope Id: '+ dsEnvelope.docuSignId);
            // Return string value of DocuSign envelope ID
            return String.valueOf(dsEnvelope.docuSignId);
        } else {
            return '';
        }
        
    }

    // ########################### Handle Tabs for repayment schedule api for alburaq
    // ###########################
    public static List<dfsle.Tab> handleRepaymentScheduleDocTabsForAlburaq(Map<String, Object> headerData, List<Object> repaymentScheduleresponseData, Integer NumberOfDocumentAdded,CaseAnnex__c caseAnnexRecord){
        // Map<String, Object> paySched = (Map<String, Object>) repaymentScheduleresponseData;
        Integer numberOfInstallments = repaymentScheduleresponseData.Size();
        List<dfsle.Tab> tabList = new List<dfsle.Tab> {};

        // Commun Tabs mapping ======
            // approvedLoanAmountTab
            dfsle.Tab approvedLoanAmountTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( caseAnnexRecord.cx_ln_Approved_Loan_Amount__c )) + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('approvedLoanAmountTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        151, // X position
                        138, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(approvedLoanAmountTab);

            // totalLoanAmountTab
            dfsle.Tab totalLoanAmountTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('totalCostOfLoan') )) + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('totalLoanAmountTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        151, // X position
                        157, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(totalLoanAmountTab);

            // cashInHandTab
            dfsle.Tab cashInHandTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('cashInHand') ))  + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('cashInHandTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        151, // X position
                        175, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(cashInHandTab);

            // monthlyInstallmentTab
            dfsle.Tab monthlyInstallmentTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('monthlyInstallment') ))  + ' BHD' )
                        .withReadOnly(true) // locked
                        .withDataLabel('monthlyInstallmentTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        151, // X position
                        193, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(monthlyInstallmentTab);

            // loanPeriodTab
            dfsle.Tab loanPeriodTab = new dfsle.TextTab()
                        .withValue(String.valueof( headerData.get('loanPeriod') )  + ' months' )
                        .withReadOnly(true) // locked
                        .withDataLabel('loanPeriodTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        151, // X position
                        212, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(loanPeriodTab);

            // interestRateTab
            dfsle.Tab interestRateTab = new dfsle.TextTab()
                        .withValue(String.valueof( headerData.get('interestRate') )  + ' %')
                        .withReadOnly(true) // locked
                        .withDataLabel('interestRateTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        85, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(interestRateTab);

            // aprTab
            dfsle.Tab aprTab = new dfsle.TextTab()
                        .withValue(String.valueof( headerData.get('apr') )  + ' %' )
                        .withReadOnly(true) // locked
                        .withDataLabel('aprTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        103, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(aprTab);

            // totalInterestTab
            dfsle.Tab totalInterestTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('totalInterest') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('totalInterestTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        122, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(totalInterestTab);

            // insuranceAmountTab
            dfsle.Tab insuranceAmountTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('insuranceAmount') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('insuranceAmountTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        140, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(insuranceAmountTab);

            // processingFeeTab
            dfsle.Tab processingFeeTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('administrationFees') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('processingFeeTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        157, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(processingFeeTab);

            // vatProcessingFeeTab
            dfsle.Tab vatProcessingFeeTab = new dfsle.TextTab()
                        .withValue(formatAmountEnUS(String.valueof( headerData.get('administrationFeesVat') ))  + ' BHD')
                        .withReadOnly(true) // locked
                        .withDataLabel('vatProcessingFeeTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        176, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(vatProcessingFeeTab);

            // firstInstallmentDateTab1
            dfsle.Tab firstInstallmentDateTab1 = new dfsle.TextTab()
                        .withValue(formatDate(String.valueof( headerData.get('firstInstallmentDate') ) ))
                        .withReadOnly(true) // locked
                        .withDataLabel('firstInstallmentDateTab1')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        195, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(firstInstallmentDateTab1);

            // lastInstallmentDateTab
            dfsle.Tab lastInstallmentDateTab = new dfsle.TextTab()
                        .withValue(formatDate(String.valueof( headerData.get('lastInstallmentDate') ) ))
                        .withReadOnly(true) // locked
                        .withDataLabel('lastInstallmentDateTab')
                        .withPosition(new dfsle.Tab.Position(
                        NumberOfDocumentAdded, // The document to use
                        1, // Page number on the document
                        450, // X position
                        212, // Y position
                        141, // Default width
                        17)); // Default height;
            tabList.add(lastInstallmentDateTab);


        Integer pageNumber = 1;
        Integer positionY = 300;
        Integer rowCounter = 0;
        Integer tabHeight = 22;
        for(Integer i=0; i<numberOfInstallments; i++){
            if (i == 21) {
                rowCounter = 0;
                pageNumber = 2;
                positionY = 44;
            }else if(i == 53){
                rowCounter = 0;
                pageNumber = 3;
                positionY = 44;
            }else if(i == 85){
                rowCounter = 0;
                pageNumber = 4;
                positionY = 44;
            }else if(i == 117){
                rowCounter = 0;
                pageNumber = 5;
                positionY = 44;
            } 

            Map<String, Object> paySched = (Map<String, Object>) repaymentScheduleresponseData[i];
            // Start Mapping =============
                // instalmentNumTab
                dfsle.Tab instalmentNumTab = new dfsle.TextTab()
                                .withValue(String.valueof(i + 1) )
                                .withReadOnly(true) // locked
                                .withDataLabel('instalmentNumTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                64, // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(instalmentNumTab);

                // paymentDateTab
                dfsle.Tab paymentDateTab = new dfsle.TextTab()
                                .withValue(formatDate(String.valueof( paySched.get('paymentDate') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('paymentDateTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                110, // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(paymentDateTab);

                // monthlyInstallementTab
                dfsle.Tab monthlyInstallementTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('monthlyInstallmentFull') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('monthlyInstallementTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                205 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(monthlyInstallementTab);

                // principalTab
                dfsle.Tab principalTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('principalAmount') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('principalTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                290 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(principalTab);

                // interestTab
                dfsle.Tab interestTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('interestAmount') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('interestTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                350 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(interestTab);

                // adminFeeTab
                /*Decimal am1 = (Decimal)paySched.get('adminFeesFlat') != null ? (Decimal)paySched.get('adminFeesFlat') : 0 ;
                Decimal am2 =  (Decimal)paySched.get('adminFeesVat') != null ? (Decimal)paySched.get('adminFeesVat') : 0;
            
                Decimal am = am1 + am2;
                dfsle.Tab adminFeeTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof(am) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('adminFeeTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                337 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(adminFeeTab);*/

                // insuranceTab
                dfsle.Tab insuranceTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( (paySched.get('monthlyInsuranceFeesFlat') != null)?paySched.get('monthlyInsuranceFeesFlat') :'0.000' ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('insuranceTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                416 , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(insuranceTab);

                // outstandingBalanceTab
                dfsle.Tab outstandingBalanceTab = new dfsle.TextTab()
                                .withValue(formatAmountEnUS(String.valueof( paySched.get('outstandingAmount') ) ))
                                .withReadOnly(true) // locked
                                .withDataLabel('outstandingBalanceTab')
                                .withPosition(new dfsle.Tab.Position(
                                NumberOfDocumentAdded, // The document to use
                                pageNumber, // Page number on the document
                                485  , // X position
                                positionY + rowCounter * tabHeight, // Y position
                                74, // Default width
                                24)); // Default height;
                tabList.add(outstandingBalanceTab);

            // Increment rowCounter
            rowCounter ++;

        }
        return (tabList);
    }

    /////////////////////////////////////////////////////////////
    @AuraEnabled
    public static String getEmbeddedSigningUrl(String envId, String url) {

    Url mySigningUrl = dfsle.SigningService.getEmbeddedSigningUrl(
        dfsle.UUID.parse(envId), // envId value as a UUID
        new URL(url) // url value as a URL
    );
    // Url mySigningUrl = dfsle.SigningService.getRecipientPreviewUrl(
    //     dfsle.UUID.parse(envId), // envId value as a UUID
    //     1
    // );
    system.debug('url : ' + url);
    system.debug('mySigningUrl.toExternalForm() : ' + mySigningUrl.toExternalForm());
    // Return string value of Url to controller
    return mySigningUrl.toExternalForm();
    }


    //////////////////////////////////////////////////////////////

    // @AuraEnabled
    // public static void sendEnvelopeUsingAPI(Id recordId) {
    //     Id mySourceId = recordId; // The ID of the initiating Salesforce object
    //     Integer numberOfInstallments = 1;
    //     List<dfsle.Document> ListOfDocs = new List<dfsle.Document> {};   
    //     List<dfsle.Tab> tabList = new List<dfsle.Tab>();
    //     List<Case> caseList = new List<Case>();
    //     String testTemplateId = '70d1b540-ed95-422a-be32-65b2f76d9512';
    //     String managerChequeTemplateId = '52d03222-cc71-4c81-9ae6-1addf153d8f4';
    //     String loanTemplateId = '9a9c42f9-409d-41b9-96e1-bea77f78a5c3';
    //     String testDynamicTable = 'e4c4fd18-429f-4d5e-8768-882bf5ed5d46';
    //     String docuSignaccountId = '18325281';

    //     String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
    //     String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc,Account.Name, Account.Subscription_Model__pc FROM Case WHERE Id = :recordId';
    //     caseList = new List<Case>((List<Case>)Database.query(soqlQuery)); 
    //     Case cItem = caseList.get(0);

    //     // Create an envelope draft ================================================
    //     JSONGenerator jsGen = SYSTEM.JSON.createGenerator(true);
    //     jsGen.writeStartObject();  
    //         jsGen.writeStringField('templateId', testDynamicTable);
    //         jsGen.writeFieldName('templateRoles');
    //             jsGen.writeStartArray(); 
    //                 jsGen.writeStartObject(); 
    //                 jsGen.writeStringField('email', cItem.cc_Email_Address__c);  // Record Data
    //                 jsGen.writeStringField('name', cItem.cc_Full_Name__c);  // Template Document
    //                 jsGen.writeStringField('roleName', 'Contact');  // Response document type which can be XHTML, PDF, or DOCX
    //                 jsGen.writeEndObject(); 
    //             jsGen.writeEndArray(); 
    //             // jsGen.writeStringField('status', 'created');
    //     jsGen.writeEndObject();
    //     String jsonData = jsGen.getAsString();
    //     System.debug('jsonData : '+jsonData);

    //     HttpRequest req = new HttpRequest();
    //     req.setEndpoint('callout:Docusign_eSign/restapi/v2.1/accounts/'+ docuSignaccountId + '/envelopes'); // API call to DocuSign endpoint 
    //     req.setHeader('Content-Type', 'application/json');
    //     req.setMethod('POST');
    //     req.setBody(jsonData); 
    //     Http http = new Http();
    //     HTTPResponse res = http.send(req);
    //     String responseBody = res.getBody(); 
    //     System.debug('Create Draft api : '+responseBody); 

    //     Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
    //     System.debug('Create Draft api => EnvelopeId : ' + responseMap.get('envelopeId'));
    //     String EnvelopeId = (String) responseMap.get('envelopeId');
    //     // Get dynamic table fields ==========================================
    //     HttpRequest req1 = new HttpRequest();
    //     req1.setEndpoint('callout:Docusign_eSign/restapi/v2.1/accounts/'+ docuSignaccountId + '/envelopes/'+ EnvelopeId +'/docGenFormFields'); // API call to DocuSign endpoint 
    //     req1.setHeader('Content-Type', 'application/json');
    //     req1.setMethod('GET');
    //     // req1.setBody('{}'); // Grab record data and template for API call
    //     Http http1 = new Http();
    //     HTTPResponse res1 = http1.send(req1);
    //     String responseBody1 = res1.getBody(); // Generated document as base64
    //     System.debug(responseBody1); 

    // }


    public static String formatAmountEnUS(String input) {
        if (String.isBlank(input)) return input;

        // Normalize & validate
        String s = String.valueOf(Decimal.valueOf(input.trim())); // e.g. "-1000.234", "1234567", "0.5"

        // Sign
        String sign = (s.startsWith('-')) ? '-' : '';
        if (sign == '-') s = s.substring(1);

        // Split parts
        Integer dot = s.indexOf('.');
        String intPart  = (dot >= 0) ? s.substring(0, dot) : s;
        String fracPart = (dot >= 0) ? s.substring(dot + 1) : '';

        // Group thousands from the right (build by prepending to a String)
        String grouped = '';
        Integer count = 0;
        for (Integer i = intPart.length() - 1; i >= 0; i--) {
            grouped = intPart.substring(i, i + 1) + grouped;
            count++;
            if (count == 3 && i > 0) {
                grouped = ',' + grouped;
                count = 0;
            }
        }

        // Rebuild
        String outStr = sign + grouped;
        if (fracPart != '') outStr += '.' + fracPart;
        return outStr;
    }

    public static String toDDMMYYYY(String dateStr) {
        if (String.isBlank(dateStr)) return dateStr;
        Date d = Date.valueOf(dateStr.trim());   // expects "YYYY-MM-DD"
        return pad2(d.day()) + '/' + pad2(d.month()) + '/' + d.year();
    } 

    public static String formatDate(String dateStr) {
        if (String.isBlank(dateStr)) return dateStr;
        try {
            return toDDMMYYYY(dateStr.trim());
        } catch (Exception e) {
            // return original if parsing fails
            return dateStr.trim();
        }
    }

    public static String pad2(Integer n) {
        return (n < 10 ? '0' : '') + String.valueOf(n);
    }

    //#CH05 : Start
    public static HttpResponse callCalculateHoldAmountApi(Case cItem) {
        ApiConnection con = new ApiConnection();
        String regionName1 = cItem.Region_Flag__c ; 
        String customerId1 = cItem.Customer_CIF__c;
        if ( cItem.Case_Model__c == 'alburaq' ) {
            regionName1 += '_alburaq';
        }
        HttpRequest request1 = con.createRequest('POST', '/api/v1/loans/calculate-hold-amount',regionName1);
        Http http = new Http(); 
        request1.setTimeout(60000);
        if(customerId1 != null && customerId1 != ''){
            request1.setHeader('customerId', customerId1);
        }
        String body1 = '{"crmCaseId": "'+cItem.Id+ '"}';
        request1.setBody(body1);
        HttpResponse holdAmountCalculResp;
        if ( test.isRunningTest() ) {
            //fake holdAmountCalculResp 
            holdAmountCalculResp = new HttpResponse();
            body1 = '{"meta":{"code":"LOAN-3200","message":"Successfully calculate hold amount."},"data":{"holdAmount":13000}}';
            holdAmountCalculResp.setStatus('OK');    
            holdAmountCalculResp.setStatusCode(200);
            holdAmountCalculResp.setBody(body1);
            holdAmountCalculResp.setHeader('Content-Type', 'application/json');
        }else{
            holdAmountCalculResp = http.send(request1);
        }
        return holdAmountCalculResp;
    }
    //#CH05 : End
}