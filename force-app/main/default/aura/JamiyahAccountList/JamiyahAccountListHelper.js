/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:
 * 		Change History: 
 *             
 *            #CH01# : #Jahangeer Mohammed# #08-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
*/
({
	loadData : function(component, customerId) {
        if ($A.util.isEmpty(customerId)) {
            console.error('JamiyahAccountListHelper.js: customerId not provided');
            return;
        }
        var helper = this;

        component.find('apexService').request(component.get('c.recordTypeServiceRequest'), {},
        function(response){
            //alert('>>>>>>>recordtype res'+JSON.stringify(response));
            component.set('v.recordTypId', response);
        });

        var account = component.get('v.account');
		component.find('apexService').request(component.get('c.loadJamiyahAccountList'), {
		    customerId: customerId,
		    regionName : account.Region_Flag__c
        },
		function(response) {
            var result = response.getReturnValue();
            console.log('result>>>>>', result);
            var data = [];
            var lstJameyas = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.jameyas)) {
                lstJameyas = result.responseData.jameyas;
                //alert('List of Jameyas:'+lstJameyas.size());
                component.set('v.data', lstJameyas);
               //console.log('List of Jameyas:'+lstJameyas.size());
            }

            // for (var i = 0; i < lstJameyas.length; i++) {
            //     var jameya = lstJameyas[i];
            //     data.push(helper.formatData(component, jameya));
            // }
		});

	},
    formatData: function(component, obj){
        var result = {};
        result.id = obj.id;
        result.name = obj.name;
        result.jameyaStatus = obj.jameyaStatus;
        result.organiserCustomerId = obj.organiserCustomerId;
        result.claimedShares = obj.claimedShares;
        result.firstCollectionDate = obj.firstCollectionDate;
        result.cycleContributionAmount = obj.cycleContributionAmount;
        result.numberOfStaff = obj.numberOfStaff;
        return result;

    },
    openRecordDetails : function(component, customerId, jameyaId) {
       component.set('v.jameyaId', jameyaId);
       component.set('v.displayJameyaDetails', true);
    },

    doStopJamiyah: function (cmp){
        console.log('>>>>>>>doStopJamiyah');
        //alert(cmp.find("requestedValue").get("v.value"));
        cmp.set("v.loadingStopJamiyah", true);
        var customerId = cmp.get('v.customerId');
        //var jamiyah = cmp.get('v.stopJamiyah');
        var newCase = cmp.get('v.newCase');
        var account = cmp.get('v.account');
        alert('---> '+JSON.stringify(newCase));
		console.log('>>>>>>>>>>');
        console.log(JSON.stringify(newCase));
        console.log(customerId);
        //console.log(jamiyah);
        cmp.find('apexService').request(cmp.get('c.apexStopJamiyah'), {
            customerId : customerId,
            isAdmin: newCase.Is_Organizer__c,
            newCase : JSON.stringify(newCase),
            regionName:account.Region_Flag__c
        },
        function(response){
            console.log('>>>>>>>doStopJamiyah res', response);
            cmp.find('stop-jamiyah-popup').close();
            cmp.set("v.loadingStopJamiyah", false);
            //component.set('v.recordTypId', response);
        },
        function(resErr){
             cmp.set("v.loadingStopJamiyah", false);
        });
    },

    generateNewCase: function(cmp){

        var selectedJamiyah = cmp.get('v.stopJamiyah');
        console.log('generateNewCase'+selectedJamiyah);

        var newCase = {
            Jamiyah_Id__c: selectedJamiyah.id,
            Is_Organizer__c : selectedJamiyah.isOrganiser,

            RecordTypeId: cmp.get('v.recordTypId')
        };

        if(selectedJamiyah.isOrganiser){
            newCase.Closure_Reason__c = 'Approved';
        }
        console.log('GENERATE NEW CASE----->');
		console.log('NEW CASE'+newCase);
        cmp.set('v.newCase', newCase);
    },

    getRowActions:function(cmp, row, cb){
        var actions = [
            { label: 'Stop Jamiyah', name: 'stop_jamiyah', disabled: (row.jameyaStatus == 'TERMINATED') }
        ];
        setTimeout($A.getCallback(function(){
            cb(actions);
        }), 0);
    },
     sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
        function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    handleLoad : function(cmp) {

	var selectedJamiyah = cmp.get('v.stopJamiyah');
        cmp.find("jamiyahId").set("v.value",selectedJamiyah.id);
        cmp.find("isOrganiser").set("v.value",selectedJamiyah.isOrganiser);
        if(selectedJamiyah.isOrganiser){

           // cmp.find("closureReason").set("v.value","Approved");

        }
        console.log('GENERATE NEW CASE----->');
	},
    //CH01: Start
    loadDataInAuditObject : function(component,jameyaId) {
        var action = component.get("c.createAuditRecordForJamiyahDetails");
        console.log('Jamiyah id in helper:',jameyaId);
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
        console.log('Acc CIF in helper:',accCIF);
        action.setParams({
            accCIF:accCIF,
            jameyaId:jameyaId
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('Fetched Audit Id:',result);
            }
            
        });
        $A.enqueueAction(action);
	},
    //CH01: END
    

})