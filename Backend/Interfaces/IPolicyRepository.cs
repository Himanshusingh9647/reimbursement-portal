using ReimbursementAPI.DTOs.Policy;

namespace ReimbursementAPI.Interfaces;

/// <summary>
/// Data access contract for policy configuration stored in the PolicyData table.
/// </summary>
public interface IPolicyRepository
{
    /// <summary>Retrieves all policy data records.</summary>
    Task<IEnumerable<PolicyDataDto>> GetAllAsync();

    /// <summary>Retrieves a single policy record by its category key.</summary>
    Task<PolicyDataDto?> GetByCategoryAsync(string category);

    /// <summary>Creates or updates a policy record for the given category.</summary>
    Task UpsertAsync(string category, string jsonData, string? updatedBy);
}
