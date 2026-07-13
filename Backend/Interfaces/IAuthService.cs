using ReimbursementAPI.DTOs.Auth;

namespace ReimbursementAPI.Interfaces;

/// <summary>
/// Handles authentication logic. Currently uses plain-text password
/// matching against the repository. In production, use proper hashing.
/// </summary>
public interface IAuthService
{
    Task<EmployeeDto?> AuthenticateAsync(string username, string password, string? loginAs);
    Task<EmployeeDto?> GetEmployeeByIdAsync(string id);
}
