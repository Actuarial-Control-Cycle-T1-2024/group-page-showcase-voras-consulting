############# RUN THIS (LINES 1-215) ONCE #############

install.packages("dplyr", "ggplot2", "tidyverse")
library(dplyr)
library(ggplot2)
library(tidyverse)

options(scipen=10)

# Reading in all needed files
inforce_raw <- read.csv("prem_inforce.csv", header = T)
mortality_raw <- read.csv("srcsc-2024-lumaria-mortality-table.csv", header = T)
mort_loadings <- read.csv("Scaling_Factors.csv", header = T)
acc_factors <- read.csv("accumulation_factors.csv", header = T)
economic <- read.csv("srcsc-2024-lumaria-economic-data.csv", header = T)


## ASSUMPTIONS

# Year variables
original_year <- 2001 # First year of data
latest_year <- 2023 # Latest year of data
years_checked <- 20 # Amount of time to analyse data (must be between 1 and 24)

starting_year <- latest_year - years_checked + 1 # Should start at 2004 

# Growth of new business assumptions [new business]

growth_rate <- 0.016 # Pending Liv's research

yearly_pols <- inforce_raw %>%
  group_by(Issue.year) %>%
  summarise(policies = n()) %>%
  filter(row_number() > 3) %>% # Filter out 2001-3
  mutate(new = floor(growth_rate*policies))

# Gender assumptions [new business]

gender_inforce <- inforce_raw %>%
  group_by(Sex) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))
female_pc <- gender_inforce$pc[1]

# Smoker assumptions [new business]

smoker_amt_male <- inforce_raw %>%
  filter(Sex == "M") %>%
  group_by(Issue.year, Smoker.Status) %>%
  summarise(n = n()) %>%
  mutate(male = n/sum(n)) %>%
  filter(Smoker.Status == "S")

smoker_amt_female <- inforce_raw %>%
  filter(Sex == "F") %>%
  group_by(Issue.year, Smoker.Status) %>%
  summarise(n = n()) %>%
  mutate(female = n/sum(n)) %>%
  filter(Smoker.Status == "S")

smoker_df <- data.frame(smoker_amt_male$male, smoker_amt_female$female)
names(smoker_df) = c("Male", "Female")

smoker_male <- smoker_df$Male
smoker_female <- smoker_df$Female

# Policy type and Face amount assumptions [new business]

policytype <- inforce_raw %>%
  group_by(Issue.age, Policy.type) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n))

spwl <- policytype %>% 
  filter(Policy.type == "SPWL", pc != 1)
spwl_pc <- mean(spwl$pc)

policy_amt <- inforce_raw %>%
  group_by(Policy.type, Face.amount) %>%
  summarise(n=n()) %>%
  mutate(pc = n/sum(n),
         cum = cumsum(pc))

spwl_gen <- function (x) {
  if (x <= policy_amt$cum[1]) {
    return(policy_amt$Face.amount[1])
  } else if (x > policy_amt$cum[1] & x <= policy_amt$cum[2]) {
    return(policy_amt$Face.amount[2])
  } else if (x > policy_amt$cum[2] & x <= policy_amt$cum[3]) {
    return(policy_amt$Face.amount[3])
  } else if (x > policy_amt$cum[3] & x <= policy_amt$cum[4]) {
    return(policy_amt$Face.amount[4])
  } else {
    return(policy_amt$Face.amount[5])
  }
}

t20_gen <- function (x) {
  if (x <= policy_amt$cum[6]) {
    return(policy_amt$Face.amount[6])
  } else if (x > policy_amt$cum[6] & x <= policy_amt$cum[7]) {
    return(policy_amt$Face.amount[7])
  } else if (x > policy_amt$cum[7] & x <= policy_amt$cum[8]) {
    return(policy_amt$Face.amount[8])
  } else if (x > policy_amt$cum[8] & x <= policy_amt$cum[9]) {
    return(policy_amt$Face.amount[9])
  } else if (x > policy_amt$cum[9] & x <= policy_amt$cum[10]) {
    return(policy_amt$Face.amount[10])
  } else {
    return(policy_amt$Face.amount[11])
  }
}

# Underwriting class assumptions [new business]

age_class_ns <- inforce_raw %>%
  filter(Smoker.Status == "NS") %>%
  group_by(Issue.age, Underwriting.Class) %>%
  summarise(n=n()) %>%
  mutate(pc=n/sum(n))

vl_risk <- mean(filter(age_class_ns, Underwriting.Class == "very low risk")$pc)  
low_risk <- mean(filter(age_class_ns, Underwriting.Class == "low risk")$pc)  
moderate_risk_ns <- mean(filter(age_class_ns, Underwriting.Class == "moderate risk")$pc)  
high_risk_ns <- mean(filter(age_class_ns, Underwriting.Class == "high risk")$pc)

risk_table <- data.frame(class = c("very low risk", "low risk", "moderate risk", "high risk"),
                         risk = c(vl_risk, low_risk, moderate_risk_ns, high_risk_ns))
risk_table <- risk_table %>% mutate(cum = cumsum(risk))

class_gen <- function (x) {
  if (x <= risk_table$cum[1]) {
    return(risk_table$class[1])
  } else if (x > risk_table$cum[1] & x <= risk_table$cum[2]) {
    return(risk_table$class[2])
  } else if (x > risk_table$cum[2] & x <= risk_table$cum[3]) {
    return(risk_table$class[3])
  } else {
    return(risk_table$class[4])
  }
}

age_class_s <- inforce_raw %>%
  filter(Smoker.Status == "S") %>%
  group_by(Issue.age, Underwriting.Class) %>%
  summarise(n=n()) %>%
  mutate(pc=n/sum(n))

moderate_s <- mean(filter(age_class_s, Underwriting.Class == "moderate risk")$pc)  

# Mortality assumptions

mortality <- mortality_raw$Mortality.Rate
mort_mappings <- c("Age", "M", "F", "MS", "MNS", "FS", "FNS", "very low risk", 
                   "low risk", "moderate risk", "high risk")

# These are from Victor's screenshot
smoke_cess <- 0.441289821
cancer_prev <- 0.925
heart_screen <- 0.925

# Cause : cause of death, smoker : smoker status,
# duration : how long they've been in the policy for
undead_mort <- function (cause, smoker, duration) {
  if(cause == "I00-I99" & smoker == "S") {
    return(smoke_cess*heart_screen^duration)
  } else if (cause == "I00-I99" & smoker == "NS") {
    return(heart_screen^duration)
  } else if (cause == "C00-D48") {
    return(cancer_prev^duration)
  } else if (cause == "J00-J98" & smoker == "S") {
    return(smoke_cess)
  } else {
    return (1)
  }
}

# Lapse assumptions

lapse_count <- inforce_raw %>%
  filter(Lapse.Indicator != "<NA>") %>%
  group_by(Year.of.Lapse) %>%
  summarise(lapses = n())

death_count <- inforce_raw %>%
  filter(Death.indicator == 1) %>%
  group_by(Year.of.Death) %>%
  summarise(deaths = n())

newclaims <- inforce_raw %>%
  group_by(Issue.year) %>%
  summarise(new = n()) %>%
  mutate(deaths = death_count$deaths,
         lapses = lapse_count$lapses) %>%
  mutate(policies = cumsum(new)-deaths-lapses) %>%
  mutate(death_prop = deaths/policies)

lapse_amt <- inforce_raw %>%
  group_by(Year.of.Lapse) %>%
  summarise(lapses = n()) %>%
  filter(row_number() <= n()-1) %>%
  mutate(inforce_pols = newclaims$policies,
         lapse_pc = lapses/inforce_pols)

lapse_rate <- lapse_amt$lapse_pc

# Expense assumptions (all are in terms of today's money)

scp_exp <- 2177.5 # per participant
cpi_exp <- 52.5 # per participant per year
hhs_exp <- 217.5 # per participant per year

# Economic assumptions

economic_data <- economic[,c(-3, -4)] %>%
  filter(row_number() > 39) 
economic_data <- economic_data %>%
  rename(Spot.rate = colnames(economic_data)[3])

f_inflation <- mean(economic_data$Inflation[-c(22,23)])
f_spotrate <- mean(economic_data$Spot.rate)
economic_data <- rbind(economic_data, 
                       data.frame(Year = c(2024:(2024+19)), 
                                  Inflation = c(rep(f_inflation, 20)),
                                  Spot.rate = c(rep(f_spotrate, 20))))

# Premium assumptions

premium_calc <- function (type, issue_year, issue_age, sex, smoker, class, face_amount) {
  
  benefits <- 0
  premiums <- 0
  cum_live <- 1
  
  if (type == "T20") {
    for (year in issue_year:(issue_year + 20)) {
      count <- year - issue_year
      index <- match(year, economic_data$Year)
      discount <- (1 + economic_data$Spot.rate[index]) /  (1+economic_data$Inflation[index])
      age <- issue_age + (year - issue_year)
      status <- paste0(sex, smoker)
      mort_rate <- (mortality[age] * 
                      mort_loadings[age, match(sex, mort_mappings)] * 
                      mort_loadings[age, match(status, mort_mappings)] * 
                      mort_loadings[age, match(class, mort_mappings)] *
                      cancer_prev * heart_screen * if(status == "FS" | status == "MS") {smoke_cess} else {1})
      
      live_rate <- 1 - mort_rate
      cum_live <- cum_live * live_rate
      
      benefits <- benefits + mort_rate/discount^(count+1)
      premiums <- premiums + cum_live/discount^count
    }
  } else {
    premiums <- 1
    for (year in issue_year:(issue_year + (120 - issue_age))) {
      count <- year - issue_year
      index <- match(year, economic_data$Year)
      if(is.na(index) == FALSE) {
        spot <- economic_data$Spot.rate[index]
        discount <- (1 + spot)/(1+ economic_data$Inflation[index])
      } else {
        spot <- f_spotrate
        discount <- (1 + spot)/(1+ f_inflation)
      }
      
      age <- issue_age + (year - issue_year)
      status <- paste0(sex, smoker)
      mort_rate <- (mortality[age] * 
                      mort_loadings[age, match(sex, mort_mappings)] * 
                      mort_loadings[age, match(status, mort_mappings)] * 
                      mort_loadings[age, match(class, mort_mappings)] *
                      cancer_prev * heart_screen * if(status == "FS" | status == "MS") {smoke_cess} else {1})
      
      live_rate <- 1 - mort_rate
      cum_live <- cum_live * live_rate
      benefits <- benefits + mort_rate/discount^(count+1)
      premiums <- premiums * (1 + spot)
    }
  }

  return(face_amount * benefits/premiums)
}

# Preparing dataset

engine_data <- inforce_raw

###############################################################

################ ENGINE (LINES 220-436) #####################
## RUN THIS AS MANY TIMES AS YOU WANT TO GET DIFF NUMBERS 

# Old business engine

engine_edit <- engine_data

old_revenue <- 0
old_expenses <- 0
old_liabilities <- 0

for (year in starting_year:latest_year) {
  print(year)
  # Calling assumptions
  lapse_prob <- lapse_rate[year - starting_year + 1]

  # ALL policies in force (alive)
  old_eligible <- engine_edit %>% 
    filter(Issue.year <= year, 
           (is.na(Death.indicator) == TRUE | Year.of.Death > year),
           (is.na(Lapse.Indicator) == TRUE | Year.of.Lapse > year))
  
  # Collect present value of premiums if policy still in force
  old_revenue <- old_revenue + 
    ((old_eligible %>% filter(Policy.type == "T20") %>% 
      summarise(total_prem = sum(Premium))) +
    (old_eligible %>% filter(Policy.type == "SPWL" & Issue.year == year) %>% 
      summarise(total_prem = sum(Premium)))) * acc_factors$Factor[year - 2004 + 1]
  
  # Adding YEARLY expenses for ALL policies in force (alive)
  old_expenses <- old_expenses + nrow(old_eligible) * (cpi_exp + hhs_exp)
  
  # Taking policies that would die in the current year
  extract <- engine_edit %>%
    filter(Year.of.Death == year | undead == TRUE) 
  
  print("rev+exp taken, data extracted")
  
  # Looping through each of those policies
  for (policy in 1:nrow(extract)) {
    
    # Checking undead policies
    if (extract$undead[policy] == TRUE) {
      # Roll for lapse
      if (runif(1,0,1) <= lapse_prob) {
        extract$Lapse.Indicator[policy] <- 1
        extract$Year.of.Lapse[policy] <- year
        extract$undead[policy] <- FALSE
      } else {
        # Roll for death
        age <- extract$Issue.age[policy] + (year - extract$Issue.year[policy])
        status <- paste(extract$Sex[policy], extract$Smoker.Status[policy], sep="")
        mort_rate <- undead_mort(
          extract$Cause.of.Death[policy],
          extract$Smoker.Status[policy],
          year - extract$Issue.year[policy]
        )
        if(runif(1,0,1) < mort_rate) { # Policyholder dies
          extract$Death.indicator[policy] <- 1
          extract$Year.of.Death[policy] <- year
          extract$undead[policy] <- FALSE
          extract$true_death[policy] <- TRUE
          # Adding liabilities
          old_liabilities <- old_liabilities + extract$Face.amount[policy] * acc_factors$Factor[year - 2004 + 1]
        }
      }  
    } else if (extract$Death.indicator[policy] == 1) { # Checking dead policies
      # Roll for actual death (with initiatives)
      age <- extract$Issue.age[policy] + (year - extract$Issue.year[policy])
      status <- paste0(extract$Sex[policy], extract$Smoker.Status[policy])
      mort_rate <- undead_mort(
        extract$Cause.of.Death[policy],
        extract$Smoker.Status[policy],
        year - extract$Issue.year[policy]
      )      
      if(runif(1,0,1) > mort_rate) { # If they survive
        extract$Death.indicator[policy] <- NA
        extract$Year.of.Death[policy] <- NA
        extract$undead[policy] <- TRUE
      } else {
        extract$true_death[policy] <- TRUE
        # Adding liabilities
        old_liabilities <- old_liabilities + extract$Face.amount[policy] * acc_factors$Factor[year - 2004 + 1]
      }
    }
  }

  print("data simulated")
  
  # Replace the engine_edit data
  engine_edit <- engine_edit %>%
    filter((Year.of.Death != year | is.na(Death.indicator) == TRUE) & undead == FALSE)
  engine_edit <- rbind(extract, engine_edit)
  
  print("data replaced")
}

old_expenses <- old_expenses + nrow(engine_edit %>% filter(
  Issue.year >= starting_year, Smoker.Status == "S"
)) * scp_exp

print("final expense added")

# New business engine

new_business <- engine_data[FALSE,]

new_expenses <- 0
new_liabilities <- 0
new_revenue <- 0

for(year in starting_year:latest_year) {
  print(year)
  counter <- year - starting_year + 1
  
  # Generating new policyholders
  for(i in 1:yearly_pols$new[counter]) {
    # Simulate age
    new_age <- round(runif(1, 26, 65),0)
    # Simulate gender and smoker status based on gender
    # SMOKER PROB WILL CHANGE depending on liv's research
    if (runif(1,0,1)<=female_pc) { 
      new_sex <- "F" 
      new_smoker <- if(runif(1,0,1) <= smoker_df$Female[counter]) {"S"} else {"NS"}
    } else { 
      new_sex <- "M"
      new_smoker <- if(runif(1,0,1) <= smoker_df$Male[counter]) {"S"} else {"NS"}
    }
    # Simulate policy type based on age
    if (new_age < 35) {
      new_type <- "T20"
    } else if (new_age > 55) {
      new_type <- "SPWL" 
    } else { 
      new_type <- if (runif(1,0,1) < spwl_pc) {"SPWL"} else {"T20"}
    }
    # Simulate face amount based on policy type
    if (new_type == "SPWL") {
      new_amt <- spwl_gen(runif(1,0,1))
    } else {
      new_amt <- t20_gen(runif(1,0,1))
    }
    # Simulate underwriting class based on smoker status and age
    if (new_smoker == "S") {
      new_class <- if(runif(1,0,1) <= moderate_s) 
        {"moderate risk"} else {"high risk"}
    } else {
      new_class <- class_gen(runif(1,0,1))
    }
    
    # Simulate premium
    new_premium <- premium_calc(new_type, year, new_age, new_sex,
                                new_smoker, new_class, new_amt)
    
    new_business[nrow(new_business)+1,] <- list(new_type, year, new_age, 
                                            new_sex, new_premium, new_amt, 
                                            new_smoker, new_class, NA, NA, 
                                            NA, NA, NA, NA, NA)
  }
  print("new policyholders generated")
  # End generating policyholders
  
  lapse_prob <- lapse_rate[year - starting_year + 1]
  
  # Going through each policyholder
  for (policy in 1:nrow(new_business)) {
    
    # Checking policies in force (alive)
    if (is.na(new_business$Death.indicator[policy]) == T & 
        is.na(new_business$Lapse.Indicator[policy]) == T) {
      
      # Collect present value of premiums
      if ((new_business$Policy.type[policy] == "T20" |
           (new_business$Policy.type[policy] == "SPWL" & new_business$Issue.year[policy] == year))) {
        new_revenue <- new_revenue + new_business$Premium[policy] * acc_factors$Factor[year - 2004 + 1]
      } 
      
      # Then take YEARLY expenses
      new_expenses <- new_expenses + cpi_exp + hhs_exp
      
      # Roll for lapse
      if (runif(1,0,1) <= lapse_prob) {
        new_business$Lapse.Indicator[policy] <- 1
        new_business$Year.of.Lapse[policy] <- year
      } else {
        # Roll for death
        age <- new_business$Issue.age[policy] + (year - new_business$Issue.year[policy])
        status <- paste0(new_business$Sex[policy], new_business$Smoker.Status[policy])
        mort_rate <- (mortality[age] * 
                        mort_loadings[age, match(new_business$Sex[policy], mort_mappings)] * 
                        mort_loadings[age, match(status, mort_mappings)] * 
                        mort_loadings[age, match(new_business$Underwriting.Class[policy], mort_mappings)] *
                        cancer_prev * heart_screen * if(status == "FS" | status == "MS") {smoke_cess} else {1})
        if(runif(1,0,1) < mort_rate) { # Policyholder dies
          new_business$Death.indicator[policy] <- 1
          new_business$Year.of.Death[policy] <- year
          # Adding liabilities
          new_liabilities <- new_liabilities + new_business$Face.amount[policy] * acc_factors$Factor[year - 2004 + 1]
        }
      }
    }
  }
  
  print("data simulated")
}

# Adding one-off SCP expense for each smoker
new_expenses <- new_expenses + nrow(filter(new_business, Smoker.Status == "S")) * scp_exp
print("final expenses added")

# Adding statistics together

expenses <- old_expenses + new_expenses
liabilities <- old_liabilities + new_liabilities
revenue <- old_revenue + new_revenue
profit <- revenue - liabilities - expenses
print(paste0("Expenses: ", expenses, 
             ", Liabilities: ", liabilities,
             ", Revenue: ", revenue,
             ", Profit: ", profit))

(profit/1.743)/20

###############################################################

## Diagnostics: run this after every engine run if you want
## (compare newclaims, engineclaims and nbclaims dataframes)

# for old business 
elapse_count <- engine_edit %>%
  filter(Lapse.Indicator != "<NA>") %>%
  group_by(Year.of.Lapse) %>%
  summarise(lapses = n())

edeath_count <- engine_edit %>%
  filter(Death.indicator == 1) %>%
  group_by(Year.of.Death) %>%
  summarise(deaths = n())

engineclaims <- engine_edit %>%
  group_by(Issue.year) %>%
  summarise(new = n()) %>%
  mutate(deaths = edeath_count$deaths,
         lapses = elapse_count$lapses) %>%
  mutate(policies = cumsum(new)-deaths-lapses) %>%
  mutate(death_prop = deaths/policies)

# for new business
nlapse_count <- new_business %>%
  filter(Lapse.Indicator != "<NA>") %>%
  group_by(Year.of.Lapse) %>%
  summarise(lapses = n())

ndeath_count <- new_business %>%
  filter(Death.indicator == 1) %>%
  group_by(Year.of.Death) %>%
  summarise(deaths = n())# %>%
#  add_row(Year.of.Death=2004, deaths=0, .before = 1)

nbclaims <- new_business %>%
  group_by(Issue.year) %>%
  summarise(new = n()) %>%
  mutate(deaths = ndeath_count$deaths,
         lapses = nlapse_count$lapses) %>%
  mutate(policies = cumsum(new)-deaths-lapses) %>%
  mutate(death_prop = deaths/policies)


# random sense checks
lib <- engine_data %>%
  filter(Death.indicator == 1) %>%
  summarise(sum = sum(Face.amount))
lib
