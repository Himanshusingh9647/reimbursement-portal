namespace ReimbursementAPI.DTOs.Requests;

/// <summary>
/// Payload received from the finance team when reviewing a reimbursement request.
/// For travel requests the reviewer can set individual stage statuses;
/// for non-travel requests only <see cref="Status"/> is used.
/// </summary>
public class FinanceReviewDto
{
    /// <summary>Employee ID of the finance reviewer performing this action.</summary>
    public string FinanceEmpId { get; set; } = string.Empty;

    /// <summary>Overall status for simple (non-travel) requests. Values: approved | rejected.</summary>
    public string? Status { get; set; }

    /// <summary>Pre-approval status for travel requests.</summary>
    public string? PreApprovalStatus { get; set; }

    /// <summary>Settlement review status for travel requests.</summary>
    public string? SettlementStatus { get; set; }

    /// <summary>Extension review status for travel requests.</summary>
    public string? ExtensionStatus { get; set; }

    /// <summary>Document review status for travel pre-approvals.</summary>
    public string? DocumentReviewStatus { get; set; }

    /// <summary>Current stage of the travel request workflow.</summary>
    public string? Stage { get; set; }

    /// <summary>Optional note from the finance reviewer.</summary>
    public string? FinanceNote { get; set; }
}
