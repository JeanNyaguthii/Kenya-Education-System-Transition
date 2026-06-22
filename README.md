# Data Analytics Capstone: Kenya Education System Transition
A data-driven review of student performance and transition rates following the implementation of the new Competency-Based Education (CBE) system in Kenya.

## Project Overview
This project serves as my capstone project, as part of [Google's Data Analytics Professional Certificate course](https://www.coursera.org/professional-certificates/google-data-analytics). Rather than using course-provided datasets, I chose to independently source and analyze data on the rollout of the Competency-Based Education (CBE) system in Kenya. This approach allowed me to demonstrate an end-to-end data analytics workflow— from problem framing and data sourcing to transformation and strategic visualization and presentation— while aligning the project with my career goal of leveraging data to drive systemic social change.

My key analytical objectives were:

1. Performance assessment: Analyzing assessment results to evaluate early performance trends under the new curriculum.
2. Enrollment mapping: Mapping student progression through the new system, with a specific focus on the transition from Grade 6 (end of primary) to Grade 7 (Junior Secondary School).

Additional contextual background on the system transition can be found in this Context Document <link>.

## Tools used
* **Data preparation & processing:** BigQuery (SQL), Spreadsheets
* **Exploratory data analysis:** BigQuery (SQL)
* **Data visualization:** Tableau
* **Documentation and presentation:** GitHub

## Data preparation & processing
#### Data sourcing
I primarily used official data from the [Kenya National Bureau of Statistics (KNBS) Open Data Portal](https://opendata.knbs.or.ke/beta/databrowser/). As the official national statistical office for Kenya, KNBS is mandated to manage and provide quality statistics for public use. To supplement a data gap identified during data analysis, I integrated data from a publication by the Kenya National Examinations Council (KNEC).

In total, 7 raw files were used:

* 5 CSV files: Containing assessment performance and student enrollment data.
* 2 PDF reports: Utilized to reconcile data discrepancies:
** KNEC KPSEA National Report 2023: Used to determine subject-level candidate numbers.
** KNBS 2026 Economic Survey: Used to validate and correct 2025 enrollment data for the Grade 9/Form 1 cohort. (During analysis, an outlier was identified in the CSV data, which upon investigation, was found to report the total number of Junior Secondaty School (JSS) students rather than the Grade 9/Form 1 students).

All raw source files are available in the [raw data folder](Kenya-Education-System-Transition/raw_data).

#### Data cleaning & validation
To ensure data integrity, the datasets were subjected to the cleaning and validation checks for data completeness, duplicates, consistency and validity based on expected ranges. Remarks were also reviewed to ensure any relevant context was considered. The table below captures the finding from this data cleaning & validation exercise:



## 📊 Key Findings
* **[Finding 1]:** (e.g., Performance in Mathematics showed a X% variance across rural vs. urban districts.)
* **[Finding 2]:** (e.g., Transition challenges are most pronounced in [specific category] during the first two years.)
* **[Finding 3]:** (e.g., Identified a correlation between [Variable A] and [Variable B] that suggests a need for targeted policy intervention.)

## 📈 Visualizations
![Overview of Findings](visualizations/dashboard_overview.png)
*[Link to your interactive Tableau Public Dashboard here](https://your-tableau-link-here)*

## 📂 Project Structure
* `/sql`: Contains the cleaning and analysis queries used to transform the raw data.
* `/visualizations`: Contains exported snapshots of the final Tableau dashboard.
* `/docs`: Detailed project report and methodology.
