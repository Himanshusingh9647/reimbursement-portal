using ReimbursementAPI.Repositories;
using ReimbursementAPI.Services;
using ReimbursementAPI.Interfaces;
using ReimbursementAPI.DTOs.Auth;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

// ── Framework Services ──────────────────────────────────────────
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// ── CORS ────────────────────────────────────────────────────────
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// ── AutoMapper ──────────────────────────────────────────────────
builder.Services.AddAutoMapper(typeof(Program));

// ── Dapper Configuration ────────────────────────────────────────
Dapper.DefaultTypeMap.MatchNamesWithUnderscores = true;

// ── Knox SSO Configuration ──────────────────────────────────────
builder.Services.Configure<KnoxSsoSettings>(
    builder.Configuration.GetSection(KnoxSsoSettings.SectionName));

// ── Database ────────────────────────────────────────────────────
Console.WriteLine("=== USING REAL MSSQL REPOSITORIES ===");
builder.Services.AddSingleton<IDbConnectionFactory, SqlConnectionFactory>();

// ── Repositories ────────────────────────────────────────────────
builder.Services.AddScoped<IEmployeeRepository, EmployeeRepository>();
builder.Services.AddScoped<IRequestRepository, RequestRepository>();
builder.Services.AddScoped<IMyFilesRepository, MyFilesRepository>();
builder.Services.AddScoped<IPolicyRepository, PolicyRepository>();

// ── Services ────────────────────────────────────────────────────
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IRequestService, RequestService>();
builder.Services.AddScoped<IMyFilesService, MyFilesService>();
builder.Services.AddScoped<IPolicyService, PolicyService>();
builder.Services.AddScoped<IKnoxSsoService, KnoxSsoService>();

var app = builder.Build();

// ── HTTP Pipeline ───────────────────────────────────────────────
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

// Serve standard wwwroot files
app.UseStaticFiles();

// Serve files from configured storage path (e.g., D:/Reimbursement)
var fileStoragePath = builder.Configuration["FileStorage:BasePath"] ?? "D:/Reimbursement";
try
{
    if (!Directory.Exists(fileStoragePath))
        Directory.CreateDirectory(fileStoragePath);
}
catch (DirectoryNotFoundException)
{
    fileStoragePath = Path.Combine(builder.Environment.ContentRootPath, "ReimbursementUploads");
    if (!Directory.Exists(fileStoragePath))
        Directory.CreateDirectory(fileStoragePath);
    Console.WriteLine($"WARNING: Configured path not found. Falling back to {fileStoragePath}");
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(fileStoragePath),
    RequestPath = "/user-files",
    OnPrepareResponse = ctx =>
    {
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Headers", "*");
    }
});

app.UseAuthorization();
app.MapControllers();

app.Run();
