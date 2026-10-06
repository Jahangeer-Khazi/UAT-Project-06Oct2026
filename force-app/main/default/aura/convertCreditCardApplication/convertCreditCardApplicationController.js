/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date: 02-07-2025
 * 		Change History: 
 * 						#CH01# #Jahangeer Mohammed# #18-08-2025 Added Masked Card Number(NBA-15639)

 *        
 *			  
 */
({
	handleOnload : function(component, event, helper) {
		component.find('apexService').request(component.get('c.getPCIOptionsCashCollateralLimitIncrease'), {
                accID : component.get("v.recordId")
            },
             function(response) {
             var result = response.getReturnValue();
                 
              var fieldMap = [];
                for(var key in result){
                    //"cardId":will contain the id of the card & "cardObj": will contain the cardObj data
                    fieldMap.push({cardId: key, cardObj: result[key] });//CH02
                }
             component.set("v.cc_cardPCINumber",fieldMap);
           });
        component.find('apexService').request(component.get('c.getDefaultName'), {
                accID : component.get("v.recordId")
            },
             function(response) {
             var result = response.getReturnValue();
             component.find("namOnCard").set("v.value",result);
           });
	},
    handleOnSubmit: function(component, event, helper) {
        helper.showSpinner(component);
        
        
    },
    handleOnSuccess : function(component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
         
        $A.get("e.force:closeQuickAction").fire();
        
        
    },
    handleOnError : function(component, event, helper) {
        helper.hideSpinner(component);
	},
    onCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
     handleLoad: function (component, event, helper) {
		console.log('handleLoad  cmp---'+component.find("Subscription_Model").get("v.value"));	
        let subscriptionModel = component.find("Subscription_Model").get("v.value");	
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){	
            component.set('v.caseModel',subscriptionModel);	
        }else{	
            component.set('v.caseModel','ila');	
        }	
    },	
    requestPCINumberChange: function (component, event, helper) {
		let requestedPCINumber = component.find("requestedPCINumber").get("v.value");
		if(requestedPCINumber != null && requestedPCINumber != ''){
            console.log('Requested PCI Number:'+requestedPCINumber);
            var myValues= component.get("v.cc_cardPCINumber");
            console.log("My Values",JSON.stringify(myValues));
            myValues.findIndex(item => {
                //console.log('Item Card Id:'+item.cardId);
                if(item.cardId == requestedPCINumber){
                	console.log('Item Card Id:'+item.cardId);
                	console.log('Item Card cardProductionConfigurationId:'+item.cardObj.cardProductionConfigurationId);
                	console.log('Requested PCI Number:'+requestedPCINumber);

                    if(item.cardObj.productMappingCode != '')
                    	component.set( 'v.requestedCardType' , item.cardObj.productMappingCode );
                    else
                		component.set('v.requestedCardType',null);
                	console.log('IBAN Account:'+item.cardObj.holdAccount);
                	
                	if(item.cardObj.holdAccount != '' && item.cardObj.holdAccount != null)
                    	component.set('v.holdAccount', item.cardObj.holdAccount);
                	else
                		component.set('v.holdAccount', null);
                    
                	if(item.cardObj.holdAmount != '' && item.cardObj.holdAmount != null)
                    	component.set('v.existingHoldAmount', item.cardObj.holdAmount);
                	else
                		component.set('v.existingHoldAmount', null);
                    if(item.cardObj.holdAccountType != '' && item.cardObj.holdAccountType != null)
                		component.set('v.holdAccountType', item.cardObj.holdAccountType);
                    else
                    	component.set('v.holdAccountType', null);
                	if(item.cardObj.holdReference != '' && item.cardObj.holdReference != null)
                    	component.set('v.holdReferenceNumber', item.cardObj.holdReference);
                	else
                		component.set('v.holdReferenceNumber', null);
                
                	if(item.cardObj.cardProductionConfigurationId != '' && item.cardObj.cardProductionConfigurationId != null)
                    	component.set('v.cardProductionConfigurationId',JSON.stringify(item.cardObj.cardProductionConfigurationId));
                	else
                		component.set('v.cardProductionConfigurationId', null);
                	//CH01: Start
                	if(item.cardObj.maskedCardNumber != '' && item.cardObj.maskedCardNumber != null)
						component.set('v.maskedCardNumber', item.cardObj.maskedCardNumber);
                    else
                		component.set('v.maskedCardNumber', null);
                	//CH01: END
                }
            });

		}else{
			component.set("v.requestedCardType",null);
            component.set('v.holdAccount', null);
            component.set('v.existingHoldAmount', null);
            component.set('v.holdReferenceNumber', null);
		}
        component.find('apexService').request(component.get('c.loadCardDetailsToFetchLimit'), {
             accID : component.get("v.recordId"),
             caseModel : component.get("v.caseModel"),
             requestedPCINumber :  requestedPCINumber
        },
        function(response) {
            var result = response.getReturnValue();
            var data = [];
            console.log('Credit Card Details',result);
            console.log('Result Type:', typeof result);
            console.log('Credit Limit:',result.creditLimit);
            component.set('v.currentCreditLimit',result.creditLimit);
            
        });
	},

    
    
})