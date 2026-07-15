-- ============================================================
-- Reimbursement Portal — Complete Database Setup
-- Target: Microsoft SQL Server 2014 (Compatibility Level 120)
-- 
-- This is a single, self-contained script. Run it in SSMS
-- on your SQL Server 2014 instance.
--
-- Contents:
--   1. Database creation
--   2. All 14 tables (with IF NOT EXISTS guards)
--   3. All stored procedures (21 total, SQL 2014 compatible)
--   4. Seed data
-- ============================================================

-- ============================================================
-- 0. CREATE DATABASE
-- ============================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'reimbursment_portal_dev')
BEGIN
    CREATE DATABASE [reimbursment_portal_dev];
END
GO

USE [reimbursment_portal_dev];
GO

-- ============================================================
-- 1. TABLES (in dependency order)
-- ============================================================

-- ------------------------------------------------------------
-- 01. Employees (no deps)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Employees]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Employees]
    (
        [Id]               NVARCHAR(20)   NOT NULL,
        [Name]             NVARCHAR(100)  NOT NULL,
        [ClLevel]          NVARCHAR(10)   NOT NULL,
        [Department]       NVARCHAR(50)   NOT NULL,
        [Designation]      NVARCHAR(100)  NULL,
        [Email]            NVARCHAR(100)  NOT NULL,
        [Manager]          NVARCHAR(100)  NULL,
        [Username]         NVARCHAR(50)   NOT NULL,
        [PasswordHash]     NVARCHAR(255)  NOT NULL,
        [Role]             NVARCHAR(20)   NOT NULL CONSTRAINT [DF_Employees_Role] DEFAULT ('employee'),
        [Team]             NVARCHAR(50)   NULL,
        [Project]          NVARCHAR(100)  NULL,
        [CreatedAt]        DATETIME2(7)   NOT NULL CONSTRAINT [DF_Employees_CreatedAt] DEFAULT (GETUTCDATE()),
        [HasFinanceAccess] BIT            NULL CONSTRAINT [DF_Employees_Finance] DEFAULT (0),
        [HasAdminAccess]   BIT            NULL CONSTRAINT [DF_Employees_Admin] DEFAULT (0),

        CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_Employees_Email] UNIQUE ([Email]),
        CONSTRAINT [UQ_Employees_Username] UNIQUE ([Username])
    );
    PRINT '01 - Employees table created.';
END
ELSE
BEGIN
    PRINT '01 - Employees table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 02. Requests (depends on: Employees)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Requests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Requests]
    (
        [Id]          NVARCHAR(20)   NOT NULL,
        [EmpId]       NVARCHAR(20)   NOT NULL,
        [Type]        NVARCHAR(30)   NOT NULL,
        [Title]       NVARCHAR(200)  NOT NULL,
        [Status]      NVARCHAR(20)   NOT NULL CONSTRAINT [DF_Requests_Status] DEFAULT ('pending'),
        [FinanceNote] NVARCHAR(500)  NULL,
        [SubmittedAt] DATETIME2(7)   NOT NULL CONSTRAINT [DF_Requests_SubmittedAt] DEFAULT (GETUTCDATE()),
        [UpdatedAt]   DATETIME2(7)   NULL,

        CONSTRAINT [PK_Requests] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_Requests_Employees] FOREIGN KEY ([EmpId]) REFERENCES [dbo].[Employees]([Id])
    );
    PRINT '02 - Requests table created.';
END
ELSE
BEGIN
    PRINT '02 - Requests table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 03. TripRequests (depends on: Requests)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TripRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TripRequests]
    (
        [Id]                 INT IDENTITY(1,1) NOT NULL,
        [RequestId]          NVARCHAR(20)  NOT NULL,
        [Subtype]            NVARCHAR(20)  NOT NULL,
        [Destination]        NVARCHAR(100) NULL,
        [State]              NVARCHAR(100) NULL,
        [Region]             NVARCHAR(100) NULL,
        [Country]            NVARCHAR(100) NULL,
        [StartDate]          DATE          NOT NULL,
        [EndDate]            DATE          NOT NULL,
        [Days]               INT           NOT NULL,
        [Purpose]            NVARCHAR(1000) NULL,
        [TravelMode]         NVARCHAR(50)  NULL,
        [Stage]              NVARCHAR(30)  NOT NULL DEFAULT ('pre-approval'),
        [LatestExtensionId]  INT           NULL,

        CONSTRAINT [PK_TripRequests] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_TripRequests_RequestId] UNIQUE ([RequestId]),
        CONSTRAINT [FK_TripRequests_Requests] FOREIGN KEY ([RequestId]) REFERENCES [dbo].[Requests]([Id])
    );
    PRINT '03 - TripRequests table created.';
END
ELSE
BEGIN
    PRINT '03 - TripRequests table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 04. PreApprovals (depends on: TripRequests, Employees)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[PreApprovals]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PreApprovals]
    (
        [Id]                    INT IDENTITY(1,1) NOT NULL,
        [TripRequestId]         INT           NOT NULL,
        [Status]                NVARCHAR(20)  NOT NULL CONSTRAINT [DF_PreApprovals_Status] DEFAULT ('pending'),
        [HasKnoxApproval]       BIT           NOT NULL CONSTRAINT [DF_PreApprovals_HasKnox] DEFAULT (0),
        [KnoxApproval]          NVARCHAR(200) NULL,
        [HasTravelInsurance]    BIT           NOT NULL CONSTRAINT [DF_PreApprovals_HasInsurance] DEFAULT (0),
        [TravelInsurance]       NVARCHAR(200) NULL,
        [HasPassportCopy]       BIT           NOT NULL CONSTRAINT [DF_PreApprovals_HasPassport] DEFAULT (0),
        [PassportCopy]          NVARCHAR(200) NULL,
        [HasVisa]               BIT           NOT NULL CONSTRAINT [DF_PreApprovals_HasVisa] DEFAULT (0),
        [Visa]                  NVARCHAR(200) NULL,
        [HasFlightTicket]       BIT           NOT NULL CONSTRAINT [DF_PreApprovals_HasFlight] DEFAULT (0),
        [FlightTicket]          NVARCHAR(200) NULL,
        [DocumentReviewStatus]  NVARCHAR(20)  NULL,
        [ApprovedAt]            DATETIME2(7)  NULL,
        [ReviewedBy]            NVARCHAR(20)  NULL,

        CONSTRAINT [PK_PreApprovals] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_PreApprovals_TripRequestId] UNIQUE ([TripRequestId]),
        CONSTRAINT [FK_PreApprovals_TripRequests] FOREIGN KEY ([TripRequestId]) REFERENCES [dbo].[TripRequests]([Id]),
        CONSTRAINT [FK_PreApprovals_Employees_ReviewedBy] FOREIGN KEY ([ReviewedBy]) REFERENCES [dbo].[Employees]([Id])
    );
    PRINT '04 - PreApprovals table created.';
END
ELSE
BEGIN
    PRINT '04 - PreApprovals table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 05. TripExtensions (depends on: TripRequests, self-ref)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[TripExtensions]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TripExtensions]
    (
        [Id]                  INT IDENTITY(1,1) NOT NULL,
        [TripRequestId]       INT           NOT NULL,
        [PreviousExtensionId] INT           NULL,
        [RevisedEndDate]      DATE          NOT NULL,
        [RevisedDays]         INT           NOT NULL,
        [Reason]              NVARCHAR(500) NULL,
        [HasApprovalDocument] BIT           NOT NULL DEFAULT (0),
        [ApprovalDocument]    NVARCHAR(200) NULL,
        [Status]              NVARCHAR(20)  NOT NULL DEFAULT ('pending'),
        [RequestedAt]         DATETIME2(7)  NOT NULL DEFAULT (GETUTCDATE()),
        [ReviewedAt]          DATETIME2(7)  NULL,

        CONSTRAINT [PK_TripExtensions] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_TripExtensions_TripRequests] FOREIGN KEY ([TripRequestId]) REFERENCES [dbo].[TripRequests]([Id])
    );
    PRINT '05 - TripExtensions table created.';
END
ELSE
BEGIN
    PRINT '05 - TripExtensions table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 06. Settlements (depends on: TripRequests)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[Settlements]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Settlements]
    (
        [Id]                INT IDENTITY(1,1) NOT NULL,
        [TripRequestId]     INT            NOT NULL,
        [Status]            NVARCHAR(20)   NOT NULL DEFAULT (N'draft'),
        [HotelName]         NVARCHAR(200)  NULL,
        [HotelAmount]       DECIMAL(18,2)  NULL,
        [HasHotelBill]      BIT            NOT NULL CONSTRAINT [DF_Settlements_HasHotel] DEFAULT (0),
        [HotelBill]         NVARCHAR(200)  NULL,
        [PerDiemDays]       INT            NULL,
        [PerDiemRate]       DECIMAL(18,2)  NULL,
        [PerDiemAmount]     DECIMAL(18,2)  NULL,
        [Currency]          NVARCHAR(10)   NOT NULL DEFAULT (N'₹'),
        [ExchangeRate]      DECIMAL(18,6)  NOT NULL DEFAULT (1.0),
        [TotalAmountForeign] DECIMAL(18,2) NULL,
        [TotalAmountINR]    DECIMAL(18,2)  NULL,
        [HasBoardingPass]   BIT            NOT NULL CONSTRAINT [DF_Settlements_HasBoarding] DEFAULT (0),
        [BoardingPass]      NVARCHAR(200)  NULL,
        [HasPassportStamps] BIT            NOT NULL CONSTRAINT [DF_Settlements_HasStamps] DEFAULT (0),
        [PassportStamps]    NVARCHAR(200)  NULL,
        [HasTripReport]     BIT            NOT NULL CONSTRAINT [DF_Settlements_HasReport] DEFAULT (0),
        [TripReport]        NVARCHAR(200)  NULL,
        [HasForexStatement] BIT            NOT NULL CONSTRAINT [DF_Settlements_HasForex] DEFAULT (0),
        [ForexStatement]    NVARCHAR(200)  NULL,
        [WinterClothes]     BIT            NOT NULL DEFAULT (0),
        [WinterClothesAmount] DECIMAL(18,2) NULL,
        [SubmittedAt]       DATETIME2(7)   NULL,
        [ReviewedAt]        DATETIME2(7)   NULL,

        CONSTRAINT [PK_Settlements] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_Settlements_TripRequestId] UNIQUE ([TripRequestId]),
        CONSTRAINT [FK_Settlements_TripRequests] FOREIGN KEY ([TripRequestId]) REFERENCES [dbo].[TripRequests]([Id])
    );
    PRINT '06 - Settlements table created.';
END
ELSE
BEGIN
    PRINT '06 - Settlements table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 07. LocalConveyances (depends on: Settlements)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[LocalConveyances]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[LocalConveyances]
    (
        [Id]              INT IDENTITY(1,1) NOT NULL,
        [SettlementId]    INT            NOT NULL,
        [ConveyanceType]  NVARCHAR(20)   NOT NULL,
        [Route]           NVARCHAR(200)  NULL,
        [Amount]          DECIMAL(18,2)  NOT NULL,
        [Distance]        DECIMAL(10,2)  NULL,
        [HasBillDocument] BIT            NOT NULL CONSTRAINT [DF_LocalConveyances_HasBill] DEFAULT (0),
        [BillDocument]    NVARCHAR(200)  NULL,

        CONSTRAINT [PK_LocalConveyances] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_LocalConveyances_Settlements] FOREIGN KEY ([SettlementId]) REFERENCES [dbo].[Settlements]([Id])
    );
    PRINT '07 - LocalConveyances table created.';
END
ELSE
BEGIN
    PRINT '07 - LocalConveyances table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 08. InternetBillRequests (depends on: Requests)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[InternetBillRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[InternetBillRequests]
    (
        [Id]                 INT IDENTITY(1,1) NOT NULL,
        [RequestId]          NVARCHAR(20)  NOT NULL,
        [Provider]           NVARCHAR(100) NOT NULL,
        [Frequency]          NVARCHAR(20)  NOT NULL,
        [TotalAmount]        DECIMAL(18,2) NULL,
        [ClaimableAmount]    DECIMAL(18,2) NULL,
        [ReimbursedTillMonth] NVARCHAR(20) NULL,

        CONSTRAINT [PK_InternetBillRequests] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_InternetBillRequests_RequestId] UNIQUE ([RequestId]),
        CONSTRAINT [FK_InternetBillRequests_Requests] FOREIGN KEY ([RequestId]) REFERENCES [dbo].[Requests]([Id])
    );
    PRINT '08 - InternetBillRequests table created.';
END
ELSE
BEGIN
    PRINT '08 - InternetBillRequests table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 09. InternetBillPeriods (depends on: InternetBillRequests)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[InternetBillPeriods]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[InternetBillPeriods]
    (
        [Id]                    INT IDENTITY(1,1) NOT NULL,
        [InternetBillRequestId] INT           NOT NULL,
        [PeriodLabel]           NVARCHAR(50)  NOT NULL,
        [Amount]                DECIMAL(18,2) NOT NULL,
        [HasBillDocument]       BIT           NOT NULL CONSTRAINT [DF_InternetBillPeriods_HasBill] DEFAULT (0),
        [BillDocument]          NVARCHAR(200) NULL,

        CONSTRAINT [PK_InternetBillPeriods] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_InternetBillPeriods_InternetBillRequests] FOREIGN KEY ([InternetBillRequestId]) REFERENCES [dbo].[InternetBillRequests]([Id])
    );
    PRINT '09 - InternetBillPeriods table created.';
END
ELSE
BEGIN
    PRINT '09 - InternetBillPeriods table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 10. CarpoolGroups (depends on: Requests, Employees)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[CarpoolGroups]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CarpoolGroups]
    (
        [Id]                  INT IDENTITY(1,1) NOT NULL,
        [RequestId]           NVARCHAR(20)  NOT NULL,
        [VehicleOwnerEmpId]   NVARCHAR(20)  NOT NULL,
        [VehicleNumber]       NVARCHAR(20)  NULL,
        [TotalMembers]        INT           NOT NULL,
        [MetroCheckPassed]    BIT           NOT NULL CONSTRAINT [DF_CarpoolGroups_MetroCheckPassed] DEFAULT (0),
        [IsActive]            BIT           NOT NULL CONSTRAINT [DF_CarpoolGroups_IsActive] DEFAULT (1),
        [MonthlyAmount]       DECIMAL(18,2) NULL,
        [ValidFrom]           DATE          NULL,
        [ValidTill]           DATE          NULL,
        [AMSVerified]         BIT           NOT NULL CONSTRAINT [DF_CarpoolGroups_AMSVerified] DEFAULT (0),
        [AMSDaysPresent]      INT           NULL,
        [TapInWindowMinutes]  INT           NOT NULL CONSTRAINT [DF_CarpoolGroups_TapInWindowMinutes] DEFAULT (5),
        [TapOutWindowMinutes] INT           NOT NULL CONSTRAINT [DF_CarpoolGroups_TapOutWindowMinutes] DEFAULT (5),

        CONSTRAINT [PK_CarpoolGroups] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_CarpoolGroups_RequestId] UNIQUE ([RequestId]),
        CONSTRAINT [FK_CarpoolGroups_Requests] FOREIGN KEY ([RequestId]) REFERENCES [dbo].[Requests]([Id]),
        CONSTRAINT [FK_CarpoolGroups_Employees_Owner] FOREIGN KEY ([VehicleOwnerEmpId]) REFERENCES [dbo].[Employees]([Id])
    );
    PRINT '10 - CarpoolGroups table created.';
END
ELSE
BEGIN
    PRINT '10 - CarpoolGroups table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 11. CarpoolMembers (depends on: CarpoolGroups, Employees)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[CarpoolMembers]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CarpoolMembers]
    (
        [Id]                  INT IDENTITY(1,1) NOT NULL,
        [CarpoolGroupId]      INT           NOT NULL,
        [EmpId]               NVARCHAR(20)  NOT NULL,
        [EmployeeType]        NVARCHAR(20)  NOT NULL,
        [PickupAddress]       NVARCHAR(500) NOT NULL,
        [Latitude]            DECIMAL(10,7) NULL,
        [Longitude]           DECIMAL(10,7) NULL,
        [NearestMetroStation] NVARCHAR(200) NULL,
        [MetroDistanceKm]     DECIMAL(5,2)  NULL,

        CONSTRAINT [PK_CarpoolMembers] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_CarpoolMembers_Group_Emp] UNIQUE ([CarpoolGroupId], [EmpId]),
        CONSTRAINT [FK_CarpoolMembers_CarpoolGroups] FOREIGN KEY ([CarpoolGroupId]) REFERENCES [dbo].[CarpoolGroups]([Id]),
        CONSTRAINT [FK_CarpoolMembers_Employees] FOREIGN KEY ([EmpId]) REFERENCES [dbo].[Employees]([Id])
    );
    PRINT '11 - CarpoolMembers table created.';
END
ELSE
BEGIN
    PRINT '11 - CarpoolMembers table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 12. RelocationRequests (depends on: Requests)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[RelocationRequests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RelocationRequests]
    (
        [Id]          INT IDENTITY(1,1) NOT NULL,
        [RequestId]   NVARCHAR(20)  NOT NULL,
        [FromCity]    NVARCHAR(100) NOT NULL,
        [ToCity]      NVARCHAR(100) NOT NULL,
        [RelocDate]   DATE          NOT NULL,
        [TeamName]    NVARCHAR(100) NULL,
        [TotalAmount] DECIMAL(18,2) NULL,

        CONSTRAINT [PK_RelocationRequests] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_RelocationRequests_RequestId] UNIQUE ([RequestId]),
        CONSTRAINT [FK_RelocationRequests_Requests] FOREIGN KEY ([RequestId]) REFERENCES [dbo].[Requests]([Id])
    );
    PRINT '12 - RelocationRequests table created.';
END
ELSE
BEGIN
    PRINT '12 - RelocationRequests table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 13. RelocationExpenses (depends on: RelocationRequests)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[RelocationExpenses]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RelocationExpenses]
    (
        [Id]                   INT IDENTITY(1,1) NOT NULL,
        [RelocationRequestId]  INT           NOT NULL,
        [Category]             NVARCHAR(50)  NOT NULL,
        [Description]          NVARCHAR(500) NULL,
        [Amount]               DECIMAL(18,2) NOT NULL,
        [HasBillDocument]      BIT           NOT NULL CONSTRAINT [DF_RelocationExpenses_HasBill] DEFAULT (0),
        [BillDocument]         NVARCHAR(200) NULL,

        CONSTRAINT [PK_RelocationExpenses] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_RelocationExpenses_RelocationRequests] FOREIGN KEY ([RelocationRequestId]) REFERENCES [dbo].[RelocationRequests]([Id])
    );
    PRINT '13 - RelocationExpenses table created.';
END
ELSE
BEGIN
    PRINT '13 - RelocationExpenses table already exists - skipped.';
END
GO

-- ------------------------------------------------------------
-- 14. EmployeeFiles (no FK to other tables)
-- ------------------------------------------------------------
IF OBJECT_ID(N'[dbo].[EmployeeFiles]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[EmployeeFiles]
    (
        [Id]         UNIQUEIDENTIFIER NOT NULL DEFAULT (NEWID()),
        [EmpId]      VARCHAR(50)  NOT NULL,
        [FileName]   VARCHAR(255) NOT NULL,
        [FilePath]   VARCHAR(500) NOT NULL,
        [FileType]   VARCHAR(50)  NOT NULL,
        [UploadedAt] DATETIME     NULL DEFAULT (GETUTCDATE()),

        CONSTRAINT [PK_EmployeeFiles] PRIMARY KEY CLUSTERED ([Id])
    );
    PRINT '14 - EmployeeFiles table created.';
END
ELSE
BEGIN
    PRINT '14 - EmployeeFiles table already exists - skipped.';
END
GO

PRINT '';
PRINT '=== All 14 tables ready. ===';
PRINT '';
GO


-- ============================================================
-- 2. STORED PROCEDURES
-- ============================================================
-- NOTE: Using IF EXISTS + DROP + CREATE pattern because
-- SQL Server 2014 does not support CREATE OR ALTER.
-- ============================================================


-- ============================================================
-- AUTH PROCEDURES
-- ============================================================

IF OBJECT_ID(N'[dbo].[sp_GetEmployeeByUsername]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmployeeByUsername];
GO
CREATE PROCEDURE [dbo].[sp_GetEmployeeByUsername]
    @Username       NVARCHAR(50),
    @PasswordHash   NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Id], [Name], [ClLevel], [Department], [Designation], [Email], [Manager],
           [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess],
           [Team], [Project], [CreatedAt]
    FROM [dbo].[Employees]
    WHERE [Username] = @Username AND [PasswordHash] = @PasswordHash;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_GetEmployeeById]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmployeeById];
GO
CREATE PROCEDURE [dbo].[sp_GetEmployeeById]
    @Id     NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Id], [Name], [ClLevel], [Department], [Designation], [Email], [Manager],
           [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess],
           [Team], [Project], [CreatedAt]
    FROM [dbo].[Employees]
    WHERE [Id] = @Id;
END;
GO


-- ============================================================
-- REQUEST QUERY PROCEDURES
-- ============================================================

IF OBJECT_ID(N'[dbo].[sp_GetAllRequests]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetAllRequests];
GO
CREATE PROCEDURE [dbo].[sp_GetAllRequests]
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.*, e.[Name] AS EmployeeName, e.[ClLevel] AS ClLevel
    INTO #AllReqs
    FROM [dbo].[Requests] r
    LEFT JOIN [dbo].[Employees] e ON r.EmpId = e.Id;

    SELECT * FROM #AllReqs ORDER BY [SubmittedAt] DESC;
    SELECT tr.* FROM [dbo].[TripRequests] tr INNER JOIN #AllReqs r ON tr.RequestId = r.Id;
    SELECT pa.* FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id INNER JOIN #AllReqs r ON tr.RequestId = r.Id;
    SELECT s.* FROM [dbo].[Settlements] s INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #AllReqs r ON tr.RequestId = r.Id;
    SELECT te.* FROM [dbo].[TripExtensions] te INNER JOIN [dbo].[TripRequests] tr ON te.TripRequestId = tr.Id INNER JOIN #AllReqs r ON tr.RequestId = r.Id;
    SELECT lc.* FROM [dbo].[LocalConveyances] lc INNER JOIN [dbo].[Settlements] s ON lc.SettlementId = s.Id INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #AllReqs r ON tr.RequestId = r.Id;
    SELECT ib.* FROM [dbo].[InternetBillRequests] ib INNER JOIN #AllReqs r ON ib.RequestId = r.Id;
    SELECT ibp.* FROM [dbo].[InternetBillPeriods] ibp INNER JOIN [dbo].[InternetBillRequests] ib ON ibp.InternetBillRequestId = ib.Id INNER JOIN #AllReqs r ON ib.RequestId = r.Id;
    SELECT cg.* FROM [dbo].[CarpoolGroups] cg INNER JOIN #AllReqs r ON cg.RequestId = r.Id;
    SELECT cm.* FROM [dbo].[CarpoolMembers] cm INNER JOIN [dbo].[CarpoolGroups] cg ON cm.CarpoolGroupId = cg.Id INNER JOIN #AllReqs r ON cg.RequestId = r.Id;
    SELECT rr.* FROM [dbo].[RelocationRequests] rr INNER JOIN #AllReqs r ON rr.RequestId = r.Id;
    SELECT re.* FROM [dbo].[RelocationExpenses] re INNER JOIN [dbo].[RelocationRequests] rr ON re.RelocationRequestId = rr.Id INNER JOIN #AllReqs r ON rr.RequestId = r.Id;
    DROP TABLE #AllReqs;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_GetRequestsByEmpId]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetRequestsByEmpId];
GO
CREATE PROCEDURE [dbo].[sp_GetRequestsByEmpId]
    @EmpId  NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.*, e.[Name] AS EmployeeName, e.[ClLevel] AS ClLevel
    INTO #EmpReqs
    FROM [dbo].[Requests] r
    LEFT JOIN [dbo].[Employees] e ON r.EmpId = e.Id
    WHERE r.[EmpId] = @EmpId;

    SELECT * FROM #EmpReqs ORDER BY [SubmittedAt] DESC;
    SELECT tr.* FROM [dbo].[TripRequests] tr INNER JOIN #EmpReqs r ON tr.RequestId = r.Id;
    SELECT pa.* FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id INNER JOIN #EmpReqs r ON tr.RequestId = r.Id;
    SELECT s.* FROM [dbo].[Settlements] s INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #EmpReqs r ON tr.RequestId = r.Id;
    SELECT te.* FROM [dbo].[TripExtensions] te INNER JOIN [dbo].[TripRequests] tr ON te.TripRequestId = tr.Id INNER JOIN #EmpReqs r ON tr.RequestId = r.Id;
    SELECT lc.* FROM [dbo].[LocalConveyances] lc INNER JOIN [dbo].[Settlements] s ON lc.SettlementId = s.Id INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #EmpReqs r ON tr.RequestId = r.Id;
    SELECT ib.* FROM [dbo].[InternetBillRequests] ib INNER JOIN #EmpReqs r ON ib.RequestId = r.Id;
    SELECT ibp.* FROM [dbo].[InternetBillPeriods] ibp INNER JOIN [dbo].[InternetBillRequests] ib ON ibp.InternetBillRequestId = ib.Id INNER JOIN #EmpReqs r ON ib.RequestId = r.Id;
    SELECT cg.* FROM [dbo].[CarpoolGroups] cg INNER JOIN #EmpReqs r ON cg.RequestId = r.Id;
    SELECT cm.* FROM [dbo].[CarpoolMembers] cm INNER JOIN [dbo].[CarpoolGroups] cg ON cm.CarpoolGroupId = cg.Id INNER JOIN #EmpReqs r ON cg.RequestId = r.Id;
    SELECT rr.* FROM [dbo].[RelocationRequests] rr INNER JOIN #EmpReqs r ON rr.RequestId = r.Id;
    SELECT re.* FROM [dbo].[RelocationExpenses] re INNER JOIN [dbo].[RelocationRequests] rr ON re.RelocationRequestId = rr.Id INNER JOIN #EmpReqs r ON rr.RequestId = r.Id;
    DROP TABLE #EmpReqs;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_GetRequestById]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetRequestById];
GO
CREATE PROCEDURE [dbo].[sp_GetRequestById]
    @Id NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.*, e.[Name] AS EmployeeName, e.[ClLevel] AS ClLevel
    INTO #IdReq
    FROM [dbo].[Requests] r
    LEFT JOIN [dbo].[Employees] e ON r.EmpId = e.Id
    WHERE r.[Id] = @Id;

    SELECT * FROM #IdReq ORDER BY [SubmittedAt] DESC;
    SELECT tr.* FROM [dbo].[TripRequests] tr INNER JOIN #IdReq r ON tr.RequestId = r.Id;
    SELECT pa.* FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id INNER JOIN #IdReq r ON tr.RequestId = r.Id;
    SELECT s.* FROM [dbo].[Settlements] s INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #IdReq r ON tr.RequestId = r.Id;
    SELECT te.* FROM [dbo].[TripExtensions] te INNER JOIN [dbo].[TripRequests] tr ON te.TripRequestId = tr.Id INNER JOIN #IdReq r ON tr.RequestId = r.Id;
    SELECT lc.* FROM [dbo].[LocalConveyances] lc INNER JOIN [dbo].[Settlements] s ON lc.SettlementId = s.Id INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #IdReq r ON tr.RequestId = r.Id;
    SELECT ib.* FROM [dbo].[InternetBillRequests] ib INNER JOIN #IdReq r ON ib.RequestId = r.Id;
    SELECT ibp.* FROM [dbo].[InternetBillPeriods] ibp INNER JOIN [dbo].[InternetBillRequests] ib ON ibp.InternetBillRequestId = ib.Id INNER JOIN #IdReq r ON ib.RequestId = r.Id;
    SELECT cg.* FROM [dbo].[CarpoolGroups] cg INNER JOIN #IdReq r ON cg.RequestId = r.Id;
    SELECT cm.* FROM [dbo].[CarpoolMembers] cm INNER JOIN [dbo].[CarpoolGroups] cg ON cm.CarpoolGroupId = cg.Id INNER JOIN #IdReq r ON cg.RequestId = r.Id;
    SELECT rr.* FROM [dbo].[RelocationRequests] rr INNER JOIN #IdReq r ON rr.RequestId = r.Id;
    SELECT re.* FROM [dbo].[RelocationExpenses] re INNER JOIN [dbo].[RelocationRequests] rr ON re.RelocationRequestId = rr.Id INNER JOIN #IdReq r ON rr.RequestId = r.Id;
    DROP TABLE #IdReq;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_GetRequestsForFinance]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetRequestsForFinance];
GO
CREATE PROCEDURE [dbo].[sp_GetRequestsForFinance]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT r.*, e.[Name] AS EmployeeName, e.[ClLevel] AS ClLevel
    INTO #FinanceReqs
    FROM [dbo].[Requests] r
    LEFT JOIN [dbo].[Employees] e ON r.[EmpId] = e.[Id]
    LEFT JOIN [dbo].[TripRequests] ptr ON r.[Id] = ptr.[RequestId]
    LEFT JOIN [dbo].[PreApprovals] ppa ON ptr.[Id] = ppa.[TripRequestId]
    LEFT JOIN [dbo].[Settlements] ps ON ptr.[Id] = ps.[TripRequestId]
    WHERE
        (r.[Type] = 'travel' AND (ppa.[Status] = 'pending' OR ps.[Status] = 'submitted'))
        OR (r.[Type] <> 'travel' AND r.[Status] = 'pending');

    SELECT * FROM #FinanceReqs ORDER BY [SubmittedAt] ASC;
    SELECT tr.* FROM [dbo].[TripRequests] tr INNER JOIN #FinanceReqs r ON tr.RequestId = r.Id;
    SELECT pa.* FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id INNER JOIN #FinanceReqs r ON tr.RequestId = r.Id;
    SELECT s.* FROM [dbo].[Settlements] s INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #FinanceReqs r ON tr.RequestId = r.Id;
    SELECT te.* FROM [dbo].[TripExtensions] te INNER JOIN [dbo].[TripRequests] tr ON te.TripRequestId = tr.Id INNER JOIN #FinanceReqs r ON tr.RequestId = r.Id;
    SELECT lc.* FROM [dbo].[LocalConveyances] lc INNER JOIN [dbo].[Settlements] s ON lc.SettlementId = s.Id INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id INNER JOIN #FinanceReqs r ON tr.RequestId = r.Id;
    SELECT ib.* FROM [dbo].[InternetBillRequests] ib INNER JOIN #FinanceReqs r ON ib.RequestId = r.Id;
    SELECT ibp.* FROM [dbo].[InternetBillPeriods] ibp INNER JOIN [dbo].[InternetBillRequests] ib ON ibp.InternetBillRequestId = ib.Id INNER JOIN #FinanceReqs r ON ib.RequestId = r.Id;
    SELECT cg.* FROM [dbo].[CarpoolGroups] cg INNER JOIN #FinanceReqs r ON cg.RequestId = r.Id;
    SELECT cm.* FROM [dbo].[CarpoolMembers] cm INNER JOIN [dbo].[CarpoolGroups] cg ON cm.CarpoolGroupId = cg.Id INNER JOIN #FinanceReqs r ON cg.RequestId = r.Id;
    SELECT rr.* FROM [dbo].[RelocationRequests] rr INNER JOIN #FinanceReqs r ON rr.RequestId = r.Id;
    SELECT re.* FROM [dbo].[RelocationExpenses] re INNER JOIN [dbo].[RelocationRequests] rr ON re.RelocationRequestId = rr.Id INNER JOIN #FinanceReqs r ON rr.RequestId = r.Id;
    DROP TABLE #FinanceReqs;
END;
GO


-- ============================================================
-- DASHBOARD STATISTICS PROCEDURES
-- ============================================================

IF OBJECT_ID(N'[dbo].[sp_GetEmployeeDashboardStats]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmployeeDashboardStats];
GO
CREATE PROCEDURE [dbo].[sp_GetEmployeeDashboardStats]
    @EmpId  NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(*) AS [TotalRequests],

        SUM(CASE
            WHEN r.[Status] = 'pending' THEN 1
            WHEN r.[Type] = 'travel' AND pa.[Status] = 'pending' THEN 1
            ELSE 0
        END) AS [Pending],

        SUM(CASE
            WHEN r.[Status] = 'approved' THEN 1
            WHEN r.[Type] = 'travel' AND (pa.[Status] = 'approved' OR s.[Status] = 'approved') THEN 1
            ELSE 0
        END) AS [Approved],

        ISNULL(SUM(CASE WHEN r.[Type] = 'travel' AND s.[Status] = 'approved' THEN s.[TotalAmountINR] ELSE 0 END), 0)
        + ISNULL(SUM(CASE WHEN r.[Type] = 'internet-bill' AND r.[Status] = 'approved' THEN ib.[ClaimableAmount] ELSE 0 END), 0)
        + ISNULL(SUM(CASE WHEN r.[Type] = 'carpooling' AND r.[Status] = 'approved' THEN cg.[MonthlyAmount] ELSE 0 END), 0)
        + ISNULL(SUM(CASE WHEN r.[Type] = 'relocation' AND r.[Status] = 'approved' THEN rr.[TotalAmount] ELSE 0 END), 0)
        AS [TotalReimbursed]

    FROM [dbo].[Requests] r
    LEFT JOIN [dbo].[TripRequests] tr ON r.[Id] = tr.[RequestId]
    LEFT JOIN [dbo].[PreApprovals] pa ON tr.[Id] = pa.[TripRequestId]
    LEFT JOIN [dbo].[Settlements] s ON tr.[Id] = s.[TripRequestId]
    LEFT JOIN [dbo].[InternetBillRequests] ib ON r.[Id] = ib.[RequestId]
    LEFT JOIN [dbo].[CarpoolGroups] cg ON r.[Id] = cg.[RequestId]
    LEFT JOIN [dbo].[RelocationRequests] rr ON r.[Id] = rr.[RequestId]
    WHERE r.[EmpId] = @EmpId;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_GetFinanceDashboardStats]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetFinanceDashboardStats];
GO
CREATE PROCEDURE [dbo].[sp_GetFinanceDashboardStats]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        SUM(CASE WHEN r.[Type] = 'travel' AND pa.[Status] = 'pending' THEN 1 ELSE 0 END) AS [PendingPreApproval],
        SUM(CASE WHEN r.[Type] = 'travel' AND s.[Status] = 'submitted' THEN 1 ELSE 0 END) AS [PendingSettlement],
        SUM(CASE WHEN r.[Type] <> 'travel' AND r.[Status] = 'pending' THEN 1 ELSE 0 END) AS [PendingOther],

        SUM(CASE WHEN (r.[Status] = 'approved' OR pa.[Status] = 'approved' OR s.[Status] = 'approved')
            AND YEAR(r.[UpdatedAt]) = YEAR(GETUTCDATE()) AND MONTH(r.[UpdatedAt]) = MONTH(GETUTCDATE())
            THEN 1 ELSE 0 END) AS [ApprovedThisMonth],

        SUM(CASE WHEN r.[Status] = 'rejected' OR pa.[Status] = 'rejected' OR s.[Status] = 'rejected' THEN 1 ELSE 0 END) AS [TotalRejected],
        0 AS [TotalSubmittedValue]
    FROM [dbo].[Requests] r
    LEFT JOIN [dbo].[TripRequests] tr ON r.[Id] = tr.[RequestId]
    LEFT JOIN [dbo].[PreApprovals] pa ON tr.[Id] = pa.[TripRequestId]
    LEFT JOIN [dbo].[Settlements] s ON tr.[Id] = s.[TripRequestId];
END;
GO


-- ============================================================
-- CREATE REQUEST PROCEDURES
-- ============================================================
-- NOTE: All OPENJSON calls have been removed.
-- Child records are now inserted from the C# backend using
-- the new sp_Insert* procedures below.
-- ============================================================

IF OBJECT_ID(N'[dbo].[sp_CreateTravelRequest]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CreateTravelRequest];
GO
CREATE PROCEDURE [dbo].[sp_CreateTravelRequest]
    @Id             NVARCHAR(20),
    @EmpId          NVARCHAR(20),
    @Title          NVARCHAR(200),

    @Subtype        NVARCHAR(20),
    @Destination    NVARCHAR(100),
    @State          NVARCHAR(100),
    @Region         NVARCHAR(100),
    @Country        NVARCHAR(100),
    @StartDate      DATE,
    @EndDate        DATE,
    @Days           INT,
    @Purpose        NVARCHAR(1000),
    @TravelMode     NVARCHAR(50),

    @HasKnoxApproval BIT,
    @KnoxApproval NVARCHAR(200),
    @HasTravelInsurance BIT,
    @TravelInsurance NVARCHAR(200),
    @HasPassportCopy BIT,
    @PassportCopy NVARCHAR(200),
    @HasVisa BIT,
    @Visa NVARCHAR(200),
    @HasFlightTicket BIT,
    @FlightTicket NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Insert Request
    INSERT INTO [dbo].[Requests] ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES (@Id, @EmpId, 'travel', @Title, 'pending', GETUTCDATE());

    -- Calculate days if NULL
    IF @Days IS NULL
    BEGIN
        SET @Days = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
        IF @Days < 1 SET @Days = 1;
    END

    -- 2. Insert TripRequests
    INSERT INTO [dbo].[TripRequests] ([RequestId], [Subtype], [Destination], [State], [Region], [Country], [StartDate], [EndDate], [Days], [Purpose], [TravelMode], [Stage])
    VALUES (@Id, @Subtype, @Destination, @State, @Region, @Country, @StartDate, @EndDate, @Days, @Purpose, @TravelMode, 'pre-approval');

    -- SQL 2014 compatible: DECLARE then SET (no inline init)
    DECLARE @TripReqId INT;
    SET @TripReqId = SCOPE_IDENTITY();

    -- 3. Insert PreApprovals
    INSERT INTO [dbo].[PreApprovals] ([TripRequestId], [Status], [HasKnoxApproval], [KnoxApproval], [HasTravelInsurance], [TravelInsurance], [HasPassportCopy], [PassportCopy], [HasVisa], [Visa], [HasFlightTicket], [FlightTicket])
    VALUES (@TripReqId, 'pending', @HasKnoxApproval, @KnoxApproval, @HasTravelInsurance, @TravelInsurance, @HasPassportCopy, @PassportCopy, @HasVisa, @Visa, @HasFlightTicket, @FlightTicket);
END;
GO


-- Internet: parent-only insert (no OPENJSON). Child rows inserted from C#.
IF OBJECT_ID(N'[dbo].[sp_CreateInternetRequest]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CreateInternetRequest];
GO
CREATE PROCEDURE [dbo].[sp_CreateInternetRequest]
    @Id                  NVARCHAR(20),
    @EmpId               NVARCHAR(20),
    @Title               NVARCHAR(200),
    @Provider            NVARCHAR(100),
    @Frequency           NVARCHAR(50),
    @TotalAmount         DECIMAL(18,2),
    @ClaimableAmount     DECIMAL(18,2),
    @ReimbursedTillMonth NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Requests] ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES (@Id, @EmpId, 'internet-bill', @Title, 'pending', GETUTCDATE());

    INSERT INTO [dbo].[InternetBillRequests] ([RequestId], [Provider], [Frequency], [TotalAmount], [ClaimableAmount], [ReimbursedTillMonth])
    VALUES (@Id, @Provider, @Frequency, @TotalAmount, @ClaimableAmount, @ReimbursedTillMonth);

    -- Return the new InternetBillRequest Id so C# can insert child periods
    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

-- NEW: Insert a single InternetBillPeriod row (called from C# loop)
IF OBJECT_ID(N'[dbo].[sp_InsertInternetBillPeriod]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_InsertInternetBillPeriod];
GO
CREATE PROCEDURE [dbo].[sp_InsertInternetBillPeriod]
    @InternetBillRequestId INT,
    @PeriodLabel           NVARCHAR(50),
    @Amount                DECIMAL(18,2),
    @HasBillDocument       BIT,
    @BillDocument          NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[InternetBillPeriods] ([InternetBillRequestId], [PeriodLabel], [Amount], [HasBillDocument], [BillDocument])
    VALUES (@InternetBillRequestId, @PeriodLabel, @Amount, @HasBillDocument, @BillDocument);
END;
GO


-- Carpool: parent-only insert (no OPENJSON). Child rows inserted from C#.
IF OBJECT_ID(N'[dbo].[sp_CreateCarpoolRequest]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CreateCarpoolRequest];
GO
CREATE PROCEDURE [dbo].[sp_CreateCarpoolRequest]
    @Id                  NVARCHAR(20),
    @EmpId               NVARCHAR(20),
    @Title               NVARCHAR(200),
    @VehicleNumber       NVARCHAR(20),
    @TotalMembers        INT,
    @MonthlyAmount       DECIMAL(18,2),
    @ValidFrom           DATE,
    @ValidTill           DATE,
    @TapInWindowMinutes  INT,
    @TapOutWindowMinutes INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Requests] ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES (@Id, @EmpId, 'carpooling', @Title, 'pending', GETUTCDATE());

    INSERT INTO [dbo].[CarpoolGroups] ([RequestId], [VehicleOwnerEmpId], [VehicleNumber], [TotalMembers], [MonthlyAmount], [ValidFrom], [ValidTill], [TapInWindowMinutes], [TapOutWindowMinutes])
    VALUES (@Id, @EmpId, @VehicleNumber, @TotalMembers, @MonthlyAmount, @ValidFrom, @ValidTill, @TapInWindowMinutes, @TapOutWindowMinutes);

    -- Return the new CarpoolGroup Id so C# can insert child members
    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

-- NEW: Insert a single CarpoolMember row (called from C# loop)
IF OBJECT_ID(N'[dbo].[sp_InsertCarpoolMember]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_InsertCarpoolMember];
GO
CREATE PROCEDURE [dbo].[sp_InsertCarpoolMember]
    @CarpoolGroupId      INT,
    @EmpId               NVARCHAR(20),
    @EmployeeType        NVARCHAR(50),
    @PickupAddress       NVARCHAR(500),
    @Latitude            DECIMAL(10,7),
    @Longitude           DECIMAL(10,7),
    @NearestMetroStation NVARCHAR(100),
    @MetroDistanceKm     DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[CarpoolMembers] ([CarpoolGroupId], [EmpId], [EmployeeType], [PickupAddress], [Latitude], [Longitude], [NearestMetroStation], [MetroDistanceKm])
    VALUES (@CarpoolGroupId, @EmpId, @EmployeeType, @PickupAddress, @Latitude, @Longitude, @NearestMetroStation, @MetroDistanceKm);
END;
GO


-- Relocation: parent-only insert (no OPENJSON). Child rows inserted from C#.
IF OBJECT_ID(N'[dbo].[sp_CreateRelocationRequest]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_CreateRelocationRequest];
GO
CREATE PROCEDURE [dbo].[sp_CreateRelocationRequest]
    @Id             NVARCHAR(20),
    @EmpId          NVARCHAR(20),
    @Title          NVARCHAR(200),
    @FromCity       NVARCHAR(100),
    @ToCity         NVARCHAR(100),
    @RelocDate      DATE,
    @TeamName       NVARCHAR(100),
    @TotalAmount    DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO [dbo].[Requests] ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES (@Id, @EmpId, 'relocation', @Title, 'pending', GETUTCDATE());

    INSERT INTO [dbo].[RelocationRequests] ([RequestId], [FromCity], [ToCity], [RelocDate], [TeamName], [TotalAmount])
    VALUES (@Id, @FromCity, @ToCity, @RelocDate, @TeamName, @TotalAmount);

    -- Return the new RelocationRequest Id so C# can insert child expenses
    SELECT SCOPE_IDENTITY() AS NewId;
END;
GO

-- NEW: Insert a single RelocationExpense row (called from C# loop)
IF OBJECT_ID(N'[dbo].[sp_InsertRelocationExpense]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_InsertRelocationExpense];
GO
CREATE PROCEDURE [dbo].[sp_InsertRelocationExpense]
    @RelocationRequestId INT,
    @Category            NVARCHAR(50),
    @Description         NVARCHAR(500),
    @Amount              DECIMAL(18,2),
    @HasBillDocument     BIT,
    @BillDocument        NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [HasBillDocument], [BillDocument])
    VALUES (@RelocationRequestId, @Category, @Description, @Amount, @HasBillDocument, @BillDocument);
END;
GO


-- ============================================================
-- SUBMIT SETTLEMENT / EXTENSION PROCEDURES
-- ============================================================

-- Settlement: parent-only insert (no OPENJSON for LocalConveyances).
-- LocalConveyance child rows inserted from C#.
-- Returns the new SettlementId.
IF OBJECT_ID(N'[dbo].[sp_SubmitSettlement]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_SubmitSettlement];
GO
CREATE PROCEDURE [dbo].[sp_SubmitSettlement]
    @RequestId          NVARCHAR(20),
    @HotelName          NVARCHAR(200),
    @HotelAmount        DECIMAL(18,2),
    @HasHotelBill       BIT,
    @HotelBill          NVARCHAR(200),
    @PerDiemDays        INT,
    @PerDiemRate        DECIMAL(18,2),
    @PerDiemAmount      DECIMAL(18,2),
    @Currency           NVARCHAR(10),
    @ExchangeRate       DECIMAL(18,6),
    @TotalAmountForeign DECIMAL(18,2),
    @TotalAmountINR     DECIMAL(18,2),
    @HasBoardingPass    BIT,
    @BoardingPass       NVARCHAR(200),
    @HasPassportStamps  BIT,
    @PassportStamps     NVARCHAR(200),
    @HasTripReport      BIT,
    @TripReport         NVARCHAR(200),
    @HasForexStatement  BIT,
    @ForexStatement     NVARCHAR(200),
    @WinterClothes      BIT,
    @WinterClothesAmount DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    -- SQL 2014 compatible: DECLARE then SET
    DECLARE @TripReqId INT;
    SET @TripReqId = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = @RequestId);

    -- Delete existing draft settlement if any
    DELETE FROM [dbo].[LocalConveyances] WHERE [SettlementId] IN (SELECT [Id] FROM [dbo].[Settlements] WHERE [TripRequestId] = @TripReqId);
    DELETE FROM [dbo].[Settlements] WHERE [TripRequestId] = @TripReqId;

    INSERT INTO [dbo].[Settlements] (
        [TripRequestId], [Status], [HotelName], [HotelAmount], [HasHotelBill], [HotelBill],
        [PerDiemDays], [PerDiemRate], [PerDiemAmount], [Currency], [ExchangeRate], [TotalAmountForeign], [TotalAmountINR],
        [HasBoardingPass], [BoardingPass], [HasPassportStamps], [PassportStamps], [HasTripReport], [TripReport],
        [HasForexStatement], [ForexStatement], [WinterClothes], [WinterClothesAmount], [SubmittedAt]
    ) VALUES (
        @TripReqId, 'submitted', @HotelName, @HotelAmount, @HasHotelBill, @HotelBill,
        @PerDiemDays, @PerDiemRate, @PerDiemAmount, @Currency, @ExchangeRate, @TotalAmountForeign, @TotalAmountINR,
        @HasBoardingPass, @BoardingPass, @HasPassportStamps, @PassportStamps, @HasTripReport, @TripReport,
        @HasForexStatement, @ForexStatement, @WinterClothes, @WinterClothesAmount, GETUTCDATE()
    );

    DECLARE @SettlementId INT;
    SET @SettlementId = SCOPE_IDENTITY();

    -- Update stage
    UPDATE [dbo].[TripRequests] SET [Stage] = 'settlement-review' WHERE [Id] = @TripReqId;

    -- Return the new Settlement Id so C# can insert child LocalConveyances
    SELECT @SettlementId AS NewId;
END;
GO

-- NEW: Insert a single LocalConveyance row (called from C# loop)
IF OBJECT_ID(N'[dbo].[sp_InsertLocalConveyance]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_InsertLocalConveyance];
GO
CREATE PROCEDURE [dbo].[sp_InsertLocalConveyance]
    @SettlementId    INT,
    @ConveyanceType  NVARCHAR(50),
    @Route           NVARCHAR(200),
    @Amount          DECIMAL(18,2),
    @Distance        DECIMAL(10,2),
    @HasBillDocument BIT,
    @BillDocument    NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[LocalConveyances] ([SettlementId], [ConveyanceType], [Route], [Amount], [Distance], [HasBillDocument], [BillDocument])
    VALUES (@SettlementId, @ConveyanceType, @Route, @Amount, @Distance, @HasBillDocument, @BillDocument);
END;
GO


IF OBJECT_ID(N'[dbo].[sp_SubmitTripExtension]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_SubmitTripExtension];
GO
CREATE PROCEDURE [dbo].[sp_SubmitTripExtension]
    @RequestId          NVARCHAR(20),
    @RevisedEndDate     DATE,
    @RevisedDays        INT,
    @Reason             NVARCHAR(500),
    @HasApprovalDocument BIT,
    @ApprovalDocument   NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- SQL 2014 compatible: DECLARE then SET
    DECLARE @TripReqId INT;
    SET @TripReqId = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = @RequestId);

    DECLARE @PrevExtId INT;
    SET @PrevExtId = (SELECT [LatestExtensionId] FROM [dbo].[TripRequests] WHERE [Id] = @TripReqId);

    INSERT INTO [dbo].[TripExtensions] ([TripRequestId], [PreviousExtensionId], [RevisedEndDate], [RevisedDays], [Reason], [HasApprovalDocument], [ApprovalDocument], [Status])
    VALUES (@TripReqId, @PrevExtId, @RevisedEndDate, @RevisedDays, @Reason, @HasApprovalDocument, @ApprovalDocument, 'pending');

    DECLARE @NewExtId INT;
    SET @NewExtId = SCOPE_IDENTITY();

    UPDATE [dbo].[TripRequests] SET [LatestExtensionId] = @NewExtId WHERE [Id] = @TripReqId;
END;
GO


-- ============================================================
-- FINANCE REVIEW PROCEDURES
-- ============================================================

IF OBJECT_ID(N'[dbo].[sp_FinanceReviewTravel]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_FinanceReviewTravel];
GO
CREATE PROCEDURE [dbo].[sp_FinanceReviewTravel]
    @RequestId              NVARCHAR(20),
    @FinanceEmpId           NVARCHAR(20),
    @PreApprovalStatus      NVARCHAR(20),
    @SettlementStatus       NVARCHAR(20),
    @ExtensionStatus        NVARCHAR(20),
    @DocumentReviewStatus   NVARCHAR(20),
    @Stage                  NVARCHAR(50),
    @FinanceNote            NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    -- SQL 2014 compatible: DECLARE then SET
    DECLARE @TripReqId INT;
    SET @TripReqId = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = @RequestId);

    -- PreApproval
    IF @PreApprovalStatus IS NOT NULL
    BEGIN
        UPDATE [dbo].[PreApprovals]
        SET [Status] = @PreApprovalStatus,
            [DocumentReviewStatus] = @DocumentReviewStatus,
            [ReviewedBy] = @FinanceEmpId,
            [ApprovedAt] = CASE WHEN @PreApprovalStatus = 'approved' THEN GETUTCDATE() ELSE NULL END
        WHERE [TripRequestId] = @TripReqId;
    END

    -- Settlement
    IF @SettlementStatus IS NOT NULL
    BEGIN
        UPDATE [dbo].[Settlements]
        SET [Status] = @SettlementStatus, [ReviewedAt] = GETUTCDATE()
        WHERE [TripRequestId] = @TripReqId;
    END

    -- Extension
    IF @ExtensionStatus IS NOT NULL
    BEGIN
        UPDATE [dbo].[TripExtensions]
        SET [Status] = @ExtensionStatus, [ReviewedAt] = GETUTCDATE()
        WHERE [TripRequestId] = @TripReqId AND [Status] = 'pending';

        IF @ExtensionStatus = 'approved'
        BEGIN
            DECLARE @RevDate DATETIME2;
            DECLARE @RevDays INT;

            SELECT TOP 1 @RevDate = [RevisedEndDate], @RevDays = [RevisedDays]
            FROM [dbo].[TripExtensions]
            WHERE [TripRequestId] = @TripReqId AND [Status] = 'approved'
            ORDER BY [Id] DESC;

            IF @RevDate IS NOT NULL
            BEGIN
                UPDATE [dbo].[TripRequests]
                SET [EndDate] = @RevDate, [Days] = @RevDays
                WHERE [Id] = @TripReqId;
            END
        END
    END

    -- Master Request & TripRequest
    UPDATE [dbo].[Requests]
    SET [Status] = COALESCE(@SettlementStatus, @PreApprovalStatus, [Status]),
        [FinanceNote] = @FinanceNote,
        [UpdatedAt] = GETUTCDATE()
    WHERE [Id] = @RequestId;

    UPDATE [dbo].[TripRequests] SET [Stage] = @Stage WHERE [Id] = @TripReqId;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_FinanceReviewOther]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_FinanceReviewOther];
GO
CREATE PROCEDURE [dbo].[sp_FinanceReviewOther]
    @RequestId      NVARCHAR(20),
    @FinanceEmpId   NVARCHAR(20),
    @Status         NVARCHAR(20),
    @FinanceNote    NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE [dbo].[Requests]
    SET [Status] = @Status, [FinanceNote] = @FinanceNote, [UpdatedAt] = GETUTCDATE()
    WHERE [Id] = @RequestId;
END;
GO


-- ============================================================
-- EMPLOYEE FILES PROCEDURES
-- ============================================================

IF OBJECT_ID(N'[dbo].[sp_SaveEmployeeFile]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_SaveEmployeeFile];
GO
CREATE PROCEDURE [dbo].[sp_SaveEmployeeFile]
    @EmpId    VARCHAR(50),
    @FileName VARCHAR(255),
    @FilePath VARCHAR(500),
    @FileType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[EmployeeFiles] ([EmpId], [FileName], [FilePath], [FileType])
    VALUES (@EmpId, @FileName, @FilePath, @FileType);
END;
GO

IF OBJECT_ID(N'[dbo].[sp_GetEmployeeFilesByEmpId]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_GetEmployeeFilesByEmpId];
GO
CREATE PROCEDURE [dbo].[sp_GetEmployeeFilesByEmpId]
    @EmpId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT [Id], [EmpId], [FileName], [FilePath], [FileType], [UploadedAt]
    FROM [dbo].[EmployeeFiles]
    WHERE [EmpId] = @EmpId
    ORDER BY [UploadedAt] DESC;
END;
GO

IF OBJECT_ID(N'[dbo].[sp_DeleteEmployeeFile]', N'P') IS NOT NULL
    DROP PROCEDURE [dbo].[sp_DeleteEmployeeFile];
GO
CREATE PROCEDURE [dbo].[sp_DeleteEmployeeFile]
    @Id UNIQUEIDENTIFIER
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM [dbo].[EmployeeFiles] WHERE [Id] = @Id;
END;
GO


PRINT '';
PRINT '=== All stored procedures created successfully. ===';
PRINT '';
GO


-- ============================================================
-- 3. SEED DATA
-- ============================================================

-- Employees
IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'EMP001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'EMP001', N'Arjun Sharma', N'emp001', N'pass123', 0, 0, N'CL3', N'Technology', N'Software Engineer', N'arjun.sharma@company.com', N'Vikram Patel', N'AI', N'Orion');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'EMP002')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'EMP002', N'Priya Mehta', N'emp002', N'pass123', 0, 0, N'CL4', N'Operations', N'Associate', N'priya.mehta@company.com', N'Neha Gupta', N'AD', N'Mercury');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'EMP003')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'EMP003', N'Karan Singh', N'emp003', N'pass123', 0, 0, N'CL2', N'Sales', N'Senior Manager', N'karan.singh@company.com', N'Amit Joshi', N'QC', N'Atlas');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'FIN001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'FIN001', N'Rahul Verma', N'finance01', N'pass123', 1, 0, N'CL2', N'Finance', N'Finance Analyst', N'rahul.verma@company.com', N'Priya Das', N'Finance', N'Portal');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'ADM001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'ADM001', N'Sunita Rao', N'admin01', N'pass123', 1, 1, N'CL1', N'HR', N'HR Director', N'sunita.rao@company.com', NULL, N'HR', N'Corporate');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'INT001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'INT001', N'Rohan Kapoor', N'intern01', N'pass123', 0, 0, N'CL4', N'Technology', N'Intern', N'rohan.kapoor@company.com', N'Arjun Sharma', N'AI', N'Orion');

PRINT 'Employees seeded.';
GO

-- Travel Request (Completed - approved settlement)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0001')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt], [UpdatedAt])
    VALUES
        (N'REQ-2024-0001', N'EMP001', N'travel', N'Client meeting at Mumbai HQ', N'approved', '2024-03-10T10:00:00', '2024-03-20T14:30:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0001')
    INSERT INTO [dbo].[TripRequests]
        ([RequestId], [Subtype], [Destination], [State], [Region], [StartDate], [EndDate], [Days], [Purpose], [TravelMode], [Stage])
    VALUES
        (N'REQ-2024-0001', N'domestic', N'Mumbai', N'Maharashtra', N'Area A', '2024-03-15', '2024-03-18', 4, N'Client meeting at Mumbai HQ', N'Air', N'settlement-approved');

IF NOT EXISTS (SELECT 1 FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id WHERE tr.RequestId = N'REQ-2024-0001')
BEGIN
    DECLARE @trip1Id INT;
    SET @trip1Id = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0001');
    INSERT INTO [dbo].[PreApprovals]
        ([TripRequestId], [Status], [KnoxApproval], [TravelInsurance], [ApprovedAt], [ReviewedBy])
    VALUES
        (@trip1Id, N'approved', N'knox_approval.pdf', N'insurance_cert.pdf', '2024-03-12T10:00:00', N'FIN001');
END;

IF NOT EXISTS (SELECT 1 FROM [dbo].[Settlements] s INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id WHERE tr.RequestId = N'REQ-2024-0001')
BEGIN
    DECLARE @trip1IdS INT;
    SET @trip1IdS = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0001');
    INSERT INTO [dbo].[Settlements]
        ([TripRequestId], [Status], [HotelName], [HotelAmount], [PerDiemDays], [PerDiemRate], [PerDiemAmount], [TotalAmountINR], [BoardingPass], [TripReport], [SubmittedAt], [ReviewedAt])
    VALUES
        (@trip1IdS, N'approved', N'Grand Hyatt', 12000.00, 4, 1500.00, 6000.00, 22500.00, N'bp_mumbai.pdf', N'trip_report.pdf', '2024-03-19T10:00:00', '2024-03-20T14:30:00');
END;

PRINT 'Seed: Travel (completed) inserted.';
GO

-- Travel Request (Pending pre-approval)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0005')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES
        (N'REQ-2024-0005', N'EMP001', N'travel', N'Quarterly review at Delhi office', N'pending', '2024-05-05T09:15:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0005')
    INSERT INTO [dbo].[TripRequests]
        ([RequestId], [Subtype], [Destination], [State], [Region], [StartDate], [EndDate], [Days], [Purpose], [TravelMode], [Stage])
    VALUES
        (N'REQ-2024-0005', N'domestic', N'Delhi', N'Delhi', N'Area A', '2024-05-10', '2024-05-14', 5, N'Quarterly review at Delhi office', N'Air', N'pre-approval');

IF NOT EXISTS (SELECT 1 FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id WHERE tr.RequestId = N'REQ-2024-0005')
BEGIN
    DECLARE @trip2Id INT;
    SET @trip2Id = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0005');
    INSERT INTO [dbo].[PreApprovals]
        ([TripRequestId], [Status], [KnoxApproval], [TravelInsurance])
    VALUES
        (@trip2Id, N'pending', N'knox_delhi.pdf', N'travel_insurance.pdf');
END;

PRINT 'Seed: Travel (pending) inserted.';
GO

-- Internet Bill (Pending)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0006')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES
        (N'REQ-2024-0006', N'EMP001', N'internet-bill', N'Internet Bill - Q1 2024', N'pending', '2024-04-01T08:00:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[InternetBillRequests] WHERE [RequestId] = N'REQ-2024-0006')
    INSERT INTO [dbo].[InternetBillRequests]
        ([RequestId], [Provider], [Frequency], [TotalAmount], [ClaimableAmount], [ReimbursedTillMonth])
    VALUES
        (N'REQ-2024-0006', N'Airtel Broadband', N'monthly', 2850.00, 2850.00, NULL);

IF NOT EXISTS (SELECT 1 FROM [dbo].[InternetBillPeriods] ibp INNER JOIN [dbo].[InternetBillRequests] ibr ON ibp.InternetBillRequestId = ibr.Id WHERE ibr.RequestId = N'REQ-2024-0006')
BEGIN
    DECLARE @inet1Id INT;
    SET @inet1Id = (SELECT [Id] FROM [dbo].[InternetBillRequests] WHERE [RequestId] = N'REQ-2024-0006');
    INSERT INTO [dbo].[InternetBillPeriods] ([InternetBillRequestId], [PeriodLabel], [Amount], [BillDocument]) VALUES
        (@inet1Id, N'Month 1 (Jan)', 950.00, N'airtel_jan.pdf');
    INSERT INTO [dbo].[InternetBillPeriods] ([InternetBillRequestId], [PeriodLabel], [Amount], [BillDocument]) VALUES
        (@inet1Id, N'Month 2 (Feb)', 950.00, N'airtel_feb.pdf');
    INSERT INTO [dbo].[InternetBillPeriods] ([InternetBillRequestId], [PeriodLabel], [Amount], [BillDocument]) VALUES
        (@inet1Id, N'Month 3 (Mar)', 950.00, N'airtel_mar.pdf');
END;

PRINT 'Seed: Internet bill inserted.';
GO

-- Carpooling (Approved)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0007')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt], [UpdatedAt])
    VALUES
        (N'REQ-2024-0007', N'EMP002', N'carpool', N'Carpool - Feb 2024', N'approved', '2024-03-01T07:30:00', '2024-03-05T11:00:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[CarpoolGroups] WHERE [RequestId] = N'REQ-2024-0007')
    INSERT INTO [dbo].[CarpoolGroups]
        ([RequestId], [VehicleOwnerEmpId], [VehicleNumber], [TotalMembers], [MetroCheckPassed], [IsActive], [MonthlyAmount], [ValidFrom], [ValidTill], [AMSVerified], [AMSDaysPresent])
    VALUES
        (N'REQ-2024-0007', N'EMP002', N'MH12AB1234', 2, 1, 1, 750.00, '2024-02-01', '2024-02-29', 1, 18);

IF NOT EXISTS (SELECT 1 FROM [dbo].[CarpoolMembers] cm INNER JOIN [dbo].[CarpoolGroups] cg ON cm.CarpoolGroupId = cg.Id WHERE cg.RequestId = N'REQ-2024-0007')
BEGIN
    DECLARE @cp1Id INT;
    SET @cp1Id = (SELECT [Id] FROM [dbo].[CarpoolGroups] WHERE [RequestId] = N'REQ-2024-0007');
    INSERT INTO [dbo].[CarpoolMembers] ([CarpoolGroupId], [EmpId], [EmployeeType], [PickupAddress], [Latitude], [Longitude]) VALUES
        (@cp1Id, N'EMP002', N'full-time', N'Plot 42, Kothrud, Pune 411038', 18.5074, 73.8077);
    INSERT INTO [dbo].[CarpoolMembers] ([CarpoolGroupId], [EmpId], [EmployeeType], [PickupAddress], [Latitude], [Longitude]) VALUES
        (@cp1Id, N'INT001', N'intern', N'Lane 5, Karve Nagar, Pune 411052', 18.4920, 73.8170);
END;

PRINT 'Seed: Carpooling inserted.';
GO

-- Relocation (Pending)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0008')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES
        (N'REQ-2024-0008', N'EMP003', N'relocation', N'Relocation Pune to Bengaluru', N'pending', '2024-05-15T12:00:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[RelocationRequests] WHERE [RequestId] = N'REQ-2024-0008')
    INSERT INTO [dbo].[RelocationRequests]
        ([RequestId], [FromCity], [ToCity], [RelocDate], [TeamName], [TotalAmount])
    VALUES
        (N'REQ-2024-0008', N'Pune', N'Bengaluru', '2024-06-01', N'QC', 45000.00);

IF NOT EXISTS (SELECT 1 FROM [dbo].[RelocationExpenses] re INNER JOIN [dbo].[RelocationRequests] rr ON re.RelocationRequestId = rr.Id WHERE rr.RequestId = N'REQ-2024-0008')
BEGIN
    DECLARE @reloc1Id INT;
    SET @reloc1Id = (SELECT [Id] FROM [dbo].[RelocationRequests] WHERE [RequestId] = N'REQ-2024-0008');
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [BillDocument]) VALUES
        (@reloc1Id, N'transport', N'Flight Pune to Bengaluru', 8500.00, N'flight_blr.pdf');
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [BillDocument]) VALUES
        (@reloc1Id, N'porter', N'Movers and packers', 12000.00, N'packers_receipt.pdf');
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [BillDocument]) VALUES
        (@reloc1Id, N'brokerage', N'Flat broker fee (1 month)', 15000.00, N'broker_receipt.pdf');
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [BillDocument]) VALUES
        (@reloc1Id, N'packing', N'Packing materials', 3500.00, N'packing_bill.pdf');
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [BillDocument]) VALUES
        (@reloc1Id, N'temporary-accommodation', N'Hotel for 3 nights', 6000.00, N'hotel_temp.pdf');
END;

PRINT 'Seed: Relocation inserted.';
GO


PRINT '';
PRINT '=== All seed data inserted successfully. ===';
PRINT '=== Database setup complete for SQL Server 2014. ===';
GO
