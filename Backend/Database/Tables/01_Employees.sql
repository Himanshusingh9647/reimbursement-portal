-- ============================================================
-- Table: Employees
-- Stores all portal users (employees, finance, admin)
-- Run order: 1 (no dependencies)
-- ============================================================

IF OBJECT_ID(N'[dbo].[Employees]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Employees]
    (
        [Id]            NVARCHAR(20)    NOT NULL,
        [Name]          NVARCHAR(100)   NOT NULL,
        [ClLevel]       NVARCHAR(10)    NOT NULL,           -- CL1 / CL2 / CL3 / CL4
        [Department]    NVARCHAR(50)    NOT NULL,
        [Designation]   NVARCHAR(100)   NULL,
        [Email]         NVARCHAR(100)   NOT NULL,
        [Manager]       NVARCHAR(100)   NULL,
        [Username]      NVARCHAR(50)    NOT NULL,
        [PasswordHash]  NVARCHAR(255)   NOT NULL,
        [HasFinanceAccess] BIT          NOT NULL    CONSTRAINT [DF_Employees_Finance] DEFAULT (0),
        [HasAdminAccess] BIT            NOT NULL    CONSTRAINT [DF_Employees_Admin] DEFAULT (0),
        [Team]          NVARCHAR(50)    NULL,
        [Project]       NVARCHAR(100)   NULL,
        [CreatedAt]     DATETIME2       NOT NULL    CONSTRAINT [DF_Employees_CreatedAt] DEFAULT (GETUTCDATE()),

        CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_Employees_Email] UNIQUE ([Email]),
        CONSTRAINT [UQ_Employees_Username] UNIQUE ([Username])
    );
END;
GO

PRINT '01 — Employees table ready.';
GO
