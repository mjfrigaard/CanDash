#=====================================================================#
# This is code to create: htmlwidgets-highcharter.R
# Authored by and feedback to: mjfrigaard
# MIT License
# Version: 0.1
#=====================================================================#


# setup -------------------------------------------------------------------

library(highcharter)
library(dplyr)
library(viridisLite)
library(forecast)
library(treemap)
library(flexdashboard)

thm <- 
    hc_theme(
        colors = c("#1a6ecc", "#434348", "#90ed7d"),
        chart = list(
            backgroundColor = "transparent",
            style = list(fontFamily = "Ubuntu")
        ),
        xAxis = list(
            gridLineWidth = 1
        )
    )


# Sales Forecast ----------------------------------------------------------
AirPassengers <- datasets::AirPassengers

# check this object
str(AirPassengers)
names(AirPassengers)
glimpse(AirPassengers)
class(AirPassengers)
typeof(AirPassengers)

AirPassengers %>% 
    # level = Confidence level for prediction intervals, 
    forecast::forecast(level = 90) %>% 
    # draw a particular plot for an object of a particular class in a single 
    # command. This needs to be a ts object
    highcharter::hchart() %>% 
    # Add highcharts themes to a highchart object.
    highcharter::hc_add_theme(thm)


# Sales by State ----------------------------------------------------------

# get data for the map
data("USArrests", package = "datasets")
# get the map
data("usgeojson", package = "highcharter")

# create some rownames from the states
USArrests <- USArrests %>%
    mutate(state = rownames(.))

class(USArrests)
str(USArrests)

n <- 4
colstops <- base::data.frame(
    q = 0:n/n,
    c = substring(viridis(n + 1), 0, 7)) %>%
    highcharter::list_parse2()

str(colstops)
class(colstops)

# map ---------------------------------------------------------------------

highcharter::highchart() %>%
    
    highcharter::hc_add_series_map(hc = ., 
                   # here is the map from highcharter
                   map = usgeojson, 
                   # these are the data from datasets package
                   df = USArrests, 
                   # this is a character vector we assign
                   name = "Sales",
                   # this is a column in the USArrests data set
                   value = "Murder", 
                   # 
                   joinBy = c("woename", "state"),
                   
                   dataLabels = list(enabled = TRUE,
                                 format = '{point.properties.postalcode}')) %>%
    
    highcharter::hc_colorAxis(stops = colstops) %>%
    
    highcharter::hc_legend(valueDecimals = 0, 
                           valueSuffix = "%") %>%
    
    highcharter::hc_mapNavigation(enabled = TRUE) %>%
    
    highcharter::hc_add_theme(thm)


# Sales by Category -------------------------------------------------------

data("Groceries", 
     package = "arules")

dfitems <- tbl_df(Groceries@itemInfo)

utils::str(dfitems)
dplyr::glimpse(dfitems)

set.seed(10)

dfitemsg <- dfitems %>%
    dplyr::mutate(category = gsub(" ", "-", level1),
                  subcategory = gsub(" ", "-", level2)) %>%
    dplyr::group_by(category, subcategory) %>% 
    dplyr::summarise(sales = n() ^ 3 ) %>% 
    dplyr::ungroup() %>% 
    dplyr::sample_n(size = 31)

utils::str(dfitemsg)
dplyr::glimpse(dfitemsg)

hctreemap2(dfitemsg, 
           group_vars = c("category"),
           size_var = "sales", 
           color_var = "sales",
           layoutAlgorithm = "squarified",
           levelIsConstant = FALSE,
           allowDrillToNode = TRUE,
           palette = rev(viridis(6))) %>% 
    hc_add_theme(thm)


# Best Sellers ------------------------------------------------------------

set.seed(2)
nprods <- 10

dfitems %>% 
    # this is the previous data 
    dplyr::sample_n(nprods) %>% 
    # pull this variable out as a vector
    .$labels %>% 
    # this repeats 
    rep(times = sort(sample(x = 1e4:2e4, 
                            size = nprods), 
                     decreasing = TRUE)) %>% 
    # convert to a factor
    base::factor(levels = unique(.)) %>%
    # utils::str()
    # add the chart
    highcharter::hchart(showInLegend = FALSE, 
           name = "Sales", 
           pointWidth = 10) %>% 
    # we created this above
    highcharter::hc_add_theme(thm) %>% 
    # convert this to a bar
    highcharter::hc_chart(type = "bar")
