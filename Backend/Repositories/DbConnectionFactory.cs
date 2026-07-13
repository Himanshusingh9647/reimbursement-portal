using System.Data;
using Microsoft.Data.SqlClient;

using ReimbursementAPI.Interfaces;

namespace ReimbursementAPI.Repositories;
/// <summary>
/// MSSQL implementation using Microsoft.Data.SqlClient.
/// Reads connection string from appsettings.json → ConnectionStrings:DefaultConnection.
/// </summary>
public class SqlConnectionFactory : IDbConnectionFactory
{
    private readonly string _connectionString;

    public SqlConnectionFactory(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found in configuration.");
    }

    public IDbConnection CreateConnection()
    {
        return new SqlConnection(_connectionString);
    }
}
