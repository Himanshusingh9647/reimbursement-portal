-- =============================================
-- Table:   [dbo].[LocalConveyances]
-- Desc:    One-to-many from Settlements — each cab trip, own vehicle trip, etc.
-- Depends: [dbo].[Settlements]
-- =============================================

IF OBJECT_ID(N'dbo.LocalConveyances', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[LocalConveyances]
    (
        [Id]              INT             IDENTITY(1,1)   NOT NULL,
        [SettlementId]    INT             NOT NULL,
        [ConveyanceType]  NVARCHAR(20)    NOT NULL,          -- cab / own-vehicle / public-transport
        [Route]           NVARCHAR(200)   NULL,              -- e.g. 'Residence → Airport (Departure)'
        [Amount]          DECIMAL(18,2)   NOT NULL,
        [Distance]        DECIMAL(10,2)   NULL,              -- km (for own vehicle)
        [HasBillDocument] BIT             NOT NULL        CONSTRAINT [DF_LocalConveyances_HasBill] DEFAULT (0),
        [BillDocument]    NVARCHAR(200)   NULL,              -- uploaded file

        CONSTRAINT [PK_LocalConveyances]              PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [FK_LocalConveyances_Settlements]  FOREIGN KEY ([SettlementId])
                   REFERENCES [dbo].[Settlements]([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_LocalConveyances_SettlementId]
        ON [dbo].[LocalConveyances] ([SettlementId]);
END
GO

PRINT 'Table [dbo].[LocalConveyances] ensured.';
GO
