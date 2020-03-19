Part 3 - K-Means Cannabis Data
================
Martin Frigaard
current version: 2020-03-19

## Load the packages

These are the packages we will use to visualize the cannabis data.

``` r
library(readr)
library(tidyverse)
library(lubridate)
library(ggthemes)
library(cluster)
library(factoextra)
library(textshape)
library(knitr)
library(rmdformats)
library(plotly)
require(janitor)
require(skimr)
library(mosaic)
library(inspectdf)
library(visdat)
library(DT)
library(hrbrthemes)
```

## Import data

This data came from a UK e-commerce dataset from the [UCI Machine
Learning
Laboratory](https://archive.ics.uci.edu/ml/datasets/online+retail) and
the [kushy cannabis data
set](https://github.com/kushyapp/cannabis-dataset).

``` r
# fs::dir_tree("data/processed/")
CannabisWowData <- read_csv("data/processed/2020-03-17-CannabisWowData.csv")
```

``` r
CannabisWowData %>% dplyr::glimpse() 
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

## Create Customer Sales data

These data are the sales by customer id. We create this data frame by
grouping on `customer_id`, then create a `sales` variable by multiplying
the quantity by the unit price (`quantity * unit_price`).

We also create three variables that aggregate the sales (`sum` and
`median`).

``` r
CustomerSales <- CannabisWowData %>%
    # select the customer_id, quantity, and unit_price
    dplyr::select(id, quantity, unit_price) %>%
    # group it by the customer id
    dplyr::group_by(id) %>%
    # create sales (which is the product of quantity and price)
    dplyr::mutate(sales = (quantity * unit_price)) %>%
    # summarize
    dplyr::summarize(
            sales_sum = sum(sales),
            sales_median = median(sales),
            quantity_sum = sum(quantity),
            quantiy_median = median(quantity)) %>%
    # we group this again by customer id
    dplyr::group_by(id)
CustomerSales %>% dplyr::glimpse(78)
```

    #>  Observations: 1,253
    #>  Variables: 5
    #>  Groups: id [1,253]
    #>  $ id             <dbl> 1, 7, 8, 9, 15, 16, 17, 18, 19, 22, 25, 27, 28, 29, …
    #>  $ sales_sum      <dbl> 11.58, 13.24, 4.95, 32.85, 5.40, 2.49, 17.70, 3.36, …
    #>  $ sales_median   <dbl> 5.790, 6.620, 4.950, 32.850, 2.700, 2.490, 17.700, 3…
    #>  $ quantity_sum   <dbl> 2, 2, 3, 3, 2, 1, 6, 1, 1, 1, 1, 12, 4, 2, 2, 8, 2, …
    #>  $ quantiy_median <dbl> 1, 1, 3, 3, 1, 1, 6, 1, 1, 1, 1, 6, 1, 1, 1, 1, 1, 1…

## Customer location data

We now join the `CustomerSales` data to a data frame with the distinct
customer ids and countries (`CustomersLocation`).

``` r
CustomersLocation <- CannabisWowData %>%
    dplyr::distinct(id, location) %>%
    dplyr::group_by(id)
# join this to the CustomersLocation
CustomersSalesLocation <- CustomerSales %>%
    dplyr::inner_join(CustomersLocation, 
               by = "id")
# check
CustomersSalesLocation %>% dplyr::glimpse(78)
```

    #>  Observations: 1,253
    #>  Variables: 6
    #>  Groups: id [1,253]
    #>  $ id             <dbl> 1, 7, 8, 9, 15, 16, 17, 18, 19, 22, 25, 27, 28, 29, …
    #>  $ sales_sum      <dbl> 11.58, 13.24, 4.95, 32.85, 5.40, 2.49, 17.70, 3.36, …
    #>  $ sales_median   <dbl> 5.790, 6.620, 4.950, 32.850, 2.700, 2.490, 17.700, 3…
    #>  $ quantity_sum   <dbl> 2, 2, 3, 3, 2, 1, 6, 1, 1, 1, 1, 12, 4, 2, 2, 8, 2, …
    #>  $ quantiy_median <dbl> 1, 1, 3, 3, 1, 1, 6, 1, 1, 1, 1, 6, 1, 1, 1, 1, 1, 1…
    #>  $ location       <chr> "California", "California", "California", "Californi…

### Create cluster (modeling) data frame

Ok, now we are going to convert the grouped data frame, drop the missing
rows, and remove any data where sales were less than zero.

``` r
# convert to data frame
CustomerSalesClust <- base::data.frame(CustomerSales)

CustomerSalesClust <- CustomerSalesClust %>%  
    # drop na 
                        tidyr::drop_na() %>%
    # remove sales less than 0
                        dplyr::filter(sales_sum > 0)
skimr::skim(CustomerSalesClust)
```

|                                                  |                    |
| :----------------------------------------------- | :----------------- |
| Name                                             | CustomerSalesClust |
| Number of rows                                   | 1222               |
| Number of columns                                | 5                  |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_   |                    |
| Column type frequency:                           |                    |
| numeric                                          | 5                  |
| \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_ |                    |
| Group variables                                  | None               |

Data summary

**Variable type: numeric**

| skim\_variable  | n\_missing | complete\_rate |   mean |     sd |   p0 |    p25 |    p50 |     p75 |    p100 | hist  |
| :-------------- | ---------: | -------------: | -----: | -----: | ---: | -----: | -----: | ------: | ------: | :---- |
| id              |          0 |              1 | 861.03 | 487.61 | 1.00 | 440.50 | 873.50 | 1282.75 | 1680.00 | ▇▇▇▇▇ |
| sales\_sum      |          0 |              1 |  43.86 | 139.07 | 0.39 |   7.37 |  19.09 |   39.80 | 3635.76 | ▇▁▁▁▁ |
| sales\_median   |          0 |              1 |  16.58 |  39.93 | 0.39 |   4.13 |   9.87 |   16.65 |  757.63 | ▇▁▁▁▁ |
| quantity\_sum   |          0 |              1 |  23.30 | 114.16 | 1.00 |   2.00 |   6.00 |   20.00 | 3576.00 | ▇▁▁▁▁ |
| quantiy\_median |          0 |              1 |   8.27 |  21.13 | 1.00 |   1.00 |   3.00 |    9.75 |  540.00 | ▇▁▁▁▁ |

-----

## K-Means clustering

Finally, we run a k-means clustering algorithm on the clustered sales
data. *What does a k-means clustering do?* Well, here is a great
definition on
[Medium](https://towardsdatascience.com/understanding-k-means-clustering-in-machine-learning-6a6e67336aa1),

> the objective of K-means is simple: group similar data points together
> and discover underlying patterns. To achieve this objective, K-means
> looks for a fixed number (k) of clusters in a dataset.

The k-means algorithm is an **unsupervised machine learning algorithm.**
The steps to perform this are:

1.  Use the `textshape::column_to_rownames()` function on the clustered
    data frame. This function

> “*Takes an existing column and uses it as rownames instead. This is
> useful when turning a data.frame into a matrix. Inspired by the tibble
> package’s `column_to_row` which is now deprecated if done on a
> `tibble` object. By coercing to a `data.frame` this problem is
> avoided.*”

We’re going to use the non-descript name, `CustomerSalesClust2`. to show
what this function is actually doing. The `utils::str()` function gives
us some information on what kind of object we’ve created here.

``` r
CustomerSalesClust2 <- textshape::column_to_rownames(CustomerSalesClust) 
utils::str(CustomerSalesClust)
```

    #>  'data.frame':   1222 obs. of  5 variables:
    #>  $ id : num 1 7 8 9 15 16 17 18 ...
    #>  $ sales_sum : num 11.58 13.24 4.95 32.85 ...
    #>  $ sales_median : num 5.79 6.62 4.95 32.85 ...
    #>  $ quantity_sum : num 2 2 3 3 2 1 6 1 ...
    #>  $ quantiy_median: num 1 1 3 3 1 1 6 1 ...

``` r
utils::str(CustomerSalesClust2)
```

    #>  'data.frame':   1222 obs. of  4 variables:
    #>  $ sales_sum : num 11.58 13.24 4.95 32.85 ...
    #>  $ sales_median : num 5.79 6.62 4.95 32.85 ...
    #>  $ quantity_sum : num 2 2 3 3 2 1 6 1 ...
    #>  $ quantiy_median: num 1 1 3 3 1 1 6 1 ...

The `CustomerSalesClust2` took the existing data frame
(`CustomerSalesClust`) and removed a column (`customer_id`) and assigned
them a rowname `base::rownames()`.

``` r
base::rownames(CustomerSalesClust2) %>% head()
```

    #>  [1] "1"  "7"  "8"  "9"  "15" "16"

2.  The 2nd step is to Scale the new `CustomerSalesClust` with
    `base::scale()`, which now has been transformed via the
    `textshape::column_to_rownames()` function. The `scale()` function
    who’s, “*default method centers and/or scales the columns of a
    numeric matrix.*”

<!-- end list -->

``` r
CustomerSalesClust3 <- base::scale(CustomerSalesClust2)
str(CustomerSalesClust3)
```

    #>  num [1:1222, 1:4] -0.2321 -0.2202 -0.2798 -0.0792 ...
    #>  - attr(*, "dimnames")=List of 2
    #>  ..$ : chr [1:1222] "1" "7" "8" ...
    #>  ..$ : chr [1:4] "sales_sum" "sales_median" "quantity_sum" ...
    #>  - attr(*, "scaled:center")= Named num [1:4] 43.86 16.58 23.3 8.27
    #>  ..- attr(*, "names")= chr [1:4] "sales_sum" "sales_median" "quantity_sum" ...
    #>  - attr(*, "scaled:scale")= Named num [1:4] 139.1 39.9 114.2 21.1
    #>  ..- attr(*, "names")= chr [1:4] "sales_sum" "sales_median" "quantity_sum" ...

Use the `kmeans()` function with the specifications below:

`centers` = A matrix of cluster centres. `nstart` =

``` r
k2 <- kmeans(CustomerSalesClust, 
             # the number of cluster centries
             centers = 2 , 
             ## random starts do help here with too many clusters
             ## (and are often recommended anyway!):
             nstart = 25)
k2
```

    #>  K-means clustering with 2 clusters of sizes 592, 630
    #>  
    #>  Cluster means:
    #>           id sales_sum sales_median quantity_sum quantiy_median
    #>  1  425.8666  51.25693     19.20398     29.82939        9.88598
    #>  2 1269.9476  36.90537     14.11969     17.16349        6.75000
    #>  
    #>  Clustering vector:
    #>     [1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>    [38] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>    [75] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [112] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [149] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [186] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [223] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [260] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [297] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [334] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [371] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [408] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [445] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [482] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [519] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [556] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    #>   [593] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [630] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [667] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [704] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [741] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [778] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [815] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [852] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [889] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [926] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>   [963] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1000] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1037] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1074] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1111] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1148] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1185] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
    #>  [1222] 2
    #>  
    #>  Within cluster sum of squares by cluster:
    #>  [1] 73977903 40773432
    #>   (between_SS / total_SS =  65.5 %)
    #>  
    #>  Available components:
    #>  
    #>  [1] "cluster"      "centers"      "totss"        "withinss"     "tot.withinss"
    #>  [6] "betweenss"    "size"         "iter"         "ifault"

``` r
fviz_cluster(k2, data = CustomerSalesClust3)
```

![](figs/five-cluster-1.png)<!-- -->

``` r
CustomerSalesCluser <- base::data.frame(CustomerSalesClust, k2$cluster)
CustomerSalesCluser %>% dplyr::glimpse(78)
```

    #>  Observations: 1,222
    #>  Variables: 6
    #>  $ id             <dbl> 1, 7, 8, 9, 15, 16, 17, 18, 19, 22, 25, 27, 28, 29, …
    #>  $ sales_sum      <dbl> 11.58, 13.24, 4.95, 32.85, 5.40, 2.49, 17.70, 3.36, …
    #>  $ sales_median   <dbl> 5.790, 6.620, 4.950, 32.850, 2.700, 2.490, 17.700, 3…
    #>  $ quantity_sum   <dbl> 2, 2, 3, 3, 2, 1, 6, 1, 1, 1, 1, 12, 4, 2, 2, 8, 2, …
    #>  $ quantiy_median <dbl> 1, 1, 3, 3, 1, 1, 6, 1, 1, 1, 1, 6, 1, 1, 1, 1, 1, 1…
    #>  $ k2.cluster     <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
