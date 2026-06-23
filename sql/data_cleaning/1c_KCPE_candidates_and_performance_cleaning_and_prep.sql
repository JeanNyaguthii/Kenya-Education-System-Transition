/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Data cleaning and preparation of data on the number of exam centres, candidates and mean scores for KCPE
  Dataset: raw_data/20260522_KNBS_Examination Centres, Candidates by Gender and Mean Scores by Subject in KCPE.csv
*/

-- Prep work: Cleaning up column naming and immediately identifiable errors in the data table
WITH cleaned_KCPE_data AS (
	SELECT -- formatting field names in snake_case
		`Frequency _A_` AS frequency,
		`Statistical unit _REG_KCPE_` AS data_metric,
		`Sex _M_` AS gender,
		`Unit of measure _NUMBER_` AS uom,
		`Breakdown group identifier __Z_` AS subject,
		`Time period _2015_` AS year,
		`Observation` AS value,
		`Observation Status` AS observation_status,
		`Unit Multiplier` AS unit_multiplier,
		`Note for Statistical Unit` AS note_for_statistical_unit,
		`Note for Reference Sector` AS note_for_reference_sector,
		`Note for Breakdown Group` AS note_for_breakdown_group,
		`Note for Dataset` AS note_for_dataset,
		`Reference Period Details` AS reference_period_details,
		`Note for Education Level` AS note_for_education_level,
		`Time Period Details` AS time_period_details,
		`Source` AS source
	FROM 
		capstone-project-497111.performance_data.KCPE_examcentres_candidates_performance),

-- 1. Checking data completeness
data_completeness AS (
	SELECT
	-- Checking for nulls in key fields needed for analyses
		COUNTIF(data_metric IS NULL) AS null_data_metrics,
		COUNTIF(gender IS NULL) AS null_genders,
		COUNTIF(year IS NULL) AS null_years,
		COUNTIF(subject IS NULL) AS null_subjects,
		COUNTIF(value IS NULL) AS null_values,
	
	-- Checking that all expected years are reported on
		MIN(year) AS first_reporting_year,
		MAX(year) AS final_reporting_year,
		CASE
		WHEN COUNT(DISTINCT year) = (MAX(year)-MIN(year)+1)
		  THEN "Yes"
	      ELSE "No"
	    END as every_year_in_range_reported_on,
	    COUNT(DISTINCT year) AS no_years_reported,

  -- Checking that all subjects are reported on
    	ARRAY_AGG(DISTINCT subject) AS unique_subjects
	FROM
		cleaned_KCPE_data),

  -- Checking for any data metrics where a year of reporting is missing
data_metrics_missing_year_data AS(
  	SELECT
		data_metric,
	    COUNT(DISTINCT year) AS no_years_reported_on
  	FROM 
	    cleaned_KCPE_data
    GROUP BY 
	    data_metric
  	HAVING 
	    no_years_reported_on < (SELECT COUNT (DISTINCT year) FROM cleaned_KCPE_data)
    
  ),

	-- Checking for any subjects where a year of reporting is missing
subjects_missing_year_data AS(
	SELECT
	    subject,
	    COUNT(DISTINCT year) AS no_years_reported_on
  	FROM 
	    cleaned_KCPE_data
    GROUP BY 
	    subject
  	HAVING 
	    no_years_reported_on < (SELECT COUNT (DISTINCT year) FROM cleaned_KCPE_data)
    
  ),
	
	-- Checking for any years where one of the 3 gender metrics (male, female, total) is missing from the 'Registered KCPE Candidates' and 'Candidates who sat for KCPE'
records_missing_gender_data AS(
	SELECT
	    year,
	    data_metric,
	    COUNT(DISTINCT gender) AS no_gender_metrics_reported_on
  	FROM 
	    cleaned_KCPE_data
    WHERE
  		data_metric = 'Registered KCPE Candidates' OR data_metric = 'Candidates who sat for KCPE'
  	GROUP BY 
	    year,
	    data_metric
  	HAVING 
		no_gender_metrics_reported_on < 
		(SELECT 
       	 	COUNT (DISTINCT gender)
     	 FROM cleaned_KCPE_data
     	 WHERE data_metric = 'Registered KCPE Candidates' OR data_metric = 'Candidates who sat for KCPE')
	
),

-- 2. Checking for duplicates
duplicates_check AS (
	SELECT
 		ARRAY_TO_STRING([data_metric, gender, subject, CAST(year AS string), CAST(value AS string)],"_") AS unique_identifier,
		COUNT(*) AS no_of_records_per_unique_identifier
	FROM
		cleaned_KCPE_data
	GROUP BY
		unique_identifier
	HAVING
		no_of_records_per_unique_identifier > 1
),

-- 3. Data range check
out_of_bounds_values AS (
	SELECT
		COUNTIF(value < 0) AS negative_values,
		COUNTIF(TRUNC(value)<>value AND data_metric <> "Subject") AS non_integer_candidate_and_assessment_centre_values, -- Checks for any non-integer values in the data metrics where integers are expected (registered number of candidates, number of candidates who sat for KCPE and number of assessment centres)
		COUNTIF(data_metric = "Subject" AND value>100) AS greater_than_100_mean_subject_values
	FROM
		cleaned_KCPE_data
),

-- 4. Checking for contradictory data
contradictions_check AS (
	SELECT
		ARRAY_TO_STRING([data_metric, gender, subject, CAST(year AS string)],"_") AS value_identifier,
    	COUNT(*) AS no_of_values_per_value_identifier
	FROM
    	cleaned_KCPE_data
	GROUP BY
    	value_identifier
	HAVING
    	no_of_values_per_value_identifier > 1
),

-- 5. Checking for inconsistent data
-- This table creates a column for reported number of male, female and total students per year for the data metrics on registered candidates, and candidates who sat for KCPE
registered_and_sitting_candidates_per_year AS (
	SELECT
	    year,
	    data_metric,
	    SUM(CASE WHEN gender = "Male" THEN value ELSE 0 END) AS no_males_reported,
	    SUM(CASE WHEN gender = "Female" THEN value ELSE 0 END) AS no_females_reported,
	    SUM(CASE WHEN gender = "Total" THEN value ELSE 0 END) AS total_candidates_reported,
	    SUM(CASE WHEN gender = "Male" THEN value ELSE 0 END) + SUM(CASE WHEN gender = "Female" THEN value ELSE 0 END) AS total_candidates_calculated
	FROM
    	cleaned_KCPE_data
	WHERE
    	data_metric = "Candidates who sat for KCPE" OR data_metric = "Registered KCPE Candidates"
	GROUP BY 
	    year,
	    data_metric
),
  
-- This table then checks above table for cases of inconsistency between the sum of the reported number of female and male candidates vs. the reported number of the total number of candidates for the same year
inconsistent_data AS(
	SELECT
		COUNT(*) AS no_inconsistencies,
  		max(ABS(total_candidates_reported-total_candidates_calculated)) AS max_abs_variance,
    	max((ABS(total_candidates_reported-total_candidates_calculated))/total_candidates_reported)*100 AS max_percentage_variance
	FROM
   	 	registered_and_sitting_candidates_per_year
	WHERE
    	total_candidates_reported<>total_candidates_calculated
),

-- Checking for any data reported after the year 2023 (The KCPE exam was discontinued after 2023- do not expect for there to be any data reported on after this year)
no_records_after_KCPE_discontinued AS (
	SELECT
    	COUNT(value) AS no_records_after_2023
	FROM
    	cleaned_KCPE_data
	WHERE
    	year > 2023
  ),


-- 6. Checking for any remarks in the remarks columns that could affect how we use the data
remarks AS (
	SELECT
	    ARRAY_AGG (DISTINCT frequency IGNORE NULLS) AS reporting_frequency,
	    ARRAY_AGG (DISTINCT uom IGNORE NULLS) AS units_of_measure,
	    ARRAY_AGG (DISTINCT observation_status IGNORE NULLS) AS remarks_on_values,
	    ARRAY_AGG (DISTINCT unit_multiplier IGNORE NULLS) AS value_multipliers,
	    ARRAY_AGG (DISTINCT note_for_statistical_unit IGNORE NULLS) AS remarks_on_statistical_units,
	    ARRAY_AGG (DISTINCT note_for_reference_sector IGNORE NULLS) AS remarks_on_reference_sector,
	    ARRAY_AGG (DISTINCT note_for_breakdown_group IGNORE NULLS) AS remarks_on_breakdown_group,
	    ARRAY_AGG (DISTINCT note_for_dataset IGNORE NULLS) AS remarks_on_dataset,
	    ARRAY_AGG (DISTINCT reference_period_details IGNORE NULLS) AS remarks_on_reporting_year,
	    ARRAY_AGG (DISTINCT note_for_education_level IGNORE NULLS) AS remarks_on_education_level,
	    ARRAY_AGG (DISTINCT time_period_details IGNORE NULLS) AS remarks_on_reporting_time_period,
	    ARRAY_AGG (DISTINCT source IGNORE NULLS) AS data_source_details
	FROM
		cleaned_KCPE_data
)

SELECT
  *,
  (SELECT COUNT(*) FROM data_metrics_missing_year_data) AS no_data_metrics_missing_year_data,
  (SELECT COUNT(*) FROM subjects_missing_year_data) AS no_subjects_missing_year_data,
  (SELECT COUNT(*) FROM records_missing_gender_data) AS no_records_missing_gender_data,
  (SELECT COUNT(*) FROM duplicates_check) AS no_of_duplicates,
  (SELECT COUNT(*) FROM contradictions_check) AS no_of_contradictory_records
FROM
  data_completeness, out_of_bounds_values, inconsistent_data, no_records_after_KCPE_discontinued, remarks
