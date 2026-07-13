using Microsoft.AspNetCore.Mvc;

namespace ReimbursementAPI.Controllers;

[ApiController]
[Route("api/files")]
public class FilesController : ControllerBase
{
    private readonly IWebHostEnvironment _env;
    private readonly IConfiguration _config;

    public FilesController(IWebHostEnvironment env, IConfiguration config)
    {
        _env = env;
        _config = config;
    }

    [HttpPost("upload")]
    public async Task<IActionResult> UploadFile(IFormFile file)
    {
        if (file == null || file.Length == 0)
        {
            return BadRequest(new { message = "No file uploaded." });
        }

        var fileStoragePath = _config["FileStorage:BasePath"] ?? "D:/Reimbursement";
        var uploadsFolder = fileStoragePath;
        
        try
        {
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }
        }
        catch (DirectoryNotFoundException)
        {
            uploadsFolder = Path.Combine(_env.ContentRootPath, "ReimbursementUploads");
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }
        }

        // Generate a unique filename to prevent overwriting
        var fileExtension = Path.GetExtension(file.FileName);
        var uniqueFileName = $"{Guid.NewGuid()}{fileExtension}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        // Return the relative path so the frontend can access it via static files
        return Ok(new { url = $"/user-files/{uniqueFileName}", originalName = file.FileName });
    }
}
