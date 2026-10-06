/* 		Organization : ABC Bank
 * 		Created By: swapna konuganti
 *		Created Date:16-12-2021
 * 		Change History: 
 *			  
*/
({
		loadData : function(component, customerId,pciNumber,account) {
            //debugger;
      console.log('CustomerId in EPP Helper:', customerId);
      console.log('PCI Number in EPP Helper:',pciNumber);
            var requestData = {
            pciNumber: pciNumber,
            statementType: "Statement"                
        }
      var helper = this;
      component.find('apexService').request(component.get('c.loadCreditCardStatement'), {
		    "customerId": customerId,
            "pciNumber": pciNumber,
          "regionName": account.Region_Flag__c,
          "requestTextJson": JSON.stringify(requestData),
        },
       function(response) {
		    var result = response.getReturnValue();
            console.log('Response from Server--> ',result.responseData);
           	var data = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
               
                var responseResult = result.responseData;
                console.log('ResulTT inside IF Cards--> ',responseResult);
                for (var i = 0; i < responseResult.statements.length; i++) {
                    var stment = responseResult.statements[i];
                    console.log('--- stment --> ',stment);
                    data.push(helper.formatData(component, stment));
                    
                }
            }
            console.log("stment data is loaded",data);
            component.set('v.data', data); 
           
           console.log("data is loaded",component.get('v.data'));
           
       });
        
    },
    formatData: function(component, cardObj) {
        console.log('cardObj swapnac'+cardObj);
        var rec = {};
        rec.statementDate = cardObj.statementDate;
        rec.statementDescription = cardObj.statementDescription;
        rec.dueDate = cardObj.dueDate;
        rec.latePaymentGraceDate = cardObj.latePaymentGraceDate;
        rec.openingBalance = cardObj.openingBalance;
        rec.closingBalance = cardObj.closingBalance;
        rec.minimumDueAmount = cardObj.minimumDueAmount;
        rec.pastDueAmount= cardObj.pastDueAmount;
        rec.overLimitAmount= cardObj.overLimitAmount;
        rec.accountId= cardObj.accountId;
        return rec;

    },
	handleGetStatement: function(component,customerId, pciNumber,account,selectedRow) {
      //debugger;
        console.log('get productName ', component.get('v.productName'));
      var accountObj =selectedRow;
      var requestData = {
            pciNumber: accountObj.accountId,
            statementDate:accountObj.statementDate,
            statementType: "Statement"                
        }
      var helper = this;
      component.find('apexService').request(component.get('c.getCardStatements'), {
		    "customerId": customerId,
            "pciNumber": pciNumber,
          "regionName": account.Region_Flag__c,
          "requestTextJson": JSON.stringify(requestData),
        },
       function(response) {
		    var result = response.getReturnValue();
			var state = response.getState();
    if (state === "SUCCESS") {
        var statementDate=accountObj.statementDate;
        let downloadLink = document.createElement("a");
        downloadLink.setAttribute("type", "hidden");
        debugger;
        downloadLink.href = "data:text/html;base64,"+result.responseData.fileContent;//response.getReturnValue();
        downloadLink.download = 'Statement-'+component.get('v.productName')+'-'+pciNumber.substr(-4)+'-'+statementDate.replace(/-/g, "")+'.pdf';//result.responseData.fileName;
        document.body.appendChild(downloadLink);
        downloadLink.click();
        downloadLink.remove();
    } 
           
       });
        
    },
   
})