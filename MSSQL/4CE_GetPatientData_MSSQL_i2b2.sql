--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: GetPatientData
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Data Model: i2b2
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_GetPatientData
AS
BEGIN

SET NOCOUNT ON;


-- Clear the existing patient data
truncate table dbo.FourCE_LocalPatientData;


--##############################################################################
--##############################################################################
--### 4CE-SITE (Site-level variables)
--##############################################################################
--##############################################################################

insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	--Your site ID
	select 'MySite', -999, '4CE-SITE', 'SiteID', '1900-01-01', '1900-01-01', -999, 'MySite', '@', '@'
	--Database, data model, and SQL version (XX.YY.ZZ => ZZYYZZ; 3.0.0 => 30000)
	union all select 'MySite', -999, '4CE-SITE', 'Database', '1900-01-01', '1900-01-01', -999, 'Microsoft SQL Server', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'DataModel', '1900-01-01', '1900-01-01', -999, 'i2b2', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'SQLVersion', '1900-01-01', '1900-01-01', 30000, '@', '@', '@'
	--Dates (change the start_date of SourceDataUpdateDate if the data are not current)
	union all select 'MySite', -999, '4CE-SITE', 'SourceDataUpdateDate', GetDate(), '1900-01-01', -999, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'PatientLevelFileCreateDate', GetDate(), '1900-01-01', -999, '@', '@', '@'
	--Obfuscation parameters for aggregate results
	union all select 'MySite', -999, '4CE-SITE', 'ObfuscationSmallCountMask', '1900-01-01', '1900-01-01', 3, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'ObfuscationSmallCountDelete', '1900-01-01', '1900-01-01', -999, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'ObfuscationBlur', '1900-01-01', '1900-01-01', 0, '@', '@', '@'
	--Flag to indicate whether the patient_num should be replaced by a random number (0=NO, 1=YES)
	union all select 'MySite', -999, '4CE-SITE', 'ReplacePatientNumWithStudyID', '1900-01-01', '1900-01-01', 0, '@', '@', '@'
	--Data are available at your site (0=NO, 1=YES)
	union all select 'MySite', -999, '4CE-SITE', 'DataAvailable:ICU', '1900-01-01', '1900-01-01', 0, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'DataAvailable:Death', '1900-01-01', '1900-01-01', 0, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'DataAvailable:Race', '1900-01-01', '1900-01-01', 0, '@', '@', '@'
	union all select 'MySite', -999, '4CE-SITE', 'DataAvailable:Ethnicity', '1900-01-01', '1900-01-01', 0, '@', '@', '@'
	;


--##############################################################################
--##############################################################################
--### 4CE-SAMPLING_GROUP (Sampling groups and site to which patients are assigned)
--##############################################################################
--##############################################################################

-- 4CE-SAMPLING_GROUP
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', s.patient_num, '4CE-SAMPLING-GROUP', s.sampling_group, s.sampled_date, isnull(h.removed_date,'1900-01-01'), -999, '@', '@', '@'
	from dbo.FourCE_SamplingGroupPatients s
		inner join dbo.FourCE_AllPatientsHistory h
			on s.sampling_group=h.sampling_group and s.patient_num=h.patient_num


--##############################################################################
--##############################################################################
--### 4CE-DEM (Demographics)
--##############################################################################
--##############################################################################

-- 4CE-DEM: AgeInYears (number as the value)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-DEM', 'AgeInYears', '1900-01-01', '1900-01-01', age_in_years_num, '@', '@', '@'
		from dbo.patient_dimension with (nolock)
		where age_in_years_num is not null
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: Sex (Female)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', p.patient_num, '4CE-DEM', 'Sex:Female', '1900-01-01', '1900-01-01', -999, '@', '@', m.local_code
		from dbo.patient_dimension p with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(p.sex_cd)=m.local_code and m.concept_type='4CE-DEM' and m.concept_code='Sex:Female'
		where p.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: Sex (Male)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', p.patient_num, '4CE-DEM', 'Sex:Male', '1900-01-01', '1900-01-01', -999, '@', '@', m.local_code
		from dbo.patient_dimension p with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(p.sex_cd)=m.local_code and m.concept_type='4CE-DEM' and m.concept_code='Sex:Male'
		where p.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-DEM: Deceased (date of death as the start_date)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-DEM', 'Deceased', isnull(death_date,'1900-01-01'), '1900-01-01', -999, isnull(vital_status_cd,'@'), '@', '@'
		from dbo.patient_dimension with (nolock)
		where (death_date is not null or vital_status_cd<>'')
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients);

--------------------------------------------------------------------------------
-- Zip Codes (US Only)
--------------------------------------------------------------------------------

-- 4CE-DEM: ZipCode (5-digit as the value_char to keep leading zeros)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	-- From the patient_dimension table
	select 'MySite', patient_num, '4CE-DEM', 'ZipCode', '1900-01-01', '1900-01-01', -999, zip_cd, '@', '@'
		from dbo.patient_dimension with (nolock)
		where zip_cd like '[0-9][0-9][0-9][0-9][0-9]'
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	-- From the observation_fact table
	union all
	select 'MySite', f.patient_num, '4CE-DEM', 'ZipCode', f.start_date, isnull(f.end_date,'1900-01-01'), -999, substring(f.concept_cd,len(m.local_code)+1,50), '@', '@'
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd like m.local_code+'%' and m.concept_type='4CE-PREFIX' and m.concept_code='DEM-ZIPCODE'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	;

-- 4CE-DEM: ZipCode (3-digit as the value_char to keep leading zeros)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	-- From the patient_dimension table
	select 'MySite', patient_num, '4CE-DEM', 'Zip3', '1900-01-01', '1900-01-01', -999, zip_cd, '@', '@'
		from dbo.patient_dimension with (nolock)
		where zip_cd like '[0-9][0-9][0-9]'
			and patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	-- From the observation_fact table
	union all
	select 'MySite', f.patient_num, '4CE-DEM', 'Zip3', f.start_date, isnull(f.end_date,'1900-01-01'), -999, substring(f.concept_cd,len(m.local_code)+1,50), '@', '@'
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd like m.local_code+'%' and m.concept_type='4CE-PREFIX' and m.concept_code='DEM-ZIP3'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	;


--##############################################################################
--##############################################################################
--### 4CE-RACE-ETHNICITY (Optional Race and Ethnicity)
--##############################################################################
--##############################################################################


-- 4CE-RACE-ETHNICITY
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	-- From the patient_dimension table
	select 'MySite', patient_num, '4CE-RACE-ETHNICITY', concept_code, '1900-01-01', '1900-01-01', -999, '@', '@', m.local_code
		from dbo.patient_dimension p with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on p.race_cd=m.local_code and m.concept_type='4CE-RACE-ETHNICITY' and m.local_table='patient_dimension'
		where p.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	-- From the observation_fact table
	union all
	select 'MySite', f.patient_num, '4CE-RACE-ETHNICITY', concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', m.local_code
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-RACE-ETHNICITY' and m.local_table='observation_fact'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	;



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
	-- From the visit_dimension table
	select 'MySite', patient_num, '4CE-VISIT', 'ICU', start_date, isnull(end_date,'1900-01-01'), -999, '@', '@', m.local_code
		from dbo.visit_dimension v with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on upper(v.location_cd)=m.local_code and m.concept_type='4CE-VISIT' and m.concept_code='ICU' and m.local_table='visit_dimension'
		where v.start_date is not null
			and v.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	-- From the observation_fact table
	union all
	select 'MySite', f.patient_num, '4CE-VISIT', 'ICU', f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', m.local_code
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-VISIT' and m.concept_code='ICU' and m.local_table='observation_fact'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
	;


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
--### 4CE-LAB-LOINC
--##############################################################################
--##############################################################################

-- 4CE-LAB-LOINC (note the join on units and the use of a scale factor to convert to standard units used by 4CE)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-LAB-LOINC', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), 
			isnull(f.nval_num*isnull(m.scale_factor,1),-999), '@', m.concept_units, isnull(m.local_code_name,'@')
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-LAB-LOINC'
					and m.local_units=isnull(f.units_cd,'DEFAULT')
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### 4CE-LAB-LOINC
--##############################################################################
--##############################################################################

-- 4CE-VITAL-SIGN (note the join on units and the use of a scale factor to convert to standard units used by 4CE)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-VITAL-SIGN', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), 
			isnull(f.nval_num*isnull(m.scale_factor,1),-999), '@', m.concept_units, isnull(m.local_code_name,'@')
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-VITAL-SIGN'
					and m.local_units=isnull(f.units_cd,'DEFAULT')
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### 4CE-MED-CLASS
--##############################################################################
--##############################################################################

-- 4CE-MED-CLASS
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-MED-CLASS', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-MED-CLASS'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### 4CE-PROC-GROUP
--##############################################################################
--##############################################################################

-- 4CE-PROC-GROUP
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-PROC-GROUP', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-PROC-GROUP'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### 4CE-COVID
--##############################################################################
--##############################################################################

-- 4CE-COVID-DIAG (CovidU071, CovidU072)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-PROC-GROUP', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-COVID-DIAG'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


-- 4CE-COVID-TEST (CovidPCRPos, CovidPCRNeg, CovidAntibodyPos, CovidAntibodyNeg, UnknownTyoePos, UnknownTypeNeg)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-COVID-TEST', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-COVID-TEST'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-COVID-TEST (Based on lab result, add "Pos" or "Neg" to end of concept_code)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-COVID-TEST', 
			m.concept_code+(case when f.tval_char in ('POS','POSITIVE') then 'Pos' else 'Ned' end), 
			f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-COVID-TEST' and m.concept_code in ('CovidPCR','CovidAntibody')
		where f.tval_char in ('POS','POSITIVE','NEG','NEGATIVE')
			and f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-COVID-VACCINE (Each vaccination date and type: Pfizer, Moderna, Janssen, OtherUnknown)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-COVID-VACCINE', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-COVID-VACCINE'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-COVID-NOTVAC (Not vaccinated: Z28.310, Z28.311)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-COVID-NOTVAC', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-COVID-NOTVAC'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-OTHER-VACCINE (Such as Influenza)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-OTHER-VACCINE', m.concept_code, f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-OTHER-VACCINE'
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);

-- 4CE-OTHER-TEST (Such as Influenza, based on lab result, add "Pos" or "Neg" to end of concept_code)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-OTHER-TEST', 
			m.concept_code+(case when f.tval_char in ('POS','POSITIVE') then 'Pos' else 'Ned' end), 
			f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-OTHER-TEST'
		where f.tval_char in ('POS','POSITIVE','NEG','NEGATIVE')
			and f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);
		

--##############################################################################
--##############################################################################
--### 4CE-VITAL-SIGN
--##############################################################################
--##############################################################################

-- 4CE-VITAL-SIGN (HeightCM - height in centimeters; multiply by 2.54 to convert inches to cm)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-VITAL-SIGN', 'HeightCM', f.start_date, isnull(f.end_date,'1900-01-01'), 
			isnull(f.nval_num*isnull(m.scale_factor,1),-999), '@', 'cm', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-VITAL-SIGN' and m.concept_code='HeightCM'
					and m.local_units=isnull(f.units_cd,'DEFAULT')
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);
			
-- 4CE-VITAL-SIGN (WeightKG - weight in kilograms; multiply by 0.453592 to convert pounds to kilograms)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-VITAL-SIGN', 'WeightKG', f.start_date, isnull(f.end_date,'1900-01-01'), 
			isnull(f.nval_num*isnull(m.scale_factor,1),-999), '@', 'kg', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-VITAL-SIGN' and m.concept_code='WeightKG'
					and m.local_units=isnull(f.units_cd,'DEFAULT')
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);
			
-- 4CE-VITAL-SIGN (BMI - body mass index in kg/m2)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-VITAL-SIGN', 'BMI', f.start_date, isnull(f.end_date,'1900-01-01'), 
			isnull(f.nval_num*isnull(m.scale_factor,1),-999), '@', 'kg/m2', f.concept_cd
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code and m.concept_type='4CE-VITAL-SIGN' and m.concept_code='BMI'
					and m.local_units=isnull(f.units_cd,'DEFAULT')
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients);


--##############################################################################
--##############################################################################
--### Other data you have about the patients
--##############################################################################
--##############################################################################

-- Other data from the observation_fact table using concepts loaded in the CodeMappings table
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, m.concept_type, m.concept_code, f.start_date, 
			isnull(f.end_date,'1900-01-01'),
			isnull(f.nval_num*isnull(scale_factor,1),-999),
			isnull(f.tval_char,-999), 
			isnull(f.units_cd,'@'),
			left(m.local_code_name,500)
		from dbo.observation_fact f with (nolock)
			inner join dbo.FourCE_CodeMappings m
				on f.concept_cd=m.local_code
		where f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
			and m.local_table='observation_fact'
			and m.concept_type in ('LAB-LOINC','MED-RxNorm','MED-ATC','PROC-CBHPM','PROC-CCAM','PROC-CPT','PROC-ICD10AM','PROC-ICD10PCS','PROC-ICD9','PROC-OPCS4','PROC-OPS','PROC-SNOMED','PROC-TOSP');
		
		
--##############################################################################
--##############################################################################
--### Custom site-specific SQL needed for these items (if available)
--##############################################################################
--##############################################################################

-- 4CE-COVID-MISC (Write a custom query for MIS-C)
/*
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', f.patient_num, '4CE-COVID-MISC', 'CovidMISC', f.start_date, isnull(f.end_date,'1900-01-01'), -999, '@', '@', f.concept_cd
		from dbo.observation_fact f with (nolock)
		where 1=0
			and f.start_date is not null
			and f.patient_num in (select patient_num from dbo.FourCE_SampledPatients)
			and f.concept_cd='MIS-C';
*/

-- 4CE-MRN (Optionally include patient MRN as the value_char to help with chart review and linkage)
/*
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select 'MySite', patient_num, '4CE-MRN', 'MRN', '1900-01-01', '1900-01-01', -999, '@', '@', '@'
		from dbo.FourCE_SampledPatients
		where 1=0;
*/



--##############################################################################
--##############################################################################
--### Optionally replace the patient_num with a random number
--##############################################################################
--##############################################################################

if exists (
	select * 
	from dbo.FourCE_LocalPatientData 
	where concept_type='4CE-SITE' and concept_code='ReplacePatientNumWithStudyID' and value_num=1
)
begin
	update p
		set p.patient_num=s.study_id
		from dbo.FourCE_LocalPatientData p
			inner join dbo.FourCE_SampledPatients s
				on p.patient_num=s.patient_num
		where s.study_id is not null;
end;





END;
GO
