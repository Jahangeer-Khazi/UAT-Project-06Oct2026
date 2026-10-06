/* 		Organization : ABC Bank
 * 		Created By:
 *		Created Date:
 * 		Change History:
 *			 #CH03# #Jahangeer Mohammed# #24-10-2024# Added Logic for Credit Card Account Closure(NBA-9192)
 *			 #CH04# #Jahangeer Mohammed# #07-05-2025# Added Logic for Credit Card Cancellation Process(NBA-13500)
 *      	 #CH05# #Jahangeer Mohammed# #19-08-2025# Added Masked Card Number(NBA-15639)
 *  		 #CH06# #Jahangeer Mohammed #11-11-2025# Added Logic for World Elite Entitlement Process (NBA-15929)


 */
({
    init : function(component, event, helper) {
        
    },
    handleOnload : function(component, event, helper) {
        console.log('On Load Calls');
        if(component.find("businessApproval").get("v.value") =='Approve'){
            component.set("v.isBusinessApproval",true);
        }
       var statusValue = component.find("status").get("v.value");
        if(statusValue == 'Closed'){
            component.set("v.isButtonVisible",false);
        }
       var chkValue = component.find("chk").get("v.value");
        console.log('Check Value:',chkValue);
        if(chkValue){
            component.set("v.isChecker",true);
            helper.setFieldVisibility(component,component.find("subType1").get("v.value"),component.find("reqType").get("v.value"));
        }else{
            component.set("v.isChecker",false);
            helper.setFieldVisibility(component,component.find("subType").get("v.value"),component.find("reqType").get("v.value"));
        }

        //#CH02 : Start
        var rFlag =  component.find("rFlag").get("v.value");
        if(rFlag == 'Bahrain'){
            component.set("v.cc_Monthly_Limit_Label","Monthly Limit Value (BHD)");
        }else if(rFlag == 'Jordan'){
            component.set("v.cc_Monthly_Limit_Label","Monthly Limit Value (JOD)");
        }
        var selectedPlan=  component.find("selectedPlan").get("v.value");
        if(selectedPlan){
            component.set("v.SelectedPlan",selectedPlan);
        }
        //#CH02 : End
        //CH05: Start
        var caseId = component.get("v.caseId");
        var mskCardNumber = component.get("v.cc_CardNumber");//Selected Mask Card Number
        var pciNumber = component.get("v.cc_CardId"); //Selected Card Id
        helper.updatePCIAndMaskCardNoCase(component,caseId,pciNumber,mskCardNumber);
        //CH05: END
        //CH06: Start
        //helper.fetchIlaWorldMembershipNumber(component,caseId);
        //CH06: END
        
	},
    handleOnSubmit : function(component, event, helper) {
       
        var isSubmitType = true;
        if(component.find("chk").get("v.value")){
            isSubmitType = false;
        }
        event.preventDefault();
        var fields = event.getParam("fields");
        fields["cc_PCI_Id__c"] = component.get("v.cc_CardId");
        fields["isSubmitted__c"] = isSubmitType;
        //Added by Imane Tsioucha
        fields["cc_Credit_Card_PCI_Number__c"] = component.get("v.cc_CardNumber");
        //CH03: Start
        var cseId = component.get("v.caseIdRelatedToCard");
        console.log('Case Id Related to Card:',cseId);
        fields["CaseExecutionNumberB__c"] = cseId;
        //CH04: Start
        fields["cc_Current_Credit_Limit__c"] = component.get("v.currentCreditLmt");
        fields["Credit_Card_Outstanding_Balance__c"] = component.get("v.currentOutStandingBalance");
        fields["Card_Nature__c"] = component.get("v.cardNature");
        fields["PrimaryCardProductConfigurationId__c"] = component.get("v.cardProductId");
        fields["LetterReferenceNumberB__c"]=component.get("v.SelectedPlan");
        /*var accClosure = component.get("v.isAccountClosure");
        console.log('Account Closure:',accClosure);
        if(accClosure){
          var ownerIdFromLabel = $A.get("$Label.c.Credit_Card_Retention_Queue"); // Replace 'CustomLabelOwnerId' with your actual custom label API name
          console.log('OwnerId from Custom Label:', ownerIdFromLabel);
          fields["OwnerId"] = ownerIdFromLabel;
        }*/
        //CH04: END
        //CH03: END
        component.find("form").submit(fields);
        helper.showSpinner(component); 
        //CH06: Start
        /*var eliteMemberShipNumber = component.get("v.membershipNumber");
        console.log('Membership Number On Submit:',eliteMemberShipNumber);
        if(eliteMemberShipNumber != ''){
            helper.handleErrors("Customer has ongoing membership, credit card can’t be canceled");
            
        }else if(eliteMemberShipNumber == '' || eliteMemberShipNumber == null){
            component.find("form").submit(fields);
        	helper.showSpinner(component); 
        }*/
        //CH06: END
    
},
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var message = 'The record has been updated successfully.'
        if(component.find("chk").get("v.value")){
            message = 'Edit mode is enabled for you.'
        }
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": message
        });
        toastEvent.fire();
        component.set("v.isChecker",true);
    },
    handleOnError : function(component, event, helper) {
        helper.hideSpinner(component);
	},
    generateCertificate : function(component, event, helper){
        
        helper.helperGenerateCertificate(component, event);
    },
    sendForBusinessApproval : function(component, event, helper){
        helper.helpersendBusinessApproval(component, event);
    },
    rejection : function(component, event, helper){
        
        helper.sendRejection(component, event);
    },
    last4DigitValidation : function(component, event, helper){
    helper.validationHelper(component,component.find("subType").get("v.value"));
}
    
    
})