#=====================================================================#
# This is code to create: MarijuanaLaws202001
# Authored by and feedback to: @mjfrigaard
# MIT License
# Version:
# Description: https://disa.com/map-of-marijuana-legality-by-state
#=====================================================================#

library(datapasta)
library(tidyverse)
library(janitor)

MarijuanaLaws202001 <- tibble::tribble(
                    ~State,   ~Legal.Status, ~Medicinal, ~Decriminalized,       ~State.Laws,
                 "Alabama", "Fully Illegal",       "No",            "No", "View State Laws",
                  "Alaska",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                 "Arizona",         "Mixed",      "Yes",            "No", "View State Laws",
                "Arkansas",         "Mixed",      "Yes",            "No", "View State Laws",
              "California",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                "Colorado",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
             "Connecticut",         "Mixed",      "Yes",       "Reduced", "View State Laws",
                "Delaware",         "Mixed",      "Yes",       "Reduced", "View State Laws",
    "District of Columbia",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                 "Florida",         "Mixed",      "Yes",            "No", "View State Laws",
                 "Georgia",         "Mixed",  "CBD Oil",            "No", "View State Laws",
                  "Hawaii",         "Mixed",      "Yes",       "Reduced", "View State Laws",
                   "Idaho", "Fully Illegal",       "No",            "No", "View State Laws",
                "Illinois",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                 "Indiana",         "Mixed",  "CBD Oil",            "No", "View State Laws",
                    "Iowa",         "Mixed",  "CBD Oil",            "No", "View State Laws",
                  "Kansas", "Fully Illegal",       "No",            "No", "View State Laws",
                "Kentucky",         "Mixed",  "CBD Oil",            "No", "View State Laws",
               "Louisiana",         "Mixed",      "Yes",            "No", "View State Laws",
                   "Maine",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                "Maryland",         "Mixed",      "Yes",       "Reduced", "View State Laws",
           "Massachusetts",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                "Michigan",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
               "Minnesota",         "Mixed",      "Yes",       "Reduced", "View State Laws",
             "Mississippi", "Fully Illegal",       "No",       "Reduced", "View State Laws",
                "Missouri",         "Mixed",      "Yes",       "Reduced", "View State Laws",
                 "Montana",         "Mixed",      "Yes",            "No", "View State Laws",
                "Nebraska", "Fully Illegal",       "No",       "Reduced", "View State Laws",
                  "Nevada",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
           "New Hampshire",         "Mixed",      "Yes",       "Reduced", "View State Laws",
              "New Jersey",         "Mixed",      "Yes",            "No", "View State Laws",
              "New Mexico",         "Mixed",      "Yes",       "Reduced", "View State Laws",
                "New York",         "Mixed",      "Yes",       "Reduced", "View State Laws",
          "North Carolina", "Fully Illegal",       "No",       "Reduced", "View State Laws",
            "North Dakota",         "Mixed",      "Yes",       "Reduced", "View State Laws",
                    "Ohio",         "Mixed",      "Yes",       "Reduced", "View State Laws",
                "Oklahoma",         "Mixed",      "Yes",            "No", "View State Laws",
                  "Oregon",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
            "Pennsylvania",         "Mixed",      "Yes",            "No", "View State Laws",
            "Rhode Island",         "Mixed",      "Yes",       "Reduced", "View State Laws",
          "South Carolina", "Fully Illegal",       "No",            "No", "View State Laws",
            "South Dakota", "Fully Illegal",       "No",            "No", "View State Laws",
               "Tennessee", "Fully Illegal",       "No",            "No", "View State Laws",
                   "Texas",         "Mixed",  "CBD Oil",            "No", "View State Laws",
                    "Utah",         "Mixed",      "Yes",            "No", "View State Laws",
                 "Vermont",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
                "Virginia",         "Mixed",  "CBD Oil",            "No", "View State Laws",
              "Washington",   "Fully Legal",      "Yes",           "Yes", "View State Laws",
           "West Virginia",         "Mixed",      "Yes",            "No", "View State Laws",
               "Wisconsin", "Fully Illegal",       "No",            "No", "View State Laws",
                 "Wyoming", "Fully Illegal",       "No",            "No", "View State Laws"
    ) %>% janitor::clean_names(case = "snake")

MarijuanaLaws202001 %>% count(legal_status)
