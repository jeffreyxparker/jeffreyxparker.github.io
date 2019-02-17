# Libraries
library(tidyverse)
library(lubridate)
library(RMySQL)

# Get the data
con <- dbConnect(MySQL(),
                 user="guest",
                 password="relational",
                 dbname="AdventureWorks2014",
                 host="relational.fit.cvut.cz")
sales <- dbGetQuery(con, "SELECT * FROM SalesOrderDetail;")

# Clean up the data
sales <- sales %>%
  select(-SalesOrderDetailID, -CarrierTrackingNumber, -rowguid) %>%
  mutate(ModifiedDate = as_date(ModifiedDate))

# Find products with many sales and many different prices
grouped_sales <- sales %>%
  select(ProductID, OrderQty, UnitPrice, ModifiedDate) %>%
  filter(SpecialOfferID == 0) %>%
  group_by(ProductID) %>%
  summarise(total_qty = sum(OrderQty),
            unique_prices = length(unique(UnitPrice)),
            std_price = sd(UnitPrice),
            days_sold = (max(ModifiedDate) - min(ModifiedDate))) %>%
  arrange(desc(total_qty),desc(unique_prices)) 

# Possible Products 715, 864, 714
# 863: 4 prices over 1 year
# 854
# 852
sales %>%
  filter(ProductID == 852) %>%
  group_by(ModifiedDate, UnitPrice) %>%
  summarise(total_sales = sum(OrderQty)) %>%
  ggplot() +
  geom_point(aes(x=ModifiedDate, y=UnitPrice, size = total_sales))

costs <- dbGetQuery(con, "SELECT * FROM ProductCostHistory;")
list_prices <- dbGetQuery(con, "SELECT * FROM ProductListPriceHistory;") %>%
  mutate(StartDate = as_date(StartDate),
         EndDate = as_date(EndDate),
         ProductID = as.factor(ProductID)) %>%
  select(-ModifiedDate)

ggplot(list_prices) +
  geom_line(aes(x=StartDate, y=scale(ListPrice), color=ProductID)) +
  theme(legend.position="none")
