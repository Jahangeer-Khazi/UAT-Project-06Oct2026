({
    helperMethod : function() {

    },
    CustomerDepositDetailsViaApi: function (component, event, helper) {
        console.log('START CustomerDepositDetailsViaApi ');
        helper.showSpinner(component, event, helper);
        var action = component.get('c.CustomerDepositDetailsViaApi');
        action.setParams(
            {
                AccountId: component.get("v.recordId")
            });
            action.setCallback(this, function (actionResult) {
                var statut = actionResult.getState();
				console.log('statut >> ',JSON.stringify(statut));                
                if (statut === "SUCCESS") {
                    let data = actionResult.getReturnValue();
                    console.log('data >> ',JSON.stringify(data));
                      //  Modified for including Separator
                    // var numberFormatter = new Intl.NumberFormat('en-GB', { style: 'decimal', maximumFractionDigits: 3});
                      var numberFormatter = new Intl.NumberFormat('en-GB', { style: 'currency', currency:'BHD'});
                    if (data) {
                        if(data.status){
                            //component.set("v.balance",data.total_balance);
                            let totalBalance = parseFloat(data.total_balance);
                            let formattedTotalBalance = totalBalance.toFixed(3);
                             //  Modified for including Separator
                           // component.set("v.balance", formattedTotalBalance);
                            component.set("v.balance", numberFormatter.format(formattedTotalBalance));     
                            component.set("v.currency",data.currancy);
                            component.set("v.status",data.status);
                            component.set("v.firstTotal",data.titleValue);
                            console.log('>>> ',component.get("v.currency"));
                        }
                        if(data.statusBoth){ 
                            console.log('in status both')
                            let totalBalanceBoth = parseFloat(data.total_balanceBoth);
                            let formattedTotalBalanceBoth = totalBalanceBoth.toFixed(3);
                          //  component.set("v.balanceBoth", formattedTotalBalanceBoth);
                          //  Modified for including Separator
                            component.set("v.balanceBoth", numberFormatter.format(formattedTotalBalanceBoth));
                            component.set("v.currencyBoth",data.currancyBoth);
                            component.set("v.secondTotal",data.secondTitleValue);
                            if(!$A.util.isEmpty(totalBalanceBoth)){
							  component.set("v.regionOption",true);
                               
                              
                            }
                            else{
                                component.set("v.regionOption",false);	
                                
                            }
                           
                        }
                            
                        if(!data.statusBoth && data.model=='both'){
                             // component.set("v.alburaqError",true);	
                             component.set("v.errorSecond",'No Total Deposit for alburaq customer');
                        }
                          if(!data.status && data.model=='both'){
                             // component.set("v.ilaError",true);	
                             component.set("v.error",'No Total Deposit for ila customer');
                        }
                         if(!data.status && data.model=='ila'){
                           // helper.handleErrors('no Total Deposit for this customer ', '');
                           
                           component.set("v.error",'No Total Deposit for ila customer');
                        }
                         if(!data.status && data.model=='alburaq'){
                           // helper.handleErrors('no Total Deposit for this customer ', '');
                           
                           component.set("v.error",'No Total Deposit for alburaq customer');
                        }
                        }
        
                        
                        helper.hideSpinner(component, event, helper);
                    }
                 else if (statut === "ERROR") {
                    // Process error returned by server
                    helper.handleErrors(actionResult.getError(), '');
                }
                else {
                    console.error("AUTRE ERROR");
                    // Handle other reponse states
                }
            });
        $A.enqueueAction(action);
	},
    showSpinner: function (component, event, helper) {
        component.set("v.showSpinner",true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.showSpinner",false);
    },
    handleErrors: function (errors, addError) {
        // Configure error toast
        let toastParams = {
            mode: "sticky",
            title: "Error",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
})