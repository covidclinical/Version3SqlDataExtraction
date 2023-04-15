--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: GetAllPatients
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Data Model: i2b2
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_GetAllPatients
AS
BEGIN

SET NOCOUNT ON;


-- Clear the existing list of all patients
truncate table dbo.FourCE_AllPatients;


--##############################################################################
--##############################################################################
--### Get all patients who match the criteria for each sampling group
--##############################################################################
--##############################################################################


--------------------------------------------------------------------------------
-- AllPatientsSince2017
--------------------------------------------------------------------------------
insert into dbo.FourCE_AllPatients (sampling_group, patient_num)
	select 'AllPatientsSince2017', patient_num
		from (
			select distinct patient_num
			from dbo.visit_dimension
			where start_date >= '2017-01-01'
				and inout_cd not in ('@') -- Filter out dummy visits ("@")
		) t;


--------------------------------------------------------------------------------
-- AdmittedSince2017
--------------------------------------------------------------------------------
insert into dbo.FourCE_AllPatients (sampling_group, patient_num)
	select 'AdmittedSince2017', patient_num
		from (
			select distinct patient_num
			from dbo.visit_dimension v
				inner join dbo.FourCE_CodeMappings m
					on upper(v.inout_cd)=m.local_code 
						and m.concept_type='4CE-VISIT' 
						and m.concept_code='Inpatient'
			where start_date >= '2017-01-01'
		) t;


--------------------------------------------------------------------------------
-- CovidPositive
--------------------------------------------------------------------------------
insert into dbo.FourCE_AllPatients (sampling_group, patient_num)
	select 'CovidPositive', patient_num
		from (
			select distinct patient_num
			from dbo.observation_fact f
				inner join dbo.FourCE_CodeMappings m
					on upper(f.concept_cd)=m.local_code 
						and m.concept_type='4CE-COVID-TEST' 
						and m.concept_code='CovidPCRPos'
		) t;


--------------------------------------------------------------------------------
-- MISC (MIS-C)
--------------------------------------------------------------------------------
insert into dbo.FourCE_AllPatients (sampling_group, patient_num)
	select 'MISC', patient_num
		from (
			-- Write a custom query to select MIS-C patients
			select -1 patient_num
			where 1=0
		) t;



--##############################################################################
--##############################################################################
--### Update the AllPatientsHistory table based on new or removed patients
--##############################################################################
--##############################################################################



-- Add new patients who now meet the sampling group criteria for the first time
insert into dbo.FourCE_AllPatientsHistory (sampling_group, patient_num, added_date, removed_date)
	select sampling_group, patient_num, GetDate(), NULL
	from dbo.FourCE_AllPatients a
	where not exists (
		select patient_num
		from dbo.FourCE_AllPatientsHistory h
		where h.sampling_group=a.sampling_group and h.patient_num=a.patient_num
	);


-- Flag patients who no longer match the sampling group criteria as removed
update h
	set h.removed_date=GetDate()
	from dbo.FourCE_AllPatientsHistory h
	where h.removed_date is null
		and not exists (
			select *
			from dbo.FourCE_AllPatients a
			where a.sampling_group=h.sampling_group and a.patient_num=h.patient_num
	);


-- Add back patients who once again match the sampling group criteria
update h
	set h.removed_date=NULL
	from dbo.FourCE_AllPatientsHistory h
	where h.removed_date is not null
		and exists (
			select *
			from dbo.FourCE_AllPatients a
			where a.sampling_group=h.sampling_group and a.patient_num=h.patient_num
	);



END;
GO
