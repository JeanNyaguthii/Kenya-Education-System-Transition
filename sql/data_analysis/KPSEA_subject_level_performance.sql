/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Aggregate KPSEA performance data by subject to assess year-over-year trends
  Data Sources:
  - Number of KPSEA candidates: raw_data/20260522_KNBS_Assessment Centres, Learners by Gender and Performance level by Subject in Grade 6 KPSEA.csv  
  - 2023 KPSEA candidature by subject: raw_data/20260612_KNEC_2023 KPSEA Performance and Candidates Per Subject Table Extract.csv
  - KPSEA subject performance: raw_data/20260522_KNBS_Performance level by Subject in Grade 6 KPSEA.csv

  Methodology: The raw datasets do not provide KPSEA performance organized into the 5 subjects (some of which are aggregate subjects) that are reported on for KPSEA. 
  This script organizes performance data into the 5 KPSEA subjects by calculating the weighted average performance by weighting subject-level scores against the number of candidates per subject. 
  This approach accounts for the fact that candidate participation levels differ across the 14 KPSEA subjects.

  Important note: Subject-level candidature data was only available for 2023. To maintain consistency, I calculated subject-specific candidate ratios for 2023 and applied them as a representative proxy for all other years in the analysis. 
*/

-- Using 2023 data to determine distribution of students across subjects
WITH students_per_subject_ratio AS (
	SELECT
		CASE -- Renaming subjects in the 2023 data to match the KNBS data
			WHEN Subject = "Science and Technology" THEN "Science"
			WHEN Subject = "Home Science" THEN "Nutrition"
			WHEN Subject = "Islamic Religious Education" THEN "Islamic Religios Education"
			ELSE Subject 
		END AS subject,
		(SUM(ALL_Sat) / 
  		(SELECT -- Query to get the total number of candidates who sat for KPSEA in 2023
  			Observation
		  FROM
			  capstone-project-497111.performance_data.KPSEA_assessmentcentres_candidates
		  WHERE
  			`Time period _2022_` = 2023 AND
  			`Statistical unit _ASS_CENT_` = "Learners who sat for Grade 6 KPSEA" AND
  			`Sex __Z_` = "Total")) AS ratio_of_all_candidates_who_took_subject
	FROM
		capstone-project-497111.performance_data.2023_KPSEA_performance_candidates_per_subj
	GROUP BY
		subject

),

-- Pulling subject-level performance for each year
KPSEA_performance_by_subject AS (
	SELECT
		`Statistical unit` AS performance_level,
		`Breakdown group identifier` AS subject,
		`Time period` AS year,
		`Observation` AS percent_of_students
	FROM capstone-project-497111.performance_data.KPSEA_performance
),

-- Combining the subject-level performance data, with candidature data
KPSEA_performance_data_with_multiplier AS (
	SELECT
		t1.subject,
		t2.ratio_of_all_candidates_who_took_subject,
		t1.year,
		t1.performance_level,
		t1.percent_of_students
	FROM KPSEA_performance_by_subject AS t1
	FULL OUTER JOIN students_per_subject_ratio AS t2
  ON t1.subject = t2.subject
),

-- Calculating the subject-level performance year on year, by calculating weighted averages (subject-level scores for the 5 KPSEA subjects, weighed against the candidate ratio for the subject)
subject_performance_by_level_by_year AS (
  SELECT
    CASE
			WHEN subject="Kiswahili Lugha" OR subject="Kenyan Sign Language" THEN "Kiswahili or KSL"
			WHEN subject="Science" OR subject="Agriculture" OR subject="Nutrition" OR subject="Physical and Health Education" THEN "Integrated Science"
			WHEN subject="Art and Craft" OR subject="Music" OR subject="Christian Religious Education" OR subject="Islamic Religios Education" OR subject="Hindu Religious Education" OR subject="Social Studies" THEN "Creative Arts and Social Studies"
			ELSE subject
		END AS KPSEA_subject,
		performance_level,
		year,
		SUM(percent_of_students * ratio_of_all_candidates_who_took_subject) / SUM(ratio_of_all_candidates_who_took_subject) AS perc_of_subjectstudents_at_performance_level
	FROM
		KPSEA_performance_data_with_multiplier
	GROUP BY
		performance_level,
		KPSEA_subject,
		year
	ORDER BY
		CASE performance_level
			WHEN "Below Expectation (%)" THEN 1
			WHEN "Approaching Expectation (%)" THEN 2
			WHEN "Meeting Expectation (%)" THEN 3
			ELSE 4
		END ASC,
		year ASC,
		KPSEA_subject ASC

)

SELECT
	*
FROM
	subject_performance_by_level_by_year
