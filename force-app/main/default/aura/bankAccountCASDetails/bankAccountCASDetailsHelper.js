({
	loadCASP : function(component,customerId,account,accountId){
        console.log('Helper Function in CAS');
        var helper = this;
         var action = component.get("c.loadCASDet");
         action.setParams({
            customerId: customerId,
            accountId: accountId,
            regionName: account.Region_Flag__c
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('State value from server:',state);
            
            var data = '';
                
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                var casData = result.responseData;
                console.log('CAS Details Length',casData.result.length);
                if(casData.result.length > 0){
                    component.set('v.showCASDetails',true);
                	component.set('v.casData', result.responseData);
                	data = result.responseData.result[0].instruments[0].birthdate;
                    console.log('Data Value:',data);
                	component.set('v.casFormattedData', helper.formatData(component,data));
                    console.log('Get Formatted Date:',component.get('v.casFormattedData'));
                }
                else if(casData.result.length === 0){
                    component.set('v.checkCASDetails',true);
                }
            }
            else if (state === "ERROR") {
            	helper.handleErrors(response.getError());
            }
            
        });
        $A.enqueueAction(action);
    },
    formatData : function(component,CASObject){
        console.log('Birth Date:',CASObject);
        var epochTimestamp = CASObject;
        
        var date = new Date(parseInt(epochTimestamp));
        var day = date.getDate().toString().padStart(2, '0');
        var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var month = monthNames[date.getMonth()];
        var year = date.getFullYear();
        var formattedDate = day + '-' + month + '-' + year;
     	
        /*const timestampInMilliseconds = epochTimestamp * 1000;
        
        //Convert seconds to milliseconds
  		const date = new Date(timestampInMilliseconds);
        const day = date.getDate().toString().padStart(2, '0');
        const monthAbbreviation = date.toLocaleString('default', { month: 'short' });
    	const year = date.getFullYear();
		const formattedDate = `${day}-${monthAbbreviation}-${year}`;
		console.log('After Formatted Date:',formattedDate);*/
        return formattedDate;
     },
    
    handleErrors: function (component,errors) {
        var helper = this;
       //Configure toast error Message Object
		let toastParams = {
			mode: "sticky",
			title: "Error",
			message: errors, // Default error message
			type: "error"
		};
		// Pass the error message if any
		if(errors && Array.isArray(errors) && errors.length > 0) {
			toastParams.message = errors[0].message;
		}
		// Fire error toast
		let toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams(toastParams);
		toastEvent.fire();
	},
     
})