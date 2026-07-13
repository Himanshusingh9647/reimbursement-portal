/*
  File:    04_PreApprovals.sql
  Object:  dbo.PreApprovals
  Purpose: One row per trip pre-approval (corporate approval + document review).
  Depends: dbo.TripRequests, dbo.Employees
*/

IF OBJECT_ID(N'dbo.PreApprovals', N'U') IS NULL
BEGIN
    CREATE TABLE [dbo].[PreApprovals]
    (
        [Id]                    INT            IDENTITY(1,1)  NOT NULL,
        [TripRequestId]         INT            NOT NULL,
        [Status]                NVARCHAR(20)   NOT NULL  CONSTRAINT [DF_PreApprovals_Status] DEFAULT ('pending'),
        [HasKnoxApproval]       BIT            NOT NULL  CONSTRAINT [DF_PreApprovals_HasKnox] DEFAULT (0),
        [KnoxApproval]          NVARCHAR(200)  NULL,
        [HasTravelInsurance]    BIT            NOT NULL  CONSTRAINT [DF_PreApprovals_HasInsurance] DEFAULT (0),
        [TravelInsurance]       NVARCHAR(200)  NULL,
        [HasPassportCopy]       BIT            NOT NULL  CONSTRAINT [DF_PreApprovals_HasPassport] DEFAULT (0),
        [PassportCopy]          NVARCHAR(200)  NULL,
        [HasVisa]               BIT            NOT NULL  CONSTRAINT [DF_PreApprovals_HasVisa] DEFAULT (0),
        [Visa]                  NVARCHAR(200)  NULL,
        [HasFlightTicket]       BIT            NOT NULL  CONSTRAINT [DF_PreApprovals_HasFlight] DEFAULT (0),
        [FlightTicket]          NVARCHAR(200)  NULL,
        [DocumentReviewStatus]  NVARCHAR(20)   NULL,
        [ApprovedAt]            DATETIME2      NULL,
        [ReviewedBy]            NVARCHAR(20)   NULL,

        CONSTRAINT [PK_PreApprovals]                PRIMARY KEY CLUSTERED ([Id]),
        CONSTRAINT [UQ_PreApprovals_TripRequestId]  UNIQUE ([TripRequestId]),

        CONSTRAINT [FK_PreApprovals_TripRequests]
            FOREIGN KEY ([TripRequestId])
            REFERENCES [dbo].[TripRequests] ([Id]),

        CONSTRAINT [FK_PreApprovals_Employees_ReviewedBy]
            FOREIGN KEY ([ReviewedBy])
            REFERENCES [dbo].[Employees] ([Id])
    );

    -- Index
    CREATE NONCLUSTERED INDEX [IX_PreApprovals_TripRequestId]
        ON [dbo].[PreApprovals] ([TripRequestId]);

    PRINT 'Created table [dbo].[PreApprovals]';
END
ELSE
BEGIN
    PRINT 'Table [dbo].[PreApprovals] already exists — skipped.';
END
GO
