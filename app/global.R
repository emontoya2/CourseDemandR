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

# Load data (assumes the CSV file has a 'term' column)
combinedData <- read.csv("data/GEsampledata.csv", stringsAsFactors = FALSE)# Data is assumed to be clean with the following variables:
# College: The academic unit or college offering the course.
# Course: The unique course identifier (typically a combination of subject and catalog number).
# Subject: The academic discipline or department of the course.
# Catalog: The course's catalog or course number.
# Avg_enrl: The average number of students enrolled in the course.
# Med_enrl: The median number of students enrolled in the course.
# Avg_fill_rate: The average enrollment as a proportion of the GE course cap.
# Median_fill_rate: The median enrollment as a proportion of the GE course cap.
# GEcapsize: The designated capacity for GE courses.
# Req_1: The primary GE requirement the course satisfies.
# Req_2: The secondary GE requirement the course satisfies.
# course_type: course's classficaion as GE only or GE/Major course.
# Avg_cap_diff: The average difference between the course's capacity and the GE course cap.
# crs_section_cnt: The number of sections offered for the course.
# Term: The academic term (e.g., Fall 24, Spring 25).

# Some extra data preprocess for purpose of the app
combinedData <- combinedData %>%
  mutate_if(is.numeric, ~ round(.x, 2))  



