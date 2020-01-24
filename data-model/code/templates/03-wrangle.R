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

# Data Cleaning

source("code/01-import.R")
source("code/02-tidy.R")

# Convert datetime to format yyyy-mm-dd to assess daily sales.
# Also need to change Description, Country, and InvoiceNo to factor for analysis.

retail_cleaned <- retail %>% 
  mutate(day = parse_date(format(InvoiceDate, "%Y-%m-%d")),
         day_of_week = wday(day, label = TRUE),
         time = parse_time(format(InvoiceDate, "%H:%M")),
         month = format(InvoiceDate, "%m"))

# Many of the variables are in <chr> format.
# Also need to change Description, Country, and InvoiceNo to factor for analysis.

retail_cleaned <- retail_cleaned %>% 
  mutate(Description = factor(Description, levels = unique(Description)),
         total_income = Quantity * UnitPrice,
         Country = factor(Country, levels = unique(Country)),
         InvoiceNo = factor(InvoiceNo, levels = unique(InvoiceNo)))

# Save data 

save(retail_cleaned, file = "retail_cleaned.RData")

# Data has been cleaned. Move on to EDA
