using Dapper;
using System.Data;
using ReimbursementAPI.DTOs.MyFiles;
using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Repositories;

public class MyFilesRepository : IMyFilesRepository
{
    private readonly IDbConnectionFactory _factory;

    public MyFilesRepository(IDbConnectionFactory factory)
    {
        _factory = factory;
    }

    public async Task SaveEmployeeFileAsync(string empId, string fileName, string filePath, string fileType)
    {
        using var conn = _factory.CreateConnection();
        await conn.ExecuteAsync("sp_SaveEmployeeFile", new
        {
            EmpId = empId,
            FileName = fileName,
            FilePath = filePath,
            FileType = fileType
        }, commandType: CommandType.StoredProcedure);
    }

    public async Task<IEnumerable<EmployeeFileDto>> GetEmployeeFilesAsync(string empId)
    {
        using var conn = _factory.CreateConnection();
        return await conn.QueryAsync<EmployeeFileDto>("sp_GetEmployeeFilesByEmpId", new { EmpId = empId }, commandType: CommandType.StoredProcedure);
    }

    public async Task DeleteEmployeeFileAsync(Guid id)
    {
        using var conn = _factory.CreateConnection();
        await conn.ExecuteAsync("sp_DeleteEmployeeFile", new { Id = id }, commandType: CommandType.StoredProcedure);
    }
}
