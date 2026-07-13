using ReimbursementAPI.DTOs.Auth;
using ReimbursementAPI.Repositories;
using AutoMapper;

using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Services;
public class AuthService : IAuthService
{
    private readonly IEmployeeRepository _employeeRepo;
    private readonly IMapper _mapper;

    public AuthService(IEmployeeRepository employeeRepo, IMapper mapper)
    {
        _employeeRepo = employeeRepo;
        _mapper = mapper;
    }

    public async Task<EmployeeDto?> AuthenticateAsync(string username, string password, string? loginAs)
    {
        var emp = await _employeeRepo.GetEmployeeByUsernameAsync(username, password);
        if (emp == null) return null;

        var dto = _mapper.Map<EmployeeDto>(emp);


        return dto;
    }

    public async Task<EmployeeDto?> GetEmployeeByIdAsync(string id)
    {
        var emp = await _employeeRepo.GetEmployeeByIdAsync(id);
        if (emp == null) return null;
        return _mapper.Map<EmployeeDto>(emp);
    }
}
