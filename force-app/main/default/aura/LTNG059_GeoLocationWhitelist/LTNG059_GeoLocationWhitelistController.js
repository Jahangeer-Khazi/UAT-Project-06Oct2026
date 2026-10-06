({
    doInit : function(component, event, helper) {
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); // January is 0
        var yyyy = today.getFullYear();      
        var todayFormatted = yyyy + '-' + mm + '-' + dd;
        component.set("v.todayDateString", todayFormatted);
	},
	GeoLocationCheck : function(component, event, helper) {
      var Geo = component.find("Geo");  
      var account = component.get("v.account");
      console.log('Fetching Minor Value from UI:',Geo.get("v.value"));
      account.Bypass_Geo_Location_Check_Update__pc = Geo.get("v.value");
        if(Geo.get("v.value")){
            component.set("v.isChecked","true");
        }else{
            component.set("v.isChecked","false");
            component.set("v.selectedDate","");
            component.set("v.selectedCountry","");
        }
	},
	GeoLocationDateCheck : function(component, event, helper) {
      var GeoDate = component.get("v.selectedDate"); 
      console.log('Fetching Minor Value from UI:',GeoDate);
      helper.checkDateIsFuture(component,GeoDate);
	},
    GeoLocationCountry:function(component, event, helper) {
      var Geoloc = event.getSource().get("v.value"); 
      var account = component.get("v.account");
      console.log('Fetching Minor Value from UI:',Geoloc);
      account.Bypass_Geo_Location_Country_Update__pc = Geoloc;
        component.set("v.selectedCountry",Geoloc);
    }
})