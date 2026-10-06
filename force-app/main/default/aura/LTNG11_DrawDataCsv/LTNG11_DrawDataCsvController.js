({

    showFilesAction: function (component, event, helper) {
        helper.trackWhoClickedOnShowFiles(component, event, helper,'View Files Button');
    },
    downloadAction: function (component, event, helper) {
        helper.downloadAction(component, event, helper);
    },
    handleLoad: function (component, event, helper) {
        let drawStatus = component.find("status").get("v.value");
        let firstApiCall = component.find("firstApiCall").get("v.value");
        var fileNamedata = [{ label: "Original eligible csv", key: "original_eligible" },{ label: "Original ineligible csv", key: "original_ineligible" }];
        if (drawStatus != 'New' && drawStatus != 'Rework' && drawStatus != 'Pending Validation' && firstApiCall == 'Success') {
            fileNamedata.push({ label: "Modified csv", key: "modified" });
            if (drawStatus != 'Ready for Scattering') {
                fileNamedata.push({ label: "Scattered csv", key: "scattered" });
                if (drawStatus != 'Ready for Scattering' && drawStatus != 'Pending ICU Validation 1' && drawStatus != 'ICU Validation 1 Failed' && drawStatus != 'Pending Maker Validation' && drawStatus != 'Maker Validation Failed') {
                    fileNamedata.push({ label: "Ineligible csv", key: "ineligible" });
                }
            }
        }
        component.set('v.fileNamedata', fileNamedata);

        //#CH01 : start
        let draw_type = component.find("draw_type").get("v.value");
        if(draw_type == 'kanzStaff'){
            var action = component.get("c.checkDrawDataVisibilityForKanzStaff");
            action.setParams({
                recordId: component.get('v.recordId')
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state == "SUCCESS") {
                    let result = response.getReturnValue();
                    if(true === result ){
                        component.set('v.showCmp', true);
                    }
                }
                if (state == "ERROR") {
                    helper.handleErrors(response.getError());
                }
            });
            $A.enqueueAction(action);
        }else{
            component.set('v.showCmp', true);
        }
        //#CH01 : End
    },
})