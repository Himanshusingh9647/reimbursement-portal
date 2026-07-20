using Microsoft.AspNetCore.Mvc;
using ReimbursementAPI.DTOs.Policy;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Controllers;

/// <summary>
/// Provides policy data endpoints. All policy data is stored in the database
/// and can be updated via the PUT endpoints without redeployment.
/// </summary>
[ApiController]
[Route("api/[controller]")]
public class PolicyController : ControllerBase
{
    private readonly IPolicyService _policyService;

    public PolicyController(IPolicyService policyService)
    {
        _policyService = policyService;
    }

    // ── Generic Policy CRUD ────────────────────────────────────────

    /// <summary>Returns all policy data records.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<PolicyDataDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAllPolicies()
    {
        var policies = await _policyService.GetAllPoliciesAsync();
        return Ok(policies);
    }

    /// <summary>Returns a single policy data record by category key.</summary>
    [HttpGet("{category}")]
    [ProducesResponseType(typeof(PolicyDataDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetPolicyByCategory(string category)
    {
        var policy = await _policyService.GetPolicyByCategoryAsync(category);
        if (policy == null)
            return NotFound(new { message = $"Policy category '{category}' not found." });
        return Ok(policy);
    }

    /// <summary>Creates or updates a policy data record for the given category.</summary>
    [HttpPut("{category}")]
    [ProducesResponseType(typeof(PolicyDataDto), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpsertPolicy(string category, [FromBody] UpsertPolicyDataDto dto)
    {
        var result = await _policyService.UpsertPolicyAsync(category, dto.JsonData, dto.UpdatedBy);
        return Ok(result);
    }

    // ── Convenience Endpoints (backward-compatible) ────────────────

    /// <summary>
    /// GET /api/policy/exchange-rate/{country}
    /// Returns { currency, rate } for the given country from the database.
    /// Falls back to USD for unknown countries.
    /// </summary>
    [HttpGet("exchange-rate/{country}")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetExchangeRate(string country)
    {
        var rate = await _policyService.GetExchangeRateAsync(country);
        return Ok(rate);
    }

    /// <summary>
    /// GET /api/policy/domestic-states
    /// Returns the domestic state-to-area mapping from the database.
    /// </summary>
    [HttpGet("domestic-states")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetDomesticStates()
    {
        var states = await _policyService.GetDomesticStatesAsync();
        return Ok(states);
    }

    /// <summary>
    /// GET /api/policy/international-countries
    /// Returns the list of standard international destinations from the database.
    /// </summary>
    [HttpGet("international-countries")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public async Task<IActionResult> GetInternationalCountries()
    {
        var countries = await _policyService.GetInternationalCountriesAsync();
        return Ok(countries);
    }
}
