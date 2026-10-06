/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:03-01-2022
 * 		Change History: 
 *			  #CH02# #Imane Tsioucha# #20-02-2024# Add Saving Pots Filter
 *            #CH03# : #Jahangeer Mohammed# #05-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
 *			  #CH04# Maksud Ali #07-01-2026# Added FD Term Deposit Button
              #CH05#: #Aitogram omar# #01-04-2026 Added logic for Dormancy Visibility Restrictions (NBA-11705)
*/
({
	loadData : function(component, customerId,account) {
        var helper = this;
        var isAlburaqProduct = component.get('v.isAlburaqProduct');

        // CH05 start  
        component.find('apexService').request(component.get('c.getJordanVisibility'), {
            customerId: customerId
        }, function (response) {
            console.log('response term deposit >> ' + response.getReturnValue());
            component.set('v.hideJordanFinancialDetails', response.getReturnValue());
        });
        // CH05 end  
        
        component.find('apexService').request(component.get('c.termDepositList'), {
		    customerId: customerId,
            regionName:component.get('v.regionName')
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log('ResulTT--> ',result);
            console.log('ResulTT 2 Param--> ',result.responseData.termDeposits); 
           
            var data = [];
            var Alldata = [];//CH02

            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.termDeposits)) {
                
                var termDep = result.responseData.termDeposits;
                var fdTermDeposits = []; //Added for //CH04
                
                for (var i = 0; i < termDep.length; i++) {
                    var termDepObj = termDep[i];
                    Alldata.push(helper.formatData(component,termDepObj));

                    console.log('--- Term Deposit OBJ --> ',termDepObj);
                     console.log('--- isAlburaqProduct --> ',isAlburaqProduct);
                   // data.push(helper.formatData(component, termDepObj));
                    if(termDepObj.progressCode.toLowerCase() == 'active')   data.push(helper.formatData(component, termDepObj));//CH02

                    //CH04 - START
                    let progressCode = helper.capitalizeFirst(termDepObj.progressCode.toLowerCase());
                    
                    if(progressCode == "Prepaid"){
                        progressCode = "Early Withdrawn"
                    }
                    
                    if(fdTermDeposits.length == 0){
                        fdTermDeposits.push({
                            fdStatus : progressCode,
                            currency : termDepObj.currency.code,
                            totalDepositAmount : progressCode == 'Matured' ? termDepObj.matruityAmount : termDepObj.depositAmount
                        });
                    }
                    else {
                        let termDepositIndex = fdTermDeposits.findIndex(f => f.fdStatus.toLowerCase() == progressCode.toLowerCase() && f.currency.toLowerCase() == termDepObj.currency.code.toLowerCase());
                        if(termDepositIndex < 0){
                            fdTermDeposits.push({
                                fdStatus : progressCode,
                                currency : termDepObj.currency.code,
                                totalDepositAmount : progressCode == 'Matured' ? termDepObj.matruityAmount : termDepObj.depositAmount
                            });
                        }
                        else {
                            fdTermDeposits[termDepositIndex].totalDepositAmount += (progressCode == 'Matured' ? termDepObj.matruityAmount : termDepObj.depositAmount);
                        }
                    }
                    //CH04 - END
                }
                
                //CH04 - START
                for(let cnt = 0; cnt < fdTermDeposits.length;cnt++){
                    if(fdTermDeposits[cnt].currency == 'BHD'){
                        fdTermDeposits[cnt].totalDepositAmount = fdTermDeposits[cnt].totalDepositAmount.toFixed(3);
                    }
                    else {
                        fdTermDeposits[cnt].totalDepositAmount = fdTermDeposits[cnt].totalDepositAmount.toFixed(2);
                    }
                }
                //Sorting data in ASC order (Status)
                fdTermDeposits.sort((a, b) => a.fdStatus.localeCompare(b.fdStatus));
				component.set('v.fdData', fdTermDeposits); 
                //CH04 - END
            }
            console.log("Term Deposit data is loaded",data);
            
            component.set('v.data', data); 
            component.set('v.Origindata', Alldata);

           
		});
       
   },
    //CH04
    checkUserCanViewFDButton: function(component,helper,customerId){
        console.log("80 User In Queue");
    	var isAlburaqProduct = component.get('v.isAlburaqProduct');
        
        var account = component.get('v.account');
        console.log('101 ', JSON.stringify(account));
        try {
         	component.find('apexService').request(component.get('c.canUserViewFDButton'), {
                regionFlag : account.Region_Flag__pc,
                segment : account.Segment__pc
            },
            function(response) {
                var result = response.getReturnValue();
                console.log("response user in queue ",result);
                component.set("v.canUserViewTermDepositButton",result);
            });   
        }
        catch(exception){
            console.erro("Error while checking the UserInQueue - ",exception);
        }
	},
    //CH04
    formatData: function(component, termDepObj) {
        var rec = {};
        rec.name = termDepObj.name;
        rec.urbisContractId =  termDepObj.urbisContractId;
        rec.statusCode =  termDepObj.progressCode;
        if(rec.statusCode.toUpperCase() == 'PREPAID'){
            rec.statusCode = 'Early Withdrawn';
        }
        return rec;
	}, 
    //CH03: Start
    loadDataInAuditObject : function(component,termDepositId) {
        var action = component.get("c.createAuditRecordForTermDepositDetails");
        console.log('term deposit id in helper:',termDepositId);
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
        console.log('Acc CIF in helper:',accCIF);
        var isAlburaqProduct = component.get('v.isAlburaqProduct');
        console.log('Product:',isAlburaqProduct);
        action.setParams({
            accCIF:accCIF,
            termDepositId:termDepositId,
            isAlburaqProduct:isAlburaqProduct
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
    //CH03: END
    //CH04 - START
    capitalizeFirst : function(str) {
      return str.charAt(0).toUpperCase() + str.slice(1);
    }
    //CH04 - END
})