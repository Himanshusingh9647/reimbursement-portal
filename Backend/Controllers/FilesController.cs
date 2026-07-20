using Microsoft.AspNetCore.Mvc;

namespace ReimbursementAPI.Controllers;

/// <summary>
/// Handles file upload and download operations for reimbursement documents.
/// </summary>
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

    /// <summary>
    /// Uploads a file to the configured storage path.
    /// Returns the relative URL and original filename.
    /// </summary>
    [HttpPost("upload")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> UploadFile(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "No file uploaded." });

        var uploadsFolder = ResolveStoragePath();

        var fileExtension = Path.GetExtension(file.FileName);
        var uniqueFileName = $"{Guid.NewGuid()}{fileExtension}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        return Ok(new { url = $"/user-files/{uniqueFileName}", originalName = file.FileName });
    }

    /// <summary>
    /// Downloads a file from the storage path as an attachment.
    /// The path parameter should be the relative path returned from upload (e.g., "/user-files/abc.pdf").
    /// </summary>
    [HttpGet("download")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public IActionResult DownloadFile([FromQuery] string path, [FromQuery] string? fileName = null)
    {
        if (string.IsNullOrWhiteSpace(path))
            return BadRequest(new { message = "File path is required." });

        // Strip the "/user-files/" prefix to get the relative path within storage
        var relativePath = path
            .Replace("/user-files/", "", StringComparison.OrdinalIgnoreCase)
            .Replace("\\", "/");

        // Security: prevent directory traversal
        if (relativePath.Contains("..") || Path.IsPathRooted(relativePath))
            return BadRequest(new { message = "Invalid file path." });

        var basePath = ResolveStoragePath();
        var fullPath = Path.Combine(basePath, relativePath.Replace("/", Path.DirectorySeparatorChar.ToString()));

        if (!System.IO.File.Exists(fullPath))
            return NotFound(new { message = "File not found." });

        var contentType = GetContentType(fullPath);
        var downloadName = fileName ?? Path.GetFileName(fullPath);

        return PhysicalFile(fullPath, contentType, downloadName);
    }

    /// <summary>
    /// Resolves the file storage base path, falling back to a local directory
    /// if the configured path doesn't exist (e.g., D:/ drive not available).
    /// </summary>
    private string ResolveStoragePath()
    {
        var fileStoragePath = _config["FileStorage:BasePath"] ?? "D:/Reimbursement";

        try
        {
            if (!Directory.Exists(fileStoragePath))
                Directory.CreateDirectory(fileStoragePath);
            return fileStoragePath;
        }
        catch (DirectoryNotFoundException)
        {
            var fallback = Path.Combine(_env.ContentRootPath, "ReimbursementUploads");
            if (!Directory.Exists(fallback))
                Directory.CreateDirectory(fallback);
            return fallback;
        }
    }

    /// <summary>
    /// Returns the MIME content type based on file extension.
    /// </summary>
    private static string GetContentType(string filePath)
    {
        var extension = Path.GetExtension(filePath).ToLowerInvariant();
        return extension switch
        {
            ".pdf" => "application/pdf",
            ".jpg" or ".jpeg" => "image/jpeg",
            ".png" => "image/png",
            ".gif" => "image/gif",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            ".xls" => "application/vnd.ms-excel",
            ".xlsx" => "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            ".zip" => "application/zip",
            _ => "application/octet-stream"
        };
    }
}
