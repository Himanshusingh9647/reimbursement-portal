namespace ReimbursementAPI.DTOs.Auth;

public record LoginDto(string Username, string Password, string? LoginAs = null);
