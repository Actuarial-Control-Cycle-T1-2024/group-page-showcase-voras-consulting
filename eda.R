install.packages("dplyr", "ggplot2", "tidyverse")
library(dplyr)
library(ggplot2)
library(tidyverse)

options(scipen=10)

inforce_raw_eda <- read.csv("2024-srcsc-superlife-inforce-dataset.csv", header = T)
head(inforce_raw)

## DATA CLEANING

# Checking for NAs in raw data (none found)
inforce <- inforce_raw_eda %>%
  drop_na(Policy.type, Issue.year, Issue.age,
          Sex, Face.amount, Smoker.Status,
          Underwriting.Class, Urban.vs.Rural,
          Region, Distribution.Channel) 

write.csv(inforce, file = "C:\\Users\\Sam\\Downloads\\clean_inforce.csv")

# Checking for duplicate policyholders (none found)
length(unique(inforce$Policy.number))==length(inforce$Policy.number)

inforce <- inforce_raw %>%
  rename(
    Policy.number = colnames(inforce_raw)[1]
  )

# Checking for any entries beyond 1 and NA (Lapse has Y as well)
unique(inforce$Lapse.Indicator)
unique(inforce$Death.indicator)

# Checking if any data entries have both death and lapse
checkDL <- inforce %>%
  filter(Death.indicator == 1, Lapse.Indicator != "<NA>") 

lapse_inforce <- inforce %>%
  filter(Lapse.Indicator != "<NA>")

# Check if Cause of death has any NAs
checkCoDNA <- inforce %>%
  filter(Death.indicator == 1, Cause.of.Death == "<NA>")

death_inforce <- inforce %>%
  filter(Death.indicator == 1)

living_inforce <- inforce %>%
  filter(is.na(Lapse.Indicator) == TRUE, is.na(Death.indicator) == TRUE)

#write.csv(death_inforce, file = "C:\\Users\\Sam\\Downloads\\death_inforce.csv")
#write.csv(lapse_inforce, file = "C:\\Users\\Sam\\Downloads\\lapse_inforce.csv")
#write.csv(living_inforce, file = "C:\\Users\\Sam\\Downloads\\living_inforce.csv")

## EDA

# Checking underwriting class statistics

underwriting <- inforce %>%
  group_by(Underwriting.Class, Smoker.Status) %>%
  summarise(n=n()) %>%
  mutate(pc=n/sum(n))

# Correlation between underwriting class and age
age_class <- inforce %>%
  group_by(Issue.age, Underwriting.Class) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))

# Checking demographic distribution

# Age
ggplot(inforce, aes(x=Issue.age)) +
  geom_histogram(bins=max(inforce$Issue.age)+1-min(inforce$Issue.age))

age_amt <- inforce %>%
  group_by(Issue.age) %>%
  summarise(mean_amt = mean(Face.amount))

ggplot(age_amt, aes(Issue.age, mean_amt)) +
  geom_col()

# Gender
gender_inforce <- inforce %>%
  group_by(Sex) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))
gender_inforce

# Smoker status
smoker_inforce <- inforce %>%
  group_by(Smoker.Status) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))
smoker_inforce


# Underwriting class analysis

under_inforce <- inforce %>%
  group_by(Sex, Smoker.Status, Underwriting.Class) %>%
  summarise(n=n())

amt_risk <- inforce %>%
  group_by(Underwriting.Class, Face.amount) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))

# underwriting class proportions for non-smokers
age_class <- inforce %>%
  filter(Smoker.Status == "S") %>%
  group_by(Issue.age, Underwriting.Class) %>%
  summarise(n=n()) %>%
  mutate(pc=n/sum(n))

age_verylow <- filter(age_class, Underwriting.Class == "very low risk")$pc  
age_low <- filter(age_class, Underwriting.Class == "low risk")$pc  
age_moderate <- filter(age_class, Underwriting.Class == "moderate risk")$pc  
age_high <- filter(age_class, Underwriting.Class == "high risk")$pc 

age_risk <- data.frame(age = c(26:65), age_verylow, age_low, age_moderate, age_high)
age_risk_s <- data.frame(age = c(26:65), age_moderate, age_high)

ggplot(age_risk_s, aes(x=age)) +
#  geom_line(aes(y=age_verylow), colour = "black") +
#  geom_line(aes(y=age_low), colour = "blue") +
  geom_line(aes(y=age_moderate), colour = "red") +
  geom_line(aes(y=age_high), colour = "green")


# Checking for unusual trends in deaths

deathcause_count <- death_inforce %>%
  group_by(Cause.of.Death) %>%
  summarise(n=n())

smoker_count <- death_inforce %>%
  group_by(Cause.of.Death, Smoker.Status) %>%
  summarise(n = n())

gender_count <- death_inforce %>%
  group_by(Cause.of.Death, Sex) %>%
  summarise(n = n())

ggplot(deathcause_count, aes(x=Cause.of.Death, y=n)) +
  geom_col()

ggplot(death_inforce, aes(x=Year.of.Death)) +
  geom_histogram(bins=length(unique(death_inforce$Year.of.Death)))

# Distribution of age at death
death_age <- death_inforce %>%
  mutate(Age.at.death = Issue.age + Year.of.Death - Issue.year)

mean(death_age$Age.at.death)
median(death_age$Age.at.death)
which.max(tabulate(death_age$Age.at.death))

ggplot(death_age,aes(x=Age.at.death)) +
  geom_histogram(bins=max(death_age$Age.at.death)+1-min(death_age$Age.at.death))
quantile(death_age$Age.at.death)
sd(death_age$Age.at.death)

# Cancer
ggplot(filter(death_age, Cause.of.Death == "C00-D48"), aes(x=Age.at.death)) +
  geom_histogram(bins=max(death_age$Age.at.death)+1-min(death_age$Age.at.death))
quantile(filter(death_age, Cause.of.Death == "C00-D48")$Age.at.death)
sd(filter(death_age, Cause.of.Death == "C00-D48")$Age.at.death)

# Circulatory
ggplot(filter(death_age, Cause.of.Death == "I00-I99"), aes(x=Age.at.death)) +
  geom_histogram(bins=max(death_age$Age.at.death)+1-min(death_age$Age.at.death))
quantile(filter(death_age, Cause.of.Death == "I00-I99")$Age.at.death)
sd(filter(death_age, Cause.of.Death == "I00-I99")$Age.at.death)

# Checking statistics of Policy types

policytype <- inforce %>%
  group_by(Policy.type, Issue.age) %>%
  summarise(n=n())

ggplot() +
  geom_col(data = filter(policytype, Policy.type == "SPWL"), 
           aes(x = Issue.age, y = n),
           colour = "red", alpha = .5) +
  geom_col(data = filter(policytype, Policy.type == "T20"), 
           aes(x = Issue.age, y = n),
           colour = "blue", alpha = .5)

policy_amt <- inforce %>%
  group_by(Policy.type, Face.amount) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))

ggplot() +
  geom_col(data = filter(policy_amt, Policy.type == "SPWL"), 
           aes(x = Face.amount, y = pc),
           colour = "red", alpha = .5) +
  geom_col(data = filter(policy_amt, Policy.type == "T20"), 
           aes(x = Face.amount, y = pc),
           colour = "blue", alpha = .5)

# Checking new claims yearly and proportion of deaths

living_count <- living_inforce %>%
  group_by(Issue.year) %>%
  summarise(n=n())

lapse_count <- lapse_inforce %>%
  group_by(Year.of.Lapse) %>%
  summarise(lapses = n())

death_count <- death_inforce %>%
  group_by(Year.of.Death) %>%
  summarise(deaths = n())

death_count_2004 <- inforce_raw %>%
  filter(Death.indicator == 1, Year.of.Death >= 2004) %>%
  group_by(Year.of.Death) %>%
  summarise(deaths = n()) %>%
  mutate(cumulative = cumsum(deaths))

death_check <- inforce %>%
  group_by(Issue.year, Year.of.Death) %>%
  summarise(n=n())

newclaims <- inforce %>%
  group_by(Issue.year) %>%
  summarise(new = n()) %>%
  mutate(deaths = death_count$deaths,
         lapses = lapse_count$lapses) %>%
  mutate(policies = cumsum(new)-deaths-lapses) %>%
  mutate(death_prop = deaths/policies)

ggplot(data = newclaims, aes(x=Issue.year)) +
  geom_col(aes(y=policies)) +
  geom_line(aes(y=death_prop*100000000)) +
  scale_y_continuous(
    name = "Number of policyholders",
    sec.axis = sec_axis(~.*1/100000000, name = "Proportion of deaths to policies")
  )

# Checking differences in urban/rural and region

urbanrural <- inforce %>%
  group_by(Region, Urban.vs.Rural) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))

region_wealth <- inforce %>%
  group_by(Region, Face.amount) %>%
  summarise(n=n()) %>%
  mutate(percent = n/sum(n)) %>%
  ungroup() %>%
  relocate(Face.amount) %>%
  group_by(Face.amount, Region) %>%
  arrange(.by_group = TRUE)

ur_wealth <- inforce %>%
  group_by(Urban.vs.Rural, Face.amount) %>%
  summarise(freq=n()) %>%
  mutate(pc = freq/sum(freq))

mean(filter(inforce, Urban.vs.Rural == "Urban")$Face.amount)
mean(filter(inforce, Urban.vs.Rural == "Rural")$Face.amount)

ggplot() +
  geom_col(data = filter(ur_wealth, Urban.vs.Rural == "Urban"), 
           aes(x = Face.amount, y = pc),
           colour = "red", alpha = .5) +
  geom_col(data = filter(ur_wealth, Urban.vs.Rural == "Rural"), 
           aes(x = Face.amount, y = pc),
           colour = "blue", alpha = .5)

# Checking feasibility of organising policies into groups

groups <- inforce %>%
  group_by(Policy.type, Issue.year, Issue.age, 
           Sex, Face.amount, Smoker.Status, 
           Underwriting.Class) %>%
  summarise(n=n())

# Checking lapse proportion per year

lapse_amt <- inforce %>%
  group_by(Year.of.Lapse) %>%
  summarise(lapses = n()) %>%
  filter(row_number() <= n()-1) %>%
  mutate(inforce_pols = newclaims$policies,
         lapse_pc = lapses/inforce_pols)
  
ggplot(lapse_amt, aes(Year.of.Lapse, lapse_pc)) + geom_col()

instant_lapse <- inforce_raw %>%
  filter(Issue.year == Year.of.Lapse)

# Smoker proportion per year

smoker_gender <- inforce %>%
  group_by(Sex, Smoker.Status) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))

smoker_amt_male <- inforce %>%
  filter(Sex == "M") %>%
  group_by(Issue.year, Smoker.Status) %>%
  summarise(n = n()) %>%
  mutate(male = n/sum(n)) %>%
  filter(Smoker.Status == "S")

smoker_amt_female <- inforce %>%
  filter(Sex == "F") %>%
  group_by(Issue.year, Smoker.Status) %>%
  summarise(n = n()) %>%
  mutate(female = n/sum(n)) %>%
  filter(Smoker.Status == "S")

smoker_df <- data.frame(smoker_amt_male$male, smoker_amt_female$female)
names(smoker_df) = c("Male", "Female")

ggplot(smoker_amt, aes(Issue.year, pc)) + geom_col()