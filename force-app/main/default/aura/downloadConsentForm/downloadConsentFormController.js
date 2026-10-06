({
//Download Reports as Pdf File  
download : function (component,event,helper) {  
        helper.downloadPdfFile(component,event,helper);  
    },
     showPopup : function(component, event, helper){
        component.set('v.vfpage',true);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    
    closeModal : function(component, event, helper){
        component.set('v.vfpage',false);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    }
})