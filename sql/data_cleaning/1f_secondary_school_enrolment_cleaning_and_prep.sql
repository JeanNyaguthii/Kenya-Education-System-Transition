/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Data cleaning and preparation of secondary school enrolment data
  Dataset: raw_data/20260522_KNBS_Enrolment in Secondary Schools by Class and Gender.csv
*/

-- Prep work: Cleaning up column naming and immediately identifiable errors in the data table
WITH cleaned_secondary_enrolment_data AS (
	SELECT -- formatting field names in snake_case
	  `Frequency _A_` AS frequency,
	  `Grade _ year of study __T_` AS grade_or_class,
	  `Sex _M_` AS gender,
	  `Unit of measure _NUMBER_` AS uom,
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
	  capstone-project-497111.enrolment_data.secondary_school_enrolment_data
),

-- 1. Checking data completeness
data_completeness AS (
  SELECT
  -- Checking for nulls in key fields needed for analyses
    COUNTIF(grade_or_class IS NULL) AS null_grades,
    COUNTIF(gender IS NULL) AS null_genders,
    COUNTIF(year IS NULL) AS null_years,
    COUNTIF(value IS NULL) AS null_values,
    COUNTIF(unit_multiplier IS NULL) AS null_multipliers,

  -- Checking that all expected years are reported on
    MIN(year) AS first_reporting_year,
    MAX(year) AS final_reporting_year,
    CASE
    WHEN COUNT(DISTINCT year) = (MAX(year)-MIN(year)+1)
      THEN "Yes"
      ELSE "No"
    END as every_year_in_range_reported_on,
    COUNT(DISTINCT year) AS no_years_reported,

  -- Checking that all grades / classes are reported on
    ARRAY_AGG(DISTINCT grade_or_class ORDER BY grade_or_class ASC) AS unique_grades_classes
  
  FROM
    cleaned_secondary_enrolment_data),

	-- Checking for any grades / classes where a year of reporting is missing
	grades_missing_year_data AS(
	  SELECT
	    grade_or_class,
	    COUNT(DISTINCT year) AS no_years_reported_on
	  FROM 
	    cleaned_secondary_enrolment_data
    GROUP BY 
	    grade_or_class
	  HAVING 
	    no_years_reported_on < (SELECT COUNT (DISTINCT year) FROM cleaned_secondary_enrolment_data)
    
  ),
	
	-- Checking for any grades / classes (and corresponding years) where one of the 3 gender metrics (male, female, total) is missing
	records_missing_gender_data AS(
	  SELECT
	    year,
	    grade_or_class,
	    COUNT(DISTINCT gender) AS no_gender_metrics_reported_on
	  FROM 
	    cleaned_secondary_enrolment_data
	  GROUP BY 
	    year,
	    grade_or_class
	  HAVING 
	    no_gender_metrics_reported_on < (SELECT COUNT (DISTINCT gender) FROM cleaned_secondary_enrolment_data)

),

-- 2. Checking for duplicates
duplicates_check AS (
  SELECT
    ARRAY_TO_STRING([CAST(year AS string),grade_or_class, gender, CAST(value AS string)],"_") AS unique_identifier,
    COUNT(*) AS no_of_records_per_unique_identifier
  FROM
    cleaned_secondary_enrolment_data
  GROUP BY
    unique_identifier
  HAVING
    no_of_records_per_unique_identifier > 1
),

-- 3. Data range check: Confirming enrolment data is not a negative number, or a non-integer value
out_of_bounds_values AS (
  SELECT
    COUNTIF(value < 0) AS negative_values,
    COUNTIF(TRUNC(value*1000)<>(value*1000)) AS non_integer_values -- Multiplied by 1000 as this is indicated as the multiplier for all values
  FROM
    cleaned_secondary_enrolment_data
),

-- 4. Checking for contradictory data
contradictions_check AS (
  SELECT
    ARRAY_TO_STRING([CAST(year AS string), grade_or_class, gender],"_") AS value_identifier,
    COUNT(*) AS no_of_values_per_value_identifier
  FROM
    cleaned_secondary_enrolment_data
  GROUP BY
    value_identifier
  HAVING
    no_of_values_per_value_identifier > 1
),

-- 5. Checking for inconsistent data
-- This table creates a column for reported number of male, female and total students per grade per year
enrolment_per_grade_per_year AS (
  SELECT
    year,
    grade_or_class,
    SUM(CASE WHEN gender = "Male" THEN value*1000 ELSE 0 END) AS males_enrolled,
    SUM(CASE WHEN gender = "Female" THEN value*1000 ELSE 0 END) AS females_enrolled,
    SUM(CASE WHEN gender = "Total" THEN value*1000 ELSE 0 END) AS reported_total_enrolment,
    SUM(CASE WHEN gender = "Male" THEN value*1000 ELSE 0 END) + SUM(CASE WHEN gender = "Female" THEN value*1000 ELSE 0 END) AS calculated_total_enrolment
  FROM
    cleaned_secondary_enrolment_data
  GROUP BY 
    year,
    grade_or_class
),
  
-- This table then checks above table for cases of inconsistency between the sum of the reported number of female and male students enrolled per grade per year, vs. the reported number of the total number of enrolled students for the same grade and year
inconsistent_data AS(
  SELECT
    COUNT(*) AS no_inconsistencies,
    max(ABS(reported_total_enrolment-calculated_total_enrolment)) AS max_abs_variance,
    max((ABS(reported_total_enrolment-calculated_total_enrolment))/reported_total_enrolment)*100 AS max_perc_variance
  FROM
    enrolment_per_grade_per_year
  WHERE
    calculated_total_enrolment <> reported_total_enrolment
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
  FROM cleaned_secondary_enrolment_data
)

SELECT
  *,
  (SELECT COUNT(*) FROM grades_missing_year_data) AS no_grades_missing_year_data,
  (SELECT COUNT(*) FROM records_missing_gender_data) AS no_records_missing_gender_data,
  (SELECT COUNT(*) FROM duplicates_check) AS no_of_duplicates,
  (SELECT COUNT(*) FROM contradictions_check) AS no_of_contradictory_records
FROM
  data_completeness, out_of_bounds_values, inconsistent_data, remarks
