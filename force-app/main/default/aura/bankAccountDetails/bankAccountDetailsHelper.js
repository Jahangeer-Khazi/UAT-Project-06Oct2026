/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History:  
 *                #CH01# : Added by Hamza Chaoui *** pass Bahrain_alburaq in case of alburaq Product
 *   		      #CH02# #Jahangeer Mohammed# #02-06-2022# Added holdAmount value(NBA-5191)
 *				  #CH03# #Jahangeer Mohammed #25-05-2022# Added new fields related to Change Interest Rates(NBA-3817)
 *				  #CH05# #Jahangeer Mohammed ##08-08-2023# Setting a Region Flag
                  #CH06# #Tsioucha Imane  ##13-09-2023# Minimum Balance Fee Logic
                  #CH07# #Tsioucha Imane #11-03-2024# Added logic for Download IBAN Letter
 *				 
 *
 */
 ({
    loadData : function(component, customerId, accountId,curency,accountNumber) {
        console.log('bankAccountDetails: loadData(customerId=' + customerId + ', accountId=' + accountId + ')'+', curency=' + curency +', accountNumber=' + accountNumber + ')');
        var account = component.get('v.account');
	    var helper = this;
         
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        var regionName = account.Region_Flag__c;
        //CH05: Start
        console.log('Region Name in Bank Account Detail:',regionName);
        component.set('v.regionName',regionName);
        //CH05: END
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End
         
		component.find('apexService').request(component.get('c.loadAccountDetails'), {
		    customerId: customerId,
		    accountId: accountId,
		    regionName: regionName
        },
		function(response) {
            /*
            var DEMO_ACCOUNT = {
                "customerId": "989248099",
                "id": "BH09ABCO00929029882",
                "alias": "Wife Account",
                "productType": "Account",
                "productName": "Saving Account",
                "category1": "",
                "category2": "",
                "account": {
                    "number": "100001009280",
                    "branch": "",
                    "currency": {
                        "code": "BHD",
                        "description": "Bahraini Dinar",
                        "decimalPlaces": 3
                    },
                    "iban": "BH09ABCO00929029882",
                    "availableBalance": 100,
                    "ledgerBalance": 100.000,
                    "startDate": "2018-01-09",
                    "endDate": "2018-02-09",
                    "status": "Active",
                    "overdraftLimit": 100000.000,
                    "overdraftExpiryDate": "2020-12-31",
                    "overdraftAvailableLimit": 1000000.000,
                    "paymentsAllowed": true
                }
            } ;
            */
		    var result = response.getReturnValue();
			console.log('Result====',result);
            var data = {};
            console.log('Response Data',result.responseData);
            console.log('Boolean Value',!$A.util.isEmpty(result.responseData));
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data = result.responseData;
                console.log('Data',data);
            }
            //TODO - remove when API is available
            //data = DEMO_ACCOUNT;

            component.set('v.data', helper.formatData(component, data));
		});
        
       /* //CH06: Start
        component.find('apexService').request(component.get('c.loadAccountDetailsMinimumBalance'), {
		    customerId: customerId,
            accountNumber:accountNumber,
            curency:curency,
		    accountId: accountId,
		    regionName: regionName
        },
		function(response) {
            
		    var result = response.getReturnValue();
			console.log('Result====',result);
            var data2 = {};
            console.log('Response Data',result.responseData);
            console.log('Boolean Value',!$A.util.isEmpty(result.responseData));
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                data2 = result.responseData;
                console.log('Data2',data2);
            }

            component.set('v.data2', helper.formatDataMinimumBalance(component, data2));
		});*/
        //CH06: END

    },
    //CH06: Start
    formatDataMinimumBalance: function(component, accountObj){
        var result = {};
        //CH04 : START Wissal
            result.averageBalance = accountObj.account.averageBalance;      
            result.threshold = accountObj.minimumBalance.threshold; 
            result.minFee = accountObj.minimumBalance.fee; 
        	result.feeWaiver = accountObj.minimumBalance.feeWaiver; 
            result.feeWaiverReason = accountObj.minimumBalance.feeWaiverReason;
        
        //CH04 : END
        return result;

    },
    //CH06: END
    formatData: function(component, accountObj){
        var result = {};
        result.id = accountObj.id;
        result.productName = accountObj.productName;
        result.branch = accountObj.account.branch;
        result.accountNumber = accountObj.account.number;
        result.accountCurrency = accountObj.account.currency.code;
        result.accountCurrencyDecimalPlaces = accountObj.account.currency.decimalPlaces;
        result.iban = accountObj.account.iban;
        result.availableBalance = accountObj.account.availableBalance;
        result.ledgerBalance = accountObj.account.ledgerBalance;
        result.startDate = accountObj.account.startDate;
        result.overdraftLimit = accountObj.account.overdraftLimit;
        //result.endDate = accountObj.account.endDate;
        result.status = accountObj.account.status;
        result.overdraftExpiryDate = accountObj.account.overdraftExpiryDate;
        result.overdraftAvailableLimit = accountObj.account.overdraftAvailableLimit;
        result.paymentsAllowed = true === accountObj.account.paymentsAllowed ? 'Yes': 'No';

        // not currently provided via API
        //result.debitInterestRate = accountObj.account.debitInterestRate;
        //result.creditInterestRate = accountObj.account.creditInterestRate;
		result.transferByMobile = accountObj.transferByMobile;
        //CH03: Start
        result.changeEarnInterest = accountObj.account.changedEarnInterest;
        result.changeEarnInterestStatus = accountObj.account.changedEarnInterestStatus;
        result.changeEarnInterestEffectiveDate = accountObj.account.effectiveDate;
        //CH03: END
        //CH02: Start
        result.holdAmount = accountObj.account.holdAmount;
        //CH02: END
        
        
        return result;

    },
    updateCaseStatus:function(component,event,helper){
        console.log('Update case status');
        var caseId=component.get('v.caseId');
        var action =component.get('c.updateCaseStatus');
        action.setParams({
            'recId':caseId
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log('case state --->'+state);
            if(state==='SUCCESS'){
                var emailResponse=response.getReturnValue();
                console.log('case emailResponse --->'+emailResponse);
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
                        "message":emailResponse
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
     
    //#CH07 START : Added by Imane Tsioucha
    downloadTermDepositCertification : function(component, customerId, accountId){
        var helper = this;
        component.find('apexService').request(component.get('c.downloadIBAN'), {
		    customerId: customerId,
            accountId: accountId,
            regionName:component.get('v.regionName')
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log('Result for iban file:',result);
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
                downloadLink.download ='IBAN Certificate.pdf';
        		document.body.appendChild(downloadLink);
        		downloadLink.click();
        		downloadLink.remove();
                
                var caseId=component.get('v.caseId');
                var action =component.get('c.updateCaseStatus');
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
    //#CH07 END   
    
     // CH09: start
     downloadIBANCertificateAndSendEmail: function(component, customerId, accountId) {
         var helper = this;
         component.find('apexService').request(component.get('c.downloadIBAN'), {
             customerId: customerId,
             accountId: accountId,
             regionName:component.get('v.regionName')
         },
		function(response) {
		    var result = response.getReturnValue();
            console.log('Result for iban file:',result);
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))
            {
                data = result.responseData;
                var fileData = data.fileContent;
                console.log(typeof fileData);
                helper.downloadIBANCertificateAndSendEmailInPDF(component, event, helper, fileData);
            }
            console.log("Download Term Deposit BLOB data---->",JSON.stringify(fileData));
		});
     },
     
     downloadIBANCertificateAndSendEmailInPDF: function(component, event, helper, fileContent) {
         console.log('Helper Method');
         var helper = this;
         var acc = component.get('v.account');
         console.log('acc --->'+JSON.stringify(acc));
         var action = component.get('c.sendEmailWithIBANCertificatePdf');
         action.setParams({
             'conEmail':acc.PersonEmail,
             'file':fileContent,
             'accountId':acc.Id,
             'caseId':component.get("v.caseId")
         });
         action.setCallback(this,function(response){
             var state=response.getState();
             console.log('State after Sending Pdf',state);
             if(state==='SUCCESS'){
                 var emailResponse=response.getReturnValue();
                 console.log('emailResponse -->'+JSON.stringify(emailResponse));
                 if(emailResponse='Success'){
                     var toastEvent = $A.get("e.force:showToast");  
                     toastEvent.setParams({  
                         "title": "Success!",  
                         "type": "success",  
                         "message": "Email Sent Successfully!"  
                     });  
                     toastEvent.fire(); 
                     helper.updateCaseStatus(component,event,helper);
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
     }
	// CH09: End
})