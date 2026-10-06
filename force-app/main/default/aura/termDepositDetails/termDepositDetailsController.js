/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:03-01-2022
 * 		Change History: 
 *         #CH02 : Added by Imane Tsioucha 11-03-2024
 * 		   #CH03: #Jahangeer Mohammed# #04-04-2024# Added the region condition(UATNB-108170)
 *			  
*/
({
	init : function(component, event, helper) {
		console.log('Inside Term Deposit Detail');
        console.log('Getting Urbis Contract Id',component.get("v.urbisContractId"));
        console.log('Getting Customer Id',component.get("v.customerId"));
        helper.loadTermDepositDetails(component, component.get('v.customerId'), component.get('v.urbisContractId'));
       
	},
    load : function(component, event, helper) {
        console.log('Inside Load Method Term Deposit Detail');
        console.log('Getting Urbis Contract Id in Load Method',component.get("v.urbisContractId"));
        console.log('Getting Customer Id in Load Method',component.get("v.customerId"));
        helper.loadTermDepositDetails(component, component.get('v.customerId'), component.get('v.urbisContractId'));

	},
    GenerateTermDeposit : function(component, event, helper){
     console.log('Inside Generate Term Deposit Method');
        helper.downloadTermDeposit(component, component.get('v.customerId'), component.get('v.urbisContractId'));
    },
     handleClick : function(component,event, helper){ 
        var urlEvent = $A.get("e.force:navigateToURL");
        //CH03: Start
        var region = component.get('v.regionName');
        if(region === 'Bahrain'){ 
        	urlEvent.setParams({
            	"url": "https://ilabank.com/FixedDeposit"
        	});
        }else if(region === 'Jordan'){
            urlEvent.setParams({
            	"url": "https://ilabank.com/jo/FixedDeposit"
        	});
        }
        //CH03: END
        urlEvent.fire();
    },
     //#CH02 : Added by Imane Tsioucha
    downloadClick : function(component, event, helper) {
        var caseId=component.get("v.recordId");
        helper.downloadTermDepositCertification(component,component.get('v.customerId'),component.get('v.urbisContractId') );
	},
})