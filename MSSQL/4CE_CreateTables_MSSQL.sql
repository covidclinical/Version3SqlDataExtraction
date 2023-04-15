--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: CreateTables
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_CreateTables
AS
BEGIN

SET NOCOUNT ON;


-- Drop existing tables.

if OBJECT_ID(N'dbo.FourCE_AllPatients', N'U') is not null drop table dbo.FourCE_AllPatients;
if OBJECT_ID(N'dbo.FourCE_AllPatientsHistory', N'U') is not null drop table dbo.FourCE_AllPatientsHistory;
if OBJECT_ID(N'dbo.FourCE_SamplingGroups', N'U') is not null drop table dbo.FourCE_SamplingGroups;
if OBJECT_ID(N'dbo.FourCE_SamplingGroupPatients', N'U') is not null drop table dbo.FourCE_SamplingGroupPatients;
if OBJECT_ID(N'dbo.FourCE_SampledPatients', N'U') is not null drop table dbo.FourCE_SampledPatients;
if OBJECT_ID(N'dbo.FourCE_CodeMappings', N'U') is not null drop table dbo.FourCE_CodeMappings;
if OBJECT_ID(N'dbo.FourCE_LocalPatientData', N'U') is not null drop table dbo.FourCE_LocalPatientData;
if OBJECT_ID(N'dbo.FourCE_SharedAggregateData', N'U') is not null drop table dbo.FourCE_SharedAggregateData;
if OBJECT_ID(N'dbo.FourCE_ConceptParentPath', N'U') is not null drop table dbo.FourCE_ConceptParentPath;


-- Create new tables.

create table dbo.FourCE_AllPatients (
	sampling_group varchar(50) not null,
	patient_num int not null
);

create table dbo.FourCE_AllPatientsHistory (
	sampling_group varchar(50) not null,
	patient_num int not null,
	added_date datetime not null,
	removed_date datetime
);

create table dbo.FourCE_SamplingGroups (
	sampling_group varchar(50) not null,
	initial_sample_size int not null,
	add_new_patients char(1) not null,
	last_sampled_date datetime,
	group_desc varchar(1000)
);

create table dbo.FourCE_SamplingGroupPatients (
	sampling_group varchar(50) not null,
	patient_num int not null,
	sampled_date datetime
);

create table dbo.FourCE_SampledPatients (
	patient_num int not null,
	study_id int not null
);

create table dbo.FourCE_CodeMappings (
	map_id int identity(1,1) not null,
	concept_type varchar(50) not null,
	concept_code varchar(50) not null,
	local_code varchar(50) not null,
	local_table varchar(100),
	local_field varchar(100),
	concept_units varchar(50),
	local_units varchar(50),
	scale_factor float,
	concept_code_name varchar(2000),
	local_code_name varchar(2000)
);

create table dbo.FourCE_LocalPatientData (
	row_id bigint identity(1,1) not null,
	site_id varchar(50) not null,
	patient_num int not null,
	concept_type varchar(50) not null,
	concept_code varchar(50) not null,
	start_date datetime not null,
	end_date datetime not null,
	value_num numeric(18,5) not null,
	value_char varchar(max) not null,
	value_units varchar(50) not null,
	local_code_name varchar(1000) not null
);

create table dbo.FourCE_SharedAggregateData (
	site_id varchar(50) not null,
	concept_type varchar(50) not null,
	concept_code varchar(50) not null,
	units varchar(50) not null,
	num_patients int not null,
	num_records int not null,
	min_start_date datetime not null,
	max_start_date datetime not null,
	min_value_num numeric(18,5) not null,
	max_value_num numeric(18,5) not null,
	mean_value_num numeric(18,5) not null,
	stdev_value_num numeric(18,5) not null,
	count_distinct_value_char int not null,
	max_local_code_name varchar(1000) not null
);


-- Add primary keys and indexes.

alter table dbo.FourCE_AllPatients add primary key (sampling_group, patient_num);
alter table dbo.FourCE_AllPatientsHistory add primary key (sampling_group, patient_num);
alter table dbo.FourCE_SamplingGroups add primary key (sampling_group);
alter table dbo.FourCE_SamplingGroupPatients add primary key (sampling_group, patient_num);
alter table dbo.FourCE_SampledPatients add primary key (patient_num);
alter table dbo.FourCE_CodeMappings add primary key (map_id);
alter table dbo.FourCE_LocalPatientData add primary key (row_id);
alter table dbo.FourCE_SharedAggregateData add primary key (site_id, concept_type, concept_code, units);

create nonclustered index idx_patient_concept on dbo.FourCE_LocalPatientData (patient_num, concept_type, concept_code, site_id);
create nonclustered index idx_concept_patient on dbo.FourCE_LocalPatientData (concept_type, concept_code, patient_num, site_id);

create nonclustered index idx_concept_to_local on dbo.FourCE_CodeMappings (concept_type, concept_code, local_code);


-- Create an optional table for i2b2 to expand concept codes.
create table dbo.FourCE_ConceptParentPath (
	parent_path varchar(700) not null,
	concept_cd varchar(50) not null
);
alter table #concept_parent_temp add primary key (parent_path,concept_cd);



END;
GO
