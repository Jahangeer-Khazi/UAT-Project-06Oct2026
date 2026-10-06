/* 		
 * 		Change History: 
 *              #CH01# : Added by Hamza Chaoui *** pass Bahrain_alburaq in case of alburaq Product
 * 				#CH02# : #Jahangeer Mohammed# #07-08-2023# Added Logic for CAS Status(NBA-7983)
 *              #CH03# : #Tsioucha Imane# #13-09-2023
 */
({
	loadData : function(component, customerId) {
        if ($A.util.isEmpty(customerId)) {
            console.error('bankAccountsListHelper.js: customerId not provided');
            return;
        }
	    var helper = this;
        var account = component.get('v.account');
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        var segment = account.Segment__pc;
        component.set('v.segment',segment);
        component.set('v.region',regionName);
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        console.error(regionName);
        console.error(customerId);
        //CH01 -End
		component.find('apexService').request(component.get('c.loadBondList'), {
		    customerId: customerId,
		    regionName: regionName
        },
		function(response) {
		    var result = response.getReturnValue();
            var data = [];
            var bonds = [];
            var instrument=[];
            var investment=[];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.investments)) {
                bonds = result.responseData.investments;
            }

            for (var i = 0; i < bonds.length; i++) {
                var bondObj = bonds[i];
                investment.push(bonds[i]);
                instrument.push(bonds[i].instrument);
                data.push(helper.formatData(component, bondObj));
            }
            component.set('v.data',data);
            component.set('v.instrument',instrument);
            component.set('v.investment',investment);
            console.log('Account:',JSON.stringify(data));
		});

	},
    formatData: function(component, bondObj){
        var result = {};
        result.investmentid = bondObj.id;
        result.ReferenceNo = bondObj.instrument.id;
        result.ISINCode = bondObj.instrument.isInCodeCBB;
        result.ISINName = bondObj.instrument.isInTypeCBB;
        result.Status = bondObj.instrument.status;
        result.invStatus = bondObj.status;
        return result;

    },
    //CH02: Added one parameter accountType
    //CH03: Adding currency and Account Number
    openInstrumentDetails : function(component, instrumentId,investmentId) {
       var instrumentList= component.get('v.instrument');
          instrumentList.findIndex(inst => {
            if(inst.id == instrumentId){
                 console.log('==> selectedinst '+JSON.stringify(inst));
           component.set('v.currentInst',inst);        
        }
       });
       var investmentList =component.get('v.investment');
         investmentList.findIndex(invst => {
            if(invst.id == investmentId){
                 console.log('==> selectedinst '+JSON.stringify(invst));
           component.set('v.currentInvst',invst);        
        }
       });
       component.set('v.displayInstrumentDetails', true);
     //  this.openTransactionList(component, customerId, accountId);
	},
    openTransactionList : function(component, customerId, accountId) {
       component.set('v.accountId', accountId);
       component.set('v.displayAccountTransactions', true);
	},
})