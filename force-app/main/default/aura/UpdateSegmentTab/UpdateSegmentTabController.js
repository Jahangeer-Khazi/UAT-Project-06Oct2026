/* 	
 * 		Change History: 
 *              #CH01# : Added by Hamza Chaoui *** add alburaq  Customization
 *              #CH02# : Added by Aniss Mbarki *** Islamic Banking - Premium Segment - CRM Requirements
 *              #CH03# : Added by Imane Tsioucha : 14-05-2024# Add add new logic for staff segment
 */
({
    init : function(cmp, event, helper) {
          helper.getSegmentOptionsCRM(cmp);
    },
    segmentHandleOnChange : function(cmp, event, helper) {
        var selectedValue = cmp.get("v.segOptSelected");
        console.log('segmentHandleOnChange value >> '+selectedValue);
        cmp.set("v.showChangeSegment", false);
        if(selectedValue == 'Staff'){
            cmp.set("v.showChangeSegment", true);
        }
    },
    onSubmitClick: function(cmp, evt, helper){
        //CH01 -Start added by Hamza Chaoui : add alburaq  Customization
        cmp.set("v.disabledButton",true);
        var account = cmp.get('v.account');
        var segmentChangeTo = cmp.get('v.segOptSelected');
        var isAlburaqProduct = cmp.get('v.isAlburaqProduct');
        var regionName = account.Region_Flag__c;

        console.log('*************>>>> '+account.Subscription_Model__pc);
        if(account.Subscription_Model__pc == 'alburaq' && isAlburaqProduct == true ){
          //#CH02 Start
            console.log('*************>>>> call helper.sendToSegmentChangeMaker(cmp) ');
          helper.sendToSegmentChangeMaker(cmp);
          //#CH02 End   
        }else{
            var pass = false;
            console.log('show segement '+cmp.get("v.showChangeSegment"));
            if(cmp.get("v.showChangeSegment") == true){
                var staf = cmp.find("staff_id");
                var stafIdValue=staf.get("v.value");
                var email=  cmp.find("staff_corporate_email");
                var emailValue=  email.get("v.value");
                console.log('stafIdValue==> '+stafIdValue );
                console.log('emailValue==> '+emailValue );

                if(!stafIdValue || !emailValue ){
                    console.log('errrrrrrrrrrrroor');
                    var toastEvent = $A.get("e.force:showToast");
                    
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Please complete the mandatory fields",
                            "type": "error",
                            "mode": "sticky"
                        });
    
                        toastEvent.fire();
                  
                }else{
                    var selectedValue = cmp.get("v.segOptSelected");
                    console.log('in else selectedValue >> '+selectedValue);
                    if(selectedValue == 'Staff' ){
                        helper.updateAccount(cmp,helper, evt);
                        pass = true;
                    }
                }
            }else{
                pass = true;
            }
            console.log('pass '+pass);
            if(pass){
                if(account.Subscription_Model__pc == 'both' && (segmentChangeTo == 'Staff' || segmentChangeTo == 'STAFF') ){
                    
    
                    // we need to call the Api twice (once with unit = 'neo' , once with unit = 'alburaq')
                    //The two Apis will Change the following : 
                    //  - ila segment will be updated to staff 
                    //  - alburaq segment will be updated to staff
                    
                        helper.updateSegment(cmp,regionName);
                        helper.updateSegment(cmp,regionName+'_alburaq');
                }else{
                    if(cmp.get('v.isAlburaqProduct') == true){
                        regionName += '_alburaq';
                    }
                    helper.updateSegment(cmp,regionName);
                }
            }
        }
        //CH01 -End
    },
    handleLoad: function (component, event, helper) {
		console.log('handleLoad  cmp---');
        let isSubmited = component.find("isSubmitted").get("v.value");
        component.set('v.isSubmited',isSubmited);
	},

    //CH03 -Start
    handleLoadAccount: function (component, event, helper) {
		console.log('handleLoad  handleLoadAccount');
        console.log('account Id >> '+component.get("v.accountId"));

        // let isSubmited = component.find("isSubmitted").get("v.value");
        // component.set('v.isSubmited',isSubmited);
	},
    //CH03 -End
})