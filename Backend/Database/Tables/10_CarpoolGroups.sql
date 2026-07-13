-- =============================================
-- Table:   [dbo].[CarpoolGroups]
-- Desc:    One row per carpool registration.
--          Links to a Request (1:1) and tracks
--          vehicle owner, metro proximity check,
--          AMS attendance verification, and
--          tap-in/out time windows.
-- Depends: [dbo].[Requests], [dbo].[Employees]
-- =============================================

IF OBJECT_ID(N'dbo.CarpoolGroups', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CarpoolGroups]
    (
        [Id]                    INT             IDENTITY(1,1)   NOT NULL,
        [RequestId]             NVARCHAR(20)    NOT NULL,
        [VehicleOwnerEmpId]     NVARCHAR(20)    NOT NULL,
        [VehicleNumber]         NVARCHAR(20)    NULL,
        [TotalMembers]          INT             NOT NULL,
        [MetroCheckPassed]      BIT             NOT NULL    CONSTRAINT [DF_CarpoolGroups_MetroCheckPassed]   DEFAULT (0),
        [IsActive]              BIT             NOT NULL    CONSTRAINT [DF_CarpoolGroups_IsActive]            DEFAULT (1),
        [MonthlyAmount]         DECIMAL(18,2)   NULL,
        [ValidFrom]             DATE            NULL,
        [ValidTill]             DATE            NULL,
        [AMSVerified]           BIT             NOT NULL    CONSTRAINT [DF_CarpoolGroups_AMSVerified]         DEFAULT (0),
        [AMSDaysPresent]        INT             NULL,
        [TapInWindowMinutes]    INT             NOT NULL    CONSTRAINT [DF_CarpoolGroups_TapInWindowMinutes]  DEFAULT (5),
        [TapOutWindowMinutes]   INT             NOT NULL    CONSTRAINT [DF_CarpoolGroups_TapOutWindowMinutes] DEFAULT (5),

        CONSTRAINT [PK_CarpoolGroups]                   PRIMARY KEY CLUSTERED ([Id] ASC),

        CONSTRAINT [UQ_CarpoolGroups_RequestId]         UNIQUE ([RequestId]),

        CONSTRAINT [FK_CarpoolGroups_Requests]          FOREIGN KEY ([RequestId])
            REFERENCES [dbo].[Requests] ([Id]),

        CONSTRAINT [FK_CarpoolGroups_Employees_Owner]   FOREIGN KEY ([VehicleOwnerEmpId])
            REFERENCES [dbo].[Employees] ([Id]),

        CONSTRAINT [CK_CarpoolGroups_TotalMembers]      CHECK ([TotalMembers] >= 2)
    );

    CREATE NONCLUSTERED INDEX [IX_CarpoolGroups_RequestId]
        ON [dbo].[CarpoolGroups] ([RequestId]);

    CREATE NONCLUSTERED INDEX [IX_CarpoolGroups_VehicleOwnerEmpId]
        ON [dbo].[CarpoolGroups] ([VehicleOwnerEmpId]);
END;
GO

PRINT 'Table [dbo].[CarpoolGroups] ensured.';
GO
