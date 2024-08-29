# this is Rstudio
# here is console window
# files pane
# environment pane
2+2
2019:2023
17
low_wage_threshold = 17

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
low_wage_earners = filter(org_data, wage > 0 & wage < 17)
count(low_wage_earners, wt = orgwgt/ 12)

low_wageotc_earners = filter(org_data, wageotc > 0 & wageotc < 17)
count(wageotc_earners, wt = orgwgt / 12)

# look at low wage workforce tracker
# do by gender

count(wageotc_earners, wt = orgwgt / 12)
count(wageotc_earners, female, wt = orgwgt / 12)

# note that this is lopsided because of sexist labor market

# now let's put that in an R script

library(epiextractr)
library(tidyverse)

org_data = load_org_sample(2023)
low_wageotc_earners = filter(org_data, wageotc > 0 & wageotc < 17)
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
load_org(2023, .extracts_dir = "/home/bzipperer/cps_data")

# this allows us to do analysis by age, say

# but what about this pesky .extracts_dir ?
# use your .Renviron file to have that set by default
usethis::edit_r_environ()

# need to restart R
# now load_org() will just work
load_org(2023)

load_org(2019:2023, year, orgwgt, wageotc, female, age, statefips)

# let's do pipes
library(tidyverse)
library(epiextractr)

org_data = load_org(2023, year, orgwgt, wageotc, female, statefips)

org_data |> 
  filter(wageotc > 0 & wageotc < 17) |> 
  count(female, wt = orgwgt / 12)

org_data |> 
  filter(wageotc > 0 & wageotc < 17) |> 
  filter(statefips == 13) |> 
  count(female, wt = orgwgt / 12)



