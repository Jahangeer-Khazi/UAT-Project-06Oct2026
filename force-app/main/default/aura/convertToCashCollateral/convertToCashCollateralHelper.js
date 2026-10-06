/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:
 * 		Change History: 
 * 			 #CH01 : Added #Jahangeer Mohammed# #14-05-2023# Region Flag
 *			  
*/
({
	loadCurrentCase : function(component,event,helper) {
		var action = component.get("c.fetchCurrentCase");
        var caseIdd = component.get("v.recordId");
        console.log('Case Record Id:'+caseIdd);
        action.setParams({"strcaseId" : caseIdd});
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('State from Apex class:'+state);
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Final Result Value:'+JSON.stringify(result));
                component.set("v.accRecord",result.AccountId);
                component.set("v.requestedCardType",result.cc_Requested_Card_Type__c);
                component.set("v.requestedCreditLimit",result.cc_Requested_Credit_Limit__c);
                component.set("v.balanceTransferCardProvider",result.cc_Balance_Transfer_Card_Provider__c);
                component.set("v.balanceTransferCardNumber",result.cc_Balance_Transfer_Card_Number__c);
                component.set("v.balanceTransferAmount",result.cc_Balance_Transfer_Amount__c);
                component.set("v.nameOnTheCard",result.cc_Name_on_the_Card__c);
                //CH01: Start
                component.set("v.region",result.Region_Flag__c);
                //CH01: END
                component.set("v.subStatus",result.Sub_Status__c);
                var caseSubStatus = component.get("v.subStatus");
                console.log('Case Sub Status 1:'+caseSubStatus);
                component.set("v.caseSubStatus",caseSubStatus);
                console.log('Case Sub Status 2:'+component.get("v.caseSubStatus"));
            }
        });
        $A.enqueueAction(action);
	},
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
    
})