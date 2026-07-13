namespace ReimbursementAPI.DTOs.MyFiles;

public class EmployeeFileDto
{
    public Guid Id { get; set; }
    public string EmpId { get; set; } = string.Empty;
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
    public DateTime UploadedAt { get; set; }
}
