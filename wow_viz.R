#=====================================================================#
# This is code to create: 2019-12-12-wow-viz.R
# Authored by and feedback to:
# MIT License
# Version:
#=====================================================================#

library(readr)
library(tidyverse)
library(lubridate)
library(ggthemes)
library(cluster)
library(factoextra)
library(textshape)

# fs::dir_ls("data/raw")
ecom <- read_csv("data-model/online-retail/Online_Retail.csv")

ecom$invoicedate_date <- as.date(ecom$invoicedate, "%m/%d/%y")
ecom$dow <- day(ecom$invoicedate_date)
ecom$week <- week(ecom$invoicedate_date)
ecom$yr <- year(ecom$invoicedate_date)
ecom$week_year <- floor_date(ecom$invoicedate_date, unit = "week")
ecom$month <- month(ecom$week_year, abbr = true, label = true)
ecom$floor_month <- floor_date(ecom$week_year, unit = "month")


wow <- ecom %>%
  select(week_year, Quantity) %>%
  group_by(week_year) %>%
  summarize(Week_Qty = sum(Quantity)) %>%
  mutate(Prev_Week = lag(Week_Qty, 1)) %>%
  mutate(WoW_Quantity = (Week_Qty - Prev_Week) / Prev_Week) %>%
  mutate(month = month(week_year, abbr = TRUE, label = TRUE)) %>%
  group_by(week_year)



ggWoW <- ggplot(
  data = wow,
  mapping = aes(
    x = week_year,
    y = WoW_Quantity
  )
) +
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


ggQty <- wow %>%
  na.omit() %>%
  ggplot(data = ., aes(x = week_year, y = Week_Qty)) +
  geom_line() +
  geom_smooth() +
  geom_point() +
  # stat_summary(fun.y=mean, geom="bar") +
  # stat_summary(fun.data=mean_cl_boot, geom="errorbar", width=0.3) +
  theme_fivethirtyeight() +
  theme(axis.title = element_text()) +
  theme(legend.position = "none") +
  labs(
    title = "Quantity Per Week",
    x = "Week", y = "Quantity Sold"
  )


ggQty


monthly <- ecom %>%
  select(floor_month, Country, Quantity, UnitPrice) %>%
  mutate(Sales = Quantity * UnitPrice) %>%
  group_by(floor_month, Country) %>%
  summarize(
    MonthlySales = sum(Sales),
    MedianSale = median(Sales)
  ) %>%
  group_by(floor_month, Country)

monthly %>% count(floor_month)

ggmonthly <- monthly %>%
  sample_n(size = 12) %>%
  ggplot(
    data = .,
    mapping = aes(
      x = floor_month,
      y = MonthlySales,
      group = Country
    )
  ) +
  geom_line() +
  geom_point() +
  theme_fivethirtyeight() +
  theme(axis.title = element_text()) +
  theme(legend.title = element_blank()) +
  scale_y_continuous(labels = scales::dollar_format(accuracy = 1)) +
  facet_wrap(~Country, scales = "free") +
  ylab("Sales") +
  xlab("Month") +
  ggtitle("Monthly Sales")

ggmonthly


ggAOV <- monthly %>%
  ggplot(
    data = .,
    mapping = aes(
      x = floor_month,
      y = MedianSale
    )
  ) +
  geom_line() +
  geom_point() +
  theme_fivethirtyeight() +
  theme(axis.title = element_text()) +
  theme(legend.title = element_blank()) +
  scale_y_continuous(labels = scales::dollar_format(accuracy = 1)) +
  facet_wrap(~Country, scales = "free") +
  ylab("Sales") +
  xlab("Month") +
  ggtitle("Median Order Value")

ggAOV

customers_sales <- ecom %>%
  select(CustomerID, Quantity, UnitPrice) %>%
  group_by(CustomerID) %>%
  mutate(Sales = (Quantity * UnitPrice)) %>%
  summarize(
    Sales = sum(Sales),
    MedianSale = median(Sales),
    Quantity = sum(Quantity),
    Median_Quantiy = median(Quantity)
  ) %>%
  group_by(CustomerID)

customers_country <- ecom %>%
  distinct(CustomerID, Country) %>%
  group_by(CustomerID)

customers_sales_country <- customers_sales %>%
  inner_join(customers_country, by = "CustomerID")


customer_sales_clust <- data.frame(customers_sales)
customer_sales_clust <- customer_sales_clust %>%
  drop_na() %>%
  filter(Sales > 0)
summary(customer_sales_clust)
customer_sales_clust <- column_to_rownames(customer_sales_clust) # , var = "CustomerID")

customer_sales_clust <- scale(customer_sales_clust)
k2 <- kmeans(customer_sales_clust, centers = 2, nstart = 25)
k2

fviz_cluster(k2, data = customer_sales_clust)

customer_sales_clust <- data.frame(customer_sales_clust, k2$cluster)
