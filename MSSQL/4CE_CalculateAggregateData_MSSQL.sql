--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: CalculateAggregateData
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_CalculateAggregateData
AS
BEGIN

SET NOCOUNT ON;


-- Clear the existing patient data
truncate table dbo.FourCE_SharedAggregateData;


--##############################################################################
--##############################################################################
--### Calculate the aggreate data
--##############################################################################
--##############################################################################

insert into dbo.FourCE_SharedAggregateData (
		site_id, concept_type, concept_code, units, 
		num_patients, num_records, 
		min_start_date, max_start_date, 
		min_value_num, max_value_num, mean_value_num, stdev_value_num, 
		count_distinct_value_char, 
		max_local_code_name
	)
	select site_id, concept_type, concept_code, value_units,
		count(distinct patient_num) num_patients,
		count(*) num_records,
		min(start_date) min_start_date,
		max(start_date) max_start_date,
		isnull(min(nullif(value_num,'-999')),'-999') min_value_num,
		isnull(max(nullif(value_num,'-999')),'-999') max_value_num,
		isnull(avg(nullif(value_num,'-999')),'-999') avg_value_num,
		isnull(stdev(nullif(value_num,'-999')),'-999') stdev_value_num,
		isnull(count(distinct nullif(value_char,'@')),0) count_distinct_value_char,
		isnull(max(nullif(local_code_name,'@')),'@') max_local_code_name
	from dbo.FourCE_LocalPatientData
	group by site_id, concept_type, concept_code, value_units;


--##############################################################################
--##############################################################################
--### Apply optional obfuscation
--##############################################################################
--##############################################################################

--------------------------------------------------------------------------------
-- Blur counts (based on Box-Muller Transform code by Darren Henderson
--------------------------------------------------------------------------------
declare @ObfuscationSmallCountBlur int
select @ObfuscationSmallCountBlur=cast(value_num as float)
	from dbo.FourCE_LocalPatientData 
	where concept_type='4CE-SITE' and concept_code='ObfuscationBlur';
if @ObfuscationSmallCountBlur>0
begin
	update dbo.FourCE_SharedAggregateData
		set num_patients = (
				select (case when rg<0 then 0 else rg end)
				from (
					select -- Convert to a Gaussian using Box-Muller Transform
						floor( 0.5 + num_patients + (sqrt(-2.0*log(r1)) * cos(2*pi()*r2) * @ObfuscationSmallCountBlur)) rg
					from (
						select -- Get two random numbers >0 and <=1
							abs(isnull(nullif(binary_checksum(newid()),0),1)/2147483648.0) r1,
							abs(isnull(nullif(binary_checksum(newid()),0),1)/2147483648.0) r2
					) t
				) t
			),
			num_records = (
				select (case when rg<0 then 0 else rg end)
				from (
					select -- convert to a gaussian using box-muller transform
						floor( 0.5 + num_records + (sqrt(-2.0*log(r1)) * cos(2*pi()*r2) * @ObfuscationSmallCountBlur)) rg
					from (
						select -- get two random numbers >0 and <=1
							abs(isnull(nullif(binary_checksum(newid()),0),1)/2147483648.0) r1,
							abs(isnull(nullif(binary_checksum(newid()),0),1)/2147483648.0) r2
					) t
				) t
			);
end;

--------------------------------------------------------------------------------
-- Delete small counts
--------------------------------------------------------------------------------
declare @ObfuscationSmallCountDelete int
select @ObfuscationSmallCountDelete=cast(value_num as int)
	from dbo.FourCE_LocalPatientData 
	where concept_type='4CE-SITE' and concept_code='ObfuscationSmallCountDelete';
if @ObfuscationSmallCountDelete>=0
begin
	delete 
		from dbo.FourCE_SharedAggregateData
		where num_patients<@ObfuscationSmallCountDelete;
end;

--------------------------------------------------------------------------------
-- Replace small counts with -99
--------------------------------------------------------------------------------
declare @ObfuscationSmallCountMask int
select @ObfuscationSmallCountMask=cast(value_num as int)
	from dbo.FourCE_LocalPatientData 
	where concept_type='4CE-SITE' and concept_code='ObfuscationSmallCountMask';
if @ObfuscationSmallCountMask>=0
begin
	update dbo.FourCE_SharedAggregateData
		set num_patients=-99, num_records=-99, 
			min_start_date='1900-01-01', max_start_date='1900-01-01',
			min_value_num=-99, max_value_num=-99, mean_value_num=-99, stdev_value_num=-99,
			count_distinct_value_char=-99
		where num_patients<@ObfuscationSmallCountMask;
end;


--##############################################################################
--##############################################################################
--### Testing
--##############################################################################
--##############################################################################

/*

select top 1000 * 
	from dbo.FourCE_SharedAggregateData
	where concept_type not in ('4CE-DIAG-ICD9','4CE-DIAG-ICD10');

select concept_type, count(*) n 
	from dbo.FourCE_SharedAggregateData 
	group by concept_type;

select top 1000 * 
	from dbo.FourCE_LocalPatientData;

*/



END;
GO
