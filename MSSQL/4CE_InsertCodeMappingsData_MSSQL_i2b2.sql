--##############################################################################
--##############################################################################
--### 4CE Federated Network Data Extraction (Version 3)
--### Script: InsertCodeMappingsData
--### Date: April 14, 2023
--### Database: Microsoft SQL Server
--### Data Model: i2b2
--### Created By: Griffin Weber (weber@hms.harvard.edu)
--##############################################################################
--##############################################################################

CREATE PROCEDURE dbo.usp_4CE_InsertCodeMappingsData
AS
BEGIN

SET NOCOUNT ON;


-- Clear out existing mappings
truncate table dbo.FourCE_CodeMappings;


--##############################################################################
--##############################################################################
--### Mappings for 4CE common data elements
--##############################################################################
--##############################################################################

-- Concept prefixes
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	values ('4CE-PREFIX', 'DIAG-ICD9', 'ICD9:', 'observation_fact', 'concept_cd', '@', '@', 0, 'Prefix for DIAG-ICD9 codes', '@')
		, ('4CE-PREFIX', 'DIAG-ICD10', 'ICD10:', 'observation_fact', 'concept_cd', '@', '@', 0, 'Prefix for DIAG-ICD10 codes', '@')
		, ('4CE-PREFIX', 'DEM-ZIPCODE', 'DEM|ZIPCODE:', 'observation_fact', 'concept_cd', '@', '@', 0, 'Prefix for 5-digit zip codes', '@')
		, ('4CE-PREFIX', 'DEM-ZIP3', 'DEM|ZIP3:', 'observation_fact', 'concept_cd', '@', '@', 0, 'Prefix for 3-digit zip codes', '@')
		;

-- Demographics (sex)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	values ('4CE-DEM', 'Sex:Female', 'F', 'patient_dimension', 'sex_cd', '@', '@', 0, 'Female', 'F')
		, ('4CE-DEM', 'Sex:Female', 'FEMALE', 'patient_dimension', 'sex_cd', '@', '@', 0, 'Female', 'FEMALE')
		, ('4CE-DEM', 'Sex:Male', 'M', 'patient_dimension', 'sex_cd', '@', '@', 0, 'Male', 'M')
		, ('4CE-DEM', 'Sex:Male', 'MALE', 'patient_dimension', 'sex_cd', '@', '@', 0, 'Male', 'FEMALE')
		;

-- Visit types
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	values ('4CE-VISIT', 'Inpatient', 'I', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Inpatient visit', 'I')
		, ('4CE-VISIT', 'Inpatient', 'IN', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Inpatient visit', 'IN')
		, ('4CE-VISIT', 'Inpatient', 'INPATIENT', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Inpatient visit', 'INPATIENT')
		, ('4CE-VISIT', 'Inpatient', 'IN_PATIENT', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Inpatient visit', 'IN_PATIENT')
		, ('4CE-VISIT', 'ED', 'E', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Emergency room visit', 'E')
		, ('4CE-VISIT', 'ED', 'ED', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Emergency room visit', 'ED')
		, ('4CE-VISIT', 'ED', 'ER', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Emergency room visit', 'ER')
		, ('4CE-VISIT', 'ED', 'EMERGENCY', 'visit_dimension', 'inout_cd', '@', '@', 0, 'Emergency room visit', 'EMERGENCY')
		, ('4CE-VISIT', 'ICU', 'ICU', 'visit_dimension', 'location_cd', '@', '@', 0, 'ICU visit', 'ICU')
		, ('4CE-VISIT', 'ICU', 'UMLS:C1547136', 'observation_fact', 'concept_cd', '@', '@', 0, 'ICU visit', 'ICU')
		;

--------------------------------------------------------------------------------
-- Race and ethnicity (optional)
--------------------------------------------------------------------------------

-- Race and ethnicity (from the observation_fact.concept_cd field)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-RACE-ETHNICITY', concept_code, local_code, 'observation_fact', 'concept_cd', '@', '@', 0, concept_code, '@'
	from (
		select null concept_code, null local_code where 1=0
		-- Race and ethnicity from United States
		union select 'us_american_indian', 'DEM|RACE:NA'
		union select 'us_asian', 'DEM|RACE:A'
		union select 'us_asian', 'DEM|RACE:AS'
		union select 'us_black', 'DEM|RACE:B'
		union select 'us_hawaiian_pacific_islander', 'DEM|RACE:H'
		union select 'us_hawaiian_pacific_islander', 'DEM|RACE:P'
		union select 'us_white', 'DEM|RACE:W'
		union select 'us_hispanic_latino', 'DEM|HISP:Y'
		union select 'us_hispanic_latino', 'DEM|HISPANIC:Y'
		union select 'us_other', 'DEM|RACE:O' -- include multiple if no additional information is known
		union select 'us_no_information', 'DEM|RACE:NI' -- unknown, not available, missing, refused to answer, not recorded, etc.
	) t;

-- Race and ethnicity (from the patient_dimension.race_cd field)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-RACE-ETHNICITY', concept_code, local_code, 'patient_dimension', 'race_cd', '@', '@', 0, concept_code, '@'
	from (
		select null concept_code, null local_code where 1=0
		--------------------------------------------------
		-- Race and ethnicity from United States
		--------------------------------------------------
		union select 'us_american_indian', 'NA'
		union select 'us_asian', 'A'
		union select 'us_asian', 'AS'
		union select 'us_black', 'B'
		union select 'us_hawaiian_pacific_islander', 'H'
		union select 'us_hawaiian_pacific_islander', 'P'
		union select 'us_white', 'W'
		union select 'us_hispanic_latino', 'HL'
		union select 'us_other', 'O' -- include multiple if no additional information is known
		union select 'us_no_information', 'NI' -- unknown, not available, missing, refused to answer, not recorded, etc.
		--------------------------------------------------
		-- Ethnicity from United Kingdom
		--------------------------------------------------
		-- union select 'uk_asian', 'Asian' -- Asian or Asian British (Indian, Pakistani, Bangladeshi, Chinese, other Asian background) 
		-- union select 'uk_black', 'Black' -- Black, African, Carribean, or Black British (African/ Caribbean/ any other Black, African or Caribbean background)
		-- union select 'uk_white', 'White' -- White (English/ Welsh/ Scottish/Northern Irish/ British, Irish, Gypsy or Irish Traveller, other White background)
		-- union select 'uk_multiple', 'Multiple' -- Mixed or Multiple ethnic groups (White and Black Caribbean, White and Black African, White and Asian, Any other Mixed or Multiple ethnic background)
		-- union select 'uk_other', 'Other' -- Other ethnic group (Arab, other ethnic group)
		-- union select 'uk_no_information', 'NI' -- unknown, not available, missing, refused to answer, not recorded, etc.
		--------------------------------------------------
		-- Race from Singapore
		--------------------------------------------------
		-- union select 'singapore_chinese', 'Chinese'
		-- union select 'singapore_malay', 'Malay'
		-- union select 'singapore_indian', 'Indian'
		-- union select 'singapore_other', 'Other'
		-- union select 'singapore_no_information', 'NI' -- unknown, not available, missing, refused to answer, not recorded, etc.
		--------------------------------------------------
		-- Race from Brazil
		--------------------------------------------------
		-- union select 'brazil_branco', 'Branco'
		-- union select 'brazil_pardo', 'Pardo'
		-- union select 'brazil_preto', 'Preto'
		-- union select 'brazil_indigena', 'Indigena'
		-- union select 'brazil_amarelo', 'Amarelo'
		-- union select 'brazil_no_information', 'NI' -- unknown, not available, missing, refused to answer, not recorded, etc.
	) t;

--------------------------------------------------------------------------------
-- Laborary tests and vital signs
--------------------------------------------------------------------------------

-- Laboratory tests
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-LAB-LOINC' concept_type, concept_code, 'LOINC:'+local_code, 'observation_fact', 'concept_cd', concept_units, local_units, scale_factor, concept_code_name,
		(
			select max(c_name) from ont.i2b2 o where o.c_basecode = t.local_code and o.c_synonym_cd='N'
		) local_code_name
	from (
		select null concept_code, null local_code, null concept_units, null local_units, null scale_factor, null concept_code_name where 1=0		
		union select '1742-6','1742-6','U/L','U/L',1,'alanine aminotransferase (ALT)'
		union select '1751-7','1751-7','g/dL','g/dL',1,'albumin'
		union select '1920-8','1920-8','U/L','U/L',1,'aspartate aminotransferase (AST)'
		union select '1975-2','1975-2','mg/dL','mg/dL',1,'total bilirubin'
		union select '1988-5','1988-5','mg/L','mg/L',1,'C-reactive protein (CRP) (Normal Sensitivity)'
		union select '2019-8','2019-8','mmHg','mmHg',1,'PaCO2'
		union select '2160-0','2160-0','mg/dL','mg/dL',1,'creatinine'
		union select '2276-4','2276-4','ng/mL','ng/mL',1,'Ferritin'
		union select '2532-0','2532-0','U/L','U/L',1,'lactate dehydrogenase (LDH)'
		union select '2703-7','2703-7','mmHg','mmHg',1,'PaO2'
		union select '3255-7','3255-7','mg/dL','mg/dL',1,'Fibrinogen'
		union select '33959-8','33959-8','ng/mL','ng/mL',1,'procalcitonin'
		union select '34714-6','34714-6','DEFAULT','DEFAULT',1,'INR'
		union select '48065-7','48065-7','ng/mL{FEU}','ng/mL{FEU}',1,'D-dimer (FEU)'
		union select '48066-5','48066-5','ng/mL{DDU}','ng/mL{DDU}',1,'D-dimer (DDU)'
		union select '49563-0','49563-0','ng/mL','ng/mL',1,'cardiac troponin (High Sensitivity)'
		union select '5902-2','5902-2','s','s',1,'prothrombin time (PT)'
		union select '6598-7','6598-7','ug/L','ug/L',1,'cardiac troponin (Normal Sensitivity)'
		union select '6690-2','6690-2','10*3/uL','10*3/uL',1,'white blood cell count (Leukocytes)'
		union select '731-0','731-0','10*3/uL','10*3/uL',1,'lymphocyte count'
		union select '751-8','751-8','10*3/uL','10*3/uL',1,'neutrophil count'
		union select '777-3','777-3','10*3/uL','10*3/uL',1,'platelet count'
		union select '4548-4','4548-4','%','%',1,'hemoglobin A1c'
	) t;

-- Vital signs (in metric, listed here as LOINC codes)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-VITAL-SIGN' concept_type, concept_code, 'LOINC:'+local_code, 'observation_fact', 'concept_cd', concept_units, local_units, scale_factor, concept_code_name,
		(
			select max(c_name) from ont.i2b2 o where o.c_basecode = t.local_code and o.c_synonym_cd='N'
		) local_code_name
	from (
		select null concept_code, null local_code, null concept_units, null local_units, null scale_factor, null concept_code_name where 1=0		
		union select 'WeightKG','3141-9','kg','kg',1,'body weight measured'
		union select 'WeightKG','3141-9','kg','lbs',0.453592,'body weight measured'
		union select 'WeightKG','3141-9','kg','gm',1000,'body weight measured'
		union select 'HeightCM','8302-2','cm','cm',1,'height'
		union select 'HeightCM','8302-2','cm','m',0.001,'height'
		union select 'HeightCM','8302-2','cm','in',2.54,'height'
		union select 'HeightCM','8302-2','cm','inches',2.54,'height'
		union select 'BMI','39156-5','kg/m2','kg/m2',1,'body mass index'
	) t;


--------------------------------------------------------------------------------
-- Medications
--------------------------------------------------------------------------------

-- Medications (ATC)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-MED-CLASS', m, 'ATC:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, m, 'ATC'
	from (
		select 'ACEI' m, c from (select 'C09AA01' c union select 'C09AA02' union select 'C09AA03' union select 'C09AA04' union select 'C09AA05' union select 'C09AA06' union select 'C09AA07' union select 'C09AA08' union select 'C09AA09' union select 'C09AA10' union select 'C09AA11' union select 'C09AA13' union select 'C09AA15' union select 'C09AA16') t
		union select 'ARB', c from (select 'C09CA01' c union select 'C09CA02' union select 'C09CA03' union select 'C09CA04' union select 'C09CA06' union select 'C09CA07' union select 'C09CA08') t
		union select 'COAGA', c from (select 'B01AC04' c union select 'B01AC05' union select 'B01AC07' union select 'B01AC10' union select 'B01AC13' union select 'B01AC16' union select 'B01AC17' union select 'B01AC22' union select 'B01AC24' union select 'B01AC25' union select 'B01AC26') t
		union select 'COAGB', c from (select 'B01AA01' c union select 'B01AA03' union select 'B01AA04' union select 'B01AA07' union select 'B01AA11' union select 'B01AB01' union select 'B01AB04' union select 'B01AB05' union select 'B01AB06' union select 'B01AB07' union select 'B01AB08' union select 'B01AB10' union select 'B01AB12' union select 'B01AE01' union select 'B01AE02' union select 'B01AE03' union select 'B01AE06' union select 'B01AE07' union select 'B01AF01' union select 'B01AF02' union select 'B01AF03' union select 'B01AF04' union select 'B01AX05' union select 'B01AX07') t
		union select 'COVIDVIRAL', c from (select 'J05AE10' c union select 'J05AP01' union select 'J05AR10') t
		union select 'DIURETIC', c from (select 'C03CA01' c union select 'C03CA02' union select 'C03CA03' union select 'C03CA04' union select 'C03CB01' union select 'C03CB02' union select 'C03CC01') t
		union select 'HCQ', c from (select 'P01BA01' c union select 'P01BA02') t
		union select 'ILI', c from (select 'L04AC03' c union select 'L04AC07' union select 'L04AC11' union select 'L04AC14') t
		union select 'INTERFERON', c from (select 'L03AB08' c union select 'L03AB11') t
		union select 'SIANES', c from (select 'M03AC03' c union select 'M03AC09' union select 'M03AC11' union select 'N01AX03' union select 'N01AX10' union select 'N05CD08' union select 'N05CM18') t
		union select 'SICARDIAC', c from (select 'B01AC09' c union select 'C01CA03' union select 'C01CA04' union select 'C01CA06' union select 'C01CA07' union select 'C01CA24' union select 'C01CE02' union select 'C01CX09' union select 'H01BA01' union select 'R07AX01') t
		union select 'REMDESIVIR', c from (select 'J05AB16' c) t
	) t;

-- Medications (RxNorm)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-MED-CLASS', m, 'RXNORM:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, m, 'ATC'
	from (
		select 'ACEI' m, c from (select '36908' c union select '39990' union select '104375' union select '104376' union select '104377' union select '104378' union select '104383' union select '104384' union select '104385' union select '1299896' union select '1299897' union select '1299963' union select '1299965' union select '1435623' union select '1435624' union select '1435630' union select '1806883' union select '1806884' union select '1806890' union select '18867' union select '197884' union select '198187' union select '198188' union select '198189' union select '199351' union select '199352' union select '199353' union select '199622' union select '199707' union select '199708' union select '199709' union select '1998' union select '199816' union select '199817' union select '199931' union select '199937' union select '205326' union select '205707' union select '205778' union select '205779' union select '205780' union select '205781' union select '206277' union select '206313' union select '206764' union select '206765' union select '206766' union select '206771' union select '207780' union select '207792' union select '207800' union select '207820' union select '207891' union select '207892' union select '207893' union select '207895' union select '210671' union select '210672' union select '210673' union select '21102' union select '211535' union select '213482' union select '247516' union select '251856' union select '251857' union select '260333' union select '261257' union select '261258' union select '261962' union select '262076' union select '29046' union select '30131' union select '308607' union select '308609' union select '308612' union select '308613' union select '308962' union select '308963' union select '308964' union select '310063' union select '310065' union select '310066' union select '310067' union select '310422' union select '311353' union select '311354' union select '311734' union select '311735' union select '312311' union select '312312' union select '312313' union select '312748' union select '312749' union select '312750' union select '313982' union select '313987' union select '314076' union select '314077' union select '314203' union select '317173' union select '346568' union select '347739' union select '347972' union select '348000' union select '35208' union select '35296' union select '371001' union select '371254' union select '371506' union select '372007' union select '372274' union select '372614' union select '372945' union select '373293' union select '373731' union select '373748' union select '373749' union select '374176' union select '374177' union select '374938' union select '378288' union select '3827' union select '38454' union select '389182' union select '389183' union select '389184' union select '393442' union select '401965' union select '401968' union select '411434' union select '50166' union select '542702' union select '542704' union select '54552' union select '60245' union select '629055' union select '656757' union select '807349' union select '845488' union select '845489' union select '854925' union select '854927' union select '854984' union select '854986' union select '854988' union select '854990' union select '857169' union select '857171' union select '857183' union select '857187' union select '857189' union select '858804' union select '858806' union select '858810' union select '858812' union select '858813' union select '858815' union select '858817' union select '858819' union select '858821' union select '898687' union select '898689' union select '898690' union select '898692' union select '898719' union select '898721' union select '898723' union select '898725') t
		union select 'ARB', c from (select '118463' c union select '108725' union select '153077' union select '153665' union select '153666' union select '153667' union select '153821' union select '153822' union select '153823' union select '153824' union select '1996253' union select '1996254' union select '199850' union select '199919' union select '200094' union select '200095' union select '200096' union select '205279' union select '205304' union select '205305' union select '2057151' union select '2057152' union select '2057158' union select '206256' union select '213431' union select '213432' union select '214354' union select '261209' union select '261301' union select '282755' union select '284531' union select '310139' union select '310140' union select '311379' union select '311380' union select '314073' union select '349199' union select '349200' union select '349201' union select '349483' union select '351761' union select '351762' union select '352001' union select '352274' union select '370704' union select '371247' union select '372651' union select '374024' union select '374279' union select '374612' union select '378276' union select '389185' union select '484824' union select '484828' union select '484855' union select '52175' union select '577776' union select '577785' union select '577787' union select '598024' union select '615856' union select '639536' union select '639537' union select '639539' union select '639543' union select '69749' union select '73494' union select '83515' union select '83818' union select '979480' union select '979482' union select '979485' union select '979487' union select '979492' union select '979494') t
		union select 'COAGA', c from (select '27518' c union select '10594' union select '108911' union select '1116632' union select '1116634' union select '1116635' union select '1116639' union select '1537034' union select '1537038' union select '1537039' union select '1537045' union select '1656052' union select '1656055' union select '1656056' union select '1656061' union select '1656683' union select '1666332' union select '1666334' union select '1736469' union select '1736470' union select '1736472' union select '1736477' union select '1736478' union select '1737465' union select '1737466' union select '1737468' union select '1737471' union select '1737472' union select '1812189' union select '1813035' union select '1813037' union select '197622' union select '199314' union select '200348' union select '200349' union select '205253' union select '206714' union select '207569' union select '208316' union select '208558' union select '213169' union select '213299' union select '241162' union select '261096' union select '261097' union select '309362' union select '309952' union select '309953' union select '309955' union select '313406' union select '32968' union select '333833' union select '3521' union select '371917' union select '374131' union select '374583' union select '375035' union select '392451' union select '393522' union select '613391' union select '73137' union select '749196' union select '749198' union select '75635' union select '83929' union select '855811' union select '855812' union select '855816' union select '855818' union select '855820') t
		union select 'COAGB', c from (select '2110605' c union select '237057' union select '69528' union select '8150' union select '163426' union select '1037042' union select '1037044' union select '1037045' union select '1037049' union select '1037179' union select '1037181' union select '1110708' union select '1114195' union select '1114197' union select '1114198' union select '1114202' union select '11289' union select '114934' union select '1232082' union select '1232084' union select '1232086' union select '1232088' union select '1241815' union select '1241823' union select '1245458' union select '1245688' union select '1313142' union select '1359733' union select '1359900' union select '1359967' union select '1360012' union select '1360432' union select '1361029' union select '1361038' union select '1361048' union select '1361226' union select '1361568' union select '1361574' union select '1361577' union select '1361607' union select '1361613' union select '1361615' union select '1361853' union select '1362024' union select '1362026' union select '1362027' union select '1362029' union select '1362030' union select '1362048' union select '1362052' union select '1362054' union select '1362055' union select '1362057' union select '1362059' union select '1362060' union select '1362061' union select '1362062' union select '1362063' union select '1362065' union select '1362067' union select '1362824' union select '1362831' union select '1362837' union select '1362935' union select '1362962' union select '1364430' union select '1364434' union select '1364435' union select '1364441' union select '1364445' union select '1364447' union select '1490491' union select '1490493' union select '15202' union select '152604' union select '154' union select '1549682' union select '1549683' union select '1598' union select '1599538' union select '1599542' union select '1599543' union select '1599549' union select '1599551' union select '1599553' union select '1599555' union select '1599557' union select '1656595' union select '1656599' union select '1656760' union select '1657991' union select '1658634' union select '1658637' union select '1658647' union select '1658659' union select '1658690' union select '1658692' union select '1658707' union select '1658717' union select '1658719' union select '1658720' union select '1659195' union select '1659197' union select '1659260' union select '1659263' union select '1723476' union select '1723478' union select '1798389' union select '1804730' union select '1804735' union select '1804737' union select '1804738' union select '1807809' union select '1856275' union select '1856278' union select '1857598' union select '1857949' union select '1927851' union select '1927855' union select '1927856' union select '1927862' union select '1927864' union select '1927866' union select '197597' union select '198349' union select '1992427' union select '1992428' union select '1997015' union select '1997017' union select '204429' union select '204431' union select '205791' union select '2059015' union select '2059017' union select '209081' union select '209082' union select '209083' union select '209084' union select '209086' union select '209087' union select '209088' union select '211763' union select '212123' union select '212124' union select '212155' union select '238722' union select '238727' union select '238729' union select '238730' union select '241112' union select '241113' union select '242501' union select '244230' union select '244231' union select '244239' union select '244240' union select '246018' union select '246019' union select '248140' union select '248141' union select '251272' union select '280611' union select '282479' union select '283855' union select '284458' union select '284534' union select '308351' union select '308769' union select '310710' union select '310713' union select '310723' union select '310732' union select '310733' union select '310734' union select '310739' union select '310741' union select '313410' union select '313732' union select '313733' union select '313734' union select '313735' union select '313737' union select '313738' union select '313739' union select '314013' union select '314279' union select '314280' union select '321208' union select '349308' union select '351111' union select '352081' union select '352102' union select '370743' union select '371679' union select '371810' union select '372012' union select '374319' union select '374320' union select '374638' union select '376834' union select '381158' union select '389189' union select '402248' union select '402249' union select '404141' union select '404142' union select '404143' union select '404144' union select '404146' union select '404147' union select '404148' union select '404259' union select '404260' union select '415379' union select '5224' union select '540217' union select '542824' union select '545076' union select '562130' union select '562550' union select '581236' union select '60819' union select '616862' union select '616912' union select '645887' union select '67031' union select '67108' union select '67109' union select '69646' union select '727382' union select '727383' union select '727384' union select '727559' union select '727560' union select '727562' union select '727563' union select '727564' union select '727565' union select '727566' union select '727567' union select '727568' union select '727718' union select '727719' union select '727722' union select '727723' union select '727724' union select '727725' union select '727726' union select '727727' union select '727728' union select '727729' union select '727730' union select '727778' union select '727831' union select '727832' union select '727834' union select '727838' union select '727851' union select '727859' union select '727860' union select '727861' union select '727878' union select '727880' union select '727881' union select '727882' union select '727883' union select '727884' union select '727888' union select '727892' union select '727920' union select '727922' union select '727926' union select '729968' union select '729969' union select '729970' union select '729971' union select '729972' union select '729973' union select '729974' union select '729976' union select '730002' union select '746573' union select '746574' union select '753111' union select '753112' union select '753113' union select '759595' union select '759596' union select '759597' union select '759598' union select '759599' union select '75960' union select '759600' union select '759601' union select '792060' union select '795798' union select '827000' union select '827001' union select '827003' union select '827069' union select '827099' union select '829884' union select '829885' union select '829886' union select '829888' union select '830698' union select '848335' union select '848339' union select '849297' union select '849298' union select '849299' union select '849300' union select '849301' union select '849312' union select '849313' union select '849317' union select '849333' union select '849337' union select '849338' union select '849339' union select '849340' union select '849341' union select '849342' union select '849344' union select '849699' union select '849702' union select '849710' union select '849712' union select '849715' union select '849718' union select '849722' union select '849726' union select '849764' union select '849770' union select '849776' union select '849814' union select '854228' union select '854232' union select '854235' union select '854236' union select '854238' union select '854239' union select '854241' union select '854242' union select '854245' union select '854247' union select '854248' union select '854249' union select '854252' union select '854253' union select '854255' union select '854256' union select '855288' union select '855290' union select '855292' union select '855296' union select '855298' union select '855300' union select '855302' union select '855304' union select '855306' union select '855308' union select '855312' union select '855314' union select '855316' union select '855318' union select '855320' union select '855322' union select '855324' union select '855326' union select '855328' union select '855332' union select '855334' union select '855336' union select '855338' union select '855340' union select '855342' union select '855344' union select '855346' union select '855348' union select '855350' union select '857253' union select '857255' union select '857257' union select '857259' union select '857261' union select '857645' union select '861356' union select '861358' union select '861360' union select '861362' union select '861363' union select '861364' union select '861365' union select '861366' union select '978713' union select '978715' union select '978717' union select '978718' union select '978719' union select '978720' union select '978721' union select '978722' union select '978723' union select '978725' union select '978727' union select '978733' union select '978735' union select '978736' union select '978737' union select '978738' union select '978740' union select '978741' union select '978744' union select '978745' union select '978746' union select '978747' union select '978755' union select '978757' union select '978759' union select '978761' union select '978777' union select '978778') t
		union select 'COVIDVIRAL', c from (select '108766' c union select '1236627' union select '1236628' union select '1236632' union select '1298334' union select '1359269' union select '1359271' union select '1486197' union select '1486198' union select '1486200' union select '1486202' union select '1486203' union select '1487498' union select '1487500' union select '1863148' union select '1992160' union select '207406' union select '248109' union select '248110' union select '248112' union select '284477' union select '284640' union select '311368' union select '311369' union select '312817' union select '312818' union select '352007' union select '352337' union select '373772' union select '373773' union select '373774' union select '374642' union select '374643' union select '376293' union select '378671' union select '460132' union select '539485' union select '544400' union select '597718' union select '597722' union select '597729' union select '597730' union select '602770' union select '616129' union select '616131' union select '616133' union select '643073' union select '643074' union select '670026' union select '701411' union select '701413' union select '746645' union select '746647' union select '754738' union select '757597' union select '757598' union select '757599' union select '757600' union select '790286' union select '794610' union select '795742' union select '795743' union select '824338' union select '824876' union select '831868' union select '831870' union select '847330' union select '847741' union select '847745' union select '847749' union select '850455' union select '850457' union select '896790' union select '902312' union select '902313' union select '9344') t
		union select 'DIURETIC', c from (select '392534' c union select '4109' union select '392464' union select '33770' union select '104220' union select '104222' union select '1112201' union select '132604' union select '1488537' union select '1546054' union select '1546056' union select '1719285' union select '1719286' union select '1719290' union select '1719291' union select '1727568' union select '1727569' union select '1727572' union select '1729520' union select '1729521' union select '1729523' union select '1729527' union select '1729528' union select '1808' union select '197417' union select '197418' union select '197419' union select '197730' union select '197731' union select '197732' union select '198369' union select '198370' union select '198371' union select '198372' union select '199610' union select '200801' union select '200809' union select '204154' union select '205488' union select '205489' union select '205490' union select '205732' union select '208076' union select '208078' union select '208080' union select '208081' union select '208082' union select '248657' union select '250044' union select '250660' union select '251308' union select '252484' union select '282452' union select '282486' union select '310429' union select '313988' union select '371157' union select '371158' union select '372280' union select '372281' union select '374168' union select '374368' union select '38413' union select '404018' union select '4603' union select '545041' union select '561969' union select '630032' union select '630035' union select '645036' union select '727573' union select '727574' union select '727575' union select '727845' union select '876422' union select '95600') t
		union select 'HCQ', c from (select '1116758' c union select '1116760' union select '1117346' union select '1117351' union select '1117353' union select '1117531' union select '197474' union select '197796' union select '202317' union select '213378' union select '226388' union select '2393' union select '249663' union select '250175' union select '261104' union select '370656' union select '371407' union select '5521' union select '755624' union select '755625' union select '756408' union select '979092' union select '979094') t
		union select 'ILI', c from (select '1441526' c union select '1441527' union select '1441530' union select '1535218' union select '1535242' union select '1535247' union select '1657973' union select '1657974' union select '1657976' union select '1657979' union select '1657980' union select '1657981' union select '1657982' union select '1658131' union select '1658132' union select '1658135' union select '1658139' union select '1658141' union select '1923319' union select '1923332' union select '1923333' union select '1923338' union select '1923345' union select '1923347' union select '2003754' union select '2003755' union select '2003757' union select '2003766' union select '2003767' union select '351141' union select '352056' union select '612865' union select '72435' union select '727708' union select '727711' union select '727714' union select '727715' union select '895760' union select '895764') t
		union select 'INTERFERON', c from (select '120608' c union select '1650893' union select '1650894' union select '1650896' union select '1650922' union select '1650940' union select '1651307' union select '1721323' union select '198360' union select '207059' union select '351270' union select '352297' union select '378926' union select '403986' union select '72257' union select '731325' union select '731326' union select '731328' union select '731330' union select '860244') t
		union select 'SIANES', c from (select '106517' c union select '1087926' union select '1188478' union select '1234995' union select '1242617' union select '1249681' union select '1301259' union select '1313988' union select '1373737' union select '1486837' union select '1535224' union select '1535226' union select '1535228' union select '1535230' union select '1551393' union select '1551395' union select '1605773' union select '1666776' union select '1666777' union select '1666797' union select '1666798' union select '1666800' union select '1666814' union select '1666821' union select '1666823' union select '1718899' union select '1718900' union select '1718902' union select '1718906' union select '1718907' union select '1718909' union select '1718910' union select '1730193' union select '1730194' union select '1730196' union select '1732667' union select '1732668' union select '1732674' union select '1788947' union select '1808216' union select '1808217' union select '1808219' union select '1808222' union select '1808223' union select '1808224' union select '1808225' union select '1808234' union select '1808235' union select '1862110' union select '198383' union select '199211' union select '199212' union select '199775' union select '2050125' union select '2057964' union select '206967' union select '206970' union select '206972' union select '207793' union select '207901' union select '210676' union select '210677' union select '238082' union select '238083' union select '238084' union select '240606' union select '259859' union select '284397' union select '309710' union select '311700' union select '311701' union select '311702' union select '312674' union select '319864' union select '372528' union select '372922' union select '375623' union select '376856' union select '377135' union select '377219' union select '377483' union select '379133' union select '404091' union select '404092' union select '404136' union select '422410' union select '446503' union select '48937' union select '584528' union select '584530' union select '6130' union select '631205' union select '68139' union select '6960' union select '71535' union select '828589' union select '828591' union select '830752' union select '859437' union select '8782' union select '884675' union select '897073' union select '897077' union select '998210' union select '998211') t
		union select 'SICARDIAC', c from (select '7442' c union select '1009216' union select '1045470' union select '1049182' union select '1049184' union select '1052767' union select '106686' union select '106779' union select '106780' union select '1087043' union select '1087047' union select '1090087' union select '1114874' union select '1114880' union select '1114888' union select '11149' union select '1117374' union select '1232651' union select '1232653' union select '1234563' union select '1234569' union select '1234571' union select '1234576' union select '1234578' union select '1234579' union select '1234581' union select '1234584' union select '1234585' union select '1234586' union select '1251018' union select '1251022' union select '1292716' union select '1292731' union select '1292740' union select '1292751' union select '1292887' union select '1299137' union select '1299141' union select '1299145' union select '1299879' union select '1300092' union select '1302755' union select '1305268' union select '1305269' union select '1307224' union select '1358843' union select '1363777' union select '1363785' union select '1363786' union select '1363787' union select '1366958' union select '141848' union select '1490057' union select '1542385' union select '1546216' union select '1546217' union select '1547926' union select '1548673' union select '1549386' union select '1549388' union select '1593738' union select '1658178' union select '1660013' union select '1660014' union select '1660016' union select '1661387' union select '1666371' union select '1666372' union select '1666374' union select '1721536' union select '1743862' union select '1743869' union select '1743871' union select '1743877' union select '1743879' union select '1743938' union select '1743941' union select '1743950' union select '1743953' union select '1745276' union select '1789858' union select '1791839' union select '1791840' union select '1791842' union select '1791854' union select '1791859' union select '1791861' union select '1812167' union select '1812168' union select '1812170' union select '1870205' union select '1870207' union select '1870225' union select '1870230' union select '1870232' union select '1939322' union select '198620' union select '198621' union select '198786' union select '198787' union select '198788' union select '1989112' union select '1989117' union select '1991328' union select '1991329' union select '1999003' union select '1999006' union select '1999007' union select '1999012' union select '204395' union select '204843' union select '209217' union select '2103181' union select '2103182' union select '2103184' union select '211199' union select '211200' union select '211704' union select '211709' union select '211712' union select '211714' union select '211715' union select '212343' union select '212770' union select '212771' union select '212772' union select '212773' union select '238217' union select '238218' union select '238219' union select '238230' union select '238996' union select '238997' union select '238999' union select '239000' union select '239001' union select '241033' union select '242969' union select '244284' union select '245317' union select '247596' union select '247940' union select '260687' union select '309985' union select '309986' union select '309987' union select '310011' union select '310012' union select '310013' union select '310116' union select '310117' union select '310127' union select '310132' union select '311705' union select '312395' union select '312398' union select '313578' union select '313967' union select '314175' union select '347930' union select '351701' union select '351702' union select '351982' union select '359907' union select '3616' union select '3628' union select '372029' union select '372030' union select '372031' union select '373368' union select '373369' union select '373370' union select '373372' union select '373375' union select '374283' union select '374570' union select '376521' union select '377281' union select '379042' union select '387789' union select '392099' union select '393309' union select '3992' union select '404093' union select '477358' union select '477359' union select '52769' union select '542391' union select '542655' union select '542674' union select '562501' union select '562502' union select '562592' union select '584580' union select '584582' union select '584584' union select '584588' union select '602511' union select '603259' union select '603276' union select '603915' union select '617785' union select '669267' union select '672683' union select '672685' union select '672891' union select '692479' union select '700414' union select '704955' union select '705163' union select '705164' union select '705170' union select '727310' union select '727316' union select '727345' union select '727347' union select '727373' union select '727386' union select '727410' union select '727842' union select '727843' union select '727844' union select '746206' union select '746207' union select '7512' union select '8163' union select '827706' union select '864089' union select '880658' union select '8814' union select '883806' union select '891437' union select '891438') t
		union select 'REMDESIVIR', c from (select '2284718' c union select '2284960') t
	) t;

-- Medications (Other)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	values ('4CE-MED-CLASS', 'REMDESIVIR', 'ACT|LOCAL:REMDESIVIR', 'observation_fact', 'concept_cd', '@', '@', 0, 'REMDESIVIR', '@')
		;


--------------------------------------------------------------------------------
-- Procedures
--------------------------------------------------------------------------------

-- Procedures (CPT4 - United States)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'CPT4:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'CPT4:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select '44970' c union select '47562' union select '47563' union select '44950' union select '49320' union select '44180' union select '49585' union select '44120') t
		union select 'EmergencyOrthopedics', c from (select '27245' c union select '27236' union select '27759' union select '24538' union select '11044' union select '27506' union select '22614' union select '27814' union select '63030') t
		union select 'EmergencyVascularSurgery', c from (select '36247' c) t
		union select 'EmergencyOBGYN', c from (select '59151' c) t
		union select 'RenalReplacement', c from (select '90935' c union select '90937' union select '90945') t
		union select 'SupplementalOxygenSevere', c from (select '94002' c union select '94003' union select '94660' union select '31500') t
		union select 'ECMO', c from (select '33946' c union select '33947' union select '33951' union select '33952') t
		union select 'CPR', c from (select '92950' c) t
		union select 'ArterialCatheter', c from (select '36620' c) t
		union select 'CTChest', c from (select '71250' c union select '71260' union select '71270') t
		union select 'Bronchoscopy', c from (select '31645' c) t
		union select 'CovidVaccine', c from (select '0001A' c union select '0002A' union select '0011A' union select '0012A' union select '0021A' union select '0022A' union select '0031A' union select '91300' union select '91301' union select '91302' union select '91303') t
	) t;

-- Procedures (CCAM - France)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'CCAM:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'CCAM:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select 'HHFA016' c union select 'HMFC004' union select 'HHFA011' union select 'ZCQC002' union select 'HGPC015' union select 'LMMA006' union select 'LMMA009' union select 'HGFA007' union select 'HGFC021') t
		union select 'EmergencyOrthopedics', c from (select 'NBCA006' c union select 'NBCA005' union select 'NCCB006' union select 'MBCB001' union select 'NBCA007' union select 'LHDA001' union select 'LHDA002' union select 'NCCA017' union select 'LFFA001' union select 'LDFA003') t
		union select 'EmergencyOBGYN', c from (select 'JJFC001' c) t
		union select 'RenalReplacement', c from (select 'JVJF004' c union select 'JVJF005' union select 'JVJF004' union select 'JVJB001' union select 'JVJB002' union select 'JVJF003' union select 'JVJF008') t
		union select 'SupplementalOxygenSevere', c from (select 'GLMF001' c union select 'GLLD003' union select 'GLLD012' union select 'GLLD019' union select 'GLMP001' union select 'GLLD008' union select 'GLLD015' union select 'GLLD004' union select 'GELD004') t
		union select 'SupplementalOxygenOther', c from (select 'GLLD017' c) t
		union select 'ECMO', c from (select 'EQLA002' c union select 'EQQP004' union select 'GLJF010') t
		union select 'CPR', c from (select 'DKMD001' c union select 'DKMD002') t
		union select 'ArterialCatheter', c from (select 'ENLF001' c) t
		union select 'CTChest', c from (select 'ZBQK001' c union select 'ZBQH001') t
		union select 'Bronchoscopy', c from (select 'GEJE001' c union select 'GEJE003') t
	) t;

-- Procedures (OPCS4 - United Kingdom)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'OPCS4:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'OPCS4:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select 'H01' c union select 'Y75.2' union select 'J18' union select 'Y75.2' union select 'J18.2' union select 'Y75.2' union select 'H01' union select 'T43' union select 'T43.8' union select 'T41.3' union select 'T24' union select 'G58.4' union select 'G69.3') t
		union select 'EmergencyOrthopedics', c from (select 'W24.1' c union select 'W19.1' union select 'W33.6' union select 'W19.2' union select 'V38' union select 'V55.1' union select 'W20.5' union select 'V25.2' union select 'V67.2' union select 'V55.1') t
		union select 'RenalReplacement', c from (select 'X40.3' c union select 'X40.3' union select 'X40.2' union select 'X40.4' union select 'X40.5' union select 'X40.6' union select 'X40.7' union select 'X40.8' union select 'X40.9') t
		union select 'SupplementalOxygenSevere', c from (select 'E85.2' c union select 'E85.4' union select 'E85.6' union select 'X56.2') t
		union select 'SupplementalOxygenOther', c from (select 'X52' c) t
		union select 'ECMO', c from (select 'X58.1' c union select 'X58.1' union select 'X58.1' union select 'X58.1') t
		union select 'CPR', c from (select 'X50.3' c) t
		union select 'CTChest', c from (select 'U07.1' c union select 'Y97.2' union select 'U07.1' union select 'Y97.3' union select 'U07.1' union select 'Y97.1') t
		union select 'Bronchoscopy', c from (select 'E48.4' c union select 'E50.4') t
	) t;

-- Procedures (OPS - Germany)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'OPS:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'OPS:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select '5-470.1' c union select '5-511.1' union select '5-511.12' union select '5-470' union select '1-694' union select '5-534' union select '5-459.0') t
		union select 'EmergencyOrthopedics', c from (select '5-790.2f' c union select '5-793.1e' union select '5-790.2m' union select '5-791.6m' union select '5-790.13' union select '5-780.6' union select '5-791.6g' union select '5-836.30' union select '5-032.30') t
		union select 'RenalReplacement', c from (select '8-854' c union select '8-854' union select '8-857' union select '8-853' union select '8-855' union select '8-856') t
		union select 'SupplementalOxygenSevere', c from (select '8-716.00' c union select '8-711.0' union select '8-712.0' union select '8-701') t
		union select 'SupplementalOxygenOther', c from (select '8-72' c) t
		union select 'ECMO', c from (select '8-852.0' c union select '8-852.30' union select '8-852.31') t
		union select 'CPR', c from (select '8-771' c) t
		union select 'CTChest', c from (select '3-202' c union select '3-221') t
	) t;

-- Procedures (TOSP - Singapore)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'TOSP:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'TOSP:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select 'SF849A' c union select 'SF801G' union select 'SF704G' union select 'SF849A' union select 'SF808A' union select 'SF800A' union select 'SF801A' union select 'SF814A' union select 'SF707I') t
		union select 'EmergencyOrthopedics', c from (select 'SB811F' c union select 'SB703F' union select 'SB705T' union select 'SB810F' union select 'SB700A' union select 'SB812S') t
		union select 'EmergencyOBGYN', c from (select 'SI805F' c) t
		union select 'SupplementalOxygenSevere', c from (select 'SC719T' c union select 'SC720T') t
		union select 'ECMO', c from (select 'SD721H' c union select 'SD721H' union select 'SD721H' union select 'SD721H') t
		union select 'ArterialCatheter', c from (select 'SD718A' c) t
		union select 'Bronchoscopy', c from (select 'SC703B' c union select 'SC704B') t
	) t;

-- Procedures (ICD10AM - Singapore, Australia)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'ICD10AM:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'ICD10AM:'+c
	from (
		select null p, null c where 1=0
		union select 'RenalReplacement', c from (select '13100-00' c union select '13100-00') t
		union select 'SupplementalOxygenSevere', c from (select '92039-00' c union select '13882-00' union select '13882-01' union select '92038-00') t
		union select 'SupplementalOxygenOther', c from (select '92044-00' c) t
		union select 'CPR', c from (select '92052-00' c) t
	) t;

-- Procedures (CBHPM - Brazil-TUSS)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'CBHPM:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'CBHPM:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select '31003079' c union select '31005497' union select '31005470' union select '31003079' union select '31009166') t
		union select 'EmergencyOrthopedics', c from (select '30725119' c union select '30725160' union select '30727138' union select '40803104' union select '30715016' union select '30715199') t
		union select 'EmergencyOBGYN', c from (select '31309186' c) t
		union select 'RenalReplacement', c from (select '30909023' c union select '30909031' union select '31008011') t
		union select 'SupplementalOxygenSevere', c from (select '20203012' c union select '20203012' union select '40202445') t
		union select 'Bronchoscopy', c from (select '40201058' c) t
	) t;

-- Procedures (ICD9Proc)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'ICD9PROC:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'ICD9PROC:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select '47.01' c union select '51.23' union select '47.0' union select '54.51' union select '53.4') t
		union select 'EmergencyOrthopedics', c from (select '79.11' c union select '79.6' union select '79.35' union select '81.03' union select '81.05' union select '81.07' union select '79.36') t
		union select 'EmergencyOBGYN', c from (select '66.62' c) t
		union select 'RenalReplacement', c from (select '39.95' c union select '39.95') t
		union select 'SupplementalOxygenSevere', c from (select '93.90' c union select '96.70' union select '96.71' union select '96.72' union select '96.04') t
		union select 'SupplementalOxygenOther', c from (select '93.96' c) t
		union select 'ECMO', c from (select '39.65' c union select '39.65' union select '39.65' union select '39.65') t
		union select 'CPR', c from (select '99.60' c) t
		union select 'ArterialCatheter', c from (select '38.91' c) t
		union select 'CTChest', c from (select '87.41' c union select '87.41' union select '87.41') t
		union select 'Bronchoscopy', c from (select '33.22' c union select '33.23') t
	) t;

-- Procedures (ICD10-PCS)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'ICD10PCS:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'ICD10PCS:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select '0DBJ4ZZ' c union select '0DTJ4ZZ' union select '0FB44ZZ' union select '0FB44ZX' union select '0DBJ0ZZ' union select '0DTJ0ZZ' union select '0DJU4ZZ' union select '0DN84ZZ' union select '0DNE4ZZ') t
		union select 'EmergencyOrthopedics', c from (select '0QQ60ZZ' c union select '0QQ70ZZ' union select '0QH806Z' union select '0QH906Z') t
		union select 'SupplementalOxygenSevere', c from (select '5A19054' c union select '5A0935Z' union select '5A0945Z' union select '5A0955Z' union select '5A09357' union select '0BH17EZ') t
		union select 'ECMO', c from (select '5A1522H' c union select '5A1522G') t
		union select 'CTChest', c from (select 'BW24' c union select 'BW24Y0Z' union select 'BW24YZZ') t
	) t;

-- Procedures (SNOMED)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-PROC-GROUP', p, 'SNOMED:'+c, 'observation_fact', 'concept_cd', '@', '@', 0, p, 'SNOMED:'+c
	from (
		select null p, null c where 1=0
		union select 'EmergencyGeneralSurgery', c from (select '174041007' c union select '45595009' union select '20630000' union select '80146002' union select '450435004' union select '18433007' union select '5789003' union select '44946007' union select '359572002') t
		union select 'EmergencyOrthopedics', c from (select '179097007' c union select '179018001' union select '73156009' union select '2480009' union select '36939002' union select '55705006' union select '439756000' union select '302129007' union select '231045009' union select '3968003' union select '260648008' union select '178619000') t
		union select 'EmergencyVascularSurgery', c from (select '392247006' c) t
		union select 'EmergencyOBGYN', c from (select '63596003' c union select '61893009') t
		union select 'RenalReplacement', c from (select '302497006' c union select '302497006') t
		union select 'SupplementalOxygenSevere', c from (select '428311008' c union select '410210009' union select '409025002' union select '47545007' union select '16883004') t
		union select 'SupplementalOxygenOther', c from (select '57485005' c) t
		union select 'ECMO', c from (select '786453001' c union select '786451004') t
		union select 'CPR', c from (select '150819003' c) t
		union select 'ArterialCatheter', c from (select '392248001' c) t
		union select 'CTChest', c from (select '395081000119108' c union select '75385009' union select '169069000') t
		union select 'Bronchoscopy', c from (select '10847001' c union select '68187007') t
	) t;



--------------------------------------------------------------------------------
-- COVID-19 Related
--------------------------------------------------------------------------------


-- COVID-19 diagnoses (ICD-10: U07.1 = Confirmed, U07.2 = Suspected)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-COVID-DIAG', c.concept_code, c.local_code, 'observation_fact', 'concept_cd', '@', '@', 0, c.concept_code_name, '@'
		from dbo.FourCE_CodeMappings m
			cross apply (
				select null concept_code, null local_code, null concept_code_name where 1=0
				union select 'U071', m.local_code+'U071', 'Confirmed COVID-19'
				union select 'U071', m.local_code+'U07.1', 'Confirmed COVID-19'
				union select 'U072', m.local_code+'U072', 'Suspected COVID-19'
				union select 'U072', m.local_code+'U07.2', 'Suspected COVID-19'
			) c
		where m.concept_type='4CE-PREFIX' and m.concept_code in ('DIAG-ICD10');


-- COVID-19 tests (OPTION #1: different codes for positive and negative test results from i2b2 ACT ontology)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-COVID-TEST', concept_code, c_basecode, 'observation_fact', 'concept_cd', '@', '@', 0, concept_code_name, max(c_name)
	from dbo.ACT_COVID_V4 c
		inner join (
			select null concept_code, null concept_code_name, null concept_path where 1=0		
			union select 'CovidPCRPos', 'SARS-CoV-2 PCR Positive', '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0022885\UMLS_C1335447\'
			union select 'CovidPCRNeg', 'SARS-CoV-2 PCR Negative', '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0022885\UMLS_C1334932\'
			union select 'CovidAntibodyPos', 'Antibody Positive', '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0022885\ACT_LOCAL_LAB_ANY_POSITIVE\'
			union select 'CovidAntibodyNeg', 'Antibody Negative', '\ACT\UMLS_C0031437\SNOMED_3947185011\UMLS_C0022885\ACT_LOCAL_LAB_ANY_NEGATIVE\'
		) t on c.c_fullname like t.concept_path+'%'
	group by concept_code, concept_code_name, c_basecode;


-- COVID-19 tests (OPTION #2: LOINC codes, where the value of the test result is "POSITIVE" or "NEGATIVE")
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-COVID-TEST', concept_code, 'LOINC:'+local_code, 'observation_fact', 'concept_cd', '@', '@', 0, 
		(case concept_code when 'CovidAntibody' then 'Antibody' else 'SARS-CoV-2 PCR' end) concept_code_name, '@'
	from (
		select null concept_code, null local_code where 1=0
		union select 'CovidPCR', '94307-6'
		union select 'CovidPCR', '94308-4'
		union select 'CovidPCR', '94309-2'
		union select 'CovidPCR', '94310-0'
		union select 'CovidPCR', '94311-8'
		union select 'CovidPCR', '94312-6'
		union select 'CovidPCR', '94313-4'
		union select 'CovidPCR', '94314-2'
		union select 'CovidPCR', '94315-9'
		union select 'CovidPCR', '94316-7'
		union select 'CovidPCR', '94500-6'
		union select 'CovidPCR', '94502-2'
		union select 'CovidPCR', '94509-7'
		union select 'CovidPCR', '94510-5'
		union select 'CovidPCR', '94511-3'
		union select 'CovidPCR', '94532-9'
		union select 'CovidPCR', '94533-7'
		union select 'CovidPCR', '94534-5'
		union select 'CovidPCR', '94558-4'
		union select 'CovidPCR', '94559-2'
		union select 'CovidPCR', '94565-9'
		union select 'CovidPCR', '94639-2'
		union select 'CovidPCR', '94640-0'
		union select 'CovidPCR', '94641-8'
		union select 'CovidPCR', '94642-6'
		union select 'CovidPCR', '94643-4'
		union select 'CovidPCR', '94644-2'
		union select 'CovidPCR', '94645-9'
		union select 'CovidPCR', '94646-7'
		union select 'CovidPCR', '94647-5'
		union select 'CovidPCR', '94660-8'
		union select 'CovidPCR', '94661-6'
		union select 'CovidPCR', '94745-7'
		union select 'CovidPCR', '94746-5'
		union select 'CovidPCR', '94756-4'
		union select 'CovidPCR', '94757-2'
		union select 'CovidPCR', '94758-0'
		union select 'CovidPCR', '94759-8'
		union select 'CovidPCR', '94760-6'
		union select 'CovidPCR', '94763-0'
		union select 'CovidPCR', '94764-8'
		union select 'CovidPCR', '94765-5'
		union select 'CovidPCR', '94766-3'
		union select 'CovidPCR', '94767-1'
		union select 'CovidPCR', '94819-0'
		union select 'CovidPCR', '94822-4'
		union select 'CovidPCR', '94845-5'
		union select 'CovidPCR', '95209-3'
		union select 'CovidPCR', '95406-5'
		union select 'CovidPCR', '95409-9'
		union select 'CovidPCR', '95423-0'
		union select 'CovidPCR', '95424-8'
		union select 'CovidPCR', '95425-5'
		union select 'CovidPCR', '95521-1'
		union select 'CovidPCR', '95522-9'
		union select 'CovidPCR', '95608-6'
		union select 'CovidPCR', '95609-4'
		union select 'CovidPCR', '95823-1'
		union select 'CovidPCR', '95824-9'
		union select 'CovidPCR', '95970-0'
		union select 'CovidPCR', '96091-4'
		union select 'CovidPCR', '96120-1'
		union select 'CovidPCR', '96121-9'
		union select 'CovidPCR', '96122-7'
		union select 'CovidPCR', '96123-5'
		union select 'CovidPCR', '96448-6'
		union select 'CovidPCR', '96741-4'
		union select 'CovidPCR', '96751-3'
		union select 'CovidPCR', '96752-1'
		union select 'CovidAntibody', '94505-5'
		union select 'CovidAntibody', '94506-3'
		union select 'CovidAntibody', '94507-1'
		union select 'CovidAntibody', '94508-9'
		union select 'CovidAntibody', '94547-7'
		union select 'CovidAntibody', '94562-6'
		union select 'CovidAntibody', '94563-4'
		union select 'CovidAntibody', '94564-2'
		union select 'CovidAntibody', '94720-0'
		union select 'CovidAntibody', '94761-4'
		union select 'CovidAntibody', '94762-2'
		union select 'CovidAntibody', '94768-9'
		union select 'CovidAntibody', '94769-7'
		union select 'CovidAntibody', '95125-1'
		union select 'CovidAntibody', '95410-7'
		union select 'CovidAntibody', '95411-5'
		union select 'CovidAntibody', '95416-4'
		union select 'CovidAntibody', '95427-1'
		union select 'CovidAntibody', '95428-9'
		union select 'CovidAntibody', '95429-7'
		union select 'CovidAntibody', '95542-7'
		union select 'CovidAntibody', '95825-6'
		union select 'CovidAntibody', '95971-8'
		union select 'CovidAntibody', '95972-6'
		union select 'CovidAntibody', '95973-4'
		union select 'CovidAntibody', '96119-3'
		union select 'CovidAntibody', '96603-6'
		union select 'CovidAntibody', '96742-2'
	) t;


-- COVID-19 vaccine (by manufacturer; procedure, medication, and CVX codes)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-COVID-VACCINE', manufacturer, local_code, 'observation_fact', 'concept_cd', '@', '@', 0, 'COVID-19 Vaccine '+manufacturer, '@'
	from (
		select null manufacturer, null local_code where 1=0
		union select 'AstraZeneca', 'ACT|LOCAL|VAX:ASTRAZENECA_VAX_VECTOR_NR_IN'
		union select 'AstraZeneca', 'CPT4:0021A'
		union select 'AstraZeneca', 'CPT4:0022A'
		union select 'AstraZeneca', 'CPT4:91302'
		union select 'AstraZeneca', 'CVX:210'
		union select 'AstraZeneca', 'NDC:0310122210'
		union select 'AstraZeneca', 'NDC:0310122215'
		union select 'Janssen', 'CPT4:0031A'
		union select 'Janssen', 'CPT4:0034A'
		union select 'Janssen', 'CPT4:91303'
		union select 'Janssen', 'CVX:212'
		union select 'Janssen', 'NDC:59676058005'
		union select 'Janssen', 'NDC:59676058015'
		union select 'Janssen', 'RXNORM:2479831'
		union select 'Janssen', 'RXNORM:2479835'
		union select 'Moderna', 'CPT4:0011A'
		union select 'Moderna', 'CPT4:0012A'
		union select 'Moderna', 'CPT4:0013A'
		union select 'Moderna', 'CPT4:0064A'
		union select 'Moderna', 'CPT4:0091A'
		union select 'Moderna', 'CPT4:0092A'
		union select 'Moderna', 'CPT4:0093A'
		union select 'Moderna', 'CPT4:0094A'
		union select 'Moderna', 'CPT4:0111A'
		union select 'Moderna', 'CPT4:0112A'
		union select 'Moderna', 'CPT4:0113A'
		union select 'Moderna', 'CPT4:0134A'
		union select 'Moderna', 'CPT4:0144A'
		union select 'Moderna', 'CPT4:91301'
		union select 'Moderna', 'CPT4:91306'
		union select 'Moderna', 'CPT4:91309'
		union select 'Moderna', 'CPT4:91311'
		union select 'Moderna', 'CPT4:91313'
		union select 'Moderna', 'CPT4:91314'
		union select 'Moderna', 'CVX:207'
		union select 'Moderna', 'NDC:80777027310'
		union select 'Moderna', 'NDC:80777027398'
		union select 'Moderna', 'NDC:80777027399'
		union select 'Moderna', 'RXNORM: 2470234'
		union select 'Moderna', 'RXNORM:2470232'
		union select 'Moderna', 'RXNORM:2470234'
		union select 'Pfizer', 'CPT4:0001A'
		union select 'Pfizer', 'CPT4:0002A'
		union select 'Pfizer', 'CPT4:0003A'
		union select 'Pfizer', 'CPT4:0004A'
		union select 'Pfizer', 'CPT4:0051A'
		union select 'Pfizer', 'CPT4:0052A'
		union select 'Pfizer', 'CPT4:0053A'
		union select 'Pfizer', 'CPT4:0054A'
		union select 'Pfizer', 'CPT4:0071A'
		union select 'Pfizer', 'CPT4:0072A'
		union select 'Pfizer', 'CPT4:0073A'
		union select 'Pfizer', 'CPT4:0074A'
		union select 'Pfizer', 'CPT4:0081A'
		union select 'Pfizer', 'CPT4:0082A'
		union select 'Pfizer', 'CPT4:0083A'
		union select 'Pfizer', 'CPT4:0124A'
		union select 'Pfizer', 'CPT4:0154A'
		union select 'Pfizer', 'CPT4:91300'
		union select 'Pfizer', 'CPT4:91305'
		union select 'Pfizer', 'CPT4:91307'
		union select 'Pfizer', 'CPT4:91308'
		union select 'Pfizer', 'CPT4:91312'
		union select 'Pfizer', 'CPT4:91315'
		union select 'Pfizer', 'CVX:208'
		union select 'Pfizer', 'NDC:59267100001'
		union select 'Pfizer', 'NDC:59267100002'
		union select 'Pfizer', 'NDC:59267100003'
		union select 'Pfizer', 'RXNORM:2468230'
		union select 'Pfizer', 'RXNORM:2468235'
		union select 'OtherUnknown', 'CPT4:0021A'
		union select 'OtherUnknown', 'CPT4:0022A'
		union select 'OtherUnknown', 'CPT4:0041A'
		union select 'OtherUnknown', 'CPT4:0042A'
		union select 'OtherUnknown', 'CPT4:0044A'
		union select 'OtherUnknown', 'CPT4:0104A'
		union select 'OtherUnknown', 'CPT4:91302'
		union select 'OtherUnknown', 'CPT4:91304'
		union select 'OtherUnknown', 'CPT4:91310'
		union select 'OtherUnknown', 'ICD10PCS:XW013S6'
		union select 'OtherUnknown', 'ICD10PCS:XW013T6'
		union select 'OtherUnknown', 'ICD10PCS:XW013U6'
		union select 'OtherUnknown', 'ICD10PCS:XW023S6'
		union select 'OtherUnknown', 'ICD10PCS:XW023T6'
		union select 'OtherUnknown', 'ICD10PCS:XW023U6'
		union select 'OtherUnknown', 'RXNORM:2468231'
		union select 'OtherUnknown', 'RXNORM:2468234'
	) t;


-- Not fully vaccinated for COVID-19 (ICD-10: Z28.310 = Unvaccinated, Z28.311 = Partially Vaccinated)
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select '4CE-COVID-NOTVAC', c.concept_code, c.local_code, 'observation_fact', 'concept_cd', '@', '@', 0, c.concept_code_name, '@'
		from dbo.FourCE_CodeMappings m
			cross apply (
				select null concept_code, null local_code, null concept_code_name where 1=0
				union select 'Unvaccinated', m.local_code+'Z28310', 'Unvaccinated for COVID-19'
				union select 'Unvaccinated', m.local_code+'Z28.310', 'Unvaccinated for COVID-19'
				union select 'PartiallyVaccinated', m.local_code+'Z28311', 'Partially vaccinated for COVID-19'
				union select 'PartiallyVaccinated', m.local_code+'Z28.311', 'Partially vaccinated for COVID-19'
			) c
		where m.concept_type='4CE-PREFIX' and m.concept_code in ('DIAG-ICD10');


-- Influenza vaccine
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	values ('4CE-OTHER-VACCINE', 'Influenza', 'ICD10PCS:3E01340', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		, ('4CE-OTHER-VACCINE', 'Influenza', 'ICD10:Z23', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		, ('4CE-OTHER-VACCINE', 'Influenza', 'CPT4:90460', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		, ('4CE-OTHER-VACCINE', 'Influenza', 'CPT4:90756', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		, ('4CE-OTHER-VACCINE', 'Influenza', 'CPT4:90685', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		, ('4CE-OTHER-VACCINE', 'Influenza', 'CPT4:90686', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		, ('4CE-OTHER-VACCINE', 'Influenza', 'CPT4:90688', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza Vaccine', '@')
		;

-- Other infectious disease tests (the test result is "POSITIVE" or "NEGATIVE")
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	values ('4CE-OTHER-TEST', 'InfluenzaPCR', 'LOINC:95422-2', 'observation_fact', 'concept_cd', '@', '@', 0, 'Influenza PCR Test', '@')
		, ('4CE-OTHER-TEST', 'RsvPCR', 'LOINC:40988-8', 'observation_fact', 'concept_cd', '@', '@', 0, 'Respiratory syncytial virus RSV PCR Test', '@')
		;


--##############################################################################
--##############################################################################
--### Mappings for other data you have about the patients
--##############################################################################
--##############################################################################


-- Get LOINC, RxNorm, and CPT4 codes from the i2b2 concept_dimension table
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select t.concept_type, x.concept_code, c.concept_cd, 'observation_fact', 'concept_cd', '@', '@', 0, x.concept_code, max(name_char)
		from dbo.concept_dimension c
			inner join (
				select null concept_type, null code_prefix where 1=0
				union select 'LAB-LOINC', 'LAB|LOINC:'
				union select 'LAB-LOINC', 'LOINC:'
				union select 'MED-RxNorm', 'MED|RXNORM:'
				union select 'MED-RxNorm', 'RXNORM:'
				union select 'MED-RxNorm', 'MED|RXCUI:'
				union select 'MED-RxNorm', 'RXCUI:'
				union select 'PROC-CPT', 'PROC|CPT4:'
				union select 'PROC-CPT', 'CPT4:'
			) t on c.concept_cd like t.code_prefix+'%'
			cross apply (select substring(c.concept_cd,len(t.code_prefix)+1,50) as concept_code) x
		group by t.concept_type, x.concept_code, c.concept_cd;



--##############################################################################
--##############################################################################
--### For i2b2, use the concept_dimension table to expand codes.
--### Note that this can take several minutes.
--##############################################################################
--##############################################################################


/*

-- For each concept, get all the parent paths
;with cte_concept_parent (parent_path,concept_cd,is_anchor) as (
	select concept_path, concept_cd, 1
		from dbo.concept_dimension
	union all
	select LEFT(parent_path, LEN(parent_path)-CHARINDEX('\', RIGHT(REVERSE(parent_path), LEN(parent_path)-1))), concept_cd, 0
		from cte_concept_parent
		where parent_path like '\%\%\%'
)
insert into dbo.FourCE_ConceptParentPath (parent_path,concept_cd)
	select distinct parent_path, concept_cd
	from cte_concept_parent
	where is_anchor=0;


-- Insert child codes for codes that are already in the CodeMappings table
insert into dbo.FourCE_CodeMappings (concept_type, concept_code, local_code, local_table, local_field, concept_units, local_units, scale_factor, concept_code_name, local_code_name)
	select m.concept_type, m.concept_code, p.concept_cd, m.local_table, m.local_field, m.concept_units, m.local_units, m.scale_factor, m.concept_code_name, m.local_code_name
	from dbo.FourCE_CodeMappings m
		inner join dbo.concept_dimension c
			on m.local_code=c.concept_cd
		inner join dbo.FourCE_ConceptParentPath p
			on c.concept_path=p.parent_path
	where m.local_table='observation_fact' and m.local_field='concept_cd'
		and m.concept_type in (
			'4CE-LAB-LOINC','4CE-VITAL-SIGN','4CE-MED-CLASS','4CE-PROC-GROUP',
			'4CE-COVID-DIAG','4CE-COVID-TEST','4CE-COVID-VACCINE','4CE-COVID-NOTVAC','4CE-OTHER-VACCINE'
		) and not exists (
			select *
			from dbo.FourCE_CodeMappings t
			where t.local_table='observation_fact' and t.local_field='concept_cd'
				and m.concept_type=t.concept_type
				and m.concept_code=t.concept_code
				and m.local_code=p.concept_cd
		);

*/


--##############################################################################
--##############################################################################
--### For i2b2, delete mappings to codes with no patients
--##############################################################################
--##############################################################################


/*

delete 
	from dbo.FourCE_CodeMappings
	where local_table='observation_fact' and local_field='concept_cd'
		and local_code not in (
			select concept_cd 
			from dbo.observation_fact with (nolock)
		);

*/

--##############################################################################
--##############################################################################
--### Custom local SQL
--##############################################################################
--##############################################################################


--------------------------------------------------------------------------------
-- Change concept prefix
--------------------------------------------------------------------------------

/*
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'LOINC:','LAB|LOINC:') where local_code like 'LOINC:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'RXNORM:','MED|RXNORM:') where local_code like 'RXNORM:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'NDC:','MED|NDC:') where local_code like 'NDC:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'ICD9:','DIAG|ICD9:') where local_code like 'ICD9:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'ICD10:','DIAG|ICD10:') where local_code like 'ICD10:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'ICD9PROC:','PROC|ICD9:') where local_code like 'ICD9PROC:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'ICD10PCS:','PROC|ICD10:') where local_code like 'ICD10PCS:%';
update dbo.FourCE_CodeMappings set local_code=replace(local_code,'CPT4:','PROC|CPT4:') where local_code like 'CPT4:%';
*/


--##############################################################################
--##############################################################################
--### Testing
--##############################################################################
--##############################################################################


/*

select concept_type, count(*)
from dbo.FourCE_CodeMappings
group by concept_type;

select top 1000 * 
from dbo.FourCE_CodeMappings
order by newid();

select distinct concept_type, left(local_code,charindex(':',local_code)) x
	from dbo.FourCE_CodeMappings
	where local_code like '%:%'
	order by 1, 2;

*/


END;
GO
