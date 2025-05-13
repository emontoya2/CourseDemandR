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
 

# Some extra data preprocess for the app
combinedData <- combinedData %>% 
  filter(Avg_enrl!=0)%>% 
  mutate( Avg_fill_rate= Avg_enrl/GEcapsize ) %>%
  mutate(Avg_cap_diff = GEcapsize - Avg_capenrl) %>%
  group_by( Term, Req_1)   %>%          # under each term for each GE area…
  mutate(
    GE_avg_fill   = mean(Avg_fill_rate, na.rm = TRUE) # …compute the area’s avg fill
  ) %>%
  ungroup() %>%
  mutate(
    Rel_GE_fill_rate = Avg_fill_rate / GE_avg_fill     # course’s rate / area’s rate
  )  %>%
  mutate_if(is.numeric, ~ round(.x, 2))  %>%
  mutate(across(where(is.character), as.factor))    

 
