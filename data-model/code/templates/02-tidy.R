#=====================================================================#
# This is code to create:
# Authored by and feedback to:
# MIT License
# Version:
#=====================================================================#

# packages ----------------------------------------------------------------

library(tidyverse)
library(DataExplorer)
library(skimr)
library(inspectdf)
library(visdat)
library(janitor)
library(rmarkdown)
library(leaflet)
library(viridis)
library(tidymodels)

# previous script ---------------------------------------------------------
source("code/01-import.R")

# Rename data for a working version

retail <- retail_dataimport

# Inspect the data

glimpse(retail)

# Create a table to inspect the first 10 observations

retail %>% 
  sample_n(10)

# Inspect dataset for missing values and create visual plot using DataExplorer package

options(repr.plot.width = 8, repr.plot.height = 3)
plot_missing(retail)

# It appears that CustomerID is most absent in the data.

# Check the dataset to find out which column has the most missing values 
retail %>% 
  map(., ~sum(is.na(.)))

# Ignore observations that hae missing values.

retail <- retail[complete.cases(retail), ]

# Check if missing values have been removed

retail %>% 
  map(., ~sum(is.na(.)))

# Missing values have been successfully removed
