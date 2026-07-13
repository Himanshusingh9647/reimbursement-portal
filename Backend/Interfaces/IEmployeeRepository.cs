using ReimbursementAPI.Models;

namespace ReimbursementAPI.Interfaces;

/// <summary>
/// Contract for employee data access.
/// </summary>
public interface IEmployeeRepository
{
    Task<Employee?> GetEmployeeByUsernameAsync(string username, string passwordHash);
    Task<Employee?> GetEmployeeByIdAsync(string id);
}
