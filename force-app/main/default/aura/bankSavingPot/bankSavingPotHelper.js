/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:
 * 		Change History: 
 *             
 *            #CH03# : #Jahangeer Mohammed# #06-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
 *            #CH04#: #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705)
*/
({
	loadData : function(component, customerId) {
        if ($A.util.isEmpty(customerId)) {
            console.error('Saving Pot Helper: customerId not provided');
            return;
        }
	    var helper = this;
		var account = component.get('v.account');
        //component.set('v.data',[]);
        //CH01 -Start added by imane : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End
        // CH04 start 
        component.find('apexService').request(component.get('c.getJordanVisibility'), {
            customerId: customerId
        }, function (response) {
            console.log('response saving pot >> ' + response.getReturnValue());
            component.set('v.hideJordanFinancialDetails', response.getReturnValue());
        });
        // CH04 end 

		component.find('apexService').request(component.get('c.loadSavingPots'), {
		    customerId: customerId,
		     regionName : regionName
        },
		function(response) {
            var result = response.getReturnValue();

            console.log('loadSavingPots >>>>>', result);
            var data = [];
            var Alldata = [];//CH02

            var pots = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.pots)) {
                pots = result.responseData.pots;
            }

            for (var i = 0; i < pots.length; i++) {
                var pot = pots[i];
                //CH02:Imane Tsioucha#  Add Saving Pots Filter
               console.log(' pot>> ', JSON.stringify(pot.account.status));
                // #CH04# added component to formData
               Alldata.push(helper.formatData(component, pot));
                if(pot.account.status.toLowerCase() == 'active' || pot.account.status.toLowerCase() == 'inactive' || pot.account.status.toLowerCase() == 'new') {
                    // #CH04# added component to formData
                    data.push(helper.formatData(component, pot));
                    
                }               
            }
            component.set('v.data', data);
            component.set('v.Origindata', Alldata);

            console.log('Account:', data);
		});

	},
    // #CH04# start  
    formatData: function(component, obj){
        var result = {};
        var hideJordanFinancialDetails = component.get('v.hideJordanFinancialDetails');
        result.id = obj.id;
        result.potId = obj.potId;
        result.name = obj.name;
        result.accountAvailableBalance =  hideJordanFinancialDetails ? '' : obj.account.availableBalance;
        result.status = obj.account.status;

        return result;

    },
    // #CH04# end  
    loadPotDetail : function(component, customerId, potId) {
       component.set('v.potId', potId);
       component.set('v.displayPotDetails', true);

       this.openTransactionList(component, customerId, potId);
	},
    openTransactionList : function(component, customerId, potId) {
       component.set('v.potId', potId);
       component.set('v.displayPotTransactions', true);
	},
    //CH03: Start
    loadDataInAuditObject : function(component,potId) {
        var action = component.get("c.createAuditRecordForSavingPotDetails");
        console.log('pot id in helper:',potId);
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
        console.log('Acc CIF in helper:',accCIF);
        action.setParams({
            accCIF:accCIF,
            potId:potId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:',result);
            }
            
        });
        $A.enqueueAction(action);
	},
    //CH03: END
})