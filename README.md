# Data Analytics Capstone: Kenya Education System Transition
A data-driven review of student performance and transition rates following the implementation of the new Competency-Based Education (CBE) system in Kenya.

## Project Overview
This project serves as my capstone project, as part of [Google's Data Analytics Professional Certificate course](https://www.coursera.org/professional-certificates/google-data-analytics). Rather than using course-provided datasets, I chose to independently source and analyze data on the rollout of the Competency-Based Education (CBE) system in Kenya. This approach allowed me to demonstrate an end-to-end data analytics workflow— from problem framing and data sourcing to transformation and strategic visualization and presentation— while aligning the project with my ultimate career goal of leveraging data to drive systemic social change.

My key analytical objectives were:

1. Performance assessment: Analyzing assessment results to evaluate early performance trends under the new curriculum.
2. Student retention mapping: Mapping student progression through the new system, with a specific interest in the transition from Grade 6 (end of Primary School) to Grade 7 (Junior Secondary School).

Some additional contextual background on the system transition can be found in this [context document](<docs/CBE Relevant Context .pdf>)

## Tools used
* **Data preparation & processing:** BigQuery (SQL), Spreadsheets
* **Exploratory data analysis:** BigQuery (SQL)
* **Data visualization:** Tableau
* **Documentation and presentation:** GitHub

## Data preparation
#### Data sourcing
I primarily used official data from the [Kenya National Bureau of Statistics (KNBS) Open Data Portal](https://opendata.knbs.or.ke/beta/databrowser/). As the official national statistical office for Kenya, KNBS is mandated to manage and provide quality statistics for public use. To supplement a data gap identified during data analysis, I integrated data from a publication by the Kenya National Examinations Council (KNEC). In total, 7 raw files were used:
* 5 CSV files: Containing assessment performance and student enrollment data.
* 2 PDF reports: Utilized to reconcile data discrepancies:
  * KNEC KPSEA National Report 2023: Used to determine subject-level candidate numbers.
  * KNBS 2026 Economic Survey: Used to validate and correct grade 8 enrolment data for the year 2025, and cross-reference and populate Grade 9/Form 1 enrolment data. <details> Grade 8 2025 enrolment data points were sourced from the KNBS Economic Survey because the CSV dataset contained outlier values that were flagged during the analysis phase. From reviewing both data soures, it was clear that the CSV erroneously reported the total number of students enrolled for Junior Secondaty School (JSS) as the number of students enrolled for Grade 8 for the same year. Grade 9/From 1 2025 enrolment data was missing from the CSVs, hence the need for cross-referencing and population from the KNBS Economic Survey data. </details>

All raw source files are available in the [raw data folder](/raw_data).

#### Data preparation
To confirm the data's reliability prior to use, the datasets were checked for completeness, duplicates, consistency and validity based on expected data ranges and types. Remarks within the datasets were also reviewed to ensure any relevant context was considered in the analysis. All data quality checks and cleaning was done in BigQuery, using SQL scripts. These can be found in the [SQL data_cleaning directory](sql/data_cleaning).

The table below captures the findings from the data preparation work.


|Dataset |	Data quality check |	Check done	| Status |	Findings |	Action taken
| :--- | :--- | :--- | :---: | :--- | :--- |
KPSEA performance |	Completeness |	NULL values |	🟢 |	0 null values in key data fields (performance levels, subjects, reporting year, value reported) |	-
KPSEA performance |	Completeness	|	Period coverage |	🟢 |	Data reported on for all 4 years when KPSEA has been sat to date (2022 to 2025) |	-
KPSEA performance |	Completeness	|	Subject coverage |	🟢 |	14 subjects reported on, which is the number of KPSEA subjects. <details> Agriculture, Art and Craft, Christian Religious Education, English Language, Hindu Religious Education, Islamic Religios Education, Kenyan Sign Language, Kiswahili Lugha, Mathematics, Music, Nutrition, Physical and Health Education, Science, Social Studies </details> Subjects reported on and naming used consistent in every reporting year |	-
KPSEA performance |	Duplicates	|	Duplicate records |	🟢 |	0 duplicate records |	-
KPSEA performance |	Data range	|	Out of bounds values |	🟢 |	0 instances of values reported outside of the expected range of score distribution (0% to 100%) |	-
KPSEA performance |	Data range |	Performance level coverage |	🟢 |	4 performance levels reported on align with KPSEA performance levels <details> Below Expectations, Approaching Expectations, Meeting Expectations, Above Expectations </details> |	-
KPSEA performance	 | Contradictory data |	Contradictory data |	🟢 |	0 contradictory records (i.e., more than 1 value for the same data record) |	-
KPSEA performance | Consistency |	Sum of distribution of scores |	🟢 |	Sum of distribution of scores (per subject per year) was 100% in every instance |	-
KPSEA performance |	Remarks |	Remarks columns |	🟢 |	Findings from remarks columns:  <br>• Data is reported on annually  <br>• All values are reported on as a percentage  <br>• 2025 data is provisional  <br>• The source of all the data is the Kenya National Bureau of Statistics |	-
| | | | | | |  
KPSEA 2023 candidates and performance |	Completeness |	NULL values |	🟢 |	0 null values in key data fields (subject, reliability coefficient, number of candidates, mean scores, standard deviation) |	-
KPSEA 2023 candidates and performance |	Completeness	|	Subject coverage |	🟢 |	14 subjects reported on, which is the number of KPSEA subjects <details> Agriculture, Art and Craft, Christian Religious Education, English Language, Hindu Religious Education, Home Science, Islamic Religious Education, Kenyan Sign Language, Kiswahili Lugha, Mathematics, Music, Physical and Health Education, Science and Technology, Social Studies </details> |	-
KPSEA 2023 candidates and performance |	Duplicates	|	Duplicate records |	🟢 |	0 duplicate records |	-
KPSEA 2023 candidates and performance |	Data range	|	Out of bounds values |	🟢 |	0 instances of negative values or values reported outside of the expected ranges |	-
| | | | | | |  
No. of exam centres, candidates and mean scores for KCPE |	Completeness |	NULL values |	🔴 |	62 null values found <br> 🟢 36 explainable <br> • 11 records: duplicates of the "Kiswahili" subject under the subject name "Kiswahili lugha". The null records under this duplicate name can be disregarded with no impact <br>  • 25 records: 2024 & 2025 records across subject/national means (18), candidate registration/attendance (6) and number of exam centres (1). This is to be expected considering final KCPE exam was sat in 2023 <br> 🔴 26 inexplicable data gaps <br>  • 11 records: Mean score data missing entirely for 'English language' subject <br>  • 15 records: Data missing entirely for national mean scores (3), number of assessment centres (3), and candidates who sat for KCPE (9) in the years 2015-2017 |	• Gaps in the 2015-2017 records were filled by cross-referencing the [KNBS 2019 Economic Survey Report](</raw_data/20260623_KNBS_2019 Economic Survey.pdf>) <br> • English language data gap identified would have no impact on the analysis within the scope of this project. As a result, no action was required
No. of exam centres, candidates and mean scores for KCPE |	Completeness |	Period coverage |	🔴 |	Data reported on 11 years (2015 to 2025) <br> 🔴 7 records of non-null data populated for 2025, despite the KCPE exam being officially discontinued after 2023. Affected Metrics: Registered candidates (3), candidates who sat for exam (3), and exam centre numbers (1) |	All analyses conducted using this dataset excluded any data from years after 2023
No. of exam centres, candidates and mean scores for KCPE |	Completeness |	Subject coverage |	🟠 |	10 subjects reported on, though the official KCPE exam only consists of 5. <details> English Language, English Composition, Kiswahili, Kiswahili Lugha, Kiswahili Insha, Mathematics, Science, Social Studies and Religious Education, Social Studies, Religious Education </details> Discrepancy arises from three issues: <br> • Subject breakdown: English and Kiswahili are split into individual papers (Language/Composition and Lugha/Insha), rather than reported as single subjects <br> • Subject name duplicate: Records of both "Kiswahili" and "Kiswahili lugha" as subjects; these are the same subject  <br> • Doublecounting: Social Studies and Religious Education are listed as both individual rows and a single combined score. <br><br>  Subjects reported on and naming used the same in every reporting year |	• Subject breakdown: Combined individual papers into one score per subject  <br>• Subject name duplicate: “Kiswahili lugha” records disregarded as all values under this subject name were NULL  <br>• Double counting: Used only single subject combined score, to avoid double counting and ensure accurate totals
No. of exam centres, candidates and mean scores for KCPE |	Completeness |	Gender coverage |	🟢 |	0 cases of missing gender data |	-
No. of exam centres, candidates and mean scores for KCPE |	Duplicates |	Duplicate records |	🟢 |	0 duplicate records |	-
No. of exam centres, candidates and mean scores for KCPE |	Data range |	Out of bounds values |	🟢 |	• 0 instances of negative values for number of candidates, assessment centres and mean scores <br> • 0 instances of non-integer candidate and assessment centre values <br> • 0 instances of mean scores greater than 100 |	-
No. of exam centres, candidates and mean scores for KCPE |	Contradictory data |	Contradictory data |	🟢 |	0 contradictory records (i.e., more than 1 value for the same data record) |	-
No. of exam centres, candidates and mean scores for KCPE |	Consistency |	Sum of male and female candidates vs. total |	🟢 |	0 instances where the sum of the number of female and male candidates did not equal the total number of candidates reported per metric per year |	-
No. of exam centres, candidates and mean scores for KCPE |	Remarks |	Remarks columns |	🟢 |	Findings from remarks columns: <br> • Data is reported on annually <br> • All values are reported on as a number  <br> • The source of all the data is the Kenya National Bureau of Statistics  <br> • 2025 data is provisional, though as above, unclear why there is any KCPE data from 2025 at all <br> • KCPE was not done in 2020 but was done in March 2021	 | -
| | | | | | |  
No. of exam centres and candidates for KPSEA |	Completeness |	NULL values |	🟢 |	0 null values in key data fields (data metric, gender, reporting year, value reported) |	-
No. of exam centres and candidates for KPSEA |	Completeness |	Period coverage |	🟢 |	Data reported on 4 years (2022 to 2025), which aligns with the period when the KPSEA exam has been administered |	-
No. of exam centres and candidates for KPSEA |	Completeness |	Gender coverage |	🟢 |	0 cases of missing gender data	-
No. of exam centres and candidates for KPSEA |	Duplicates |	Duplicate records |	🟢 |	0 duplicate records |	-
No. of exam centres and candidates for KPSEA |	Data range |	Out of bounds values |	🟢 |	0 instances of negative or non-integer values for number of candidates and assessment centres |	-
No. of exam centres and candidates for KPSEA |	Contradictory data |	Contradictory data |	🟢 |	0 contradictory records (i.e., more than 1 value for the same data record) |	-
No. of exam centres and candidates for KPSEA |	Consistency |	Sum of male and female candidates vs. total |	🟢 |	0 instances where the sum of the number of female and male candidates did not equal the total number of candidates reported per metric per year |	-
No. of exam centres and candidates for KPSEA |	Remarks |	Remarks columns |	🟢 |	Findings from remarks columns: <br>  • Data is reported on annually <br> • All values are reported on as a number <br> • The source of all the data is the Kenya National Bureau of Statistics <br> • 2025 data is provisional |	-
| | | | | | |  
Primary and JSS enrolment |	Completeness |	NULL values |	🟠 |	81 null values found <br> 🟢 66 explainable  <br> • 51 records: CBE grades’ enrolment records, prior to launch of enrolment for these grades <br>  • 15 records: 8-4-4 classes’ enrolment records, after phasing out of the system <br> 🟠 15 inexplicable data gaps <br> • 15 records: No total enrolment data provided for the years 2015-2019 |	Total enrolment data for 2015–2019 calculated by summing up the enrolment values of all individual grades
Primary and JSS enrolment |	Completeness |	Period coverage |	🟢 |	Data reported on 11 years (2015 to 2025). Data record is present for every grade level reported for all 11 years |	-
Primary and JSS enrolment |	Completeness |	Grade coverage |	🟠 |	10 grades and classes reported on: <br>🟢 Grades 1 to 6 (primary education in both 8-4-4 and CBE systems) <br> 🟢 Standard 7 and standard 8 (primary education in 8-4-4 system) <br> 🟢 Grades 7 & 8 (junior secondary education in CBE system) <br> 🟠 No data on Grade 9 enrolment, despite this being part of junior secondary education in the CBE system |	Data gap was found to be a data organization issue- Grade 9 enrolment data is available in the Secondary School enrolment dataset
Primary and JSS enrolment |	Completeness |	Gender coverage |	🟢 |	Each grade each year reported on as “no of males enrolled”, “no of females enrolled” and “total number of students enrolled” |	-
Primary and JSS enrolment |	Duplicates |	Duplicate records |	🟢 |	0 duplicate records|	-
Primary and JSS enrolment |	Data range |	Out of bounds values |	🟢 |	0 instances of negative or non-integer values|	-
Primary and JSS enrolment |	Contradictory data |	Contradictory data |	🟢 |	0 contradictory records (i.e., more than 1 value for the same data record)|-
Primary and JSS enrolment |	Consistency |	Unexpected enrolment data |	🟢 |	0 instances of unexpected enrolment data (Enrolment data for CBE grades, prior to CBE roll-out OR enrolment data for 8-4-4 systems after transition away from 8-4-4 system) | -
Primary and JSS enrolment |	Consistency |	Sum of male and female candidates vs. total |	🟠 |	20 cases where the sum of the number of reported female and male students enrolled did not equal the total number of candidates reported per grade per year <br> • Max. absolute variance: 700 students <br> • Max. % variance: 0.0093%	| With % variance of 0.0093%, error is considered negligible. For consistency, the provided totals were used as the total number of candidates (not calculated totals from summing the number of female and male candidates)
Primary and JSS enrolment |	Remarks |	Remarks columns |	🟢 |	Findings from remarks columns: <br>  • Data is reported on annually <br>  • All values are reported on as a number <br> • Multiplier for all numbers reported is thousands <br>  • 2025 data is provisional <br> • The source of all the data is the Kenya National Bureau of Statistics |	Applied thousands multiplier on all data used for analyses
| | | | | | |  
Secondary school enrolment |	Completeness |	NULL values |	🔴 |	3 null values found <br> 🔴 3 inexplicable data gaps <br>  • 3 records: Grade 9 / Form 1 enrolment for 2025 (male, female and total) |	Gaps in the dataset were filled by cross-referencing the [KNBS 2026 Economic Survey Report](</raw_data/20260614_KNBS_2026 Economic Survey Section 15 (Education).pdf>)
Secondary school enrolment |	Completeness |	Period coverage |	🟢 |	Data reported on 11 years (2015 to 2025). Data record is present for every grade level reported for all 11 years | -
Secondary school enrolment |	Completeness |	Grade coverage |	🟢 |	4 grades and forms reported on, as expected <details> • Grade 9 / Form 1 <br> • Grade 10 / Form 2 <br> • Grade 11 / Form 3 <br> • Grade 12 / Form 4 </details> |	-
Secondary school enrolment |	Completeness |	Gender coverage |	🟢 |	Each grade each year reported on as “no of males enrolled”, “no of females enrolled” and “total number of students enrolled”	| -
Secondary school enrolment |	Duplicates |	Duplicate records |	🟢 |	0 duplicate records |	-
Secondary school enrolment |	Data range |	Out of bounds values |	🟠 |	🟢 0 instances of negative values <br> 🟠 2 instances of non-integer values <details> • Grade 11/Form 3 females enrolled in 2023: 513299.99999999994 <br>  • Grade 11/Form 3 females enrolled in 2024: 513700.00000000006 </details>	| Rounded non-integer enrolment values to the nearest whole number
Secondary school enrolment |	Contradictory data |	Contradictory data |	🟢	| 0 contradictory records (i.e., more than 1 value for the same data record) |	-
Secondary school enrolment |	Consistency |	Sum of male and female candidates vs. total |	🟠 |	12 cases where the sum of the number of reported female and male students enroled did not equal the total number of candidates reported per grade per year <br> • Max. absolute variance: 100 students <br> • Max. % variance: 0.014%	| With % variance of 0.014%, error is considered negligible. For consistency, the provided totals were used as the total number of candidates (not calculated totals by summing the number of female and male candidates)
Secondary school enrolment |	Remarks |	Remarks columns |	🟢 |	Findings from remarks columns:  <br> • Data is reported on annually <br>  • All values are reported on as a number <br>  • Multiplier for all numbers reported is thousands <br>  • Data for 2020 is as at the Month of March 2020 <br>  • 2025 data is provisional <br>  • The source of all the data is the Kenya National Bureau of Statistics |	Applied thousands multiplier on all data used for analyses


## Data analysis and key observations
All data transformation and analysis was done in BigQuery, using SQL scripts. These are in the [SQL data_analysis directory](sql/data_analysis). The outputs of the analyses were visualized in Tableau, extracts of which are in the [visualizations directory](visualizations).

### KPSEA performance trends
The first part of the analysis focused on assessing student performance trends.

#### Aggregated KPSEA performance across all students
Subject-level KPSEA data was aggregated as a weighted average, accounting for the number of students assessed per subject, to evaluate performance trends since the launch of the KPSEA in 2022.

![Aggregated KSPSEA performance](<visualizations/Aggregated KPSEA performance.png>)


Key observations:
* **Declining performance trend:** Since its launch in 2022, there has been a notable shift in student distribution across the four performance levels. Majority (64%) of students achieved "Meeting" or "Exceeding" expectations performance levels in 2022. However, the combined share of these two performance levels dropped to 56% in 2023, an all-time low of 35% in 2024 and 39% in 2025.
* **Shift of student share to lower-performance levels:** The share of students at the "Approaching Expectations" performance level has consistently increased year on year, while the share of students in the "Meeting Expectations" level has consistently decreased.
* **2024 performance dip:** 2024 recorded the poorest performance to date, with a significant 21% of students performing at the "Below Expectation" performance level, and another 45% at the "Approaching Expectation" level- a combined total of 66% of students were not performing at the "Meeting Expectations" level or above.
* **Consistency in high achievement:** The share of students at the "Exceeding Expectations" level has remained quite stable, consistently comprising 13–14% of students, with the exception of an 8% dip in 2024.

#### Aggregated KCPE performance across all students
To provide broader context for the KPSEA results, historical data from the Kenya Certificate of Primary Education (KCPE)—the national exam marking the primary to highscool transition in the 8-4-4 system- was reviewed. While the KPSEA uses performance levels to assess performance, the phased-out KCPE exam was graded via subject-specific percentage scores and letter grades.

![Aggregated KCPE performance](<visualizations/KCPE Mean Scores.png>)

Key observations:
* **Performance stability:** Over the final nine years of the KCPE, performance remained stable, with national mean scores within a narrow range between 51.51 and 53.18. As per the [KNEC KCPE Result Guidelines](https://www.knec.ac.ke/wp-content/uploads/2023/11/KCPE-Results-Guidelines.pdf), over the period considered, the average mean scores consistently corresponded to a 'C' grade.

#### KPSEA performance by subject
Subject-level KPSEA performance data was reviewed, to gain insight on subject contributions towards the overall performance trends observed.
Important note: Subject-level candidature data was only available for 2023. As such, subject-specific candidate ratios were calculated for 2023, and applied as a representative candidate ratio proxy for the other years in the analysis.

![KPSEA Performance By Subject](<visualizations/KPSEA Performance By Subject.png>)

Key observations:
* **Declining performance trend:** Overall, performance trends across subjects mirror the aggregate downward trend, with 2024 marking the peak of students in lower-performance levels across nearly all subjects-- with the exception of Creative Arts and Social Sciences- where 2025 had the highest number of students at the "Below" or "Approaching" expectation levels.
* **Top-performing subject:** Kiswahilli / Kenya Sign Language (KSL) have consistently had the highest percentage of students in the top performance levels -"Meeting" or "Exceeding" expectations, though English overtook it slightly in 2025 (52% vs. 51%).
* **Poorest-performing subject:** Mathematics has recorded the highest persistent concentration of students in the "Below" or "Approaching" expectation levels, with the exception of 2025 where 66% of Creative Arts and Social Studies students were in these performance levels, against Mathematics' 64%.
* **Creative Arts and Social Studiees decline:** Creative Arts and Social Studies shows the most concerning trajectory, with a steady annual increase in the share of students in lower-performance levels and a corresponding decrease in the student share in higher-performance levels.

### Retention trends
The second component of the analysis was a review of student retention rates. To visualize this, retention curves were plotted for each cohort, indexing the starting grade size at 100% and tracking the subsequent year-over-year enrollment relative to that baseline. As a note, for 8-4-4 system cohorts where Grade 1 enrollment data was unavailable, the earliest available grade was used as the 100% reference point. This was to provide a sufficient sample size, as only two 8-4-4 cohorts had data starting at Grade 1 enrollment.

The retention rates were plotted in two graphs: one for 8-4-4 cohorts (Grade 1 entry prior to 2017) and one for CBE cohorts (Grade 1 entry from 2017 onwards).

![8-4-4 Student Retention Trends](<visualizations/8-4-4 Student Retention Rates.png>)

Key Observations:
* **Highschool transition drop:** Nearly all 8-4-4 student cohorts exhibit a visible drop in cohort size as they approach, and during, the transition from primary school (Standard 8) into highschool (Form 1).
* **Stable early-mid primary and highschool cohort sizes:** Outside of the primary to highschool transition, student cohort sizes remain relatively stable.

![CBE Student Retention Trends](<visualizations/CBE Student Retention Rates.png>)

Key Observations:
* **Early-on attrition in initial CBE Cohorts:** In the first (CBE) cohorts (2017–2018), approximately 10% attrition was observed within the first three grades. However, following this initial attrition, cohort sizes remained stable, only showing further attrition as students transitioned into and in junior secondary school
* **Improving retention in recent cohorts:** Overall, CBE retention trends are positive, with cohorts joining Grade 1 from 2019 onwards having had no overall attrition to date

**Important note:** As of 2026, the first CBE cohort is just entering senior secondary school (Grade 10). Consequently, there is currently no data to analyze the transition from junior to senior secondary school—a critical point where the required change in schools may impact retention rates.


## Conclusions and recommendations

Overall, the analysis indicates that with the CBE system so far, student retention is high, but KPSEA performance has consistently declined since 2022. While current retention rates are encouraging, the true stress test will occur as cohorts transition into senior secondary school—a phase requiring school changes, that has correlated with attrition in the previous education system (8-4-4).

### Recommendations: Analytical opportunities for policy makers
To better understand, and inform policies and changes that could reverse any observed early negative trends, I recommend prioritizing the following areas of study, most critically on student performance:
* **Root cause analysis of the 2024 performance dip:** 2024 represents a critical negative outlier in the dataset. Looking more closely at this could reveal whether this was likely  driven by specific curriculum adjustments, changes in the assessment methodology, external socio-economic factors or other factors that impacted students during that academic cycle, which could inform prevention of similar challenges for other cohorts.
* **Curriculum review for Creative Arts & Social Studies:** Performance in Creative Arts and Social Studies has shown a steady decline year on year. A targeted review of specific curriculum units within these subjects is needed to determine if factors like content complexity, teaching methods or resource availability are impacting student results.
* **Geographic and school type segmentation:** Segmenting performance data by county or region and school type (e.g., public vs. private, boarding vs. day) could help identify high-performing regions and school models whose best practices could be scaled to to improve performance elsewhere.
 * **Continued retention monitoring:** As the first CBE cohorts enter senior secondary school in 2026, monitoring of this transition is very important. Specifically, to determine if the physical change of schools triggers attrition, particularly given the added complexity of the new school selection process at a transition point that the analysis indicated was already a vulnerable point for students in the previous (8-4-4) system.
 * **Senior secondary school transition:** With the first CBE cohort entering senior secondary school this year (2026), there is limited data available on senior seconday school more broadly- beyond looking at student retention. However, this is an area that would require critical monitoring and investigation, with some specific key areas for monitoring suggested below:
   * **Investigation areas related to pathway specializations:** One of the most significant changes that CBE introduced was three specialized study pathways (STEM, Social Sciences and Arts & Sports Science) for senior secondary schools. There are a number of factors that need to be studied in relation to this, such as:
     * **Pathway alignment and mapping:** It would be important to evaluate if students are being correctly mapped to their chosen pathways  based on their Junior Secondary School (JSS) selections, performance and interests.
     * **Pathway distribution:** What is the distribution of students across the various path options? How does this vary by different segments? (Gender, county, rural vs. urban school-goers, private vs. public school-goers)- are there indications of introduction of any bias?
     * **School resourcing:** It is important to analyze whether schools possess the necessary resources, such as specialized laboratories and equipment, to support their assigned pathways.
     * **Pathway changes:** How are students who change their mind about which path to pursue being accommodated?
   * **Retention and attrition risks during the entire 3-year period:** Similar to analysis that was done above for primary and junior secondary school students, student retention should be monitored beyond just the transition point of joining senior secondary- to comprehensively assess whether the new cirriculum with all its changes (early-specialization, different assessment approaches etc.) is driving students to leave the system mid-course.
   * **Performance and equity analysis:** Data should be segmented by learning pathway, region, and school type (e.g., public vs. private). This will help identify if specific pathways, regions or school types are leading to certain groups of students being systematically underserved.
   * **Resource and support equity:** Given that a significant portion of the curriculum relies on project-based learning (often requiring high parental involvelemnt and purchase of materials) and digital literacy (which necessitates access to electricity, digital devices, and reliable internet) it is critical to evaluate the provisions being made for learners from resource-constrained households, and households with parents/guardians who are unable to provide the required support, to ensure that students are not penalized due to a lack of parental/guardian support or the inability to cover the costs of required learning materials.
   * **Teacher readiness:** As senior secondary curriculum complexity increases, it is critical to assess if teachers are prepared to deliver the required instruction- completion and effectiveness of tacher training should be reviewed. As a note- this would apply both to both senior secondary and primary / junior secondary schools.
   * **Transition to further education:** We must investigate how well the CBE curriculum aligns with the requirements of tertiary education institutions (universities, colleges, training institutes etc.), both locally and internationally. A critical question that will emerge is whether the transition to higher education is a smooth, transparent process or if students encounter hurdles in meeting entry standards.

## 📂 Project structure
* `/docs`: Contains a contextual background document on the Competency-Based Education (CBE) system, including reference documentation.
* `/raw_data`: The primary, unaltered datasets used for this project.
* `/sql`: The SQL scripts used for data quality checks, data cleaning, and analytical transformations.
* `/visualizations`: Contains exported snapshots of the final Tableau dashboard.
