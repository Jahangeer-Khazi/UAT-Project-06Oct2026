({
	onMinorChange : function(component, event, helper) {
      var fetchMinor = component.find("minor");
      var account = component.get("v.account");
      console.log('Fetching Minor Value from UI:',fetchMinor.get("v.value"));
      account.Minor_Update__pc = fetchMinor.get("v.value");
	},
    
})