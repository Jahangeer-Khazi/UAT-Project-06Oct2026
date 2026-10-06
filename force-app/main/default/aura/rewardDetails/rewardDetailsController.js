({
    init : function(component, event, helper) {
        debugger;
        console.log('---> Customer ID 1 --> ', component.get('v.customerId'));
        console.log('---> Card ID 1 -->  ', component.get('v.cardId'));
        console.log('---> Account ID 1 --> ', component.get('v.account.PersonEmail'));
        console.log('---> preferredReward',JSON.stringify(component.get('v.preferredReward')));
        component.set('v.preferredRewardsOption',component.get('v.preferredReward')['preferredRewardsOption']);
        helper.loadRewardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'), component.get('v.preferredRewardsOption'));
	},
     load : function(component, event, helper) {
        debugger;
        console.log('---> Customer ID 1 --> ', component.get('v.customerId'));
        console.log('---> Card ID 1 -->  ', component.get('v.cardId'));
        console.log('---> Account ID 1 --> ', component.get('v.account.PersonEmail'));
        console.log('---> preferredReward',JSON.stringify(component.get('v.preferredReward')));
        component.set('v.preferredRewardsOption',component.get('v.preferredReward')['preferredRewardsOption']);
        helper.loadRewardDetails(component, component.get('v.customerId'), component.get('v.cardId'), component.get('v.account'), component.get('v.preferredRewardsOption'));
	}
})