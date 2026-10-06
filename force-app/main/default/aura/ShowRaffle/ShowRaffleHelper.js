/**
 * @description       : This component it's used as a button to launch visualforce
 * @author            : ismael.ocana
 * @group             : 
 * @last modified on  : 19/10/2021
 * @last modified by  : ismael.ocana
**/
({
    init : function(cmp) {
        let drawId = cmp.get("v.drawId");
        console.log('drawId', drawId);
        let apexAction = cmp.get("c.getURL");

        apexAction.setParams({
            drawId : drawId
        });

        apexAction.setCallback(this, (response) => {
            let state = response.getState();
            console.log('state', state);
            console.log('response', response);
            if(state == "SUCCESS"){
                let result = response.getReturnValue();
                //call api to get winners list
                this.getWinnersListApi(cmp,drawId, result);
            }
            else{
                let errors = response.getError();
                let strError;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        strError = errors[0].message;
                    }
                } else {
                    strError = "Unknown error";
                }
                this.showToast("Error!", strError, "error");
                this.closeModal();
            }
        });
        $A.enqueueAction(apexAction);
    },  
    getWinnersListApi : function (cmp,drawId, templateId) {
        let apexAction = cmp.get("c.createWinnerListApi");

        apexAction.setParams({
            drawId : drawId
        });

        apexAction.setCallback(this, (response) => {
            let state = response.getState();
            console.log('state', state);
            console.log('response', response);
            if(state == "SUCCESS"){
                let isError = response.getReturnValue();
                if(isError == true){
                    this.showToast("Error!", 'Error from server side for more information check the System Action Or Contact your administrator', "error");
                }else{
                    this.openVisualforce(drawId, templateId);
                }
            }
            else{
                let errors = response.getError();
                let strError;
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        strError = errors[0].message;
                    }
                } else {
                    strError = "Unknown error";
                }
                this.showToast("Error!", strError, "error");
            }
            this.closeModal();
            $A.get('e.force:refreshView').fire();
        });
        $A.enqueueAction(apexAction);
    }, 
    openVisualforce : function (drawId, result) {
        window.open('/' + result + '?drawId=' + drawId,'_blank');
    }, 
    showToast : function(title, message, type){
    	var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
            "title"		: title,
            "message"	: message,
            "mode"	: 'sticky',
            "type"		: type
        });
        toastEvent.fire();
    },
    closeModal : function(){
        $A.get("e.force:closeQuickAction").fire();
    }
})