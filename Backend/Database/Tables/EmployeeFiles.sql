CREATE TABLE EmployeeFiles (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    EmpId VARCHAR(50) NOT NULL,
    FileName VARCHAR(255) NOT NULL,
    FilePath VARCHAR(500) NOT NULL,
    FileType VARCHAR(50) NOT NULL, -- e.g., 'passport', 'boarding-pass', 'internet-bill', 'other'
    UploadedAt DATETIME DEFAULT GETUTCDATE()
);
GO

CREATE PROCEDURE sp_SaveEmployeeFile
    @EmpId VARCHAR(50),
    @FileName VARCHAR(255),
    @FilePath VARCHAR(500),
    @FileType VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO EmployeeFiles (EmpId, FileName, FilePath, FileType)
    VALUES (@EmpId, @FileName, @FilePath, @FileType);
END
GO

CREATE PROCEDURE sp_GetEmployeeFilesByEmpId
    @EmpId VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        Id,
        EmpId,
        FileName,
        FilePath,
        FileType,
        UploadedAt
    FROM EmployeeFiles
    WHERE EmpId = @EmpId
    ORDER BY UploadedAt DESC;
END
GO
