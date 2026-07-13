/*
  File:    03_TripRequests.sql
  Object:  dbo.TripRequests
  Purpose: One row per business-travel request (domestic / international).
  Depends: dbo.Requests
*/

IF OBJECT_ID(N'dbo.TripRequests', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TripRequests]
    (
        [Id]                  INT            IDENTITY(1,1)  NOT NULL,
        [RequestId]           NVARCHAR(20)   NOT NULL,
        [Subtype]             NVARCHAR(20)   NOT NULL,          -- domestic | international
        [Destination]         NVARCHAR(100)  NULL,              -- city name
        [State]               NVARCHAR(100)  NULL,              -- state (domestic)
        [Region]              NVARCHAR(100)  NULL,              -- Area A / B / C (domestic)
        [Country]             NVARCHAR(100)  NULL,              -- country (international)
        [StartDate]           DATE           NOT NULL,
        [EndDate]             DATE           NOT NULL,
        [Days]                INT            NOT NULL,
        [Purpose]             NVARCHAR(1000) NULL,
        [TravelMode]          NVARCHAR(50)   NULL,              -- Air / Train / Bus
        [Stage]               NVARCHAR(30)   NOT NULL  DEFAULT 'pre-approval',
            -- pre-approval | document-review | extension-pending | settlement-pending | settlement-approved
        [LatestExtensionId]   INT            NULL,              -- FK added after TripExtensions is created

        CONSTRAINT [PK_TripRequests]            PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_TripRequests_RequestId]  UNIQUE ([RequestId]),

        CONSTRAINT [FK_TripRequests_Requests]
            FOREIGN KEY ([RequestId])
            REFERENCES [dbo].[Requests] ([Id])
    );

    -- Indexes
    CREATE NONCLUSTERED INDEX [IX_TripRequests_RequestId]
        ON [dbo].[TripRequests] ([RequestId]);

    CREATE NONCLUSTERED INDEX [IX_TripRequests_Stage]
        ON [dbo].[TripRequests] ([Stage]);

    PRINT 'Created table [dbo].[TripRequests]';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[TripRequests] already exists — skipped.';
END
GO
