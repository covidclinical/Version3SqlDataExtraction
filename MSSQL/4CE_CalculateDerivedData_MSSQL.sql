--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: CalculateDerivedData
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_CalculateDerivedData
AS
BEGIN

SET NOCOUNT ON;


--##############################################################################
--##############################################################################
--### Visit summary information
--##############################################################################
--##############################################################################

-- Clear existing derived data
delete from dbo.FourCE_LocalPatientData
	where concept_type in ('4CE-VISIT-SUMMARY');

-- Get the earliest start and latest end dates of all visits, and the number of visits, by visit type
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, '4CE-VISIT-SUMMARY', concept_code+'Summary',
		start_date, (case when NullEndDate=1 then '1900-01-01' else dateadd(ss,60*60*24 - 1,end_date) end),
		n, '@', '@', '@'
	from (
		select site_id, patient_num, concept_code, count(*) n,
			cast(min(start_date) as date) start_date, -- Convert to midnight
			cast(cast(max(end_date) as date) as datetime) end_date, -- Convert to midnight
			max(case when end_date='1900-01-01' then 1 else 0 end) NullEndDate
		from dbo.FourCE_LocalPatientData p
		where concept_type='4CE-VISIT'
		group by site_id, patient_num, concept_code
	) t;

-- Get the earliest start and latest end dates of all visits, and the number of visits, regardless of visit type
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, '4CE-VISIT-SUMMARY', 'AllVisitSummary', min(start_date), 
		(case when max(case when end_date='1900-01-01' then 1 else 0 end)=1 then '1900-01-01' else max(end_date) end),
		sum(value_num), '@', '@', '@'
	from dbo.FourCE_LocalPatientData p
	where concept_type='4CE-VISIT-SUMMARY'
	group by site_id, patient_num;

		
--##############################################################################
--##############################################################################
--### COVID-19 related summary information
--##############################################################################
--##############################################################################

-- Clear existing derived data
delete from dbo.FourCE_LocalPatientData
	where concept_type in ('4CE-COVID-SUMMARY');

-- Get the first and last dates and number of occurrences of COVID tests, diagnoses, and vaccines
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, '4CE-COVID-SUMMARY', 
		(case when concept_type='4CE-COVID-VACCINE' then 'CovidVaccine' else concept_code end)+Summary, 
		min(start_date), max(start_date), count(distinct d.d), '@', '@', '@'
	from dbo.FourCE_LocalPatientData
		cross apply (select cast(start_date as date) d) d
	where concept_type in ('4CE-COVID-TEST', '4CE-COVID-DIAG', '4CE-COVID-VACCINE')
	group by concept_type, concept_code, site_id, patient_num;


--##############################################################################
--##############################################################################
--### 4CE Version 2 Demographics
--##############################################################################
--##############################################################################

-- Clear existing derived data
delete from dbo.FourCE_LocalPatientData
	where concept_type='4CE-DEM' and concept_code like 'AgeInYears:%';

-- Age Groups (AgeInYears:AgeGroup as the concept code)
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, concept_type, 
			'AgeInYears:'+(case 
				when value_num between 0 and 2 then '00to02'
				when value_num between 3 and 5 then '03to05'
				when value_num between 6 and 11 then '06to11'
				when value_num between 12 and 17 then '12to17'
				when value_num between 18 and 20 then '18to20'
				when value_num between 21 and 25 then '21to25'
				when value_num between 26 and 49 then '26to49'
				when value_num between 50 and 69 then '50to69'
				when value_num between 70 and 79 then '70to79'
				when value_num >= 80 then '80plus'
				else 'other' end),
			start_date, end_date, value_num, value_char, value_units, local_code_name
		from dbo.FourCE_LocalPatientData
		where concept_type='4CE-DEM' and concept_code='AgeInYears';


--##############################################################################
--##############################################################################
--### 4CE Version 2 Cohorts, Severity, and Time Periods
--##############################################################################
--##############################################################################

-- Clear existing derived data
delete from dbo.FourCE_LocalPatientData
	where concept_type in ('4CE-V2-COHORT','4CE-V2-SEVERE-LAB','4CE-V2-SEVERE-DIAG','4CE-V2-SEVERE','4CE-V2-TIME-PERIOD');

--------------------------------------------------------------------------------
-- COVID-19 Cohorts (PCR status, admitted, year and quarter)
--------------------------------------------------------------------------------

-- Determine the 4CE Version 2 cohort in the format {Pos|U071|Neg}{Adm|NotAdm}{2020|2021|2022|2023}{Q1|Q2|Q3|Q4}
-- The start_date is the "index date", which is the first admission date for "Adm" cohorts and the first test/U071 date for "NotAdm" cohorts
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, '4CE-V2-COHORT', 
		cohort+is_admitted+cast(datepart(yy,index_date) as varchar(10))+'Q'+cast(floor(datepart(mm,index_date)/4)+1 as varchar(10)), 
		index_date, '1900-01-01', -999, '@', '@', '@'
	from (
		select *, 
			cast(isnull(admission_date,test_date) as date) index_date,
			(case when admission_date is not null then 'Adm' else 'NotAdm' end) is_admitted
		from (
			select *,
				row_number() over (partition by site_id, patient_num order by (case when admission_date is not null then 0 else 1 end), cohort_rank) k
			from (
				select t.site_id, t.patient_num, t.concept_code, t.start_date test_date,
					min(case when a.patient_num is not null then a.start_date else null end) admission_date,
					(case t.concept_code when 'CovidPCRPosSummary' then 'Pos' when 'U071Summary' then 'U071' else 'Neg' end) cohort,
					(case t.concept_code when 'CovidPCRPosSummary' then 1 when 'U071Summary' then 2 else 3 end) cohort_rank
				from dbo.FourCE_LocalPatientData t --Covid Test
					left outer join dbo.FourCE_LocalPatientData a --Covid Admission
						on t.site_id=a.site_id and t.patient_num=a.patient_num
							and a.concept_type='4CE-VISIT' and a.concept_code='Inpatient'
							and datediff(dd,t.start_date,a.start_date) between -7 and 14
				where t.concept_type='4CE-COVID-SUMMARY' and t.concept_code in ('CovidPCRPosSummary','CovidPCRNegSummary','U071Summary')
				group by t.site_id, t.patient_num, t.concept_code, t.start_date
			) t
		) t
		where k=1
	) t;

--------------------------------------------------------------------------------
-- Severe COVID-19
--------------------------------------------------------------------------------

-- Determine the dates when patients had a "severe" COVID-19 related lab test or diagnosis
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select site_id, patient_num, severe_type, severe_code, start_date, end_date, value_num, value_char, value_units, local_code_name
	from (
		-- Any PaCO2 or PaO2 lab test
		select '4CE-V2-SEVERE-LAB' severe_type, 'BloodGas' severe_code, *
			from dbo.FourCE_LocalPatientData
			where concept_type='4CE-LAB-LOINC' and concept_code in ('2019-8','2703-7')
		-- Acute respiratory distress syndrome (diagnosis)
		union select '4CE-V2-SEVERE-DIAG', 'ARDS', *
			from dbo.FourCE_LocalPatientData
			where (concept_type='4CE-DIAG-ICD9' and concept_code in ('518.82','51882'))
				or (concept_type='4CE-DIAG-ICD10' and concept_code in ('J80'))
		-- Ventilator associated pneumonia (diagnosis)
		union select '4CE-V2-SEVERE-DIAG', 'VAP', *
			from dbo.FourCE_LocalPatientData
			where (concept_type='4CE-DIAG-ICD9' and concept_code in ('997.31','99731'))
				or (concept_type='4CE-DIAG-ICD10' and concept_code in ('J95.851','J95851'))
	) t;

-- Flag the patients as "severe" if they had any severe COVID-19 related code between 0 and 30 days after their cohort index date
insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
		select c.site_id, c.patient_num, '4CE-V2-SEVERE', c.concept_code, min(p.start_date), '1900-01-01', -999, '@', '@', '@'
		from dbo.FourCE_LocalPatientData c
			inner join dbo.FourCE_LocalPatientData p
				on p.site_id=c.site_id and p.patient_num=c.patient_num
		where c.concept_type='4CE-V2-COHORT'
			and datediff(dd,c.start_date,p.start_date) between 0 and 30
			and (
				-- Any severe lab or diagnosis
				(p.concept_type in ('4CE-V2-SEVERE-LAB','4CE-V2-SEVERE-DIAG'))
				-- Any severe medication
				or (p.concept_type='4CE-MED-CLASS' and p.concept_code in ('SIANES','SICARDIAC'))
				-- Any severe procedure
				or (p.concept_type='4CE-PROC-GROUP' and p.concept_code in ('SupplementalOxygenSevere','ECMO'))
			)
		group by c.site_id, c.patient_num, c.concept_code;

--------------------------------------------------------------------------------
-- Time Periods (for PASC analyses)
--------------------------------------------------------------------------------

insert into dbo.FourCE_LocalPatientData (site_id, patient_num, concept_type, concept_code, start_date, end_date, value_num, value_char, value_units, local_code_name)
	select p.site_id, p.patient_num, '4CE_V2_TIME_PERIOD', t.concept_code, cast(t.start_date as date),
		(case when t.end_date='1900-01-01' then t.end_date else dateadd(ss,60*60*23+60*59+59,cast(cast(t.end_date as date) as datetime)) end),
		-999, '@', '@', '@'
	from dbo.FourCE_LocalPatientData p
		cross apply (
			select null concept_code, null start_date, null end_date where 1=0
			-- Original V2 time periods
			union select 'before_adm', dateadd(dd,-365,start_date), dateadd(dd,-15,start_date)
			union select 'since_adm', start_date, '1900-01-01'
			union select 'dayN14toN1', dateadd(dd,-14,start_date), dateadd(dd,-1,start_date)
			union select 'day0to29', start_date, dateadd(dd,29,start_date)
			union select 'day30to89', dateadd(dd,30,start_date), dateadd(dd,89,start_date)
			union select 'day30plus', dateadd(dd,30,start_date), '1900-01-01'
			union select 'day90plus', dateadd(dd,90,start_date), '1900-01-01'
			-- Additional time periods to capture 1st occurrences (e.g., day30plus AND NOT beefore_day30)
			union select 'before_dayN365', '1900-01-01', dateadd(dd,-366,start_date)
			union select 'before_day0', '1900-01-01', dateadd(dd,-1,start_date)
			union select 'before_day30', '1900-01-01', dateadd(dd,29,start_date)
			union select 'before_day90', '1900-01-01', dateadd(dd,89,start_date)
		) t
	where concept_type='4CE-V2-COHORT';



END;
GO
