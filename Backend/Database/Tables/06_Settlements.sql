-- =============================================
-- Table:   [dbo].[Settlements]
-- Desc:    One row per trip settlement
-- Depends: [dbo].[TripRequests]
-- =============================================

IF OBJECT_ID(N'dbo.Settlements', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[Settlements]
    (
        [Id]                  INT             IDENTITY(1,1)   NOT NULL,
        [TripRequestId]       INT             NOT NULL,
        [Status]              NVARCHAR(20)    NOT NULL        DEFAULT N'draft',   -- draft / submitted / approved / rejected
        [HotelName]           NVARCHAR(200)   NULL,
        [HotelAmount]         DECIMAL(18,2)   NULL,
        [HasHotelBill]        BIT             NOT NULL  CONSTRAINT [DF_Settlements_HasHotel] DEFAULT (0),
        [HotelBill]           NVARCHAR(200)   NULL,            -- uploaded file
        [PerDiemDays]         INT             NULL,
        [PerDiemRate]         DECIMAL(18,2)   NULL,
        [PerDiemAmount]       DECIMAL(18,2)   NULL,
        [Currency]            NVARCHAR(10)    NOT NULL        DEFAULT N'₹',
        [ExchangeRate]        DECIMAL(18,6)   NOT NULL        DEFAULT 1.0,
        [TotalAmountForeign]  DECIMAL(18,2)   NULL,
        [TotalAmountINR]      DECIMAL(18,2)   NULL,
        [HasBoardingPass]     BIT             NOT NULL  CONSTRAINT [DF_Settlements_HasBoarding] DEFAULT (0),
        [BoardingPass]        NVARCHAR(200)   NULL,            -- uploaded file
        [HasPassportStamps]   BIT             NOT NULL  CONSTRAINT [DF_Settlements_HasStamps] DEFAULT (0),
        [PassportStamps]      NVARCHAR(200)   NULL,            -- uploaded file (intl only)
        [HasTripReport]       BIT             NOT NULL  CONSTRAINT [DF_Settlements_HasReport] DEFAULT (0),
        [TripReport]          NVARCHAR(200)   NULL,            -- uploaded file
        [HasForexStatement]   BIT             NOT NULL  CONSTRAINT [DF_Settlements_HasForex] DEFAULT (0),
        [ForexStatement]      NVARCHAR(200)   NULL,            -- uploaded file (intl only)
        [WinterClothes]       BIT             NOT NULL        DEFAULT 0,
        [WinterClothesAmount] DECIMAL(18,2)   NULL,
        [SubmittedAt]         DATETIME2       NULL,
        [ReviewedAt]          DATETIME2       NULL,

        CONSTRAINT [PK_Settlements]                 PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_Settlements_TripRequestId]   UNIQUE ([TripRequestId]),
        CONSTRAINT [FK_Settlements_TripRequests]     FOREIGN KEY ([TripRequestId])
                   REFERENCES [dbo].[TripRequests]([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_Settlements_TripRequestId]
        ON [dbo].[Settlements] ([TripRequestId]);

    CREATE NONCLUSTERED INDEX [IX_Settlements_Status]
        ON [dbo].[Settlements] ([Status]);
END
GO

PRINT 'Table [dbo].[Settlements] ensured.';
GO
