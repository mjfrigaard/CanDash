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
SampBrandsProducts <- readr::read_csv("data/SampBrandsProducts.csv") %>% 
    janitor::clean_names(case = "snake")

SmallOnlineRetail <- readr::read_csv("data/SmallOnlineRetail.csv") %>% 
    janitor::clean_names(case = "snake") %>% 
    dplyr::select(-country)

SampBrandsProducts %>% glimpse()
SmallOnlineRetail %>% glimpse()


# combine -----------------------------------------------------------------
CannabisData <- bind_cols(SampBrandsProducts, SmallOnlineRetail)
CannabisData

# create Wow data -----
CannabisDataWow <- CannabisData %>%
  # only
  select(week_year, quantity) %>%
  
  group_by(week_year) %>%
  summarize(week_qty = sum(quantity)) %>%
  mutate(prev_week = lag(week_qty, 1)) %>%
  mutate(wow_quantity = (week_qty - prev_week) / prev_Week) %>%
  mutate(month = month(week_year, abbr = TRUE, label = TRUE)) %>%
  group_by(week_year)

CannabisDataWow

# create list of brands
# CannabisData %>% distinct(brand) %>% as.list() %>% dput()

# create list of categories 
# CannabisData %>% distinct(category) %>% as.list() %>% dput()

ggWoW <- ggplot(
  data = CannabisDataWow,
  mapping = aes(
    x = week_year,
    y = WoW_Quantity
  )) +
  # color = purchaser_gender)) +
  geom_line() +
  geom_point() +
  theme_fivethirtyeight() +
  theme(axis.title = element_text()) +
  theme(legend.title = element_blank()) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  facet_wrap(~month, scales = "free") +
  ylab("Sales") +
  xlab("Week") +
  ggtitle("Week Over Week Sales")

ggWoW


