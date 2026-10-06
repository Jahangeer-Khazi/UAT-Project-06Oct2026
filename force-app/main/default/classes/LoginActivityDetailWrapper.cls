public with sharing class LoginActivityDetailWrapper {
    @AuraEnabled public Datetime timestamp { get; set; }
    @AuraEnabled public String channel { get; set; } // Device ID from API
    @AuraEnabled public String unit { get; set; } // City from API
    @AuraEnabled public String category { get; set; } // IP address from API
    @AuraEnabled public String description { get; set; }
    @AuraEnabled public String result { get; set; }
    @AuraEnabled public String errorCode { get; set; }

    public LoginActivityDetailWrapper() {}
}