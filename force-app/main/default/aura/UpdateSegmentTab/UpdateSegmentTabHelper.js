/* 	
 * 		Change History: 
 *              #CH01# : Added by Hamza Chaoui *** pass Bahrain_alburaq in case of alburaq Product
 *              #CH02# : Added by Aniss Mbarki *** Islamic Banking - Premium Segment - CRM Requirements
 *              #CH03# : Added by Imane Tsioucha : 14-05-2024# Add add new logic for staff segment
 */
({
    getSegmentOptionsCRM: function(cmp){
        var customerId = cmp.get('v.customerId');
        var caseId = cmp.get("v.caseId");
        var account = cmp.get('v.account');
        console.log('customerId >> '+customerId);
        console.log('caseId >> '+caseId);
        console.log('account >> '+JSON.stringify(account));
        console.log('account Id >> '+JSON.stringify(account.Id));
        cmp.set("v.accountId", account.Id);

        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        if(cmp.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End

        cmp.find('apexService').request(cmp.get('c.loadSegmentOptionsCRM'), {
            customerId: customerId,
            caseId: caseId,
            regionName:regionName
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log("result", result);
            if (result.isSuccess === true && !$A.util.isEmpty(result.responseData)) {

                //generate card options
                var lstSegOpts = result.responseData.segmentOptions ? result.responseData.segmentOptions : [];
                var segOpts = [];
                lstSegOpts.forEach(segOpt => {
                    segOpts.push({label: segOpt.segmentName, value: segOpt.segmentCrmId});
                });

                var lstCardOpts = result.responseData.cardOptions ? result.responseData.cardOptions : [];
                var cardOpts = [];
                lstCardOpts.forEach(cardOpt => {
                    cardOpts.push({label: cardOpt.cardDisplayName, value: cardOpt.cardAfsId})
                });

                var lstDisOpts = result.responseData.discountOptions ? result.responseData.discountOptions : [];
                var disOpts = [];
                // cmp.set("v.showChangeSegment", false);
                console.log("options value "+JSON.stringify(lstDisOpts));
                lstDisOpts.forEach(disOpt => {
                    disOpts.push({label: disOpt.displayName, value: disOpt.name})
                    // if(disOpt.name == "STAF") cmp.set("v.showChangeSegment", true);
                });

                cmp.set("v.segmentCardOpts", cardOpts);
                cmp.set("v.segmentCurCards", result.responseData.currentCards ? result.responseData.currentCards : []);
                cmp.set("v.segmentCurrent", result.responseData.currentSegment ? result.responseData.currentSegment : {});
                cmp.set("v.segmentDisOpts", disOpts);
                cmp.set("v.segmentOpts", segOpts);
				console.error(segOpts);
                cmp.set("v.segmenttransitionInProgress", result.responseData.transitionInProgress ? result.responseData.transitionInProgress : false);
                
            }

		});
    },
    
    updateSegment: function(cmp,regionName){
        var customerId = cmp.get('v.customerId');
        var caseId = cmp.get('v.caseId');
        var account = cmp.get('v.account');
        var helper = this;
        cmp.find('apexService').request(cmp.get('c.updateSegment'), {
            customerId: customerId,
            newSegmentCRMId: cmp.get('v.segOptSelected'),
            caseId: caseId,
            regionName:regionName

        },
        function(response) {
            var result = response.getReturnValue();
            console.log("res", response);
            if (true === result.isSuccess ) {
				cmp.find('apexService').showSuccessMessage("Update Segment successful");
                // refresh the standard page view
                $A.get('e.force:refreshView').fire();
            }
        });
    },

    //CH03 -Start
    updateAccount: function(cmp,helper, event){
        var account = cmp.get('v.account');
        console.log('account id '+account.Id);
        console.log('staff id '+cmp.find("staff_id").get("v.value"));
        console.log('staff corporate '+cmp.find("staff_corporate_email").get("v.value"));
        cmp.find('apexService').request(cmp.get('c.updateAccount'), {
            accountId: account.Id,
            staffId: cmp.find("staff_id").get("v.value"),
            staffCorporateEmail: cmp.find("staff_corporate_email").get("v.value")
        },
        function(response) {
            console.log('response ');
            var result = response.getReturnValue();
            console.log("updateAccount res", response);
            if (true === result.isSuccess ) {
				// cmp.find('apexService').showSuccessMessage("Update Segment successful");
                // refresh the standard page view
                // $A.get('e.force:refreshView').fire();
            }
        });
    },
      //CH03 -End

    //#CH02 Start
    sendToSegmentChangeMaker: function(cmp){
        var discountName;
        var account = cmp.get('v.account');
        var newSegment = cmp.get('v.segOptSelected');
        if(newSegment == 'Premium' && account.Subscription_Model__pc == 'alburaq' ){
            discountName = cmp.find("segMemberShipDiscount").get("v.value");
        }else{
            discountName = null;
        }
        
        cmp.find('apexService').request(cmp.get('c.sendToSegmentChangeMaker'), {
            caseId: cmp.get('v.caseId'),
            currentSegment: cmp.get('v.segmentCurrent').segmentName,
            newSegment: newSegment,
            discountName: discountName
        },
        function(response) {
            var state = response.getState();
			if (state == "SUCCESS") {
                console.log("the OwnerId changed sucssfully to SegmentChangeMaker");
                $A.get('e.force:refreshView').fire();
			}
        });
    },
    //#CH02 End

})