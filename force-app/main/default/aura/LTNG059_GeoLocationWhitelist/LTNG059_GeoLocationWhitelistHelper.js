({
	checkDateIsFuture : function(component, selectedDateString) {
        // 1. Convert the input date string to a JavaScript Date object
        // The input string is in YYYY-MM-DD format.
        var account = component.get("v.account");
        var selectedDate = new Date(selectedDateString);
        
        // 2. Get today's date and set time to midnight for an accurate day-level comparison
        var today = new Date();
        today.setHours(0, 0, 0, 0); 

        // 3. Perform the comparison
        // Comparison logic: selectedDate > today
        if (selectedDate > today) {
            account.Bypass_Geo_Location_End_Date_Update__pc = selectedDateString;
        } else {
            component.set("v.selectedDate","");
        }
    }
})