/* 		Organization : ABC Bank
 * 		Created By: 
 *		Created Date:
 * 		Change History: 
 *			   #CH01 : #Jahangeer Mohammed# #27-08-2026# Added Logic for restricting mobile country codes Jordan(NBA-17747)
 */
({
    doInit : function(component, event, helper) {
        component.set("v.accountOld", JSON.parse(JSON.stringify(component.get("v.account"))));
        helper.init(component);
    },
    
    onEditClick : function(component, event, helper) { 
        component.set('v.mode', 'edit');
	},
    
    onCancelClick : function(component, event, helper) {
        component.set('v.account', JSON.parse(JSON.stringify(component.get('v.accountOld'))));
        component.set('v.mode', 'view');
	},
    
    onSaveClick : function(component, event, helper) {
        var account = component.get("v.account");
        var customerId = component.get('v.customerId');
        var caseId = component.get('v.caseId');
        //CH01: Start
        console.log('Profile Update Save Click');
        let invalidCountryCodes = $A.get("$Label.c.INVALID_COUNTRY_CODE_JO").split(',');
        
        
        var childcontactInformation = component.find('contactInformation');
        var mobileCountryCode = childcontactInformation.find("countryISOCode").get("v.value");
        console.log('Mobile Country Code:',mobileCountryCode);
        let userCode = mobileCountryCode ? mobileCountryCode.replace(/\s+/g, '').trim() : '';
        
        if(invalidCountryCodes.includes(userCode)){
            //error condition
            component.find('idValNotice').showNotice({
                "variant": "error",
                "header": "Please check the Mobile Country Code!",
                "message": "Restricted country code for mobile number. Please use different country code",
                closeCallback: function () { }
            });
            return;
            
        }
        //CH01: END   
        helper.save(component, account, customerId, caseId);
    }
})