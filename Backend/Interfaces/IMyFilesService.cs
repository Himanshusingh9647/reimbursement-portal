using ReimbursementAPI.DTOs.MyFiles;

namespace ReimbursementAPI.Interfaces;

public interface IMyFilesService
{
    Task<EmployeeFileDto> UploadFileAsync(string empId, string fileType, IFormFile file);
    Task<IEnumerable<EmployeeFileDto>> GetEmployeeFilesAsync(string empId);
    Task DeleteFileAsync(Guid id);
}
