public class ConvertCreditCardDocusignTemplates implements Queueable, Database.AllowsCallouts{
    Set<Id> recordIds;
    public ConvertCreditCardDocusignTemplates(Set<Id> caseIdSet){
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
            dfsle.CustomField myCustomField2 = new dfsle.CustomField('text','Cas Full Name',mySourceId,null,true,true);
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
            
           
            dfsle.UUID Staff_ilaSwitch_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Staff_ilaSwitch);
            dfsle.UUID Staff_ilaBlue_templateID = dfsle.UUID.parse(System.Label.CreditCardDoc_Staff_ilaBlue);
            
            
           
            
            dfsle.Document myDocument ;
            //create a new document for the Envelope.
            
            if(cItem.Region_Flag__c == 'Bahrain')
            {
                ///////////////////////////////// CONVERT CREDIT CARD -- if customer is BH : Non Staff : ila Switch ////////////////////////////////////// 
                if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - BH');
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    
                    myDocument = dfsle.Document.fromTemplate(
                        BHNONStaff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                        'Non_Staff_BH'); // name of the template
                }
                
                ///////////////////////////////// CONVERT CREDIT CARD --  if customer is BH : Non Staff : ila Blue //////////////////////////////////////
                if(cItem.Type == 'Convert Credit Card Nature Application'  && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc =='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('Non Staff - BH');
                    String product = '';
                    if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        system.debug('Non Staff - BH ILA BLUE');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        system.debug('Non Staff - BH ILA WORLD');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        system.debug('Non Staff - BH ILA WORLD ELITE');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        system.debug('Non Staff - BH ILA GULF AIR');
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', ' ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    myDocument = dfsle.Document.fromTemplate(
                        BHNONStaff_ilaBlue_templateID, // templateId in dfsle.UUID format
                        'Non_Staff_BH'); // name of the template
                }
                
                ///////////////////////////////// CONVERT CREDIT CARD --  if customer is Expat : Non Staff : ila Switch //////////////////////////////////////
                if(cItem.Type == 'Convert Credit Card Nature Application'  && cItem.Account.Segment__pc !='Staff' && cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c =='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('NON Staff - Non BH');
                    String product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_BALANCE_TRANSFER_01', 'ila Switch');
                    myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    myDocument = dfsle.Document.fromTemplate(
                        ExpatNONStaff_ilaSwitch_templateID, // templateId in dfsle.UUID format
                        'NON_Staff_Non_BH'); // name of the template
                    
                }
                ///////////////////////////////// CONVERT CREDIT CARD --  if customer is Expat : Non Staff : ila Blue //////////////////////////////////////
                if(cItem.Type == 'Convert Credit Card Nature Application'  && cItem.Account.Segment__pc !='Staff' &&  cItem.Account.Nationality__pc !='BH' && cItem.cc_Approved_Requested_Card_Type__c !='PLATINUM_BALANCE_TRANSFER_01' && cItem.cc_Approved_Requested_Card_Type__c != null){
                    system.debug('NON Staff - Non BH');
                    String product = '';
                    if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'PLATINUM_CASHBACK_AND_REWARD_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('PLATINUM_CASHBACK_AND_REWARD_01', 'ila Blue');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_CASHBACK_AND_REWARDS_01', 'ila World');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'WORLD_ELITE_CASHBACK_AND_REWARDS_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('WORLD_ELITE_CASHBACK_AND_REWARDS_01', 'ila World Elite');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    else if(cItem.Type == 'Convert Credit Card Nature Application' && cItem.cc_Approved_Requested_Card_Type__c == 'ILA_GULF_AIR_COBRAND_01'){
                        product = cItem.cc_Approved_Requested_Card_Type__c.replace('ILA_GULF_AIR_COBRAND_01', 'ila Gulf Air');
                        myEnvelope = myEnvelope.withEmail(System.Label.CREDIT_CARD_GENERIC_SUBJECT + ' ' + product + ' ' +System.Label.CREDIT_CARD_NEW, null);
                    }
                    myDocument = dfsle.Document.fromTemplate(
                        ExpatNONStaff_ilaBlue_templateID, // templateId in dfsle.UUID format
                        'NON_Staff_Non_BH'); // name of the template
                    
                }
            }
            //add document to the Envelope
            myEnvelope = myEnvelope.withDocuments(new List<dfsle.Document> { myDocument }).
                withCustomFields(new List<dfsle.CustomField> { myCustomField1,myCustomField2,myCustomField3,myCustomField4,myCustomField5,
                    myCustomField6,myCustomField7,myCustomField8,myCustomField10,myCustomField11,myCustomField12,myCustomField13,
                    myCustomField14,myCustomField15,myCustomField16,myCustomField17,myCustomField18,myCustomField19,myCustomField20,
                    myCustomField21,myCustomField22,myCustomField23,myCustomField24,myCustomField25,myCustomField26,myCustomField27,
                    myCustomField28,myCustomField29,myCustomField30,myCustomField31,myCustomField32,myCustomField33,myCustomField34,myCustomField35,myCustomField36,
                    myCustomField37,myCustomField38,myCustomField41,myCustomField42});
            // Send the envelope.
            myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                myEnvelope, // The envelope to send
                true); // Send now?
            String varDocID = String.valueOf(myEnvelope.docuSignId);
        }
        
    }

}