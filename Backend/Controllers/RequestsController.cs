using Microsoft.AspNetCore.Mvc;
using ReimbursementAPI.DTOs.Requests;
using ReimbursementAPI.DTOs.Auth;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Controllers;

/// <summary>
/// Handles all reimbursement request operations: CRUD, travel workflows,
/// finance reviews, and employee info lookups.
/// </summary>
[ApiController]
[Route("api/requests")]
public class RequestsController : ControllerBase
{
    private readonly IRequestService _requestService;
    private readonly IAuthService _authService;

    public RequestsController(IRequestService requestService, IAuthService authService)
    {
        _requestService = requestService;
        _authService = authService;
    }

    // ── Employee Info ──────────────────────────────────────────────

    /// <summary>Returns employee details needed during finance review.</summary>
    [HttpGet("employee-info/{empId}")]
    [ProducesResponseType(typeof(EmployeeDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<EmployeeDto>> GetEmployeeInfo(string empId)
    {
        var emp = await _authService.GetEmployeeByIdAsync(empId);
        if (emp == null) return NotFound(new { message = $"Employee '{empId}' not found." });
        return Ok(emp);
    }

    // ── Query APIs ─────────────────────────────────────────────────

    /// <summary>Returns all reimbursement requests across all employees.</summary>
    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<FrontendRequestDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<FrontendRequestDto>>> GetAllRequests()
    {
        var reqs = await _requestService.GetAllRequestsAsync();
        return Ok(reqs.Select(FrontendRequestDto.FromRequestDto));
    }

    /// <summary>Returns a single request by its ID.</summary>
    [HttpGet("{id}")]
    [ProducesResponseType(typeof(FrontendRequestDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<FrontendRequestDto>> GetRequestById(string id)
    {
        var request = await _requestService.GetRequestByIdAsync(id);
        if (request == null) return NotFound(new { message = $"Request '{id}' not found." });
        return Ok(FrontendRequestDto.FromRequestDto(request));
    }

    /// <summary>Returns all requests for a specific employee.</summary>
    [HttpGet("employee/{empId}")]
    [ProducesResponseType(typeof(IEnumerable<FrontendRequestDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<FrontendRequestDto>>> GetRequestsByEmployee(string empId)
    {
        var reqs = await _requestService.GetRequestsForEmployeeAsync(empId);
        return Ok(reqs.Select(FrontendRequestDto.FromRequestDto));
    }

    /// <summary>Returns requests that require finance team action.</summary>
    [HttpGet("finance")]
    [ProducesResponseType(typeof(IEnumerable<FrontendRequestDto>), StatusCodes.Status200OK)]
    public async Task<ActionResult<IEnumerable<FrontendRequestDto>>> GetFinanceActionableRequests()
    {
        var reqs = await _requestService.GetRequestsForFinanceAsync();
        return Ok(reqs.Select(FrontendRequestDto.FromRequestDto));
    }

    // ── Create APIs ────────────────────────────────────────────────

    /// <summary>Creates a new domestic or international travel request with pre-approval.</summary>
    [HttpPost("travel/{empId}")]
    [ProducesResponseType(typeof(FrontendRequestDto), StatusCodes.Status201Created)]
    public async Task<ActionResult<FrontendRequestDto>> CreateTravelRequest(string empId, [FromBody] TripRequestDto dto)
    {
        var req = new RequestDto { EmpId = empId, Title = $"Travel to {dto.Destination}" };
        var created = await _requestService.CreateTravelRequestAsync(req, dto);
        return CreatedAtAction(nameof(GetRequestById), new { id = created.Id }, FrontendRequestDto.FromRequestDto(created));
    }

    /// <summary>Creates a new internet bill reimbursement request.</summary>
    [HttpPost("internet/{empId}")]
    [ProducesResponseType(typeof(FrontendRequestDto), StatusCodes.Status201Created)]
    public async Task<ActionResult<FrontendRequestDto>> CreateInternet(string empId, [FromBody] InternetBillRequestDto dto)
    {
        var req = new RequestDto { EmpId = empId, Title = "Internet Bill" };
        var created = await _requestService.CreateInternetRequestAsync(req, dto);
        return CreatedAtAction(nameof(GetRequestById), new { id = created.Id }, FrontendRequestDto.FromRequestDto(created));
    }

    /// <summary>Creates a new carpool reimbursement request with member details.</summary>
    [HttpPost("carpool")]
    [ProducesResponseType(typeof(FrontendRequestDto), StatusCodes.Status201Created)]
    public async Task<ActionResult<FrontendRequestDto>> CreateCarpool([FromBody] CarpoolGroupDto dto)
    {
        var req = new RequestDto { EmpId = dto.VehicleOwnerEmpId, Title = "Carpool Request" };
        var created = await _requestService.CreateCarpoolRequestAsync(req, dto);
        return CreatedAtAction(nameof(GetRequestById), new { id = created.Id }, FrontendRequestDto.FromRequestDto(created));
    }

    /// <summary>Creates a new relocation reimbursement request.</summary>
    [HttpPost("relocation/{empId}")]
    [ProducesResponseType(typeof(FrontendRequestDto), StatusCodes.Status201Created)]
    public async Task<ActionResult<FrontendRequestDto>> CreateRelocation(string empId, [FromBody] RelocationRequestDto dto)
    {
        var req = new RequestDto { EmpId = empId, Title = $"Relocation {dto.FromCity} to {dto.ToCity}" };
        var created = await _requestService.CreateRelocationRequestAsync(req, dto);
        return CreatedAtAction(nameof(GetRequestById), new { id = created.Id }, FrontendRequestDto.FromRequestDto(created));
    }

    // ── Update APIs ────────────────────────────────────────────────

    /// <summary>Submits a trip extension request for an approved travel pre-approval.</summary>
    [HttpPost("{id}/extend-trip")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> SubmitTripExtension(string id, [FromBody] TripExtensionDto dto)
    {
        var existing = await _requestService.GetRequestByIdAsync(id);
        if (existing == null)
            return NotFound(new { message = "Request not found." });

        if (existing.Type != "travel" || existing.TripRequest?.PreApproval?.Status != "approved")
            return BadRequest(new { message = "Trip extension can only be requested after pre-approval." });

        if (dto.RevisedDays == null && dto.RevisedEndDate.HasValue && existing.TripRequest?.StartDate.HasValue == true)
        {
            dto.RevisedDays = (int)(dto.RevisedEndDate.Value.Date - existing.TripRequest.StartDate.Value.Date).TotalDays + 1;
        }

        await _requestService.SubmitTripExtensionAsync(id, dto);
        return Ok(new { message = "Trip extension submitted successfully.", id });
    }

    /// <summary>Submits settlement details for a travel request.</summary>
    [HttpPost("{id}/settlement")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> SubmitSettlement(string id, [FromBody] SettlementDto dto)
    {
        var existing = await _requestService.GetRequestByIdAsync(id);
        if (existing == null)
            return NotFound(new { message = "Request not found." });

        await _requestService.SubmitSettlementAsync(id, dto);
        return Ok(new { message = "Settlement submitted successfully.", id });
    }

    /// <summary>Finance team reviews a request — approves, rejects, or returns for changes.</summary>
    [HttpPut("{id}/finance-review")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> FinanceReview(string id, [FromBody] FinanceReviewDto req)
    {
        var existing = await _requestService.GetRequestByIdAsync(id);
        if (existing == null)
            return NotFound(new { message = $"Request '{id}' not found." });

        if (existing.Type == "travel")
        {
            await _requestService.FinanceReviewTravelAsync(
                id, req.FinanceEmpId,
                req.PreApprovalStatus, req.SettlementStatus,
                req.ExtensionStatus, req.DocumentReviewStatus,
                req.Stage, req.FinanceNote);
        }
        else
        {
            await _requestService.FinanceReviewOtherAsync(
                id, req.FinanceEmpId,
                req.Status ?? "approved", req.FinanceNote);
        }

        return NoContent();
    }
}
