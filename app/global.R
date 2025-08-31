# Load required packages
library(shiny)
library(shinyjs)
library(shinyBS)
library(dplyr)
library(ggplot2)
library(DT)
library(tidyr)
library(broom)
library(ggrepel)
library(reshape2)
library(plotly)


# Load data
combinedData <- read.csv("data/GEsampledata.csv", stringsAsFactors = FALSE)
# Data is assumed to be clean tidy data with at least the following
# variable names: 'Term' 'College' 'Course' 'Catalog' 'Req_1' 'Req_2'
# 'Avg_enrl' 'GEcapsize' 'Avg_capenrl' 'Crs_section_cnt'. See the app
# for description of each variable.

# Source validation function
source("R/validate_data.R")

# Function to process the data for the app
prepData <- function(df) {
  df %>%
    filter(Avg_enrl != 0) %>%
    mutate(Avg_fill_rate = Avg_enrl/GEcapsize, Avg_cap_diff = GEcapsize -
             Avg_capenrl) %>%
    group_by(Term, Req_1) %>%
    mutate(GE_avg_fill = mean(Avg_fill_rate, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(Rel_GE_fill_rate = Avg_fill_rate/GE_avg_fill) %>%
    mutate_if(is.numeric, ~round(.x, 2)) %>%
    mutate(GE_course_level = if_else(Catalog < 3000, "LD", "UD")) %>%
    mutate(across(where(is.character), as.factor))
}

