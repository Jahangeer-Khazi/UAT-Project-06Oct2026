({
	myAction : function(component, event, helper) {
		
	},
    
    toggleSection : function(component, event, helper) {
        var isOpen = component.get("v.isOpen");
        component.set("v.isOpen", !isOpen);
    }
 

})