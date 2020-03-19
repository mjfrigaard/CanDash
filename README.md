CanDash - A Cannabis Dashboard
================

## Overview

File/folder structure

    #>  .
    #>  ├── 00-INSTALL.R
    #>  ├── 01-software-requirement-specifications.md
    #>  ├── 01-wrangle.Rmd
    #>  ├── 02-visualize.Rmd
    #>  ├── 02-visualize.md
    #>  ├── 03-k-means.Rmd
    #>  ├── 03-k-means.md
    #>  ├── CanDash.Rproj
    #>  ├── README.Rmd
    #>  ├── README.md
    #>  ├── dashboard
    #>  ├── data
    #>  ├── docs
    #>  ├── figs
    #>  └── to-do.md

## The data

The data model for the CanDash application had to be constructed from a
few different sources. First, a list of products, brands, and other
categorical data were imported form the Kushy application on Github. You
can find the original data for this project
[here](https://github.com/kushyapp/cannabis-dataset).

We had to simulate the cost data for the products in the `Products` and
`Brands` tables. We used the online retail data from the [UCI Machine
Learning
Laboratory](https://archive.ics.uci.edu/ml/datasets/online+retail).

``` r
fs::dir_tree("data", recurse = TRUE)
```

    #>  data
    #>  ├── README.md
    #>  ├── kushy-datasets
    #>  │   ├── AUTHORS
    #>  │   ├── CHANGELOG.md
    #>  │   ├── LICENSE
    #>  │   ├── README.md
    #>  │   ├── csv
    #>  │   │   ├── brands-kushy_api.2017-11-14.csv
    #>  │   │   ├── products-kushy_api.2017-11-14.csv
    #>  │   │   ├── shops-kushy_api.2017-11-14.csv
    #>  │   │   └── strains-kushy_api.2017-11-14.csv
    #>  │   └── sql
    #>  │       ├── brands-kushy_api.2017-11-14.sql.gz
    #>  │       ├── products-kushy_api.2017-11-14.sql.gz
    #>  │       ├── shops-kushy_api.2017-11-14.sql.gz
    #>  │       └── strains-kushy_api.2017-11-14.sql.gz
    #>  ├── online-retail
    #>  │   ├── Online_Retail.csv
    #>  │   ├── README.md
    #>  │   ├── SmallOnlineRetail.csv
    #>  │   └── online-retail-data-set-from-uci-ml-repo.zip
    #>  └── processed
    #>      ├── 2020-03-17-CannabisWowData.csv
    #>      ├── 2020-03-19-CannabisWowData.csv
    #>      ├── 2020-03-19-MonthlyLocationSales.csv
    #>      └── 2020-03-19-WeekOverWeek.csv

## Import

The data for the dashboard are imported below.

``` r
# fs::dir_tree("data/processed/")
CannabisWowData <- read_csv("data/processed/2020-03-17-CannabisWowData.csv")
CannabisWowData %>% dplyr::glimpse(78)
```

    #>  Observations: 2,799
    #>  Variables: 21
    #>  $ id               <dbl> 404, 404, 404, 404, 404, 404, 216, 216, 216, 216, …
    #>  $ location         <chr> "California", "California", "California", "Califor…
    #>  $ quantity         <dbl> 1296, 600, 600, 480, 360, 240, 240, 200, 192, 150,…
    #>  $ unit_price       <dbl> 1.06, 0.42, 1.79, 0.36, 0.42, 2.55, 0.39, 1.74, 0.…
    #>  $ cost_per_invoice <dbl> 1373.76, 252.00, 1074.00, 172.80, 151.20, 612.00, …
    #>  $ product_name     <chr> "Sour Diesel", "Sour Diesel", "Sour Diesel", "Sour…
    #>  $ prod_name_count  <dbl> 480, 480, 480, 480, 480, 480, 423, 423, 423, 423, …
    #>  $ product_category <chr> "Flowers", "Flowers", "Flowers", "Pre-Roll", "Pre-…
    #>  $ invoice_date     <date> 2020-10-07, 2020-07-24, 2020-10-06, 2020-04-18, 2…
    #>  $ dow              <dbl> 7, 24, 6, 18, 18, 6, 28, 11, 8, 21, 12, 21, 23, 3,…
    #>  $ week             <dbl> 41, 30, 40, 16, 12, 49, 44, 41, 15, 47, 28, 47, 21…
    #>  $ yr               <dbl> 2020, 2020, 2020, 2020, 2020, 2020, 2020, 2020, 20…
    #>  $ week_year        <date> 2020-10-04, 2020-07-19, 2020-10-04, 2020-04-12, 2…
    #>  $ month            <chr> "Oct", "Jul", "Oct", "Apr", "Mar", "Dec", "Oct", "…
    #>  $ floor_month      <date> 2020-10-01, 2020-07-01, 2020-10-01, 2020-04-01, 2…
    #>  $ invoice_no       <dbl> 570097, 561051, 569815, 550344, 546992, 580985, 57…
    #>  $ stock_code       <chr> "20971", "21977", "85099F", "22546", "21977", "226…
    #>  $ product_details  <chr> "Pre-roll", "Pre-roll", "Pre-roll", "Pre-roll", "P…
    #>  $ brand            <chr> "Medi Cone", "Medi Cone", "Medi Cone", "Medi Cone"…
    #>  $ brand_name       <chr> "Day Dreamers", "Day Dreamers", "Day Dreamers", "D…
    #>  $ brand_category   <chr> "Concentrates", "Edibles", "Medical", "Concentrate…

## Date ranges

``` r
CannabisWowData %>% 
  dplyr::summarize(min_invoice_date = min(invoice_date, na.rm = TRUE),
                   max_invoice_date = max(invoice_date, na.rm = TRUE),
                   min_week_year = min(week_year, na.rm = TRUE),
                   max_week_year = max(week_year, na.rm = TRUE))
```

    #>  # A tibble: 1 x 4
    #>    min_invoice_date max_invoice_date min_week_year max_week_year
    #>    <date>           <date>           <date>        <date>       
    #>  1 2020-01-04       2020-12-23       2019-12-29    2020-12-20

These will help in determining what inputs to set on the dashboard.

### Missing data

These data are missing from the final `CannabisWowData`.

``` r
NAProducts <- inspectdf::inspect_na(df1 = CannabisWowData)
NAProducts %>% inspectdf::show_plot(text_labels = TRUE) 
```

![](figs/NAProducts-1.png)<!-- -->

## Categorical data

These are the categorical variables in the `CannabisWowData`.

``` r
CannabisWowCats <- CannabisWowData %>% 
  dplyr::select_if(is.character) %>% 
  inspectdf::inspect_cat()
CannabisWowCats %>% inspectdf::show_plot(text_labels = TRUE) 
```

![](figs/CannabisWowCats-1.png)<!-- -->
