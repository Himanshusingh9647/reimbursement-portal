namespace ReimbursementAPI.DTOs.Auth;

/// <summary>
/// Configuration settings for Knox SSO integration.
/// Bound from appsettings.json section "KnoxSso".
/// </summary>
public class KnoxSsoSettings
{
    /// <summary>Section name in appsettings.json.</summary>
    public const string SectionName = "KnoxSso";

    /// <summary>Whether Knox SSO is enabled. When false, the endpoint returns 503.</summary>
    public bool Enabled { get; set; } = false;

    /// <summary>Path to the Knox SSO private key file (PEM or PKCS8 format).</summary>
    public string PrivateKeyPath { get; set; } = string.Empty;

    /// <summary>Expected issuer claim in the Knox JWT token.</summary>
    public string Issuer { get; set; } = "knox-sso";

    /// <summary>Expected audience claim in the Knox JWT token.</summary>
    public string Audience { get; set; } = "reimbursement-portal";

    /// <summary>Knox SSO login page URL for frontend redirect.</summary>
    public string LoginUrl { get; set; } = string.Empty;
}

/// <summary>
/// Request payload for Knox SSO token validation.
/// </summary>
public class KnoxSsoTokenDto
{
    /// <summary>The JWT token received from Knox SSO after authentication.</summary>
    public string Token { get; set; } = string.Empty;
}
