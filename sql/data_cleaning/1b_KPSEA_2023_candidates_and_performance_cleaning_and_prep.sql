/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Data cleaning and preparation of the KPSEA 2023 candidates by subject data
  Dataset: raw_data/20260612_KNEC_2023 KPSEA Performance and Candidates Per Subject Table Extract.csv
*/

-- Prep work: Cleaning up column naming and immediately identifiable errors in the data table
WITH cleaned_2023_KPSEA_performance_data AS (
	SELECT -- formatting field names in snake_case
	  `Subject` AS subject,
    `KR-20 Reliability Coefficient` AS reliability_coefficient,
    `ALL_Sat` AS total_no_students, -- The total number of students who sat for the subject's exam
    `ALL_Mean` AS mean_scores_all_students, -- The mean scores for the subject, across all students in the country who sat for the exam
    `ALL_SD` AS standard_dev_all_students, -- The standard deviation from the mean scores for the subject, across all students in the country who sat for the exam
    `GIRLS_Sat` AS no_female_students,
    `GIRLS_Mean` AS mean_scores_female_students,
    `GIRLS_SD` AS standard_dev_female_students,
    `BOYS_Sat` AS no_male_students,
    `BOYS_Mean` AS mean_scores_male_students,
    `BOYS_SD` AS standard_dev_male_students
	FROM 
	  `capstone-project-497111.performance_data.2023_KPSEA_performance_candidates_per_subj`
),

-- Data quality checks
-- 1. Checking data completeness
data_quality_metrics AS (
  SELECT
  -- Checking for nulls in key fields needed for analyses
    COUNTIF(subject IS NULL) AS null_subjects,
    COUNTIF(reliability_coefficient IS NULL) AS null_reliability_coefficients,
    COUNTIF(total_no_students IS NULL) + COUNTIF(no_female_students IS NULL) + COUNTIF(no_male_students IS NULL) AS null_no_of_students,
    COUNTIF(mean_scores_all_students IS NULL) + COUNTIF(mean_scores_female_students IS NULL) + COUNTIF(mean_scores_male_students IS NULL) AS null_performance_data,
    COUNTIF(standard_dev_all_students IS NULL) + COUNTIF(standard_dev_female_students IS NULL) + COUNTIF(standard_dev_male_students IS NULL) AS null_standard_dev_data,

  -- Listing out all subjects reported on, to confirm completeness
    ARRAY_AGG(DISTINCT subject ORDER BY subject ASC) AS unique_subjects,
	
-- 2. Checking for duplicates
  (SELECT
    SUM(no_of_records_per_subject)
  FROM
    (SELECT
      subject,
      COUNT(*) AS no_of_records_per_subject
    FROM
      cleaned_2023_KPSEA_performance_data
    GROUP BY
      subject)
  WHERE
    no_of_records_per_subject > 1) AS no_of_duplicates,

-- 3. Data range checks
  -- Checking for any negative values
      COUNTIF(reliability_coefficient < 0) +
      COUNTIF(total_no_students<0) + COUNTIF(mean_scores_all_students < 0) + COUNTIF(standard_dev_all_students < 0) +
      COUNTIF(no_female_students<0) + COUNTIF(mean_scores_female_students < 0) + COUNTIF(standard_dev_female_students < 0) +
      COUNTIF(no_male_students<0) + COUNTIF(mean_scores_male_students < 0) + COUNTIF(standard_dev_male_students < 0) +

      -- Checking for any reliability coefficients above 1
      COUNTIF(reliability_coefficient >1)
    AS no_out_of_bounds_values
  FROM
    cleaned_2023_KPSEA_performance_data
)

-- Outputs the findings from the above checks
SELECT
  *
FROM
  data_quality_metrics
