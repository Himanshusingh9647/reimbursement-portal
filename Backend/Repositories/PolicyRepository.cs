using Dapper;
using System.Data;
using ReimbursementAPI.DTOs.Policy;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Repositories;

/// <summary>
/// MSSQL implementation of <see cref="IPolicyRepository"/>.
/// Uses stored procedures via Dapper for all database operations.
/// </summary>
public class PolicyRepository : IPolicyRepository
{
    private readonly IDbConnectionFactory _factory;

    public PolicyRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    /// <inheritdoc />
    public async Task<IEnumerable<PolicyDataDto>> GetAllAsync()
    {
        using var conn = _factory.CreateConnection();
        return await conn.QueryAsync<PolicyDataDto>(
            "sp_GetAllPolicyData",
            commandType: CommandType.StoredProcedure);
    }

    /// <inheritdoc />
    public async Task<PolicyDataDto?> GetByCategoryAsync(string category)
    {
        using var conn = _factory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<PolicyDataDto>(
            "sp_GetPolicyDataByCategory",
            new { Category = category },
            commandType: CommandType.StoredProcedure);
    }

    /// <inheritdoc />
    public async Task UpsertAsync(string category, string jsonData, string? updatedBy)
    {
        using var conn = _factory.CreateConnection();
        await conn.ExecuteAsync(
            "sp_UpsertPolicyData",
            new { Category = category, JsonData = jsonData, UpdatedBy = updatedBy },
            commandType: CommandType.StoredProcedure);
    }
}
