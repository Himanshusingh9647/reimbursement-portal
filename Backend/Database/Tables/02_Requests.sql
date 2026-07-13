-- ============================================================
-- Table: Requests (Master)
-- One row per reimbursement request of any type.
-- Parent table — all subtypes FK back to this.
-- Run order: 2 (depends on: Employees)
-- ============================================================

IF OBJECT_ID(N'[dbo].[Requests]', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Requests]
    (
        [Id]            NVARCHAR(20)    NOT NULL,               -- REQ-2026-XXXX
        [EmpId]         NVARCHAR(20)    NOT NULL,
        [Type]          NVARCHAR(30)    NOT NULL,               -- travel | internet-bill | carpool | relocation
        [Title]         NVARCHAR(200)   NOT NULL,
        [Status]        NVARCHAR(20)    NOT NULL    CONSTRAINT [DF_Requests_Status] DEFAULT ('pending'),
                                                                -- pending | approved | rejected
        [FinanceNote]   NVARCHAR(500)   NULL,
        [SubmittedAt]   DATETIME2       NOT NULL    CONSTRAINT [DF_Requests_SubmittedAt] DEFAULT (GETUTCDATE()),
        [UpdatedAt]     DATETIME2       NULL,

        CONSTRAINT [PK_Requests] PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_Requests_Employees] FOREIGN KEY ([EmpId])
            REFERENCES [dbo].[Employees]([Id]),
        CONSTRAINT [CK_Requests_Type] CHECK ([Type] IN (
            N'travel', N'internet-bill', N'carpool', N'relocation'
        ))
    );
END;
GO

-- Indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Requests_EmpId')
    CREATE NONCLUSTERED INDEX [IX_Requests_EmpId]
        ON [dbo].[Requests] ([EmpId]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Requests_Type')
    CREATE NONCLUSTERED INDEX [IX_Requests_Type]
        ON [dbo].[Requests] ([Type]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Requests_Status')
    CREATE NONCLUSTERED INDEX [IX_Requests_Status]
        ON [dbo].[Requests] ([Status]);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE [name] = N'IX_Requests_SubmittedAt')
    CREATE NONCLUSTERED INDEX [IX_Requests_SubmittedAt]
        ON [dbo].[Requests] ([SubmittedAt] DESC);
GO

PRINT '02 — Requests master table ready.';
GO
