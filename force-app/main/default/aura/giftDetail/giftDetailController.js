/**
 * Created by Himanshu on 17/01/2022.
 */

({
     init : function(component, event, helper) {
             var customerId = component.get('v.customerId');
             console.log('getDetails customerId >> ' +customerId);
             var action = component.get("c.getSentGifts");
             action.setParams({
                     customerId: customerId
                });
             action.setCallback(this, function (response) {
                 var state = response.getState();
                  console.log('State > ' +state);
                 console.log('>>>>>>> res ' +JSON.stringify(response.getReturnValue()));
                 var data = response.getReturnValue().responseData;
                 console.log('>>>>>>> data ' +data);

                   if (state == "SUCCESS") {

                      if(!$A.util.isEmpty(data)){
                          component.set('v.giftRecords', data.gifts);

                      }else{
                             console.error('No data found');
                             this.fireToast('Error', 'No file found', 5000 , 'Error', 'dismissible' );
                        }

                  }else if(state == "ERROR"){
                       this.handleErrors(component, response.getError());
                  }

                 });

              $A.enqueueAction(action);
    },

    fireToast : function(title, message, duration, type, mode ){

     	    $A.get("e.force:showToast").setParams({
                                title : title,
                                message: message,
                                duration: duration,
                                key: 'info_alt',
                                type: type,
                                mode: mode
            }).fire();

       },
       handleErrors: function (cmp, errors) {
                 if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                        this.fireToast('Error', errors[0].message , 5000 , 'Error', 'dismissible' );

                    }
                }

            }
});