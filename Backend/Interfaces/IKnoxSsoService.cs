using ReimbursementAPI.DTOs.Auth;

namespace ReimbursementAPI.Interfaces;

/// <summary>
/// Service contract for Knox SSO token validation and employee resolution.
/// Implementations should validate the JWT token using the configured private key
/// and extract employee information from the token claims.
/// </summary>
public interface IKnoxSsoService
{
    /// <summary>
    /// Validates a Knox SSO JWT token and returns the authenticated employee.
    /// </summary>
    /// <param name="token">The JWT token from Knox SSO.</param>
    /// <returns>Employee DTO if the token is valid; null if validation fails.</returns>
    Task<EmployeeDto?> ValidateAndAuthenticateAsync(string token);

    /// <summary>
    /// Returns whether Knox SSO is currently enabled in configuration.
    /// </summary>
    bool IsEnabled { get; }

    /// <summary>
    /// Returns the Knox SSO login page URL for frontend redirect.
    /// </summary>
    string GetLoginUrl();
}
