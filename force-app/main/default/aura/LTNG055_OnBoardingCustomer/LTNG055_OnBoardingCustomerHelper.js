({
	showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
	},
    initializeVariables: function (component, event, helper) {
		console.log('initializeVariables Start ---');
        let appTax = component.find("ApplicableResidencyTaxId").get("v.value");
        component.set("v.ApplicableResidencyTax",appTax);

        let tax1 = component.find("Tax_Country_1_1").get("v.value");
        component.set("v.tax1",tax1);
        
        let tax2 = component.find("Tax_Country_2_2").get("v.value");
        component.set("v.tax2",tax2);
        
        let tax3 = component.find("Tax_Country_3_3").get("v.value");
        component.set("v.tax3",tax3);
        
        let tax4 = component.find("Tax_Country_4_4").get("v.value");
        component.set("v.tax4",tax4);

        console.log('initializeVariables END');

	},
})