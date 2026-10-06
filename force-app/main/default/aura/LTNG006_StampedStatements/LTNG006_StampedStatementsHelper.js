/* 		
 *   Organization : ABC Bank
 * 	Created By: Aniss Mbarki
 *	Created Date: 07-01-2022
 * 	Change History: 
 *			  
 */
({
    doInit: function (component, event, helper) {
        console.log('init LTNG006_StampedStatementsHelper : accountId : ' + component.get('v.account').Id);
        console.log('init LTNG006_StampedStatementsHelper : customer Id : ' + component.get('v.customerId'));
        var action = component.get('c.stampedStatementVisibility');
        action.setParams(
            {
                accountId: component.get('v.account').Id
            });

        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let result = actionResult.getReturnValue();
                console.log('LTNG006_StampedStatements visiblity : ' + result);
                component.set('v.showCmp', result);
                helper.loadData(component, event, helper);
            } else if (statut === "ERROR") {
                //toDo : ....
                // Process error returned by server
                console.error(actionResult.getError());
                //helper.handleErrors(actionResult.getError(), '');
            }
            else {
                //toDo : ....
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);
    },
    loadData: function (component, event, helper) {
        var action = component.get('c.loadAccountStatements');
        var requestData = {
            accountId: component.get('v.accountId'),
            statementType: "Statement"
        }

        action.setParams(
            {
                customerId: component.get('v.customerId'),
                requestTextJson: JSON.stringify(requestData)
            });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let result = actionResult.getReturnValue();
                var data = [];
                if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                    var responseResult = result.responseData;
                    for (var i = 0; i < responseResult.statements.length; i++) {
                        var stment = responseResult.statements[i];
                        console.log('---LTNG006_StampedStatements loadData --> ', stment);
                        data.push(helper.formatData(component, stment));
                    }
                }
                component.set('v.data', data);
            } else if (statut === "ERROR") {
                //toDo : ....
                // Process error returned by server
                console.error(actionResult.getError());
                //helper.handleErrors(actionResult.getError(), '');
            }
            else {
                //toDo : ....
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);

    },
    formatData: function (component, statObj) {
        var rec = {};
        rec.statementDate = statObj.statementDate;
        rec.statementDescription = statObj.statementDescription;
        return rec;

    },
    handleAccStatementDetails: function (helper,component, selectedRow) {
        console.log('handleAccStatementDetails dowload');
        var statementDate = selectedRow.statementDate;
        var ibanNumber = component.get('v.accountId');
        var requestData = {
            accountId: ibanNumber,
            statementDate: statementDate,
            statementType: "Statement"
        }

        var action = component.get('c.getAccountStatementDetails');
        action.setParams(
            {
                customerId: component.get('v.customerId'),
                requestTextJson: JSON.stringify(requestData)
            });
        action.setCallback(this, function (actionResult) {
            var statut = actionResult.getState();
            if (statut === "SUCCESS") {
                let result = actionResult.getReturnValue();
                if(true === result.isSuccess){
                    let downloadLink = document.createElement("a");
                    downloadLink.setAttribute("type", "hidden");
                    debugger;
                    downloadLink.href = "data:text/html;base64," + result.responseData.fileContent;
                    //downloadLink.download = result.responseData.fileName;
                    downloadLink.download = 'Statement-'+ibanNumber.substr(-4)+'-'+statementDate.replace(/-/g, "")+'.pdf';
                    document.body.appendChild(downloadLink);
                    downloadLink.click();
                    downloadLink.remove();
                }else{
                    helper.handleErrors(result.errorData.code + ' : '+result.errorData.message, 'Error Related to API call : ');
                    console.error(result.errorData);
                }

            } else if (statut === "ERROR") {
                //toDo : ....
                // Process error returned by server
                console.error(actionResult.getError());
                //helper.handleErrors(actionResult.getError(), '');
            }
            else {
                //toDo : ....
                console.error("AUTRE ERROR");
                // Handle other reponse states
            }
        });
        $A.enqueueAction(action);

    },
    handleErrors: function (errors, addError) {
        // Configure error toast
        let toastParams = {
            mode: "sticky",
            title: "Erreur",
            message: errors, // Default error message
            type: "error"
        };
        // Pass the error message if any
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = addError + '' + errors[0].message;
        }
        // Fire error toast
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
})