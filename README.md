> **Version**: v1.3.0  •  **License**: [MIT](LICENSE)  •  **Zenodo Archive**: [10.5281/zenodo.15557906](https://doi.org/10.5281/zenodo.15557906)

# CourseDemandR
 
[![Data Validation CI](https://github.com/emontoya2/CourseDemandR/actions/workflows/validate-data.yml/badge.svg)](https://github.com/emontoya2/CourseDemandR/actions/workflows/validate-data.yml)


**CourseDemandR**  is a data-driven tool that supports general education enrollment through statistical modeling and scenario planning

## Version 1.3.0 – Release Notes

- **Add data‐validation pre‐check** (`validate_data.R`):  
	- Ensures required columns (`Term`, `College`, `Course`, etc.) are present
	- Checks for no missing values and enforces numeric ≥ 0 in key fields
	- Logs outcomes to `validation_log.txt`  
- Fix minor UI reset issues so filter inputs reliably return to their defaults  

### Notes

This version supersedes v1.2.0, which supported user uploads but did not utilize data validation.

## Local Deployment of **CourseDemandR**

This section provides step-by-step instructions for running **CourseDemandR** locally using [R](https://cran.r-project.org/) and [RStudio](https://www.rstudio.com/products/rstudio/download/).


### Preliminaries

Ensure the following are installed on your machine:

- **R** (version 4.4.2 or higher): [Download R](https://cran.r-project.org/)
- **RStudio** (IDE for running Shiny apps): [Download RStudio](https://www.rstudio.com/products/rstudio/download/)


### Step 1: Get the App Files

**Option 1: Download as ZIP**

1. Visit the GitHub repository: https://github.com/emontoya2/CourseDemandR  
2. Click on the green **"Code"** button and choose **"Download ZIP"**  
3. Unzip the downloaded folder to a local directory on your computer

**Option 2: Clone via Git (for those familiar with Git)**

`git clone https://github.com/emontoya2/CourseDemandR.git`


### Step 2: Open the App in RStudio

1. Launch **RStudio**  
2. Navigate to the folder containing the app files  
3. Open the `app.R` file or the `.Rproj` file (if available)



### Step 3: Install Required R Packages

In the RStudio **Console**, run the following command to install dependencies:

`install.packages(c("shiny", "shinyjs", "shinyBS", "tidyverse", "DT", "broom", "ggrepel", "reshape2"))`

Additional packages may be installed dynamically on first run.


### Step 4: Launch the Application

1. With `app.R` open in RStudio, click the **"Run App"** button in the top right  
2. Or run this in the Console:

`shiny::runApp()`


This will launch the app in your default web browser.

### Optional: Run Online (No Installation Required)

You may also access the hosted version at:

[https://emontoya2.shinyapps.io/coursedemandr/](https://emontoya2.shinyapps.io/coursedemandr/)  


## Data Requirements

The application expects a structured CSV file with aggregate GE course enrollment data. Required columns include:

- `College`, `Course`, `Catalog`, `Term`
- `Avg_enrl`,  `crs_section_cnt`, `"Avg_capenrl`
- `GEcapsize`,  `Req_1`, `Req_2`

A sample dataset is included with this release for demonstration.

> **Note:** On launch or upload, the app now runs `validate_data.R` to verify your CSV matches the expected schema (required columns, no NAs, numeric ≥ 0). Any violations will be logged in `validation_log.txt`.

## Citation

Montoya, E. (2025). CourseDemandR: An R Shiny App for General Education Curriculum Planning  (v1.3.0). Zenodo. https://doi.org/10.5281/zenodo.15557906
