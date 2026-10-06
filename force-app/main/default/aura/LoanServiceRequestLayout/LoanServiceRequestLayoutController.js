({
	doInit: function (component, event, helper) {
        helper.doInit(component, event, helper);
    },
    handleOnload: function (component, event, helper) {
        console.log("on load form !");
       component.find("caseModel").set("v.value",'');
    },
    handleOnSubmit: function (component, event, helper) {
        console.log('handleOnSubmit');
        var subjectVal = component.find("subject").get("v.value");
        var descriptionVal = component.find("description").get("v.value");
        var modelVal = component.find("caseModel").get("v.value");
        var typeVal = component.find("type").get("v.value");
        var subtypeVal = component.find("subType").get("v.value");
        var originVal = component.find("origin").get("v.value");
        var natureVal = component.find("nature").get("v.value");
        var reasonVal = component.find("Reason").get("v.value");
        if(subjectVal == '' || descriptionVal == '' || modelVal == '' || typeVal == '' || subtypeVal == '' || originVal == '' || natureVal == '' || reasonVal == '' ) {
            component.set("v.isErrorVisible",true);
            window.setTimeout($A.getCallback(function () {
                const errCmp = component.find("header_section");
                if (!errCmp || !errCmp.getElement) { return; }
                
                const el = errCmp.getElement();
                const scroller = (function getScrollableParent(node) {
                    let n = node;
                    while (n && n !== document.body) {
                        const s = window.getComputedStyle(n);
                        if ((/auto|scroll/).test(s.overflowY) && n.scrollHeight > n.clientHeight) return n;
                        n = n.parentNode;
                    }
                    return window;
                })(el);
                
                try {
                    el.scrollIntoView({ behavior: "smooth", block: "start", inline: "nearest" });
                } catch (e) {
                    const rect = el.getBoundingClientRect();
                    const top = (scroller === window)
                    ? window.pageYOffset + rect.top - 16
                    : scroller.scrollTop + (rect.top - scroller.getBoundingClientRect().top) - 16;
                    
                    if (scroller === window) {
                        window.scrollTo(0, top);
                    } else {
                        scroller.scrollTop = top;
                    }
                }
            }), 0);
            return;
        }
        
        component.set("v.isErrorVisible",false);
        helper.showSpinner(component);
        component.find('form').submit();
        
    },
    handleTypeChange:function (component, event, helper) {
        console.log('handleOnChange');
        var typeOp = component.find("type").get("v.value");
		component.set("v.typeOption",typeOp);

        if(typeOp == "Collection Letters"){
            component.set("v.subjectValue", "Loan / Finance Collection Letter");
            component.set("v.descriptionValue", "New Loan / Finance Collection Letter");

        } else if(typeOp == "New Loan / Finance Service Request"){
            component.set("v.subjectValue", "Loan / Finance Service Request");
            component.set("v.descriptionValue", "New Loan / Finance Service Request");
 
        }

    },
        handleSubTypeChange: function (component, event, helper) {
            var subTypeValue = component.find("subType").get("v.value");
            var letterTypeField = component.find("letter");
            if (subTypeValue === "Outstanding balance Letter") {
                letterTypeField.set("v.value", "Outstanding Balance");
            } else if (subTypeValue === "No Liability Letter") {
                letterTypeField.set("v.value", "No Liability");
            }
        },
 
    handleOnSuccess: function (component, event, helper) {
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "success",
            "title": "Success!",
            "message": "Case has been created successfully."
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();

        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParam("response").id,
            "slideDevName": "detail"
        });
        navEvt.fire();
     //   helper.closeCase(component, event, helper,event.getParam("response").id);
    },
    handleOnError: function (component, event, helper) {
        helper.hideSpinner(component);
    },
    onCancel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleLoad: function (component, event, helper) { 
		console.log('handleLoad  cmp---');
        let subscriptionModel = component.find("Subscription_Model").get("v.value");
        if( subscriptionModel != null && subscriptionModel == 'alburaq' ){
            component.set('v.caseModel',subscriptionModel);
        }else{
            component.set('v.caseModel','ila');
        }
	},
})