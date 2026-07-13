using ReimbursementAPI.DTOs.MyFiles;

namespace ReimbursementAPI.Interfaces;

public interface IMyFilesRepository
{
    Task SaveEmployeeFileAsync(string empId, string fileName, string filePath, string fileType);
    Task<IEnumerable<EmployeeFileDto>> GetEmployeeFilesAsync(string empId);
    Task DeleteEmployeeFileAsync(Guid id);
}
