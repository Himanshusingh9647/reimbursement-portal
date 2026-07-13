using Microsoft.AspNetCore.Mvc;
using ReimbursementAPI.DTOs.Dashboard;
using ReimbursementAPI.Services;
using ReimbursementAPI.Interfaces;
namespace ReimbursementAPI.Controllers;

[ApiController]
[Route("api/dashboard")]
public class DashboardController : ControllerBase
{
    private readonly IRequestService _requestService;

    public DashboardController(IRequestService requestService)
    {
        _requestService = requestService;
    }

    [HttpGet("employee/{empId}")]
    public async Task<ActionResult<DashboardStatsDto>> GetEmployeeStats(string empId)
    {
        var stats = await _requestService.GetEmployeeDashboardStatsAsync(empId);
        return Ok(stats);
    }

    [HttpGet("finance")]
    public async Task<ActionResult<FinanceDashboardStatsDto>> GetFinanceStats()
    {
        var stats = await _requestService.GetFinanceDashboardStatsAsync();
        return Ok(stats);
    }
}
