# Version3SqlDataExtraction

This repository contains SQL scripts to generate the LocalPatientData.csv and SharedAggregateData.csv files for 4CE Version 3.

**IMPORTANT**: 4CE sites are not expected to run these scripts yet. We are providing the scripts so that sites can preview them and offer feedback and suggestions. Additional clinical variables (Common Data Elements, or CDEs) will be added to the scripts before they are finalized.


## Introduction


Thes SQL scripts in this repository generate a database table named FourCE_LocalPatientData. This table contains, in one location, all the data needed for 4CE studies. It is based on the i2b2 observation_fact table, where each row represents a clinical "observation" of a patient. The table is exported to a comma separated values (CSV) file named LocalPatientData.csv, which is used by 4CE R scripts. Never share this file outside your institution!

The SQL scripts also (1) maps local codes in your database to standard 4CE comon data elements (CDEs); (2) selects groups of patients relevant to 4CE studies (e.g., patients with COVID-19); (3) randomly samples subsets of those patients for analysis; and (4) creates a summary table (FourCE_SharedAggregateData) with aggregate counts and statistics about the types of data that were collected.

The current SQL scripts are written for Microsoft SQL Server and optimized for the i2b2 data model. However, there will also be an Oracle version of the final scripts. A set of OMOP-to-i2b2 database views will also be available to assist sites using the OMOP data model.


## Instructions


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
