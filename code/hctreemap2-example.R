## Not run:

library(tidyverse)
library(highcharter)
library(RColorBrewer)
library(treemap)
data(GNI2014)


# from https://rpubs.com/jbkunst/hctreemap2
# treemap -----------------------------------------------------------------
treemap(GNI2014,
  index = c("continent", "iso3"),
  vSize = "population",
  vColor = "GNI",
  type = "value",
  draw = FALSE
) %>%
  hctreemap(allowDrillToNode = TRUE, 
            layoutAlgorithm = "squarified") %>%
  hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
                            Pop: {point.value:,.0f}<br>
                            GNI: {point.valuecolor:,.0f}")

# Warning message:
# 'hctreemap' is deprecated.
# Use 'hctreemap2' instead.
# See help("Deprecated")
# hctreemap2 -----------------------------------------------------------------
# try new function (hctreemap2)
hctreemap2(
  data = GNI2014,
  group_vars = c("continent", "iso3"),
  size_var = "population",
  color_var = "GNI",
  layoutAlgorithm = "squarified",
  levelIsConstant = FALSE,
  levels = list(
    list(level = 1, dataLabels = list(enabled = TRUE)),
    list(level = 2, dataLabels = list(enabled = FALSE)),
    list(level = 3, dataLabels = list(enabled = FALSE))
  )
) %>%
  hc_colorAxis(
    minColor = brewer.pal(7, "Greens")[1],
    maxColor = brewer.pal(7, "Greens")[7]
  ) %>%
  hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
                            Pop: {point.value:,.0f}<br>
                            GNI: {point.colorValue:,.0f}")

# group_vars -----------------------------------------------------------------
# for some reason it works without the 2nd group_vars element ("iso3")
hctreemap2(
  data = GNI2014,
  group_vars = c("continent"),
  size_var = "population",
  color_var = "GNI",
  layoutAlgorithm = "squarified",
  levelIsConstant = FALSE,
  levels = list(
    list(level = 1, dataLabels = list(enabled = TRUE)),
    list(level = 2, dataLabels = list(enabled = FALSE)),
    list(level = 3, dataLabels = list(enabled = FALSE))
  )
) %>%
  hc_colorAxis(
    minColor = brewer.pal(7, "Greens")[1],
    maxColor = brewer.pal(7, "Greens")[7]
  ) %>%
  hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
                            Pop: {point.value:,.0f}<br>
                            GNI: {point.colorValue:,.0f}")
