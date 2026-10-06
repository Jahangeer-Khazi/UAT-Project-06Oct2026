({
    open : function(component, event, helper) {
        var dialog = component.find('window');
        $A.util.addClass(dialog, 'slds-fade-in-open');
        var dialogBackground = component.find('dialog-back');
        $A.util.addClass(dialogBackground, 'slds-backdrop_open');
    },
    close : function(component, event, helper) {
        var isRefreshOnClose = component.get('v.refreshPageOnClose');
        if(isRefreshOnClose){
            $A.get('e.force:refreshView').fire();
        }
        else{
            var dialog = component.find('window');
            $A.util.removeClass(dialog, 'slds-fade-in-open');
            var dialogBackground = component.find('dialog-back');
            $A.util.removeClass(dialogBackground, 'slds-backdrop_open');    
        }        
    }
})