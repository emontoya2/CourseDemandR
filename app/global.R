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

# Load data  
combinedData <- read.csv("data/GEsampledata.csv", stringsAsFactors = FALSE)# Data is assumed to be clean with the following variables:
 
# Some extra data preprocess for purpose of the app
combinedData <- combinedData %>%
  mutate_if(is.numeric, ~ round(.x, 2))  



