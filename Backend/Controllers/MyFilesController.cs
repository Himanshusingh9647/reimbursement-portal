using Microsoft.AspNetCore.Mvc;
using ReimbursementAPI.DTOs.MyFiles;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Controllers;

[ApiController]
[Route("api/my-files")]
public class MyFilesController : ControllerBase
{
    private readonly IMyFilesService _myFilesService;

    public MyFilesController(IMyFilesService myFilesService)
    {
        _myFilesService = myFilesService;
    }

    [HttpGet("{empId}")]
    public async Task<ActionResult<IEnumerable<EmployeeFileDto>>> GetFiles(string empId)
    {
        var files = await _myFilesService.GetEmployeeFilesAsync(empId);
        return Ok(files);
    }

    [HttpPost("upload")]
    public async Task<ActionResult<EmployeeFileDto>> UploadFile([FromForm] string empId, [FromForm] string fileType, IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { message = "No file uploaded." });
        }

        var savedFile = await _myFilesService.UploadFileAsync(empId, fileType, file);
        return Ok(savedFile);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteFile(Guid id)
    {
        await _myFilesService.DeleteFileAsync(id);
        return NoContent();
    }
}
