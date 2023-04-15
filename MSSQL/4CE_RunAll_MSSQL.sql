--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: RunAll
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_RunAll
	@FirstRun BIT = 0
AS
BEGIN

SET NOCOUNT ON;

/*
This stored procedure runs all the other procedures in the correct order.

The first time you run this, use: 
	exec dbo.usp_4CE_RunAll @FirstRun=1;

To later update patient data, use:
	exec dbo.usp_4CE_RunAll;

Note: You will need to customize the following procedures for your site:
1) usp_4CE_InsertCodeMappingsData
2) usp_4CE_GetAllPatients
3) usp_4CE_GetPatientData

You should not need to modify the other procedures.
*/

--------------------------------------------------------------------------------
-- These procedures run one time to setup the tables
--------------------------------------------------------------------------------
IF @FirstRun = 1
BEGIN
	exec dbo.usp_4CE_CreateTables;
	exec dbo.usp_4CE_InsertCodeMappingsData;
	exec dbo.usp_4CE_InsertSamplingGroupsData;
END;

--------------------------------------------------------------------------------
-- These procedures run each time you want to update patient data
--------------------------------------------------------------------------------
exec dbo.usp_4CE_GetAllPatients;
exec dbo.usp_4CE_SamplePatients;
exec dbo.usp_4CE_GetPatientData;
exec dbo.usp_4CE_CalculateDerivedData;
exec dbo.usp_4CE_CalculateAggregateData;


END;
GO
