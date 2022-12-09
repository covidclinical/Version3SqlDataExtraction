--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: GetPatientData
--### Date: December 8, 2022
--### Database: Microsoft SQL Server
--### Data Model: i2b2
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################



--##############################################################################
--##############################################################################
--### 4CE-SITE (Site-level variables)
--##############################################################################
--##############################################################################

insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', -999, '4CE-SITE', 'SiteID', '1900-01-01', '1900-01-01', -999, 'MySite', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'SourceDataUpdateDate', GetDate(), '1900-01-01', -999, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'PatientLevelFileCreateDate', GetDate(), '1900-01-01', -999, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'ObfuscationSmallCountMask', '1900-01-01', '1900-01-01', 3, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'ICUDataAvailable', '1900-01-01', '1900-01-01', -999, 'N', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'DeathDataAvailable', '1900-01-01', '1900-01-01', -999, 'N', '@', '@'


--##############################################################################
--##############################################################################
--### 4CE-SAMPLING_GROUP (Sampling groups and site to which patients are assigned)
--##############################################################################
--##############################################################################

-- 4CE-SAMPLING_GROUP
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-SAMPLING-GROUP', sampling_group, sampled_date, '1900-01-01', -999, '@', '@', '@'
	from dbo.FourCE_SamplingGroupPatients


--##############################################################################
--##############################################################################
--### 4CE-DEM (Demographics)
--##############################################################################
--##############################################################################

-- 4CE-DEM: AgeInYears
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-DEM', 'AgeInYears', '1900-01-01', '1900-01-01', age_in_years_num, '@', '@', '@'
		from dbo.patient_dimension with (nolock)
		where age_in_years_num is not null
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: Sex
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', p.patient_num, '4CE-DEM', 'Sex', '1900-01-01', '1900-01-01', -999, (case when m.concept_code='Sex:Female' then 'Female' else 'Male' end), '@', m.local_code
		from dbo.patient_dimension p with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(p.sex_cd)=m.local_code and m.concept_type='4CE-DEM' and m.concept_code in ('Sex:Female','Sex:Male')
		where p.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: ZipCode
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-DEM', 'ZipCode', '1900-01-01', '1900-01-01', -999, zip_cd, '@', '@'
		from dbo.patient_dimension with (nolock)
		where zip_cd is not null
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: Deceased
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-DEM', 'Deceased', '1900-01-01', '1900-01-01', -999, 'Y', '@', '@'
		from dbo.patient_dimension with (nolock)
		where death_date is not null
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: DateOfDeath
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-DEM', 'DateOfDeath', death_date, '1900-01-01', -999, '@', '@', '@'
		from dbo.patient_dimension with (nolock)
		where death_date is not null
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);
			
--------------------------------------------------------------------------------
-- Demographic Categories
--------------------------------------------------------------------------------

-- 4CE-DEM: Sex (Female or Male)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, concept_type, 'Sex:'+value_char, start_date, end_date, value_num, value_char, value_units, local_code_name
		from dbo.FourCE_LocalPatientData
		where concept_type='4CE-DEM' and concept_code='Sex'

-- 4CE-DEM: Age (Age Groups)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, concept_type, 
			'AgeInYears:'+(case 
				when value_num=-999 then 'X'
				when value_num<0 then 'L'
				when value_num>=0 and value_num<18 then '0to17'
				when value_num>=18 and value_num<65 then '18to64'
				else '65plus'
				end),
			start_date, end_date, value_num, value_char, value_units, local_code_name
		from dbo.FourCE_LocalPatientData
		where concept_type='4CE-DEM' and concept_code='AgeInYears'


--##############################################################################
--##############################################################################
--### 4CE-VISIT (Visits)
--##############################################################################
--##############################################################################

-- 4CE-VISIT: Inpatient
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', v.patient_num, '4CE-VISIT', 'Inpatient', v.start_date, isnull(v.end_date,'1900-01-01'), -999, '@', '@', m.local_code
		from dbo.visit_dimension v with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(v.inout_cd)=m.local_code and m.concept_type='4CE-VISIT' and m.concept_code='Inpatient'
		where v.start_date is not null
			and v.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-VISIT: ED
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', v.patient_num, '4CE-VISIT', 'ED', v.start_date, isnull(v.end_date,'1900-01-01'), -999, '@', '@', m.local_code
		from dbo.visit_dimension v with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(v.inout_cd)=m.local_code and m.concept_type='4CE-VISIT' and m.concept_code='ED'
		where v.start_date is not null
			and v.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-VISIT: OtherVisit
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-VISIT', 'OtherVisit', start_date, isnull(end_date,'1900-01-01'), -999, '@', '@', inout_cd
		from dbo.visit_dimension with (nolock)
		where inout_cd<>'@'
			and upper(inout_cd) not in (select local_code from dbo.FourCE_CodeMappings where concept_type='4CE-VISIT' and concept_code in ('Inpatient','ED'))
			and start_date is not null
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-VISIT: ICU
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-VISIT', 'ICU', start_date, isnull(end_date,'1900-01-01'), -999, '@', '@', m.local_code
		from dbo.visit_dimension v with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(v.location_cd)=m.local_code and m.concept_type='4CE-VISIT' and m.concept_code='ICU'
		where v.start_date is not null
			and v.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### 4CE-DIAG (Diagnoses, without prefix or periods)
--##############################################################################
--##############################################################################

-- 4CE-DIAG-ICD9
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-DIAG-ICD9', replace(substring(f.concept_cd,len(m.local_code)+1,50),'.',''), f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd like m.local_code+'%' and m.concept_type='4CE-PREFIX' and m.concept_code='DIAG-ICD9'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DIAG-ICD10
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-DIAG-ICD10', replace(substring(f.concept_cd,len(m.local_code)+1,50),'.',''), f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd like m.local_code+'%' and m.concept_type='4CE-PREFIX' and m.concept_code='DIAG-ICD10'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### 4CE-COVID-TEST (COVID-19 test results or diagnoses)
--##############################################################################
--##############################################################################

-- 4CE-COVID-TEST
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-COVID-TEST', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd like m.local_code+'%' and m.concept_type='4CE-COVID-TEST'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


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
	group by site_id, concept_type, concept_code, value_units


--##############################################################################
--##############################################################################
--### Testing
--##############################################################################
--##############################################################################

/*

select top 1000 * 
	from dbo.FourCE_SharedAggregateData
	where concept_type not in ('4CE-DIAG-ICD9','4CE-DIAG-ICD10')

select concept_type, count(*) n 
	from dbo.FourCE_SharedAggregateData 
	group by concept_type

select top 1000 * 
	from dbo.FourCE_LocalPatientData

*/

