/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:03-01-2022
 * 		Change History: 
 *			  #CH01# Added #28-08-2022# Added logic to append dynamic curreny code replacing 
 			   hardcoded BHD to the price value in the formatData method in Helper by Jayanth
              #CH02# #Tsioucha Imane #11-03-2024# Added logic for Term Deposit Certification
              #CH03# #Jahangeer Mohammed #21-05-2024# Added Interest Payment Option and Calculated Interest
              #CH04# #Jahangeer Mohammed #03-06-2024# Added three decimals for BHD and two decimals for Non BHD
              #CH05# #Jahangeer Mohammed #04-07-2024# Added linkedAsCollateral, PCI Number(NBA-10092)
              #CH06# #Maksud Ali #12-08-2025 decimal place issue  (UATNB-228703)

*/
({
	loadTermDepositDetails : function(component, customerId, urbisContractId) {
	    var helper = this;
		component.find('apexService').request(component.get('c.termDepositDetails'), {
		    customerId: customerId,
            urbisContractId: urbisContractId,
            regionName:component.get('v.regionName')
        },
		function(response) {
		    var result = response.getReturnValue();
            
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))
            {
                data = result.responseData.termDeposits;
            }
           
            //component.set('v.termDepositData', data);
            component.set('v.termDepositData', helper.formatData(component,data));
            console.log("Term Deposit Details data---->",JSON.stringify(data));
           // console.log("Term Deposit Date---->",data.startDate);
		});
        console.log('caseId#####'+component.get('v.caseId'));
        let caseId = component.get('v.caseId');
        if(caseId != null && caseId.startsWith('005')){ // case id might contains account id instead of caseid , so added a check
        	helper.fetchCaseStatus(component,event,caseId);    
        }
	},
    formatData : function(component,termDepositObject){
         var helper = this;
        var result = {};
        //CH04: Start
        var countryCurrency = termDepositObject.currency.code;
        //CH04: END
        /////////////////////////////////////////////////// ID START ////////////////////////////////////////////////////////////
        
        result.tdID = termDepositObject.urbisContractId;
        
        ////////////////////////////////////////////////// ID END /////////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////// Name START //////////////////////////////////////////////////////////
        
        result.name = termDepositObject.name;
        
        ////////////////////////////////////////////////// Name END /////////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////// State START /////////////////////////////////////////////////////////
        result.statusCode = termDepositObject.progressCode;
        if(result.statusCode == 'PREPAID'){
            result.statusCode = 'Early Withdrawn';
        }
        /////////////////////////////////////////////////// State END ///////////////////////////////////////////////////////////
        
        //////////////////////////////////////////////////// Currency START ///////////////////////////////////////////////////////
        
        result.currencyCode = termDepositObject.currency.code;
        
        /////////////////////////////////////////////////// Currency END /////////////////////////////////////////////////////////
        
       /////////////////////////////////////////////////// Deposit Amount START ///////////////////////////////////////////////////// 
        var depositAmt = termDepositObject.depositAmount;
        console.log('Deposit Amount',depositAmt);
        if(depositAmt != ''){ //Checking for Staff customers if View Staff Data is Checked.
            //CH04: Start
            if(countryCurrency === 'BHD'){
                var formatDepositAmt = helper.formatCurrency(depositAmt,3,undefined,undefined);
            }else{
                var formatDepositAmt = helper.formatCurrency(depositAmt,2,undefined,undefined);
            }
        	//var formatDepositAmt = helper.formatCurrency(depositAmt,3,undefined,undefined);
            //CH04: END
        	result.depositAmount = formatDepositAmt;
        }
        //////////////////////////////////////////////// Deposit Amount END /////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////// Accrued Interest Amount START ////////////////////////////////////////////////////
        
        if(result.statusCode == 'ACTIVE'){
        	var accruedInterestAmt = termDepositObject.accroudInterest;
        	if(accruedInterestAmt != ''){ //Checking for Staff customers if View Staff Data is Checked.
                //CH04: Start
                if(countryCurrency === 'BHD'){
                    var formatAccruedInterestAmt = helper.formatCurrency(accruedInterestAmt,3,undefined,undefined);
                }else{
                    var formatAccruedInterestAmt = helper.formatCurrency(accruedInterestAmt,2,undefined,undefined);
				}
                 //#CH01# Start
            	 result.accruedInterestAmt = termDepositObject.currency.code+' ' +formatAccruedInterestAmt;
                //#CH01# End
                //CH04: END
            }
        }
        else{
            result.accruedInterestAmt = '';
        }
        
        ///////////////////////////////////////////////////// Accrued Interest Amount END /////////////////////////////////////////
        
        //////////////////////////////////////////////////// Start Date START //////////////////////////////////////////////////////
        
        var termDepStartDate = new Date(termDepositObject.startDate);
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
		var termDepositMonth = (termDepStartDate.getMonth() + 1) + "";
        termDepositMonth = termDepositMonth.length >= 2 ? termDepositMonth : "0" + termDepositMonth;
		var termDepDate = termDepStartDate.getDate() + "";
        termDepDate = termDepDate.length >= 2 ? termDepDate : "0" + termDepDate;
        result.startDate = termDepDate + ' ' + months[termDepStartDate.getMonth()] + ' ' + termDepStartDate.getFullYear();
        
        /////////////////////////////////////////////////// Start Date END //////////////////////////////////////////////////////////

        ////////////////////////////////////////////////// Maturity Date START //////////////////////////////////////////////////////
        
        var termDepMaturityDate = new Date(termDepositObject.matruityDate);
        var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
		var termDepositMaturityMonth = (termDepMaturityDate.getMonth() + 1) + "";
        termDepositMaturityMonth = termDepositMaturityMonth.length >= 2 ? termDepositMaturityMonth : "0" + termDepositMaturityMonth;
		var termDepMatDate = termDepMaturityDate.getDate() + "";
        termDepMatDate = termDepMatDate.length >= 2 ? termDepMatDate : "0" + termDepMatDate;
        result.matruityDate = termDepMatDate + ' ' + months[termDepMaturityDate.getMonth()] + ' ' + termDepMaturityDate.getFullYear();
        
        ////////////////////////////////////////////// Maturity Date END ////////////////////////////////////////////////////////////
        
        ////////////////////////////////////////////// Deposit Duration START ////////////////////////////////////////////////////////
        
        result.depositDurationValue = termDepositObject.depositDuration.value;
        var durationUnit = termDepositObject.depositDuration.unit;
        if(durationUnit == 'm' || durationUnit == 'M' || durationUnit == 'month'){
            result.depositDurationUnit = 'month';
        }
         if(durationUnit == 'y' || durationUnit == 'Y' || durationUnit == 'year'){
            result.depositDurationUnit = 'year';
        }
        
        //result.depositDurationUnit = termDepositObject.depositDuration.unit;
        
        ////////////////////////////////////////////// Deposit Duration END ////////////////////////////////////////////////////////

        
        ///////////////////////////////////////////////// Duration in Days START /////////////////////////////////////////////////////
        
        result.tdCompletedPeriod = termDepositObject.totalNumberOfDays;
        
       ///////////////////////////////////////////////// Duration in Days END /////////////////////////////////////////////////////

        
        ///////////////////////////////////////////////// Annual Interest Rate START ///////////////////////////////////////////////////
        
        var interestRate = termDepositObject.interestRate;
        if(interestRate != ''){ //Checking for Staff customers if View Staff Data is Checked.
            console.log('interestRate interestRate ',interestRate);
        	result.interestRate = (interestRate.toFixed(2)) + '%'; //CH06 - Change Added Maksud - 12 Aug
        }
        
       ///////////////////////////////////////////////// Annual Interest Rate END ///////////////////////////////////////////////////

        ///////////////////////////////////////////////// Maturity Amount START ////////////////////////////////////////////////////////
        
        var maturityAmt = termDepositObject.matruityAmount;
        if(maturityAmt != ''){ //Checking for Staff customers if View Staff Data is Checked.
            //CH04: Start
            if(countryCurrency === 'BHD'){
                var formatMaturityAmt = helper.formatCurrency(maturityAmt,3,undefined,undefined);
            }else{
                var formatMaturityAmt = helper.formatCurrency(maturityAmt,2,undefined,undefined);
            }
            //CH04: END
        	result.matruityAmount = formatMaturityAmt;
            console.log('Maturity Amount:',formatMaturityAmt);
        	//result.matruityAmount = maturityAmt;
        }
        
        //////////////////////////////////////////////// Maturity Amount END ///////////////////////////////////////////////////////////
        
        ///////////////////////////////////////////////// Interest Earned START ///////////////////////////////////////////////////////
        
        if(result.statusCode == 'MATURED' ){
        	var totalInterestEarned = termDepositObject.totalInterestEarned;
            if(totalInterestEarned != ''){ //Checking for Staff customers if View Staff Data is Checked.
                //CH06 Change Start
                let deicmalPlaces = countryCurrency === 'BHD' ? 3 : 2;
                var formatInterestEarned = helper.formatCurrency(totalInterestEarned,deicmalPlaces,undefined,undefined);
            	result.totalInterestEarned = formatInterestEarned;
                //CH06 Change End
            }
        }
        else{
            result.totalInterestEarned = '';
        }
        
       ///////////////////////////////////////////////// Interest Earned END ///////////////////////////////////////////////////////

        
        ///////////////////////////////////////////////////// Proceeds Credited On START //////////////////////////////////////////////
        
        if(result.statusCode == 'MATURED'){
            //var termDepWithdrawDate = new Date(termDepositObject.earlyWithdraw.withdrawDate);
            var termDepWithdrawDate = new Date(termDepositObject.matruityDate);
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            var termDepositWithdrawMonth = (termDepWithdrawDate.getMonth() + 1) + "";
            termDepositWithdrawMonth = termDepositWithdrawMonth.length >= 2 ? termDepositWithdrawMonth : "0" + termDepositWithdrawMonth;
            var termDepWithDate = termDepWithdrawDate.getDate() + "";
            termDepWithDate = termDepWithDate.length >= 2 ? termDepWithDate : "0" + termDepWithDate;
            result.withDrawDate = termDepWithDate + ' ' + months[termDepWithdrawDate.getMonth()] + ' ' + termDepWithdrawDate.getFullYear();
        }
        else{
             result.withDrawDate = '';
        }
        
        ///////////////////////////////////////////////////// Proceeds Credited On END //////////////////////////////////////////////

       
        //////////////////////////////////////// Auto Rollover START ///////////////////////////////////////////////
        result.autoRenew = termDepositObject.autoRenewEnable;
        result.autoRenewAmount = termDepositObject.autoRenewAmount;
        if(result.statusCode == 'ACTIVE' || result.statusCode == 'MATURED'){
            if(result.autoRenew == false){
                result.autoRenewAmount = 'Disabled';
            }
            if(result.autoRenew == true){
                if(result.autoRenewAmount == 'maturityamount')
                    result.autoRenewAmount = 'Principal with Interest';
                else if(result.autoRenewAmount == 'depositamount')
                    result.autoRenewAmount = 'Principal Amount';
            }
            
        }
        else{
            result.autoRenewAmount = '';
        }
        
       //////////////////////////////////////// Auto Rollover END ///////////////////////////////////////////////

        //CH03: Start
      //////////////////////////////////////// Interest Payment Option START ///////////////////////////////////////////////
      
        result.paymentType = termDepositObject.paymentType;
      
      //////////////////////////////////////// Interest Payment Option END ///////////////////////////////////////////////

       //////////////////////////////////////// Calculated Interest START ///////////////////////////////////////////////
        var nextInterestAmount = termDepositObject.nextInterestAmount;
        console.log('Next Interest Amt:',nextInterestAmount);
        if(nextInterestAmount != null){
            result.nextInterestAmount = nextInterestAmount + '/'+ result.paymentType;
        }
        
      
      //////////////////////////////////////// Calculated Interest END ///////////////////////////////////////////////
        //CH03: END
        
        //CH05: Start
        
        //////////////////////////////////////// Linked As Collateral START /////////////////////////////////////////////////
        
        result.linkedAsCollateral = termDepositObject.linkedAsCollateral;

        //#CH06
        //result.linkedAsLoan = termDepositObject.linkedAsLoan; //toDo: check with Shameer
        
        /////////////////////////////////////// Linked As Collateral END ///////////////////////////////////////////////////
        
        //////////////////////////////////////// Linked PCI Number /////////////////////////////////////////////////
        
        result.linkedPciNumber = termDepositObject.linkedPciNumber;
        
        /////////////////////////////////////// Linked PCI Number ///////////////////////////////////////////////////
        
        //CH05: END
        
        if(result.statusCode == 'Early Withdrawn'){
            
           ////////////////////////////////////// Early Withdrawal Fee START ////////////////////////////////////////////////////
           
           var earlyWithDrawFee = termDepositObject.earlyWithdraw.withdrawFee;
           if(earlyWithDrawFee != ''){ //Checking for Staff customers if View Staff Data is Checked.
               
               //CH06 START
               let decimalPlaces = termDepositObject.currency.code == 'BHD' ? 3 : 2;
               
           	var formatWithDrawFee = helper.formatCurrency(earlyWithDrawFee,decimalPlaces,undefined,undefined);
               //CH06 END
               //#CH01# Start
            result.earlyWithdrawFee = termDepositObject.currency.code + ' '+formatWithDrawFee; 
               //#CH01# End
           }
            
           ////////////////////////////////////// Early Withdrawal Fee END ////////////////////////////////////////////////////
          
           ///////////////////////////////////// Date of Early Withdrawal START //////////////////////////////////////////
           	
            var termDepWithdrawDate = new Date(termDepositObject.earlyWithdraw.withdrawDate);
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            var termDepositWithdrawMonth = (termDepWithdrawDate.getMonth() + 1) + "";
            termDepositWithdrawMonth = termDepositWithdrawMonth.length >= 2 ? termDepositWithdrawMonth : "0" + termDepositWithdrawMonth;
            var termDepWithDate = termDepWithdrawDate.getDate() + "";
            termDepWithDate = termDepWithDate.length >= 2 ? termDepWithDate : "0" + termDepWithDate;
            result.earlyWithdrawDate = termDepWithDate + ' ' + months[termDepWithdrawDate.getMonth()] + ' ' + termDepWithdrawDate.getFullYear();
            
            ///////////////////////////////////// Date of Early Withdrawal END //////////////////////////////////////////
            
           result.noOfDaysPassed = termDepositObject.noOfDaysPassed;
           
           var withdrawIntrestRate = termDepositObject.earlyWithdraw.withdrawIntrestRate;
           if(withdrawIntrestRate != ''){ //Checking for Staff customers if View Staff Data is Checked.
              
               //CH06 START
               let decimalPlaces = termDepositObject.currency.code == 'BHD' ? 3 : 2;
               var formatwithdrawIntrestRate =  helper.formatCurrency(withdrawIntrestRate,decimalPlaces,undefined,undefined);
               //CH06 END
           	  console.log('With Draw Interest Rate:',withdrawIntrestRate);
              result.withdrawIntrestRate = formatwithdrawIntrestRate + '%';
           }//CH06 START
            else {
                result.withdrawIntrestRate =(termDepositObject.currency.code == 'BHD' ? '0.000%' : '0.00%');
            }//CH06 END
          
           		
       	  /////////////////////////////////// New Interest Earned START /////////////////////////////////////////////////
           var interestEarned = termDepositObject.totalInterestEarned;
           if(interestEarned != ''){ //Checking for Staff customers if View Staff Data is Checked.
               //CH06 START
               let decimalPlaces = termDepositObject.currency.code == 'BHD' ? 3 : 2;
               
           	   var formatinterestEarned = helper.formatCurrency(interestEarned,decimalPlaces,undefined,undefined);
               //CH06 END
               
               //#CH01# Start
               result.interestEarned = termDepositObject.currency.code + ' '+formatinterestEarned ;
               //#CH01# End
           }//CH06 START
            else {
                result.interestEarned = termDepositObject.currency.code + ' '+ (termDepositObject.currency.code == 'BHD' ? '0.000' : '0.00');
            }//CH06 END
            
           /////////////////////////////////// New Interest Earned START /////////////////////////////////////////////////
           
           ////////////////////////////////// Proceeds Credited On START /////////////////////////////////////////////////
            
            var termDepWithdrawDate = new Date(termDepositObject.earlyWithdraw.withdrawDate);
            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            var termDepositWithdrawMonth = (termDepWithdrawDate.getMonth() + 1) + "";
            termDepositWithdrawMonth = termDepositWithdrawMonth.length >= 2 ? termDepositWithdrawMonth : "0" + termDepositWithdrawMonth;
            var termDepWithDate = termDepWithdrawDate.getDate() + "";
            termDepWithDate = termDepWithDate.length >= 2 ? termDepWithDate : "0" + termDepWithDate;
            result.proceedCreditedOn = termDepWithDate + ' ' + months[termDepWithdrawDate.getMonth()] + ' ' + termDepWithdrawDate.getFullYear();
            
            //result.proceedCreditedOn = result.withDrawDate;
           
            
 		   ////////////////////////////////// Proceeds Credited On END /////////////////////////////////////////////////            
        }
        else{
             result.earlyWithdrawFee = '';
             result.earlyWithdrawDate = '';
             result.noOfDaysPassed = '';
             result.withdrawIntrestRate = '';
             result.interestEarned = '';
             result.proceedCreditedOn = '';
        }
       
        return result;
    },
     formatCurrency : function(number,decPlaces,decSep,thouSep){
        console.log('Inside Format currency');
        decPlaces = isNaN(decPlaces = Math.abs(decPlaces)) ? 2 : decPlaces;

		decSep = typeof decSep === "undefined" ? "." : decSep;

		thouSep = typeof thouSep === "undefined" ? "," : thouSep;

        var sign = number < 0 ? "-" : "";
		var i = String(parseInt(number = Math.abs(Number(number) || 0).toFixed(decPlaces)));
       // console.log('Number to String:'+i);
       // console.log('Number Length:'+i.length);
		var j = (j = i.length) > 3 ? j % 3 : 0;
        return sign +
		(j ? i.substr(0, j) + thouSep : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + thouSep) + (decPlaces ? decSep + Math.abs(number - i).toFixed(decPlaces).slice(2) : "");
    },
    fetchCaseStatus : function(component,event,caseId){
        var helper = this;
        console.log('Case Id inside fetch Case Status Method---->',caseId);
        var action =component.get('c.fetchCaseStatus');
        action.setParams({
            'recId':caseId
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var caseStatus = response.getReturnValue();
                console.log('CASE STATUS VALUE---->',caseStatus);
                component.set('v.caseStatus',caseStatus);
                //$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    downloadTermDeposit : function(component, customerId, urbisContractId){
        var helper = this;
        component.find('apexService').request(component.get('c.downloadTermDeposit'), {
		    customerId: customerId,
            urbisContractId: urbisContractId,
            regionName:component.get('v.regionName')
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log('Result for term deposit file:',result);
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))
            {
                data = result.responseData;
                var fileData = data.fileContent;
                console.log(typeof fileData);
                helper.downloadTermDepositPdf(component,customerId,urbisContractId,fileData,component.get("v.account"));
            }
            //console.log("Download Term Deposit data---->",JSON.stringify(data));
            console.log("Download Term Deposit BLOB data---->",JSON.stringify(fileData));
		});
	},
    downloadTermDepositPdf : function(component,customerId,urbisContractId,fileData,account){
        var helper = this;
        console.log('Account Email:',account.PersonEmail);
        var regionName=component.get('v.regionName');
        var acc=account.PersonEmail;
        var action=component.get('c.sendEmailWithTermDepositPdf');
         action.setParams({
            'conEmail':acc,
            'file':fileData,
            'region':regionName        
        });
         action.setCallback(this,function(response){
            var state=response.getState();
            console.log('State after Sending Pdf',state);
            if(state==='SUCCESS'){
                var emailResponse=response.getReturnValue();
                if(emailResponse='Success'){
                    var toastEvent = $A.get("e.force:showToast");  
           				toastEvent.setParams({  
             							"title": "Success!",  
             							"type": "success",  
             							"message": "Email Sent Successfully!"  
           			});  
           			toastEvent.fire(); 
                    	helper.updateCaseStatus(component,event,helper,fileData);
                    	

                }else{
                     var toastEvent = $A.get("e.force:showToast");  
           				toastEvent.setParams({  
             							"title": "Error!",  
             							"type": "error",  
             							"message":emailResponse 
           				});  
           			toastEvent.fire(); 
                }
                
            }
            
            
        });
        
        $A.enqueueAction(action);
        
   },
    
    updateCaseStatus:function(component,event,helper,fileData){
        var helper = this;
        var data = fileData;
        console.log('Inside UpdateCaseStatus Method')
        console.log('------>Data',data);
        var caseId=component.get('v.caseId');
        var action =component.get('c.updateCaseStatus');
        action.setParams({
            'recId':caseId,
             'file':data
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state==='SUCCESS'){
                var emailResponse=response.getReturnValue();
                if(emailResponse='Success'){
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Success!",  
                        "type": "success",  
                        "message": "Case Status Closed!"  
                    });
                    //component.set("v.showTermDepositButton",false);
                    toastEvent.fire(); 
                    $A.get('e.force:refreshView').fire();
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");  
                    toastEvent.setParams({  
                        "title": "Error!",  
                        "type": "error",  
                        "message":emailResponse 
                    });  
                    toastEvent.fire(); 
                }
                
            }
            
            
        });
        
        $A.enqueueAction(action);
        
        
    },
    //#CH02 START : Added by Imane Tsioucha
    downloadTermDepositCertification : function(component, customerId, urbisContractId){
        var helper = this;
        component.find('apexService').request(component.get('c.downloadTermDeposit'), {
		    customerId: customerId,
            urbisContractId: urbisContractId,
            regionName:component.get('v.regionName')
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log('Result for term deposit file:',result);
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))
            {
                data = result.responseData;
                var fileData = data.fileContent;
                console.log(typeof fileData);
                helper.downloadTermDepositCertificationPdf(component, event, helper,fileData );
            }
            console.log("Download Term Deposit BLOB data---->",JSON.stringify(fileData));
		});
	},
    
    downloadTermDepositCertificationPdf: function (component, event, helper, fileContent) {
        
                var blob = fileContent;
        		let downloadLink = document.createElement("a");
        		downloadLink.setAttribute("type", "hidden");
        		downloadLink.href = "data:text/html;base64,"+fileContent;
                downloadLink.download ='Term Deposit.pdf';
        		document.body.appendChild(downloadLink);
        		downloadLink.click();
        		downloadLink.remove();
                
                var caseId=component.get('v.caseId');
                var action =component.get('c.closedCaseStatus');
                action.setParams({
                    'recId':caseId,
                    // 'file':fileContent
                });
                action.setCallback(this,function(response){
                    var state=response.getState();
                    if(state==='SUCCESS'){
                        var emailResponse=response.getReturnValue();
                        if(emailResponse='Success'){
                            var toastEvent = $A.get("e.force:showToast");  
                            toastEvent.setParams({  
                                "title": "Success!",  
                                "type": "success",  
                                "message": "Case Status Closed!"  
                            });
                            toastEvent.fire(); 
                            $A.get('e.force:refreshView').fire();
                        }else{
                            var toastEvent = $A.get("e.force:showToast");  
                            toastEvent.setParams({  
                                "title": "Error!",  
                                "type": "error",  
                            });  
                            toastEvent.fire(); 
                        } 
                    } 
                });
                $A.enqueueAction(action);
    },
    //#CH02 End 
    

})