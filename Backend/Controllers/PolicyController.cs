using Microsoft.AspNetCore.Mvc;

namespace ReimbursementAPI.Controllers;

[ApiController]
[Route("api/[controller]")]
public class PolicyController : ControllerBase
{
    // Mock exchange rates — in production this would call a backend service or DB
    private static readonly Dictionary<string, object> KnownRates = new()
    {
        { "Vietnam",     new { Currency = "VND", Rate = 0.0034m } },
        { "Korea",       new { Currency = "KRW", Rate = 0.062m } },
        { "Philippines", new { Currency = "PHP", Rate = 1.48m } },
        { "Japan",       new { Currency = "JPY", Rate = 0.55m } },
        { "USA",         new { Currency = "USD", Rate = 83.50m } },
        { "UK",          new { Currency = "GBP", Rate = 105.20m } },
        { "Singapore",   new { Currency = "SGD", Rate = 61.80m } },
        { "Germany",     new { Currency = "EUR", Rate = 91.50m } },
        { "Australia",   new { Currency = "AUD", Rate = 54.30m } },
        { "Canada",      new { Currency = "CAD", Rate = 61.20m } },
    };

    /// <summary>
    /// GET /api/policy/exchange-rate/{country}
    /// Returns { currency: "KRW", rate: 0.062 } for known countries.
    /// Falls back to USD for unknown countries (simulates backend fetch).
    /// </summary>
    [HttpGet("exchange-rate/{country}")]
    public IActionResult GetExchangeRate(string country)
    {
        if (KnownRates.TryGetValue(country, out var rate))
            return Ok(rate);

        // Fallback for unknown countries — mock a backend lookup
        return Ok(new { Currency = "USD", Rate = 83.50m });
    }

    /// <summary>
    /// GET /api/policy/domestic-states
    /// Returns the domestic state-to-area mapping.
    /// </summary>
    [HttpGet("domestic-states")]
    public IActionResult GetDomesticStates()
    {
        var states = new Dictionary<string, string>
        {
            { "Maharashtra", "Area A" }, { "Delhi", "Area A" }, { "Karnataka", "Area A" }, { "Tamil Nadu", "Area A" },
            { "Telangana", "Area B" }, { "Gujarat", "Area B" }, { "West Bengal", "Area B" },
            { "Other", "Area C" }
        };
        return Ok(states);
    }

    /// <summary>
    /// GET /api/policy/international-countries
    /// Returns the list of standard international destinations.
    /// </summary>
    [HttpGet("international-countries")]
    public IActionResult GetInternationalCountries()
    {
        return Ok(new[] { "Vietnam", "Korea", "Philippines", "Other" });
    }
}
