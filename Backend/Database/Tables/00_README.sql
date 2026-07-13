-- ============================================================
-- Reimbursement Portal — Master Schema Runner
-- Run this file to create all tables in dependency order.
-- Target: Microsoft SQL Server 2019+
-- ============================================================

-- Run each table script in dependency order:
--   01 → Employees         (no deps)
--   02 → Requests          (→ Employees)
--   03 → TripRequests      (→ Requests)
--   04 → PreApprovals      (→ TripRequests, Employees)
--   05 → TripExtensions    (→ TripRequests, self-ref) + ALTER TripRequests FK
--   06 → Settlements       (→ TripRequests)
--   07 → LocalConveyances  (→ Settlements)
--   08 → InternetBillReqs  (→ Requests)
--   09 → InternetBillPers  (→ InternetBillRequests)
--   10 → CarpoolGroups     (→ Requests, Employees)
--   11 → CarpoolMembers    (→ CarpoolGroups, Employees)
--   12 → RelocationReqs    (→ Requests)
--   13 → RelocationExpenses(→ RelocationRequests)

-- NOTE: In SSMS, open each file via :r or run them manually
--       in the numbered order above.
--       If using sqlcmd, you can use:
--         sqlcmd -S localhost -d YourDB -i Tables\01_Employees.sql
--         sqlcmd -S localhost -d YourDB -i Tables\02_Requests.sql
--         ... etc.

PRINT '=== Run table scripts 01 through 13 in order ===';
PRINT '';
PRINT 'Table dependency graph:';
PRINT '';
PRINT '  Employees';
PRINT '    └── Requests';
PRINT '          ├── TripRequests';
PRINT '          │     ├── PreApprovals';
PRINT '          │     ├── TripExtensions (chained, self-ref)';
PRINT '          │     └── Settlements';
PRINT '          │           └── LocalConveyances (1:many)';
PRINT '          ├── InternetBillRequests';
PRINT '          │     └── InternetBillPeriods (1:many)';
PRINT '          ├── CarpoolGroups';
PRINT '          │     └── CarpoolMembers (1:many)';
PRINT '          └── RelocationRequests';
PRINT '                └── RelocationExpenses (1:many)';
PRINT '';
PRINT '=== Execute each file in Tables\ folder in order ===';
GO
