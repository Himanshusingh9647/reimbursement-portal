namespace ReimbursementAPI.DTOs.Dashboard;

public class DashboardStatsDto
{
    public int TotalRequests { get; set; }
    public int Pending { get; set; }
    public int Approved { get; set; }
    public decimal TotalReimbursed { get; set; }
    public List<object> RecentRequests { get; set; } = new();
}
