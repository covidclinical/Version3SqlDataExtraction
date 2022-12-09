--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: InsertSamplingGroupsData
--### Date: December 8, 2022
--### Database: Microsoft SQL Server
--### Data Model: i2b2
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################


-- Define the sampling groups.
insert into dbo.FourCE_SamplingGroups (sampling_group, initial_sample_size, is_active, group_desc)
	values ('AllPatientsSince2017', 10000, 'Y', 'All patients with any type of visit since Jan 1, 2017');

insert into dbo.FourCE_SamplingGroups (sampling_group, initial_sample_size, is_active, group_desc)
	values ('AdmittedSince2017', 10000, 'Y', 'All patients with an inpatient visit since Jan 1, 2017');

insert into dbo.FourCE_SamplingGroups (sampling_group, initial_sample_size, is_active, group_desc)
	values ('CovidPositive', 10000, 'Y', 'Any SARS-CoV-2 PCR or antigen positive test or U07.1 or U07.2 diagnosis');

insert into dbo.FourCE_SamplingGroups (sampling_group, initial_sample_size, is_active, group_desc)
	values ('MISC', 10000, 'Y', 'Patients with MIS-C');

