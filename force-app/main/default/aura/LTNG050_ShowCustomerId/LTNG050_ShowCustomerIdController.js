({
    doInit: function (component, event, helper) {
        console.log(' start do init ');
        helper.doInit(component, event, helper);
    },
    handleSearch : function(component, event, helper) {
        component.set("v.responseExist", false);
        helper.SearchIban(component,event,helper);
        
    },
    onChangeInputField : function(component,event,helper){
        var searchTerm = component.find("searchInput");
        searchTerm=searchTerm.get("v.value");
        console.log('TTTTTTTTTTTTTTTrrrrrrrrrrrrrrrrTT==> '+searchTerm);
        component.set("v.searchTerm",searchTerm);
    }
    
})