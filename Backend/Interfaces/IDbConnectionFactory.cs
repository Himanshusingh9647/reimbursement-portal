using System.Data;

namespace ReimbursementAPI.Interfaces;

/// <summary>
/// Factory for creating database connections. Abstracts the connection
/// creation so repositories don't depend on a specific ADO.NET provider.
/// </summary>
public interface IDbConnectionFactory
{
    IDbConnection CreateConnection();
}
