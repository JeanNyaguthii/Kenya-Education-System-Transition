/*
  Project: Kenya Education System Transition Analaysis | Capstone Project
  Purpose: Aggregate KCPE annual data to assess year-over-year trends
  Data Sources:
  - KCPE mean scores: raw_data/20260522_KNBS_Examination Centres, Candidates by Gender and Mean Scores by Subject in KCPE.csv
  - KCPE mean scores (2015-2017): raw_data/20260623_KNBS_2019 Economic Survey.pdf
  Methodology: National mean scores were pulled from KNBS data.
*/

SELECT
  `Sex _M_` AS gender,
  `Breakdown group identifier __Z_` AS data_metric,
  `Time period _2015_` AS year,

-- National mean scores are extracted from the KNBS "Examination Centres, Candidates by Gender and Mean Scores by Subject in KCPE" dataset. The dataset is missing 2015-2017 data for this metric. Missing records are populated below from the KNBS 2019 Economic Survey. Both sources linked above

  CASE 
    WHEN `Time period _2015_` = 2015 then 52.78
    WHEN `Time period _2015_` = 2016 then 52.98
    WHEN `Time period _2015_` = 2017 then 52.16
    ELSE Observation
  END AS national_mean_score

FROM `capstone-project-497111.performance_data.KCPE_examcentres_candidates_performance`

WHERE
  `Statistical unit _REG_KCPE_` = "Subject" AND
  `Sex _M_` = "Total" AND
  `Breakdown group identifier __Z_` = "National Mean Score"

ORDER BY
  year ASC
