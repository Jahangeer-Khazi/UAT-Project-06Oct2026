/**
Change History :
*         #CH01 : #D&A Team #24-06-2022# Added Case model parameter to add alburaq logic.
*		  #CH02 :  Added by Aniss Mbarki  11-09-2023 supplementary requirement jordan
*/
({

    doInit: function (component, event, helper) {
        var accId = component.get('v.accountId');
        console.log('LTNG001 ====> AccountId :  '+accId);
        helper.getCurrentCards(component, event, helper,accId);
    },
    accChange : function (component, event, helper) { 
        var newVal = event.getParam("value");
        if( !Array.isArray(newVal) ){
            console.error(newVal);
            //console.error(JSON.stringify(newVal));
            //console.error(component.get('v.accountId'));
            helper.getCurrentCards(component, event, helper,component.get('v.accountId'));
        }else if(Array.isArray(newVal) && newVal.length == 0 ){
            component.set("v.valueCurrentCard",null);
            helper.getCurrentCards(component, event, helper,null);
        }

    },
    primaryCardChange : function (component, event, helper) {
        console.error('primaryCardChange=================>>>>');
        var myValues= component.get("v.currentCards");
        var value = component.find("primaryRecord").get("v.value");
        console.log(value);
        var maskNum = '';
        var confId = '';
        var cardDisplayName = '';
        //#CH02 : add productMappingCode
        var productMappingCode = '';
        myValues.findIndex(item => {
            console.error('item.id =================>>>>'+item.id);
            console.log(item);
            console.log('check -->',(item.id == value));
            if(item.id == value){
                maskNum = item.maskedCardNumber;
                confId = item.cardProductConfigurationId;
                cardDisplayName = item.cardDisplayName;
            	productMappingCode = item.productMappingCode;
            }
            console.log('item after',item);
        });
        component.set("v.maskedNumCurrentCard", maskNum );
        component.set("v.productConfigCurrentCard", confId );
        component.set("v.cardDisplayName", cardDisplayName );
        component.set("v.productMappingCode", productMappingCode );
            
        console.log('maskNum --->',component.get("v.maskedNumCurrentCard"));
            console.log('productConfigCurrentCard --->',component.get("v.productConfigCurrentCard"));
            console.log('cardDisplayName --->',component.get("v.cardDisplayName"));
            console.log('productMappingCode --->',component.get("v.productMappingCode"));

    },
     caseModelIsChanged : function(component, event, helper) {
        console.error('is changed caseModelIsChanged');
        //#CH01
        component.find("primaryRecord").set("v.value",'');
        var accId = component.get('v.accountId');
        helper.getCurrentCards(component, event, helper,accId);
    },
})