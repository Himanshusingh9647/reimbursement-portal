CREATE OR ALTER PROCEDURE [dbo].[sp_SubmitSettlement]
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
    @WinterClothesAmount DECIMAL(18,2),
    @LocalConveyancesJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TripReqId INT = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = @RequestId);

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

    DECLARE @SettlementId INT = SCOPE_IDENTITY();

    INSERT INTO [dbo].[LocalConveyances] ([SettlementId], [ConveyanceType], [Route], [Amount], [Distance], [HasBillDocument], [BillDocument])
    SELECT @SettlementId, [ConveyanceType], [Route], [Amount], [Distance], [HasBillDocument], [BillDocument]
    FROM OPENJSON(@LocalConveyancesJson)
    WITH (
        [ConveyanceType] NVARCHAR(50),
        [Route] NVARCHAR(200),
        [Amount] DECIMAL(18,2),
        [Distance] DECIMAL(10,2),
        [HasBillDocument] BIT,
        [BillDocument] NVARCHAR(200)
    );
    
    -- Update stage
    UPDATE [dbo].[TripRequests] SET [Stage] = 'settlement' WHERE [Id] = @TripReqId;
END;
GO
