using ReimbursementAPI.DTOs.Policy;

namespace ReimbursementAPI.Interfaces;

/// <summary>
/// Business logic contract for policy configuration management.
/// </summary>
public interface IPolicyService
{
    /// <summary>Returns all policy data records.</summary>
    Task<IEnumerable<PolicyDataDto>> GetAllPoliciesAsync();

    /// <summary>Returns a single policy record by category, or null if not found.</summary>
    Task<PolicyDataDto?> GetPolicyByCategoryAsync(string category);

    /// <summary>Creates or updates a policy record. Returns the updated record.</summary>
    Task<PolicyDataDto?> UpsertPolicyAsync(string category, string jsonData, string? updatedBy);

    /// <summary>Returns exchange rate info for a specific country.</summary>
    Task<object?> GetExchangeRateAsync(string country);

    /// <summary>Returns the domestic state-to-area mapping.</summary>
    Task<object?> GetDomesticStatesAsync();

    /// <summary>Returns the list of international countries.</summary>
    Task<object?> GetInternationalCountriesAsync();
}
