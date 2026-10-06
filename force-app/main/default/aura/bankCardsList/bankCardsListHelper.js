/* 	
 * 		Change History: 
 *              #CH01# : added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
 *              #CH02# : Added by Imane Tsioucha: 01-11-2023# Added recordId for LoadCardList
 *              #CH03# : #Jahangeer Mohammed# #06-05-2024# Added Logic for Audit History Enhancements(NBA-9027)

 */
({
	loadData : function(component, customerId) {
        /*
        component.set('v.data', [
            {'id': '1', 'productType': 'Virtual', 'cardType': 'Primary', 'status': 'Active', 'maskedCardNumber': '123456******1234'},
            {'id': '2', 'productType': 'Classic', 'cardType': 'Supplementary', 'status': 'Active', 'maskedCardNumber': '123456******5678'},
            {'id': '3', 'productType': 'Premium', 'cardType': 'Primary', 'status': 'Frozen', 'maskedCardNumber': '123456******0000'}
        ]);
        */
        var account = component.get('v.account');

        var helper = this;

        //Customer Id is required for make request
        if(!customerId){
            return;
        }
        //CH01 -Start added by Hamza Chaoui : pass Bahrain_alburaq in case of alburaq Product
        console.log(' -- account log --> ',JSON.stringify(account));
        var regionName = account.Region_Flag__c;
        var subModel = account.Subscription_Model__pc;
        if(component.get('v.isAlburaqProduct') == true || subModel == 'alburaq'){
            regionName += '_alburaq';
        }
        //CH01 -End
    	component.find('apexService').request(component.get('c.loadCardList'), {
		    customerId: customerId,
            personEmail: account.PersonEmail,
            regionName: regionName,
            //CH02 -Start
            recordId: component.get('v.caseId')
            //CH02 -End
        },
		function(response) {
		    var result = response.getReturnValue();
            console.log(result);
            // array of card data
            var data = [];
            if (true === result.isSuccess && !$A.util.isEmpty(result.responseData.cards)) {
                var cards = result.responseData.cards;
                for (var i = 0; i < cards.length; i++) {
                    var cardObj = cards[i];
                    console.log(cardObj);
                    data.push(helper.formatData(component, cardObj));
                }
            }
            console.log("CardList data is loaded" +data);
            component.set('v.data', data);
		});

	},
    formatData: function(component, cardObj) {
        var rec = {};
        rec.id = cardObj.id;
        rec.productType = cardObj.productType;
        //rec.cardType = cardObj.cardType;
        rec.status = cardObj.status;
        rec.maskedCardNumber = cardObj.maskedCardNumber;
        //console.log('Format Active Debit Data:',rec);
        return rec;

    },

    activateCard : function(component, customerId, cardId) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
        	"title": "This is a demo!",
            "message": "This action will activate selected card."
       });
       toastEvent.fire();
	},
    //accountId is added as it is required by API
    openCardDetails : function(component, customerId, cardId, accountId) {
        component.set('v.selectedCardId', cardId);
        console.log("AccountId is received" +accountId);
        component.set('v.accountId', accountId);  //added to get accountId
	},
    //CH03: Start
    loadDataInAuditObject : function(component,maskNumber,cardClassification,cardStatus) {
        var action = component.get("c.createAuditRecordForDebitCardDetails");
        console.log('Mask Number in helper:',maskNumber);
        console.log('Card Classification in helper:',cardClassification);
        console.log('Card Status in helper:',cardStatus); 
        var account = component.get('v.account');
        var accCIF = account.CIF__pc;
        console.log('Acc CIF in helper:',accCIF);
        action.setParams({
            accCIF:accCIF,
            maskNumber:maskNumber,
            cardClassification:cardClassification,
            cardStatus:cardStatus
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

})