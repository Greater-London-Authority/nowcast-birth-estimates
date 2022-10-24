library(tidyverse)
library(lubridate)

source("R/functions/calc_birth_gp_coefficients.R")
source("R/functions/predict_births.R")

fpath <- list(births_actual = "data/processed/births_actual.rds",
              gp_0 = "data/processed/gp_age_0.rds",
              births_predicted = "outputs/births_predicted.csv",
              birth_gp_coeff = "outputs/birth_gp_coefficients.csv",
              births_all = "outputs/births_all.csv",
              births_predicted_wide = "outputs/predicted_births_wide.csv",
              births_actual_wide = "outputs/actual_births_wide.csv")

# these dates define the period on which the model bases the relationships between patient counts and
# annual births used to predict recent births
date_start <- "2018-07-01"
# leave as "" to use up to the date of the most recent actual birth data
date_end <- ""

#-----

births_actual <- readRDS(fpath$births_actual) %>%
  select(-sex)

gp_0 <- readRDS(fpath$gp_0) %>%
  rename(gp_count = value)

birth_gp_coeff <- calc_birth_gp_coefficients(births_actual, gp_0, date_start, date_end)

births_predicted <- predict_births(birth_gp_coeff, gp_0) %>%
  rename(year_ending_date = date, annual_births = births)

births_all <- bind_rows(
  births_actual %>%
    mutate(ci_lower = births, ci_upper = births, type = "actual") %>%
    rename(year_ending_date = date, annual_births = births),
  births_predicted %>%
    mutate(type = "predicted")
) %>%
  arrange(gss_code, type, year_ending_date)

births_predicted_wide <- births_all %>%
  filter(type == "predicted") %>%
  pivot_longer(cols = c("annual_births", "ci_lower", "ci_upper"),
               names_to = "measure", values_to = "value") %>%
  pivot_wider(names_from = "year_ending_date",
              values_from = "value")

births_actual_wide <- births_all %>%
  filter(type == "actual") %>%
  mutate(measure = "annual_births") %>%
  select(-c(ci_lower, ci_upper)) %>%
  pivot_wider(names_from = "year_ending_date",
              values_from = "annual_births")

write_csv(birth_gp_coeff, fpath$birth_gp_coeff)
write_csv(births_predicted, fpath$births_predicted)
write_csv(births_all, fpath$births_all)
write_csv(births_predicted_wide, fpath$births_predicted_wide)
write_csv(births_actual_wide, fpath$births_actual_wide)
