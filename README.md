> **Version**: v1.2.0  •  **License**: [MIT](LICENSE)  •  **Zenodo Archive**: [10.5281/zenodo.15191359](https://doi.org/10.5281/zenodo.15428178)

# CourseDemandR
 
**CourseDemandR**  is a data-driven tool that supports general education enrollment through statistical modeling and scenario planning

## Version 1.2.0 – Release Notes

- Now supports user-uploaded CSV datasets with base variables; derived metrics are computed dynamically by the app
- Two new metrics and two additional plots added for deeper exploration of fill rates
- Improved code documentation and inline comments for better maintainability
- Updated README.md and sample dataset to reflect new functionality

### Notes

This version supersedes v1.1.0, which required precomputed variables and supported only the built-in dataset.

## Local Deployment of **CourseDemandR**

This section provides step-by-step instructions for running **CourseDemandR** locally using [R](https://cran.r-project.org/) and [RStudio](https://www.rstudio.com/products/rstudio/download/).


### Preliminaries

Ensure the following are installed on your machine:

- **R** (version 4.0 or higher): [Download R](https://cran.r-project.org/)
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

## Citation

Montoya, E. (2025). *CourseDemandR: An R Shiny App for General Education Curriculum Planning*. [Zenodo](https://doi.org/10.5281/zenodo.15428178)
