namespace ReimbursementAPI.DTOs.Policy;

/// <summary>
/// Represents a single policy data record stored in the PolicyData table.
/// Each record contains a category key and its associated JSON configuration.
/// </summary>
public class PolicyDataDto
{
    public int Id { get; set; }

    /// <summary>Category key, e.g. "ExchangeRates", "DomesticStates", "InternationalCountries".</summary>
    public string Category { get; set; } = string.Empty;

    /// <summary>JSON string containing the policy configuration data.</summary>
    public string JsonData { get; set; } = "{}";

    /// <summary>Timestamp of the last update.</summary>
    public DateTime UpdatedAt { get; set; }

    /// <summary>Employee ID of the user who last updated this record.</summary>
    public string? UpdatedBy { get; set; }
}

/// <summary>
/// Request payload for creating or updating a policy data record.
/// </summary>
public class UpsertPolicyDataDto
{
    /// <summary>JSON string containing the policy configuration data.</summary>
    public string JsonData { get; set; } = "{}";

    /// <summary>Employee ID of the user performing the update.</summary>
    public string? UpdatedBy { get; set; }
}
