({
	redirectToVF : function(component,caseId) {
		console.log('Redirect to Site address');
        console.log('Id In Redirect Method:',caseId);
        //var vfPageUrl = '/apex/walkinCustomerRegistration_Display?id=' + caseId;
       // window.open(vfPageUrl, '_blank');
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
           "url": "https://ilabank--uatx.sandbox.my.salesforce-sites.com/WalkinDisplayMonitor?id=" +caseId

        });
        urlEvent.fire();
        
	}
})