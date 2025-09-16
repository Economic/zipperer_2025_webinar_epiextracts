# OK how do you use the EPI CPS extracts
# first let's open R, orient our selves, and install some packages

# this is Rstudio
# here is console window
# files pane
# environment pane

# TELL FOLKS TO REMOVE AUTOMATIC RDATA LOADING/SAVING

2+2
2019:2023
20
low_wage_threshold = 20

# install packages
# also install skimr
install.packages("skimr")

# after installing package
library(epiextractr)
load_org_sample(2023)

# let's explore the data
org_data = load_org_sample(2023)
# look at data in environment pane
# click on data and look at data browser
# type org_data just to see in console window

# use tidyverse to really explore your data
library(tidyverse)
glimpse(org_data)

# see the distribution of variables
library(skimr)
skim(org_data)

# count the number of wage earners
count(org_data)

wage_earners = filter(org_data, wage > 0)

count(wage_earners)
count(wage_earners, wt = orgwgt)
count(wage_earners, wt = orgwgt / 12)

summarize(wage_earners, sum(orgwgt / 12))
summarize(wage_earners, number_of_workers = sum(orgwgt / 12))
summarize(wage_earners, number_of_workers = sum(orgwgt / 12000000))

# low wage earners

# another wage variable, inclusive of OTC
low_wage_earners = filter(org_data, wage > 0 & wage < 20)
count(low_wage_earners, wt = orgwgt/ 12)

low_wageotc_earners = filter(org_data, wageotc > 0 & wageotc < 20)
count(low_wageotc_earners, wt = orgwgt / 12)

# look at low wage workforce tracker
# do by gender

count(low_wageotc_earners, wt = orgwgt / 12)
count(low_wageotc_earners, female, wt = orgwgt / 12)

# note that this is lopsided because of sexist labor market

# now let's put that in an R script

library(epiextractr)
library(tidyverse)

org_data = load_org_sample(2023)
low_wageotc_earners = filter(org_data, wageotc > 0 & wageotc < 20)
count(wageotc_earners, female, wt = orgwgt / 12)

# let's do a specific state, like GA
# look at microdata site
ga_low_wages = filter(low_wageotc_earners, statefips == 13)
count(ga_low_wages, wt = orgwgt/12)

count(ga_low_wages, female, wt = orgwgt/12000)

# do this by year instead of gender
# modify to 
org_data = load_org_sample(2019:2023)
# then
count(ga_low_wages, year, wt = orgwgt/12000)

# show how you can select just some variables
org_data = load_org_sample(2019:2023, year, orgwgt, wageotc, female, statefips)

# now that's not all the data, look at microdata site
load_org_sample(2023)
# vs: microdata.epi.org
# download the actual data
# make a directory
# then download data
download_cps("org", "/home/bzipperer/cps_data")

# take a break: questions

# load data
# before load_org_sample(): that's just some sample data
# let's use the real data we download with load_org()
# this will give an error
load_org(2023)

# this will work
load_org(2023, .extracts_dir = "/home/bzipperer/cps_data")

load_org(2024, .extracts_dir = "/home/bzipperer/cps_data")

load_org(2025, .extracts_dir = "/home/bzipperer/cps_data")

# this allows us to do analysis by education say age or a different race variable

# but what about this pesky .extracts_dir ?
# use your .Renviron file to have that set by default
usethis::edit_r_environ()
# set EPIEXTRACTS_CPSORG_DIR

# need to restart R
# now load_org() will just work
load_org(2024)

# now do script by wbhao
load_org(2019:2024, year, orgwgt, wageotc, female, wbhao, statefips)

# make our script better

# let's do pipes
library(tidyverse)
library(epiextractr)

org_data = load_org(2024, year, orgwgt, wageotc, female, statefips)

org_data |> 
  filter(wageotc > 0 & wageotc < 20) |> 
  count(female, wt = orgwgt / 12)

org_data |> 
  filter(wageotc > 0 & wageotc < 20) |> 
  filter(statefips == 13) |> 
  count(female, wt = orgwgt / 12)

# let's calculate shares of low wage workers too
org_data |> 
  filter(wageotc > 0) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  count(low_wage_status, wt = orgwgt / 12)

# mean
org_data |> 
  filter(wageotc > 0) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = mean(low_wage_status)
  )

# weighted mean
org_data |> 
  filter(wageotc > 0) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = weighted.mean(low_wage_status, w = orgwgt)
  )

# put it together
org_data |> 
  filter(wageotc > 0) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = weighted.mean(low_wage_status, w = orgwgt),
    low_wage_count = sum(orgwgt / 12)
  )

org_data |> 
  filter(wageotc > 0) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = weighted.mean(low_wage_status, w = orgwgt),
    low_wage_count = sum(low_wage_status * orgwgt / 12)
  )

# now do this by gender
org_data |> 
  filter(wageotc > 0) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = weighted.mean(low_wage_status, w = orgwgt),
    low_wage_count = sum(low_wage_status * orgwgt / 12),
    .by = female
  )

# now restrict to GA
org_data |> 
  filter(wageotc > 0) |> 
  filter(statefips == 13) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = weighted.mean(low_wage_status, w = orgwgt),
    low_wage_count = sum(low_wage_status * orgwgt / 12000),
    .by = female
  )

# write these results to a csv file
results = org_data |> 
  filter(wageotc > 0) |> 
  filter(statefips == 13) |> 
  mutate(low_wage_status = if_else(wageotc < 20, 1, 0)) |> 
  summarize(
    low_wage_share = weighted.mean(low_wage_status, w = orgwgt),
    low_wage_count = sum(low_wage_status * orgwgt / 12000),
    .by = female
  )

write_csv(results, "my_results.csv")


# NEW SLIDE: 
# other analysis you can do
# reference FAQ

# NEW ANALYSIS:
# example employment analysis: use the basic
#you will need to download the basic (takes a while)
# download_cps("basic", "/home/benzipperer/cps_data")
# need to add
# EPIEXTRACTS_CPSBASIC_DIR="/data/cps/basic/epi/"
library(tidyverse)
library(epiextractr)
basic_data = load_basic(2024, year, emp, basicwgt, age, statefips, female) 
  
basic_data |> 
  filter(age >= 25 & age <= 54, basicwgt > 0) |> 
  summarize(prime_age_epop = weighted.mean(emp, w = basicwgt))

# confirm those results with BLS CPS: www.bls.gov/cps

# or maybe just some states
basic_data |> 
  filter(age >= 25 & age <= 54, basicwgt > 0) |> 
  filter(statefips == 13 | statefips == 1 | statefips == 2) |> 
  summarize(
    prime_age_epop = weighted.mean(emp, w = basicwgt),
    .by = statefips
  ) 

# show also statefips %in% c() construct

# CONCLUDE 