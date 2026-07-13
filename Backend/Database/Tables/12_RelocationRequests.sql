/*  ============================================================
    Table :  dbo.RelocationRequests
    Desc  :  One row per relocation request (1-to-1 with Requests).
    Deps  :  dbo.Requests
    ============================================================ */

IF OBJECT_ID(N'dbo.RelocationRequests', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RelocationRequests]
    (
        [Id]            INT             IDENTITY(1,1)   NOT NULL,
        [RequestId]     NVARCHAR(20)                    NOT NULL,
        [FromCity]      NVARCHAR(100)                   NOT NULL,
        [ToCity]        NVARCHAR(100)                   NOT NULL,
        [RelocDate]     DATE                            NOT NULL,
        [TeamName]      NVARCHAR(100)                   NULL,
        [TotalAmount]   DECIMAL(18,2)                   NULL,

        CONSTRAINT [PK_RelocationRequests]
            PRIMARY KEY CLUSTERED ([Id]),

        CONSTRAINT [UQ_RelocationRequests_RequestId]
            UNIQUE ([RequestId]),

        CONSTRAINT [FK_RelocationRequests_Requests]
            FOREIGN KEY ([RequestId])
            REFERENCES [dbo].[Requests] ([Id])
    );

    CREATE NONCLUSTERED INDEX [IX_RelocationRequests_RequestId]
        ON [dbo].[RelocationRequests] ([RequestId]);

    PRINT 'Table [dbo].[RelocationRequests] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[RelocationRequests] already exists — skipped.';
END
GO
