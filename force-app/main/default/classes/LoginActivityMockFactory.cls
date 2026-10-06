public with sharing class LoginActivityMockFactory {
    
    public static List<LoginActivityWrapper> generateLoginActivities(Integer count) {
        List<LoginActivityWrapper> activities = new List<LoginActivityWrapper>();
        
        String[] statuses = new String[]{'Success', 'Failed'};
        String[] vpnTypes = new String[]{'App', 'eSIM'};
        String[] deviceModels = new String[]{'iPhone 12', 'Samsung Galaxy S21', 'Pixel 6', 'iPhone 14 Pro'};
        String[] deviceTypes = new String[]{'iOS', 'Android'};
        String[] authTypes = new String[]{'PIN', 'Biometric'};
        String[] units = new String[]{'ila Bahrain', 'ila Jordan', 'alburaq'};
        String[] locations = new String[]{'Bahrain, Manama', 'Jordan, Amman', 'UAE, Dubai'};
        
        for (Integer i = 0; i < count; i++) {
            LoginActivityWrapper item = new LoginActivityWrapper();
            item.loginTimestamp = Datetime.now().addHours(-i * 2);
            item.status = statuses[Math.mod(i, 2)]; // Alternating success/fail
            
            if (item.status == 'Failed') {
                item.errorCode = 'LOGIN_INVALID';
            } else {
                item.errorCode = '';
            }
            
            item.deviceIp = '192.168.1.' + i;
            item.vpnUsed = Math.mod(i, 3) == 0; // Every 3rd is VPN
            if (item.vpnUsed) {
                item.vpnType = vpnTypes[Math.mod(i, vpnTypes.size())];
            } else {
                item.vpnType = '';
            }
            
            item.timeZone = 'GMT+3';
            item.deviceModel = deviceModels[Math.mod(i, deviceModels.size())];
            item.deviceType = deviceTypes[Math.mod(i, deviceTypes.size())];
            item.operator = 'STC'; // Simplified
            item.authType = authTypes[Math.mod(i, authTypes.size())];
            item.unit = units[Math.mod(i, units.size())];
            item.location = locations[Math.mod(i, locations.size())];
            
            activities.add(item);
        }
        return activities;
    }

    public static List<LoginActivityDetailWrapper> generateActivityDetails(Integer count) {
        List<LoginActivityDetailWrapper> details = new List<LoginActivityDetailWrapper>();
        
        String[] channels = new String[]{'SMS', 'Email', 'App'};
        String[] categories = new String[]{'Notification', 'Action'};
        String[] units = new String[]{'ila Bahrain', 'ila Jordan', 'alburaq'};
        String[] descriptions = new String[]{'OTP Sent', 'Password Change', 'Login from new IP', 'Statement Viewed'};
        
        for (Integer i = 0; i < count; i++) {
            LoginActivityDetailWrapper item = new LoginActivityDetailWrapper();
            item.timestamp = Datetime.now().addHours(-i);
            item.channel = channels[Math.mod(i, channels.size())];
            item.unit = units[Math.mod(i, units.size())];
            item.category = categories[Math.mod(i, categories.size())];
            item.description = descriptions[Math.mod(i, descriptions.size())];
            
            // Make some fail specifically
            if (Math.mod(i, 5) == 0) {
                 item.result = 'Failed';
                 item.errorCode = 'ERR_00' + i;
            } else {
                 item.result = 'Success';
                 item.errorCode = '';
            }
            
            details.add(item);
        }
        return details;
    }
}