({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
        
    },
    OnDocumentRequired:function(component, event, helper) {
        var Documents_Required = component.find("Upload_Documents_Required").get("v.value");
        if(Documents_Required=='Yes'){
            component.set('v.isDocumentReq','true');
        }else{
            component.set('v.isDocumentReq','false');
        }
    },
    OnOverdueHandling:function(component, event, helper) {
        var OnOverdueHandling = component.find("Overdue_Handling").get("v.value");
        if(OnOverdueHandling=='Level 3 - App (Nudges & Splash), Notifications & Restrictions'){
            component.set('v.isRestriction','true');
        }else{
            component.set('v.isRestriction','false');
        }
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
    },
    handleOnSubmit: function (component, event, helper) {
        var Type = component.find("type").get("v.value");
        
        var docList;
        var isDocumentReq =  component.get('v.isDocumentReq');
        if(isDocumentReq =='true'){
            docList = component.find("Document_List").get("v.value"); 
        }
        
        
        if(Type=='KYC_SUSPECTED_IDENTITY_FRAUD'){ 
            var Baccount=component.find("Block_Account_Debits").get("v.value");
            var Bapp=component.find("Block_App_Access").get("v.value");
            var BCcard=component.find("Block_Credit_Cards").get("v.value");
            var BDcard=component.find("Block_Debit_Cards").get("v.value");
            if(!Baccount&&!Bapp&&!BCcard&&!BDcard){
                console.log('insideif');
                component.set('v.isallowed',"false");
            }else{
                component.set('v.isallowed',"true");
                component.set('v.isallowedIDV',"true");
                component.set('v.isallowedRP',"true");
                
            }
        }
        if(Type=='KYC_PERIODIC_REVIEW'){
            var subType = component.find("subType").get("v.value"); 
            if(subType=='Custom Configurations'){
                var idvReqVal = component.find("IDVRequired").get("v.value");
                var RPI = component.find("Review_Personal_Information").get("v.value");
                var UPR = component.find("Upload_Documents_Required").get("v.value");
                if((idvReqVal=='Yes' || RPI=='Yes'||UPR=='Yes')&& isDocumentReq =='true'){ 
                    
                    var selectedValues = docList;
                    console.log('insideif'+selectedValues);
                    if ((selectedValues) || (isDocumentReq=='false')) {
                        console.log('insideif');
                        component.set('v.isallowed',"true");
                    }else{
                        component.set('v.isallowed',"false");
                    }
                } else if(isDocumentReq =='false'){
                     component.set('v.isallowed',"true");
                }else{
                     component.set('v.isallowed',"false");
                }
            }
            else  if(subType=='Default Configurations'){
                component.set('v.isallowed',"true");
                component.set('v.isallowedIDV',"true");
                component.set('v.isallowedRP',"true");
            }
        }
        console.log('handleOnSubmit');
        event.preventDefault();
        console.error(component.get('v.recordTypeId'));
        var fields = event.getParam('fields');  
        fields["Status__c"] = "Open";
        //fields["Sub_Status__c"]="In-Progress";
        var allow=component.get('v.isallowed');
          var idvallow=component.get('v.isallowedIDV');
        var rpallow=component.get('v.isallowedRP');
        if(allow=='true' && idvallow=='true' && rpallow){
            component.find('form').submit(fields);
            helper.showSpinner(component);
        }
        
    },
    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) {//CH01
        console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
    },
    loadSubType: function (component, event, helper) {
        var Type = component.find("type").get("v.value");
        component.set('v.isallowed',"true");
        helper.validateOpencase(component, event, helper);
        helper.getTypeBasedRecordType(component, event, helper,Type);
        if(Type=='KYC_PERIODIC_REVIEW'){         
            component.set('v.isPeriodic','true');
            component.set('v.isFraud','false');           
        }else if(Type=='KYC_SUSPECTED_IDENTITY_FRAUD'){
            component.set('v.isFraud','true');
            component.set('v.isPeriodic','false');
        }
    },
    loadConfiguration: function (component, event, helper) {
        var Type = component.find("subType").get("v.value");
        if(Type=='Custom Configurations'){
            component.set('v.isCustom','true');
        }else{
            component.set('v.isCustom','false');
        }
    },
    validateIDVDocStatus:function (component, event, helper) {
        var idvReqVal = component.find("IDVRequired").get("v.value");
        if(idvReqVal=='Yes'){
            
            var DocumentStatus= component.find("DocumentStatus").get("v.value");
            if(DocumentStatus=='Unable to Verify'){
                component.find("IDVRequired").set("v.value","");
                component.set('v.isallowedIDV',"false");
                component.find('notifLibrary').showToast({
                    "title": "Error/Warning!",
                    "message": "KYC Verification case for Periodic Review with ID&V Required set to “Yes” cannot be created as customer was manually onboarded neither using a Bahraini ID nor a Bahraini Passport.",
                    "variant": "error", // 'error', 'warning', 'success', or 'info'
                    "mode": "dismissible" // 'dismissible', 'pester', or 'sticky'
                });
                
            }else{
                component.set('v.isallowedIDV',"true");
            }
            if(DocumentStatus=='Complete'){
                var ExlNationalities = $A.get("$Label.c.ID_V_Excluded_Nationalities");
                const Exclnationality = ExlNationalities.split(';');
                var Nationality = component.find("nationality").get("v.value");
                if(Nationality){
                    if(Exclnationality.indexOf(Nationality)>-1){
                        var message="⚠️ Customer with "+ Nationality +" Nationality already has complete onboarding documents and it is not recommended to perform ID&V.";
                        /*   component.find('notifLibrary').showToast({
        "title": "Warning!",
        "message": message,
        "variant": "warning", // 'error', 'warning', 'success', or 'info'
        "mode": "dismissible" // 'dismissible', 'pester', or 'sticky'
    });*/
                    component.find('notifLibrary').showNotice({
                        "variant": "warning",
                        "header": "⚠️Warning!",
                        "message": message,
                        closeCallback: function() {
                            component.set('v.isallowedIDV',"true");
                            // CALL APEX/PROCESS REQUEST HERE
                            console.log('Action processed');
                        }
                    });
                }
                }
                
            }
        }
        if(idvReqVal=='No'){
            var DocumentStatus= component.find("DocumentStatus").get("v.value");
            if(DocumentStatus=='Missing'){
                component.set('v.isallowedIDV',"false");
                component.find('notifLibrary').showNotice({
                    "variant": "warning",
                    "header": "⚠️Warning!",
                    "message": "⚠️Customer is missing onboarding documents and it is recommended to perform ID&V.",
                    closeCallback: function() {
                        component.set('v.isallowedIDV',"true");
                        // CALL APEX/PROCESS REQUEST HERE
                        console.log('Action processed');
                    }
                });
                /*   component.find('notifLibrary').showToast({
        "title": "Warning!",
        "message": "Customer is missing onboarding documents and it is recommended to perform ID&V.",
        "variant": "warning", // 'error', 'warning', 'success', or 'info'
        "mode": "dismissible" // 'dismissible', 'pester', or 'sticky'
    });*/
               }else{
                   component.set('v.isallowedIDV',"true");
               }
            
        }
        
        
    },
    validateeKYCDocStatus:function (component, event, helper) {
        var idvReqVal = component.find("eKYC_iGA_Data").get("v.value");
        if(idvReqVal=='Yes'){
            var DocumentStatus= component.find("DocumentStatus").get("v.value");
            if(DocumentStatus=='Unable to Verify'){
                component.set('v.isallowedEkey',"false");
                component.find("eKYC_iGA_Data").set("v.value","");
                component.find('notifLibrary').showToast({
                    "title": "Error/Warning!",
                    "message": " KYC Verification case for Periodic Review with Update eKYC iGA Data set to “Yes” cannot be created as customer was manually onboarded neither using a Bahraini ID nor a Bahraini Passport and KYC data cannot be fetched from iGA",
                    "variant": "error", // 'error', 'warning', 'success', or 'info'
                    "mode": "dismissible" // 'dismissible', 'pester', or 'sticky'
                });
                
            }else{
                component.set('v.isallowedEkey',"true");
            }
            
        }
    },
    validateRPDocStatus:function (component, event, helper) {
        var idvReqVal = event.getSource().get("v.value");
        // var idvReqVal = component.find("Document_Residence_Permit");
        //alert(newValue);
        if(idvReqVal){
            var DocumentStatus= component.find("DocumentStatus").get("v.value");
            if(DocumentStatus=='Unable to Verify'){
                component.set('v.isallowedRP',"false");
                component.find('notifLibrary').showToast({
                    "title": "Error/Warning!",
                    "message": " KYC Verification case for Periodic Review with Upload Residence Permit Document required cannot be created as it is not required for customers with a Bahraini or GCC nationality",
                    "variant": "error", // 'error', 'warning', 'success', or 'info'
                    "mode": "dismissible" // 'dismissible', 'pester', or 'sticky'
                });
            }else{
                component.set('v.isallowedRP',"true");
            }
            
        }
    },
    toggleSection:function (component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
    }
})