/*
  File:    05_TripExtensions.sql
  Object:  dbo.TripExtensions
  Purpose: Chained linked-list for trip extensions (self-referencing).
           Also adds deferred FK from TripRequests.LatestExtensionId → TripExtensions.Id.
  Depends: dbo.TripRequests
*/

-- ── 1. Create the TripExtensions table ──────────────────────────────────────

IF OBJECT_ID(N'dbo.TripExtensions', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[TripExtensions]
    (
        [Id]                    INT            IDENTITY(1,1)  NOT NULL,
        [TripRequestId]         INT            NOT NULL,
        [PreviousExtensionId]   INT            NULL,           -- self-ref → chain
        [RevisedEndDate]        DATE           NOT NULL,
        [RevisedDays]           INT            NOT NULL,
        [Reason]                NVARCHAR(500)  NULL,
        [HasApprovalDocument]   BIT            NOT NULL  DEFAULT (0),
        [ApprovalDocument]      NVARCHAR(200)  NULL,
        [Status]                NVARCHAR(20)   NOT NULL  DEFAULT 'pending',
            -- pending | approved | rejected
        [RequestedAt]           DATETIME2      NOT NULL  DEFAULT GETUTCDATE(),
        [ReviewedAt]            DATETIME2      NULL,

        CONSTRAINT [PK_TripExtensions]  PRIMARY KEY CLUSTERED ([Id]),

        CONSTRAINT [FK_TripExtensions_TripRequests]
            FOREIGN KEY ([TripRequestId])
            REFERENCES [dbo].[TripRequests] ([Id]),

        CONSTRAINT [FK_TripExtensions_PreviousExtension]
            FOREIGN KEY ([PreviousExtensionId])
            REFERENCES [dbo].[TripExtensions] ([Id])
    );

    -- Indexes
    CREATE NONCLUSTERED INDEX [IX_TripExtensions_TripRequestId]
        ON [dbo].[TripExtensions] ([TripRequestId]);

    CREATE NONCLUSTERED INDEX [IX_TripExtensions_Status]
        ON [dbo].[TripExtensions] ([Status]);

    PRINT 'Created table [dbo].[TripExtensions]';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[TripExtensions] already exists — skipped.';
END
GO

-- ── 2. Add deferred FK: TripRequests.LatestExtensionId → TripExtensions.Id ──

IF NOT EXISTS (
    SELECT 1
    FROM   sys.foreign_keys
    WHERE  [name] = N'FK_TripRequests_LatestExtension'
)
BEGIN
    ALTER TABLE [dbo].[TripRequests]
        ADD CONSTRAINT [FK_TripRequests_LatestExtension]
            FOREIGN KEY ([LatestExtensionId])
            REFERENCES [dbo].[TripExtensions] ([Id]);

    PRINT 'Added FK [FK_TripRequests_LatestExtension] on TripRequests.LatestExtensionId';
END
ELSE
BEGIN
    PRINT 'FK [FK_TripRequests_LatestExtension] already exists — skipped.';
END
GO
