using Dapper;
using System.Data;
using ReimbursementAPI.Models;

using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Repositories;
/// <summary>
/// MSSQL implementation — calls stored procedures via Dapper.
/// </summary>
public class EmployeeRepository : IEmployeeRepository
{
    private readonly IDbConnectionFactory _factory;

    public EmployeeRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task<Employee?> GetEmployeeByUsernameAsync(string username, string passwordHash)
    {
        using var conn = _factory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<Employee>(
            "sp_GetEmployeeByUsername",
            new { Username = username, PasswordHash = passwordHash },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<Employee?> GetEmployeeByIdAsync(string id)
    {
        using var conn = _factory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<Employee>(
            "sp_GetEmployeeById",
            new { Id = id },
            commandType: CommandType.StoredProcedure
        );
    }
}
