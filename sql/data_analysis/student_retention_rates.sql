/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Determine year on year student retention rates for each cohort
  Data Sources:
  - Primary and Junior Secondary School enrolment data: raw_data/20260522_KNBS_Primary and Junior School Enrolment by Class and Gender.csv
  - Secondary school ernrolment data: raw_data/20260522_KNBS_Enrolment in Secondary Schools by Class and Gender.csv
  - Supplementary data source for data errors and gaps: visualizations
  Methodology: The starting grade size was indexed at 100%, and the subsequent year-over-year enrollment was tracked relative to that baseline. As a note, for 8-4-4 system cohorts where Grade 1 enrollment data was unavailable, the earliest available grade was used as the 100% reference point. This was to provide a sufficient sample size, as only two 8-4-4 cohorts had data starting at Grade 1 enrollment.
*/

-- Setting up a clean table for primary school enrolment
WITH primary_enrolment_data AS (
  SELECT
    CASE -- Standardized grade naming
      WHEN `Grade _ year of study __T_` = "Grade 6 (KPSEA)" THEN "Grade 6"
      WHEN (`Grade _ year of study __T_` = "Grade 7" OR `Grade _ year of study __T_` = "Standard 7") THEN "Grade/Std 7"
      WHEN (`Grade _ year of study __T_` = "Grade 8" OR `Grade _ year of study __T_` = "Standard 8") THEN "Grade/Std 8"
      ELSE `Grade _ year of study __T_`
    END AS grade,
    `Time period _2015_` AS year,
    CASE
      WHEN Observation LIKE "%.%.%" THEN CAST(REGEXP_REPLACE(Observation, r'(.*)\.(.*)\.(.*)', r'\1\2.\3') AS FLOAT64)*1000 -- Correcting an error that was discovered during data quality checks, where a number erroneously had 2 decimal points in it
      WHEN (`Grade _ year of study __T_` = "Grade 8" AND `Time period _2015_` = 2025) THEN 1232.3*1000 -- Manual correction done- the CSV dataset contained an outlier value. From reviewing the Economic Survey report from the same source (KNBS), it was clear that the CSV erroneously reported the total number of students enrolled for Junior Secondaty School (JSS) as the number of students enrolled for Grade 8 for the same year.
      ELSE CAST(Observation AS FLOAT64)*1000
      END AS enrolled_students
  FROM `capstone-project-497111.enrolment_data.primary_and_juniorsec_enrolment`
  WHERE
    `Sex _M_` = "Total" AND
    `Grade _ year of study __T_` <> "Total" AND NOT ( -- Since grade 7 & 8 are solely CBE terms, and Standard 7 and 8 are solely KCPE terms, excluded years when there should have been no enrolment for these grades / classes
    (`Grade _ year of study __T_` = "Grade 7" AND `Time period _2015_` < 2023) OR
    (`Grade _ year of study __T_` = "Grade 8" AND `Time period _2015_` < 2024) OR
    (`Grade _ year of study __T_` = "Standard 7" AND `Time period _2015_` > 2022) OR
    (`Grade _ year of study __T_` = "Standard 8" AND `Time period _2015_` > 2023))
),

-- Setting up a clean table for secondary school enrolment
secondary_enrolment_data AS (
  SELECT
    `Grade _ year of study __T_` AS grade,
    `Time period _2015_` AS year,
    CASE
      WHEN (`Time period _2015_`=2025 AND `Grade _ year of study __T_`="Grade 9 / Form 1") THEN 1149.8*1000 -- Populated missing data from the dataset, by cross-referencing the Economic Survey from the same source (KNBS)
      ELSE Observation*1000 
    END AS enrolled_students
  FROM `capstone-project-497111.enrolment_data.secondary_school_enrolment_data`
  WHERE
    `Sex _M_` = "Total" AND
    `Grade _ year of study __T_` <> "Total"
),

-- Combining the 2 datasets (primary and secondary school enrolment)

combined_enrolment_data AS (
SELECT
  year,
  grade,
  CASE
    WHEN grade="Grade 1" THEN 1
    WHEN grade="Grade 2" THEN 2
    WHEN grade="Grade 3" THEN 3
    WHEN grade="Grade 4" THEN 4
    WHEN grade="Grade 5" THEN 5
    WHEN grade="Grade 6" THEN 6
    WHEN grade="Grade/Std 7" THEN 7
    WHEN grade="Grade/Std 8" THEN 8
    WHEN grade="Grade 9 / Form 1" THEN 9
    WHEN grade="Grade 10 / Form 2" THEN 10
    WHEN grade="Grade 11 / Form 3" THEN 11
    ELSE 12
  END AS grade_number,
  enrolled_students
FROM
  primary_enrolment_data
  FULL OUTER JOIN secondary_enrolment_data
  USING (grade, year, enrolled_students)

),

-- Named cohorts by the year in which the cohort entered Grade 1
data_with_cohorts AS (
SELECT
  year,
  grade,
  grade_number,
  (year-grade_number+1) AS cohort,
  enrolled_students
FROM
  combined_enrolment_data
),

-- Determined the cohort start size as the earliest available enrollment data for that cohort
cohort_start_size AS (
  SELECT 
    cohort,
    enrolled_students AS cohort_start_size
  FROM data_with_cohorts AS d1
  WHERE d1.year = (
    SELECT MIN(d2.year) 
    FROM data_with_cohorts AS d2 
    WHERE d2.cohort = d1.cohort)
)

-- Combining all the data into 1 output table
SELECT
  dwc.year AS year,
  dwc.grade AS grade,
  dwc.grade_number AS grade_number,
  dwc.cohort AS cohort,
  dwc.enrolled_students AS enrolled_students,
  css.cohort_start_size AS cohort_start_size,
  round((dwc.enrolled_students / css.cohort_start_size)*100,2) AS percentage_of_cohort_start_size
FROM
  data_with_cohorts AS dwc
  FULL OUTER JOIN cohort_start_size AS css
  USING (cohort)
ORDER BY
  year ASC,
  grade_number ASC
