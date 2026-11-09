## Factors Associated with State Level Polling Accuracy for 2012 and 2016 US Presidential Elections

This repository includes a final statistical report examining polling characteristics associated with state-level polling accuracy in the 2012 and 2016 US presidential elections. The report builds on a preceding exploratory data analysis (EDA) by investigating how polling timing, election year, sample size and methodology are related to differences between polling results and election outcomes.

This analysis utilises 2,436 state-level polls and four progressively adjusted OLS regression models. Preparation of the data and statistical analysis were performed in R, and the final report was created using Quarto.

## Project Structure

```         
Final-Report/
├── README.md                           <- this file 
├── Final Report.qmd                    <- Report source 
├── Final-Report.pdf                    <- Rendered final report
├── final_data_preparation.R            <-  Data preparation script
├── report-references.bib               <- References 
└── data/
    ├── 1976-2024-president-clean.csv   <- Cleaned election results
    ├── state_polls_2012_clean.csv      <- Cleaned 2012 polling data
    ├── state_polls_2016_clean.csv      <- Cleaned 2016 polling data
    └── final_model_data.csv            <- Final report dataset 
```

## Data 

The project utilises 3 cleaned data sets developed during the EDA process:

-   state_polls_2012_clean.csv - state-level polling data for election year 2012

-   state_polls_2016_clean.csv - state-level polling data for election year 2016

-   1976-2024-president-clean.csv - state-level US election results spanning from 1976 to 2024

Polling data was retrieved from HuffPost Pollster via the pollstR R package as part of the rOpenGov project. The 1976-2024 election results were retrieved from the MIT Election Data and Science Lab via Harvard Dataverse.

For this report, the three data sets were combined and prepared using final_data_preparation.R to produce the data set final_model_data.csv used in the regression analysis. The unit of observation in the final data set is an individual state-level poll.

## Research Questions 

The analysis investigates the research question: **To what degree are polling timing, sample size and methodology associated with the accuracy of state-level presidential polls for the 2012 and 2016 elections.** More specifically, it explores:

1\. Whether polling accuracy is associated with days prior to Election Day

2\. Whether election year, sample size and methodology explain variation in polling errors once timing is accounted for

## Prerequisites 

Ensure the following tools and software are installed before running the project:

-   R (v4.0.0+)

-   RStudio (v2022.07+)

-   Quarto

-   LaTeX distribution for PDF rendering

Run this command in your R console to install the required packages:

`install.packages(c("tidyverse", "modelsummary", "knitr"))`

For code quality checks, user can also install lintr package:

`install.packages("lintr")`

If TinyTeX has not already been installed, do so in the RStudio Terminal:

`quarto install tinytex`

## Reproducibility 

To reproduce the project, the below steps must be followed in order:

1.  Run this command to clone the repository:

`git clone https://github.com/TICA-STATX290-2026/Final-Report.git`

2.  Launch RStudio and open the cloned repository folder.

3.  Run final_data_preparation.R to reproduce final_model_data.csv from the three EDA data sets.

4.  Render the Final Report.qmd file to generate the pdf report:

-   In RStudio, open Final Report.qmd and click the "Render" button.

All regression models, tables and figures are produced through executable R code within the qmd file. The final report is available as Final-Report.pdf.

## Statistical Analysis 

The response variable in this analysis is absolute polling error. This variable is defined as the absolute difference between each poll's Democratic-Republican voting margin and the actual election outcome margin. Four nested regression models investigate possible associations with polling timing, election year, sample size and methodology. Further, diagnostic checks are performed to examine model assumptions and potentially influential observations.

## Key Findings 

Polling timing, election year and sample size were found to be statistically significant in explaining variation in absolute polling error, while polling methodology appeared to not be statistically significant after accounting for other factors. The final model was able to explain roughly 10.9% of variation in the response variable, indicating the limited explanatory power of the characteristics investigated in the model.

## Contributors

STATX290 - Adelaide University, Semester 2, 2026

Tia Light

Tue Linh Tran

Xuan Zhu

Amey Chande
