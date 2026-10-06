/**
 * @description       : This class is the controller for RelativesForm.page It will contains all the logic regarding PLA with linked accounts.
 * @author            : ismael.ocana
 * @group             :
 * @last modified on  : 26/10/2021
 * @last modified by  : ismael.ocana
 * @history           : #CH01 : Aniss Mbarki NBA-9970 PLA - Relatives Declaration - CRM Changes  
 *                      #CH02 : Aniss Mbarki NBA-12883 Al Kanz - Introducing Al Kanz for Staff - Changes to Staff Declaration Form  
 *                      #CH03 : Aniss Mbarki NBA-13089 [JO] PLA - Introducing Al Kanz Prizes for Staff & Relatives - Handling of Relative Lifecycle  
 *                      #CH04 : Aniss Mbarki NBA-16859 CRM Enhancement – Relatives Declaration Form – CPR ID as the Primary Identifier  
**/
public without sharing class RelativesFormController {

    public Contact userContact {get;set;}
    public String accountId;
    public String otpUser {get;set;}
    public String staffIdUser {get;set;}

    public Boolean renderLogin{get;set;}
    public Boolean showForm{get;set;}
    public Boolean isContractor{get;set;}
    public Boolean isStaff{get;set;}
    public Boolean immediateRelative{get;set;}
    public Boolean plaStaffRelative;
    public Date joinDate{get;set;}
    public Date exitDate{get;set;}
    public String employmentType{get;set;}

    public List<TableWrapper> linkAccList {get;set;}
    public Map<String, String> inactiveLAsMapByIdNumber{get;set;}

    //aniss add
    public Map<String, String> inactiveLAsMapByMobileNumber{get;set;}

    public TableWrapper selectedWrapper {get;set;}
    public Map<String, TableWrapper> mapLinkAcc{get;set;}

    public Integer listSize {get;set;}
    public Boolean showSuccessUser{get;set;}
    public Boolean showSuccess{get;set;}
    public String successMessage{get;set;}
    public String successMessageUser{get;set;}
    public Boolean showErrorForm{get;set;}
    public String errorMessageForm{get;set;}
    public String leadRecordType;
    public String otpSelected{get;set;}
    public String regionFlag {get;set;}//#CH02

    public RelativesFormController() {

        this.renderLogin = true;
        this.showForm = false;
        this.isContractor = false;
        this.isStaff = false;
        this.userContact = new Contact(OTP__c = null);
        this.linkAccList = new List<TableWrapper>();
        this.selectedWrapper = new TableWrapper(null);
        this.mapLinkAcc = new Map<String,TableWrapper>();
        this.inactiveLAsMapByIdNumber = new Map<String,String>();
        this.inactiveLAsMapByMobileNumber = new Map<String,String>();
        this.listSize = this.linkAccList.size();
        this.employmentType = '';
        this.showSuccess = false;
        this.showSuccessUser = false;
        this.immediateRelative=false;
        this.plaStaffRelative=false;
        this.showErrorForm = false;
        this.leadRecordType = this.getLeadRecordType();
    }


    /**
    * @description Return Relative Id record type
    * @author ismael.ocana | 15/10/2021
    * @return String
    **/
    private String getLeadRecordType(){

        Map<String, Schema.RecordTypeInfo> leadRTInfos = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName();
        Id leadRT = leadRTInfos.get('Relative').getRecordTypeId();
        return (String)leadRT;
    }

    /**
    * @description It will query for the right user and prepare the whole data
    * @author ismael.ocana | 13/10/2021
    **/
    public void saveLogin(){

        String failMessage = '';
        try{
            system.debug('this.otpUser==>'+this.otpUser);
            system.debug('staffIdUser-->'+this.staffIdUser);
            //#CH01 : add Region_Flag__c
            //#CH03 : add PLA_Eligibility__c,PLA_Ineligibility_Reason__c
            Contact [] conListOTP = [SELECT ID, Name, Date_of_Joining__c, Date_of_Exit__c,No_Immediate_Relative__c,PLA_Staff_Relative_declaration_done__c,OTP__c, Staff_Id__c, ID_Number__c,
                                        Marital_Status__c, Employment_Type__c, FirstName, LastName,Region_Flag__c,PLA_Eligibility__c,PLA_Ineligibility_Reason__c
                                            FROM Contact WHERE ID_number__c =: this.otpUser];
            system.debug('conListOTP.size()-->'+conListOTP.size());
            Contact [] conListStaff = [SELECT ID, Name, AccountId, Staff_ID__c,No_Immediate_Relative__c,PLA_Staff_Relative_declaration_done__c FROM Contact WHERE Staff_ID__c =: this.staffIdUser];
            system.debug('conListStaff==>'+conListStaff.size());
            //We have just one contact with this OTP and STAFF ID
            if(conListOTP.size() == conListStaff.size() && conListStaff.size() == 1){
                if(conListOTP.get(0).Id == conListStaff.get(0).Id){
                    system.debug('region flag ==>'+conListOTP.get(0).Region_Flag__c);
                    this.renderLogin = false;
                    this.showForm = true;
                    this.userContact = conListOTP.get(0);
                    this.otpSelected = conListOTP.get(0).ID_Number__c;
                    this.accountId = conListStaff.get(0).AccountId;
                    this.employmentType = this.userContact.Employment_Type__c;
                    this.immediateRelative=this.userContact.No_Immediate_Relative__c;
                    this.plaStaffRelative=this.userContact.PLA_Staff_Relative_declaration_done__c;
                    this.isStaff = this.userContact.Employment_Type__c == 'Staff';
                    this.isContractor = this.userContact.Employment_Type__c == 'Contractor';
                    this.getLinkedAccounts(this.accountId);
                    this.joinDate = this.userContact.Date_of_joining__c;
                    this.regionFlag = this.userContact.Region_Flag__c ;//#CH02
                }
                else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Credentials not found.'));
                }
            } else{
                if(conListOTP.size() == 0){
                    failMessage = System.label.OTP_NOT_FOUND + ' ';
                }
                if(conListOTP.size() > 1){
                    failMessage = System.label.OTP_FOUND_DUPLICATED + ' ';
                }
                if(conListStaff.size() == 0){
                    failMessage += System.label.STAFF_ID_NOT_FOUND + ' ';
                }
                if(conListStaff.size() > 1){
                    failMessage += System.label.STAFF_ID_FOUND_DUPLICATED + ' ';
                }
                //More than one user found, show error
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, failMessage));
            }
        } catch (Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }

    /**
    * @description It will fill the data structures regarding Linked accounts.
    * @author ismael.ocana | 13/10/2021
    * @param String accountId
    **/
    private void getLinkedAccounts(String accountId){

        List<TableWrapper> formList = new List<TableWrapper>();
        TableWrapper tw;

        for(Linked_Account__c la : [SELECT ID,Relationship__c, Relationship_Date_Added__c, Relationship_Date_Removed__c , Relative_Customer__r.Name, Relative__r.Name,
                                        Relative_Customer__r.ID_Number__pc, Relative__r.ID_Number__c, Linked_Account__c, Active__c,Staff_ID__c,ID_Number__c,Existing_ila_Customer__c,Mobile_Country_Code__c,Mobile__c,Relative_Customer__r.Mobile_Phone_Check__pc,Relative__r.sys_Mobile_Number__c,First_Name__c,Last_Name__c,CustomerKanz__c,StaffRelativesKanz__c//#CH02
                                            FROM Linked_Account__c WHERE Linked_Account__c =: accountId AND Active__c = true AND isDeleted = false ORDER BY Relationship_Date_Added__c]){
            //If it's active we store it in the active LAs map
            if(la.Active__c){
                tw = generateTableWrapper(la);
                this.mapLinkAcc.put(tw.id, tw);
            } 
            /*else {//#CH03
                tw = generateTableWrapper(la);
                this.inactiveLAsMapByIdNumber.put(tw.idNumber, tw.la.Id);
                this.inactiveLAsMapByMobileNumber.put(la.Mobile_Country_Code__c+la.Mobile__c, tw.la.Id);
            }*/
        }
        //If there isn't rows we show one
        if(this.mapLinkAcc.isEmpty()){
            this.addRow();
        }
        this.linkAccList = this.mapLinkAcc.values();
        this.listSize = this.linkAccList.size();
    }

    /**
    * @description It will return the related Wrapper object to store the LAs
    * @author ismael.ocana | 13/10/2021
    * @param Linked_Account__c la
    * @return TableWrapper
    **/
    private TableWrapper generateTableWrapper(Linked_Account__c la){

        TableWrapper tw = new TableWrapper(
            la,
            la.Relative_Customer__r.ID_Number__pc != null ? la.Relative_Customer__r.ID_Number__pc : la.Relative__r.ID_Number__c,
            la.Relationship_Date_Added__c != null ? la.Relationship_Date_Added__c : System.now(),
            la.Relationship_Date_Removed__c
            );
        return tw;
    }

    /**
    * @description It will save the contact information
    * @author ismael.ocana | 13/10/2021
    **/
    public void saveContact(){

        this.showSuccessUser = false;
        try{
            if(this.joinDate != null){
                this.userContact.Date_of_joining__c = this.joinDate;
            }
            if(this.exitDate != null){
                this.userContact.Date_of_exit__c = this.exitDate;
            }
             if(this.immediateRelative != this.userContact.No_Immediate_Relative__c){
                this.userContact.No_Immediate_Relative__c = this.immediateRelative;
            }
            if(this.plaStaffRelative!=null && this.plaStaffRelative!=this.userContact.PLA_Staff_Relative_declaration_done__c){
                this.userContact.PLA_Staff_Relative_declaration_done__c=this.plaStaffRelative;
            }
            update this.userContact;
            this.showSuccessUser = true;
            this.successMessageUser = System.label.USER_UPDATED_CORRECT;
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }


    /**
    * @description It will add a new row to the list and map
    * @author ismael.ocana | 13/10/2021
    **/
    public void addRow(){
        //#CH01-start : country code & regionFlag
        String countryCode;
        String customerKanz;//#CH02
        if(this.userContact.Region_Flag__c == 'Bahrain'){
            //countryCode = '+973';//#CH04
            customerKanz = 'Excluded';//#CH02
        }else if(this.userContact.Region_Flag__c == 'Jordan'){
            countryCode = '+962';
        }
        TableWrapper fm = new TableWrapper(new Linked_Account__c(Linked_Account__c = this.AccountId, Mobile_Country_Code__c = countryCode,CustomerKanz__c = customerKanz));//#CH02
        //#CH01-end
        this.mapLinkAcc.put(fm.id, fm);
        this.linkAccList = this.mapLinkAcc.values();
        this.listSize = this.linkAccList.size();
    }

    /**
    * @description It will save the rows.
    * If there's a Linked account inactive related to the idNumber it will activate it.
    * If there's not a Lead or a Person Account related to the ID Number it will create a Lead.
    * If there's a related Lead or Person Account it will create an Active Linked Account.
    * @author ismael.ocana | 13/10/2021
    **/
    public void saveRowAction(){
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Account> accsToUpdate = new List<Account>();
        List<Account> accsToUpdateEligibility = new List<Account>();
        this.showSuccess = false;
        this.showErrorForm = false;
        
        //Boolean duplicatedIdNumber = false;
        Set<String> idNumbers = new Set<String>();
        Map<String, String> relatedIdByIdNumber = new Map<String, String>();
        Map<String, TableWrapper> twByIdNumber = new Map<String, TableWrapper>();
        
        //aniss -start
        Set<String> mobileNumbers = new Set<String>();
        Boolean duplicatedMobileNumber = false;
        Map<String, String> relatedIdByMobileNumber = new Map<String, String>();
        Map<String, TableWrapper> twByMobileNumber = new Map<String, TableWrapper>();
        //end

        Savepoint sp = Database.setSavepoint();

        //iterate though the wrapper
        for(TableWrapper tw : linkAccList){

            String mobNum = tw.la.Mobile_Country_Code__c + tw.la.Mobile__c;

            //check if it's blank
            if( (String.isNotBlank(tw.la.Mobile_Country_Code__c) && String.isNotBlank(tw.la.Mobile__c)) || String.isNotBlank(tw.la.ID_Number__c) ){

                if(String.isNotBlank(tw.la.Mobile__c)){
                    //check if duplicated
                    if(mobileNumbers.contains(mobNum) && this.regionFlag == 'Jordan'){//#CH04 : add {&& this.regionFlag == 'Jordan'}
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.MOBILE_NUMBER_DUPLICATED));
                        //duplicatedIdNumber = true;
                        duplicatedMobileNumber = true;
                        this.showErrorForm = true;
                        this.errorMessageForm = System.label.MOBILE_NUMBER_DUPLICATED + ' : ' + mobNum;
                        //stop the for
                        break;
                    }
    
                    //aniss -start
                    if(tw.isEdit && tw.mobileConcat != mobNum && this.regionFlag == 'Jordan'){//#CH04 : add {&& this.regionFlag == 'Jordan'}
                        this.showErrorForm = true;
                        this.showSuccess = false;
                        this.errorMessageForm = 'The Mobile Number cannot be changed. Please delete this entry and create a new one.';
                        //stop the for
                        break;
                    }
                    //end
    
                    //twByIdNumber.put(tw.idNumber, tw);
                    //idNumbers.add(tw.idNumber);
                    twByMobileNumber.put(mobNum, tw);
                    mobileNumbers.add(mobNum);
                }

                if(String.isNotBlank(tw.la.ID_Number__c)){
                    //#CH04 : Start
                    //check if duplicated
                    if(idNumbers.contains(tw.la.ID_Number__c) && this.regionFlag != 'Jordan'){
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.label.MOBILE_NUMBER_DUPLICATED));
                        this.showErrorForm = true;
                        this.errorMessageForm = 'CPR Number is duplicated : ' + tw.la.ID_Number__c;
                        //stop the for
                        break;
                    }
                    //#CH04 : End

                    twByIdNumber.put(tw.la.ID_Number__c, tw);
                    idNumbers.add(tw.la.ID_Number__c);
                }
            }
            if( String.isBlank(tw.la.Mobile__c) && String.isBlank(tw.la.ID_Number__c) && this.regionFlag == 'Jordan' ) {//#CH04 : add {&& this.regionFlag == 'Jordan'}
                this.showErrorForm = true;
                //this.errorMessageForm = 'Mobile Number is mandatory';
                this.errorMessageForm = 'Please fill either Mobile Number or the ID Number to complete the declaration.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, this.errorMessageForm ));
                //stop the for
                break;
            }
            //#CH04 : Start
            if( String.isBlank(tw.la.ID_Number__c) && !tw.isEdit && this.regionFlag != 'Jordan' ) {
                this.showErrorForm = true;
                //this.errorMessageForm = 'Mobile Number is mandatory';
                this.errorMessageForm = 'Please fill the CPR Number to complete the declaration.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, this.errorMessageForm ));
                //stop the for
                break;
            }
            else if( !test.isRunningTest() && String.isNotBlank(tw.la.ID_Number__c) && (!tw.isEdit || (tw.isEdit && tw.la.ID_Number__c != tw.idNumber) ) && this.regionFlag != 'Jordan' && !Pattern.matches('^[0-9]{9}$', tw.la.ID_Number__c)  ) {
                this.showErrorForm = true;
                this.errorMessageForm = 'CPR Number must be exactly 9 digits.';
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, this.errorMessageForm ));
                //stop the for
                break;
            }
            //#CH04 : End
        }

        if(this.showErrorForm == false){
            //If there's not a duplicate and we have id numbers
            if( (!mobileNumbers.isEmpty() && !duplicatedMobileNumber) || !idNumbers.isEmpty() ){

                if( !mobileNumbers.isEmpty() ){
                    relatedIdByMobileNumber = this.getRelatedIdByMobileNumber(mobileNumbers);
                }

                if( !idNumbers.isEmpty() ){
                    relatedIdByIdNumber = this.getRelatedIdByIdNumber(idNumbers);
                }

                List<Linked_Account__c> laToUpsert = new List<Linked_Account__c>();
                List<Lead> leadsToInsert = new List<Lead>();
                String relatedId;
                Linked_Account__c laNew;
    
                System.debug('TableWrapper **********************************');
                for(TableWrapper tw : linkAccList){
    
                    String mobNum = tw.la.Mobile_Country_Code__c + tw.la.Mobile__c;
                    System.debug(mobNum);
                    System.debug(tw.la);
                    
                    //it's insert
                    if(!tw.isEdit){
                        tw.isEdit = true;
                        System.debug('New Row');
                        //do we have an inactive LA?
                        if(inactiveLAsMapByMobileNumber.containsKey(mobNum)){
                            /*System.debug('we have an inactive LA');
                            
                            laNew = tw.la;
                            laNew.Relationship__c = tw.relationship;//#CH2 : Correction bug
                            laNew.ID_Number__c=tw.la.ID_Number__c;//
                            laNew.Staff_ID__c=this.staffIdUser;
                            laNew.Id = inactiveLAsMapByMobileNumber.get(mobNum);
                            laNew.Active__c = true;
                            laNew.Relationship_Date_Removed__c = null;
                            //laNew.Staff_ID__c = tw.IdNumber;//staffIdUser;//relatedIdByIdNumber.get(tw.idNumber);
                            laNew.Relationship_Date_Added__c = System.now();
                            system.debug('laNew==>'+laNew);
                            system.debug('===>'+tw.la.Relative_Customer__c );
                            //relatedId = relatedIdByIdNumber.get(tw.idNumber);
                            relatedId = relatedIdByMobileNumber.get(mobNum);//toCheck
                            system.debug('===>'+relatedId);
                            laToUpsert.add(laNew);
                            if( String.isNotBlank(relatedId) && ((Id)relatedId).getSObjectType().getDescribe().getName() == 'Account' ) {//toDo : check with Ashish
                                system.debug('relatedId===>'+relatedId);
                                Account acc = new Account(Id=relatedId); //toDo : relatedId can be in this case a lead or account!!!
                                //#CH02 : start 
                                
                                if((tw.la.StaffRelativesKanz__c == 'Exclude from the Raffles' && this.regionFlag != 'Jordan')){
                                    acc.PLA_Eligibility__pc='No';
                                    acc.PLA_Ineligibility_Reason__pc='Not Interested Relative';
                                    accsToUpdateEligibility.add(acc);
                                }
                                else if(this.regionFlag == 'Jordan' && this.userContact.PLA_Eligibility__c == 'Yes' 
                                    && (this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff' || this.userContact.PLA_Ineligibility_Reason__c == 'Resigned Staff') 
                                ){
                                    if(this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff'){
                                        acc.PLA_Ineligibility_Reason__pc='Probationary Relatives';
                                    }else{
                                        acc.PLA_Ineligibility_Reason__pc='Resigned Relatives';
                                    }
                                    acc.PLA_Eligibility__pc='Yes';
                                    accsToUpdateEligibility.add(acc);
                                }
                                else{
                                    acc.PLA_Eligibility__pc='Yes';
                                    acc.PLA_Ineligibility_Reason__pc='Relatives';
                                    accsToUpdateEligibility.add(acc);
                                }
                                //#CH02 : End
                            }*/
                        }
                        else {
                            //is it a contact or a lead?
                            system.debug('==> is it a contact or a lead?');
                            //#CH04 : start
                            if(this.regionFlag != 'Jordan'){
                                //priority to Id Number , then mobNumber
                                relatedId = relatedIdByIdNumber.get(tw.la.ID_Number__c);
                                
                                if(String.isBlank(relatedId)){
                                    relatedId = relatedIdByMobileNumber.get(mobNum);//toCheck
                                }
                            }else{
                                //relatedId = relatedIdByIdNumber.get(tw.idNumber);
                                relatedId = relatedIdByMobileNumber.get(mobNum);//toCheck
    
                                if(String.isBlank(relatedId)){
                                    relatedId = relatedIdByIdNumber.get(tw.la.ID_Number__c);
                                }
                            }
                            //#CH04 : End

                            if(String.isNotBlank(relatedId)){
                                //is a contact or a lead so create a new Linked Account
                                System.debug('is a (contact or a lead) so create a new Linked Account');
                                laNew = this.getLinkedAccount(tw, relatedId);
                                laNew.Existing_ila_Customer__c = TRUE;
                                laNew.ID_Number__c=tw.la.ID_Number__c;//
                                laNew.Staff_ID__c=this.staffIdUser;
                                laNew.Relationship__c = tw.relationship;//#CH2 : Correction bug
                                laToUpsert.add(laNew);
                                if(String.isNotBlank(relatedId) && ((Id)relatedId).getSObjectType().getDescribe().getName() == 'Account') {
                                    system.debug('relatedId ===>'+relatedId);
                                    Account acc=New Account(Id=relatedId);//relatedId is account!!!
                                    //#CH02 : Start
                                    if((tw.la.StaffRelativesKanz__c == 'Exclude from the Raffles' && this.regionFlag != 'Jordan')){
                                        acc.PLA_Eligibility__pc='No';
                                        acc.PLA_Ineligibility_Reason__pc='Not Interested Relative';
                                        accsToUpdateEligibility.add(acc);
                                    }
                                    else if(this.regionFlag == 'Jordan' && this.userContact.PLA_Eligibility__c == 'Yes' 
                                    && (this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff' || this.userContact.PLA_Ineligibility_Reason__c == 'Resigned Staff') 
                                    ){
                                        if(this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff'){
                                            acc.PLA_Ineligibility_Reason__pc='Probationary Relatives';
                                        }else{
                                            acc.PLA_Ineligibility_Reason__pc='Resigned Relatives';
                                        }
                                        acc.PLA_Eligibility__pc='Yes';
                                        accsToUpdateEligibility.add(acc);
                                    }
                                    else {
                                        acc.PLA_Eligibility__pc='Yes';
                                        acc.PLA_Ineligibility_Reason__pc='Relatives';
                                        accsToUpdateEligibility.add(acc);
                                    }
                                    //#CH02 : End
                                }else{//it means it's a lead record
                                    system.debug('Lead relatedId ===>'+relatedId);
                                    Lead ld=New Lead(Id=relatedId);//toDo : relatedId can be in this case a lead or account!!!
                                    //#CH02 :Start
                                    if(this.regionFlag != 'Jordan'){
                                        if(tw.la.StaffRelativesKanz__c == 'Exclude from the Raffles'){
                                            ld.Lead_PLA_Eligibility__c='No';
                                            ld.Lead_PLA_Ineligibility_Reason__c='Not Interested Relative';
                                            leadsToUpdate.add(ld);
                                        }else{
                                            ld.Lead_PLA_Eligibility__c='Yes';
                                            ld.Lead_PLA_Ineligibility_Reason__c='Relatives';
                                            leadsToUpdate.add(ld);
                                        }
                                    }
                                    else if(this.regionFlag == 'Jordan' && this.userContact.PLA_Eligibility__c == 'Yes' 
                                    && (this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff' || this.userContact.PLA_Ineligibility_Reason__c == 'Resigned Staff') 
                                    ){
                                        if(this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff'){
                                            ld.Lead_PLA_Ineligibility_Reason__c='Probationary Relatives';
                                        }else{
                                            ld.Lead_PLA_Ineligibility_Reason__c='Resigned Relatives';
                                        }
                                        ld.Lead_PLA_Eligibility__c='Yes';
                                        leadsToUpdate.add(ld);
                                    }
                                    else{
                                        ld.Lead_PLA_Eligibility__c='No';
                                        ld.Lead_PLA_Ineligibility_Reason__c='Relatives';
                                        leadsToUpdate.add(ld);
                                    }
                                    //#CH02 : End
                                }
                            } else {
                                //create lead and linked account
                                Lead ld = this.generateLead(tw);
                                System.debug('Lead to be inserted --->>>');
                                System.debug('this.regionFlag --->>>' + this.regionFlag);
                                //#CH02 :Start
                                if(this.regionFlag != 'Jordan'){
                                    if(tw.la.StaffRelativesKanz__c == 'Exclude from the Raffles'){
                                        ld.Lead_PLA_Eligibility__c='No';
                                        ld.Lead_PLA_Ineligibility_Reason__c='Not Interested Relative';
                                    }else{
                                        ld.Lead_PLA_Eligibility__c='Yes';
                                        ld.Lead_PLA_Ineligibility_Reason__c='Relatives';
                                    }
                                }
                                else if(this.regionFlag == 'Jordan' && this.userContact.PLA_Eligibility__c == 'Yes' 
                                && (this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff' || this.userContact.PLA_Ineligibility_Reason__c == 'Resigned Staff') 
                                ){
                                    if(this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff'){
                                        ld.Lead_PLA_Ineligibility_Reason__c='Probationary Relatives';
                                    }else{
                                        ld.Lead_PLA_Ineligibility_Reason__c='Resigned Relatives';
                                    }
                                    ld.Lead_PLA_Eligibility__c='Yes';
                                }
                                else{
                                    ld.Lead_PLA_Eligibility__c='Yes';
                                    ld.Lead_PLA_Ineligibility_Reason__c='Relatives';
                                }
                                //#CH02 : End
                                leadsToInsert.add(ld);
                            }
                        }
                        tw.mobileConcat = mobNum;
                    }
                    //We have to update the LA
                    else {
                        tw.la.Relationship__c = tw.relationship;//#CH2 : Correction bug
                        laToUpsert.add(tw.la);

                        //#CH04 : Start
                        if(this.regionFlag != 'Jordan'){
                            //priority to Id Number , then mobNumber
                            relatedId = relatedIdByIdNumber.get(tw.la.ID_Number__c);
                            if(String.isBlank(relatedId)){
                                relatedId = relatedIdByMobileNumber.get(mobNum);
                            }
                        }else {
                            //#CH02
                            relatedId = relatedIdByMobileNumber.get(mobNum);
                            if(String.isBlank(relatedId)){
                                relatedId = relatedIdByIdNumber.get(tw.la.ID_Number__c);
                            }
                        }
                        //#CH04 : End

                        if(String.isNotBlank(relatedId)){
                            //is a contact or a lead so create a new Linked Account
                            if(((Id)relatedId).getSObjectType().getDescribe().getName() == 'Account') {
                                system.debug('relatedId ===>'+relatedId);
                                Account acc=New Account(Id=relatedId);
                                if((tw.la.StaffRelativesKanz__c == 'Exclude from the Raffles' && this.regionFlag != 'Jordan')){
                                    acc.PLA_Eligibility__pc='No';
                                    acc.PLA_Ineligibility_Reason__pc='Not Interested Relative';
                                    accsToUpdateEligibility.add(acc);
                                }
                                else if(this.regionFlag == 'Jordan' && this.userContact.PLA_Eligibility__c == 'Yes' 
                                && (this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff' || this.userContact.PLA_Ineligibility_Reason__c == 'Resigned Staff') 
                                ){
                                    if(this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff'){
                                        acc.PLA_Ineligibility_Reason__pc='Probationary Relatives';
                                    }else{
                                        acc.PLA_Ineligibility_Reason__pc='Resigned Relatives';
                                    }
                                    acc.PLA_Eligibility__pc='Yes';
                                    accsToUpdateEligibility.add(acc);
                                }
                                else {
                                    acc.PLA_Eligibility__pc='Yes';
                                    acc.PLA_Ineligibility_Reason__pc='Relatives';
                                    accsToUpdateEligibility.add(acc);
                                }
                            }else{//it means it's a lead record
                                system.debug('Lead relatedId ===>'+relatedId);
                                Lead ld=New Lead(Id=relatedId);//relatedId can be in this case a lead or account!!!
                                if(this.regionFlag != 'Jordan'){
                                    if(tw.la.StaffRelativesKanz__c == 'Exclude from the Raffles'){
                                        ld.Lead_PLA_Eligibility__c='No';
                                        ld.Lead_PLA_Ineligibility_Reason__c='Not Interested Relative';
                                        leadsToUpdate.add(ld);
                                    }else{
                                        ld.Lead_PLA_Eligibility__c='Yes';
                                        ld.Lead_PLA_Ineligibility_Reason__c='Relatives';
                                        leadsToUpdate.add(ld);
                                    }
                                }
                                else if(this.regionFlag == 'Jordan' && this.userContact.PLA_Eligibility__c == 'Yes' 
                                    && (this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff' || this.userContact.PLA_Ineligibility_Reason__c == 'Resigned Staff') 
                                ){
                                    if(this.userContact.PLA_Ineligibility_Reason__c == 'Probationary Staff'){
                                        ld.Lead_PLA_Ineligibility_Reason__c='Probationary Relatives';
                                    }else{
                                        ld.Lead_PLA_Ineligibility_Reason__c='Resigned Relatives';
                                    }
                                    ld.Lead_PLA_Eligibility__c='Yes';
                                    leadsToUpdate.add(ld);
                                }
                                else{
                                    ld.Lead_PLA_Eligibility__c='No';
                                    ld.Lead_PLA_Ineligibility_Reason__c='Relatives';
                                    leadsToUpdate.add(ld);
                                }
                            }
                        }
                        //#CH02 : End
                    }
                }
                system.debug('accsToUpdateEligibility-->'+accsToUpdateEligibility);
                
                if(!leadsToInsert.isEmpty()){
                    System.debug('this.insertLeads');
                    System.debug(leadsToInsert);
                    this.insertLeads(leadsToInsert, laToUpsert, twByMobileNumber,twByIdNumber);
                }
                if(!laToUpsert.isEmpty()){
                    System.debug('this.upsertLinkedAccounts');
                    this.upsertLinkedAccounts(laToUpsert);
                    
                }
                if(!accsToUpdate.isEmpty()){
                    System.debug('this.updateAccounts');
                    this.updateAccounts(accsToUpdate, sp);
                }
                if(!leadsToUpdate.isEmpty()){
                    System.debug('this.updateLead');
                    this.updateLead(leadsToUpdate, sp);
                } 
                if(!accsToUpdateEligibility.isEmpty()){
                    System.debug('this.updateRelativeCustomer');
                    this.updateRelativeCustomer(accsToUpdateEligibility);
                }
                this.plaStaffRelative=true;
            }
            saveContact();
        }
    }

    /**
    * @description
    * @author ismael.ocana | 24/10/2021
    * @param List<Account> accsToUpdate
    **/
    public void updateAccounts(List<Account> accsToUpdate, Savepoint sp){
        try{
            update accsToUpdate;
        } catch (Exception e) {
            this.errorMessageForm = '';
            this.showErrorForm = true;
            this.showSuccess = false;
            this.errorMessageForm = e.getMessage();
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                this.errorMessageForm += e.getMessage();
            }
            Database.rollback(sp);
        }
    }

    /**
    * @description
    * @author ismael.ocana | 24/10/2021
    * @param List<Lead> leadsToUpdate
    **/
    public void updateLead(List<Lead> leadsToUpdate, Savepoint sp){
        try {
            update leadsToUpdate;
        } catch(DmlException e) {
            this.errorMessageForm = '';
            this.showErrorForm = true;
            this.showSuccess = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                this.errorMessageForm += this.processErrorMessage(e.getMessage());
            }

            Database.rollback(sp);
        }
    }

    public String processErrorMessage(String errMessage){
        String err = '';
        err = errMessage.contains('Manual On-boarding') ? 'The ID Number cannot be changed. Please delete this entry and create a new one.' : errMessage;
        return err;
    }

    /**
    * @description It will query to Person Accounts and Lead related to the idNumbers
    * @author ismael.ocana | 13/10/2021
    * @param Set<String> idNumbers
    * @return Map<String, String> it will return a map with idNumber, relatedId
    **/
    @TestVisible
    private Map<String, String> getRelatedIdByIdNumber(Set<String> idNumbers){

        Map<String, String> relatedIdByIdNumber = new Map<String, String>();
        List<Account> accountList = [SELECT ID, ID_Number__pc FROM Account WHERE Id_Number__pc IN :idNumbers];
        List<Lead> leadList = [SELECT ID, ID_Number__c FROM Lead WHERE Id_Number__c IN :idNumbers];
        relatedIdByIdNumber = this.getRelatedIdByIdNumberByObject((List<SObject>)leadList, 'Id_Number__c', relatedIdByIdNumber);
        relatedIdByIdNumber = this.getRelatedIdByIdNumberByObject((List<SObject>)accountList, 'Id_Number__pc', relatedIdByIdNumber);
        return relatedIdByIdNumber;
    }

    private Map<String, String> getRelatedIdByMobileNumber(Set<String> mobileNumbers){

        Map<String, String> relatedIdByMobileNumber = new Map<String, String>();
        List<Account> accountList = [SELECT ID, Mobile_Phone_Check__pc FROM Account WHERE Mobile_Phone_Check__pc IN :mobileNumbers];
        List<Lead> leadList = [SELECT ID, sys_Mobile_Number__c FROM Lead WHERE sys_Mobile_Number__c IN :mobileNumbers AND isConverted = false ];
        relatedIdByMobileNumber = this.getRelatedIdByIdNumberByObject((List<SObject>)leadList, 'sys_Mobile_Number__c', relatedIdByMobileNumber);
        relatedIdByMobileNumber = this.getRelatedIdByIdNumberByObject((List<SObject>)accountList, 'Mobile_Phone_Check__pc', relatedIdByMobileNumber);
        return relatedIdByMobileNumber;
    }

    /**
    * @description It will iterate though the soList and look for the field
    * @author ismael.ocana | 13/10/2021
    * @param List<SObject> soList sobject list
    * @param String field sobject's field
    * @param Map<String String> relatedIdByIdNumber map to be returned
    * @return Map<String, String> it will return a map with idNumber, relatedId
    **/
    @TestVisible
    private Map<String, String> getRelatedIdByIdNumberByObject(List<SObject> soList, String field, Map<String, String> relatedIdByIdNumber){

        Id idObj;
        for(Sobject so : soList){
            idObj = (Id)so.get('Id');
            relatedIdByIdNumber.put((String)so.get(field), (String)idObj);
        }
        return relatedIdByIdNumber;
    }

    /**
    * @description it will insert the new leads and return the LAs to insert
    * @author ismael.ocana | 13/10/2021
    * @param List<Lead> leadsToInsert
    * @param List<Linked_Account__c> laToUpsert
    **/
    @TestVisible
    private void insertLeads(List<Lead> leadsToInsert, List<Linked_Account__c> laToUpsert, Map<String,TableWrapper> twByMobileNumber, Map<String,TableWrapper> twByIdNumber){

        try{
            insert leadsToInsert;
            Linked_Account__c laNew;
            TableWrapper tw;
            for(Lead l : leadsToInsert){
                String mobNum = l.Mobile_Country_Code__c + l.MobilePhone;
                //#CH04 :Start
                if(this.regionFlag != 'Jordan'){
                    tw = twByIdNumber.get(l.Id_Number__c);
                    if(tw == null){
                        tw = twByMobileNumber.get(mobNum);
                    }
                }
                else{
                    tw = twByMobileNumber.get(mobNum);
                    if(tw == null){
                        tw = twByIdNumber.get(l.Id_Number__c);
                    }
                }
                //#CH04 :End
                laNew = this.getLinkedAccount(tw, (String)l.Id);
                laToUpsert.add(laNew);
            }
        } catch(DmlException e){
            this.errorMessageForm = '';
            this.showErrorForm = true;
            this.showSuccess = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                this.errorMessageForm += this.processErrorMessage(e.getMessage());
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }

    }

    /**
    * @description it will upsert the LAs
    * @author ismael.ocana | 13/10/2021
    * @param List<Linked_Account__c> laToUpsert
    **/
    @TestVisible
    private void upsertLinkedAccounts(List<Linked_Account__c> laToUpsert){

        try {
            upsert laToUpsert;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Relative updated.'));
            this.showSuccess = true;
            this.successMessage = System.label.RELATIVE_UPDATED_CORRECT;
            
        } catch (DmlException e) {
            this.errorMessageForm = '';
            this.showErrorForm = true;
            this.showSuccess = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                this.errorMessageForm += this.processErrorMessage(e.getMessage());
            }
        }

    }
    /**
    * @description it will upsert the LAs
    * @author swapna Reddy | 24/04/2022
    * @param List<Account> updateRelCustomer
    **/
    @TestVisible
    private void updateRelativeCustomer(List<Account> updateRelCustomer){

        try {
            system.debug('updateRelCustomer==>'+updateRelCustomer);
            update updateRelCustomer;
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Relative customer updated.'));
            this.showSuccess = true;
            this.successMessage = System.label.RELATIVE_UPDATED_CORRECT;
            system.debug('updated Successfully');
        } catch (DmlException e) {
            this.errorMessageForm = '';
            this.showErrorForm = true;
            this.showSuccess = false;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                this.errorMessageForm += this.processErrorMessage(e.getMessage());
            }
        }
    }


    /**
    * @description It will delete the row
    * @author ismael.ocana | 13/10/2021
    **/
    public void deleteRowAction(){

        this.showSuccess = false;
        this.showErrorForm = false;
        String elementId = Apexpages.currentPage().getParameters().get('selectedWrapperVF');
        Map<String, TableWrapper> mapWrapper = this.mapLinkAcc.clone();
        List<TableWrapper> laList;
        TableWrapper tw = this.mapLinkAcc.get(elementId);
        if(tw.isEdit){
            System.debug('tw.isEdit true');
            Linked_Account__c la = new Linked_Account__c(Id=tw.la.Id);
            la.Active__c = false;
            la.Relationship_Date_Removed__c = System.now();
            try{
                //update la;
                delete la;//#CH03 comment update
                this.showSuccess = true;
                this.successMessage = System.label.RELATIVE_DELETED_CORRECT;

                //add to inactive map after removing an existing LA row
                //this.inactiveLAsMapByMobileNumber.put(tw.mobileConcat, tw.la.Id);//#CH03 comment this part
                //#CH03 : update  PLA eligibility to Yes, and PLA ineligibility to ““ 
                if(tw.la.Relative_Customer__c != null){
                    Account acc = new Account(Id=tw.la.Relative_Customer__c);
                    acc.PLA_Eligibility__pc='Yes';
                    acc.PLA_Ineligibility_Reason__pc=null;
                    update acc;
                }

            } catch (Exception e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            }

        }
        mapWrapper.remove(tw.id);
        this.mapLinkAcc = mapWrapper;
        this.linkAccList = mapWrapper.values();
        this.listSize = this.linkAccList.size();
    }

    /**
    * @description It will generate a new Lead related to the Wrapper
    * @author ismael.ocana| 08/10/2021
    * @param TableWrapper tw
    * @return Lead
    **/
    private Lead generateLead(TableWrapper tw){
        return new Lead(
            Mobile_Country_Code__c = tw.la.Mobile_Country_Code__c,
            MobilePhone = tw.la.Mobile__c,
            Id_Number__c = tw.la.ID_Number__c,
            /* firstName = this.userContact.firstName,
            lastName = this.userContact.lastName */ 
            firstName =tw.la.First_Name__c,
            lastName = tw.la.Last_Name__c,
            recordTypeId = this.leadRecordType,
            Lead_PLA_Eligibility__c='No',
            Lead_PLA_Ineligibility_Reason__c='Relatives'
        );
    }

    /**
    * @description it will get a Linked Account
    * @author ismael.ocana | 08/10/2021
    * @param TableWrapper tw
    * @return Linked_Account__c
    **/
    public Linked_Account__c getLinkedAccount(TableWrapper tw){
        Linked_Account__c la = tw?.la;
        la.Relationship_Date_Added__c = System.now();
        la.Relationship_Date_Removed__c = null;
        la.Active__c = true;
        la.ID_Number__c=tw?.la?.ID_Number__c;//
        la.Staff_ID__c=this.staffIdUser;
        la.Relationship__c = tw.relationship;//#CH2 : Correction bug
        return la;
    }

    /**
    * @description It will get a Linked Account with the relative field filled
    * @author ismael.ocana | 13/10/2021
    * @param TableWrapper tw
    * @param String relativeId
    * @return Linked_Account__c
    **/
    public Linked_Account__c getLinkedAccount(TableWrapper tw, String relativeId){

        Linked_Account__c la = this.getLinkedAccount(tw);
        la.put(this.getRelativeField(relativeId), relativeId);
        return la;
    }

    /**
    * @description It will return the field related the object type
    * @author ismael.ocana | 13/10/2021
    * @param String relativeId
    * @return String
    **/
    private String getRelativeField(String relativeId){

        String field;
        Id rId = relativeId;
        field = rId.getSObjectType().getDescribe().getName() == 'Lead' ? 'Relative__c' : 'Relative_Customer__c';
        return field;
    }

    //We are using a Wrapper because we have to use idNumber and the dates and we can't use the same object
    public class TableWrapper{
        public Linked_Account__c la {get;set;}
        public String relationship {get;set;}//#CH2 : Correction bug
        //Apex input forces us to use non salesforce objects, that's why they are at the wrapper
        public DateTime startDT {get;set;}
        public DateTime endDT {get;set;}
        public String idNumber {get;set;}
        public String mobileConcat {get;set;}
        public String id {get;set;}
        public Boolean isEdit {get;set;}

        public TableWrapper(Linked_Account__c la, String idNumber, DateTime startDT, DateTime endDT){
            this.la = la;
            this.idNumber = idNumber;
            this.startDT = startDT;
            this.endDT = endDT;
            this.id = 'LA - ' + System.now().getTime() + la.Id;
            this.isEdit = true;
            this.mobileConcat = la.Mobile_Country_Code__c + la.Mobile__c;
            this.relationship = la.Relationship__c;//#CH2 : Correction bug
        }
        public TableWrapper(Linked_Account__c la){
            this.la = la;
            this.startDT = System.now();
            this.id = 'LA - ' + System.now().getTime();
            this.isEdit = false;
            if(la != null){
                this.relationship = la.Relationship__c;//#CH2 : Correction bug
            }
        }
    }


    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('--None--',''));//#CH02
        if(this.userContact.Region_Flag__c == 'Jordan'){
            options.add(new SelectOption('Father','Father'));
            options.add(new SelectOption('Mother','Mother'));
            options.add(new SelectOption('Son','Son'));
            options.add(new SelectOption('Daughter','Daughter'));
            options.add(new SelectOption('Wife','Wife'));
            options.add(new SelectOption('Husband','Husband'));
        }else {
            options.add(new SelectOption('Son','Son'));
            options.add(new SelectOption('Daughter','Daughter'));
            options.add(new SelectOption('Spouse(s)','Spouse(s)'));
            options.add(new SelectOption('Grandchildren','Grandchildren'));
            options.add(new SelectOption('Parents','Parents'));
        }
        
        return options;
    }
}