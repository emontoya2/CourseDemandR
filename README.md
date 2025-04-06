# `CourseDemandR`

A Data-Driven Tool for General Education Enrollment: Statistical Analysis & Scenario Planning

## Local Deployment of `CourseDemandR`

This section provides step-by-step instructions for running `CourseDemandR` locally using [R](https://cran.r-project.org/) and [RStudio](https://www.rstudio.com/products/rstudio/download/).

---

### Preliminaries

Ensure the following are installed on your machine:

- **R** (version 4.0 or higher): [Download R](https://cran.r-project.org/)
- **RStudio** (IDE for running Shiny apps): [Download RStudio](https://www.rstudio.com/products/rstudio/download/)

---

### Step 1: Get the App Files

**Option 1: Download as ZIP**

1. Visit the GitHub repository: https://github.com/emontoya2/CourseDemandR  
2. Click on the green **"Code"** button and choose **"Download ZIP"**  
3. Unzip the downloaded folder to a local directory on your computer

**Option 2: Clone via Git (for those familiar with Git)**



### Step 2: Open the App in RStudio

1. Launch **RStudio**  
2. Navigate to the folder containing the app files  
3. Open the `app.R` file or the `.Rproj` file (if available)

---

### Step 3: Install Required R Packages

In the RStudio **Console**, run the following command to install dependencies:

`install.packages(c("shiny", "shinyjs", "shinyBS" "tidyverse", "DT", "broom", "ggrepel", "reshape2"))`


Additional packages may be installed dynamically on first run.

---

### Step 4: Launch the Application

1. With `app.R` open in RStudio, click the **"Run App"** button in the top right  
2. Or run this in the Console:

`shiny::runApp()`


This will launch the app in your default web browser.

---

### 📡 Optional: Run Online (No Installation Required)

You may also access the hosted version at:

[https://www.shinyapps.io/](https://www.shinyapps.io/) *(Not yet deployed on shinyapps -- to be linked)*

