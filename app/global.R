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
combinedData <- read.csv("data/GEsampledata.csv", stringsAsFactors = FALSE)# Data is assumed to be clean tidy data 
 

# Some extra data preprocess for purpose of the app
combinedData <- combinedData %>% 
  mutate( Avg_fill_rate= Avg_enrl/GEcapsize ) %>%
  mutate(Avg_cap_diff = GEcapsize - Avg_capenrl) %>%
   mutate_if(is.numeric, ~ round(.x, 2))  %>%
  mutate(across(where(is.character), as.factor)) 


 

 