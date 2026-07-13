-- ============================================================
-- Table:   [dbo].[InternetBillRequests]
-- Desc:    One row per internet-bill reimbursement request (1:1 with Requests).
-- Depends: [dbo].[Requests]
-- ============================================================

IF OBJECT_ID(N'dbo.InternetBillRequests', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[InternetBillRequests]
    (
        [Id]                    INT             IDENTITY(1,1)   NOT NULL,
        [RequestId]             NVARCHAR(20)                    NOT NULL,
        [Provider]              NVARCHAR(100)                   NOT NULL,
        [Frequency]             NVARCHAR(20)                    NOT NULL,   -- monthly / quarterly / half-yearly / yearly
        [TotalAmount]           DECIMAL(18,2)                   NULL,       -- sum of all period amounts
        [ClaimableAmount]       DECIMAL(18,2)                   NULL,       -- capped amount
        [ReimbursedTillMonth]   NVARCHAR(20)                    NULL,       -- e.g. 'March 2026'

        CONSTRAINT [PK_InternetBillRequests]            PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_InternetBillRequests_RequestId]  UNIQUE ([RequestId]),
        CONSTRAINT [FK_InternetBillRequests_Requests]   FOREIGN KEY ([RequestId])
            REFERENCES [dbo].[Requests] ([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_InternetBillRequests_RequestId]
        ON [dbo].[InternetBillRequests] ([RequestId]);

    PRINT 'Created table [dbo].[InternetBillRequests]';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[InternetBillRequests] already exists — skipped.';
END
GO
