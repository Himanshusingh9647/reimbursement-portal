/*  ============================================================
    Table :  dbo.RelocationExpenses
    Desc  :  Expense line-items (many-to-one) for a RelocationRequest.
    Deps  :  dbo.RelocationRequests
    ============================================================ */

IF OBJECT_ID(N'dbo.RelocationExpenses', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[RelocationExpenses]
    (
        [Id]                    INT             IDENTITY(1,1)   NOT NULL,
        [RelocationRequestId]   INT                             NOT NULL,
        [Category]              NVARCHAR(50)                    NOT NULL,
        [Description]           NVARCHAR(500)                   NULL,
        [Amount]                DECIMAL(18,2)                   NOT NULL,
        [HasBillDocument]       BIT             NOT NULL        CONSTRAINT [DF_RelocationExpenses_HasBill] DEFAULT (0),
        [BillDocument]          NVARCHAR(200)                   NULL,

        CONSTRAINT [PK_RelocationExpenses]
            PRIMARY KEY CLUSTERED ([Id]),

        CONSTRAINT [FK_RelocationExpenses_RelocationRequests]
            FOREIGN KEY ([RelocationRequestId])
            REFERENCES [dbo].[RelocationRequests] ([Id]),

        CONSTRAINT [CK_RelocationExpenses_Category]
            CHECK ([Category] IN (
                N'porter',
                N'brokerage',
                N'transport',
                N'packing',
                N'temporary-accommodation',
                N'other'
            ))
    );

    CREATE NONCLUSTERED INDEX [IX_RelocationExpenses_RelocationRequestId]
        ON [dbo].[RelocationExpenses] ([RelocationRequestId]);

    PRINT 'Table [dbo].[RelocationExpenses] created successfully.';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[RelocationExpenses] already exists — skipped.';
END
GO
