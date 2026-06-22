/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Data cleaning and preparation of the KPSEA performance dataset
  Dataset: raw_data/20260522_KNBS_Performance level by Subject in Grade 6 KPSEA.csv
*/

-- Prep work: Cleaning up column naming and errors in the data table
WITH cleaned_KPSEA_performance_data AS (
SELECT -- formatting field names in snake_case
	`Frequency` AS frequency,
	`Statistical unit` AS performance_level,
	`Unit of measure` AS uom,
	`Breakdown group identifier` AS subject,
	`Time period` AS year,
	`Observation` AS value,
	`Observation status` AS observation_status,
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
  	capstone-project-497111.performance_data.KPSEA_performance
),

-- 1. Checking data completeness
data_completeness AS (
SELECT
  -- Checking for nulls in key fields needed for analyses
    COUNTIF(performance_level IS NULL) AS null_performance_levels,
    COUNTIF(subject IS NULL) AS null_subjects,
    COUNTIF(year IS NULL) AS null_years,
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

  -- Listing out all subjects reported on, to confirm completeness
    ARRAY_AGG(DISTINCT subject ORDER BY subject ASC) AS unique_subjects
  
FROM
    cleaned_KPSEA_performance_data),

	-- Checking for any subjects where a year of reporting is missing
subjects_missing_year_data AS(
SELECT
	subject,
	COUNT(DISTINCT year) AS no_years_reported_on
FROM 
	cleaned_KPSEA_performance_data
GROUP BY 
	subject
HAVING 
	no_years_reported_on < (SELECT count (DISTINCT year) FROM cleaned_KPSEA_performance_data)
),
	
-- 2. Checking for duplicates
duplicates_check AS (
SELECT
	ARRAY_TO_STRING([CAST(year AS string), performance_level, subject, CAST(value AS string)],"_") AS unique_identifier,
    COUNT(*) AS no_of_records_per_unique_identifier
FROM
    cleaned_KPSEA_performance_data
GROUP BY
    unique_identifier
HAVING
    no_of_records_per_unique_identifier > 1
),

-- 3. Data range checks
-- Confirming performance data is within the expected range (between 0% and 100%)
out_of_bounds_values AS (
SELECT
	COUNTIF(value < 0) + COUNTIF(value>100) AS no_out_of_bounds_values
FROM
    cleaned_KPSEA_performance_data
),

-- This table confirms that the performance levels used are only the 4 expected for the KPSEA (Below Expectation, Approaching Expectation, Meeting Expectation, Exceeding Expectation)
performance_levels_reported_on AS (
SELECT
    ARRAY_AGG(DISTINCT performance_level) AS performance_levels_reported_on
FROM
    cleaned_KPSEA_performance_data
),

-- 4. Checking for contradictory data (more than 1 value reported for the same performance level, subject and year
contradictions_check AS (
SELECT
    ARRAY_TO_STRING([CAST(year AS string), performance_level, subject],"_") AS value_identifier,
    COUNT(*) AS no_of_values_per_value_identifier
FROM
	cleaned_KPSEA_performance_data
GROUP BY
    value_identifier
HAVING
    no_of_values_per_value_identifier > 1
),

-- 5. Checking for inconsistent data
-- This table creates a column showing the sum of all performance levels per subject per year (since the data is in a distribution format, this should always sum to 100%)
sum_performance_data_per_subject_per_year AS (
SELECT
    SUM (value) AS distribution_total
FROM
	cleaned_KPSEA_performance_data
GROUP BY 
	year,
    subject
),
  
-- This table then checks above table for cases where the distribution total per subject per year is not equal to 100
inconsistent_data AS(
SELECT
    COUNT(*) AS no_inconsistencies,
FROM
    sum_performance_data_per_subject_per_year
WHERE
    ROUND(distribution_total) <> 100
),

-- 6. Checking for any remarks in the remarks columns that could affect how we use the data
remarks AS (
SELECT
    ARRAY_AGG (DISTINCT frequency IGNORE NULLS) AS reporting_frequency,
    ARRAY_AGG (DISTINCT uom IGNORE NULLS) AS units_of_measure,
    ARRAY_AGG (DISTINCT observation_status IGNORE NULLS) AS remarks_on_values,
    ARRAY_AGG (DISTINCT unit_multiplier IGNORE NULLS) AS value_multipliers,
    ARRAY_AGG (DISTINCT note_for_statistical_unit IGNORE NULLS) AS remarks_on_performance_levels,
    ARRAY_AGG (DISTINCT note_for_reference_sector IGNORE NULLS) AS remarks_on_reference_sector,
    ARRAY_AGG (DISTINCT note_for_breakdown_group IGNORE NULLS) AS remarks_on_subjects,
    ARRAY_AGG (DISTINCT note_for_dataset IGNORE NULLS) AS remarks_on_dataset,
    ARRAY_AGG (DISTINCT reference_period_details IGNORE NULLS) AS remarks_on_reporting_year,
    ARRAY_AGG (DISTINCT note_for_education_level IGNORE NULLS) AS remarks_on_education_level,
    ARRAY_AGG (DISTINCT time_period_details IGNORE NULLS) AS remarks_on_reporting_time_period,
    ARRAY_AGG (DISTINCT source IGNORE NULLS) AS data_source_details
FROM 
	cleaned_KPSEA_performance_data
)

-- Outputs the findings from all the above checks
SELECT
  *,
  (SELECT COUNT(*) FROM subjects_missing_year_data) AS no_subjects_missing_year_data,
  (SELECT COUNT(*) FROM duplicates_check) AS no_of_duplicates,
  (SELECT COUNT(*) FROM contradictions_check) AS no_of_contradictory_records
FROM
  data_completeness, out_of_bounds_values, performance_levels_reported_on, inconsistent_data, remarks
