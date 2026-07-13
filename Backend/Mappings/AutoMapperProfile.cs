using System.Text.Json;
using AutoMapper;
using ReimbursementAPI.DTOs.Auth;
using ReimbursementAPI.DTOs.Requests;
using ReimbursementAPI.Models;

namespace ReimbursementAPI.Mappings;

public class AutoMapperProfile : Profile
{
    public AutoMapperProfile()
    {
        // Auth
        CreateMap<Employee, EmployeeDto>();
    }
}
