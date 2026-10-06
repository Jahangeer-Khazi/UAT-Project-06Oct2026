/* 		Organization : ABC Bank
 * 		Created By: Maksud Ali
 *		Created Date: 08-12-2025 (Below code is cloned from bank account details)
 * 		Change History: 
 *			   #CH01 : Added by Imane Tsioucha 13-09-2023
 *             #CH02 : Added by Imane Tsioucha 11-03-2024
 *
 */
 ({
    init : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        var accountNumber=component.get('v.accountNumber');//#CH01 
        var curency=component.get('v.curency');//#CH01 a
        //var isAlburaqTab = component.get('v.isAlburaqProduct');
        //console.log('Is Albuarq Tab Clicked:',isAlburaqTab);
        helper.loadData(component, customerId, accountId,curency,accountNumber);
    },
    load : function(component, event, helper) {
        var customerId = component.get('v.customerId');
        var accountId = component.get('v.accountId');
        var accountNumber=component.get('v.accountNumber');//#CH01 
        var curency=component.get('v.curency');//#CH01

        helper.loadData(component, customerId, accountId,curency,accountNumber);
    },
     
    GenerateiBan : function(component, event, helper){
	console.log('test');
        //debugger;
        var method="post";
        var sendData = component.get("v.data");
        var accountCurrency=sendData.accountCurrency;
        var iBAN=sendData.iban;
        var startDate=sendData.startDate;
        var acc=component.get('v.account');
        var action=component.get('c.sendEmailWithPdf');
        action.setParams({
            'IBAN':iBAN,
            'startDate':startDate,
            'accountId':acc.Id,
            'accountCurrency':accountCurrency,
            'conEmail':acc.PersonEmail,
            'conName':acc.Name,
            'caseId' : component.get("v.caseId") //#CH01 : Added by Imane Tsioucha
            
        });
        //alert('inside##');
        action.setCallback(this,function(response){
            var state=response.getState();
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
    },
     
     //#CH09: Added by Ranjith Raja
     GenerateIBAN: function(component, event, helper) {
         helper.downloadIBANCertificateAndSendEmail(component,component.get('v.customerId'),component.get('v.accountId'));
     },
    
    //#CH02 : Added by Imane Tsioucha
    downloadClick : function(component, event, helper) {
        var caseId=component.get("v.recordId");
        helper.downloadTermDepositCertification(component,component.get('v.customerId'),component.get('v.accountId') );
	},
})