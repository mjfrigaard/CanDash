README - Wrangling cannabis data
================
Martin Frigaard
current version: 2019-11-21

# Motivation

This script outlines the steps to wrangle the Cannabis and Online Retail
data.

## Import Online Retail data

This data came from a UK e-commerce dataset from the [UCI Machine
Learning
Laboratory](https://archive.ics.uci.edu/ml/datasets/online+retail).

``` r
# fs::dir_tree("data")
OnlineRetail <- readr::read_csv("data/raw/Online_Retail.csv",
                                col_types = cols(
                                InvoiceNo = col_character(),
                                StockCode = col_character(),
                                Description = col_character(),
                                Quantity = col_integer(),
                                InvoiceDate = col_datetime("%m/%d/%Y %H:%M"),
                                UnitPrice = col_double(),
                                CustomerID = col_integer(),
                                Country = col_character()))
```

``` r
dplyr::glimpse(OnlineRetail)
```

    #>  Observations: 541,909
    #>  Variables: 8
    #>  $ InvoiceNo   <chr> "536365", "536365", "536365", "536365", "536365", "5363…
    #>  $ StockCode   <chr> "85123A", "71053", "84406B", "84029G", "84029E", "22752…
    #>  $ Description <chr> "WHITE HANGING HEART T-LIGHT HOLDER", "WHITE METAL LANT…
    #>  $ Quantity    <int> 6, 6, 8, 6, 6, 2, 6, 6, 6, 32, 6, 6, 8, 6, 6, 3, 2, 3, …
    #>  $ InvoiceDate <dttm> 2010-12-01 08:26:00, 2010-12-01 08:26:00, 2010-12-01 0…
    #>  $ UnitPrice   <dbl> 2.55, 3.39, 2.75, 3.39, 3.39, 7.65, 4.25, 1.85, 1.85, 1…
    #>  $ CustomerID  <int> 17850, 17850, 17850, 17850, 17850, 17850, 17850, 17850,…
    #>  $ Country     <chr> "United Kingdom", "United Kingdom", "United Kingdom", "…

There are 8 variables in this data frame.

``` r
skimr::skim(OnlineRetail)
```

    #>  Skim summary statistics
    #>   n obs: 541909 
    #>   n variables: 8 
    #>  
    #>  ── Variable type:character ───
    #>      variable missing complete      n min max empty n_unique
    #>       Country       0   541909 541909   3  20     0       38
    #>   Description    1454   540455 541909   1  35     0     4211
    #>     InvoiceNo       0   541909 541909   6   7     0    25900
    #>     StockCode       0   541909 541909   1  12     0     4070
    #>  
    #>  ── Variable type:integer ─────
    #>     variable missing complete      n     mean      sd     p0   p25   p50   p75
    #>   CustomerID  135080   406829 541909 15287.69 1713.6   12346 13953 15152 16791
    #>     Quantity       0   541909 541909     9.55  218.08 -80995     1     3    10
    #>    p100     hist
    #>   18287 ▇▆▇▇▆▆▆▇
    #>   80995 ▁▁▁▁▇▁▁▁
    #>  
    #>  ── Variable type:numeric ─────
    #>    variable missing complete      n mean    sd        p0  p25  p50  p75  p100
    #>   UnitPrice       0   541909 541909 4.61 96.76 -11062.06 1.25 2.08 4.13 38970
    #>       hist
    #>   ▁▇▁▁▁▁▁▁
    #>  
    #>  ── Variable type:POSIXct ─────
    #>      variable missing complete      n        min        max     median n_unique
    #>   InvoiceDate       0   541909 541909 2010-12-01 2011-12-09 2011-07-19    23260

## Import kushy data

``` r
kushy_files <- fs::dir_ls("data/kushy-datasets", regexp = "kushy_")
# kushy_files[4]
KushyBrands <- readr::read_csv(kushy_files[1])
```

    #>  Parsed with column specification:
    #>  cols(
    #>    id = col_double(),
    #>    name = col_character(),
    #>    slug = col_character(),
    #>    location = col_character(),
    #>    category = col_character(),
    #>    instagram = col_logical()
    #>  )

``` r
KushyProducts <- readr::read_csv(kushy_files[2])
```

    #>  Parsed with column specification:
    #>  cols(
    #>    id = col_double(),
    #>    name = col_character(),
    #>    slug = col_character(),
    #>    brand = col_character(),
    #>    category = col_character(),
    #>    strain = col_character(),
    #>    thc = col_character(),
    #>    cbd = col_character(),
    #>    lab_test = col_character()
    #>  )

``` r
KushyShops <- readr::read_csv(kushy_files[3])
```

    #>  Parsed with column specification:
    #>  cols(
    #>    .default = col_character(),
    #>    id = col_double(),
    #>    status = col_double(),
    #>    sort = col_double(),
    #>    description = col_logical(),
    #>    lat = col_double(),
    #>    lng = col_double(),
    #>    address = col_double(),
    #>    tumblr = col_logical(),
    #>    googleplus = col_logical()
    #>  )

    #>  See spec(...) for full column specifications.

``` r
KushyStrains <- readr::read_csv(kushy_files[4])
```

    #>  Parsed with column specification:
    #>  cols(
    #>    .default = col_character(),
    #>    id = col_double(),
    #>    status = col_double(),
    #>    sort = col_double(),
    #>    thc = col_double(),
    #>    cbd = col_double(),
    #>    cbn = col_double()
    #>  )
    #>  See spec(...) for full column specifications.

### Categorical data

These are the categories in the `KushyBrands` data frame.

``` r
kushy_brands_inspect_cat <- KushyBrands %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_cat() 
kushy_brands_inspect_cat %>% 
    inspectdf::show_plot()
```

![](figs/cat-KushyBrands-1.png)<!-- -->

``` r
kushy_products_inspect_cat <- KushyProducts %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_cat() 
kushy_products_inspect_cat %>% 
    inspectdf::show_plot()
```

![](figs/cat-KushyProducts-1.png)<!-- -->

``` r
kushy_shops_inspect_cat <- KushyShops %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_cat()
kushy_shops_inspect_cat %>% 
    inspectdf::show_plot(text_labels = TRUE)
```

![](figs/cat-KushyShops-1.png)<!-- -->

``` r
kushy_strains_inspect_cat <- KushyStrains %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_cat()
kushy_strains_inspect_cat %>% 
    inspectdf::show_plot(text_labels = TRUE)
```

![](figs/cat-KushyStrains-1.png)<!-- -->

## Missing Kushy data

These plots show the missing data

``` r
kushy_brands_inspect_na <- KushyBrands %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_na()
kushy_brands_inspect_na %>% 
    inspectdf::show_plot(text_labels = TRUE)
```

![](figs/kushy_brands_inspect_na-1.png)<!-- -->

``` r
kushy_products_inspect_na <- KushyProducts %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_na()
kushy_products_inspect_na %>% 
    inspectdf::show_plot(text_labels = TRUE)
```

![](figs/kushy_products_inspect_na-1.png)<!-- -->

``` r
kushy_shops_inspect_na <- KushyShops %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_na()
kushy_shops_inspect_na %>% 
    inspectdf::show_plot(text_labels = TRUE)
```

![](figs/kushy_shops_inspect_na-1.png)<!-- -->

``` r
kushy_strains_inspect_na <- KushyStrains %>% 
    select_if(is.character) %>% 
    inspectdf::inspect_na()
kushy_strains_inspect_na %>% 
    inspectdf::show_plot(text_labels = TRUE)
```

![](figs/kushy_strains_inspect_na-1.png)<!-- -->
