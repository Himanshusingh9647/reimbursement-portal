using Microsoft.AspNetCore.Mvc;
using ReimbursementAPI.DTOs.Auth;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Controllers;

/// <summary>
/// Handles authentication — both traditional username/password login
/// and Knox SSO token-based authentication.
/// </summary>
[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IKnoxSsoService _knoxSsoService;

    public AuthController(IAuthService authService, IKnoxSsoService knoxSsoService)
    {
        _authService = authService;
        _knoxSsoService = knoxSsoService;
    }

    /// <summary>Authenticates an employee using username and password.</summary>
    [HttpPost("login")]
    [ProducesResponseType(typeof(EmployeeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var employee = await _authService.AuthenticateAsync(dto.Username, dto.Password, dto.LoginAs);

        if (employee == null)
            return Unauthorized(new { message = "Invalid username or password" });

        return Ok(employee);
    }

    /// <summary>
    /// Authenticates an employee using a Knox SSO JWT token.
    /// Returns 503 if Knox SSO is not configured.
    /// </summary>
    [HttpPost("knox-sso")]
    [ProducesResponseType(typeof(EmployeeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status503ServiceUnavailable)]
    public async Task<IActionResult> KnoxSsoLogin([FromBody] KnoxSsoTokenDto dto)
    {
        if (!_knoxSsoService.IsEnabled)
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, new
            {
                message = "Knox SSO is not configured. Please contact your administrator.",
                configured = false
            });
        }

        var employee = await _knoxSsoService.ValidateAndAuthenticateAsync(dto.Token);

        if (employee == null)
            return Unauthorized(new { message = "Invalid or expired Knox SSO token." });

        return Ok(employee);
    }

    /// <summary>
    /// Returns Knox SSO configuration status and login URL.
    /// Used by the frontend to decide whether to show the Knox SSO login option.
    /// </summary>
    [HttpGet("knox-sso/config")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    public IActionResult GetKnoxSsoConfig()
    {
        return Ok(new
        {
            enabled = _knoxSsoService.IsEnabled,
            loginUrl = _knoxSsoService.IsEnabled ? _knoxSsoService.GetLoginUrl() : null
        });
    }
}
