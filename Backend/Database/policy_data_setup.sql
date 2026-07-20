-- ============================================================
-- Policy Data — Database Setup
-- Target: Microsoft SQL Server 2014 (Compatibility Level 120)
--
-- Creates a flexible PolicyData table for storing configurable
-- policy information (exchange rates, state mappings, etc.)
-- as JSON blobs, plus stored procedures for CRUD.
-- ============================================================

USE [ReimbursementDB];
GO

-- ------------------------------------------------------------
-- Table: PolicyData
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PolicyData]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PolicyData]
    (
        [Id]         INT IDENTITY(1,1) NOT NULL,
        [Category]   NVARCHAR(100)     NOT NULL,
        [JsonData]   NVARCHAR(MAX)     NOT NULL,
        [UpdatedAt]  DATETIME2(7)      NOT NULL CONSTRAINT [DF_PolicyData_UpdatedAt] DEFAULT (GETUTCDATE()),
        [UpdatedBy]  NVARCHAR(20)      NULL,

        CONSTRAINT [PK_PolicyData] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_PolicyData_Category] UNIQUE ([Category])
    );
    PRINT 'PolicyData table created.';
END
ELSE
BEGIN
    PRINT 'PolicyData table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- SP: sp_GetAllPolicyData
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[sp_GetAllPolicyData]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetAllPolicyData];
GO
CREATE PROCEDURE [dbo].[sp_GetAllPolicyData]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Id], [Category], [JsonData], [UpdatedAt], [UpdatedBy]
    FROM [dbo].[PolicyData]
    ORDER BY [Category];
END;
GO

-- ------------------------------------------------------------
-- SP: sp_GetPolicyDataByCategory
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[sp_GetPolicyDataByCategory]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetPolicyDataByCategory];
GO
CREATE PROCEDURE [dbo].[sp_GetPolicyDataByCategory]
    @Category NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Id], [Category], [JsonData], [UpdatedAt], [UpdatedBy]
    FROM [dbo].[PolicyData]
    WHERE [Category] = @Category;
END;
GO

-- ------------------------------------------------------------
-- SP: sp_UpsertPolicyData
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[sp_UpsertPolicyData]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_UpsertPolicyData];
GO
CREATE PROCEDURE [dbo].[sp_UpsertPolicyData]
    @Category  NVARCHAR(100),
    @JsonData  NVARCHAR(MAX),
    @UpdatedBy NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM [dbo].[PolicyData] WHERE [Category] = @Category)
    BEGIN
        UPDATE [dbo].[PolicyData]
        SET [JsonData]  = @JsonData,
            [UpdatedAt] = GETUTCDATE(),
            [UpdatedBy] = @UpdatedBy
        WHERE [Category] = @Category;
    END
    ELSE
    BEGIN
        INSERT INTO [dbo].[PolicyData] ([Category], [JsonData], [UpdatedBy])
        VALUES (@Category, @JsonData, @UpdatedBy);
    END
END;
GO

-- ============================================================
-- SEED DATA
-- ============================================================

-- Exchange Rates
IF NOT EXISTS (SELECT 1 FROM [dbo].[PolicyData] WHERE [Category] = 'ExchangeRates')
BEGIN
    INSERT INTO [dbo].[PolicyData] ([Category], [JsonData], [UpdatedBy])
    VALUES ('ExchangeRates', N'{
        "Vietnam":     { "currency": "VND", "rate": 0.0034 },
        "Korea":       { "currency": "KRW", "rate": 0.062 },
        "Philippines": { "currency": "PHP", "rate": 1.48 },
        "Japan":       { "currency": "JPY", "rate": 0.55 },
        "USA":         { "currency": "USD", "rate": 83.50 },
        "UK":          { "currency": "GBP", "rate": 105.20 },
        "Singapore":   { "currency": "SGD", "rate": 61.80 },
        "Germany":     { "currency": "EUR", "rate": 91.50 },
        "Australia":   { "currency": "AUD", "rate": 54.30 },
        "Canada":      { "currency": "CAD", "rate": 61.20 }
    }', 'SYSTEM');
    PRINT 'Seeded ExchangeRates.';
END
GO

-- Domestic States to Area mapping
IF NOT EXISTS (SELECT 1 FROM [dbo].[PolicyData] WHERE [Category] = 'DomesticStates')
BEGIN
    INSERT INTO [dbo].[PolicyData] ([Category], [JsonData], [UpdatedBy])
    VALUES ('DomesticStates', N'{
        "Maharashtra": "Area A",
        "Delhi": "Area A",
        "Karnataka": "Area A",
        "Tamil Nadu": "Area A",
        "Telangana": "Area B",
        "Gujarat": "Area B",
        "West Bengal": "Area B",
        "Other": "Area C"
    }', 'SYSTEM');
    PRINT 'Seeded DomesticStates.';
END
GO

-- International Countries list
IF NOT EXISTS (SELECT 1 FROM [dbo].[PolicyData] WHERE [Category] = 'InternationalCountries')
BEGIN
    INSERT INTO [dbo].[PolicyData] ([Category], [JsonData], [UpdatedBy])
    VALUES ('InternationalCountries', N'["Vietnam", "Korea", "Philippines", "Japan", "USA", "UK", "Singapore", "Germany", "Australia", "Canada", "Other"]', 'SYSTEM');
    PRINT 'Seeded InternationalCountries.';
END
GO

PRINT '';
PRINT '=== PolicyData setup complete. ===';
GO
