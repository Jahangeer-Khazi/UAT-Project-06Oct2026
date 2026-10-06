/* 		Organization : ABC Bank
 * 		Created By: Jahangeer Mohammed
 *		Created Date:03-01-2022
 * 		Change History: 
 *             CH01 - added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
 *			  #CH02# #Imane Tsioucha# #20-02-2024# Add Term Deposit Filter
 *            #CH03# : #Jahangeer Mohammed# #05-05-2024# Added Logic for Audit History Enhancements(NBA-9027)
 *			  #CH04# Maksud Ali #07-01-2026# Added FD Term Deposit Button  

*/
({
	init : function(component, event, helper) {
    console.log('Inside init method of Term Deposit component');
    console.log('sobjectName==> '+component.get('v.sObjectName'));
	var columns  = [
            {label: 'Id', fieldName: 'urbisContractId', type: 'text',sortable:true},
            {label: 'Name', fieldName: 'name', type: 'text',sortable:true },
            {label: 'Status', fieldName: 'statusCode', type: 'text',sortable:true}
     ];
		component.set('v.columns', columns);
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        var accountId = component.get('v.account.Id');
        var segment = account.Segment__pc;
        var regionFlag = account.Region_Flag__c;
        var subscriptionModel = account.Subscription_Model__pc;

        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        if(component.get('v.isAlburaqProduct') == true || subscriptionModel == 'alburaq'){
            regionFlag += '_alburaq';
        }
        //CH01 -End

        console.log('Segment Value:'+segment);
        console.log('Region Value:'+regionFlag);
        component.set('v.customerSegment',segment);
        component.set('v.regionName',regionFlag);

        //#CH01 --Start
        var alburaqSegment = account.Alburaq_Segment__pc;
        component.set('v.customerAlburaqSegment',alburaqSegment);
        //#CH01 --End
        helper.loadData(component, customerId,account);
        
        //CH04 - START
        var fdColumns  = [
            {label: 'FD Status', fieldName: 'fdStatus', type: 'text',sortable:true},
            {label: 'Currency', fieldName: 'currency', type: 'text',sortable:true },
            {label: 'Total Deposit Amount', fieldName: 'totalDepositAmount', type: 'text',sortable:true}
        ];
        component.set('v.fdColumns', fdColumns);
        helper.checkUserCanViewFDButton(component,helper,customerId);
        //CH04 - END
	},
    LoadAccountId : function(component, event, helper) {
        var accountId = event.getParam("globalAccountId");
        component.set("v.accountId", accountId);  //set the accountID passed through bank account list component
        
     },
     load: function (component, event, helper) {
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        helper.loadData(component, customerId, account);
    },
    handleRowAction: function (component, event, helper) {
    },
    handleRowSelection: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        
        console.log('--> SELECTED ROW OF TERM DEPOSIT-> ',selectedRows);
        for(var i =0 ;i < selectedRows.length; i++){
            var termDepositId = selectedRows[i].urbisContractId;
            console.log('--> This is Account ID -> ',component.get('v.account.Id'));
            console.log('--> SELECTED ROW URBIS ID -> ',termDepositId);
            component.set("v.selectedTermDepositId",termDepositId);
            //CH03: Start
            var enableAuditComp = $A.get("$Label.c.ENABLE_AUDIT_COMPONENT");
            console.log('Enable Audit Comp:',enableAuditComp);
            if(enableAuditComp == 'true'){
                helper.loadDataInAuditObject(component,termDepositId);
            }
            //CH03: END
        }
        
    },
    handleAppEvent: function (component, event, helper) {
        console.log("bankCardsList.handleAppEvent=" + JSON.stringify(event));

        var isMyEvent = 'cardList' === event.getParam("target");
        
        if (!isMyEvent) {
            return;
        }

        var message = event.getParam("message");
        var action = message.action;
        
        var customerId = component.get('v.customerId');
        var account = component.get('v.account');
        
        if ( "refresh" === action) {
            // reload card list and reset selection
            component.set('v.selectedCardId', undefined);
            component.find('termDepositListTable').set("v.selectedRows", []);
            helper.loadData(component, customerId, account);
        }
    },
     //CH02: Start
     onFixedDepositStatusChange : function(component, event, helper){
         
         
        var newdata = [];
        var fixedDepositSelected = component.get('v.selectedFixedDepositStatus'); 
        console.log('Selected Fixed Deposit: >>>  '+fixedDepositSelected);
        var accounts = component.get('v.Origindata');
        console.log('bank saving pot Account: ', JSON.stringify(accounts));
        accounts.forEach(account => { 
            console.log('acc >> '+JSON.stringify(account));
            console.log('accaccount.statusCode >> '+JSON.stringify(account.statusCode));
            console.log('toLowerCase>> '+JSON.stringify(account.statusCode.toLowerCase()));
           if(((account.statusCode.toLowerCase() == 'active' ) && fixedDepositSelected == 'A')
           || ((account.statusCode.toLowerCase() == 'matured') && fixedDepositSelected == 'B')
           || ((account.statusCode.toLowerCase() == 'prepaid' || account.statusCode.toLowerCase() == 'early withdrawn') && fixedDepositSelected == 'C')
           ){
              	newdata.push(account);
        	} 
        })
            
            //CH04 START
         component.set('v.data', []);//clearing the data before populating actual data.
         component.set("v.selectedTermDepositId","");
         //CH04 END
        console.log('newdata >>>> '+JSON.stringify(newdata));
        component.set('v.data', newdata);
    },
    //CH02: END
    //CH04 - START
    onTotalDepositClicked : function(component, event, helper){
    	component.set('v.isShowTermDeposit', true); 
    },
    //CH04 - END
})