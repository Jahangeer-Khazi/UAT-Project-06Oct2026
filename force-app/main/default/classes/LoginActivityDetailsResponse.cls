public with sharing class LoginActivityDetailsResponse {
    @AuraEnabled public List<LoginActivityDetailWrapper> records { get; set; }
    @AuraEnabled public Integer totalRecords { get; set; }
    @AuraEnabled public Integer currentPage { get; set; }
    @AuraEnabled public Integer totalPages { get; set; }

    public LoginActivityDetailsResponse() {
        this.records = new List<LoginActivityDetailWrapper>();
        this.totalRecords = 0;
        this.currentPage = 1;
        this.totalPages = 1;
    }
}