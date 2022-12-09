# Version3SqlDataExtraction
This repository contains SQL code to generate the LocalPatientData.csv and SharedAggregateData.csv files for 4CE Version 3.

The MSSQL-i2b2 folder contains scripts for Microsoft SQL Server and the i2b2 data model.

Run the scripts in this order:
1) 4CE_CreateTables.sql
2) 4CE_InsertCodeMappingsData.sql
3) 4CE_InsertSamplingGroupsData.sql
4) 4CE_GetAllPatients.sql
5) 4CE_SamplePatients.sql
6) 4CE_GetPatientData.sql

Save the table FourCE_LocalPatientData to a CSV file named LocalPatientData.csv. NEVER SHARE THIS FILE!

Save the table FourCE_SharedAggregateData to a CSV file named SharedAggregateData.csv.
