({
    doInit: function (component, event, helper) {
		console.log('doInit');
        helper.getDrawList(component, event, helper);
    },
    drawToChange : function (component, event, helper) {
        console.error('drawToChange =================>>>>');
        var myValues= component.get("v.drawList");
        var value = component.find("drawToChange").get("v.value");
        if(value == ''){
            component.set('v.currentDraw','{}');
            return ;
        }
        myValues.findIndex(item => {
            if(item.id == value){
                component.set('v.currentDraw',item)
            }
        });
	},
	drawTypeChange : function (component, event, helper) {
        console.error('drawTypeChange =================>>>>');
        helper.getDrawList(component, event, helper);
	},
	regionFlagChange : function (component, event, helper) {
        console.error('regionFlagChange =================>>>>');
        helper.getDrawList(component, event, helper);
	}
})