/**
 * @description       : This is a Controller class for aura cmp LTNG035_NewBankStatementRequest
 * @author            : ANISS MBARKI
 * @creation date     : 24-11-2023
 * History Changes :  
 *                  #CH01# : By Elmustapha Refresh Available balance in Default account when calculate fees button is clicked
 *                  #CH02# #Imane Tsioucha# #15-01-2024# add x-canary head
 *                  #CH03# #Aniss Mbarki# #15-03-2024# Bank Statement phase 2
**/
public without sharing class LTNG035_NewBankStatementReqController {

    @AuraEnabled
	public static Id getBankStatementRecordType() {
        return Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('BankStatementRequest').getRecordTypeId();
    }

    @AuraEnabled
	public static List<Object> getAccountConfigViaApi(String accountId,String caseModel) {
        ApiConnection con = new ApiConnection();
        List<Object> accList = new List<Object>();

        System.debug('===========++>  '+accountId);
        if(accountId != null && accountId != '' ){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__pc,x_canary__pc FROM Account WHERE Id=: accountId];
            System.debug('accObj===========++>  '+accObj);
            String regionName = accObj.Region_Flag__pc;
            System.debug('regionName===========++>  '+regionName);
            System.debug('caseModel===========++>  '+caseModel);
            if(caseModel == 'alburaq'){
                regionName += '_alburaq';
            }
			System.debug('regionName after===========++>  '+regionName);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = con.createRequest('GET','/api/v1/accounts/all?',regionName);
            request.setHeader('userId', accObj.PersonEmail);
            request.setHeader('customerId', accObj.CIF__pc);
			request.setTimeout(120000);
            //#CH02 : start
            if(accObj.x_canary__pc != null){
                request.setHeader('x-canary', accObj.x_canary__pc);
            }
            //#CH02 : end
            
            
            system.debug('---> Request EndPoint --> '+ request.getEndPoint() );
            system.debug('---> Request Header userId --> '+ accObj.PersonEmail );
            system.debug('---> Request Header customerId --> '+accObj.CIF__pc );
            system.debug('---> Request --> '+request.getBody());
            
            HttpResponse response = EM001_ApiCalls.callAccountListApi(request,200);
            // fake response
            /* HttpResponse response = new HttpResponse();
            String body = '{"meta":{"code":"ACCO-1000","message":"Accounts list for customer [2061256] has been retrieved successfully."},"data":{"accounts":[{"id":"BH35ABCO20612569101001","customerId":"2061256","alias":"BHD Account","productType":"account","productName":"BHD Account","category1":"","category2":"","detailsExist":true,"account":{"branch":"91084710","number":"206125691010","currency":{"code":"BHD","decimalPlaces":"3"},"iban":"BH35ABCO20612569101001","availableBalance":9222.573,"ledgerBalance":9933.573,"startDate":"2021-09-13","endDate":"2021-12-31","overdraftLimit":0.0,"overdraftExpiryDate":"2022-01-17","overdraftAvailableLimit":0.0,"paymentsAllowed":true,"status":"Active","creditInterestFrequencyCode":"200001","creditInterestFrequency":"MONTHLY","debitInterestFrequencyCode":"0","debitInterestFrequency":"N/A","creditGlAccount":"2011204","creditGlAccountDescription":"LIAB CURRENT ACCT - REGULAR","debitGlAccount":"2011204","debitGlAccountDescription":"LIAB CURRENT ACCT - REGULAR","minimumBalance":0.0,"maximumBalance":0.0,"valueBalance":9933.573,"holdAmount":711.0,"overdraftReviewDate":"1957-01-01","defaultAccount":true}}]}}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json'); */
            
            system.debug('---> Responce New --> '+response.getBody());
    
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Accounts API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> accountsList = (List<Object>)m1.get('accounts');
                for(Object accountOption : accountsList){
                    System.debug('accountOption -->'+accountOption);
                    Map<String,Object> mapAccountOption = (Map<String, Object>)accountOption;
                    accList.add(accountOption);
                }
            }
        }
        
        return accList;
    }

    @AuraEnabled
    public static void calculateFees(Id caseId){
        //THIS function should be called before creation of the new record, if it's called after the creation maybe the reults will diffrent !!

        Case caseObj = [ SELECT Id,Sub_Type__c,Customer_Segment__c,AccountId,Fee_Waiver__c,NumberOfPages__c,ac_Iban__c,Calculated_Fees__c, Case_Model__c,cc_Credit_Card_PCI_Number__c,
                         (SELECT Id FROM Bank_Statements__r) FROM Case WHERE Id =:caseId ];

        if( caseObj.NumberOfPages__c == null ){
            throw new AuraHandledException('The \'Number of Pages\' field is mandatory for calculating fees. Please ensure this field is not empty! ');
        }

        if( caseObj.Bank_Statements__r != null && caseObj.Bank_Statements__r.size()>0 ){
            throw new AuraHandledException('You cannot calculate fees for this case because a bank statement has already been created on this case record!');
        }

        List<Bank_Statement_Charges__mdt> chargersConfig = [ SELECT Id,Maximum_Charges__c,Number_of_Free_Requests_Year__c,PricePerPage__c,Segment__c,Type__c,VAT__c 
                                                       FROM Bank_Statement_Charges__mdt 
                                                       WHERE Type__c=:caseObj.Sub_Type__c AND Segment__c =: caseObj.Customer_Segment__c ];
        if(chargersConfig != null ){

            if(chargersConfig.size() == 0 ){
                throw new AuraHandledException('Bank Statement Charges Configuration not found for this case , Please contact your administrator for more infos !');
            }else{
                Bank_Statement_Charges__mdt configFees = chargersConfig.get(0);
                System.debug('**********************>>>>'+configFees);

                String ibanOrMaskedNumber; 
                if(caseObj.Sub_Type__c == 'Request Account Bank Statement'){
                    ibanOrMaskedNumber = caseObj.ac_Iban__c;
                }else{
                    ibanOrMaskedNumber = caseObj.cc_Credit_Card_PCI_Number__c;
                }
                //toDO : separate function for each subType
                Integer currentYear = System.Today().year();
                List<Bank_Statement__c> bankStatementCurrentYearList = [ SELECT Id FROM Bank_Statement__c 
                                                    WHERE Customer__c =:caseObj.AccountId AND YEAR__c =:currentYear AND Type__c =: caseObj.Sub_Type__c AND IBAN_MASKED_CARD_NO__c =: ibanOrMaskedNumber ]; 
                if( bankStatementCurrentYearList.size() >= configFees.Number_of_Free_Requests_Year__c ){
                    if(caseObj.Fee_Waiver__c == true){
                        caseObj.Calculated_Fees__c = 0;
                    }else{
                        Decimal calculFees = caseObj.NumberOfPages__c * configFees.PricePerPage__c;
                        if(calculFees > configFees.Maximum_Charges__c){
                            calculFees = configFees.Maximum_Charges__c + (configFees.Maximum_Charges__c*configFees.VAT__c/100);
                        }else{
                            calculFees = calculFees + (calculFees*configFees.VAT__c/100);
                        }
                        caseObj.Calculated_Fees__c = calculFees;
                    }
                }else{
                    caseObj.Calculated_Fees__c = 0;
                }
                // Start CH01
                List<Object> accountsList = getAccountConfigViaApi(caseObj.AccountId, caseObj.Case_Model__c);
                for (Object item : accountsList) {
                    Map<String, Object> firstElement = (Map<String, Object>) item;
                    Map<String, Object> accountDetails = (Map<String, Object>) firstElement.get('account');
                    system.debug('accountsList accountDetails--> '+accountDetails);

                    if((Boolean)accountDetails.get('defaultAccount') == true){

                        Decimal availableBalance = (Decimal) accountDetails.get('availableBalance');
                        system.debug('accountsList availableBalance--> '+availableBalance);
                        caseObj.Debit_Account_Available_Balance__c = availableBalance;
                    }
                    
                }
                
                //End CH01
                update caseObj;

            }
        }

    }


    //#CH03 : Start
    @AuraEnabled
	public static List<Object> getCCardOptionsViaApi(String accountId, String subType, String caseModel) {
        ApiConnection con = new ApiConnection();
        List<Object> ccList = new List<Object>();

        System.debug('===========++>  '+accountId);
        if(accountId != null && accountId != '' ){
            List<System_Action__c> lstSA = new List<System_Action__c>();
            Account accObj = [SELECT Id, CIF__pc,PersonEmail,Region_Flag__pc,x_canary__pc FROM Account WHERE Id=: accountId];
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
                request.setHeader('x-canary', accObj.x_canary__pc);
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
                String body = '{"meta":{"code":"CCRD-1100","message":"Card list has been retrieved successfully."},"data":{"currentCards":[{"id":"2660030003081773","cardSequenceNumber":"0001","expiryDate":"2027-04-22","cardProductionConfigurationId":2,"productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blu12e","cmsCardProductId":"003","cmsCardProductType":"01","isPrimary":true,"embossName":"Hasan Abdulla","maskedCardNumber":"511724XXXXXX1773","issueDate":"2024-04-22","provider":"Mastercard","isRequestedCard":false,"order":3000,"isDelinquent":false,"mustBeActivated":false,"isBankBlocked":false,"hasSupplementaryCardFees":false,"canRequestSupplementaryCard":false,"pendingRelease":false,"cardNature":"unsecured","supportedDigitalWallets":["APPLE_PAY"],"enabledCardActions":["SETUP_AUTOMATIC_PAYMENT","CHANGE_CREDIT_LIMIT","TRANSACTIONS_CONTROL"],"cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}],"enabledMainActions":[{"mainAction":"OFFERS","status":"SHOW_ENABLED","sortOrder":7}],"primaryCardPciNumber":"2660030003081773","applicationStatus":"","blockCode":"O","pendingRequests":[]}],"pendingCards":[{"id":"16511","cardProductConfigurationId":2,"cardType":"01","productMappingCode":"PLATINUM_CASHBACK_AND_REWARD_01","cardDisplayName":"ila Blue","cmsCardProductId":"003","cmsCardProductType":"01","status":"PENDING","order":1000,"caseId":"5007Y00000IlpWNQAZ","embossName":"MOHAMED ALBASRI","createdDate":"2021-09-26T14:45:36","modifiedDate":"2021-09-26T14:45:36","closureDate":"2021-09-26T14:45:36","creditLimit":4000.00000,"requestType":"CREDIT_CARD_ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"1"}]}],"cardOptions":[{"cardProductConfigurationId":4,"productMappingCode":"TITANIUM_CO_BRAND_01","cardDisplayName":"Titanium Gulf Air","cmsCardProductId":"005","cmsCardProductType":"01","order":2,"productStatus":"ORDER","cardConfigurations":[{"configCode":"MINIMUM_MONTHLY_INCOME","configValue":"400"},{"configCode":"MAXIMUM_SUPPLEMENTARY_CARDS","configValue":"0"}],"cardNature":["unsecured","secured"]}]}}';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(body);
            }
            
            system.debug('---> response body --> '+response.getBody());
    
            if (response.getStatusCode() != 200 ) {
                String errorMsg = 'The status code returned was not expected when we are calling Get Credit cards list API : ' + response.getStatusCode();
                System.debug(errorMsg);
                throw new AuraHandledException(errorMsg);
            }else {
                //toDo : check conditions with Ashish
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());// meta, data
                Map<String, Object> m1 = (Map<String, Object>)m.get('data');
                List<Object> currCardsList = (List<Object>)m1.get('currentCards'); //Current Cards
                for(Object currCard : currCardsList){
                    Map<String,Object> mapCurrCard = (Map<String, Object>)currCard;
                    if(mapCurrCard.get('isPrimary') == true){
                        String cardNature = (String) mapCurrCard.get('cardNature');
                        if( subType == 'Request Credit Card Bank Statement' && (cardNature == 'secured' || cardNature == 'unsecured') ){
                            ccList.add(mapCurrCard);
                        }
                        if( subType == 'Request Prepaid Card Bank Statement' && cardNature == 'prepaid' ){
                            ccList.add(mapCurrCard);
                        }
                    }
                }
            }
        }
        
        return ccList;
    }

    @InvocableMethod(label='Send Email DocuSign Consent Form' description='Send Email DocuSign consent form' callout=true )
    public static List<String> sendEmailDocuSign(List<Id> caseIds)
    {
        sendEmailDocuSignFuture(new Set<Id>(caseIds));
        return caseIds;
    }
    
    @future(callout=true)
    public static void sendEmailDocuSignFuture (Set<Id> caseIds)
    {
        List<System_Action__c> lstSA = new List<System_Action__c>();
        List<Case> cases = new List<Case>();
        if (caseIds != null && caseIds.size() > 0) {
            String fields = DM000_sObjectDescriber.constructFieldListForQueryFrom('Case');
            
            String soqlQuery = 'SELECT ' + fields + ',Account.PersonEmail,Account.CIF__pc,Account.Region_Flag__pc FROM Case WHERE Id IN :caseIds';
            cases = new List<Case>((List<Case>)Database.query(soqlQuery));
        }

        for(Case cItem : cases){
            try {

                Id mySourceId = cItem.Id;// The ID of the initiating Salesforce object.
                
                // Create an empty envelope.
                dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                    new dfsle.Entity(mySourceId));
                // The initiating Salesforce entity.

                //use the Recipient.fromSource method to create the Recipient
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                    cItem.cc_Full_Name__c, // Recipient name
                    cItem.cc_Email_Address__c, // Recipient email
                    null, //Optional phone number
                    'Contact', //Role Name. Specify the exact role name from template
                    new dfsle.Entity(cItem.Id)); //source object for the Recipient.
                
                //add Recipient to the Envelope
                myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });

                dfsle.CustomField myCustomField = new dfsle.CustomField('text','CAS CIF',mySourceId,null,true,true);
                dfsle.CustomField myCustomField1 = new dfsle.CustomField('text','CAS CreatedDate',mySourceId,null,true,true);
                dfsle.CustomField myCustomField2 = new dfsle.CustomField('text','CAS Currency',mySourceId,null,true,true);
                dfsle.CustomField myCustomField3 = new dfsle.CustomField('text','CAS CustomerName',mySourceId,null,true,true);
                dfsle.CustomField myCustomField4 = new dfsle.CustomField('text','CAS FromDate',mySourceId,null,true,true);
                dfsle.CustomField myCustomField5 = new dfsle.CustomField('text','CAS ToDate',mySourceId,null,true,true);
                dfsle.CustomField myCustomField6 = new dfsle.CustomField('text','CAS PrimaryIBAN',mySourceId,null,true,true);
                dfsle.CustomField myCustomField7 = new dfsle.CustomField('text','CAS IBAN',mySourceId,null,true,true);
                dfsle.CustomField myCustomField8 = new dfsle.CustomField('text','CAS MaskedCardNumber',mySourceId,null,true,true);

                String templateID;
                String templateName;
                List<dfsle.CustomField> customFields;

                if(cItem.Sub_Type__c == 'Request Account Bank Statement'){
                    if (cItem.Case_Model__c != 'alburaq') {
                        templateID = System.Label.BankStatementDocuSign_BH; //for ila scenario
                        templateName = 'ila_BankAccountStatement_RequestForm_v.10';
                    }else {
                        templateID = System.Label.BankStatementDocuSign_BH_alburaq; //alburaq account request scenario : 
                        templateName = 'alburaq_BankAccountStatement_RequestForm_v.10';
                    }
                    customFields = new List<dfsle.CustomField> { myCustomField,myCustomField1,myCustomField2,myCustomField3,myCustomField4,myCustomField5,myCustomField6,myCustomField7};
                }else{
                    templateID = System.Label.BankStatementDocuSign_BH_cc_OR_pp; //ila cc/pp request : 
                    templateName = 'ila_BankCCStatement_RequestForm_v.10'; //toDo : ...
                    customFields = new List<dfsle.CustomField> { myCustomField,myCustomField1,myCustomField2,myCustomField3,myCustomField4,myCustomField5,myCustomField8};
                }

                //myTemplateId contains the DocuSign Id of the DocuSign Template
                dfsle.UUID BankStatementDocuSign_templateID = dfsle.UUID.parse(templateID);

                Map<String, Map<String, Object>> envelopeEventUpdates= new Map<String, Map<String, Object>> {
                    dfsle.Envelope.STATUS_COMPLETED => new Map<String, Object> {
                        'Waiting_for_customer_feedback__c' => false
                    }
                };
                // Define document write-back options
                dfsle.Document.WriteBack documentWriteBack = new dfsle.Document.WriteBack(
                    // Where to link the completed document(s)
                    mySourceId,
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

                dfsle.Document myDocument ;
                //create a new document for the Envelope.
                myDocument = dfsle.Document.fromTemplate(
                    BankStatementDocuSign_templateID, // templateId in dfsle.UUID format
                    templateName);

                //add document to the Envelope
                myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument }).
                    withCustomFields(customFields).withOptions(options);
                // Send the envelope.
                myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                    myEnvelope, // The envelope to send
                    true); 
                
                cItem.Waiting_for_customer_feedback__c = true;
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                lstSA.add(SM001_ApiCalls.setSystemAction( null,'Error Message : ' +e.getMessage()+'; Trace : '+String.valueOf(e.getStackTraceString()),
                                                         null,null,
                                                         cItem.id,cItem.Customer_CIF__c,cItem.accountId,null, 
                                                         cItem.Type+' Send Email DocuSign Consent Form (unhandled error)', cItem.Sub_Type__c
                                                        ));
                cItem.Last_Api_Call_Status__c = 'Failed';
            }

        }

        if(cases != null && cases.size()>0){
            update cases;
        }

        if(lstSA != null && lstSA.size()>0){
            insert lstSA;
        }
    }
    //#CH03 : End

}