({
	onFATCA_CustomerChanged : function(component, event, helper) {
        var fatcaCustomer = component.find("fatcaCustomer");
		var account = component.get("v.account");
        console.log('Fatca Value form UI:',fatcaCustomer.get("v.value"));
        account.FATCA_Customer__pc = fatcaCustomer.get("v.value");
	}, 
    
    onEmploymentStatusChanged : function(component, event, helper) {
        var account = component.get("v.account");
        if(account.Employment_Status__pc == "Employed"){
            account.Business_Name__pc = '';
            account.Business_Address__pc = '';
            account.Business_Industry__pc = '';
        }else if(account.Employment_Status__pc == "Self Employed"){
            account.Employer_Name__pc = '';
            account.Employer_Address__pc = '';
            account.Employer_Country__pc = '';
        }else if(account.Employment_Status__pc == 'Retired' || account.Employment_Status__pc == 'Unemployed'){
        	account.Business_Name__pc = '';
            account.Business_Address__pc = '';
            account.Business_Industry__pc = '';
            
            account.Employer_Name__pc = '';
            account.Employer_Address__pc = '';
            account.Employer_Country__pc = '';
        }
        component.set("v.account", account);
    },
    
    SourceOfFundsChanged : function(component, event, helper) {
        
        var account = component.get("v.account");
    	if(account.Sources_of_Funds__pc){
            var sources = account.Sources_of_Funds__pc.split(";");
            var source_other = false;
            for(var i in sources){
                if(sources[i] === "Other"){
                    source_other = true;
                    break;
                }
            }
            
            if(!source_other){
            	account.Source_Found_specify__pc = '';
            }
        }
        component.set("v.account", account);
    }
})