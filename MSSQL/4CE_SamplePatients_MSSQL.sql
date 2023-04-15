--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: SamplePatients
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_SamplePatients
AS
BEGIN

SET NOCOUNT ON;


-- Add new patients to sampling groups that already have patients.
-- Only sample from patients who have met the sampling group criteria since the last update.
-- Select a sample size so that the sampling rate remains the same as prior updates to this sampling group.
insert into dbo.FourCE_SamplingGroupPatients(sampling_group, patient_num, sampled_date)
	select sampling_group, patient_num, GetDate()
	from (
		select p.*, t.sample_size, row_number() over (partition by p.sampling_group order by newid()) random_sort_order
		from dbo.FourCE_AllPatientsHistory p
			inner join (
				select g.sampling_group, g.last_sampled_date, 
						floor(s.current_sample_size/cast(h.last_all_patients_size as float)*h.new_all_patients_size) sample_size
				from dbo.FourCE_SamplingGroups g
					inner join (
						select a.sampling_group,
							sum(case when a.added_date<b.last_sampled_date then 1 else 0 end) last_all_patients_size,
							sum(case when a.added_date>=b.last_sampled_date then 1 else 0 end) new_all_patients_size
						from dbo.FourCE_AllPatientsHistory a
							inner join dbo.FourCE_SamplingGroups b
								on a.sampling_group=b.sampling_group
						group by a.sampling_group
					) h on h.sampling_group=g.sampling_group
					inner join (
						select sampling_group, count(*) current_sample_size
						from dbo.FourCE_SamplingGroupPatients
						group by sampling_group
					) s on s.sampling_group=g.sampling_group
				where g.add_new_patients='Y'
		) t on p.sampling_group=t.sampling_group
		where p.added_date>t.last_sampled_date
	) t
	where random_sort_order<=sample_size;
	

-- Randomly select patients for each sampling group that does not yet have any patients.
-- Select the sample size based on the "initial_sample_size" parameter for this sampling group.
insert into dbo.FourCE_SamplingGroupPatients(sampling_group, patient_num, sampled_date)
	select p.sampling_group, p.patient_num, GetDate()
	from (
		select *, row_number() over (partition by sampling_group order by newid()) random_sort_order
		from dbo.FourCE_AllPatientsHistory
	) p inner join dbo.FourCE_SamplingGroups g
		on p.sampling_group=g.sampling_group
			and p.random_sort_order<=g.initial_sample_size;
	where p.sampling_group not in (
		select sampling_group from dbo.FourCE_SamplingGroupPatients
	);


-- Clear the SampledPatients table.
truncate table dbo.FourCE_SampledPatients;

-- Get a distinct list of patients across all sampling groups.
-- The study_id is a random number that can optionally replace patient_num in data files.
insert into dbo.FourCE_SampledPatients(patient_num, study_id)
	select patient_num, row_number() over (order by newid())
	from (
		select distinct patient_num
		from dbo.FourCE_SamplingGroupPatients
	) t;


-- Save the current date to know when sampling was last run.
update dbo.FourCE_SamplingGroups
	set last_sampled_date=GetDate()
	where (last_sample_date is null) or (add_new_patients='Y');


END;
GO
