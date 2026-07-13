namespace ReimbursementAPI.Models;

public class Employee
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string ClLevel { get; set; } = string.Empty;
    public string Department { get; set; } = string.Empty;
    public string Designation { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Manager { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public bool HasFinanceAccess { get; set; }
    public bool HasAdminAccess { get; set; }
    public string Team { get; set; } = string.Empty;
    public string Project { get; set; } = string.Empty;
}
