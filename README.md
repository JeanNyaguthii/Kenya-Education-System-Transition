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

## Data preparation
#### Data sourcing
I primarily used official data from the [Kenya National Bureau of Statistics (KNBS) Open Data Portal](https://opendata.knbs.or.ke/beta/databrowser/). As the official national statistical office for Kenya, KNBS is mandated to manage and provide quality statistics for public use. To supplement a data gap identified during data analysis, I integrated data from a publication by the Kenya National Examinations Council (KNEC).

In total, 7 raw files were used:
* 5 CSV files: Containing assessment performance and student enrollment data.
* 2 PDF reports: Utilized to reconcile data discrepancies:
** KNEC KPSEA National Report 2023: Used to determine subject-level candidate numbers.
** KNBS 2026 Economic Survey: Used to validate and correct 2025 enrollment data for the Grade 9/Form 1 cohort. (During analysis, an outlier was identified in the CSV data, which upon investigation, was found to report the total number of Junior Secondaty School (JSS) students rather than the Grade 9/Form 1 students).

All raw source files are available in the [raw data folder](/raw_data).

#### Data preparation
To ensure data integrity, the datasets were checked for completeness, duplicates, consistency and validity based on expected data ranges and types. Remarks within the datasets were also reviewed to ensure any relevant context was considered in the analysis. The table below captures the findings from the data preparation work.


|Dataset |	Data quality check |	Check done	| Status |	Findings |	Action taken
| :--- | :--- | :--- | :---: | :--- | :--- |
KPSEA performance |	Completeness |	NULL values |	🟢 |	0 null values in key data fields (performance levels, subjects, reporting year, value reported) |	-
KPSEA performance |	Completeness	|	Period coverage |	🟢 |	Data reported on for all 4 years when KPSEA has been sat to date (2022 to 2025) |	-
KPSEA performance |	Completeness	|	Subject coverage |	🟢 |	14 subjects reported on, as expected. Subjects reported on and naming used consistent in every reporting year |	-
KPSEA performance |	Duplicates	|	Duplicate records |	🟢 |	0 duplicate records |	-
KPSEA performance |	Data range	|	Out of bounds values |	🟢 |	0 instances of values reported outside of the expected range of score distribution (0% to 100%) |	-
KPSEA performance |	Data range |	Performance level coverage |	🟢 |	4 performance levels reported on align with KPSEA performance levels |	-
KPSEA performance	 | Contradictory data |	Contradictory data |	🟢 |	0 contradictory records (i.e., more than 1 value for the same data record) |	-
KPSEA performance | Consistency |	Sum of distribution of scores |	🟢 |	Sum of distribution of scores (per subject per year) was 100% in every instance |	-
KPSEA performance |	Remarks |	Remarks columns |	🟢 |	Findings from remarks columns:  • Data is reported on annually  • All values are reported on as a percentage value  • 2025 data is provisional  • The source of all the data is the Kenya National Bureau of Statistics |	-
| | | | | | |  
KPSEA 2023 candidates and performance |	Completeness |	NULL values |	🟢 |	0 null values in key data fields (subject, reliability coefficient, number of candidates, mean scores, standard deviation) |	-
KPSEA 2023 candidates and performance |	Completeness	|	Subject coverage |	🟢 |	14 subjects reported on, as expected |	-
KPSEA 2023 candidates and performance |	Duplicates	|	Duplicate records |	🟢 |	0 duplicate records |	-
KPSEA 2023 candidates and performance |	Data range	|	Out of bounds values |	🟢 |	0 instances of negative values or values reported outside of the expected ranges |	-
| | | | | | |  





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
