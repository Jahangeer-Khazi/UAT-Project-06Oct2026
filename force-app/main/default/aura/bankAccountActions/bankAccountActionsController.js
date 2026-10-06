/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History: 
 *			   #CH03# #Jahangeer Mohammed# #04-07-2022# Added Logic for Embossing Name(PI-3384)
 *             
 *
 */
({
    init : function(component, event, helper) {
              
        /*
        var options = [
            {'label': 'Request First Card', 'value': 'Request First Card', 'helpText':''},
        ];
        */
        var account = component.get('v.account');
        component.set('v.regionName',account.Region_Flag__c);
        //#CH02 : added by Aniss 20-06-2022
        component.find('apexService').request(component.get('c.visibilityOptionsCheck'), {
            caseId: component.get('v.caseId'),
        },
        function(response) {
            var result = response.getReturnValue();
            var caseStatus = result.Status; 
            var profileName = result.Profile;
            component.set("v.caseStatus",caseStatus);
            component.set("v.profileName",profileName);

            if(caseStatus != 'Closed'){
                var options = [
                    {'label': 'Issue New Card (With Issuance Fee)', 'value': 'Issue New Card (With Issuance Fee)', 'helpText':''}        
                ];

                if( profileName != null && ( profileName.includes('Admin') || profileName == 'RMT' || profileName == 'ila Risk') ){
                    options.push({'label': 'Issue New Card (Without Issuance Fee)', 'value': 'Issue New Card (Without Issuance Fee)', 'helpText':''});
                }
                component.set('v.accountActionTypeOptions', options);
                //CH03: Start
                var FName = component.get('v.account.FirstName');
                var LName = component.get('v.account.LastName');
                var embName = FName +' '+LName;
                console.log('Emb Name:',embName);
                component.set('v.embossingName',embName);
                //CH03: END
            }
        });
        //#CH02 : END
        
        //helper.loadCardDetails(component, component.get('v.customerId'), component.get('v.cardId'));
	},
    onSubmitClick : function(component, event, helper) {
         component.set("v.isButtonDisabled","true");
        var selectedAccountActionType = component.get('v.selectedAccountActionType');
        if ($A.util.isEmpty(selectedAccountActionType)) {
            component.find('apexService').showErrorMessage("Action is required");
            return;
        }
        
        var customerId = component.get('v.customerId');
        var accountDetails = component.get('v.accountDetails');
        var caseId = component.get('v.caseId');
        var nm=component.find('embossingName').get('v.value');
        //alert('2nd'+nm);
        //
        //#CH02 : add embossingName
        var requestData = {
            accountId: accountDetails.iban,
            productType: component.get('v.productType'),
            deliveryType: component.get('v.deliveryType'),
            embossName: component.find('embossingName').get('v.value'),
            status: "Inactive",
        };

        if ('Request First Card' === selectedAccountActionType || 'Issue New Card (With Issuance Fee)' === selectedAccountActionType || 
            'Issue New Card (Without Issuance Fee)' === selectedAccountActionType ) {
                
            if ($A.util.isEmpty(requestData.productType)) {
                component.find('apexService').showErrorMessage("Product Type is required");
                return;
            }
            if ($A.util.isEmpty(requestData.deliveryType)) {
                component.find('apexService').showErrorMessage("Delivery Type is required");
                return;
            }
            if ($A.util.isEmpty(requestData.embossName)) {
                component.find('apexService').showErrorMessage("Emboss Name is required");
                return;
            }
            if ( !$A.util.isEmpty(requestData.embossName) && (requestData.embossName.length <6 || requestData.embossName.length >24) ) {
                component.find('apexService').showErrorMessage("Emboss name is not within specified character length");
                return;
            }
            
            
            if( 'Issue New Card (With Issuance Fee)' === selectedAccountActionType ){
                requestData["collectFee"] = true;
            }else{
                requestData["collectFee"] = false;
            }

            requestData["cardType"] = "Primary";
        	var account = component.get('v.account');
            helper.processRequestFirstCard(component, customerId, requestData, caseId, account);
            return;

        }
        component.find('apexService').showWarningMessage("Support for this action is Not implemented");
    },
    onActionSelectionChange : function(component, event, helper) {
        var options = component.get('v.accountActionTypeOptions');
        var selectedAccountActionType = component.get('v.selectedAccountActionType');
        var selectedOption = options.find(function(option) {
            return option.value === selectedAccountActionType;
        })
        if (selectedOption && !$A.util.isEmpty(selectedOption.helpText)) {
            component.set('v.selectedActionHelpText', selectedOption.helpText);
            
        } else {
            component.set('v.selectedActionHelpText', undefined);
        }
    },
    valueChanged : function(component, event, helper){
     var selectedValue=  event.getSource().get("v.value");
     //alert('selectedValue#'+JSON.stringify(selectedValue));
     console.log('selectedValue##'+event.getSource());
     console.log('Selected Emboss Name:',selectedValue);
     component.set("v.embossingName",selectedValue);
}

})