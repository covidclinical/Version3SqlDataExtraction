--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: GetAllPatients
--### Date: December 8, 2022
--### Database: Microsoft SQL Server
--### Data Model: i2b2
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


-- Get the list of patients who match the criteria for the sampling group AllPatientsSince2017
insert into dbo.FourCE_AllPatients (sampling_group, patient_num, added_date)
	select 'AllPatientsSince2017', patient_num, GetDate()
		from (
			select distinct patient_num
			from dbo.visit_dimension
			where inout_cd not in ('@')
				and start_date >= '2017-01-01'
		) t
		where patient_num not in (
			select patient_num
			from dbo.FourCE_AllPatients
			where sampling_group='AllPatientsSince2017'
		);


-- Get the list of patients who match the criteria for the sampling group AdmittedSince2017
insert into dbo.FourCE_AllPatients (sampling_group, patient_num, added_date)
	select 'AdmittedSince2017', patient_num, GetDate()
		from (
			select distinct patient_num
			from dbo.visit_dimension v
				inner join dbo.FourCE_CodeMappings m
					on upper(v.inout_cd)=m.local_code and m.concept_type='4CE-VISIT' and m.concept_code='Inpatient'
			where start_date >= '2017-01-01'
		) t
		where patient_num not in (
			select patient_num
			from dbo.FourCE_AllPatients
			where sampling_group='AdmittedSince2017'
		);


-- Get the list of patients who match the criteria for the sampling group CovidPositive
insert into dbo.FourCE_AllPatients (sampling_group, patient_num, added_date)
	select 'CovidPositive', patient_num, GetDate()
		from (
			select distinct patient_num
			from dbo.observation_fact f
				inner join dbo.FourCE_CodeMappings m
					on upper(f.concept_cd)=m.local_code and m.concept_type='4CE-COVID-TEST' and m.concept_code='CovidPCRPos'
		) t
		where patient_num not in (
			select patient_num
			from dbo.FourCE_AllPatients
			where sampling_group='CovidPositive'
		);


-- Get the list of patients who match the criteria for the sampling group MISC
insert into dbo.FourCE_AllPatients (sampling_group, patient_num, added_date)
	select 'MISC', patient_num, GetDate()
		from (
			-- Write a custom query to select MIS-C patients
			select -1 patient_num
			where 1=0
		) t
		where patient_num not in (
			select patient_num
			from dbo.FourCE_AllPatients
			where sampling_group='MISC'
		);

