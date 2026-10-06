public with sharing class LoginActivityWrapper {
    @AuraEnabled public Datetime loginTimestamp { get; set; }
    @AuraEnabled public String status { get; set; } // Success / Failed
    @AuraEnabled public String errorCode { get; set; } // Populated if Status=Failed
    @AuraEnabled public String deviceIp { get; set; }
    @AuraEnabled public Boolean vpnUsed { get; set; }
    @AuraEnabled public String vpnType { get; set; } // App / eSIM
    @AuraEnabled public String timeZone { get; set; }
    @AuraEnabled public String deviceModel { get; set; } // e.g., iPhone 12
    @AuraEnabled public String deviceType { get; set; } // iOS / Android
    @AuraEnabled public String operator { get; set; } // Network operator
    @AuraEnabled public String authType { get; set; } // PIN / Biometric
    @AuraEnabled public String unit { get; set; } // e.g., ila Bahrain
    @AuraEnabled public String location { get; set; } // Country, City

    public LoginActivityWrapper() {}
}