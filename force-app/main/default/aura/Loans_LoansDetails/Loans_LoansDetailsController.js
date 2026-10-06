({
    init : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var loanId = component.get('v.loanId');
        var responseLoanListdata = component.get('v.responseLoanListdata');
        var responseLoanEarlySettlementdata = component.get('v.responseLoanEarlySettlementdata');
        console.log('responseLoanEarlySettlementdata => '+ responseLoanEarlySettlementdata);
        var isAlburaqProduct = component.get("v.isAlburaqProduct");
        var loanOrFinance = (isAlburaqProduct) ? 'Finance' : 'Loan';
        console.log('isAlburaqProduct => '+ isAlburaqProduct);
        component.set('v.loanOrFinance', loanOrFinance);

        helper.loadData(component, customerId, loanId, responseLoanListdata, responseLoanEarlySettlementdata);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var loanId = component.get('v.loanId');
        var responseLoanListdata = component.get('v.responseLoanListdata');
        var responseLoanEarlySettlementdata = component.get('v.responseLoanEarlySettlementdata');
            console.log('responseLoanEarlySettlementdata ===> '+ responseLoanEarlySettlementdata);
        helper.loadData(component, customerId, loanId, responseLoanListdata, responseLoanEarlySettlementdata);
    },
    // GenerateiBan : function(component, event, helper){
	// console.log('test');
    //     //debugger;
    //     var method="post";
    //      var sendData = component.get("v.data");
    //     var accountCurrency=sendData.accountCurrency;
    //     var iBAN=sendData.iban;
    //     var startDate=sendData.startDate;
    //     var acc=component.get('v.account');
    //     var action=component.get('c.sendEmailWithPdf');
    //     action.setParams({
    //         'IBAN':iBAN,
    //         'startDate':startDate,
    //         'accountId':acc.Id,
    //         'accountCurrency':accountCurrency,
    //         'conEmail':acc.PersonEmail,
    //         'conName':acc.Name,
    //         'caseId' : component.get("v.caseId") //#CH01 : Added by Imane Tsioucha
            
    //     });
    //     action.setCallback(this,function(response){
    //         var state=response.getState();
    //         if(state==='SUCCESS'){
    //             var emailResponse=response.getReturnValue();
    //             if(emailResponse='Success'){
    //                 var toastEvent = $A.get("e.force:showToast");  
    //        toastEvent.setParams({  
    //          "title": "Success!",  
    //          "type": "success",  
    //          "message": "Email Sent Successfully!"  
    //        });  
    //        toastEvent.fire(); 
    //                 helper.updateCaseStatus(component,event,helper);

    //             }else{
    //                  var toastEvent = $A.get("e.force:showToast");  
    //        toastEvent.setParams({  
    //          "title": "Error!",  
    //          "type": "error",  
    //          "message":emailResponse 
    //        });  
    //        toastEvent.fire(); 
    //             }
                
    //         }
            
            
    //     });
        
    //     $A.enqueueAction(action);
        
     
       
        
      
        
    // }
 
})