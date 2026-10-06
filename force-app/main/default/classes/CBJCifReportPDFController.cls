public with sharing class CBJCifReportPDFController {
    public class ReportWrapper {
        public CBJCifReportService.ReportData data { get; set; }
        public String statusLabel { get; set; }
        public String statusClass { get; set; }
        public String formattedGenerateDate { get; set; }

        public ReportWrapper(CBJCifReportService.ReportData r) {
            this.data = r;
            this.formattedGenerateDate = r.generateDate + ', 00:00';
            if (r.status != null && r.status.name != null) {
                String s = r.status.name.toUpperCase();
                if (s.startsWith('COMPLETED')) {
                    this.statusLabel = 'Active';
                    this.statusClass = 'status-active';
                } else if (s == 'PENDING') {
                    this.statusLabel = 'Pending';
                    this.statusClass = 'status-pending';
                } else if (s == 'EXPIRED') {
                    this.statusLabel = 'Expired';
                    this.statusClass = 'status-failed';
                } else {
                    this.statusLabel = r.status.name;
                    this.statusClass = 'status-failed';
                }
            } else {
                this.statusLabel = 'N/A';
                this.statusClass = '';
            }
        }
    }

    public CBJCifReportService.CustomerInfo customer { get; private set; }
    public String jodAccountNumber { get; private set; }
    public List<ReportWrapper> activeReports { get; private set; }
    public List<ReportWrapper> expiredReports { get; private set; }
    public Integer activeCount { get; private set; }
    public Integer expiredCount { get; private set; }
    public String todayDate { get; private set; }

    public CBJCifReportPDFController() {
        String recordId = ApexPages.currentPage().getParameters().get('id');
        todayDate = Datetime.now().format('dd MMM yyyy, HH:mm');
        
        if (String.isNotBlank(recordId)) {
            customer = CBJCifReportService.getCustomerInfo(recordId);
            String cif = customer != null ? customer.cif : null;
            String email = customer != null ? customer.email : null;
            String region = customer != null ? customer.region : null;

            CBJCifReportService.ReportListResponse reportRes = CBJCifReportService.getReportRequests(cif, email, region);
            activeReports = new List<ReportWrapper>();
            expiredReports = new List<ReportWrapper>();
            
            if (reportRes != null && reportRes.data != null) {
                for (CBJCifReportService.ReportData r : reportRes.data) {
                    ReportWrapper wrapper = new ReportWrapper(r);
                    if (r.status != null && r.status.name != null && r.status.name.equalsIgnoreCase('expired')) {
                        expiredReports.add(wrapper);
                    } else {
                        activeReports.add(wrapper);
                    }
                }
            }
            activeCount = activeReports.size();
            expiredCount = expiredReports.size();
            
            jodAccountNumber = 'N/A';
            CBJCifReportService.AccountDetailsResponse accRes = CBJCifReportService.getAccountDetails(cif, region);
            if (accRes != null && accRes.data != null && accRes.data.account != null) {
                if (accRes.data.account.currency_z != null && accRes.data.account.currency_z.code == 'JOD') {
                    jodAccountNumber = accRes.data.account.number_z;
                }
            }
        }
    }
}