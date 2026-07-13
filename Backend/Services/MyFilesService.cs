using ReimbursementAPI.DTOs.MyFiles;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Services;

public class MyFilesService : IMyFilesService
{
    private readonly IMyFilesRepository _repo;
    private readonly IConfiguration _config;

    public MyFilesService(IMyFilesRepository repo, IConfiguration config)
    {
        _repo = repo;
        _config = config;
    }

    public async Task<EmployeeFileDto> UploadFileAsync(string empId, string fileType, IFormFile file)
    {
        var basePath = _config["FileStorage:BasePath"] ?? "D:/Reimbursement";
        var empFolder = Path.Combine(basePath, empId);

        try
        {
            if (!Directory.Exists(empFolder))
            {
                Directory.CreateDirectory(empFolder);
            }
        }
        catch (DirectoryNotFoundException)
        {
            basePath = Path.Combine(Directory.GetCurrentDirectory(), "ReimbursementUploads");
            empFolder = Path.Combine(basePath, empId);
            if (!Directory.Exists(empFolder))
            {
                Directory.CreateDirectory(empFolder);
            }
        }

        var extension = Path.GetExtension(file.FileName);
        var uniqueFileName = $"{Guid.NewGuid()}{extension}";
        var physicalPath = Path.Combine(empFolder, uniqueFileName);

        using (var stream = new FileStream(physicalPath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        // Relative path for the frontend (mapped via PhysicalFileProvider)
        var relativeUrl = $"/user-files/{empId}/{uniqueFileName}";

        await _repo.SaveEmployeeFileAsync(empId, file.FileName, relativeUrl, fileType);

        return new EmployeeFileDto
        {
            EmpId = empId,
            FileName = file.FileName,
            FilePath = relativeUrl,
            FileType = fileType,
            UploadedAt = DateTime.UtcNow
        };
    }

    public async Task<IEnumerable<EmployeeFileDto>> GetEmployeeFilesAsync(string empId)
    {
        return await _repo.GetEmployeeFilesAsync(empId);
    }

    public async Task DeleteFileAsync(Guid id)
    {
        await _repo.DeleteEmployeeFileAsync(id);
    }
}
