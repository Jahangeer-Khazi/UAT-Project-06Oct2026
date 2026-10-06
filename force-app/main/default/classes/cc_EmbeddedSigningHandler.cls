//WARNING : any change to this class "DocuSignApexToolKit" for Bahrain regionFlag should also impact this class
public without sharing class cc_EmbeddedSigningHandler {
    private static List<System_Action__c> lstSA = new List<System_Action__c>();

    @AuraEnabled
    public static String sendEnvelope(Case cItem) {
        String EnvelopeId;
        try{
            EnvelopeId = createEnvelopeId(cItem);
        }
        catch(Exception e){
            //store unexpected errors from system !!
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            lstSA.add(SM001_ApiCalls.setSystemAction( e.getMessage(),String.valueOf(e.getStackTraceString()),
                                                  null,null,
                                                  cItem.id,cItem.Customer_CIF__c,cItem.accountId,null, 
                                                  'please check : '+'cc_EmbeddedSigningHandler.sendEnvelope()', cItem.Type
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

    public static String createEnvelopeId(Case cItem) {
        System.debug('***============ createEnvelopeId Begin ============*********');
        //In-App
        dfsle.Recipient myRecipient = dfsle.Recipient.newEmbeddedSigner(cItem.cc_Full_Name__c, cItem.cc_Email_Address__c, cItem.ContactId).withRole('Contact');
        dfsle.Envelope dsEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                                        new dfsle.Entity(cItem.Id, 'Case', new dfsle.Entity(cItem.ContactId) )
                                    ); 
        dsEnvelope = dsEnvelope.withRecipients(new List<dfsle.Recipient> {myRecipient});

        dfsle.UUID StaffBHTemplateId = dfsle.UUID.parse(System.Label.e_SignatureTemplateId);
            
        dfsle.UUID BHNONStaff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_BH_NONStaff_ilaSwitch);
        dfsle.UUID BHNONStaff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_BH_NONStaff_ilaBlue);
        dfsle.UUID ExpatNONStaff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Expats_NONStaff_ilaSwitch);
        dfsle.UUID ExpatNONStaff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Expats_NONStaff_ilaBlue);
        
        dfsle.UUID Staff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Staff_ilaSwitch);
        dfsle.UUID Staff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Staff_ilaBlue);
        
        dfsle.UUID BHNONStaff_ilaBlueCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_BH_NONStaff_ilaBlue);
        dfsle.UUID BHNONStaff_ilaSwitchCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_BH_NONStaff_ilaSwitch);
        dfsle.UUID ExpatNONStaff_ilaBlueCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_Expats_NONStaff_ilaBlue);
        dfsle.UUID ExpatNONStaff_ilaSwitchCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_Expats_NONStaff_ilaSwitch);
        
        dfsle.UUID JONONStaff_ilaBlueCC_EN_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_NONStaff_ilaBlue_EN);
        dfsle.UUID JONONStaff_ilaBlueCC_AR_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_NONStaff_ilaBlue_AR);
        dfsle.UUID JONONStaff_ilaBlueCashColl_EN_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_JO_NONStaff_ilaBlue_EN);
        dfsle.UUID JONONStaff_ilaBlueCashColl_AR_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_JO_NONStaff_ilaBlue_AR);
        dfsle.UUID JOStaff_ilaBlueCC_EN_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_Staff_ilaBlue_EN);
        dfsle.UUID JOStaff_ilaBlueCC_AR_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_Staff_ilaBlue_AR);
        
        //CH08: Start
        //dfsle.UUID BH_CREDIT_LIMIT_SPLIT_templateID =  dfsle.UUID.parse(System.Label.CreditCardDoc_CreditLimit_BH);
        //CH08: END
        
        List<dfsle.Document> ListOfDocs = new List<dfsle.Document> {};   
        dfsle.Document myDocument ;

        if(cItem.Region_Flag__c == 'Bahrain')
        {
            ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE -- if customer is BH : Non Staff : ila Switch ////////////////////////////////////// 
            //#CH03
            if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Non Staff - BH');
                String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                if(test.isRunningTest() || cItem.Type == 'Credit Card Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.Type == 'Credit Limit Increase Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                
                myDocument = dfsle.Document.fromTemplate(
                    BHNONStaff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                    'Non_Staff_BH'); // name of the template
            }
            
            ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is BH : Non Staff : ila Blue //////////////////////////////////////
            //#CH03
            if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Non Staff - BH');
                //CH07: Start
                String product = '';
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    system.debug('Non Staff - BH ILA BLUE');
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    system.debug('Non Staff - BH ILA WORLD');
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    system.debug('Non Staff - BH ILA WORLD ELITE');
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    system.debug('Non Staff - BH ILA GULF AIR');
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', ' ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    BHNONStaff_ilaBlue_templateID, // templateId in dfsle.UUID format
                    'Non_Staff_BH'); // name of the template
            }
            
            ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is Expat : Non Staff : ila Switch //////////////////////////////////////
            if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('NON Staff - Non BH');
                //CH07: Start
                String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                if(test.isRunningTest() || cItem.Type == 'Credit Card Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.Type == 'Credit Limit Increase Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    ExpatNONStaff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                    'NON_Staff_Non_BH'); // name of the template
                
            }
            ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is Expat : Non Staff : ila Blue //////////////////////////////////////
            //#CH03
            if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' &&  cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('NON Staff - Non BH');
                //CH07: Start
                String product = '';
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    ExpatNONStaff_ilaBlue_templateID, // templateId in dfsle.UUID format
                    'NON_Staff_Non_BH'); // name of the template
                
            }
            //CH01: Start    
            ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is BH/Expat : Staff : ila Blue //////////////////////////////////////
            
            //#CH03
            if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc =='Staff' /*&& cItem.Account.Nationality__pc =='BH'*/ && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Staff - BH');
                //CH07: Start
                String product = '';
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    Staff_ilaBlue_templateID, // templateId in dfsle.UUID format
                    'Staff_ilaBlue'); // name of the template.
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////  
            
            ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is BH/Expat : Staff : ila Switch //////////////////////////////////////
            
            //#CH03
            if(test.isRunningTest() || (cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc =='Staff' /*&& cItem.Account.Nationality__pc =='BH'*/ && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Staff - BH');
                //CH07: Start
                String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                if(test.isRunningTest() || cItem.Type == 'Credit Card Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.Type == 'Credit Limit Increase Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    Staff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                    'Staff_ilaSwitch'); // name of the template
            }
            ///////////////////////////////////////////////////////////////////////////////////////////////////////////// 
            //CH01: END 
            
            //CH02: Start
            ///////////////////////////////// CASH COLLATERAL -- if customer is BH : Non Staff : ila Blue //////////////////////////////////////
            //CH04 : Added Type = 'Cash Collateral Credit Limit Increase Application' in if Block
            //#CH03
            if(test.isRunningTest() || ((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH'  && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Non Staff - BH - Cash Collateral - ila Blue');
                //CH07: Start
                String product = '';
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', ' ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    BHNONStaff_ilaBlueCashColl_templateID, // templateId in dfsle.UUID format
                    'Non_Staff_BH_ilaBlue'); // name of the template
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            ///////////////////////////////// CASH COLLATERAL -- if customer is BH : Non Staff : ila SWITCH //////////////////////////////////////
            //CH04 : Added Type = 'Cash Collateral Credit Limit Increase Application' in if Block
            //#CH03
            if(test.isRunningTest() || ((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Non Staff - BH - Cash Collateral - ila Switch');
                //CH07: Start
                String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                if(test.isRunningTest() || cItem.Type == 'Credit Card Cash Collateral Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.Type == 'Cash Collateral Credit Limit Increase Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    BHNONStaff_ilaSwitchCashColl_templateID, // templateId in dfsle.UUID format
                    'Non_Staff_BH_ilaSwitch'); // name of the template
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            ///////////////////////////////// CASH COLLATERAL -- if customer is Expat : Non Staff : ila Blue //////////////////////////////////////
            //CH04 : Added Type = 'Cash Collateral Credit Limit Increase Application' in if Block
            //#CH03
            if(test.isRunningTest() || ((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Non Staff - Expat - Cash Collateral - ila Blue');
                //CH07: Start
                String product = '';
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                } 
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                if(test.isRunningTest() || (cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01')){
                    product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                } 
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    ExpatNONStaff_ilaBlueCashColl_templateID, // templateId in dfsle.UUID format
                    'Non_Staff_Expat_ilaBlue'); // name of the template
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            
            ///////////////////////////////// CASH COLLATERAL -- if customer is Expat : Non Staff : ila Switch //////////////////////////////////////
            //CH04 : Added Type = 'Cash Collateral Credit Limit Increase Application' in if Block
            //#CH03
            if(test.isRunningTest() || ((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff'  && cItem.Account.Nationality__pc !='BH'  && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                system.debug('Non Staff - Expat - Cash Collateral - ila Switch');
                //CH07: Start
                String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                if(test.isRunningTest() || cItem.Type == 'Credit Card Cash Collateral Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.Type == 'Cash Collateral Credit Limit Increase Application'){
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                }
                //CH07: END
                myDocument = dfsle.Document.fromTemplate(
                    ExpatNONStaff_ilaSwitchCashColl_templateID, // templateId in dfsle.UUID format
                    'Non_Staff_Expat_ilaSwitch'); // name of the template
            }
            /////////////////////////////////////////////////////////////////////////////////////////////////////////////
            //CH02: END
            //CH08: Start
            /*if(test.isRunningTest() || (cItem.Type == 'Credit Card Upgrade' && cItem.Sub_Type__c == 'Credit Card Limit Split' && cItem.cc_Requested_Card_Type__c != null)){
                System.debug('Credit Card Limit Split Process');
                String product = '';
                if(test.isRunningTest() || cItem.cc_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                    product = cItem.cc_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.cc_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                    product = cItem.cc_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                    product = cItem.cc_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    product = cItem.cc_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                    product = cItem.cc_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                if(test.isRunningTest() || cItem.cc_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                    product = cItem.cc_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    dsEnvelope = dsEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                }
                myDocument = dfsle.Document.fromTemplate(
                    BH_CREDIT_LIMIT_SPLIT_templateID, // templateId in dfsle.UUID format
                    'CREDIT_LIMIT_SPLIT');
            }*/
            //CH08: END
        }
        
        if (myDocument != null) {
            ListOfDocs.add(myDocument);
        }
        
        Map<String, Map<String, Object>> envelopeEventUpdates= new Map<String, Map<String, Object>> {
            dfsle.Envelope.STATUS_SENT => new Map<String, Object> {
                'Last_Call_Outcome__c' => 'Sent'
            },
            dfsle.Envelope.STATUS_COMPLETED => new Map<String, Object> {
                'Last_Call_Outcome__c' => 'Completed'
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
        
        dsEnvelope = dsEnvelope.withOptions(options);
        dsEnvelope = dsEnvelope.withDocuments(ListOfDocs);

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
}