public class PayrollData {
    public Id recordId { get; set; }
    public String makerResult { get; set; }
    public String checkerResult { get; set; }
    public String payrollAction { get; set; }
    public Decimal payrollTotalDebitAmount { get; set; }
    public Decimal payrollDebitAccountBalance { get; set; }
    public String uniquePayrollId { get; set; }
    public String cif { get; set; }
    public String payrollReason { get; set; }
    
    public PayrollData(Id recordId) {
        this.recordId = recordId;
    }
}