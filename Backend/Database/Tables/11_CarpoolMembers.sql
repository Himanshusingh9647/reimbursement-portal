-- =============================================
-- Table:   [dbo].[CarpoolMembers]
-- Desc:    One row per member in a carpool group.
--          Stores pickup address, lat/lng for
--          metro proximity checks, and computed
--          nearest metro station with distance.
-- Depends: [dbo].[CarpoolGroups], [dbo].[Employees]
-- =============================================

IF OBJECT_ID(N'dbo.CarpoolMembers', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[CarpoolMembers]
    (
        [Id]                    INT             IDENTITY(1,1)   NOT NULL,
        [CarpoolGroupId]        INT             NOT NULL,
        [EmpId]                 NVARCHAR(20)    NOT NULL,
        [EmployeeType]          NVARCHAR(20)    NOT NULL,
        [PickupAddress]         NVARCHAR(500)   NOT NULL,
        [Latitude]              DECIMAL(10,7)   NULL,
        [Longitude]             DECIMAL(10,7)   NULL,
        [NearestMetroStation]   NVARCHAR(200)   NULL,
        [MetroDistanceKm]       DECIMAL(5,2)    NULL,

        CONSTRAINT [PK_CarpoolMembers]                          PRIMARY KEY CLUSTERED ([Id] ASC),

        CONSTRAINT [UQ_CarpoolMembers_Group_Emp]                UNIQUE ([CarpoolGroupId], [EmpId]),

        CONSTRAINT [FK_CarpoolMembers_CarpoolGroups]            FOREIGN KEY ([CarpoolGroupId])
            REFERENCES [dbo].[CarpoolGroups] ([Id]),

        CONSTRAINT [FK_CarpoolMembers_Employees]                FOREIGN KEY ([EmpId])
            REFERENCES [dbo].[Employees] ([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_CarpoolMembers_CarpoolGroupId]
        ON [dbo].[CarpoolMembers] ([CarpoolGroupId]);

    CREATE NONCLUSTERED INDEX [IX_CarpoolMembers_EmpId]
        ON [dbo].[CarpoolMembers] ([EmpId]);
END;
GO

PRINT 'Table [dbo].[CarpoolMembers] ensured.';
GO
