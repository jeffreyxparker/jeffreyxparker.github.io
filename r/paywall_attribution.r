# Libraries
library(tidyverse)
library(lubridate)
library(rpart)
library(rpart.plot)

# Data
paywall <- read_csv("paywall_data.csv") %>%
  mutate_at(3:18, mdy_hm) %>%
  inner_join(read_csv("paywall_payment_data.csv"), by = "id") %>%
  mutate(`First Payment Date` = mdy_hm(`First Payment Date`))


# Exploratory -------------------------------------------------------------

# Distribution of Payments
summary(paywall$`Registration Date`)
table(paywall$`Paid?`)
as.data.frame(table(as_date(paywall$`First Payment Date`)))
ggplot(paywall) +
  geom_histogram(aes(`First Payment Value`))

# Conversion rates
foo <- paywall %>%
  group_by(year(`Registration Date`), month(`Registration Date`)) %>%
  summarise(Registrations = n(),
            Converstions = sum(`Paid?`),
            Converstion_rate = Converstions/Registrations)

# Filtering for 2016 only
paywall <- paywall %>% 
  filter(`Registration Date` >= as_date("2016-01-01")) 

# Removing all paywalls after first payment date
foo <- paywall %>%
  mutate_at(4:18, function(.){!is.na(.)}) %>%
  mutate(paywalls_seen = rowSums(.[4:18]))
sum(foo$paywalls_seen) #22670 paywalls seen before

paywall <- paywall %>%
  mutate(temp_date = ifelse(is.na(`First Payment Date`), ymd_hm("2999-01-01 02:22"), `First Payment Date`)) %>%
  mutate(temp_date = as.POSIXct(temp_date, tz = "UTC", origin = "1970-01-01")) 
paywall <- paywall %>%
  mutate_at(4:18, function(.){ifelse(. >= paywall$temp_date, NA, .)}) %>%
  mutate_at(4:18, function(.){as.POSIXct(., tz = "UTC", origin = "1970-01-01")}) %>%
  select(-temp_date)

foo <- paywall %>%
  mutate_at(4:18, function(.){!is.na(.)}) %>%
  mutate(paywalls_seen = rowSums(.[4:18]))
sum(foo$paywalls_seen) #21400 paywalls seen after

# More testing to ensure no paywalls after first payment date
foo <- paywall %>%
  filter(`Paid?` == 1)
foo$colMax <- apply(foo[,4:18], 1, function(x) max(x, na.rm = TRUE))
foo$colMax <- ymd_hms(foo$colMax)
foo$diff <- (foo$`First Payment Date`-foo$colMax)/(24*60)

# Removing all paywalls before registration date
foo <- paywall %>%
  mutate_at(4:18, function(.){!is.na(.)}) %>%
  mutate(paywalls_seen = rowSums(.[4:18]))
sum(foo$paywalls_seen) #21400 paywalls seen before

paywall <- paywall %>%
  mutate(temp_date = ifelse(is.na(`Registration Date`), ymd_hm("1900-01-01 02:22"), `Registration Date`)) %>%
  mutate(temp_date = as.POSIXct(temp_date, tz = "UTC", origin = "1970-01-01")) 

paywall <- paywall %>%
  mutate_at(4:18, function(.){ifelse(. <= paywall$temp_date, NA, .)}) %>%
  mutate_at(4:18, function(.){as.POSIXct(., tz = "UTC", origin = "1970-01-01")}) %>%
  select(-temp_date)

foo <- paywall %>%
  mutate_at(4:18, function(.){!is.na(.)}) %>%
  mutate(paywalls_seen = rowSums(.[4:18]))
sum(foo$paywalls_seen) #20898 paywalls seen after

foo <- paywall
foo$colMin <- apply(foo[,4:18], 1, function(x) min(x, na.rm = TRUE))
foo$colMin <- ymd_hms(foo$colMin)
foo$diff <- (foo$colMin - foo$`First Payment Date`)/(24*60)

# Converstion Rate --------------------------------------------------------

# Last Paywall Wins

paywall_vert <- paywall %>%
  select(1:2,4:18) %>%
  gather(paywall,date,3:17) %>%
  arrange(id)

foo <- paywall_vert %>%
  group_by(id) %>%
  filter(date == max(date, na.rm = TRUE))

bar <- foo %>%
  group_by(paywall) %>%
  summarise(cnt = n(),
            converted = sum(`Paid?`),
            converstion_rate = converted/cnt) %>%
  arrange(desc(cnt))

# Every Paywall Seen

# All Customers
paywall_vert %>% 
  filter(!is.na(date)) %>%
  group_by(id) %>%
  summarise(cnt_paywalls = n()) %>%
  group_by(cnt_paywalls) %>%
  summarise(dist = n())

# Converted Customers
paywall_vert %>% 
  filter(!is.na(date),
         `Paid?` == 1) %>%
  group_by(id) %>%
  summarise(cnt_paywalls = n()) %>%
  group_by(cnt_paywalls) %>%
  summarise(dist = n())

bar <- paywall_vert %>%
  filter(!is.na(date)) %>%
  group_by(paywall) %>%
  summarise(cnt = n(),
            converted = sum(`Paid?`),
            not_converted = cnt - converted,
            converstion_rate = converted/cnt) %>%
  arrange(desc(converted))

# Denominator in both conversion rate methods
sum(paywall_vert$`Paid?`) #29025
sum(paywall$`Paid?`) #1935

# Testing Significance
foo <- bar[c(1,3,15),]
chisq.test(foo$converted, foo$not_converted)

# Predictive Modelling ----------------------------------------------------

paywall_dt <- paywall %>%
  select(2,4:18) %>%
  mutate_at(2:16, function(.){factor(!is.na(.), levels=c("TRUE","FALSE"))}) %>%
  mutate(`Paid?` = ifelse(`Paid?`==1,"Paid","Not"))

# Grow a tree
control <- rpart.control(minbucket = 5, cp = 0.0001, maxsurrogate = 0, usesurrogate = 0, xval = 3) # Tuning parameters
fit1 <- rpart(`Paid?` ~ ., paywall_dt, method="class", control = control) # model fit

# results of tree
printcp(fit1) # display the results 
plotcp(fit1) # visualize cross-validation results 

# prune the tree 
#fit1<- prune(fit1, cp=fit1$cptable[which.min(fit1$cptable[,"xerror"]),"CP"])
fit1<- prune(fit1, cp = 0.00010336)
foo <- as.data.frame(fit1$variable.importance )
summary(fit1) 

# plot tree 
plot(fit1, uniform=TRUE, main="Pruned Decision Tree")
text(fit1, use.n=TRUE, all=TRUE, cex=.8)
rpart.plot(fit1, cex = .8)

# Revenue Attribution -----------------------------------------------------

# Last Paywall Wins
paid <- paywall %>%
  filter(`Paid?` == 1) %>%
  select(1,4:18,20) %>%
  gather(paywall, date, 2:16) %>%
  filter(!is.na(date)) %>%
  group_by(id) %>%
  arrange(desc(date)) %>%
  top_n(1) %>%
  group_by(paywall) %>%
  summarise(rev = sum(`First Payment Value`))


# Equal Weighting
paid <- paywall %>%
  filter(`Paid?` == 1) %>%
  select(1,4:18,20) %>%
  mutate_at(2:16, function(.){!is.na(.)}) %>%
  mutate(paywalls_seen = rowSums(.[2:16]),
         rev_perc = `First Payment Value`/paywalls_seen) %>%
  gather(paywall,value,2:16) %>%
  filter(value == TRUE) %>%
  arrange(id) %>%
  group_by(paywall) %>%
  summarise(rev = sum(rev_perc))

# Time-Weighted

# Calculating total trial duration

options(scipen=999)
paid <- paywall %>%
  filter(`Paid?` == 1) %>%
  mutate(trial_duration_days = as.numeric(`First Payment Date` - `Registration Date`)/(60*60*24)) %>%
  filter(!is.na(`Registration Date`)) 
paid$trial_duration_days[1]
paid <- paid %>%
  mutate_at(4:18, function(.){. - paid$`Registration Date`}) %>%
  mutate_at(4:18, function(.){as.numeric(.)/(60*24)})
paid$`(Pw) Page-Limit`[1]

# Weighting by days since registraion
paid <- paid %>%
  mutate_at(4:18, function(.){. / paid$trial_duration_days})
paid$`(Pw) Page-Limit`[1]

# Calculating revenue attribution
paid <- paid %>%
  mutate(denom = rowSums(.[4:18], na.rm = TRUE)) # denominator
paid <- paid %>%
  mutate_at(4:18, function(.){. / paid$denom}) # weighting
paid <- paid %>%
  mutate(total_perc = rowSums(.[4:18], na.rm = TRUE)) # should equal 1
paid <- paid %>%
  mutate_at(4:18, function(.){. * paid$`First Payment Value`}) #value

# testing
paid <- paid %>%
  mutate(test = rowSums(.[4:18], na.rm = TRUE)) #should equal first payment

paid <- paid %>%
  select(1,4:18,20) %>%
  gather(paywall, rev, 2:16) %>%
  filter(!is.na(rev))

paid <- paid %>% 
  group_by(paywall) %>%
  summarise(rev_att = sum(rev))
  

# Association Rules -------------------------------------------------------

paid <- paywall %>%
  filter(`Paid?` == 1) %>%
  select(id, `(Pw) Page-Limit`, `(Pw) Pdf-dpi`, `(Pw) Storage`, `First Payment Value`)

paid$group <- ifelse(!is.na(paid$`(Pw) Page-Limit`) & !is.na(paid$`(Pw) Storage`) & !is.na(paid$`(Pw) Pdf-dpi`), "All Three",
              ifelse(!is.na(paid$`(Pw) Page-Limit`) & !is.na(paid$`(Pw) Storage`) & is.na(paid$`(Pw) Pdf-dpi`), "Page-Limit & Storage",
              ifelse(!is.na(paid$`(Pw) Page-Limit`) & is.na(paid$`(Pw) Storage`) & !is.na(paid$`(Pw) Pdf-dpi`), "Page-Limit & PDF",
              ifelse(is.na(paid$`(Pw) Page-Limit`) & !is.na(paid$`(Pw) Storage`) & !is.na(paid$`(Pw) Pdf-dpi`), "Storage & PDF",
              ifelse(!is.na(paid$`(Pw) Page-Limit`) & is.na(paid$`(Pw) Storage`) & is.na(paid$`(Pw) Pdf-dpi`), "Page-Limit Only",
              ifelse(is.na(paid$`(Pw) Page-Limit`) & !is.na(paid$`(Pw) Storage`) & is.na(paid$`(Pw) Pdf-dpi`), "Storage Only", 
              ifelse(is.na(paid$`(Pw) Page-Limit`) & is.na(paid$`(Pw) Storage`) & !is.na(paid$`(Pw) Pdf-dpi`), "PDF Only",
              ifelse(is.na(paid$`(Pw) Page-Limit`) & is.na(paid$`(Pw) Storage`) & is.na(paid$`(Pw) Pdf-dpi`), "None of Them","Error"))))))))

foo <- paid %>%
  group_by(group) %>%
  summarise(rev_ave = mean(`First Payment Value`),
            cnt = n())
