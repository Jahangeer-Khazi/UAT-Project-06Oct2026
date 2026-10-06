/*      Organization : ABC Bank
*      Created By: Jahangeer Mohammed
*      Created Date: 19-07-2021
*      Change History: 
*           #CH01# #Jahangeer Mohammed# Added #16-02-2022# Adding Promissory Notes for Staff.
*           #CH02# #Ashish # 20-3-2022# Added the Cash Collateral email tempates.
*           #CH03# #Hamza CHaoui # 17-06-2022# Alburaq logic
*           #CH04# #Jahangeer Mohammed# Added #04-10-2022# Added Cash Collateral Limit Increase Logic
*           #CH05# #Ashish # 13-07-2023# Added the JORDAN credit Card Docusign email tempates.
*           #CH06# #Aniss # 05-06-2024# Added the Fixed Deposit Funding Account.
*           #CH07# #Jahangeer Mohammed# Added #31-10-2024# Adding Dynamic Email Subject for Credit Card Application, Limit Increase & Cash Collateral Application
* 			 #CH08# #Jahangeer Mohammed# Added #28-01-2025# Added Logic for Credit Card Limit Split
*/
public class DocuSignApexToolKit implements Queueable, Database.AllowsCallouts{
    
    Set<Id> recordIds;
    public DocuSignApexToolKit(Set<Id> caseIdSet){
        this.recordIds = caseIdSet;
        System.debug('Case Id in Queable Class:'+recordIds);
    }
    
    public void execute(QueueableContext context){
        
        List<Case> caseList = [Select Id,cc_Full_Name__c,cc_Email_Address__c,Status, Sub_Status__c, Type, Sub_Type__c,Account.Segment__pc,Account.Nationality__pc, cc_Approved_Requested_Card_Type__c,
                               cc_CPR_Number__c,Account.Name,cc_Requested_Card_Type__c, Region_Flag__c, Customer_Language_Preference__c,Debit_Account_IBAN__c,ccol_Hold_Account__c FROM Case where Id In: recordIds];
        system.debug('DocuSignApexToolKit||sendEnvelopeMethod');
        for(Case cItem: caseList){
            Id mySourceId = cItem.Id;// The ID of the initiating Salesforce object.
            //create custom field
            //
            String caseStr = (String) cItem.Id + '~' +  cItem.Id.getSobjectType();
            dfsle.CustomField myCustomField1 = new dfsle.CustomField(
                'text', //type
                'Cas CPR Number', //##SF+Salesforce API name of the object                                                    
                mySourceId, //Id of the record                                          
                null,
                true,
                true);
            dfsle.CustomField myCustomField2 = new dfsle.CustomField('text','Cas Full Name','test name 123',null,true,true);
            dfsle.CustomField myCustomField3 = new dfsle.CustomField('text','Cas CPR Expiry Date',mySourceId,null,true,true);
            dfsle.CustomField myCustomField4 = new dfsle.CustomField('text','Cas Email',mySourceId,null,true,true);
            dfsle.CustomField myCustomField5 = new dfsle.CustomField('text','Cas Mobile Phone',mySourceId,null,true,true);
            dfsle.CustomField myCustomField6 = new dfsle.CustomField('text','Cas Nationality',mySourceId,null,true,true);
            dfsle.CustomField myCustomField7 = new dfsle.CustomField('text','Cas Birthdate',mySourceId,null,true,true);
            dfsle.CustomField myCustomField8 = new dfsle.CustomField('text','Cas Gender',mySourceId,null,true,true);
            // dfsle.CustomField myCustomField9 = new dfsle.CustomField('text','Cas Nationality',mySourceId,null,true,true);
            dfsle.CustomField myCustomField10 = new dfsle.CustomField('text','Cas iGA-Place of Birth',mySourceId,null,true,true);
            dfsle.CustomField myCustomField11 = new dfsle.CustomField('text','Cas Approved Credit Limit',mySourceId,null,true,true);
            
            dfsle.CustomField myCustomField12 = new dfsle.CustomField('text','Cas Approved Requested Card Type',mySourceId,null,true,true);
            dfsle.CustomField myCustomField13 = new dfsle.CustomField('text','Cas Marital Status',mySourceId,null,true,true);
            dfsle.CustomField myCustomField14 = new dfsle.CustomField('text','Cas Number of Dependents',mySourceId,null,true,true);
            dfsle.CustomField myCustomField15 = new dfsle.CustomField('text','Cas Academic Qualifications',mySourceId,null,true,true);
            dfsle.CustomField myCustomField16 = new dfsle.CustomField('text','Cas Residency Permit Number',mySourceId,null,true,true);
            dfsle.CustomField myCustomField17 = new dfsle.CustomField('text','Cas Number of Years at Current Residence',mySourceId,null,true,true);
            dfsle.CustomField myCustomField18 = new dfsle.CustomField('text','Cas Employer Name',mySourceId,null,true,true);
            dfsle.CustomField myCustomField19 = new dfsle.CustomField('text','Cas Employer Address',mySourceId,null,true,true);
            dfsle.CustomField myCustomField20 = new dfsle.CustomField('text','Cas Occupation',mySourceId,null,true,true);
            dfsle.CustomField myCustomField21 = new dfsle.CustomField('text','Cas Monthly Income - Actual',mySourceId,null,true,true);
            dfsle.CustomField myCustomField22 = new dfsle.CustomField('text','Cas Friend’s Name',mySourceId,null,true,true);
            dfsle.CustomField myCustomField23 = new dfsle.CustomField('text','Cas Friend’s Contact Number',mySourceId,null,true,true);
            dfsle.CustomField myCustomField24 = new dfsle.CustomField('text','Cas Passport Expiry Date',mySourceId,null,true,true);
            dfsle.CustomField myCustomField25 = new dfsle.CustomField('text','Cas Residency Permit Expiry',mySourceId,null,true,true);
            dfsle.CustomField myCustomField26 = new dfsle.CustomField('text','Cas Passport Number',mySourceId,null,true,true);
            dfsle.CustomField myCustomField27 = new dfsle.CustomField('text','Cas Home Country Telephone Number',mySourceId,null,true,true);
            dfsle.CustomField myCustomField28 = new dfsle.CustomField('text','Cas Home Address City',mySourceId,null,true,true);
            
            dfsle.CustomField myCustomField29 = new dfsle.CustomField('text','Cas Approved Balance Transfer Amount',mySourceId,null,true,true);
            dfsle.CustomField myCustomField30 = new dfsle.CustomField('text','Cas Approved Balance Transfer Card Provider',mySourceId,null,true,true);
            
            dfsle.CustomField myCustomField31 = new dfsle.CustomField('text','Cas Employment Status',mySourceId,null,true,true);
            dfsle.CustomField myCustomField32 = new dfsle.CustomField('text','Cas Home Country Address',mySourceId,null,true,true);
            dfsle.CustomField myCustomField33 = new dfsle.CustomField('text','Cas ID Expiry Date',mySourceId,null,true,true);
            dfsle.CustomField myCustomField34 = new dfsle.CustomField('text','Cas ID Number',mySourceId,null,true,true);
            dfsle.CustomField myCustomField35 = new dfsle.CustomField('text','Cas Last 4 Digit',mySourceId,null,true,true);
            dfsle.CustomField myCustomField36 = new dfsle.CustomField('text','Cas Mailing Address',mySourceId,null,true,true);
            dfsle.CustomField myCustomField37 = new dfsle.CustomField('text','Cas Monthly Income',mySourceId,null,true,true);
            dfsle.CustomField myCustomField38 = new dfsle.CustomField('text','Cas Place of Birth',mySourceId,null,true,true);
            dfsle.CustomField myCustomField39 = new dfsle.CustomField('text','Cas Mailing Street',mySourceId,null,true,true);
            dfsle.CustomField myCustomField40 = new dfsle.CustomField('text','Cas Place of birth - government',mySourceId,null,true,true);
            dfsle.CustomField myCustomField41 = new dfsle.CustomField('text','Cas Fixed Deposit Funding Account',mySourceId,null,true,true);//#CH06
            dfsle.CustomField myCustomField42 = new dfsle.CustomField('text','Cas ccol_Hold_Account',mySourceId,null,true,true);//#CH06
            
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
            
            //myTemplateId contains the DocuSign Id of the DocuSign Template
            dfsle.UUID StaffBHTemplateId = dfsle.UUID.parse(System.Label.e_SignatureTemplateId);
            
            dfsle.UUID BHNONStaff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_BH_NONStaff_ilaSwitch);
            dfsle.UUID BHNONStaff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_BH_NONStaff_ilaBlue);
            dfsle.UUID ExpatNONStaff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Expats_NONStaff_ilaSwitch);
            dfsle.UUID ExpatNONStaff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Expats_NONStaff_ilaBlue);
            
            //CH01: Start
            dfsle.UUID Staff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Staff_ilaSwitch);
            dfsle.UUID Staff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Staff_ilaBlue);
            //CH01: END
            
            //CH02: Start
            dfsle.UUID BHNONStaff_ilaBlueCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_BH_NONStaff_ilaBlue);
            dfsle.UUID BHNONStaff_ilaSwitchCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_BH_NONStaff_ilaSwitch);
            dfsle.UUID ExpatNONStaff_ilaBlueCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_Expats_NONStaff_ilaBlue);
            dfsle.UUID ExpatNONStaff_ilaSwitchCashColl_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_Expats_NONStaff_ilaSwitch);
            //CH02: END
            
            //CH05: Start
            dfsle.UUID JONONStaff_ilaBlueCC_EN_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_NONStaff_ilaBlue_EN);
            dfsle.UUID JONONStaff_ilaBlueCC_AR_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_NONStaff_ilaBlue_AR);
            dfsle.UUID JONONStaff_ilaBlueCashColl_EN_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_JO_NONStaff_ilaBlue_EN);
            dfsle.UUID JONONStaff_ilaBlueCashColl_AR_templateID = dfsle.UUID.parse(System.Label.CreditCardCashCollDoc_JO_NONStaff_ilaBlue_AR);
            dfsle.UUID JOStaff_ilaBlueCC_EN_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_Staff_ilaBlue_EN);
            dfsle.UUID JOStaff_ilaBlueCC_AR_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_JO_Staff_ilaBlue_AR);
            //CH05: END
            
            //CH08: Start
            dfsle.UUID BH_CREDIT_LIMIT_SPLIT_templateID =  dfsle.UUID.parse(System.Label.CreditCardDoc_CreditLimit_BH);
            //CH08: END
            
            dfsle.Document myDocument ;
            //create a new document for the Envelope.
            
            if(cItem.Region_Flag__c == 'Bahrain')
            {
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE -- if customer is BH : Non Staff : ila Switch ////////////////////////////////////// 
                //#CH03
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - BH');
                    //CH07: Start
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    if(cItem.Type == 'Credit Card Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    //CH07: END
                    myDocument = dfsle.Document.fromTemplate(
                        BHNONStaff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                        'Non_Staff_BH'); // name of the template
                }
                
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is BH : Non Staff : ila Blue //////////////////////////////////////
                //#CH03
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - BH');
                    //CH07: Start
                    String product = '';
                    if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        system.debug('Non Staff - BH ILA BLUE');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        system.debug('Non Staff - BH ILA WORLD');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        system.debug('Non Staff - BH ILA WORLD ELITE');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        system.debug('Non Staff - BH ILA GULF AIR');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', ' ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    
                    //CH07: END
                    myDocument = dfsle.Document.fromTemplate(
                        BHNONStaff_ilaBlue_templateID, // templateId in dfsle.UUID format
                        'Non_Staff_BH'); // name of the template
                }
                
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is Expat : Non Staff : ila Switch //////////////////////////////////////
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('NON Staff - Non BH');
                    //CH07: Start
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    if(cItem.Type == 'Credit Card Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    //CH07: END
                    myDocument = dfsle.Document.fromTemplate(
                        ExpatNONStaff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                        'NON_Staff_Non_BH'); // name of the template
                    
                }
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is Expat : Non Staff : ila Blue //////////////////////////////////////
                //#CH03
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' &&  cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('NON Staff - Non BH');
                    //CH07: Start
                    String product = '';
                    if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    
                    //CH07: END
                    myDocument = dfsle.Document.fromTemplate(
                        ExpatNONStaff_ilaBlue_templateID, // templateId in dfsle.UUID format
                        'NON_Staff_Non_BH'); // name of the template
                    
                }
                //CH01: Start    
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is BH/Expat : Staff : ila Blue //////////////////////////////////////
                
                //#CH03
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc =='Staff' /*&& cItem.Account.Nationality__pc =='BH'*/ && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Staff - BH');
                    //CH07: Start
                    String product = '';
                    if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    
                    //CH07: END
                    myDocument = dfsle.Document.fromTemplate(
                        Staff_ilaBlue_templateID, // templateId in dfsle.UUID format
                        'Staff_ilaBlue'); // name of the template.
                }
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////  
                
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is BH/Expat : Staff : ila Switch //////////////////////////////////////
                
                //#CH03
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc =='Staff' /*&& cItem.Account.Nationality__pc =='BH'*/ && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Staff - BH');
                    //CH07: Start
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    if(cItem.Type == 'Credit Card Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Limit Increase Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
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
                if(((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH'  && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - BH - Cash Collateral - ila Blue');
                    //CH07: Start
                    String product = '';
                    if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', ' ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
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
                if(((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - BH - Cash Collateral - ila Switch');
                    //CH07: Start
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    if(cItem.Type == 'Credit Card Cash Collateral Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
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
                if(((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - Expat - Cash Collateral - ila Blue');
                    //CH07: Start
                    String product = '';
                    if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Credit Card Cash Collateral Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    } 
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
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
                if(((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff'  && cItem.Account.Nationality__pc !='BH'  && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - Expat - Cash Collateral - ila Switch');
                    //CH07: Start
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    if(cItem.Type == 'Credit Card Cash Collateral Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Cash Collateral Credit Limit Increase Application'){
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_LIMIT, null);
                    }
                    //CH07: END
                    myDocument = dfsle.Document.fromTemplate(
                        ExpatNONStaff_ilaSwitchCashColl_templateID, // templateId in dfsle.UUID format
                        'Non_Staff_Expat_ilaSwitch'); // name of the template
                }
                /////////////////////////////////////////////////////////////////////////////////////////////////////////////
                //CH02: END
                //CH08: Start
                if(cItem.Type == 'Credit Card Upgrade' && cItem.Sub_Type__c == 'Credit Card Limit Split' && cItem.cc_Requested_Card_Type__c != null){
                    System.debug('Credit Card Limit Split Process');
                    String product = '';
                    if(cItem.cc_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.cc_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.cc_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.cc_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.cc_Requested_Card_Type__c == 'PLATINUM_BALANCE_TRANSFER_01'){
                        product = cItem.cc_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    myDocument = dfsle.Document.fromTemplate(
                        BH_CREDIT_LIMIT_SPLIT_templateID, // templateId in dfsle.UUID format
                        'CREDIT_LIMIT_SPLIT');
                }
                //CH08: END
                /*  ///////////////////////////////// if customer is Expat : Staff : ila Switch //////////////////////////////////////

if(cItem.Account.Segment__pc =='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01'){
system.debug('Staff - Non BH');
myDocument = dfsle.Document.fromTemplate(
StaffBHTemplateId, // templateId in dfsle.UUID format
'Staff_Non_BH'); // name of the template

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////// */
                
                /* ///////////////////////////////// if customer is Expat : Staff : ila Blue //////////////////////////////////////

if(cItem.Account.Segment__pc =='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01'){
system.debug('Staff - Non BH');
myDocument = dfsle.Document.fromTemplate(
StaffBHTemplateId, // templateId in dfsle.UUID format
'Staff_Non_BH'); // name of the template

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////// */
                
            }
            
            ///CH05: Start
            if(cItem.Region_Flag__c == 'Jordan'){
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is Non Staff : ila Blue - JORDAN - ENGLISH ////////////////////////////////////////////////////////
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.Customer_Language_Preference__c == 'English'){
                    system.debug('NON Staff - JO - Credit Card/ Limit Increase - ila Blue - ENGLISH');
                    myDocument = dfsle.Document.fromTemplate(
                        JONONStaff_ilaBlueCC_EN_templateID, // templateId in dfsle.UUID format
                        'Non_Staff_CC_EN'); // name of the template
                }
                
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is Non Staff : ila Blue - JORDAN - ARABIC //////////////////////////////////////
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc !='Staff' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.Customer_Language_Preference__c == 'Arabic'){
                    system.debug('NON Staff - JO - Credit Card/ Limit Increase - ila Blue - ARABIC');
                    myDocument = dfsle.Document.fromTemplate(JONONStaff_ilaBlueCC_AR_templateID, 'Non_Staff_CC_AR');
                }
                
                ///////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is JO Staff : ila Blue - ENGLISH //////////////////////////////////////
                
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc =='Staff'  && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.Customer_Language_Preference__c == 'English'){
                    system.debug('Staff - JO - Credit Card/ Limit Increase - ila Blue - ENGLISH');
                    myDocument = dfsle.Document.fromTemplate(JOStaff_ilaBlueCC_EN_templateID, 'Staff_EN_ilaBlue'); 
                }
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                //////////////////////////////// CREDIT CARD/ LIMIT INCREASE --  if customer is JO Staff : ila Blue - ARABIC /////////////////////////////////////////////////////////
                
                if((cItem.Type == 'Credit Card Application' || cItem.Type == 'Credit Limit Increase Application') && cItem.Account.Segment__pc =='Staff'  && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.Customer_Language_Preference__c == 'Arabic'){
                    system.debug('Staff - JO - Credit Card/ Limit Increase - ila Blue - ARABIC');
                    myDocument = dfsle.Document.fromTemplate(JOStaff_ilaBlueCC_AR_templateID,'Staff_AR_ilaBlue'); 
                }
                ///////////////////////////////////////////////////////////////////////////////////////////////////////////// //////////////////////// 
                
                ///////////////////////////////// CASH COLLATERAL/ CASH COLLATERAL LIMIT INCREASE  -- if customer is Non Staff : ila Blue - ENGLISH //////////////////////////////////////
                if(((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff'  && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.Customer_Language_Preference__c == 'English'){
                    system.debug('NON Staff - JO - Cash Collateral/ Limit Increase  - ila Blue - ENGLISH');
                    myDocument = dfsle.Document.fromTemplate(JONONStaff_ilaBlueCashColl_EN_templateID, 'Non_Staff_JO_CC_EN_ilaBlue');
                }
                ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
                ///////////////////////////////// CASH COLLATERAL / CASH COLLATERAL LIMIT INCREASE -- if customer is Non Staff : ila Blue - ARABIC //////////////////////////////////////
                if(((cItem.Type == 'Credit Card Cash Collateral Application') || (cItem.Type == 'Cash Collateral Credit Limit Increase Application')) && cItem.Account.Segment__pc !='Staff'  && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.Customer_Language_Preference__c == 'Arabic'){
                    system.debug('NON Staff - JO - Cash Collateral/ Limit Increase - ila Blue - ARABIC');
                    myDocument = dfsle.Document.fromTemplate(JONONStaff_ilaBlueCashColl_AR_templateID,'Non_Staff_JO_CC_AR_ilaBlue'); 
                }
                //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
            }   
            //CH05: END
            //add document to the Envelope
            myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument }).
                withCustomFields(new List<dfsle.CustomField> { myCustomField1,myCustomField2,myCustomField3,myCustomField4,myCustomField5,
                    myCustomField6,myCustomField7,myCustomField8,myCustomField10,myCustomField11,myCustomField12,myCustomField13,
                    myCustomField14,myCustomField15,myCustomField16,myCustomField17,myCustomField18,myCustomField19,myCustomField20,
                    myCustomField21,myCustomField22,myCustomField23,myCustomField24,myCustomField25,myCustomField26,myCustomField27,
                    myCustomField28,myCustomField29,myCustomField30,myCustomField31,myCustomField32,myCustomField33,myCustomField34,myCustomField35,myCustomField36,
                    myCustomField37,myCustomField38,myCustomField41,myCustomField42});//#CH06
            // Send the envelope.
            myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                myEnvelope, // The envelope to send
                true); // Send now?
            String varDocID = String.valueOf(myEnvelope.docuSignId);
        }
        // Retrieve the five most recent envelope statuses from the Salesforce source object.
        // The status results are sorted oldest to newest.
        /*List<dfsle.Envelope.Status> myStatus = dfsle.StatusService.getStatus(
new Set<Id> { // IDs of the Salesforce objects with associated status.
mySourceId
},
5); // Maximum number of records to return.
*/
    }
    
    
}