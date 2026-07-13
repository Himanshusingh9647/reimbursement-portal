-- ============================================================
-- Reimbursement Portal — Seed Data (Normalized Schema)
-- Target: Microsoft SQL Server 2019+
-- Idempotent: safe to run multiple times
-- Run AFTER all table scripts (01–13)
-- ============================================================


-- ============================================================
-- 1. SEED EMPLOYEES
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'EMP001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'EMP001', N'Arjun Sharma', N'emp001', N'pass123', 0, 0, N'CL3', N'Technology', N'Software Engineer', N'arjun.sharma@company.com', N'Vikram Patel', N'AI', N'Orion');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'EMP002')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'EMP002', N'Priya Mehta', N'emp002', N'pass123', 0, 0, N'CL4', N'Operations', N'Associate', N'priya.mehta@company.com', N'Neha Gupta', N'AD', N'Mercury');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'EMP003')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'EMP003', N'Karan Singh', N'emp003', N'pass123', 0, 0, N'CL2', N'Sales', N'Senior Manager', N'karan.singh@company.com', N'Amit Joshi', N'QC', N'Atlas');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'FIN001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'FIN001', N'Rahul Verma', N'finance01', N'pass123', 1, 0, N'CL2', N'Finance', N'Finance Analyst', N'rahul.verma@company.com', N'Priya Das', N'Finance', N'Portal');

IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'ADM001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'ADM001', N'Sunita Rao', N'admin01', N'pass123', 1, 1, N'CL1', N'HR', N'HR Director', N'sunita.rao@company.com', NULL, N'HR', N'Corporate');

-- Intern for carpool testing
IF NOT EXISTS (SELECT 1 FROM [dbo].[Employees] WHERE [Id] = N'INT001')
    INSERT INTO [dbo].[Employees]
        ([Id], [Name], [Username], [PasswordHash], [HasFinanceAccess], [HasAdminAccess], [ClLevel], [Department], [Designation], [Email], [Manager], [Team], [Project])
    VALUES
        (N'INT001', N'Rohan Kapoor', N'intern01', N'pass123', 0, 0, N'CL4', N'Technology', N'Intern', N'rohan.kapoor@company.com', N'Arjun Sharma', N'AI', N'Orion');

PRINT 'Employees seeded.';
GO


-- ============================================================
-- 2. SEED: Business Travel (Completed — approved settlement)
-- ============================================================

-- Master request
IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0001')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt], [UpdatedAt])
    VALUES
        (N'REQ-2024-0001', N'EMP001', N'travel', N'Client meeting at Mumbai HQ', N'approved', '2024-03-10T10:00:00', '2024-03-20T14:30:00');

-- Trip details
IF NOT EXISTS (SELECT 1 FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0001')
    INSERT INTO [dbo].[TripRequests]
        ([RequestId], [Subtype], [Destination], [State], [Region], [StartDate], [EndDate], [Days], [Purpose], [TravelMode], [Stage])
    VALUES
        (N'REQ-2024-0001', N'domestic', N'Mumbai', N'Maharashtra', N'Area A', '2024-03-15', '2024-03-18', 4, N'Client meeting at Mumbai HQ', N'Air', N'settlement-approved');

-- Pre-approval (approved)
IF NOT EXISTS (SELECT 1 FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id WHERE tr.RequestId = N'REQ-2024-0001')
BEGIN
    DECLARE @trip1Id INT = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0001');
    INSERT INTO [dbo].[PreApprovals]
        ([TripRequestId], [Status], [KnoxApproval], [TravelInsurance], [ApprovedAt], [ReviewedBy])
    VALUES
        (@trip1Id, N'approved', N'knox_approval.pdf', N'insurance_cert.pdf', '2024-03-12T10:00:00', N'FIN001');
END;

-- Settlement (approved)
IF NOT EXISTS (SELECT 1 FROM [dbo].[Settlements] s INNER JOIN [dbo].[TripRequests] tr ON s.TripRequestId = tr.Id WHERE tr.RequestId = N'REQ-2024-0001')
BEGIN
    DECLARE @trip1IdS INT = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0001');
    INSERT INTO [dbo].[Settlements]
        ([TripRequestId], [Status], [HotelName], [HotelAmount], [PerDiemDays], [PerDiemRate], [PerDiemAmount], [TotalAmountINR], [BoardingPass], [TripReport], [SubmittedAt], [ReviewedAt])
    VALUES
        (@trip1IdS, N'approved', N'Grand Hyatt', 12000.00, 4, 1500.00, 6000.00, 22500.00, N'bp_mumbai.pdf', N'trip_report.pdf', '2024-03-19T10:00:00', '2024-03-20T14:30:00');
END;

PRINT 'Seed: Travel (completed) inserted.';
GO


-- ============================================================
-- 3. SEED: Business Travel (Pending pre-approval)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0005')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES
        (N'REQ-2024-0005', N'EMP001', N'travel', N'Quarterly review at Delhi office', N'pending', '2024-05-05T09:15:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0005')
    INSERT INTO [dbo].[TripRequests]
        ([RequestId], [Subtype], [Destination], [State], [Region], [StartDate], [EndDate], [Days], [Purpose], [TravelMode], [Stage])
    VALUES
        (N'REQ-2024-0005', N'domestic', N'Delhi', N'Delhi', N'Area A', '2024-05-10', '2024-05-14', 5, N'Quarterly review at Delhi office', N'Air', N'pre-approval');

IF NOT EXISTS (SELECT 1 FROM [dbo].[PreApprovals] pa INNER JOIN [dbo].[TripRequests] tr ON pa.TripRequestId = tr.Id WHERE tr.RequestId = N'REQ-2024-0005')
BEGIN
    DECLARE @trip2Id INT = (SELECT [Id] FROM [dbo].[TripRequests] WHERE [RequestId] = N'REQ-2024-0005');
    INSERT INTO [dbo].[PreApprovals]
        ([TripRequestId], [Status], [KnoxApproval], [TravelInsurance])
    VALUES
        (@trip2Id, N'pending', N'knox_delhi.pdf', N'travel_insurance.pdf');
END;

PRINT 'Seed: Travel (pending) inserted.';
GO


-- ============================================================
-- 4. SEED: Internet Bill (Pending — monthly, 3 periods)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0006')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES
        (N'REQ-2024-0006', N'EMP001', N'internet-bill', N'Internet Bill - Q1 2024', N'pending', '2024-04-01T08:00:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[InternetBillRequests] WHERE [RequestId] = N'REQ-2024-0006')
    INSERT INTO [dbo].[InternetBillRequests]
        ([RequestId], [Provider], [Frequency], [TotalAmount], [ClaimableAmount], [ReimbursedTillMonth])
    VALUES
        (N'REQ-2024-0006', N'Airtel Broadband', N'monthly', 2850.00, 2850.00, NULL);

IF NOT EXISTS (SELECT 1 FROM [dbo].[InternetBillPeriods] ibp INNER JOIN [dbo].[InternetBillRequests] ibr ON ibp.InternetBillRequestId = ibr.Id WHERE ibr.RequestId = N'REQ-2024-0006')
BEGIN
    DECLARE @inet1Id INT = (SELECT [Id] FROM [dbo].[InternetBillRequests] WHERE [RequestId] = N'REQ-2024-0006');
    INSERT INTO [dbo].[InternetBillPeriods] ([InternetBillRequestId], [PeriodLabel], [Amount], [BillDocument]) VALUES
        (@inet1Id, N'Month 1 (Jan)', 950.00, N'airtel_jan.pdf'),
        (@inet1Id, N'Month 2 (Feb)', 950.00, N'airtel_feb.pdf'),
        (@inet1Id, N'Month 3 (Mar)', 950.00, N'airtel_mar.pdf');
END;

PRINT 'Seed: Internet bill inserted.';
GO


-- ============================================================
-- 5. SEED: Carpooling (Approved)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0007')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt], [UpdatedAt])
    VALUES
        (N'REQ-2024-0007', N'EMP002', N'carpool', N'Carpool - Feb 2024', N'approved', '2024-03-01T07:30:00', '2024-03-05T11:00:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[CarpoolGroups] WHERE [RequestId] = N'REQ-2024-0007')
    INSERT INTO [dbo].[CarpoolGroups]
        ([RequestId], [VehicleOwnerEmpId], [VehicleNumber], [TotalMembers], [MetroCheckPassed], [IsActive], [MonthlyAmount], [ValidFrom], [ValidTill], [AMSVerified], [AMSDaysPresent])
    VALUES
        (N'REQ-2024-0007', N'EMP002', N'MH12AB1234', 2, 1, 1, 750.00, '2024-02-01', '2024-02-29', 1, 18);

IF NOT EXISTS (SELECT 1 FROM [dbo].[CarpoolMembers] cm INNER JOIN [dbo].[CarpoolGroups] cg ON cm.CarpoolGroupId = cg.Id WHERE cg.RequestId = N'REQ-2024-0007')
BEGIN
    DECLARE @cp1Id INT = (SELECT [Id] FROM [dbo].[CarpoolGroups] WHERE [RequestId] = N'REQ-2024-0007');
    INSERT INTO [dbo].[CarpoolMembers] ([CarpoolGroupId], [EmpId], [EmployeeType], [PickupAddress], [Latitude], [Longitude]) VALUES
        (@cp1Id, N'EMP002', N'full-time', N'Plot 42, Kothrud, Pune 411038', 18.5074, 73.8077),
        (@cp1Id, N'INT001', N'intern',    N'Lane 5, Karve Nagar, Pune 411052', 18.4920, 73.8170);
END;

PRINT 'Seed: Carpooling inserted.';
GO


-- ============================================================
-- 6. SEED: Relocation (Pending)
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM [dbo].[Requests] WHERE [Id] = N'REQ-2024-0008')
    INSERT INTO [dbo].[Requests]
        ([Id], [EmpId], [Type], [Title], [Status], [SubmittedAt])
    VALUES
        (N'REQ-2024-0008', N'EMP003', N'relocation', N'Relocation Pune → Bengaluru', N'pending', '2024-05-15T12:00:00');

IF NOT EXISTS (SELECT 1 FROM [dbo].[RelocationRequests] WHERE [RequestId] = N'REQ-2024-0008')
    INSERT INTO [dbo].[RelocationRequests]
        ([RequestId], [FromCity], [ToCity], [RelocDate], [TeamName], [TotalAmount])
    VALUES
        (N'REQ-2024-0008', N'Pune', N'Bengaluru', '2024-06-01', N'QC', 45000.00);

IF NOT EXISTS (SELECT 1 FROM [dbo].[RelocationExpenses] re INNER JOIN [dbo].[RelocationRequests] rr ON re.RelocationRequestId = rr.Id WHERE rr.RequestId = N'REQ-2024-0008')
BEGIN
    DECLARE @reloc1Id INT = (SELECT [Id] FROM [dbo].[RelocationRequests] WHERE [RequestId] = N'REQ-2024-0008');
    INSERT INTO [dbo].[RelocationExpenses] ([RelocationRequestId], [Category], [Description], [Amount], [BillDocument]) VALUES
        (@reloc1Id, N'transport', N'Flight Pune to Bengaluru', 8500.00, N'flight_blr.pdf'),
        (@reloc1Id, N'porter',    N'Movers and packers',       12000.00, N'packers_receipt.pdf'),
        (@reloc1Id, N'brokerage', N'Flat broker fee (1 month)', 15000.00, N'broker_receipt.pdf'),
        (@reloc1Id, N'packing',   N'Packing materials',         3500.00, N'packing_bill.pdf'),
        (@reloc1Id, N'temporary-accommodation', N'Hotel for 3 nights', 6000.00, N'hotel_temp.pdf');
END;

PRINT 'Seed: Relocation inserted.';
GO


PRINT '=== All seed data inserted successfully. ===';
GO
