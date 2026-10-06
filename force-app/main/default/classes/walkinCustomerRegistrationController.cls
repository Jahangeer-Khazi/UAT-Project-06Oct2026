/*       Organization : ABC Bank
*       Created By: Ashish Pandey
*       Created Date:
*       Change History: 
						#CH01# #Jahangeer Mohammed# #01-07-2025# Added Logic to Populate Descrition Field (UATNB-175451)
*/
public without sharing class walkinCustomerRegistrationController 
{
    public walkinCustomerRegistrationController() {
    }
    
    //public String reqEmail{get;set;}
    public String reqPhone{get;set;}
    public String phoneCode{get;set;}
    public String reqType{get;set;}
    public String reqDesc{get;set;}
    //public Decimal reqLatitude{get;set;}
    //public Decimal reqLongitude{get;set;}
    public Decimal tok{get;set;}
    public Decimal customerNumber{get;set;}
    public String CustomerLabelAR{get;set;}
    public String CustomerLabelEN{get;set;}
    public String CustomerNextLabelAR{get;set;}
    public List<Case> lstCreateCase = new List<Case>();
    public walkinCustomerRegistrationController (ApexPages.StandardController controller) {
    }

    public PageReference saveRequest()
    {
        PageReference pr;
        Case objCase = new Case();
        //system.debug('---> Email --> ' +reqEmail);
        system.debug('---> type --> ' +reqType);
        system.debug('---> Description --> ' +reqDesc);
        system.debug('---> Mobile Phone --> ' +reqPhone);
        //system.debug('---> Longitude --> ' +reqLongitude);


        if(reqPhone != ''){
            List<Account> lstAcc = [Select id, PersonContactId from Account where 
                                   (PersonMobilePhone=: reqPhone AND RecordType.Name != 'Prospect' AND Region_Flag__pc = 'Bahrain' AND Archived__pc = false AND Onboarding_Stage__pc = 'ACCOUNT_ACTIVATED' AND Residency__pc = 'BH') OR 
                                   (PersonMobilePhone=: reqPhone AND RecordType.Name = 'Prospect' AND Region_Flag__pc = 'Bahrain' AND CreatedDate = LAST_N_DAYS : 30)];
            
           // objCase.Subject = 'Walkin customers - Branch Support';
            objCase.RecordTypeID = system.label.WalkinCustomerCaseRecordTypeId;
            objCase.Description = reqDesc;
            objCase.Type = 'Walkin Customer';
            objCase.Sub_Type__c = reqType;
            objCase.Status = 'New';
            objCase.Sub_Status__c = 'New';
            objCase.Priority = 'High';
            //objCase.Case_Model__c = 'Walkin';
            objCase.Case_Nature__c = 'Walkin';
            //objCase.SuppliedEmail = reqEmail;
            objCase.Web_Phone_Country_Code__c = phoneCode;
            objCase.SuppliedPhone = reqPhone;
            objCase.OwnerId = system.label.Walk_in_Service_Centre_Queue;
            objCase.Origin = 'Service Centre';
            if(lstAcc.size()>0){
                objCase.ContactId = lstAcc[0].PersonContactId;
            }
            lstCreateCase.add(objCase);
            }
            insert lstCreateCase;
       // }
        pr = new PageReference('/apex/walkinCustomerRegistration_ThankyouPage?id='+objCase.id);
        System.debug('Page Reference is:'+pr);
        pr.setRedirect(true);
        return pr;
    }
    public PageReference generateToken()
    {
       id addTo= Apexpages.currentPage().getParameters().get('id');
       System.debug('-----> Case ID --> '+addTo);
       Customer_TokenCounter__c tcm = getMetaDataRecords()[0];        
        tok = tcm.Counter__c ;
        //Case objCaseUpdate = new Case(id=addTo);
        //CH01: Start: Added Sub_Type__c,Description in SOQL Query
        Case objCaseUpdate = [select id,Subject,Sub_Type__c,Description,Token_Counter__c,Total_Walkin_Cases__c from Case where Id =:addTo ];
        //CH02: End
        customerNumber = objCaseUpdate.Total_Walkin_Cases__c;
        if(customerNumber==0 || customerNumber==1){
            CustomerLabelEN = 'Customer';
            CustomerLabelAR = 'عميل';
            CustomerNextLabelAR = 'موجود حاليًا في صف الانتظار';
        }else if (customerNumber > 1){
            CustomerLabelEN = 'Customers';
            CustomerLabelAR = 'عملاء';
            CustomerNextLabelAR = 'موجودين حاليًا في صف الانتظار';
        }
            
        
        objCaseUpdate.Token_Counter__c = tok;
        objCaseUpdate.Subject = 'Walkin customers - Branch Support Token Number' + ' ' + tok;
        //CH01: Start
        if(objCaseUpdate.Sub_Type__c == 'Recovery code reset'){
            objCaseUpdate.Description = 'Recovery code reset';
        }else if(objCaseUpdate.Sub_Type__c == 'Change email/ Mobile number'){
            objCaseUpdate.Description = 'Change email/ Mobile number';
        }else if(objCaseUpdate.Sub_Type__c == 'Account Statements'){
            objCaseUpdate.Description = 'Account Statements';
        }else if(objCaseUpdate.Sub_Type__c == 'IBAN Certificate'){
            objCaseUpdate.Description = 'IBAN Certificate';
        }else if(objCaseUpdate.Sub_Type__c == 'Receive Card or Cheque'){
            objCaseUpdate.Description = 'Receive Card or Cheque';
        }else if(objCaseUpdate.Sub_Type__c == 'APP Support'){
            objCaseUpdate.Description = 'APP Support';
        }else{
            objCaseUpdate.Description = '';
        }
        //CH01: END
        System.debug('-----> objCaseUpdate --> '+objCaseUpdate );
        Update objCaseUpdate ;
        System.debug('-----> Counter Value --> '+tok );
        tcm.Counter__c = tcm.Counter__c+1;
        System.debug('-----> POST Counter Value --> '+tcm.Counter__c);
        update tcm; 
       
        return null;
    }
    public static list<Customer_TokenCounter__c> getMetaDataRecords()
    {
        list<Customer_TokenCounter__c> tcm = [Select Id, name, Today_s_Date__c, Counter__c FROM Customer_TokenCounter__c];
        return tcm;
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('', 'Select an option | حدد اختيارا'));
        options.add(new SelectOption('Recovery code reset','Recovery code reset | الحصول على رمز الاسترداد'));
        options.add(new SelectOption('Change email/ Mobile number','Change email/ Mobile number | تغيير رقم الموبايل أوالإيميل'));
        options.add(new SelectOption('Account Statements','Account Statements | كشف حساب'));
        options.add(new SelectOption('IBAN Certificate','IBAN Certificate | IBAN اصدار شهادة'));
        options.add(new SelectOption('Receive Card or Cheque','Receive Card or Cheque | استلام بطاقة أو شيك'));
        options.add(new selectOption('APP Support', 'APP Support | دعم التطبيق'));
        
        //options.add(new selectOption('General Enquiry', 'General Enquiry | استفسار عام'));
        //options.add(new SelectOption('IBAN Related','IBAN Related | IBAN ذات صلة بـ'));
        //options.add(new SelectOption('Onboarding Support','Onboarding Support | دعم المستخدم الجديد'));
        return options;

    }
    
    public List<SelectOption> getPhoneCodeItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new selectOption('+973', '+973'));
        options.add(new selectOption('+965', '+965'));
        options.add(new selectOption('+968', '+968'));
        options.add(new SelectOption('+974','+974'));
        options.add(new SelectOption('+966','+966'));
        options.add(new SelectOption('+971','+971'));
       
        return options;

    }
    
}