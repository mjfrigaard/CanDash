#=====================================================================#
# This is code to create: 00-create-kushy-data.R
# Authored by and feedback to:
# MIT License
# Version: 1.0
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

# import kushy data -------------------------------------------------------

kushy_files <- fs::dir_ls("data/kushy-datasets", regexp = "kushy_")
# kushy_files[4]
KushyBrands <- readr::read_csv(kushy_files[1])
KushyProducts <- readr::read_csv(kushy_files[2])
KushyShops <- readr::read_csv(kushy_files[3])
KushyStrains <- readr::read_csv(kushy_files[4])



# products ----------------------------------------------------------------
SampleBrands <- KushyBrands %>% 
    distinct(name) %>% 
    # get 20% sample
    sample_frac(size = .20) %>% 
    dplyr::rename(brand = name)

# SampleBrands %>% glimpse(78)
# join this with products and remove missing
SampBrandsProducts <- dplyr::inner_join(SampleBrands, 
                                        KushyProducts, 
                                        by = "brand") %>% 
                                        dplyr::select(-c(lab_test, slug,
                                                         id))
# SampBrandsProducts %>% glimpse(78)


# export SampBrandsProducts data ----------
readr::write_csv(as.data.frame(SampBrandsProducts), 
                                       path = "data/SampBrandsProducts.csv")







