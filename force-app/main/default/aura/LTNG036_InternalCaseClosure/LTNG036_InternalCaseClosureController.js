({
    init : function(component, event, helper) {
        helper.loadCase(component, component.get('v.recordId'));
    },
    onViewRefresh : function(component, event, helper) {
        helper.loadCase(component, component.get('v.recordId'));
    },
    onSubmitClick: function(component, event, helper) {
        helper.showSpinner(component);
        event.preventDefault();       // stop the form from submitting
        var fields = event.getParam('fields');       
        var prizeType = fields.Prize_Won__c;
        var Sponsored = fields.Sponsor_Prize__c;
        var subType = component.get("v.subType");
        var sponDetail= fields.Sponsor_Details__c;
        if(subType=='Roadshow'){
            if ($A.util.isEmpty(prizeType)) {
                component.find('apexService').showWarningMessage("Prize Type is required");
                component.set("v.showSpinner",false);
                return;
            }
            
            var isSponsored = prizeType.indexOf('Gift') >= 0;
            if (isSponsored) {
                if ($A.util.isEmpty(Sponsored)) {
                    component.find('apexService').showWarningMessage("Sponsored Prize is required");
                    component.set("v.showSpinner",false);
                    return;
                }
                var isVoucher = Sponsored.indexOf('Voucher') >= 0;
                if (isVoucher) {
                    if ($A.util.isEmpty(sponDetail)) {
                        component.find('apexService').showWarningMessage("Sponsored Detail is required");
                        component.set("v.showSpinner",false);
                        return;
                    }
                }
            }
        }
        var fields = event.getParam('fields');
        fields["Status"] = "Closed";
        component.find("caseIdentification").submit(fields);
    },
    handleSuccess: function(component, event, helper) {
        console.log('Success##');
        $A.get('e.force:refreshView').fire();
        // Call the navigation service here
    },
    handleError:function(component, event, helper) {
        console.log('failure##');
        helper.hideSpinner(component);
        // Call the navigation service here
    }
})