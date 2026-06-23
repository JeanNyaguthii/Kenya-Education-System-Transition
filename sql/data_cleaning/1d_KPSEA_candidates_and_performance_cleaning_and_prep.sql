/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Data cleaning and preparation of data on the number of exam centres and candidates for KPSEA
  Dataset: raw_data/20260522_KNBS_Assessment Centres, Learners by Gender and Performance level by Subject in Grade 6 KPSEA.csv
*/

-- Prep work: Cleaning up column naming and immediately identifiable errors in the data table
WITH cleaned_KPSEA_data AS (
	SELECT 
	  `Frequency _A_` AS frequency,
	  `Statistical unit _ASS_CENT_` AS data_metric,
	  `Sex __Z_` AS gender,
	  `Unit of measure _NUMBER_` AS uom,
	  `Time period _2022_` AS year,
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
	  capstone-project-497111.performance_data.KPSEA_assessmentcentres_candidates),

-- 1. Checking data completeness
data_completeness AS (
  SELECT
  -- Checking for nulls in key fields needed for analyses
    COUNTIF(data_metric IS NULL) AS null_data_metrics,
    COUNTIF(gender IS NULL) AS null_genders,
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
  FROM
    cleaned_KPSEA_data),

-- Checking for any data metrics where a year of reporting is missing
data_metrics_missing_year_data AS(
  SELECT
    data_metric,
    COUNT(DISTINCT year) AS no_years_reported_on
  FROM 
    cleaned_KPSEA_data
  GROUP BY 
    data_metric
  HAVING 
    no_years_reported_on < (SELECT COUNT (DISTINCT year) FROM cleaned_KPSEA_data)
    
  ),
	
	-- Checking for any years where one of the 3 gender metrics (male, female, total) is missing from the data metrics on registered candidates and candidates who sat for KPSEA
records_missing_gender_data AS(
  SELECT
    year,
    data_metric,
    COUNT(DISTINCT gender) AS no_gender_metrics_reported_on
  FROM 
    cleaned_KPSEA_data
  WHERE
    data_metric = "Registered Grade 6 KPSEA Learners" OR data_metric = "Learners who sat for Grade 6 KPSEA"
  GROUP BY 
    year,
    data_metric
  HAVING 
    no_gender_metrics_reported_on < 
    (SELECT 
       COUNT (DISTINCT gender)
     FROM cleaned_KPSEA_data
     WHERE data_metric = "Registered Grade 6 KPSEA Learners" OR data_metric = "Learners who sat for Grade 6 KPSEA")

),

-- 2. Checking for duplicates
duplicates_check AS (
  SELECT
    ARRAY_TO_STRING([data_metric, gender, CAST(year AS string), CAST(value AS string)],"_") AS unique_identifier,
    COUNT(*) AS no_of_records_per_unique_identifier
  FROM
    cleaned_KPSEA_data
  GROUP BY
    unique_identifier
  HAVING
    no_of_records_per_unique_identifier > 1
),

-- 3. Data range check
out_of_bounds_values AS (
  SELECT
    COUNTIF(value < 0) AS negative_values,
    COUNTIF(TRUNC(value)<>value) AS non_integer_candidate_and_assessment_centre_values
  FROM
    cleaned_KPSEA_data
),

-- 4. Checking for contradictory data
contradictions_check AS (
  SELECT
    ARRAY_TO_STRING([data_metric, gender, CAST(year AS string)],"_") AS value_identifier,
    COUNT(*) AS no_of_values_per_value_identifier
  FROM
    cleaned_KPSEA_data
  GROUP BY
    value_identifier
  HAVING
    no_of_values_per_value_identifier > 1
),

-- 5. Checking for inconsistent data
-- This table creates a column for reported number of male, female and total students per year for the data metrics on registered candidates, and candidates who sat for KPSEA
registered_and_sitting_candidates_per_year AS (
  SELECT
    year,
    data_metric,
    SUM(CASE WHEN gender = "Male" THEN value ELSE 0 END) AS no_males_reported,
    SUM(CASE WHEN gender = "Female" THEN value ELSE 0 END) AS no_females_reported,
    SUM(CASE WHEN gender = "Total" THEN value ELSE 0 END) AS total_candidates_reported,
    SUM(CASE WHEN gender = "Male" THEN value ELSE 0 END) + SUM(CASE WHEN gender = "Female" THEN value ELSE 0 END) AS total_candidates_calculated
  FROM
    cleaned_KPSEA_data
  WHERE
    data_metric = "Registered Grade 6 KPSEA Learners" OR data_metric = "Learners who sat for Grade 6 KPSEA"
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

-- Checking for any data reported before the year 2022 (The KPSEA exam was first sat in this year)
no_records_before_KPSEA_start AS (
  SELECT
    COUNT(value) AS no_records_before_2022
  FROM
    cleaned_KPSEA_data
  WHERE
    year < 2022
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
  FROM cleaned_KPSEA_data
)

SELECT
  *,
  (SELECT COUNT(*) FROM data_metrics_missing_year_data) AS no_data_metrics_missing_year_data,
  (SELECT COUNT(*) FROM records_missing_gender_data) AS no_records_missing_gender_data,
  (SELECT COUNT(*) FROM duplicates_check) AS no_of_duplicates,
  (SELECT COUNT(*) FROM contradictions_check) AS no_of_contradictory_records
FROM
  data_completeness, out_of_bounds_values, inconsistent_data, no_records_before_KPSEA_start, remarks
