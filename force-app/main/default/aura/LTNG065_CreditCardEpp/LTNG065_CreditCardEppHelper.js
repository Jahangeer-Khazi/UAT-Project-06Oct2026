/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:23-09-2021
 * 		Change History: 
 *			  
*/
({
    
    loadCaseData: function(component, event,helper) {
        var recordId = component.get('v.recordId');
         var helper = this;
        component.find('apexService').request(component.get('c.loadCaseDetail'), {
		    "caseId": recordId
        },
       function(response) {
		    var result = response.getReturnValue();
            console.log('Response from Server Load Case Data--> ',result[0]);
           	var data = [];
            if (result[0].Customer_CIF__c) {             
             helper.loadData(component,result[0].Customer_CIF__c,result[0].cc_PCI_Id__c,result[0].Region_Flag__c,result[0].LetterReferenceNumberB__c);
            }
                
        });
        
    },
	loadData : function(component,customerId,pciNumber,regionName,planNumber) {
      var helper = this;
      console.log('insde CustomerId in EPP Helper:', customerId);
      console.log('insdie PCI Number in EPP Helper:',pciNumber);
     
      
      component.find('apexService').request(component.get('c.loadEPPList'), {
		    "customerId": customerId,
            "pciNumber": pciNumber,
             regionName:regionName
        },
       function(response) {
		    var result = response.getReturnValue();
            console.log('Response from Server--> ',result.responseData);
           	var data = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.eppList)) {
               
                var numOfEPP = result.responseData.eppList;
                console.log('ResulTT inside IF Cards--> ',numOfEPP);
                for (var i = 0; i < numOfEPP.length; i++) {
                    var eppObj = numOfEPP[i];
                    console.log('--- EPP OBJ --> ',eppObj);
                    data.push(helper.formatData(component, eppObj));
                    
                }
            }
            console.log("EPPList data is loaded",data);
            component.set('v.data', data); 
            component.set('v.eppSelected',false);
           // Logic to find rows based on a particular value
           
           var selectedPlan = planNumber;
           console.log("EPPList data is loaded",selectedPlan);
           if(selectedPlan){
               var selectedKeys = [];
                data.forEach(function(row) {
                     console.log("planNumber",planNumber);
                    if (row.planNumber === selectedPlan) { // Your specific value check
                        selectedKeys.push(row.planNumber);                    
                          component.set('v.selectedEPPRow',row);
                          component.set('v.eppTargetData',row);
                          component.set('v.eppSelected',true);
                          component.set('v.SelectedPlan',row.planNumber);
                    }
                });
               console.log("selectedKeys",selectedKeys);
                // Set the selectedRows attribute to pre-select these rows
                component.set("v.selectedRowIds", selectedKeys);
           }
                
        });
        
    },
	formatData: function(component, eppObj) {
        var rec = {};
        rec.merchant = eppObj.merchant;
        rec.planNumber =  eppObj.planNumber;
        rec.tenor =  eppObj.tenor;
        rec.transactionAmount = eppObj.transactionAmount;
        rec.remainingBalance = eppObj.remainingBalance;
        rec.installmentAmount = eppObj.installmentAmount;
        rec.numberOfInstallmentsRemaining = eppObj.numberOfInstallmentsRemaining;
        rec.numberOfInstallmentsPaid = eppObj.numberOfInstallmentsPaid;
        rec.installmentBookingDate = eppObj.installmentBookingDate;
        rec.currencycode=eppObj.currency.code;
        //rec.status = 'ACTIVE';
        rec.status = eppObj.status;
        return rec;
	},    
       
    
})