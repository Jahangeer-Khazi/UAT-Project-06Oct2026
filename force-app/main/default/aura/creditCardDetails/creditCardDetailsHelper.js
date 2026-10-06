({
    loadCardDetails : function(component, customerId, cardId, account) {
        var helper = this;
        
        if(account.Region_Flag__c=='Jordan'){
            component.set('v.currencyCode','(JOD)'); 
        }else{
            component.set('v.currencyCode','(BHD)'); 
        }
       
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
                                                  debugger;
                                                  console.log("result.responseData21 ",result);
                                                  if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))//responseData.currentCards))
                                                  {
                                                      data = result.responseData;//result.responseData.currentCards;
                                                  }
                                                  
                                                  console.log("result.responseData21 data ",data);
                                                  
                                                  component.set('v.isRewardDetailAvailable',false);
                                                  
                                                  //CH11 - START - Annual Membership Changes
                                                  if(data.remainingSpendForWaiver != undefined){
                                                      data.remainingSpendForWaiver = helper.getFormattedCurrency(data.remainingSpendForWaiver);
                                                  }
                                                  else {
                                                      data.remainingSpendForWaiver = "0.000";
                                                  }
                                                  if(data.totalSpendSinceLastRenewal != undefined){
                                                      data.totalSpendSinceLastRenewal = helper.getFormattedCurrency(data.totalSpendSinceLastRenewal);
                                                  }
                                                  else {
                                                      data.totalSpendSinceLastRenewal = "0.000";
                                                  }
                                                  if(data.nextMembershipRenewalWaiverLimit != undefined){
                                                      data.nextMembershipRenewalWaiverLimit = helper.getFormattedCurrency(data.nextMembershipRenewalWaiverLimit);
                                                  }
                                                  else {
                                                      data.nextMembershipRenewalWaiverLimit = "0.000";
                                                  }
                                                  if(data.nextMembershipRenewalFeeVAT != undefined){
                                                      data.nextMembershipRenewalFeeVAT = helper.getFormattedCurrency(data.nextMembershipRenewalFeeVAT);
                                                  }
                                                  else {
                                                      data.nextMembershipRenewalFeeVAT = "0.000";
                                                  }
                                                  if(data.nextMembershipRenewalFee != undefined){
                                                      data.nextMembershipRenewalFee = helper.getFormattedCurrency(data.nextMembershipRenewalFee);
                                                  }
                                                  else {
                                                      data.nextMembershipRenewalFee = "0.000";
                                                  }
                                                  //CH11 - END
                                                  
                                                  component.set('v.cardData', data);
                                                  console.log("Card Details data---->",JSON.stringify(data));
                                                  console.log("productName",component.get('v.cardData').cmsProductDescription);
                                                  
                                                  // console.log('preferredReward##'+data.rewardsSummary.preferredRewardsOption);
                                                  if($A.get("$Label.c.ilaRewardsFeatures")=='True'){
                                                      console.log('insiderewards')
                                                      if(data.rewardsSummary){
                                                          component.set('v.preferredReward',data.rewardsSummary);
                                                          if(data.rewardsSummary.preferredRewardsOption){
                                                              component.set('v.isRewardDetailAvailable',true);
                                                              // alert('##rewardsSummary'+JSON.stringify(data.rewardsSummary));
                                                          }
                                                      }
                                                  }
                                                  
                                                  var cmpEvent = component.getEvent("cmpEvent");
                                                  cmpEvent.setParams({
                                                      "productName" : component.get('v.cardData').cmsProductDescription });
                                                  cmpEvent.fire();
                                              });
        
    },
    //CH07 START
    downloadCashCollateralCert:function(component,helper){
    	const caseId = component.get("v.caseId");
        
        const cardDetailObj = {
            'creditLimit' : component.get('v.cardData').creditLimit == undefined ? 0 : component.get('v.cardData').creditLimit,
            'accountNo' : component.get('v.cardData').cmsAccountId == undefined ? '' : component.get('v.cardData').cmsAccountId,
            'issueDate' : component.get('v.cardData').issueDate == undefined ? '' : component.get('v.cardData').issueDate,
            'cardType' : component.get('v.cardData').cmsProductDescription == undefined ? '' : component.get('v.cardData').cmsProductDescription,
            'typeOfAccount' : component.get('v.cardData').holdAccountType == undefined ? '' : component.get('v.cardData').holdAccountType,
            'holdAccount' : component.get('v.cardData').holdAccount == undefined ? '' : component.get('v.cardData').holdAccount,
            'pledgedAmount' : component.get('v.holdAmount') == undefined ? '' : component.get('v.holdAmount')
        }
        console.log("cardDetailObj ",cardDetailObj);
        component.find('apexService').request(component.get('c.downloadCashCollateral'), {
		    caseId: caseId,
            mapOfCardDetails:cardDetailObj
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log('Result for cash collateral file:',result);
            var data = {};
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData))
            {
                data = result.responseData;
                var fileData = result.responseData;
                console.log(typeof fileData);
                helper.downloadCashCollateralCertPdf(component,fileData );
            }
		});
	},
    senEmailCashCollateralCert:function(component,helper){
    	const caseId = component.get("v.caseId");
        const accountId = component.get("v.accountId");
        
        const cardDetailObj = {
            'creditLimit' : component.get('v.cardData').creditLimit == undefined ? 0 : component.get('v.cardData').creditLimit,
            'accountNo' : component.get('v.cardData').cmsAccountId == undefined ? '' : component.get('v.cardData').cmsAccountId,
            'issueDate' : component.get('v.cardData').issueDate == undefined ? '' : component.get('v.cardData').issueDate,
            'cardType' : component.get('v.cardData').cmsProductDescription == undefined ? '' : component.get('v.cardData').cmsProductDescription,
            'typeOfAccount' : component.get('v.cardData').holdAccountType == undefined ? '' : component.get('v.cardData').holdAccountType,
            'holdAccount' : component.get('v.cardData').holdAccount == undefined ? '' : component.get('v.cardData').holdAccount,
            'pledgedAmount' : component.get('v.holdAmount') == undefined ? '' : component.get('v.holdAmount'),
        }
        
        component.find('apexService').request(component.get('c.sendEmailWithCashCollateralCert'), {
		    caseId: caseId,
            mapOfCardDetails:cardDetailObj
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log('Result for email cash collateral file:',result);
            if(result == 'success'){
                var toastEvent = $A.get("e.force:showToast");  
                toastEvent.setParams({  
                    "title": "Success!",  
                    "type": "success",  
                    "message": "Email Sent Successfully!"  
                });  
                toastEvent.fire(); 
                helper.updateCaseStatus(component,event,helper);
            }
            else {
                var toastEvent = $A.get("e.force:showToast");  
                toastEvent.setParams({  
                    "title": "Error!",  
                    "type": "error",  
                    "message":result 
                });  
                toastEvent.fire(); 
            }
		});
	},
    downloadCashCollateralCertPdf: function (component,fileContent) {
        console.log("fileContent ",fileContent);
    	var blob = fileContent;
        let downloadLink = document.createElement("a");
        downloadLink.setAttribute("type", "hidden");
        downloadLink.href = "data:text/html;base64,"+fileContent;
        downloadLink.download ='Cash Collateral Certificate.pdf';
        document.body.appendChild(downloadLink);
        downloadLink.click();
        downloadLink.remove();
    },
    updateCaseStatus:function(component,event,helper){
        var caseId=component.get('v.caseId');
        var action =component.get('c.updateCaseStatus');
        action.setParams({
            'caseId':caseId
        });
        action.setCallback(this,function(response){
            var state=response.getState();
            console.log('case state --->'+state);
            if(state==='SUCCESS'){
                var caseResponse=response.getReturnValue();
                console.log('case emailResponse --->'+caseResponse);
                if(caseResponse='Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    component.set("v.caseStatus","Closed");
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
    checkCreditCardUser:function(component,helper){
        var action = component.get("c.checkCreditCardUser");
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === 'SUCCESS'){
            	var creditcardUser = response.getReturnValue();
                if(creditcardUser == 'yes' || creditcardUser == 'no'){
                    let isCreditCardUser =  creditcardUser == 'yes' ? true : false;
                    component.set("v.isCreditCardUser",isCreditCardUser);
                }
                else {
                    console.error("Error while fetching the Credit Card User ",creditcardUser);
                }
            }
        });
        $A.enqueueAction(action);
    },
    //CH07 END
    //CH11 START - Annual Membership Details
    getFormattedCurrency:function(currencyValue){
        if(currencyValue == null) return '';
        
        let formattedCurrency = currencyValue.toString();
        
        if(formattedCurrency != '' && formattedCurrency.indexOf('.') == -1){
            formattedCurrency = formattedCurrency + '.000';
        }
        else {
            let currencyDecimal = formattedCurrency.split('.')[1];
            if(currencyDecimal.length == 0){
                formattedCurrency = formattedCurrency + '000';
            }
            else if(currencyDecimal.length == 1){
                formattedCurrency = formattedCurrency + '00';
            }
            else if(currencyDecimal.length == 2){
                formattedCurrency = formattedCurrency + '0';
            }
        }
        return formattedCurrency;
    }
    //CH11 END
})