README - Ecomm Retail Data
================
Martin Frigaard
current version: 2019-11-07

Use this tiny `url` to download this file:
<http://bit.ly/good-enuff-template>, or enter this into your R/RStudio
console:

``` r
utils::download.file(url = "http://bit.ly/good-enuff-template", 
                     destfile = "goodenuffR-template.Rmd")
```

# Cannabis Sales/Marketing Dashboard

The company that I mentioned previously is
[Headset](https://www.headset.io/). They recently secured $12.1 M in
seed funding which you can read about
[here](https://www.newcannabisventures.com/leading-cannabis-analytics-company-headset-closes-12-1-million-series-a/).
I agree with you Peter that there is a lot of room in this space and
look forward to discovering the most pressing problems we can solve.
Other potential competitors in this space to be aware of are:

[Springbig](https://www.springbig.com/) - Read more about them
[here](https://www.newcannabisventures.com/springbig-cannabis-dispensary-marketing-engine/).

[DemandLink](https://demandlink.com/solutions/)- Read more about them
[here](https://www.newcannabisventures.com/springbig-cannabis-dispensary-marketing-engine/).

I believe Headset is the leader at present. Headset founders also
started [Leafly](https://www.leafly.com/), a Yelp-style platform for
cannabis.

The landing page for discovery is a great place to start. I have
obtained a UK e-commerce dataset from the [UCI Machine Learning
Laboratory](https://archive.ics.uci.edu/ml/datasets/online+retail). It
can also be found on Kaggle. I’ve taken the liberty of adding both of
you to an RStudio Cloud project I’ve started with this data. I’ve
cleaned and prepped it for purposes of making some slick time-series
graphs, or any cool sample visualizations we can use for the landing
page. Feel free to edit an collaborate as you see fit.

## Project folder structure

``` r
fs::dir_tree(".")
```

    #>  .
    #>  ├── 00-setup.R
    #>  ├── CHANGELOG.md
    #>  ├── CITATION
    #>  ├── INSTALL.R
    #>  ├── LICENSE
    #>  ├── README.Rmd
    #>  ├── README.md
    #>  ├── code
    #>  │   ├── 01-import.R
    #>  │   ├── 02-tidy.R
    #>  │   ├── 03-wrangle.R
    #>  │   ├── 04-visualize.R
    #>  │   ├── 05-model.R
    #>  │   ├── 06-communicate.R
    #>  │   └── runall.R
    #>  ├── data
    #>  │   ├── Online_Retail.csv
    #>  │   └── README.md
    #>  ├── doc
    #>  │   ├── lab-notes.md
    #>  │   └── project-manuscript.md
    #>  ├── ecomm-retail-data.Rproj
    #>  ├── requirements.txt
    #>  └── results
    #>      └── README.md
