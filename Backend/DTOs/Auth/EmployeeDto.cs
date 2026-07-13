namespace ReimbursementAPI.DTOs.Auth;

public class EmployeeDto
{
    public string Id { get; set; } = "";
    public string Name { get; set; } = "";
    public string ClLevel { get; set; } = "";
    public string Department { get; set; } = "";
    public string? Designation { get; set; }
    public string? Email { get; set; }
    public string? Team { get; set; }
    public string? Project { get; set; }
    public bool HasFinanceAccess { get; set; }
    public bool HasAdminAccess { get; set; }
    public string? Manager { get; set; }
}
