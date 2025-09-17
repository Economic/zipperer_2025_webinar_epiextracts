library(tidyverse)
library(epiextractr)

# low wage threshold
low_wage_threshold = 20

# use the CPS ORG
org_data = load_org(2024, year, orgwgt, wage, wageotc, statefips, female, wbhao)

ga_data = org_data |> 
  # wage earners only
  filter(wageotc > 0) |> 
  # in Georgia
  filter(statefips == 13) |> 
  # 2024 only
  filter(year == 2024) |> 
  # low wage indicator
  mutate(low_wage = if_else(wageotc < low_wage_threshold, 1, 0))

# number low-wage in Georgia
ga_data |> 
  count(low_wage, wt = orgwgt / 12)

# share low-wage
ga_data |> 
  summarize(
    weighted.mean(low_wage, w = orgwgt),
    .by = wbhao
  )
  
# analysis by gender
ga_data |> 
  count(female, wt = orgwgt / 12)

# analysis by race
ga_data |> 
  count(wbhao, wt = orgwgt / 12)


