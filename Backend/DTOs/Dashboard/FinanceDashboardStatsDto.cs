namespace ReimbursementAPI.DTOs.Dashboard;

public class FinanceDashboardStatsDto
{
    public int PendingPreApproval { get; set; }
    public int PendingSettlement { get; set; }
    public int PendingOther { get; set; }
    public int ApprovedThisMonth { get; set; }
    public int TotalRejected { get; set; }
    public decimal TotalSubmittedValue { get; set; }
    public List<object> ActionableRequests { get; set; } = new();
}
