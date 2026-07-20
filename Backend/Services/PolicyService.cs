using System.Text.Json;
using ReimbursementAPI.DTOs.Policy;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Services;

/// <summary>
/// Service layer for policy data management. Handles JSON parsing and
/// provides typed access to specific policy categories.
/// </summary>
public class PolicyService : IPolicyService
{
    private readonly IPolicyRepository _repo;

    public PolicyService(IPolicyRepository repo)
    {
        _repo = repo;
    }

    /// <inheritdoc />
    public async Task<IEnumerable<PolicyDataDto>> GetAllPoliciesAsync()
    {
        return await _repo.GetAllAsync();
    }

    /// <inheritdoc />
    public async Task<PolicyDataDto?> GetPolicyByCategoryAsync(string category)
    {
        return await _repo.GetByCategoryAsync(category);
    }

    /// <inheritdoc />
    public async Task<PolicyDataDto?> UpsertPolicyAsync(string category, string jsonData, string? updatedBy)
    {
        await _repo.UpsertAsync(category, jsonData, updatedBy);
        return await _repo.GetByCategoryAsync(category);
    }

    /// <inheritdoc />
    public async Task<object?> GetExchangeRateAsync(string country)
    {
        var policy = await _repo.GetByCategoryAsync("ExchangeRates");
        if (policy == null)
            return new { Currency = "USD", Rate = 83.50m };

        try
        {
            using var doc = JsonDocument.Parse(policy.JsonData);
            if (doc.RootElement.TryGetProperty(country, out var countryData))
            {
                var currency = countryData.GetProperty("currency").GetString();
                var rate = countryData.GetProperty("rate").GetDecimal();
                return new { Currency = currency, Rate = rate };
            }
        }
        catch (JsonException)
        {
            // Fallback on parse error
        }

        // Fallback for unknown countries
        return new { Currency = "USD", Rate = 83.50m };
    }

    /// <inheritdoc />
    public async Task<object?> GetDomesticStatesAsync()
    {
        var policy = await _repo.GetByCategoryAsync("DomesticStates");
        if (policy == null)
        {
            return new Dictionary<string, string>
            {
                { "Maharashtra", "Area A" }, { "Delhi", "Area A" },
                { "Karnataka", "Area A" }, { "Tamil Nadu", "Area A" },
                { "Telangana", "Area B" }, { "Gujarat", "Area B" },
                { "West Bengal", "Area B" }, { "Other", "Area C" }
            };
        }

        try
        {
            return JsonSerializer.Deserialize<Dictionary<string, string>>(policy.JsonData);
        }
        catch (JsonException)
        {
            return new Dictionary<string, string> { { "Other", "Area C" } };
        }
    }

    /// <inheritdoc />
    public async Task<object?> GetInternationalCountriesAsync()
    {
        var policy = await _repo.GetByCategoryAsync("InternationalCountries");
        if (policy == null)
            return new[] { "Vietnam", "Korea", "Philippines", "Other" };

        try
        {
            return JsonSerializer.Deserialize<List<string>>(policy.JsonData);
        }
        catch (JsonException)
        {
            return new[] { "Other" };
        }
    }
}
