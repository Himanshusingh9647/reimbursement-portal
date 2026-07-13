using Microsoft.AspNetCore.Mvc;
using ReimbursementAPI.DTOs.Auth;
using ReimbursementAPI.Services;
using ReimbursementAPI.Interfaces;
namespace ReimbursementAPI.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        var employee = await _authService.AuthenticateAsync(dto.Username, dto.Password, dto.LoginAs);

        if (employee == null)
            return Unauthorized(new { message = "Invalid username or password" });

        return Ok(employee);
    }
}
