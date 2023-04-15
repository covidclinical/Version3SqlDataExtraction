# Version3SqlDataExtraction
This repository contains SQL code to generate the LocalPatientData.csv and SharedAggregateData.csv files for 4CE Version 3.

The MSSQL folder contains scripts for Microsoft SQL Server.

STEP 1:

Run the following scripts, which create stored procedures:
1) 4CE_CreateTables
2) 4CE_InsertCodeMappingsData ***
3) 4CE_InsertSamplingGroupsData
4) 4CE_GetAllPatients ***
5) 4CE_SamplePatients
6) 4CE_GetPatientData ***
7) 4CE_CalculateDerivedData
8) 4CE_CalculateAggregateData
9) 4CE_RunAll

*** You will need to modify these files based on your data model and codes.

Note that a database name (e.g., "MSSQL"), and in some cases a data model (e.g., "i2b2"), are added to the end of each script's file name. Choose the appropriate version for your site.

STEP 2:

If this is your first time running the scripts, run:

exec dbo.usp_4CE_RunAll @FirstRun=1;

STEP 3:

Save the table FourCE_LocalPatientData to a CSV file named LocalPatientData.csv. NEVER SHARE THIS FILE!

Save the table FourCE_SharedAggregateData to a CSV file named SharedAggregateData.csv.

STEP 4:

To update the tables in the future with new patients and data, run:

exec dbo.usp_4CE_RunAll;
