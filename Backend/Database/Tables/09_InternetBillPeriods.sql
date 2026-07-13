-- ============================================================
-- Table:   [dbo].[InternetBillPeriods]
-- Desc:    Individual billing periods for an internet-bill request (many:1 with InternetBillRequests).
-- Depends: [dbo].[InternetBillRequests]
-- ============================================================

IF OBJECT_ID(N'dbo.InternetBillPeriods', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[InternetBillPeriods]
    (
        [Id]                        INT             IDENTITY(1,1)   NOT NULL,
        [InternetBillRequestId]     INT                             NOT NULL,
        [PeriodLabel]               NVARCHAR(50)    NOT NULL,       -- 'Month 1', 'Q1', 'Year', etc.
        [Amount]                    DECIMAL(18,2)   NOT NULL,
        [HasBillDocument]           BIT             NOT NULL        CONSTRAINT [DF_InternetBillPeriods_HasBill] DEFAULT (0),
        [BillDocument]              NVARCHAR(200)   NULL,           -- uploaded file path / name

        CONSTRAINT [PK_InternetBillPeriods]                         PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_InternetBillPeriods_InternetBillRequests]     FOREIGN KEY ([InternetBillRequestId])
            REFERENCES [dbo].[InternetBillRequests] ([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_InternetBillPeriods_InternetBillRequestId]
        ON [dbo].[InternetBillPeriods] ([InternetBillRequestId]);

    PRINT 'Created table [dbo].[InternetBillPeriods]';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[InternetBillPeriods] already exists — skipped.';
END
GO
