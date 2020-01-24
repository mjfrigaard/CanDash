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

# Bring in the data
# export SampBrandsProducts data ----------
SampBrandsProducts <- readr::read_csv("data/SampBrandsProducts.csv")

# create list of brands
# SampBrandsProducts %>% distinct(brand) %>% as.list() %>% dput()

# create list of categories 
# SampBrandsProducts %>% distinct(category) %>% as.list() %>% dput()


