({
    loadCardDetails : function(component, customerId, cardId, account) {
        var helper = this;
        component.find('apexService').request(component.get('c.loadCardDetails'), {
            customerId: customerId,
            cardId: cardId,
            personEmail: account.PersonEmail,
            regionName: account.Region_Flag__c
        },
        function(response) {
             var result = response.getReturnValue();
             // single card data
             var data = {};
             if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))//responseData.currentCards))
             {
                   data = result.responseData;//result.responseData.currentCards;
                   component.set('v.cardData', data);
                   component.set('v.isEnableButton',true);
                   console.log("Card Details in Upgrade Component---->",JSON.stringify(data));
             }
            else{
                component.set('v.isEnableButton',false);
            }
                                                  
            
        });
        /*component.find('apexService').request(component.get('c.fetchMakerResult'), {
                caseId : component.get("v.caseId")
            },
             function(response) {
             console.log('Response State:',response.getState());
             var result = response.getReturnValue();
             console.log('Maker Result JSON:',JSON.stringify(response.getReturnValue()));
             console.log('Maker Result:',result);    
              if (result != null ) {
                 console.log('Hide Button');
                 component.set("v.isEnableButton",false);
             }else{
                 console.log('Display Button');
                 component.set("v.isEnableButton",true);
             }
             
           });*/
        var action = component.get("c.fetchMakerResult");
        action.setParams({"caseId":component.get("v.caseId")});
        action.setCallback(this, function(response) {
            console.log('Response State:',response.getState());
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                //console.log('Maker Result JSON:',JSON.stringify(response.getReturnValue()));
             	console.log('Maker Result:',result);
                if(result != null ) {
                 	console.log('Hide Button');
                 	component.set("v.isEnableButton",false);
             	}else{
                 	console.log('Display Button');
                 	component.set("v.isEnableButton",true);
             	}
            }
            else if(state === "INCOMPLETE"){
                console.log("Incomplete message");
            }
            else if(state === 'Error'){
                var errors = response.getError();
                if(errors){
                    console.log("Error message: ",+ errors[0].message);
                }else{
                     console.log("UNKNOWN error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})